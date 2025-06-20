<?php
session_start();
require_once '../config/database.php';

// Check if user is logged in and is an admin
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header("Location: ../index.php");
    exit();
}

// Get user info
$sql = "SELECT name FROM users WHERE id = ?";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $_SESSION['user_id']);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$user = mysqli_fetch_assoc($result);

// Get system statistics
$sql = "SELECT 
            COUNT(DISTINCT u.id) as total_users,
            COUNT(DISTINCT p.id) as total_papers,
            COUNT(DISTINCT r.id) as total_reviewers,
            COUNT(DISTINCT a.id) as total_authors
        FROM users u
        LEFT JOIN papers p ON u.id = p.author_id
        LEFT JOIN users r ON r.role = 'reviewer'
        LEFT JOIN users a ON a.role = 'author'
        WHERE u.role = 'author' OR u.role = 'reviewer'";
$result = mysqli_query($conn, $sql);
$stats = mysqli_fetch_assoc($result);

// Get recent papers
$sql = "SELECT p.*, u.name as author_name, c.name as category_name 
        FROM papers p 
        JOIN users u ON p.author_id = u.id 
        LEFT JOIN categories c ON p.category_id = c.id 
        ORDER BY p.created_at DESC 
        LIMIT 5";
$recent_papers = mysqli_query($conn, $sql);

// Get paper reviews
$sql = "SELECT 
            p.id as paper_id,
            p.title,
            p.author_id,
            p.status,
            u1.name as author_name,
            r.id as review_id,
            r.score,
            r.recommendation,
            u2.name as reviewer_name
        FROM papers p
        JOIN users u1 ON p.author_id = u1.id
        LEFT JOIN reviews r ON p.id = r.paper_id
        LEFT JOIN users u2 ON r.reviewer_id = u2.id
        WHERE p.status IN ('under_review', 'reviewed')
        ORDER BY p.created_at DESC";
$result = mysqli_query($conn, $sql);
if ($result === false) {
    die("Error: " . mysqli_error($conn));
}

