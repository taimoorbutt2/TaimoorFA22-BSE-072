<?php
session_start();
require_once '../config/database.php';

// Fetch current user info
$sql = "SELECT name FROM users WHERE id = ?";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$user = mysqli_fetch_assoc($result);

if (!$user) {
    error_log("User not found for ID: " . $_SESSION['user_id']);
    header("Location: ../index.php");
    exit();
}

// Check if user is logged in and is an admin
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header("Location: ../index.php");
    exit();
}

// Handle assignment actions
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    error_log("Assignment request received: " . print_r($_POST, true));
    
    switch ($_POST['action']) {
        case 'assign':
            $paperId = intval($_POST['paper_id'] ?? 0);
            $reviewerId = intval($_POST['reviewer_id'] ?? 0);
            
            error_log("Assignment attempt: Paper ID=$paperId, Reviewer ID=$reviewerId");
            
            // Verify IDs are valid numbers
            if ($paperId <= 0 || $reviewerId <= 0) {
                error_log("Invalid IDs: Paper ID=$paperId, Reviewer ID=$reviewerId");
                header("Location: assignments.php?error=" . urlencode("Invalid paper or reviewer ID"));
                exit();
            }
            
            // Check database connection
            if (!$conn) {
                error_log("Database connection failed");
                header("Location: assignments.php?error=" . urlencode("Database connection failed"));
                exit();
            }

            // Start transaction
            if (!mysqli_begin_transaction($conn)) {
                error_log("Failed to start transaction: " . mysqli_error($conn));
                header("Location: assignments.php?error=" . urlencode("Failed to start transaction"));
                exit();
            }
            
            // Check if paper exists
            $sql = "SELECT id, status FROM papers WHERE id = ?";
            $stmt = mysqli_prepare($conn, $sql);
            if (!$stmt) {
                error_log("Failed to prepare paper query: " . mysqli_error($conn));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to prepare paper query"));
                exit();
            }
            mysqli_stmt_bind_param($stmt, "i", $paperId);
            if (!mysqli_stmt_execute($stmt)) {
                error_log("Failed to query paper: " . mysqli_stmt_error($stmt));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to query paper"));
                exit();
            }
            $result = mysqli_stmt_get_result($stmt);
            $paper = mysqli_fetch_assoc($result);
            
            if (!$paper) {
                error_log("Paper not found: ID=$paperId");
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Paper not found"));
                exit();
            }
            
            error_log("Paper found: ID=$paperId, Status=" . $paper['status']);
            
            if ($paper['status'] !== 'submitted') {
                error_log("Paper not in submitted status: ID=$paperId, Status=" . $paper['status']);
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Paper is not in submitted status"));
                exit();
            }
            
            // Check if reviewer exists
            $sql = "SELECT id FROM users WHERE id = ? AND role = 'reviewer'";
            $stmt = mysqli_prepare($conn, $sql);
            if (!$stmt) {
                error_log("Failed to prepare reviewer query: " . mysqli_error($conn));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to prepare reviewer query"));
                exit();
            }
            mysqli_stmt_bind_param($stmt, "i", $reviewerId);
            if (!mysqli_stmt_execute($stmt)) {
                error_log("Failed to query reviewer: " . mysqli_stmt_error($stmt));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to query reviewer"));
                exit();
            }
            $result = mysqli_stmt_get_result($stmt);
            $reviewer = mysqli_fetch_assoc($result);
            
            if (!$reviewer) {
                error_log("Reviewer not found: ID=$reviewerId");
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Reviewer not found"));
                exit();
            }
            
            error_log("Reviewer found: ID=$reviewerId");
            
            // Check if assignment already exists
            $sql = "SELECT COUNT(*) as count FROM assignments WHERE paper_id = ? AND reviewer_id = ?";
            $stmt = mysqli_prepare($conn, $sql);
            if (!$stmt) {
                error_log("Failed to prepare assignment query: " . mysqli_error($conn));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to prepare assignment query"));
                exit();
            }
            mysqli_stmt_bind_param($stmt, "ii", $paperId, $reviewerId);
            if (!mysqli_stmt_execute($stmt)) {
                error_log("Failed to query assignment: " . mysqli_stmt_error($stmt));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to query assignment"));
                exit();
            }
            $result = mysqli_stmt_get_result($stmt);
            $row = mysqli_fetch_assoc($result);
            
            if ($row['count'] > 0) {
                error_log("Assignment already exists: Paper ID=$paperId, Reviewer ID=$reviewerId");
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Reviewer already assigned to this paper"));
                exit();
            }
            
            // First update paper status to 'under_review'
            $sql = "UPDATE papers SET status = 'under_review', updated_at = CURRENT_TIMESTAMP WHERE id = ?";
            $stmt = mysqli_prepare($conn, $sql);
            if (!$stmt) {
                error_log("Failed to prepare status update: " . mysqli_error($conn));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to prepare status update"));
                exit();
            }
            mysqli_stmt_bind_param($stmt, "i", $paperId);
            if (!mysqli_stmt_execute($stmt)) {
                error_log("Failed to update paper status: " . mysqli_stmt_error($stmt));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to update paper status"));
                exit();
            }

            // Then create the assignment
            $sql = "INSERT INTO assignments (paper_id, reviewer_id, assigned_at) VALUES (?, ?, CURRENT_TIMESTAMP)";
            $stmt = mysqli_prepare($conn, $sql);
            if (!$stmt) {
                error_log("Failed to prepare assignment insert: " . mysqli_error($conn));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to prepare assignment insert"));
                exit();
            }
            mysqli_stmt_bind_param($stmt, "ii", $paperId, $reviewerId);
            if (!mysqli_stmt_execute($stmt)) {
                error_log("Failed to create assignment: " . mysqli_stmt_error($stmt));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to create assignment"));
                exit();
            }

            // Commit transaction
            if (!mysqli_commit($conn)) {
                error_log("Failed to commit transaction: " . mysqli_error($conn));
                mysqli_rollback($conn);
                header("Location: assignments.php?error=" . urlencode("Failed to commit transaction"));
                exit();
            }
            
            error_log("Assignment created: Paper ID=$paperId, Reviewer ID=$reviewerId");
            
            // Verify the assignment was created
            $sql = "SELECT id FROM assignments WHERE paper_id = ? AND reviewer_id = ?";
            $stmt = mysqli_prepare($conn, $sql);
            if (!$stmt) {
                error_log("Failed to prepare verification: " . mysqli_error($conn));
                header("Location: assignments.php?error=" . urlencode("Failed to prepare verification"));
                exit();
            }
            mysqli_stmt_bind_param($stmt, "ii", $paperId, $reviewerId);
            if (!mysqli_stmt_execute($stmt)) {
                error_log("Failed to get verification result: " . mysqli_stmt_error($stmt));
                header("Location: assignments.php?error=" . urlencode("Failed to get verification result"));
                exit();
            }
            $result = mysqli_stmt_get_result($stmt);
            $assignment = mysqli_fetch_assoc($result);
            
            if (!$assignment) {
                error_log("Assignment verification failed: Assignment not found after creation");
                header("Location: assignments.php?error=" . urlencode("Failed to verify assignment creation"));
                exit();
            }
            
            error_log("Assignment verified: ID=" . $assignment['id']);
            
            header("Location: assignments.php?success=" . urlencode("Reviewer assigned successfully"));
            exit();
            break;
            
        case 'unassign':
            $paperId = intval($_POST['paper_id'] ?? 0);
            $reviewerId = intval($_POST['reviewer_id'] ?? 0);
            
            // Check if reviewer has submitted a review
            $sql = "SELECT COUNT(*) as count FROM reviews WHERE paper_id = ? AND reviewer_id = ?";
            $stmt = mysqli_prepare($conn, $sql);
            if (!$stmt) {
                error_log("Failed to prepare review check statement: " . mysqli_error($conn));
                header("Location: assignments.php?error=" . urlencode("Failed to prepare review check statement"));
                exit();
            }
            mysqli_stmt_bind_param($stmt, "ii", $paperId, $reviewerId);
            if (!mysqli_stmt_execute($stmt)) {
                error_log("Failed to execute review check: " . mysqli_stmt_error($stmt));
                header("Location: assignments.php?error=" . urlencode("Failed to execute review check"));
                exit();
            }
            $result = mysqli_stmt_get_result($stmt);
            if ($result === false) {
                error_log("Failed to get review result: " . mysqli_error($conn));
                header("Location: assignments.php?error=" . urlencode("Failed to get review result"));
                exit();
            }
            $row = mysqli_fetch_assoc($result);
            
            if ($row['count'] > 0) {
                header("Location: assignments.php?error=" . urlencode("Cannot unassign reviewer who has already submitted a review"));
                exit();
            }
            
            // Delete the assignment
            $sql = "DELETE FROM assignments WHERE paper_id = ? AND reviewer_id = ?";
            $stmt = mysqli_prepare($conn, $sql);
            if (!$stmt) {
                error_log("Failed to prepare delete statement: " . mysqli_error($conn));
                header("Location: assignments.php?error=" . urlencode("Failed to prepare delete statement"));
                exit();
            }
            mysqli_stmt_bind_param($stmt, "ii", $paperId, $reviewerId);
            if (!mysqli_stmt_execute($stmt)) {
                error_log("Failed to delete assignment: " . mysqli_stmt_error($stmt));
                header("Location: assignments.php?error=" . urlencode("Failed to delete assignment"));
                exit();
            }
            
            header("Location: assignments.php?success=Reviewer unassigned successfully");
            exit();
            break;
    }
}

