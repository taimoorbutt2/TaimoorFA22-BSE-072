<?php
session_start();
require_once '../config/database.php';

// Check if user is logged in and is an admin
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header("Location: ../index.php");
    exit();
}

// Get paper ID and new status
$paper_id = isset($_POST['paper_id']) ? intval($_POST['paper_id']) : 0;
$status = isset($_POST['status']) ? mysqli_real_escape_string($conn, $_POST['status']) : '';

// Validate input
if ($paper_id <= 0 || empty($status)) {
    $_SESSION['error'] = "Invalid input parameters";
    header("Location: dashboard.php");
    exit();
}

// Check if paper exists and get current status
$sql = "SELECT id, status FROM papers WHERE id = ?";
$stmt = mysqli_prepare($conn, $sql);
mysqli_stmt_bind_param($stmt, "i", $paper_id);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$paper = mysqli_fetch_assoc($result);

if (!$paper) {
    $_SESSION['error'] = "Paper not found";
    header("Location: dashboard.php");
    exit();
}

// Check if all reviews are completed if changing from 'reviewed'
if ($paper['status'] === 'reviewed' && $status !== 'reviewed') {
    $sql = "SELECT COUNT(*) as total_reviews, 
            (SELECT COUNT(*) FROM assignments WHERE paper_id = ?) as total_assignments
            FROM reviews WHERE paper_id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "ii", $paper_id, $paper_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $stats = mysqli_fetch_assoc($result);

    if (!$stats || $stats['total_reviews'] < $stats['total_assignments']) {
        $_SESSION['error'] = "Cannot change status: Not all reviews are completed";
        header("Location: dashboard.php");
        exit();
    }
}

// Start transaction
mysqli_begin_transaction($conn);

try {
    // Update paper status
    $sql = "UPDATE papers SET status = ? WHERE id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "si", $status, $paper_id);
    if (!mysqli_stmt_execute($stmt)) {
        throw new Exception("Error updating paper status: " . mysqli_stmt_error($stmt));
    }

    // Update assignments status
    $sql = "UPDATE assignments SET status = ? WHERE paper_id = ?";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "si", $status, $paper_id);
    if (!mysqli_stmt_execute($stmt)) {
        throw new Exception("Error updating assignments status: " . mysqli_stmt_error($stmt));
    }

    // Commit transaction
    mysqli_commit($conn);
    
    $_SESSION['success'] = "Paper status updated successfully";
    header("Location: dashboard.php");
    exit();

} catch (Exception $e) {
    // Rollback transaction
    mysqli_rollback($conn);
    
    // Log error
    error_log("Error updating paper status: " . $e->getMessage());
    
    // Set error message
    $_SESSION['error'] = "Error updating paper status: " . $e->getMessage();
    header("Location: dashboard.php");
    exit();
}
?>
