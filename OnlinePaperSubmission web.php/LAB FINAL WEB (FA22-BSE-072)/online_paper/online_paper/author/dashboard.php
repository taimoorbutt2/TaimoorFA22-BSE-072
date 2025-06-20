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
$_SESSION['user_name'] = $user['name'] ?? 'Author';

if (!$user) {
    error_log("User not found for ID: " . $_SESSION['user_id']);
    header("Location: ../index.php");
    exit();
}

// Check if user is logged in and is an author
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'author') {
    header("Location: ../index.php");
    exit();
}

// File upload handling
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['paper_file'])) {
    // Create uploads directory if it doesn't exist
    $upload_dir = '../uploads/papers/';
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    // Get file details
    $file = $_FILES['paper_file'];
    $allowed_types = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
    
    // Validate file type
    if (!in_array($file['type'], $allowed_types)) {
        $error = "Error: Only PDF and DOC files are allowed";
    } else {
        // Generate unique filename
        $timestamp = time();
        $original_name = $file['name'];
        $extension = pathinfo($original_name, PATHINFO_EXTENSION);
        $unique_filename = $timestamp . '_' . $original_name;
        
        // Set file path
        $file_path = $upload_dir . $unique_filename;
        
        // Move uploaded file
        if (move_uploaded_file($file['tmp_name'], $file_path)) {
            // Save to database
            $title = mysqli_real_escape_string($conn, $_POST['title']);
            $abstract = mysqli_real_escape_string($conn, $_POST['abstract']);
            $keywords = mysqli_real_escape_string($conn, $_POST['keywords']);
            $category_id = mysqli_real_escape_string($conn, $_POST['category_id']);
            
            $sql = "INSERT INTO papers (title, abstract, keywords, file_name, file_path, category_id, author_id) 
                    VALUES (?, ?, ?, ?, ?, ?, ?)";
            $stmt = mysqli_prepare($conn, $sql);
            mysqli_stmt_bind_param($stmt, "sssissi", $title, $abstract, $keywords, $original_name, $file_path, $category_id, $_SESSION['user_id']);
            
            if (mysqli_stmt_execute($stmt)) {
                $success = "Paper submitted successfully!";
            } else {
                $error = "Error saving paper to database";
            }
        } else {
            $error = "Error uploading file";
        }
    }
}

// Get user statistics
$sql = "SELECT 
    (SELECT COUNT(*) FROM papers WHERE author_id = ?) as total_papers,
    (SELECT COUNT(*) FROM papers WHERE author_id = ? AND status = 'pending') as pending_papers,
    (SELECT COUNT(*) FROM papers WHERE author_id = ? AND status = 'accepted') as accepted_papers,
    (SELECT COUNT(*) FROM papers WHERE author_id = ? AND status = 'rejected') as rejected_papers";

$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "iiii", $_SESSION['user_id'], $_SESSION['user_id'], $_SESSION['user_id'], $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$stats = mysqli_fetch_assoc($result);

// Get recent papers
$sql = "SELECT p.*, c.name as category_name FROM papers p 
        LEFT JOIN categories c ON p.category_id = c.id 
        WHERE p.author_id = ? 
        ORDER BY p.created_at DESC 
        LIMIT 5";

$stmt = mysqli_prepare($conn, $sql);
if ($stmt) {
    mysqli_stmt_bind_param($stmt, "i", $_SESSION['user_id']);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    if ($result) {
        $recent_papers = mysqli_fetch_all($result, MYSQLI_ASSOC);
    } else {
        $recent_papers = [];
    }
} else {
    $recent_papers = [];
}

// Get submitted papers count
$sql = "SELECT COUNT(*) as count FROM papers WHERE author_id = ? AND status = 'submitted'";
$stmt = mysqli_prepare($conn, $sql);
if ($stmt) {
    mysqli_stmt_bind_param($stmt, "i", $_SESSION['user_id']);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $submitted_count = mysqli_fetch_assoc($result)['count'];
} else {
    $submitted_count = 0;
}

// Get under review papers count
$sql = "SELECT COUNT(*) as count FROM papers WHERE author_id = ? AND status = 'under_review'";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$under_review_count = mysqli_fetch_assoc($result)['count'];

