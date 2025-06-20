<?php
session_start();
require_once '../config/database.php';

// Debug - Check database connection
if (!$conn) {
    error_log("Database connection failed: " . mysqli_connect_error());
    die("Database connection failed: " . mysqli_connect_error());
}

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

// Debug - Check if we're in the admin panel
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    error_log("Unauthorized access attempt");
    header("Location: ../index.php");
    exit();
}

// Debug - Check if we can query the database
$sql = "SELECT COUNT(*) as count FROM users";
$result = mysqli_query($conn, $sql);
if (!$result) {
    error_log("Error querying users table: " . mysqli_error($conn));
    die("Database error: " . mysqli_error($conn));
}

// Handle user actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    error_log("Received POST request");
    error_log("POST data: " . print_r($_POST, true));
    error_log("Request URI: " . $_SERVER['REQUEST_URI']);
    error_log("Request method: " . $_SERVER['REQUEST_METHOD']);
    error_log("Session data: " . print_r($_SESSION, true));
    error_log("Server data: " . print_r($_SERVER, true));
    error_log("Headers: " . print_r(getallheaders(), true));
    error_log("Environment: " . print_r($_ENV, true));
    error_log("Server variables: " . print_r($_SERVER, true));
    error_log("Request URI: " . $_SERVER['REQUEST_URI']);
    error_log("HTTP_HOST: " . $_SERVER['HTTP_HOST']);
    error_log("HTTP_REFERER: " . (isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'None'));
    if (isset($_POST['action'])) {
        switch ($_POST['action']) {
            case 'add':
                try {
                    $conn = get_db_connection();
                    begin_transaction();
                    
                    $name = mysqli_real_escape_string($conn, $_POST['name']);
                    $email = mysqli_real_escape_string($conn, $_POST['email']);
                    $password = password_hash($_POST['password'], PASSWORD_DEFAULT);
                    $role = mysqli_real_escape_string($conn, $_POST['role']);
                    
                    // Validate inputs
                    if (empty($name) || empty($email) || empty($password) || empty($role)) {
                        rollback_transaction();
                        header("Location: users.php?error=All fields are required");
                        exit();
                    }
                    
                    // Validate email format
                    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                        rollback_transaction();
                        header("Location: users.php?error=Invalid email format");
                        exit();
                    }
                    
                    // Validate role
                    if (!in_array($role, ['author', 'reviewer', 'admin'])) {
                        rollback_transaction();
                        header("Location: users.php?error=Invalid role selected");
                        exit();
                    }
                    
                    // Check if email already exists
                    $sql = "SELECT id FROM users WHERE email = ?";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "s", $email);
                    mysqli_stmt_execute($stmt);
                    $result = mysqli_stmt_get_result($stmt);
                    
                    if (mysqli_num_rows($result) > 0) {
                        rollback_transaction();
                        header("Location: users.php?error=Email already exists");
                        exit();
                    }

                    // Insert the new user
                    $sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "ssss", $name, $email, $password, $role);
                    
                    if (!mysqli_stmt_execute($stmt)) {
                        rollback_transaction();
                        handle_db_error("Failed to add user: " . mysqli_stmt_error($stmt));
                    }
                    
                    commit_transaction();
                    header("Location: users.php?success=User added successfully");
                    exit();
                } catch (Exception $e) {
                    rollback_transaction();
                    handle_db_error("Error adding user: " . $e->getMessage());
                }
                break;

            case 'delete':
                try {
                    $conn = get_db_connection();
                    begin_transaction();
                    
                    $userId = mysqli_real_escape_string($conn, $_POST['user_id']);
                    
                    // Check if user exists
                    $sql = "SELECT id, role FROM users WHERE id = ?";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "i", $userId);
                    mysqli_stmt_execute($stmt);
                    $result = mysqli_stmt_get_result($stmt);
                    $user = mysqli_fetch_assoc($result);
                    
                    if (!$user) {
                        rollback_transaction();
                        header("Location: users.php?error=User not found");
                        exit();
                    }
                    
                    // Prevent admin from deleting themselves
                    if ($userId == $_SESSION['user_id']) {
                        rollback_transaction();
                        header("Location: users.php?error=Cannot delete your own account");
                        exit();
                    }
                    
                    // Delete the user
                    $sql = "DELETE FROM users WHERE id = ?";
                    $stmt = prepare_statement($sql);
                    mysqli_stmt_bind_param($stmt, "i", $userId);
                    
                    if (!mysqli_stmt_execute($stmt)) {
                        rollback_transaction();
                        handle_db_error("Failed to delete user: " . mysqli_stmt_error($stmt));
                    }
                    
                    commit_transaction();
                    header("Location: users.php?success=User deleted successfully");
                    exit();
                } catch (Exception $e) {
                    rollback_transaction();
                    handle_db_error("Error deleting user: " . $e->getMessage());
                }
                break;
        }
    }
}