// Store the result in a variable to use in the table
$paper_reviews = $result;
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Online Paper Submission System</title>
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
            animation: pulse 10s infinite alternate;
            z-index: 0;
        }

        .admin-container::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(45deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.2));
            animation: shine 5s infinite;
            z-index: 1;
        }

        @keyframes pulse {
            0% { transform: scale(0.5); opacity: 0.5; }
            100% { transform: scale(1.5); opacity: 0.1; }
        }

        @keyframes shine {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        /* Sidebar */
        .sidebar {
            width: 250px;
            background: rgba(0, 0, 0, 0.9);
            color: #fff;
            transition: all 0.3s ease;
            position: fixed;
            height: 100vh;
            padding: 10px 0;
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

        /* Dashboard Layout */
        .dashboard-content {
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 10px;
            background: rgba(0, 0, 0, 0.8);
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }

        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 10px;
            margin-bottom: 10px;
        }

        .stat-card {
            background: rgba(0, 0, 0, 0.8);
            border: 1px solid rgba(0, 255, 142, 0.1);
            padding: 10px;
            text-align: center;
            border-radius: 5px;
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-card i {
            color: #00ffcc;
            text-shadow: 0 0 5px rgba(0, 255, 204, 0.5);
            font-size: 1.5rem;
        }

        .stat-card h3, .stat-card p {
            color: #00ffcc;
            text-shadow: 0 0 5px rgba(0, 255, 204, 0.5);
            margin: 2px 0;
        }

        .papers-section, .reviews-section {
            margin-bottom: 10px;
        }

        .papers-section h2, .reviews-section h3 {
            color: #00ffcc;
            text-shadow: 0 0 5px rgba(0, 255, 204, 0.5);
            margin-bottom: 5px;
        }

        .papers-table, .reviews-table {
            background: rgba(0, 0, 0, 0.8);
            border: 1px solid rgba(0, 255, 142, 0.1);
            border-radius: 5px;
            overflow-x: hidden;
        }

        .papers-table table, .reviews-table table {
            width: 100%;
            border-collapse: collapse;
        }

        .papers-table th, .reviews-table th {
            background: rgba(0, 255, 142, 0.1);
            color: #fff;
            padding: 8px;
            text-align: left;
        }

        .papers-table td, .reviews-table td {
            padding: 8px;
            border-bottom: 1px solid rgba(0, 255, 142, 0.1);
            color: #fff;
        }

        .action-btn {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            color: #fff;
            padding: 5px 8px;
            text-decoration: none;
            border-radius: 3px;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 3px;
            font-size: 0.9rem;
        }

        .action-btn:hover {
            box-shadow: 0 5px 15px rgba(0, 255, 204, 0.3);
            transform: translateY(-2px);
        }

        .status.success {
            background: rgba(0, 255, 142, 0.1);
            color: #00ffcc;
            padding: 3px 8px;
            border-radius: 10px;
            display: inline-block;
        }

        .status.danger {
            background: rgba(255, 0, 0, 0.1);
            color: #ff0000;
            padding: 3px 8px;
            border-radius: 10px;
            display: inline-block;
        }

        .status.warning {
            background: rgba(255, 255, 0, 0.1);
            color: #ffff00;
            padding: 3px 8px;
            border-radius: 10px;
            display: inline-block;
        }

        .status.secondary {
            background: rgba(128, 128, 128, 0.1);
            color: #888;
            padding: 3px 8px;
            border-radius: 10px;
            display: inline-block;
        }

        /* Animations */
        @keyframes rise {
            0% { transform: translateY(100vh); opacity: 1; }
            100% { transform: translateY(-10vh); opacity: 0; }
        }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
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
                <a href="dashboard.php" class="active">
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
                <!-- Statistics Section -->
                <div class="stats-section">
                    <div class="stat-card">
                        <i class="fas fa-users"></i>
                        <h3>Users</h3>
                        <p><?php echo $stats['total_users']; ?></p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-file-alt"></i>
                        <h3>Papers</h3>
                        <p><?php echo $stats['total_papers']; ?></p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-user-tie"></i>
                        <h3>Reviewers</h3>
                        <p><?php echo $stats['total_reviewers']; ?></p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-user-edit"></i>
                        <h3>Authors</h3>
                        <p><?php echo $stats['total_authors']; ?></p>
                    </div>
                </div>

                <!-- Paper Reviews Section -->
                <div class="reviews-section">
                    <h3>Paper Reviews</h3>
                    <?php if (mysqli_num_rows($paper_reviews) === 0): ?>
                        <p style="color: #00ffcc;">No papers under review found.</p>
                    <?php endif; ?>
                    <div class="reviews-table">
                        <table>
                            <thead>
                                <tr>
                                    <th>Paper ID</th>
                                    <th>Paper Title</th>
                                    <th>Author</th>
                                    <th>Reviewer</th>
                                    <th>Score</th>
                                    <th>Recommendation</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php while ($row = mysqli_fetch_assoc($paper_reviews)): ?>
                                <tr>
                                    <td><?php echo $row['paper_id']; ?></td>
                                    <td><?php echo htmlspecialchars($row['title']); ?></td>
                                    <td><?php echo htmlspecialchars($row['author_name']); ?></td>
                                    <td><?php echo $row['reviewer_name'] ?? 'Not assigned'; ?></td>
                                    <td><?php echo $row['score'] ?? '-'; ?></td>
                                    <td>
                                        <?php 
                                            $recommendation = $row['recommendation'] ?? 'No review';
                                            $recommendation_class = match($recommendation) {
                                                'accept' => 'success',
                                                'reject' => 'danger',
                                                'minor_revision' => 'warning',
                                                'major_revision' => 'warning',
                                                default => 'secondary'
                                            };
                                        ?>
                                        <span class="status <?php echo $recommendation_class; ?>"><?php echo $recommendation; ?></span>
                                    </td>
                                    <td><?php echo ucfirst(str_replace('_', ' ', $row['status'])); ?></td>
                                    <td>
                                        <div class="action-buttons">
                                            <?php if ($row['review_id']): ?>
                                                <a href="../download.php?paper_id=<?php echo $row['paper_id']; ?>" class="action-btn view">
                                                    <i class="fas fa-eye"></i> View
                                                </a>
                                            <?php endif; ?>
                                        </div>
                                    </td>
                                </tr>
                                <?php endwhile; ?>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Recent Papers Section -->
                <div class="papers-section">
                    <h2>Recent Papers</h2>
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
                                <?php 
                                mysqli_data_seek($recent_papers, 0); // Reset pointer
                                while ($paper = mysqli_fetch_assoc($recent_papers)): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($paper['title']); ?></td>
                                    <td><?php echo htmlspecialchars($paper['author_name']); ?></td>
                                    <td><?php echo htmlspecialchars($paper['category_name']); ?></td>
                                    <td>
                                        <span class="status <?php echo $paper['status']; ?>">
                                            <?php echo ucfirst(str_replace('_', ' ', $paper['status'])); ?>
                                        </span>
                                    </td>
                                    <td><?php echo date('M d, Y', strtotime($paper['created_at'])); ?></td>
                                    <td>
                                        <a href="../download.php?paper_id=<?php echo $paper['id']; ?>" class="action-btn view">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                    </td>
                                </tr>
                                <?php endwhile; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Slide-up animation for main-content
        const mainContent = document.querySelector('.main-content');
        mainContent.style.transform = 'translateY(50px)';
        mainContent.style.opacity = '0';
        setTimeout(() => {
            mainContent.style.transition = 'transform 0.6s ease-out, opacity 0.6s ease-out';
            mainContent.style.transform = 'translateY(0)';
            mainContent.style.opacity = '1';
        }, 100);

        // Floating animation for stat-cards and table rows
        const statCards = document.querySelectorAll('.stat-card');
        const tableRows = document.querySelectorAll('.papers-table tbody tr, .reviews-table tbody tr');
        [...statCards, ...tableRows].forEach((element, index) => {
            element.style.animation = `float ${2 + index * 0.2}s infinite ease-in-out`;
        });

        // Pulsing effect for action buttons
        const actionBtns = document.querySelectorAll('.action-btn');
        actionBtns.forEach(btn => {
            setInterval(() => {
                btn.style.boxShadow = '0 0 15px #00ffcc, 0 0 30px #3300ff, 0 0 40px #ff00cc';
                setTimeout(() => {
                    btn.style.boxShadow = '0 5px 15px rgba(0, 255, 204, 0.3)';
                }, 500);
            }, 2000);
        });

        // Particle animation
        function createParticle() {
            const particle = document.createElement('div');
            particle.classList.add('particle');
            particle.style.left = Math.random() * 100 + 'vw';
            particle.style.animationDuration = Math.random() * 5 + 5 + 's';
            particle.style.animationDelay = Math.random() * 2 + 's';
            document.querySelector('.admin-container').appendChild(particle);
            setTimeout(() => particle.remove(), 10000);
        }
        setInterval(createParticle, 500);
    </script>
    <style>
        .particle {
            position: absolute;
            width: 5px;
            height: 5px;
            background: rgba(255, 0, 204, 0.8);
            border-radius: 50%;
            animation: rise 5s infinite linear;
            z-index: 0;
        }
    </style>
</body>
</html>