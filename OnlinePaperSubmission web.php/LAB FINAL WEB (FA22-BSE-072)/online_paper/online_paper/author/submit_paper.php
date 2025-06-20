<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

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

// Get categories for dropdown
$sql = "SELECT id, name FROM categories";
$result = mysqli_query($conn, $sql);
if (!$result) {
    die("Error fetching categories: " . mysqli_error($conn));
}
$categories = mysqli_fetch_all($result, MYSQLI_ASSOC);

// Initialize variables
$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Start transaction
    if (!mysqli_begin_transaction($conn)) {
        $error = "Database error: Failed to start transaction";
        goto display_form;
    }

    // Get form data
    $title = isset($_POST['title']) ? mysqli_real_escape_string($conn, $_POST['title']) : '';
    $abstract = isset($_POST['abstract']) ? mysqli_real_escape_string($conn, $_POST['abstract']) : '';
    $keywords = isset($_POST['keywords']) ? mysqli_real_escape_string($conn, $_POST['keywords']) : '';
    $category_id = isset($_POST['category']) ? mysqli_real_escape_string($conn, $_POST['category']) : '';

    // Handle file upload
    $target_dir = dirname(dirname(__FILE__)) . '/uploads/papers/';
    if (!file_exists($target_dir)) {
        if (!mkdir($target_dir, 0777, true)) {
            $error = "Error: Failed to create uploads directory";
            goto display_form;
        }
    }

    // Validate file upload
    if (!isset($_FILES['file'])) {
        $error = "Error: No file was uploaded";
        goto display_form;
    }

    $upload_error = $_FILES['file']['error'];
    if ($upload_error !== UPLOAD_ERR_OK) {
        $error = "File upload error: " . $upload_error;
        goto display_form;
    }

    // Validate file size (limit to 5MB)
    $max_size = 5 * 1024 * 1024; // 5MB
    if ($_FILES['file']['size'] > $max_size) {
        $error = "Error: File size must be less than 5MB";
        goto display_form;
    }

    // Validate file type
    $allowed_types = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
    $file_type = mime_content_type($_FILES['file']['tmp_name']);
    if (!in_array($file_type, $allowed_types)) {
        $error = "Error: Only PDF and DOC files are allowed";
        goto display_form;
    }

    // Generate unique filename
    $timestamp = time();
    $original_name = $_FILES['file']['name'];
    $extension = pathinfo($original_name, PATHINFO_EXTENSION);
    $unique_filename = $timestamp . '_' . $original_name;

    // Set file path
    $target_file = $target_dir . $unique_filename;

    // Move uploaded file
    if (!move_uploaded_file($_FILES['file']['tmp_name'], $target_file)) {
        $error = "Error uploading file. Please try again.";
        goto display_form;
    }

    // Verify file was uploaded
    if (!file_exists($target_file)) {
        $error = "Error: File not found after upload. Please try again.";
        goto display_form;
    }

    // Insert paper into database
    $sql = "INSERT INTO papers (title, abstract, keywords, file_name, file_path, category_id, author_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = mysqli_prepare($conn, $sql);
    if (!$stmt) {
        $error = "Database error: " . mysqli_error($conn);
        goto display_form;
    }

    if (!mysqli_stmt_bind_param($stmt, "sssissi", $title, $abstract, $keywords, $original_name, $target_file, $category_id, $_SESSION['user_id'])) {
        $error = "Database error: " . mysqli_error($conn);
        goto display_form;
    }

    if (!mysqli_stmt_execute($stmt)) {
        $error = "Database error: " . mysqli_error($conn);
        goto display_form;
    }

    // Get the ID of the newly inserted paper
    $paper_id = mysqli_insert_id($conn);
    if (!$paper_id) {
        $error = "Error: Failed to get paper ID";
        goto display_form;
    }

    // Verify paper was inserted
    $verify_sql = "SELECT id, file_path FROM papers WHERE id = ?";
    if (!$verify_stmt = mysqli_prepare($conn, $verify_sql)) {
        $error = "Database error: " . mysqli_error($conn);
        goto display_form;
    }

    if (!mysqli_stmt_bind_param($verify_stmt, "i", $paper_id)) {
        $error = "Database error: " . mysqli_error($conn);
        goto display_form;
    }

    if (!mysqli_stmt_execute($verify_stmt)) {
        $error = "Database error: " . mysqli_error($conn);
        goto display_form;
    }

    $result = mysqli_stmt_get_result($verify_stmt);
    $paper = mysqli_fetch_assoc($result);
    if (!$paper) {
        $error = "Database error: Paper not found after insertion";
        goto display_form;
    }

    // Commit transaction
    if (!mysqli_commit($conn)) {
        $error = "Database error: Failed to commit transaction";
        goto display_form;
    }

    // Success
    $success = "Paper submitted successfully!";
    mysqli_close($conn);
    header("Location: dashboard.php?success=1&paper_id=" . $paper_id);
    exit();
}

display_form:
// Rollback transaction if we're here due to error
if (isset($error)) {
    mysqli_rollback($conn);
}

