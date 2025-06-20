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

// Handle category actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['action'])) {
        switch ($_POST['action']) {
            case 'add':
                try {
                    $conn = get_db_connection();
                    begin_transaction();
                    
                    $name = mysqli_real_escape_string($conn, $_POST['name']);
                    $description = mysqli_real_escape_string($conn, $_POST['description']);
                    
                    // Check if category already exists
                    $sql = "SELECT id FROM categories WHERE name = ?";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "s", $name);
                    mysqli_stmt_execute($stmt);
                    $result = mysqli_stmt_get_result($stmt);
                    $existing = mysqli_fetch_assoc($result);
                    
                    if ($existing) {
                        rollback_transaction();
                        header("Location: categories.php?error=Category already exists");
                        exit();
                    }
                    
                    // Add the new category
                    $sql = "INSERT INTO categories (name, description) VALUES (?, ?)";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "ss", $name, $description);
                    
                    if (!mysqli_stmt_execute($stmt)) {
                        rollback_transaction();
                        $error = mysqli_stmt_error($stmt);
                        if (strpos($error, 'Duplicate entry') !== false) {
                            header("Location: categories.php?error=Category already exists");
                        } else {
                            handle_db_error("Failed to add category: " . $error);
                        }
                        exit();
                    }
                    
                    commit_transaction();
                    header("Location: categories.php?success=Category added successfully");
                    exit();
                } catch (Exception $e) {
                    rollback_transaction();
                    handle_db_error("Error adding category: " . $e->getMessage());
                }
                break;

            case 'delete':
                try {
                    $conn = get_db_connection();
                    begin_transaction();
                    
                    $categoryId = mysqli_real_escape_string($conn, $_POST['category_id']);
                    
                    // Check if category exists
                    $sql = "SELECT COUNT(*) as count FROM categories WHERE id = ?";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "i", $categoryId);
                    mysqli_stmt_execute($stmt);
                    $result = mysqli_stmt_get_result($stmt);
                    $category = mysqli_fetch_assoc($result);
                    
                    if ($category['count'] == 0) {
                        rollback_transaction();
                        header("Location: categories.php?error=Category not found");
                        exit();
                    }
                    
                    // Check if category has papers
                    $sql = "SELECT COUNT(*) as paper_count FROM papers WHERE category_id = ?";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "i", $categoryId);
                    mysqli_stmt_execute($stmt);
                    $result = mysqli_stmt_get_result($stmt);
                    $papers = mysqli_fetch_assoc($result);
                    
                    if ($papers['paper_count'] > 0) {
                        rollback_transaction();
                        header("Location: categories.php?error=Cannot delete category. It has papers assigned.");
                        exit();
                    }
                    
                    // Delete the category
                    $sql = "DELETE FROM categories WHERE id = ?";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "i", $categoryId);
                    
                    if (!mysqli_stmt_execute($stmt)) {
                        rollback_transaction();
                        handle_db_error("Failed to delete category");
                    }
                    
                    commit_transaction();
                    header("Location: categories.php?success=Category deleted successfully");
                    exit();
                } catch (Exception $e) {
                    rollback_transaction();
                    handle_db_error("Error deleting category: " . $e->getMessage());
                }
                break;
        }
    }
}

