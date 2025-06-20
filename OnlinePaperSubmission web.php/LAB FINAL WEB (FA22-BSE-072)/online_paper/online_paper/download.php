<?php
session_start();
require_once 'config/database.php';

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: index.php");
    exit();
}

// Get paper ID from URL
if (!isset($_GET['paper_id'])) {
    die("Error: Paper ID not provided");
}

$paper_id = intval($_GET['paper_id']);
$user_id = $_SESSION['user_id'];
$user_role = $_SESSION['role'];

// Log for debugging
error_log("Download attempt: Paper ID = $paper_id, User ID = $user_id, Role = $user_role");

// Get paper details
$sql = "SELECT p.file_path, p.file_name, p.author_id 
        FROM papers p 
        WHERE p.id = ?";
$stmt = mysqli_prepare($conn, $sql);
if (!$stmt) {
    die("Error: " . mysqli_error($conn));
}

mysqli_stmt_bind_param($stmt, "i", $paper_id);
if (!mysqli_stmt_execute($stmt)) {
    die("Error executing query: " . mysqli_stmt_error($stmt));
}

$result = mysqli_stmt_get_result($stmt);
if (!$result) {
    die("Error getting result: " . mysqli_error($conn));
}

if ($row = mysqli_fetch_assoc($result)) {
    // Log paper details
    error_log("Paper found: File path = " . $row['file_path'] . ", File name = " . $row['file_name']);
    
    // Check user permissions
    $is_author = $row['author_id'] == $user_id;
    $is_admin = $user_role === 'admin';
    $is_reviewer = false;

    if ($user_role === 'reviewer') {
        // Check if reviewer is assigned to this paper
        $sql = "SELECT COUNT(*) as count 
                FROM assignments 
                WHERE paper_id = ? AND reviewer_id = ?";
        $stmt = mysqli_prepare($conn, $sql);
        if (!$stmt) {
            die("Error: " . mysqli_error($conn));
        }
        
        mysqli_stmt_bind_param($stmt, "ii", $paper_id, $user_id);
        if (!mysqli_stmt_execute($stmt)) {
            die("Error executing assignment check: " . mysqli_stmt_error($stmt));
        }
        
        $result = mysqli_stmt_get_result($stmt);
        if (!$result) {
            die("Error getting assignment result: " . mysqli_error($conn));
        }
        
        $assignment_row = mysqli_fetch_assoc($result);
        $is_reviewer = $assignment_row['count'] > 0;
    }

    if (!$is_author && !$is_admin && !$is_reviewer) {
        die("Error: You do not have permission to access this paper");
    }

    // Get file details
    $file_path = $row['file_path'];
    $file_name = $row['file_name'];

    // Normalize path separators
    $file_path = str_replace('/', DIRECTORY_SEPARATOR, $file_path);
    $file_path = str_replace('\\', DIRECTORY_SEPARATOR, $file_path);

    // Get absolute path
    $absolute_path = realpath($file_path);
    
    // Log paths
    error_log("Raw file path: " . $file_path);
    error_log("Absolute file path: " . $absolute_path);
    error_log("File exists: " . (file_exists($file_path) ? 'true' : 'false'));
    error_log("Is readable: " . (is_readable($file_path) ? 'true' : 'false'));

    // Validate file path
    if (!$absolute_path || !file_exists($file_path)) {
        error_log("File not found: $file_path");
        die("Error: File not found");
    }

    // Get file type
    $file_type = mime_content_type($file_path);
    if (!$file_type) {
        die("Error: Could not determine file type");
    }

    // Set headers
    header('Content-Type: ' . $file_type);
    header('Content-Disposition: inline; filename="' . $file_name . '"');
    header('Content-Length: ' . filesize($file_path));
    header('Pragma: no-cache');
    header('Expires: 0');

    // Log file size
    error_log("File size: " . filesize($file_path) . " bytes");

    // Output the file
    if (!readfile($file_path)) {
        error_log("Error reading file: " . $file_path);
        die("Error reading file");
    }
    exit();
} else {
    error_log("Paper not found: ID = $paper_id");
    die("Error: Paper not found");
}
$result = mysqli_stmt_get_result($stmt);
$paper = mysqli_fetch_assoc($result);

if (!$paper) {
    die("Paper not found");
}

// Verify user has access to this paper (must be the author)
if ($paper['author_id'] != $_SESSION['user_id']) {
    die("Access denied");
}

// Get the file path from database
$relative_path = $paper['file_path'];

// Convert relative path to absolute path
$base_path = __DIR__ . '/uploads/papers/';
$file_path = $base_path . $paper['file_path'];

// Debug logging
error_log("Attempting to access file: " . $file_path);
error_log("File exists: " . (file_exists($file_path) ? 'Yes' : 'No'));
error_log("Database file path: " . $paper['file_path']);
error_log("Base path: " . $base_path);
error_log("Full path: " . $file_path);

// Verify file exists
if (!file_exists($base_path)) {
    error_log("Uploads directory not found: " . $base_path);
    error_log("Directory contents: " . print_r(scandir(dirname($base_path)), true));
    die("Uploads directory not found: " . $base_path);
}

if (!file_exists($file_path)) {
    error_log("File not found: " . $file_path);
    error_log("Directory contents: " . print_r(scandir($base_path), true));
    die("File not found: " . $file_path);
}

// Get file info
$filename = basename($file_path);
$filesize = filesize($file_path);
$filetype = mime_content_type($file_path);

// Set headers for file download
header('Content-Type: ' . $filetype);
header('Content-Length: ' . $filesize);
header('Content-Disposition: attachment; filename="' . $filename . '"');
header('Content-Transfer-Encoding: binary');

// Read and output the file
readfile($file_path);
exit();
?>
