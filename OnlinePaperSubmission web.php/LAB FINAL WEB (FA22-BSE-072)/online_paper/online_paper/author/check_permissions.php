<?php
$upload_dir = "../uploads/papers";

if (file_exists($upload_dir)) {
    echo "Upload directory exists.<br>";
    
    if (is_writable($upload_dir)) {
        echo "Upload directory is writable.<br>";
    } else {
        echo "Upload directory is NOT writable.<br>";
    }
} else {
    echo "Upload directory does not exist.<br>";
}

// Test file upload
$test_file = $upload_dir . '/test.txt';
if (file_put_contents($test_file, 'Test file') !== false) {
    echo "Successfully wrote to test file.<br>";
    unlink($test_file);
} else {
    echo "Failed to write to test file.<br>";
}
?>
