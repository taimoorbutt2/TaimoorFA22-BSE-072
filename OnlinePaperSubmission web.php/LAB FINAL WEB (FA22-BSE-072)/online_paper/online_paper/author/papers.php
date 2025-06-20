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

// Get user's papers
$author_id = $_SESSION['user_id'];
$sql = "SELECT p.*, c.name as category_name, u.name as reviewer_name 
        FROM papers p 
        LEFT JOIN categories c ON p.category_id = c.id 
        LEFT JOIN assignments a ON p.id = a.paper_id 
        LEFT JOIN users u ON a.reviewer_id = u.id 
        WHERE p.author_id = ? 
        ORDER BY p.created_at DESC";

// Debug - Log the SQL query
error_log("SQL Query: " . $sql);

if (!$stmt = mysqli_prepare($conn, $sql)) {
    error_log("Error preparing statement: " . mysqli_error($conn));
    die("Error preparing statement: " . mysqli_error($conn));
}

if (!mysqli_stmt_bind_param($stmt, "i", $author_id)) {
    error_log("Error binding parameters: " . mysqli_error($conn));
    die("Error binding parameters: " . mysqli_error($conn));
}

if (!mysqli_stmt_execute($stmt)) {
    error_log("Error executing statement: " . mysqli_error($conn));
    die("Error executing statement: " . mysqli_error($conn));
}

$result = mysqli_stmt_get_result($stmt);
if ($result === false) {
    error_log("Error getting result: " . mysqli_error($conn));
    die("Error getting result: " . mysqli_error($conn));
}

$papers = [];
while ($row = mysqli_fetch_assoc($result)) {
    $papers[$row['id']] = $row;
    // Aggregate reviewer names if multiple assignments exist
    if ($row['reviewer_name'] && !isset($papers[$row['id']]['reviewer_names'])) {
        $papers[$row['id']]['reviewer_names'] = [];
    }
    if ($row['reviewer_name']) {
        $papers[$row['id']]['reviewer_names'][] = $row['reviewer_name'];
    }
}
$papers = array_values($papers); // Reindex array
if ($papers === false) {
    error_log("Error fetching papers: " . mysqli_error($conn));
    $papers = [];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Papers - Author Dashboard</title>
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
            animation: pulseGlow 4s infinite ease-in-out;
            z-index: 0;
        }

        @keyframes pulseGlow {
            0% { transform: scale(0.9); opacity: 0.2; }
            50% { transform: scale(1.1); opacity: 0.5; }
            100% { transform: scale(0.9); opacity: 0.2; }
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

        nav {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        nav a {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        nav a:hover,
        nav a.active {
            background: rgba(0, 255, 142, 0.1);
            color: #00ffcc;
        }

        nav a i {
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

        /* Papers Section */
        .papers-section {
            background: rgba(0, 0, 0, 0.7);
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }

        .no-papers {
            text-align: center;
            color: #fff;
            padding: 2rem;
        }

        .no-papers .action-btn {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            color: #fff;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 1rem;
        }

        .no-papers .action-btn:hover {
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
            animation: pulseRow 1.5s infinite ease-in-out;
        }

        @keyframes pulseRow {
            0% { transform: scale(1); }
            50% { transform: scale(1.02); }
            100% { transform: scale(1); }
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

        .status.draft {
            background: rgba(255, 243, 205, 0.3);
            color: #856404;
        }

        .action-btn {
            display: inline-block;
            margin-right: 10px;
            padding: 5px 10px;
            text-decoration: none;
            color: #fff;
            border-radius: 4px;
            transition: all 0.3s ease;
            animation: glowBtn 2s infinite ease-in-out;
        }

        @keyframes glowBtn {
            0% { box-shadow: 0 0 0 rgba(0, 255, 204, 0.3); }
            50% { box-shadow: 0 0 10px rgba(0, 255, 204, 0.5); }
            100% { box-shadow: 0 0 0 rgba(0, 255, 204, 0.3); }
        }

        .action-btn.view {
            background: #2ecc71;
        }

        .action-btn.view:hover {
            background: #27ae60;
            transform: scale(1.05);
        }

        .action-btn.edit {
            background: #ffc107;
            color: #333;
        }

        .action-btn.edit:hover {
            background: #e0a800;
            transform: scale(1.05);
        }

        .action-btn.delete {
            background: #e74c3c;
        }

        .action-btn.delete:hover {
            background: #c0392b;
            transform: scale(1.05);
        }

        /* Scale-in Animation */
        .main-content {
            animation: scaleIn 0.5s ease-out;
        }

        @keyframes scaleIn {
            from { transform: scale(0.95); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .sidebar {
                width: 70px;
            }
            nav a {
                padding: 0.8rem;
                text-align: center;
            }
            nav a span {
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
            
            <nav>
                <a href="dashboard.php" class="nav-item">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
                <a href="papers.php" class="nav-item active">
                    <i class="fas fa-file-alt"></i>
                    <span>My Papers</span>
                </a>
                <a href="submit_paper.php" class="nav-item">
                    <i class="fas fa-plus"></i>
                    <span>Submit Paper</span>
                </a>
                <a href="../logout.php" class="nav-item">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </nav>
        </div>

        <!-- Header -->
        <div class="dashboard-header">
            <h1>My Papers</h1>
            <div class="user-info">
                <span>Welcome back, <?php echo htmlspecialchars($_SESSION['user_name']); ?></span>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="papers-section">
                <?php if (empty($papers)): ?>
                    <div class="no-papers">
                        <p>You haven't submitted any papers yet.</p>
                        <a href="submit_paper.php" class="action-btn">
                            <i class="fas fa-plus"></i> Submit New Paper
                        </a>
                    </div>
                <?php else: ?>
                    <table class="papers-table">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Category</th>
                                <th>Status</th>
                                <th>Reviewer</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($papers as $paper): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($paper['title']); ?></td>
                                    <td><?php echo htmlspecialchars($paper['category_name'] ?? 'N/A'); ?></td>
                                    <td>
                                        <span class="status <?php echo strtolower(str_replace(' ', '_', $paper['status'])); ?>">
                                            <?php echo ucfirst(str_replace('_', ' ', $paper['status'])); ?>
                                        </span>
                                    </td>
                                    <td>
                                        <?php echo implode(', ', array_map('htmlspecialchars', $paper['reviewer_names'] ?? ['Not Assigned'])); ?>
                                    </td>
                                    <td>
                                        <a href="../download.php?paper_id=<?php echo $paper['id']; ?>" class="action-btn view">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                        <?php if ($paper['status'] === 'Draft'): ?>
                                            <a href="edit_paper.php?id=<?php echo $paper['id']; ?>" class="action-btn edit">
                                                <i class="fas fa-edit"></i> Edit
                                            </a>
                                        <?php endif; ?>
                                        <a href="delete_paper.php?id=<?php echo $paper['id']; ?>" class="action-btn delete" onclick="return confirm('Are you sure you want to delete this paper?')">
                                            <i class="fas fa-trash"></i> Delete
                                        </a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
        </div>
    </div>
</body>
</html>