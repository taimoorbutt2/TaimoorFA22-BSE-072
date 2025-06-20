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

// Enable debug mode for testing (remove in production)
$debug = isset($_GET['debug']) && $_GET['debug'] == 1;

// Verify database connection
if (!$conn) {
    $error = "Database connection failed: " . mysqli_connect_error();
    error_log($error);
    if ($debug) {
        die($error);
    } else {
        header("Location: papers.php?error=" . urlencode($error));
        exit();
    }
}

// Handle paper actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['action'])) {
        switch ($_POST['action']) {
            case 'update_status':
                $paperId = intval($_POST['paper_id']);
                $newStatus = mysqli_real_escape_string($conn, $_POST['status']);
                
                // Log POST data for debugging
                error_log("Update status POST data: " . print_r($_POST, true));
                
                // Check if paper exists
                $sql = "SELECT id, status FROM papers WHERE id = ?";
                $stmt = mysqli_prepare($conn, $sql);
                if (!$stmt) {
                    $error = "Database error preparing SELECT: " . mysqli_error($conn);
                    error_log($error);
                    if ($debug) {
                        die($error);
                    } else {
                        header("Location: papers.php?error=" . urlencode($error));
                        exit();
                    }
                }
                mysqli_stmt_bind_param($stmt, "i", $paperId);
                if (!mysqli_stmt_execute($stmt)) {
                    $error = "Database error executing SELECT: " . mysqli_stmt_error($stmt);
                    error_log($error);
                    if ($debug) {
                        die($error);
                    } else {
                        header("Location: papers.php?error=" . urlencode($error));
                        exit();
                    }
                }
                $result = mysqli_stmt_get_result($stmt);
                $paper = mysqli_fetch_assoc($result);

                if (!$paper) {
                    header("Location: papers.php?error=Paper not found");
                    exit();
                }

                // Start transaction
                if (!mysqli_begin_transaction($conn)) {
                    $error = "Database error starting transaction: " . mysqli_error($conn);
                    error_log($error);
                    if ($debug) {
                        die($error);
                    } else {
                        header("Location: papers.php?error=" . urlencode($error));
                        exit();
                    }
                }

                try {
                    // Update paper status
                    $sql = "UPDATE papers SET status = ? WHERE id = ?";
                    $stmt = mysqli_prepare($conn, $sql);
                    if (!$stmt) {
                        throw new Exception("Database error preparing UPDATE: " . mysqli_error($conn));
                    }
                    mysqli_stmt_bind_param($stmt, "si", $newStatus, $paperId);
                    if (!mysqli_stmt_execute($stmt)) {
                        throw new Exception("Error executing paper status update: " . mysqli_stmt_error($stmt));
                    }
                    $affected_rows = mysqli_stmt_affected_rows($stmt);
                    if ($affected_rows == 0) {
                        throw new Exception("No rows updated for paper ID: " . $paperId);
                    }

                    // Check if assignments table exists before updating
                    $check_sql = "SHOW TABLES LIKE 'assignments'";
                    $result = mysqli_query($conn, $check_sql);
                    if ($result && mysqli_num_rows($result) > 0) {
                        // Verify assignments table structure
                        $describe_sql = "DESCRIBE assignments";
                        $describe_result = mysqli_query($conn, $describe_sql);
                        $has_status = false;
                        while ($column = mysqli_fetch_assoc($describe_result)) {
                            if ($column['Field'] === 'status') {
                                $has_status = true;
                                break;
                            }
                        }

                        if ($has_status) {
                            // Update assignments status to match paper status
                            $sql = "UPDATE assignments SET status = ? WHERE paper_id = ?";
                            $stmt = mysqli_prepare($conn, $sql);
                            if (!$stmt) {
                                throw new Exception("Database error preparing assignments UPDATE: " . mysqli_error($conn));
                            }
                            mysqli_stmt_bind_param($stmt, "si", $newStatus, $paperId);
                            if (!mysqli_stmt_execute($stmt)) {
                                throw new Exception("Error executing assignments status update: " . mysqli_stmt_error($stmt));
                            }
                            $affected_rows = mysqli_stmt_affected_rows($stmt);
                            if ($affected_rows == 0) {
                                error_log("No assignments updated for paper ID: " . $paperId . ", which might be expected if no assignments exist.");
                            }
                        } else {
                            error_log("Assignments table exists but lacks 'status' column for paper ID: " . $paperId);
                        }
                    } else {
                        error_log("Assignments table not found, skipping update for paper ID: " . $paperId);
                    }

                    // Commit transaction
                    if (!mysqli_commit($conn)) {
                        throw new Exception("Error committing transaction: " . mysqli_error($conn));
                    }
                    
                    header("Location: papers.php?success=Status updated successfully");
                    exit();

                } catch (Exception $e) {
                    // Rollback transaction
                    mysqli_rollback($conn);
                    $error = $e->getMessage();
                    error_log("Error updating paper status: " . $error);
                    if ($debug) {
                        die($error);
                    } else {
                        header("Location: papers.php?error=" . urlencode($error));
                        exit();
                    }
                }
                break;

            case 'delete':
                $paperId = mysqli_real_escape_string($conn, $_POST['paper_id']);
                // Delete the paper file
                $sql = "SELECT file_path FROM papers WHERE id = ?";
                $stmt = mysqli_prepare($conn, $sql);
                mysqli_stmt_bind_param($stmt, "i", $paperId);
                mysqli_stmt_execute($stmt);
                $result = mysqli_stmt_get_result($stmt);
                $paper = mysqli_fetch_assoc($result);
                
                if ($paper && file_exists($paper['file_path'])) {
                    unlink($paper['file_path']);
                }
                
                // Delete the paper from database
                $sql = "DELETE FROM papers WHERE id = ?";
                $stmt = mysqli_prepare($conn, $sql);
                mysqli_stmt_bind_param($stmt, "i", $paperId);
                mysqli_stmt_execute($stmt);
                
                header("Location: papers.php?success=Paper deleted successfully");
                exit();
                break;
        }
    }
}

