<?php
session_start();
require_once '../config/database.php';

// Check if user is logged in and is a reviewer
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'reviewer') {
    header("Location: ../index.php");
    exit();
}

// Get paper ID from URL
$paper_id = isset($_GET['paper_id']) ? intval($_GET['paper_id']) : 0;

// If we're handling a form submission, get paper_id from POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $paper_id = isset($_POST['paper_id']) ? intval($_POST['paper_id']) : $paper_id;
}

if ($paper_id <= 0) {
    die("Error: Invalid paper ID");
}

// Debug output for paper ID
error_log("Paper ID from URL: " . $paper_id);
error_log("User ID: " . $_SESSION['user_id']);

// Check if paper exists and reviewer is assigned
$sql = "SELECT p.id as paper_id, p.title, a.id as assignment_id 
        FROM papers p 
        JOIN assignments a ON p.id = a.paper_id 
        WHERE p.id = ? AND a.reviewer_id = ?";
$stmt = mysqli_prepare($conn, $sql);
if (!$stmt) {
    die("Error preparing SQL: " . mysqli_error($conn));
}

mysqli_stmt_bind_param($stmt, "ii", $paper_id, $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$paper_data = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

if (!$paper_data) {
    die("Error: Paper not found or you are not assigned to review this paper");
}

// Debug output
error_log("Paper data: " . print_r($paper_data, true));
error_log("Paper ID: " . $paper_data['paper_id']);
error_log("Assignment ID: " . $paper_data['assignment_id']);

// Get existing review if any
$sql = "SELECT * FROM reviews WHERE paper_id = ? AND reviewer_id = ?";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "ii", $paper_data['paper_id'], $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$review = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

// Debug information (only visible in development)
if (isset($_GET['debug'])) {
    echo "<pre style='background-color: #f9f9f9; padding: 10px; border: 1px solid #ddd;'>";
    echo "Raw paper_id from URL: " . htmlspecialchars($_GET['paper_id'] ?? 'Not set') . "<br>";
    echo "Parsed paper_id: " . ($paper_id !== null ? $paper_id : 'Not set') . "<br>";
    echo "User ID: " . $_SESSION['user_id'] . "<br>";
    echo "Paper found: Yes<br>";
    echo "Paper Title: " . htmlspecialchars($paper_data['title']) . "<br>";
    echo "Paper ID from database: " . $paper_data['paper_id'] . "<br>";
    echo "Assignment ID: " . $paper_data['assignment_id'] . "<br>";
    echo "</pre>";
}

// Handle review submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Verify database connection
    if (!$conn) {
        $_SESSION['message'] = "Unsuccessful: No database connection";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }
    
    // Verify we're using the correct database
    if (!$conn->select_db(DB_NAME)) {
        $_SESSION['message'] = "Unsuccessful: Could not select database";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }
    
    // Debug POST data
    error_log("POST data: " . print_r($_POST, true));
    
    // Get paper_id from POST
    $paper_id = isset($_POST['paper_id']) ? intval($_POST['paper_id']) : 0;
    
    if ($paper_id <= 0) {
        $_SESSION['message'] = "Unsuccessful: Invalid paper ID";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }
    
    // Get other form fields
    $score = isset($_POST['score']) ? intval($_POST['score']) : 0;
    $comments = isset($_POST['comments']) ? mysqli_real_escape_string($conn, $_POST['comments']) : '';
    $recommendation = isset($_POST['recommendation']) ? mysqli_real_escape_string($conn, $_POST['recommendation']) : '';
    
    // Validate input
    if ($score < 0 || $score > 100) {
        $_SESSION['message'] = "Unsuccessful: Score must be between 0 and 100";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }
    if (empty($comments)) {
        $_SESSION['message'] = "Unsuccessful: Comments are required";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }
    if (empty($recommendation)) {
        $_SESSION['message'] = "Unsuccessful: Recommendation is required";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }
    
    // Verify reviews table exists and has correct structure
    $check_sql = "SHOW TABLES LIKE 'reviews'";
    $result = mysqli_query($conn, $check_sql);
    
    if (mysqli_num_rows($result) == 0) {
        // Create reviews table if it doesn't exist
        $create_sql = "CREATE TABLE IF NOT EXISTS reviews (
            id INT AUTO_INCREMENT PRIMARY KEY,
            paper_id INT NOT NULL,
            reviewer_id INT NOT NULL,
            comments TEXT NOT NULL,
            score INT NOT NULL,
            recommendation ENUM('accept', 'minor_revision', 'major_revision', 'reject') NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (paper_id) REFERENCES papers(id),
            FOREIGN KEY (reviewer_id) REFERENCES users(id),
            UNIQUE KEY unique_review (paper_id, reviewer_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        
        if (!mysqli_query($conn, $create_sql)) {
            $_SESSION['message'] = "Unsuccessful: Error creating reviews table";
            header("Location: review_paper.php?paper_id=" . $paper_id);
            exit();
        }
    }
    
    // Verify assignments table exists and has correct structure
    $check_sql = "SHOW TABLES LIKE 'assignments'";
    $result = mysqli_query($conn, $check_sql);
    
    if (mysqli_num_rows($result) == 0) {
        // Create assignments table if it doesn't exist
        $create_sql = "CREATE TABLE IF NOT EXISTS assignments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            paper_id INT NOT NULL,
            reviewer_id INT NOT NULL,
            status ENUM('pending', 'completed') DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (paper_id) REFERENCES papers(id),
            FOREIGN KEY (reviewer_id) REFERENCES users(id),
            UNIQUE KEY unique_assignment (paper_id, reviewer_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        
        if (!mysqli_query($conn, $create_sql)) {
            $_SESSION['message'] = "Unsuccessful: Error creating assignments table";
            header("Location: review_paper.php?paper_id=" . $paper_id);
            exit();
        }
    }
    
    // First get the assignment details
    $sql = "SELECT a.paper_id, a.reviewer_id 
            FROM assignments a 
            WHERE a.paper_id = ? AND a.reviewer_id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    if (!$stmt) {
        $_SESSION['message'] = "Unsuccessful: Error preparing assignment SQL";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }
    mysqli_stmt_bind_param($stmt, "ii", $paper_id, $_SESSION['user_id']);
    mysqli_stmt_execute($stmt);
    $assignment_data = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));

    if (!$assignment_data) {
        $_SESSION['message'] = "Unsuccessful: You are not assigned to review this paper";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }

    // Start transaction
    mysqli_begin_transaction($conn);

    // Check if review exists using paper_id and reviewer_id
    $sql = "SELECT id FROM reviews WHERE paper_id = ? AND reviewer_id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    if (!$stmt) {
        $_SESSION['message'] = "Unsuccessful: Error preparing review check SQL";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }
    mysqli_stmt_bind_param($stmt, "ii", $assignment_data['paper_id'], $assignment_data['reviewer_id']);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $existing_review = mysqli_fetch_assoc($result);

    // Prepare the appropriate SQL query
    if ($existing_review) {
        // Update existing review using paper_id and reviewer_id
        $sql = "UPDATE reviews SET 
                score = ?, 
                comments = ?, 
                recommendation = ?, 
                updated_at = NOW()
                WHERE paper_id = ? AND reviewer_id = ?";
        $stmt = mysqli_prepare($conn, $sql);
        if (!$stmt) {
            $_SESSION['message'] = "Unsuccessful: Error preparing update SQL";
            header("Location: review_paper.php?paper_id=" . $paper_id);
            exit();
        }
        mysqli_stmt_bind_param($stmt, "issii", $score, $comments, $recommendation, $assignment_data['paper_id'], $assignment_data['reviewer_id']);
    } else {
        // Insert new review
        $sql = "INSERT INTO reviews (paper_id, reviewer_id, score, comments, recommendation) 
                VALUES (?, ?, ?, ?, ?)";
        $stmt = mysqli_prepare($conn, $sql);
        if (!$stmt) {
            $_SESSION['message'] = "Unsuccessful: Error preparing insert SQL";
            header("Location: review_paper.php?paper_id=" . $paper_id);
            exit();
        }
        mysqli_stmt_bind_param($stmt, "iiiss", $assignment_data['paper_id'], $assignment_data['reviewer_id'], $score, $comments, $recommendation);
    }

    // Execute the review query
    if (!mysqli_stmt_execute($stmt)) {
        mysqli_rollback($conn);
        error_log("Error saving review: " . mysqli_stmt_error($stmt) . " for paper_id: " . $assignment_data['paper_id'] . ", reviewer_id: " . $assignment_data['reviewer_id']);
        $_SESSION['message'] = "Unsuccessful: Error saving review";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }

    // Check affected rows
    $affected_rows = mysqli_stmt_affected_rows($stmt);
    if ($affected_rows == 0) {
        mysqli_rollback($conn);
        error_log("No rows affected for paper_id: " . $assignment_data['paper_id'] . ", reviewer_id: " . $assignment_data['reviewer_id']);
        $_SESSION['message'] = "Unsuccessful: No changes made to the database";
        header("Location: review_paper.php?paper_id=" . $paper_id);
        exit();
    }

    // Commit transaction
    mysqli_commit($conn);

    // Add this for debugging
    error_log("Review saved successfully for paper_id: " . $assignment_data['paper_id'] . ", reviewer_id: " . $assignment_data['reviewer_id']);
    $_SESSION['message'] = "Review updated successfully";

    // Update paper status to 'Under Review'
    $sql = "UPDATE papers SET status = 'Under Review' WHERE id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    if (!$stmt) {
        die("Error preparing paper status update SQL: " . mysqli_error($conn));
    }
    mysqli_stmt_bind_param($stmt, "i", $assignment_data['paper_id']);
    mysqli_stmt_execute($stmt);

    // Check if all reviews are completed
    $sql = "SELECT COUNT(*) as total_reviews, 
            (SELECT COUNT(*) FROM assignments WHERE paper_id = ?) as total_assignments
            FROM reviews WHERE paper_id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    if (!$stmt) {
        die("Error preparing review count SQL: " . mysqli_error($conn));
    }
    mysqli_stmt_bind_param($stmt, "ii", $assignment_data['paper_id'], $assignment_data['paper_id']);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $stats = mysqli_fetch_assoc($result);

    // If all assignments have reviews, update paper status to 'Reviewed'
    if ($stats && $stats['total_reviews'] >= $stats['total_assignments']) {
        $sql = "UPDATE papers SET status = 'Reviewed' WHERE id = ?";
        $stmt = mysqli_prepare($conn, $sql);
        if (!$stmt) {
            die("Error preparing paper status update SQL: " . mysqli_error($conn));
        }
        mysqli_stmt_bind_param($stmt, "i", $assignment_data['paper_id']);
        mysqli_stmt_execute($stmt);
    }

    // Redirect with success message
    header("Location: review_paper.php?paper_id=" . $assignment_data['paper_id']);
    exit();
}

