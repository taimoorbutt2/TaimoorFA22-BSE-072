<?php
// Database configuration
define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'root');
define('DB_PASSWORD', '');
define('DB_NAME', 'onlinepapersub');
define('DB_CHARSET', 'utf8mb4');

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/error_log.txt');

// Function to get a new database connection
function get_db_connection() {
    global $conn;
    
    if (isset($conn) && is_resource($conn)) {
        return $conn;
    }
    
    // Log server status
    error_log("Attempting database connection...");
    error_log("Server: " . DB_SERVER);
    error_log("Username: " . DB_USERNAME);
    error_log("Database: " . DB_NAME);
    
    // First try to connect without database name
    $conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD);
    
    // Check connection
    if ($conn->connect_error) {
        error_log("Connection error: " . $conn->connect_error);
        error_log("Connection error number: " . $conn->connect_errno);
        die("ERROR: Could not connect to MySQL server. Error: " . $conn->connect_error . " (" . $conn->connect_errno . ")");
    }
    
    error_log("Successfully connected to MySQL server");

    // Try to select or create database
    if (!$conn->select_db(DB_NAME)) {
        error_log("Could not select database: " . $conn->error);
        
        // Database doesn't exist, try to create it
        $sql = "CREATE DATABASE IF NOT EXISTS " . DB_NAME . " CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
        error_log("Attempting to create database with query: " . $sql);
        
        if (!$conn->query($sql)) {
            error_log("Failed to create database: " . $conn->error);
            die("ERROR: Could not create database. Error: " . $conn->error);
        }
        
        error_log("Database created successfully");
        
        // Select the newly created database
        if (!$conn->select_db(DB_NAME)) {
            error_log("Failed to select database: " . $conn->error);
            die("ERROR: Could not select database. Error: " . $conn->error);
        }
        
        error_log("Database selected successfully");
    } else {
        error_log("Database selected successfully");
    }

    // Set character set
    if (!$conn->set_charset(DB_CHARSET)) {
        error_log("Error setting charset: " . $conn->error);
        die("ERROR: Could not set charset. Error: " . $conn->error);
    }
    
    error_log("Charset set successfully");

    // Set autocommit to false for transaction support
    $conn->autocommit(FALSE);
    
    error_log("Database connection initialized successfully");
    
    return $conn;
}

// Function to close the connection
function close_db_connection() {
    global $conn;
    if (isset($conn) && is_resource($conn)) {
        $conn->close();
    }
}

// Initialize the connection
$conn = get_db_connection();

// Test the connection
$sql = "SELECT 1";
if (!$conn->query($sql)) {
    error_log("Test query failed: " . $conn->error);
    die("ERROR: Connection test failed. " . $conn->error);
}

// Transaction functions
function begin_transaction() {
    global $conn;
    return mysqli_begin_transaction($conn);
}

function commit_transaction() {
    global $conn;
    return mysqli_commit($conn);
}

function rollback_transaction() {
    global $conn;
    return mysqli_rollback($conn);
}

// Query functions
function prepare_statement($sql) {
    global $conn;
    $stmt = mysqli_prepare($conn, $sql);
    if (!$stmt) {
        error_log("Failed to prepare statement: " . mysqli_error($conn));
        die("ERROR: Could not prepare statement. " . mysqli_error($conn));
    }
    return $stmt;
}

function execute_query($sql) {
    global $conn;
    $result = mysqli_query($conn, $sql);
    if (!$result) {
        error_log("Query failed: " . mysqli_error($conn));
        die("ERROR: Query failed. " . mysqli_error($conn));
    }
    return $result;
}

// Error handling
function handle_db_error($message = "Database error") {
    global $conn;
    error_log($message . ": " . mysqli_error($conn));
    die("ERROR: " . $message . ". Please try again later.");
}
?>
