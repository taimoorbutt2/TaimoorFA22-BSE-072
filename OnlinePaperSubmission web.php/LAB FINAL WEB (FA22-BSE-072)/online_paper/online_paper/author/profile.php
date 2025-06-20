<?php
session_start();
require_once '../config/database.php';

// Check if user is logged in and is an author
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'author') {
    header("Location: ../index.php");
    exit();
}

// Get user information
$user_id = $_SESSION['user_id'];
$sql = "SELECT * FROM users WHERE id = ?";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $user_id);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$user = mysqli_fetch_assoc($result);

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validate and update user information
    $name = mysqli_real_escape_string($conn, $_POST['name']);
    $email = mysqli_real_escape_string($conn, $_POST['email']);
    $institution = mysqli_real_escape_string($conn, $_POST['institution']);
    
    // Update user information
    $sql = "UPDATE users SET name = ?, email = ?, institution = ? WHERE id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    
    if ($stmt === false) {
        $error = "Error preparing statement: " . mysqli_error($conn);
    } else {
        if (!mysqli_stmt_bind_param($stmt, "sssi", $name, $email, $institution, $user_id)) {
            $error = "Error binding parameters: " . mysqli_stmt_error($stmt);
        } else {
            if (mysqli_stmt_execute($stmt)) {
                $_SESSION['user_name'] = $name; // Update session name
                $success = "Profile updated successfully!";
            } else {
                $error = "Error updating profile: " . mysqli_stmt_error($stmt);
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - Author Dashboard</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/author.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .profile-container {
            max-width: 600px;
            margin: 2rem auto;
            padding: 2rem;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .profile-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .profile-header img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            margin-bottom: 1rem;
        }
        .profile-form .form-group {
            margin-bottom: 1.5rem;
        }
        .profile-form label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: bold;
        }
        .profile-form input[type="text"],
        .profile-form input[type="email"] {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .profile-form button {
            background-color: #007bff;
            color: white;
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .profile-form button:hover {
            background-color: #0056b3;
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
                        <div class="name"><?php echo htmlspecialchars($user['name']); ?></div>
                        <div class="role">Author</div>
                    </div>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <a href="dashboard.php">
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
                <a href="profile.php" class="active">
                    <i class="fas fa-user"></i>
                    <span>Profile</span>
                </a>
                <a href="../logout.php">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="profile-container">
                <div class="profile-header">
                    <h1>My Profile</h1>
                </div>

                <?php if (isset($error)): ?>
                    <div class="alert alert-danger"><?php echo htmlspecialchars($error); ?></div>
                <?php endif; ?>

                <?php if (isset($success)): ?>
                    <div class="alert alert-success"><?php echo htmlspecialchars($success); ?></div>
                <?php endif; ?>

                <form method="POST" class="profile-form">
                    <div class="form-group">
                        <label for="name">Name</label>
                        <input type="text" id="name" name="name" value="<?php echo htmlspecialchars($user['name']); ?>" required>
                    </div>

                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" value="<?php echo htmlspecialchars($user['email']); ?>" required>
                    </div>

                    <div class="form-group">
                        <label for="institution">Institution</label>
                        <input type="text" id="institution" name="institution" value="<?php echo isset($user['institution']) ? htmlspecialchars($user['institution']) : ''; ?>">
                    </div>

                    <button type="submit" class="btn btn-primary">Update Profile</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