// Get all categories
try {
    $conn = get_db_connection();
    $sql = "SELECT * FROM categories ORDER BY name";
    $result = execute_query($sql);
    $categories = mysqli_fetch_all($result, MYSQLI_ASSOC);
} catch (Exception $e) {
    handle_db_error("Error fetching categories: " . $e->getMessage());
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Categories - Admin Panel</title>
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
            animation: pulseGlow 6s infinite ease-in-out;
            z-index: 0;
        }

        @keyframes pulseGlow {
            0% { transform: scale(0.9); opacity: 0.4; }
            50% { transform: scale(1.1); opacity: 0.7; }
            100% { transform: scale(0.9); opacity: 0.4; }
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

        /* Add Category Form */
        .add-category-form {
            padding: 15px;
            background: rgba(0, 0, 0, 0.7);
            border-radius: 5px;
            animation: pulseForm 2s infinite ease-in-out;
        }

        @keyframes pulseForm {
            0% { transform: scale(1); box-shadow: 0 0 0 rgba(0, 255, 204, 0.3); }
            50% { transform: scale(1.02); box-shadow: 0 0 10px rgba(0, 255, 204, 0.5); }
            100% { transform: scale(1); box-shadow: 0 0 0 rgba(0, 255, 204, 0.3); }
        }

        .add-category-form h2 {
            color: #00ffcc;
            text-shadow: 0 0 5px rgba(0, 255, 204, 0.5);
            margin-bottom: 10px;
        }

        .form-group {
            margin-bottom: 10px;
        }

        .form-group label {
            color: #fff;
            display: block;
            margin-bottom: 5px;
        }

        .form-group input, .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid rgba(0, 255, 142, 0.1);
            border-radius: 5px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
        }

        .submit-btn {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .submit-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0, 255, 204, 0.5);
        }

        /* Categories Table */
        .categories-table {
            padding: 15px;
            background: rgba(0, 0, 0, 0.7);
            border-radius: 5px;
        }

        .categories-table table {
            width: 100%;
            border-collapse: collapse;
        }

        .categories-table th {
            background: rgba(0, 255, 142, 0.1);
            color: #fff;
            padding: 10px;
            text-align: left;
        }

        .categories-table td {
            padding: 10px;
            border-bottom: 1px solid rgba(0, 255, 142, 0.1);
            color: #fff;
            position: relative;
            overflow: hidden;
        }

        .categories-table td::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: radial-gradient(circle, rgba(255, 0, 204, 0.2) 0%, transparent 70%);
            animation: ripple 2s infinite;
            z-index: -1;
        }

        @keyframes ripple {
            0% { transform: translate(-50%, -50%) scale(0); opacity: 0.5; }
            50% { transform: translate(-50%, -50%) scale(1); opacity: 0.2; }
            100% { transform: translate(-50%, -50%) scale(0); opacity: 0.5; }
        }

        .delete-btn {
            background: none;
            border: none;
            color: #ff0000;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .delete-btn:hover {
            color: #ff3333;
            transform: scale(1.2);
        }

        /* Fade-in Animation */
        .main-content {
            animation: fadeIn 0.5s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
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
                <a href="categories.php" class="active">
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

                <div class="add-category-form">
                    <h2>Add New Category</h2>
                    <form method="POST" action="categories.php">
                        <input type="hidden" name="action" value="add">
                        <div class="form-group">
                            <label for="name">Category Name:</label>
                            <input type="text" name="name" id="name" required>
                        </div>
                        <div class="form-group">
                            <label for="description">Description:</label>
                            <textarea name="description" id="description" rows="3"></textarea>
                        </div>
                        <button type="submit" class="submit-btn">
                            <i class="fas fa-plus"></i> Add Category
                        </button>
                    </form>
                </div>

                <div class="categories-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Description</th>
                                <th>Papers</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($categories as $category): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($category['name']); ?></td>
                                    <td><?php echo htmlspecialchars($category['description']); ?></td>
                                    <td>
                                        <?php
                                        $sql = "SELECT COUNT(*) as paper_count 
                                                FROM papers 
                                                WHERE category_id = ?";
                                        $stmt = prepare_statement($sql);
                                        mysqli_stmt_bind_param($stmt, "i", $category['id']);
                                        mysqli_stmt_execute($stmt);
                                        $result = mysqli_stmt_get_result($stmt);
                                        $count = mysqli_fetch_assoc($result);
                                        echo $count['paper_count'];
                                        ?>
                                    </td>
                                    <td>
                                        <form method="POST" action="categories.php" class="delete-form" onsubmit="return handleDelete(event, this)">
                                            <input type="hidden" name="category_id" value="<?php echo $category['id']; ?>">
                                            <input type="hidden" name="action" value="delete">
                                            <button type="submit" class="delete-btn">
                                                <i class="fas fa-trash"></i>
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
    <script>
        function handleDelete(e, form) {
            e.preventDefault();
            if (!confirm('Are you sure you want to delete this category?')) {
                return false;
            }
            form.submit();
            return true;
        }
    </script>
</body>
</html>