// Clear message after displaying
if (isset($_SESSION['message'])) {
    $message = $_SESSION['message'];
    unset($_SESSION['message']);
} else {
    $message = '';
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Paper - <?php echo htmlspecialchars($paper_data['title']); ?></title>
    <link rel="stylesheet" href="../assets/css/reviewer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"></script>
</head>
<body>
    <div id="particles-js"></div>
    <div class="container">
        <div class="dashboard-header">
            <h1>Review Paper: <?php echo htmlspecialchars($paper_data['title']); ?></h1>
            <div class="user-info">
                <span>Welcome, <?php echo isset($_SESSION['user_name']) ? htmlspecialchars($_SESSION['user_name']) : 'Reviewer'; ?></span>
                <a href="../logout.php" class="logout-btn">Logout</a>
            </div>
        </div>

        <div class="review-content">
            <?php if ($message): ?>
                <div class="alert <?php echo strpos($message, 'successfully') !== false ? 'alert-success' : 'alert-danger'; ?>">
                    <?php echo htmlspecialchars($message); ?>
                    <button class="close-btn">&times;</button>
                </div>
            <?php endif; ?>

            <div class="review-form">
                <form method="POST" action="review_paper.php">
                    <input type="hidden" name="paper_id" value="<?php echo htmlspecialchars($paper_data['paper_id']); ?>">
                    <div class="form-group">
                        <label for="score">Score (0-100)</label>
                        <input type="number" id="score" name="score" min="0" max="100" required 
                               value="<?php echo $review ? htmlspecialchars($review['score']) : ''; ?>">
                    </div>

                    <div class="form-group">
                        <label for="comments">Comments</label>
                        <textarea id="comments" name="comments" rows="5" required><?php 
                            echo $review ? htmlspecialchars($review['comments']) : ''; 
                        ?></textarea>
                    </div>

                    <div class="form-group">
                        <label for="recommendation">Recommendation</label>
                        <select id="recommendation" name="recommendation" required>
                            <option value="">Select recommendation</option>
                            <option value="accept" <?php echo $review && $review['recommendation'] === 'accept' ? 'selected' : ''; ?>>Accept</option>
                            <option value="minor_revision" <?php echo $review && $review['recommendation'] === 'minor_revision' ? 'selected' : ''; ?>>Minor Revision Required</option>
                            <option value="major_revision" <?php echo $review && $review['recommendation'] === 'major_revision' ? 'selected' : ''; ?>>Major Revision Required</option>
                            <option value="reject" <?php echo $review && $review['recommendation'] === 'reject' ? 'selected' : ''; ?>>Reject</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <a href="dashboard.php" class="action-btn cancel">Cancel</a>
                        <button type="submit" class="action-btn submit">Submit Review</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        particlesJS('particles-js', {
            "particles": {
                "number": {
                    "value": 80,
                    "density": {
                        "enable": true,
                        "value_area": 800
                    }
                },
                "color": {
                    "value": ["#00ffcc", "#3300ff", "#ff00cc"]
                },
                "shape": {
                    "type": "circle",
                    "stroke": {
                        "width": 0,
                        "color": "#000000"
                    }
                },
                "opacity": {
                    "value": 0.5,
                    "random": true,
                    "anim": {
                        "enable": true,
                        "speed": 1,
                        "opacity_min": 0.1,
                        "sync": false
                    }
                },
                "size": {
                    "value": 3,
                    "random": true,
                    "anim": {
                        "enable": true,
                        "speed": 2,
                        "size_min": 0.1,
                        "sync": false
                    }
                },
                "line_linked": {
                    "enable": true,
                    "distance": 150,
                    "color": "#00ffcc",
                    "opacity": 0.4,
                    "width": 1
                },
                "move": {
                    "enable": true,
                    "speed": 2,
                    "direction": "none",
                    "random": true,
                    "straight": false,
                    "out_mode": "out",
                    "bounce": false
                }
            },
            "interactivity": {
                "detect_on": "canvas",
                "events": {
                    "onhover": {
                        "enable": true,
                        "mode": "grab"
                    },
                    "onclick": {
                        "enable": true,
                        "mode": "push"
                    },
                    "resize": true
                },
                "modes": {
                    "grab": {
                        "distance": 140,
                        "line_linked": {
                            "opacity": 1
                        }
                    },
                    "bubble": {
                        "distance": 400,
                        "size": 40,
                        "duration": 2,
                        "opacity": 8,
                        "speed": 3
                    },
                    "repulse": {
                        "distance": 200,
                        "duration": 0.4
                    },
                    "push": {
                        "particles_nb": 4
                    },
                    "remove": {
                        "particles_nb": 2
                    }
                }
            },
            "retina_detect": true
        });

        // Close alert button functionality
        document.querySelectorAll('.close-btn').forEach(button => {
            button.addEventListener('click', () => {
                button.parentElement.style.display = 'none';
            });
        });
    </script>
</body>
</html>