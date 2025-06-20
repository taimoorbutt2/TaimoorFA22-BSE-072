<?php
session_start();
require_once '../config/database.php';

// Check if user is logged in and is an author
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'author') {
    header("Location: ../index.php");
    exit();
}

// Check if paper ID is provided
if (!isset($_GET['id'])) {
    die("Paper ID not provided");
}

$paper_id = mysqli_real_escape_string($conn, $_GET['id']);

// Start transaction
if (!mysqli_begin_transaction($conn)) {
    die("Error starting transaction: " . mysqli_error($conn));
}

try {
    // Get paper details to verify ownership and get file path
    $sql = "SELECT p.*, c.name as category_name 
            FROM papers p 
            LEFT JOIN categories c ON p.category_id = c.id 
            WHERE p.id = ? AND p.author_id = ?";

    if (!$stmt = mysqli_prepare($conn, $sql)) {
        throw new Exception("Error preparing statement: " . mysqli_error($conn));
    }

    if (!mysqli_stmt_bind_param($stmt, "ii", $paper_id, $_SESSION['user_id'])) {
        throw new Exception("Error binding parameters: " . mysqli_error($conn));
    }

    if (!mysqli_stmt_execute($stmt)) {
        throw new Exception("Error executing statement: " . mysqli_error($conn));
    }

    $result = mysqli_stmt_get_result($stmt);
    $paper = mysqli_fetch_assoc($result);

    if (!$paper) {
        throw new Exception("Paper not found or you don't have permission to delete it");
    }

    // Delete the file
    $target_dir = dirname(__FILE__) . '/../uploads/papers/';
    $file_path = $target_dir . $paper['file_path'];

    if (file_exists($file_path)) {
        if (!unlink($file_path)) {
            throw new Exception("Error deleting file: " . error_get_last()['message']);
        }
    }

    // Delete from database
    $delete_sql = "DELETE FROM papers WHERE id = ? AND author_id = ?";

    if (!$stmt = mysqli_prepare($conn, $delete_sql)) {
        throw new Exception("Error preparing delete statement: " . mysqli_error($conn));
    }

    if (!mysqli_stmt_bind_param($stmt, "ii", $paper_id, $_SESSION['user_id'])) {
        throw new Exception("Error binding delete parameters: " . mysqli_error($conn));
    }

    if (!mysqli_stmt_execute($stmt)) {
        throw new Exception("Error deleting paper: " . mysqli_error($conn));
    }

    // Commit transaction
    if (!mysqli_commit($conn)) {
        throw new Exception("Error committing transaction: " . mysqli_error($conn));
    }

    // Redirect back to papers page
    header("Location: papers.php?success=Paper deleted successfully");
    exit();

} catch (Exception $e) {
    // Rollback transaction on error
    mysqli_rollback($conn);
    die("Error: " . $e->getMessage());
}
?>