// Get all papers with related data
$sql = "SELECT p.*, u.name as author_name, c.name as category_name 
        FROM papers p 
        JOIN users u ON p.author_id = u.id 
        LEFT JOIN categories c ON p.category_id = c.id 
        ORDER BY p.created_at DESC";
$result = mysqli_query($conn, $sql);
$papers = mysqli_fetch_all($result, MYSQLI_ASSOC);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Papers - Admin Panel</title>
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
            animation: glowPulse 5s infinite ease-in-out;
            z-index: 0;
        }

        @keyframes glowPulse {
            0% { transform: scale(0.95); opacity: 0.3; }
            50% { transform: scale(1.05); opacity: 0.6; }
            100% { transform: scale(0.95); opacity: 0.3; }
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

        /* Papers Table */
        .papers-table {
            padding: 15px;
            background: rgba(0, 0, 0, 0.7);
            border-radius: 5px;
        }

        .papers-table table {
            width: 100%;
            border-collapse: collapse;
        }

        .papers-table th {
            background: rgba(0, 255, 142, 0.1);
            color: #fff;
            padding: 10px;
            text-align: left;
        }

        .papers-table td {
            padding: 10px;
            border-bottom: 1px solid rgba(0, 255, 142, 0.1);
            color: #fff;
            position: relative;
            animation: bounceIn 0.5s ease-out;
        }

        @keyframes bounceIn {
            0% { transform: translateY(20px); opacity: 0; }
            60% { transform: translateY(-5px); opacity: 1; }
            100% { transform: translateY(0); }
        }

        .status-form select {
            padding: 5px;
            border: 1px solid rgba(0, 255, 142, 0.1);
            border-radius: 4px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            cursor: pointer;
            transition: border-color 0.3s;
        }

        .status-form select:focus {
            border-color: #00ffcc;
            outline: none;
        }

        .action-buttons a, .action-buttons button {
            display: inline-block;
            margin-right: 10px;
            padding: 5px 10px;
            text-decoration: none;
            color: #fff;
            border-radius: 4px;
            transition: all 0.3s ease;
            animation: glowPulseBtn 2s infinite ease-in-out;
        }

        @keyframes glowPulseBtn {
            0% { box-shadow: 0 0 0 rgba(0, 255, 204, 0.3); }
            50% { box-shadow: 0 0 10px rgba(0, 255, 204, 0.5); }
            100% { box-shadow: 0 0 0 rgba(0, 255, 204, 0.3); }
        }

        .action-buttons a.view {
            background: #2ecc71;
        }

        .action-buttons a.view:hover {
            background: #27ae60;
            transform: scale(1.05);
        }

        .delete-btn {
            background: #e74c3c;
            border: none;
            cursor: pointer;
        }

        .delete-btn:hover {
            background: #c0392b;
            transform: scale(1.1);
        }

        /* Slide-in Animation */
        .main-content {
            animation: slideIn 0.5s ease-out;
        }

        @keyframes slideIn {
            from { transform: translateX(50px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
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
                <a href="papers.php" class="active">
                    <i class="fas fa-file-alt"></i>
                    All Papers
                </a>
                <a href="assignments.php">
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

                <div class="papers-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Category</th>
                                <th>Status</th>
                                <th>Submitted On</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($papers as $paper): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($paper['title']); ?></td>
                                    <td><?php echo htmlspecialchars($paper['author_name']); ?></td>
                                    <td><?php echo htmlspecialchars($paper['category_name']); ?></td>
                                    <td>
                                        <form method="POST" class="status-form">
                                            <input type="hidden" name="paper_id" value="<?php echo $paper['id']; ?>">
                                            <input type="hidden" name="action" value="update_status">
                                            <select name="status" onchange="this.form.submit()">
                                                <option value="submitted" <?php echo $paper['status'] === 'submitted' ? 'selected' : ''; ?>>Submitted</option>
                                                <option value="under_review" <?php echo $paper['status'] === 'under_review' ? 'selected' : ''; ?>>Under Review</option>
                                                <option value="accepted" <?php echo $paper['status'] === 'accepted' ? 'selected' : ''; ?>>Accepted</option>
                                                <option value="rejected" <?php echo $paper['status'] === 'rejected' ? 'selected' : ''; ?>>Rejected</option>
                                                <option value="revision_required" <?php echo $paper['status'] === 'revision_required' ? 'selected' : ''; ?>>Revision Required</option>
                                            </select>
                                        </form>
                                    </td>
                                    <td><?php echo date('M d, Y', strtotime($paper['created_at'])); ?></td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="../download.php?paper_id=<?php echo $paper['id']; ?>" class="action-btn view">
                                                <i class="fas fa-eye"></i> View
                                            </a>
                                            <form method="POST" class="delete-form" onsubmit="return confirm('Are you sure you want to delete this paper?')">
                                                <input type="hidden" name="paper_id" value="<?php echo $paper['id']; ?>">
                                                <input type="hidden" name="action" value="delete">
                                                <button type="submit" class="delete-btn">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </form>
                                        </div>
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