// Get all papers that need review
$sql = "SELECT p.*, u.name as author_name, c.name as category_name 
        FROM papers p 
        JOIN users u ON p.author_id = u.id 
        LEFT JOIN categories c ON p.category_id = c.id 
        WHERE p.status = 'submitted' 
        ORDER BY p.created_at DESC";
$result = mysqli_query($conn, $sql);
if ($result === false) {
    die("Failed to fetch papers: " . mysqli_error($conn));
}
$papers = mysqli_fetch_all($result, MYSQLI_ASSOC);

// Get all reviewers
$sql = "SELECT * FROM users WHERE role = 'reviewer'";
$result = mysqli_query($conn, $sql);
if ($result === false) {
    die("Failed to fetch reviewers: " . mysqli_error($conn));
}
$reviewers = mysqli_fetch_all($result, MYSQLI_ASSOC);

function getReviewers($conn, $paperId) {
    $sql = "SELECT u.name 
            FROM assignments a 
            JOIN users u ON a.reviewer_id = u.id 
            WHERE a.paper_id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "i", $paperId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    return mysqli_fetch_all($result, MYSQLI_ASSOC);
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Assignments - Admin Panel</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Container */
        .admin-container {
            min-height: 100vh;
            display: flex;
            background: linear-gradient(135deg, #00ffcc 0%, #3300ff 50%, #ff00cc 100%);
            padding: 0;
            overflow: hidden;
            position: relative;
        }

        /* Particle Animation */
        .admin-container::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(0, 255, 204, 0.2) 0%, transparent 70%);
            animation: shimmerGlow 4s infinite ease-in-out;
            z-index: 0;
        }

        @keyframes shimmerGlow {
            0% { transform: scale(0.85); opacity: 0.2; }
            50% { transform: scale(1.15); opacity: 0.5; }
            100% { transform: scale(0.85); opacity: 0.2; }
        }

        /* Sidebar */
        .sidebar {
            width: 250px;
            background: rgba(0, 0, 0, 0.9);
            color: #fff;
            padding: 10px 0;
            position: fixed;
            height: 100vh;
            z-index: 2;
            backdrop-filter: blur(10px);
            border-right: 1px solid rgba(255, 255, 255, 0.1);
        }

        .sidebar-header h2 {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 10px rgba(0, 255, 204, 0.5);
            font-size: 1.5rem;
            margin: 0 0 10px;
            padding: 10px;
            text-align: center;
        }

        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 15px;
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            border-radius: 5px;
            margin: 2px 0;
            transition: all 0.3s ease;
        }

        .sidebar-nav a:hover {
            background: rgba(0, 255, 142, 0.1);
            color: #00ffcc;
        }

        .sidebar-nav a.active {
            color: #00ffcc;
            background: rgba(0, 255, 142, 0.1);
        }

        /* Header */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(0, 0, 0, 0.8);
            padding: 10px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            position: fixed;
            width: calc(100% - 250px);
            left: 250px;
            z-index: 2;
        }

        .header .user-info span {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 10px rgba(0, 255, 204, 0.5);
            font-size: 1.1rem;
        }

        /* Main Content */
        .main-content {
            margin-left: 250px;
            margin-top: 60px;
            padding: 10px;
            background: rgba(255, 255, 255, 0.05);
            overflow-y: auto;
            height: calc(100vh - 60px);
            backdrop-filter: blur(10px);
        }

        /* Dashboard Content */
        .dashboard-content {
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 10px;
            background: rgba(0, 0, 0, 0.8);
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }

        /* Messages */
        .success-message, .error-message {
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 5px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .success-message {
            background: rgba(0, 255, 142, 0.1);
            color: #00ffcc;
        }

        .error-message {
            background: rgba(255, 0, 0, 0.1);
            color: #ff0000;
        }

        /* Assignments Table */
        .assignments-table {
            padding: 15px;
            background: rgba(0, 0, 0, 0.7);
            border-radius: 5px;
        }

        .assignments-table table {
            width: 100%;
            border-collapse: collapse;
        }

        .assignments-table th {
            background: rgba(0, 255, 142, 0.1);
            color: #fff;
            padding: 10px;
            text-align: left;
        }

        .assignments-table td {
            padding: 10px;
            border-bottom: 1px solid rgba(0, 255, 142, 0.1);
            color: #fff;
            position: relative;
            animation: floatUp 1.5s infinite ease-in-out;
        }

        @keyframes floatUp {
            0% { transform: translateY(0); }
            50% { transform: translateY(-5px); }
            100% { transform: translateY(0); }
        }

        .assign-form select {
            padding: 5px;
            border: 1px solid rgba(0, 255, 142, 0.1);
            border-radius: 4px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            cursor: pointer;
            transition: border-color 0.3s;
        }

        .assign-form select:focus {
            border-color: #00ffcc;
            outline: none;
        }

        .assign-btn, .unassign-btn {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            color: #fff;
            border: none;
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
            animation: shimmerBtn 1.5s infinite ease-in-out;
        }

        @keyframes shimmerBtn {
            0% { box-shadow: 0 0 0 rgba(0, 255, 204, 0.3); }
            50% { box-shadow: 0 0 5px rgba(0, 255, 204, 0.7); }
            100% { box-shadow: 0 0 0 rgba(0, 255, 204, 0.3); }
        }

        .assign-btn:hover, .unassign-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0, 255, 204, 0.5);
        }

        .reviewer-badge {
            display: inline-block;
            background: rgba(0, 255, 142, 0.1);
            padding: 2px 8px;
            border-radius: 10px;
            margin-right: 5px;
            margin-bottom: 5px;
        }

        /* Zoom-in Animation */
        .main-content {
            animation: zoomIn 0.5s ease-out;
        }

        @keyframes zoomIn {
            from { transform: scale(0.95); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .sidebar {
                width: 70px;
            }
            .sidebar-nav a {
                padding: 12px 10px;
                text-align: center;
            }
            .sidebar-nav a span {
                display: none;
            }
            .main-content {
                margin-left: 70px;
            }
            .header {
                width: calc(100% - 70px);
                left: 70px;
            }
        }
    </style>
</head>
<body>
    <div class="admin-container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <h2><i class="fas fa-graduation-cap"></i> Admin Panel</h2>
            </div>
            <nav class="sidebar-nav">
                <a href="dashboard.php">
                    <i class="fas fa-home"></i>
                    Dashboard
                </a>
                <a href="users.php">
                    <i class="fas fa-users"></i>
                    Manage Users
                </a>
                <a href="categories.php">
                    <i class="fas fa-tags"></i>
                    Categories
                </a>
                <a href="papers.php">
                    <i class="fas fa-file-alt"></i>
                    All Papers
                </a>
                <a href="assignments.php" class="active">
                    <i class="fas fa-tasks"></i>
                    Assignments
                </a>
                <a href="../logout.php">
                    <i class="fas fa-sign-out-alt"></i>
                    Logout
                </a>
            </nav>
        </div>

        <!-- Header -->
        <div class="header">
            <div class="user-info">
                <span>Welcome, <?php echo htmlspecialchars($user['name']); ?></span>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="dashboard-content">
                <?php if (isset($_GET['success'])): ?>
                    <div class="success-message">
                        <i class="fas fa-check-circle"></i>
                        <span><?php echo htmlspecialchars($_GET['success']); ?></span>
                    </div>
                <?php endif; ?>

                <?php if (isset($_GET['error'])): ?>
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><?php echo htmlspecialchars($_GET['error']); ?></span>
                    </div>
                <?php endif; ?>

                <div class="assignments-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Paper Title</th>
                                <th>Author</th>
                                <th>Category</th>
                                <th>Current Reviewers</th>
                                <th>Assign New Reviewer</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($papers as $paper): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($paper['title']); ?></td>
                                    <td><?php echo htmlspecialchars($paper['author_name']); ?></td>
                                    <td><?php echo htmlspecialchars($paper['category_name']); ?></td>
                                    <td>
                                        <?php $currentReviewers = getReviewers($conn, $paper['id']); ?>
                                        <?php foreach ($currentReviewers as $reviewer): ?>
                                            <span class="reviewer-badge">
                                                <?php echo htmlspecialchars($reviewer['name']); ?>
                                                <form method="POST" class="unassign-form" style="display: inline;">
                                                    <input type="hidden" name="paper_id" value="<?php echo $paper['id']; ?>">
                                                    <input type="hidden" name="reviewer_id" value="<?php echo $reviewer['id']; ?>">
                                                    <input type="hidden" name="action" value="unassign">
                                                    <button type="submit" class="unassign-btn">
                                                        <i class="fas fa-times"></i>
                                                    </button>
                                                </form>
                                            </span>
                                        <?php endforeach; ?>
                                    </td>
                                    <td>
                                        <form method="POST" class="assign-form">
                                            <input type="hidden" name="paper_id" value="<?php echo $paper['id']; ?>">
                                            <input type="hidden" name="action" value="assign">
                                            <select name="reviewer_id" required>
                                                <option value="">Select Reviewer</option>
                                                <?php foreach ($reviewers as $reviewer): ?>
                                                    <option value="<?php echo $reviewer['id']; ?>">
                                                        <?php echo htmlspecialchars($reviewer['name']); ?>
                                                    </option>
                                                <?php endforeach; ?>
                                            </select>
                                            <button type="submit" class="assign-btn">
                                                <i class="fas fa-plus"></i> Assign
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>