// Get any existing paper data for editing
$paper_id = isset($_GET['id']) ? intval($_GET['id']) : null;
if ($paper_id) {
    $sql = "SELECT * FROM papers WHERE id = ? AND author_id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "ii", $paper_id, $_SESSION['user_id']);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $paper = mysqli_fetch_assoc($result);
    if (!$paper) {
        header("Location: dashboard.php");
        exit();
    }
} else {
    $paper = [
        'title' => '',
        'abstract' => '',
        'keywords' => '',
        'category_id' => ''
    ];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Paper - Author Dashboard</title>
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
            animation: zoomGlow 5s infinite ease-in-out;
            z-index: 0;
        }

        @keyframes zoomGlow {
            0% { transform: scale(0.95); opacity: 0.2; }
            50% { transform: scale(1.05); opacity: 0.5; }
            100% { transform: scale(0.95); opacity: 0.2; }
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

        /* Form Container */
        .form-container {
            max-width: 800px;
            margin: 2rem auto;
            padding: 2rem;
            background: rgba(0, 0, 0, 0.7);
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
            animation: fadeInForm 0.5s ease-out;
        }

        @keyframes fadeInForm {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .error {
            color: #ff0000;
            margin-bottom: 1rem;
            padding: 0.5rem;
            background: rgba(255, 0, 0, 0.1);
            border-radius: 5px;
        }

        .success {
            color: #00ffcc;
            margin-bottom: 1rem;
            padding: 0.5rem;
            background: rgba(0, 255, 142, 0.1);
            border-radius: 5px;
        }

        .form-label {
            color: #fff;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .form-control {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(0, 255, 142, 0.1);
            color: #fff;
            border-radius: 5px;
            padding: 0.5rem;
            width: 100%;
            transition: border-color 0.3s ease;
        }

        .form-control:focus {
            border-color: #00ffcc;
            outline: none;
            box-shadow: 0 0 5px rgba(0, 255, 204, 0.5);
        }

        textarea.form-control {
            resize: vertical;
            min-height: 100px;
        }

        .form-select {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(0, 255, 142, 0.1);
            color: #fff;
            border-radius: 5px;
            padding: 0.5rem;
            width: 100%;
            transition: border-color 0.3s ease;
        }

        .form-select:focus {
            border-color: #00ffcc;
            outline: none;
            box-shadow: 0 0 5px rgba(0, 255, 204, 0.5);
        }

        .form-text {
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.9rem;
            margin-top: 0.25rem;
        }

        /* Buttons */
        .btn {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-right: 0.5rem;
        }

        .btn-primary {
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            color: #fff;
            animation: bounceBtn 1.5s infinite ease-in-out;
        }

        @keyframes bounceBtn {
            0% { transform: translateY(0); }
            50% { transform: translateY(-5px); }
            100% { transform: translateY(0); }
        }

        .btn-primary:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0, 255, 204, 0.5);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: scale(1.05);
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
            .form-container {
                margin: 1rem;
                padding: 1rem;
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
                <a href="papers.php" class="nav-item">
                    <i class="fas fa-file-alt"></i>
                    <span>My Papers</span>
                </a>
                <a href="submit_paper.php" class="nav-item active">
                    <i class="fas fa-upload"></i>
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
            <h1>Submit Paper</h1>
            <div class="user-info">
                <span>Welcome back, <?php echo htmlspecialchars($_SESSION['user_name']); ?></span>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="form-container">
                <?php if ($error): ?>
                    <div class="error"><?php echo htmlspecialchars($error); ?></div>
                <?php endif; ?>
                <?php if ($success): ?>
                    <div class="success"><?php echo htmlspecialchars($success); ?></div>
                <?php endif; ?>

                <h2 class="mb-4" style="color: #fff;">Submit New Paper</h2>
                <form method="POST" enctype="multipart/form-data" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label for="title" class="form-label">Title *</label>
                        <input type="text" class="form-control" id="title" name="title" value="<?php echo htmlspecialchars($paper['title']); ?>" required>
                    </div>

                    <div class="mb-3">
                        <label for="abstract" class="form-label">Abstract *</label>
                        <textarea class="form-control" id="abstract" name="abstract" rows="4" required><?php echo htmlspecialchars($paper['abstract']); ?></textarea>
                    </div>

                    <div class="mb-3">
                        <label for="keywords" class="form-label">Keywords</label>
                        <input type="text" class="form-control" id="keywords" name="keywords" value="<?php echo htmlspecialchars($paper['keywords']); ?>">
                        <div class="form-text">Separate keywords with commas</div>
                    </div>

                    <div class="mb-3">
                        <label for="category" class="form-label">Category *</label>
                        <select class="form-select" id="category" name="category" required>
                            <option value="">Select category</option>
                            <?php foreach ($categories as $category): ?>
                                <option value="<?php echo $category['id']; ?>" 
                                    <?php if ($category['id'] == $paper['category_id']): ?>selected<?php endif; ?>>
                                    <?php echo htmlspecialchars($category['name']); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="file" class="form-label">Paper File *</label>
                        <input type="file" class="form-control" id="file" name="file" accept=".pdf,.doc,.docx" required>
                        <div class="form-text">Allowed formats: PDF, DOC, DOCX. Maximum size: 5MB</div>
                    </div>

                    <button type="submit" class="btn btn-primary">Submit Paper</button>
                    <a href="dashboard.php" class="btn btn-secondary">Cancel</a>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Form validation
        (function () {
            'use strict'
            var forms = document.querySelectorAll('.needs-validation')
            Array.prototype.slice.call(forms)
                .forEach(function (form) {
                    form.addEventListener('submit', function (event) {
                        if (!form.checkValidity()) {
                            event.preventDefault()
                            event.stopPropagation()
                        }
                        form.classList.add('was-validated')
                    }, false)
                })
        })()
    </script>
</body>
</html>