// Get all users
try {
    $conn = get_db_connection();
    begin_transaction();
    
    $sql = "SELECT * FROM users ORDER BY created_at DESC";
    $result = execute_query($sql);
    $users = mysqli_fetch_all($result, MYSQLI_ASSOC);
    
    commit_transaction();
} catch (Exception $e) {
    rollback_transaction();
    handle_db_error("Error fetching users: " . $e->getMessage());
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Admin Panel</title>
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
            animation: sparkle 8s infinite ease-in-out;
            z-index: 0;
        }

        @keyframes sparkle {
            0% { transform: scale(0.8); opacity: 0.3; }
            50% { transform: scale(1.2); opacity: 0.6; }
            100% { transform: scale(0.8); opacity: 0.3; }
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

        /* Add User Form */
        .add-user-form {
            padding: 15px;
            background: rgba(0, 0, 0, 0.7);
            border-radius: 5px;
            animation: wave 3s infinite ease-in-out;
        }

        @keyframes wave {
            0% { transform: translateY(0); }
            50% { transform: translateY(-5px); }
            100% { transform: translateY(0); }
        }

        .add-user-form h2 {
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

        .form-group input, .form-group select {
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
            animation: rotateGlow 2s infinite linear;
        }

        @keyframes rotateGlow {
            0% { transform: rotate(0deg); box-shadow: 0 0 5px #00ffcc; }
            50% { transform: rotate(180deg); box-shadow: 0 0 15px #ff00cc; }
            100% { transform: rotate(360deg); box-shadow: 0 0 5px #00ffcc; }
        }

        .submit-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0, 255, 204, 0.5);
        }

        /* Users Table */
        .users-table {
            padding: 15px;
            background: rgba(0, 0, 0, 0.7);
            border-radius: 5px;
        }

        .users-table table {
            width: 100%;
            border-collapse: collapse;
        }

        .users-table th {
            background: rgba(0, 255, 142, 0.1);
            color: #fff;
            padding: 10px;
            text-align: left;
        }

        .users-table td {
            padding: 10px;
            border-bottom: 1px solid rgba(0, 255, 142, 0.1);
            color: #fff;
            position: relative;
            overflow: hidden;
        }

        .users-table td::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255, 0, 204, 0.2) 0%, transparent 70%);
            animation: sparkleSpread 3s infinite;
            z-index: -1;
        }

        @keyframes sparkleSpread {
            0% { transform: scale(0); opacity: 0.5; }
            50% { transform: scale(1); opacity: 0.2; }
            100% { transform: scale(0); opacity: 0.5; }
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
                <a href="users.php" class="active">
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

                <!-- Add User Form -->
                <div class="add-user-form">
                    <h2>Add New User</h2>
                    <form method="POST" action="">
                        <input type="hidden" name="action" value="add">
                        
                        <div class="form-group">
                            <label for="name">Full Name:</label>
                            <input type="text" name="name" id="name" required>
                        </div>

                        <div class="form-group">
                            <label for="email">Email:</label>
                            <input type="email" name="email" id="email" required>
                        </div>

                        <div class="form-group">
                            <label for="password">Password:</label>
                            <input type="password" name="password" id="password" required>
                        </div>

                        <div class="form-group">
                            <label for="role">Role:</label>
                            <select name="role" id="role" required>
                                <option value="author">Author</option>
                                <option value="reviewer">Reviewer</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>

                        <button type="submit" class="submit-btn">
                            <i class="fas fa-plus"></i> Add User
                        </button>
                    </form>
                </div>

                <!-- Users Table -->
                <div class="users-table">
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Created At</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($users as $user): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($user['name']); ?></td>
                                    <td><?php echo htmlspecialchars($user['email']); ?></td>
                                    <td>
                                        <span><?php echo htmlspecialchars(ucfirst($user['role'])); ?></span>
                                    </td>
                                    <td><?php echo date('M d, Y', strtotime($user['created_at'])); ?></td>
                                    <td>
                                        <form method="POST" action="users.php" class="delete-form">
                                            <input type="hidden" name="user_id" value="<?php echo $user['id']; ?>">
                                            <input type="hidden" name="action" value="delete">
                                            <button type="submit" class="delete-btn" onclick="return handleDelete(event, this.form, '<?php echo $_SESSION['user_id']; ?>')">
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
    function handleDelete(e, form, currentUserId) {
        e.preventDefault();
        
        if (!confirm('Are you sure you want to delete this user?')) {
            return false;
        }
        
        // Get the user ID from the form
        const userId = form.user_id.value;
        
        // Prevent deleting current user
        if (userId == currentUserId) {
            alert('You cannot delete your own account');
            return false;
        }
        
        // Log form data for debugging
        console.log('Form data:', {
            action: form.action.value,
            user_id: userId
        });
        
        // Submit the form
        form.submit();
        return true;
    }
    </script>
</body>
</html>