// Get accepted papers count
$sql = "SELECT COUNT(*) as count FROM papers WHERE author_id = ? AND status = 'accepted'";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$accepted_count = mysqli_fetch_assoc($result)['count'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Author Dashboard - Online Paper Submission System</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/author.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Container */
        .author-dashboard {
            min-height: 100vh;
            display: flex;
            background: linear-gradient(135deg, #00ffcc 0%, #3300ff 50%, #ff00cc 100%);
            padding: 0;
            overflow: hidden;
            position: relative;
        }

        /* Particle Animation */
        .author-dashboard::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(0, 255, 204, 0.2) 0%, transparent 70%);
            animation: rotateGlow 5s infinite linear;
            z-index: 0;
        }

        @keyframes rotateGlow {
            0% { transform: rotate(0deg); opacity: 0.3; }
            50% { transform: rotate(180deg); opacity: 0.6; }
            100% { transform: rotate(360deg); opacity: 0.3; }
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

        .sidebar-header {
            text-align: center;
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .sidebar-header h2 {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 10px rgba(0, 255, 204, 0.5);
            font-size: 1.5rem;
            margin: 0 0 10px;
        }

        .sidebar-header .user-info {
            margin-top: 1rem;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
        }

        .sidebar-header .user-info img {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            margin-bottom: 1rem;
            border: 2px solid #00ffcc;
        }

        .sidebar-header .user-info .name {
            font-size: 1.1rem;
            font-weight: 600;
            color: #fff;
        }

        .sidebar-header .user-info .role {
            color: rgba(255, 255, 255, 0.8);
            font-size: 0.9rem;
        }

        .sidebar-nav {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .sidebar-nav a:hover,
        .sidebar-nav a.active {
            background: rgba(0, 255, 142, 0.1);
            color: #00ffcc;
        }

        .sidebar-nav a i {
            width: 20px;
            text-align: center;
        }

        /* Header */
        .dashboard-header {
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

        .dashboard-header h1 {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 10px rgba(0, 255, 204, 0.5);
            font-size: 2rem;
            margin: 0;
        }

        .dashboard-header .user-info span {
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

        /* Stats Section */
        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: rgba(0, 0, 0, 0.7);
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
            text-align: center;
            animation: fadeInCard 0.5s ease-out;
        }

        @keyframes fadeInCard {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .stat-card i {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: #00ffcc;
        }

        .stat-card h3 {
            color: #fff;
            margin-bottom: 0.5rem;
        }

        .stat-card p {
            font-size: 1.5rem;
            font-weight: bold;
            color: #fff;
            margin: 0;
        }

        /* Papers Section */
        .papers-section {
            background: rgba(0, 0, 0, 0.7);
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }

        .papers-section h2 {
            color: #fff;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .actions-section .action-btn {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            color: #fff;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .actions-section .action-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0, 255, 204, 0.5);
        }

        /* Papers Table */
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
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from { transform: translateY(10px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .status {
            padding: 0.5rem 1rem;
            border-radius: 15px;
            font-size: 0.9rem;
            display: inline-block;
            min-width: 100px;
            text-align: center;
        }

        .status.submitted {
            background: rgba(232, 245, 233, 0.3);
            color: #2e7d32;
        }

        .status.under_review {
            background: rgba(255, 243, 205, 0.3);
            color: #856404;
        }

        .status.accepted {
            background: rgba(212, 237, 218, 0.3);
            color: #155724;
        }

        .status.rejected {
            background: rgba(248, 215, 218, 0.3);
            color: #721c24;
        }

        .status.revision_required {
            background: rgba(255, 243, 205, 0.3);
            color: #856404;
        }

        .action-buttons a {
            display: inline-block;
            margin-right: 10px;
            padding: 5px 10px;
            text-decoration: none;
            color: #fff;
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .action-buttons .download-btn {
            background: #2ecc71;
        }

        .action-buttons .download-btn:hover {
            background: #27ae60;
            transform: scale(1.05);
        }

        .action-buttons .edit-btn {
            background: #ffc107;
            color: #333;
        }

        .action-buttons .edit-btn:hover {
            background: #e0a800;
            transform: scale(1.05);
        }

        .action-buttons .delete-btn {
            background: #e74c3c;
        }

        .action-buttons .delete-btn:hover {
            background: #c0392b;
            transform: scale(1.05);
        }

        /* Rotate-in Animation */
        .main-content {
            animation: rotateIn 0.5s ease-out;
        }

        @keyframes rotateIn {
            from { transform: rotate(-5deg) scale(0.95); opacity: 0; }
            to { transform: rotate(0) scale(1); opacity: 1; }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .sidebar {
                width: 70px;
            }
            .sidebar-nav a {
                padding: 0.8rem;
                text-align: center;
            }
            .sidebar-nav a span {
                display: none;
            }
            .main-content {
                margin-left: 70px;
            }
            .dashboard-header {
                width: calc(100% - 70px);
                left: 70px;
            }
        }
    </style>
</head>
<body>
    <div class="author-dashboard">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <h2>Author Dashboard</h2>
                <div class="user-info">
                    <img src="../assets/images/default-avatar.png" alt="Profile Picture">
                    <div>
                        <div class="name"><?php echo htmlspecialchars($_SESSION['user_name']); ?></div>
                        <div class="role">Author</div>
                    </div>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <a href="dashboard.php" class="active">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
                <a href="papers.php">
                    <i class="fas fa-file-alt"></i>
                    <span>My Papers</span>
                </a>
                <a href="submit_paper.php">
                    <i class="fas fa-upload"></i>
                    <span>Submit Paper</span>
                </a>
                <a href="profile.php">
                    <i class="fas fa-user"></i>
                    <span>Profile</span>
                </a>
                <a href="../logout.php">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </nav>
        </div>

        <!-- Header -->
        <div class="dashboard-header">
            <h1>My Dashboard</h1>
            <div class="user-info">
                <span>Welcome back, <?php echo htmlspecialchars($_SESSION['user_name']); ?></span>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <?php if (isset($success)): ?>
                <div class="success-message">
                    <i class="fas fa-check-circle"></i>
                    <span><?php echo htmlspecialchars($success); ?></span>
                </div>
            <?php endif; ?>

            <?php if (isset($error)): ?>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i>
                    <span><?php echo htmlspecialchars($error); ?></span>
                </div>
            <?php endif; ?>

            <!-- Stats Section -->
            <div class="stats-section">
                <div class="stat-card">
                    <i class="fas fa-file-alt"></i>
                    <h3>Total Papers</h3>
                    <p><?php echo isset($stats['total_papers']) ? $stats['total_papers'] : 0; ?></p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-paper-plane"></i>
                    <h3>Submitted</h3>
                    <p><?php echo $submitted_count; ?></p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-hourglass-half"></i>
                    <h3>Under Review</h3>
                    <p><?php echo $under_review_count; ?></p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-check-circle"></i>
                    <h3>Accepted</h3>
                    <p><?php echo $accepted_count; ?></p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-times-circle"></i>
                    <h3>Rejected</h3>
                    <p><?php echo isset($stats['rejected_papers']) ? $stats['rejected_papers'] : 0; ?></p>
                </div>
            </div>

            <!-- Papers Section -->
            <div class="papers-section">
                <div class="actions-section">
                    <button onclick="window.location.href='submit_paper.php'" class="action-btn">
                        <i class="fas fa-plus"></i> Submit New Paper
                    </button>
                </div>

                <h2>Recent Papers</h2>
                <div class="papers-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Category</th>
                                <th>Status</th>
                                <th>Submitted On</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (!empty($recent_papers)): ?>
                                <?php foreach ($recent_papers as $paper): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($paper['title']); ?></td>
                                        <td><?php echo htmlspecialchars($paper['category_name'] ?? 'N/A'); ?></td>
                                        <td>
                                            <span class="status <?php echo strtolower(str_replace(' ', '_', $paper['status'])); ?>">
                                                <?php echo ucfirst(str_replace('_', ' ', $paper['status'])); ?>
                                            </span>
                                        </td>
                                        <td><?php echo date('M d, Y', strtotime($paper['created_at'])); ?></td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="../download.php?paper_id=<?php echo $paper['id']; ?>" class="download-btn" title="Download Paper">
                                                    <i class="fas fa-download"></i>
                                                </a>
                                                <?php if ($paper['status'] === 'submitted'): ?>
                                                    <a href="edit_paper.php?id=<?php echo $paper['id']; ?>" class="edit-btn" title="Edit Paper">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="delete_paper.php?id=<?php echo $paper['id']; ?>" class="delete-btn" title="Delete Paper" onclick="return confirm('Are you sure you want to delete this paper?')">
                                                        <i class="fas fa-trash"></i>
                                                    </a>
                                                <?php endif; ?>
                                            </div>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            <?php else: ?>
                                <tr>
                                    <td colspan="5" class="no-papers">No papers found</td>
                                </tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>