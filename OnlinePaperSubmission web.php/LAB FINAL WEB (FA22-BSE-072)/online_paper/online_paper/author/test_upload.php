<?php
session_start();
require_once '../config/database.php';

// Check database connection
$conn = get_db_connection();
if (!$conn) {
    die("Database connection failed");
}

// Check uploads directory
$uploads_dir = "../uploads/papers";
$test_file = $uploads_dir . '/test.txt';

// Check if directory exists
if (!file_exists($uploads_dir)) {
    echo "Uploads directory doesn't exist. Creating...<br>";
    if (!mkdir($uploads_dir, 0777, true)) {
        echo "Failed to create uploads directory<br>";
        echo "Error: " . error_get_last()['message'] . "<br>";
        die();
    }
}

// Check directory permissions
if (!is_writable($uploads_dir)) {
    echo "Uploads directory is not writable<br>";
    die();
}

// Test file creation
if (file_put_contents($test_file, 'Test file content') !== false) {
    echo "Successfully wrote to test file<br>";
    unlink($test_file);
} else {
    echo "Failed to write to test file<br>";
    echo "Error: " . error_get_last()['message'] . "<br>";
}

// Test database connection
if (mysqli_query($conn, "SELECT 1")) {
    echo "Database connection is working<br>";
} else {
    echo "Database connection failed: " . mysqli_error($conn) . "<br>";
}

// Test paper table
$sql = "SELECT COUNT(*) as count FROM papers";
$result = mysqli_query($conn, $sql);
if ($result && $row = mysqli_fetch_assoc($result)) {
    echo "Papers table exists and contains " . $row['count'] . " records<br>";
} else {
    echo "Failed to query papers table: " . mysqli_error($conn) . "<br>";
}
?>
