<?php
session_start();
require_once '../config/database.php';

// Check if user is logged in and is a reviewer
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'reviewer') {
    header("Location: ../index.php");
    exit();
}

// Get reviewer's assigned papers (excluding reviewed ones)
$sql = "SELECT p.*, u.name as author_name, c.name as category_name 
        FROM papers p 
        JOIN assignments a ON p.id = a.paper_id 
        JOIN users u ON p.author_id = u.id 
        LEFT JOIN categories c ON p.category_id = c.id 
        LEFT JOIN reviews r ON p.id = r.paper_id AND r.reviewer_id = ?
        WHERE a.reviewer_id = ? 
        AND p.status = 'under_review'
        AND r.id IS NULL
        ORDER BY p.created_at DESC";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "ii", $_SESSION['user_id'], $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$assigned_papers = mysqli_stmt_get_result($stmt);

// Get reviewed papers
$sql = "SELECT 
            p.id as paper_id,
            p.title,
            p.author_id,
            p.status,
            p.file_path,
            p.file_name,
            u.name as author_name,
            r.id as review_id,
            r.score,
            r.recommendation
        FROM papers p 
        JOIN reviews r ON p.id = r.paper_id 
        JOIN users u ON p.author_id = u.id 
        WHERE r.reviewer_id = ? 
        ORDER BY r.created_at DESC";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$reviewed_papers = mysqli_stmt_get_result($stmt);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reviewer Dashboard - Online Paper Submission System</title>
    <link rel="stylesheet" href="../assets/css/reviewer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"></script>
</head>
<body>
    <div id="particles-js"></div>
    <div class="container">
        <div class="dashboard-header">
            <h1>Reviewer Dashboard</h1>
            <div class="user-info">
                <span>Welcome, <?php echo isset($_SESSION['user_name']) ? htmlspecialchars($_SESSION['user_name']) : 'Reviewer'; ?></span>
                <a href="../logout.php" class="logout-btn">Logout</a>
            </div>
        </div>

        <div class="dashboard-content">
            <div class="stats-section">
                <div class="stat-card">
                    <h3>Assigned Papers</h3>
                    <p><?php echo mysqli_num_rows($assigned_papers); ?></p>
                </div>
                <div class="stat-card">
                    <h3>Reviewed Papers</h3>
                    <p><?php echo mysqli_num_rows($reviewed_papers); ?></p>
                </div>
            </div>

            <div class="papers-section">
                <h2>Assigned Papers</h2>
                <div class="papers-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Category</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while ($paper = mysqli_fetch_assoc($assigned_papers)): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($paper['title']); ?></td>
                                <td><?php echo htmlspecialchars($paper['author_name']); ?></td>
                                <td><?php echo htmlspecialchars($paper['category_name']); ?></td>
                                <td>
                                    <span class="status <?php echo $paper['status']; ?>">
                                        <?php 
                                        $status = ucfirst(str_replace('_', ' ', $paper['status']));
                                        echo $status;
                                        if ($paper['status'] === 'under_review') {
                                            $sql = "SELECT r.id FROM reviews r WHERE r.paper_id = ? AND r.reviewer_id = ?";
                                            $stmt = mysqli_prepare($conn, $sql);
                                            mysqli_stmt_bind_param($stmt, "ii", $paper['id'], $_SESSION['user_id']);
                                            mysqli_stmt_execute($stmt);
                                            $result = mysqli_stmt_get_result($stmt);
                                            if (mysqli_num_rows($result) > 0) {
                                                echo " (Review Submitted)";
                                            }
                                        }
                                        ?>
                                    </span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="../download.php?paper_id=<?php echo $paper['id']; ?>" class="action-btn view">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                        <a href="review_paper.php?paper_id=<?php echo $paper['id']; ?>" class="action-btn review">
                                            <i class="fas fa-edit"></i> Review
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="papers-section">
                <h2>Reviewed Papers</h2>
                <div class="papers-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Score</th>
                                <th>Recommendation</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while ($paper = mysqli_fetch_assoc($reviewed_papers)): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($paper['title']); ?></td>
                                <td><?php echo htmlspecialchars($paper['author_name']); ?></td>
                                <td><?php echo $paper['score']; ?></td>
                                <td>
                                    <span class="status <?php echo $paper['recommendation']; ?>">
                                        <?php echo ucfirst(str_replace('_', ' ', $paper['recommendation'])); ?>
                                    </span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="../download.php?paper_id=<?php echo intval($paper['paper_id']); ?>" class="action-btn view">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>
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
    </script>
</body>
</html>