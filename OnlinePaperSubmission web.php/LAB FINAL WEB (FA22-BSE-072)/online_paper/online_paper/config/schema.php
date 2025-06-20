<?php
require_once 'database.php';

// Get a fresh connection
echo "<pre>";
$conn = get_db_connection();
if (!is_object($conn) || $conn->connect_error) {
    die("ERROR: Failed to get database connection: " . ($conn->connect_error ?? 'Unknown error'));
}

echo "Database connection: Success\n";

// Function to create table if it doesn't exist
function create_table($sql) {
    global $conn;
    if (!$conn->query($sql)) {
        echo "Error creating table: " . $conn->error . "\n";
        return false;
    }
    return true;
}

// Create tables in order of dependencies
$tables = [
    'users' => "CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        password VARCHAR(255) NOT NULL,
        email VARCHAR(100) NOT NULL,
        role ENUM('author', 'reviewer', 'admin') NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB",
    
    'categories' => "CREATE TABLE IF NOT EXISTS categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB",
    
    'papers' => "CREATE TABLE IF NOT EXISTS papers (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        abstract TEXT,
        keywords VARCHAR(255),
        file_name VARCHAR(255) NOT NULL,
        file_path VARCHAR(255) NOT NULL,
        category_id INT,
        author_id INT,
        status ENUM('submitted', 'under_review', 'accepted', 'rejected') DEFAULT 'submitted',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (author_id) REFERENCES users(id)
    ) ENGINE=InnoDB",
    
    'assignments' => "CREATE TABLE IF NOT EXISTS assignments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        paper_id INT,
        reviewer_id INT,
        assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status ENUM('pending', 'completed') DEFAULT 'pending',
        FOREIGN KEY (paper_id) REFERENCES papers(id) ON DELETE CASCADE,
        FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE SET NULL
    ) ENGINE=InnoDB",
    
    'reviews' => "CREATE TABLE IF NOT EXISTS reviews (
        id INT AUTO_INCREMENT PRIMARY KEY,
        paper_id INT,
        reviewer_id INT,
        comments TEXT,
        score INT,
        recommendation ENUM('accept', 'minor_revision', 'major_revision', 'reject'),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (paper_id) REFERENCES papers(id) ON DELETE CASCADE,
        FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE SET NULL
    ) ENGINE=InnoDB"
];

// Create tables in order
foreach ($tables as $table => $sql) {
    if (create_table($sql)) {
        echo "{$table} table created/exists\n";
    }
}

// Verify all tables exist
foreach ($tables as $table => $sql) {
    $result = $conn->query("SHOW TABLES LIKE '$table'");
    if ($result && $result->num_rows > 0) {
        echo "Table $table exists\n";
    } else {
        echo "Table $table does not exist\n";
    }
}

// Close the connection
close_db_connection();
echo "\nDatabase schema setup complete\n";

// Create tables if they don't exist
$sql = "CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    institution VARCHAR(255),
    role ENUM('author', 'reviewer', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB";

if (!mysqli_query($conn, $sql)) {
    echo "Error creating users table: " . mysqli_error($conn) . "\n";
} else {
    echo "Users table created/exists\n";
}

// Add more debug output for each table creation
$sql = "CREATE TABLE IF NOT EXISTS papers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    abstract TEXT NOT NULL,
    keywords VARCHAR(255),
    file_path VARCHAR(255) NOT NULL,
    category_id INT,
    author_id INT,
    status ENUM('submitted', 'under_review', 'accepted', 'rejected', 'revision_required') DEFAULT 'submitted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB";

if (!mysqli_query($conn, $sql)) {
    echo "Error creating papers table: " . mysqli_error($conn) . "\n";
} else {
    echo "Papers table created/exists\n";
}

$sql = "CREATE TABLE IF NOT EXISTS assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paper_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_paper_id (paper_id),
    KEY idx_reviewer_id (reviewer_id),
    KEY idx_paper_reviewer (paper_id, reviewer_id)
) ENGINE=InnoDB";

if (!mysqli_query($conn, $sql)) {
    echo "Error creating assignments table: " . mysqli_error($conn) . "\n";
} else {
    echo "Assignments table created/exists\n";
}

// Add foreign keys only if they don't exist
echo "\nAdding foreign keys...\n";

// Check if paper foreign key exists in assignments
$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'assignments' 
        AND constraint_name = 'fk_assignments_paper'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE assignments 
            ADD CONSTRAINT fk_assignments_paper 
            FOREIGN KEY (paper_id) 
            REFERENCES papers(id) 
            ON DELETE CASCADE";
    if (!mysqli_query($conn, $sql)) {
        echo "Error adding paper foreign key: " . mysqli_error($conn) . "\n";
    } else {
        echo "Paper foreign key added\n";
    }
}

// Check if reviewer foreign key exists in assignments
$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'assignments' 
        AND constraint_name = 'fk_assignments_reviewer'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE assignments 
            ADD CONSTRAINT fk_assignments_reviewer 
            FOREIGN KEY (reviewer_id) 
            REFERENCES users(id) 
            ON DELETE SET NULL";
    if (!mysqli_query($conn, $sql)) {
        echo "Error adding reviewer foreign key: " . mysqli_error($conn) . "\n";
    } else {
        echo "Reviewer foreign key added\n";
    }
}

// Create reviews table if it doesn't exist
$sql = "CREATE TABLE IF NOT EXISTS reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paper_id INT,
    reviewer_id INT,
    comments TEXT,
    score INT,
    recommendation ENUM('accept', 'minor_revision', 'major_revision', 'reject'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB";

if (!mysqli_query($conn, $sql)) {
    echo "Error creating reviews table: " . mysqli_error($conn) . "\n";
} else {
    echo "Reviews table created/exists\n";
}

// Check if paper foreign key exists in reviews
$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'reviews' 
        AND constraint_name = 'fk_reviews_paper'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE reviews 
            ADD CONSTRAINT fk_reviews_paper 
            FOREIGN KEY (paper_id) 
            REFERENCES papers(id) 
            ON DELETE CASCADE";
    if (!mysqli_query($conn, $sql)) {
        echo "Error adding paper foreign key to reviews: " . mysqli_error($conn) . "\n";
    } else {
        echo "Paper foreign key to reviews added\n";
    }
}

// Check if reviewer foreign key exists in reviews
$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'reviews' 
        AND constraint_name = 'fk_reviews_reviewer'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE reviews 
            ADD CONSTRAINT fk_reviews_reviewer 
            FOREIGN KEY (reviewer_id) 
            REFERENCES users(id) 
            ON DELETE SET NULL";
    if (!mysqli_query($conn, $sql)) {
        echo "Error adding reviewer foreign key to reviews: " . mysqli_error($conn) . "\n";
    } else {
        echo "Reviewer foreign key to reviews added\n";
    }
}

// Create categories table if it doesn't exist
$sql = "CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB";

if (!mysqli_query($conn, $sql)) {
    echo "Error creating categories table: " . mysqli_error($conn) . "\n";
} else {
    echo "Categories table created/exists\n";
}

// Check if category foreign key exists in papers
$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'papers' 
        AND constraint_name = 'fk_papers_category'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE papers 
            ADD CONSTRAINT fk_papers_category 
            FOREIGN KEY (category_id) 
            REFERENCES categories(id)";
    if (!mysqli_query($conn, $sql)) {
        echo "Error adding category foreign key to papers: " . mysqli_error($conn) . "\n";
    } else {
        echo "Category foreign key to papers added\n";
    }
}

// Check if author foreign key exists in papers
$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'papers' 
        AND constraint_name = 'fk_papers_author'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE papers 
            ADD CONSTRAINT fk_papers_author 
            FOREIGN KEY (author_id) 
            REFERENCES users(id)";
    if (!mysqli_query($conn, $sql)) {
        echo "Error adding author foreign key to papers: " . mysqli_error($conn) . "\n";
    } else {
        echo "Author foreign key to papers added\n";
    }
}

// Verify all tables exist
echo "\nVerifying tables...\n";
$tables = ['users', 'papers', 'assignments', 'reviews', 'categories'];
foreach ($tables as $table) {
    $sql = "SHOW TABLES LIKE '$table'";
    $result = mysqli_query($conn, $sql);
    if ($result && mysqli_num_rows($result) > 0) {
        echo "Table $table exists\n";
    } else {
        echo "Table $table does not exist\n";
    }
}

echo "</pre>";

if (!mysqli_query($conn, $sql)) {
    error_log("Failed to create users table: " . mysqli_error($conn));
    die("ERROR: Could not create users table. " . mysqli_error($conn));
}

$sql = "CREATE TABLE IF NOT EXISTS papers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    abstract TEXT NOT NULL,
    keywords VARCHAR(255),
    file_path VARCHAR(255) NOT NULL,
    category_id INT,
    author_id INT,
    status ENUM('submitted', 'under_review', 'accepted', 'rejected', 'revision_required') DEFAULT 'submitted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB";

if (!mysqli_query($conn, $sql)) {
    error_log("Failed to create papers table: " . mysqli_error($conn));
    die("ERROR: Could not create papers table. " . mysqli_error($conn));
}

$sql = "CREATE TABLE IF NOT EXISTS assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paper_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_paper_id (paper_id),
    KEY idx_reviewer_id (reviewer_id),
    KEY idx_paper_reviewer (paper_id, reviewer_id)
) ENGINE=InnoDB";

if (!mysqli_query($conn, $sql)) {
    error_log("Failed to create assignments table: " . mysqli_error($conn));
    die("ERROR: Could not create assignments table. " . mysqli_error($conn));
}

// Add missing columns to papers table if needed
$sql = "SELECT COUNT(*) as count FROM information_schema.columns 
        WHERE table_schema = DATABASE() 
        AND table_name = 'papers' 
        AND column_name = 'file_name'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE papers ADD COLUMN file_name VARCHAR(255) NOT NULL";
    if (!mysqli_query($conn, $sql)) {
        error_log("Failed to add file_name column: " . mysqli_error($conn));
        die("ERROR: Could not add file_name column. " . mysqli_error($conn));
    }
}

// Check if status column exists and has correct enum values
$sql = "SELECT COUNT(*) as count FROM information_schema.columns 
        WHERE table_schema = DATABASE() 
        AND table_name = 'papers' 
        AND column_name = 'status'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);

if ($row['count'] > 0) {
    // Check if status enum has all required values
    $sql = "SELECT column_type FROM information_schema.columns 
            WHERE table_schema = DATABASE() 
            AND table_name = 'papers' 
            AND column_name = 'status'";
    $result = mysqli_query($conn, $sql);
    $row = mysqli_fetch_assoc($result);
    $enum_values = explode("'", $row['column_type']);
    $required_values = array('submitted', 'under_review', 'accepted', 'rejected', 'revision_required');
    $missing_values = array_diff($required_values, array_filter($enum_values, function($v) { return $v !== ','; }));
    
    if (!empty($missing_values)) {
        // Add missing enum values
        $sql = "ALTER TABLE papers MODIFY status ENUM('submitted', 'under_review', 'accepted', 'rejected', 'revision_required') DEFAULT 'submitted'";
        if (!mysqli_query($conn, $sql)) {
            error_log("Failed to update status enum: " . mysqli_error($conn));
            die("ERROR: Could not update status enum. " . mysqli_error($conn));
        }
    }
}

// Add foreign keys if they don't exist
$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'assignments' 
        AND constraint_name = 'fk_assignments_paper'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE assignments 
            ADD CONSTRAINT fk_assignments_paper 
            FOREIGN KEY (paper_id) 
            REFERENCES papers(id) 
            ON DELETE CASCADE";
    if (!mysqli_query($conn, $sql)) {
        error_log("Failed to add paper foreign key: " . mysqli_error($conn));
        die("ERROR: Could not add paper foreign key. " . mysqli_error($conn));
    }
}

$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'assignments' 
        AND constraint_name = 'fk_assignments_reviewer'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE assignments 
            ADD CONSTRAINT fk_assignments_reviewer 
            FOREIGN KEY (reviewer_id) 
            REFERENCES users(id) 
            ON DELETE SET NULL";
    if (!mysqli_query($conn, $sql)) {
        error_log("Failed to add reviewer foreign key: " . mysqli_error($conn));
        die("ERROR: Could not add reviewer foreign key. " . mysqli_error($conn));
    }
}

$sql = "CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";
if (!mysqli_query($conn, $sql)) {
    error_log("Failed to create categories table: " . mysqli_error($conn));
    die("ERROR: Could not create categories table. " . mysqli_error($conn));
}

$sql = "CREATE TABLE IF NOT EXISTS reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paper_id INT,
    reviewer_id INT,
    comments TEXT,
    score INT,
    recommendation ENUM('accept', 'minor_revision', 'major_revision', 'reject'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB";

if (!mysqli_query($conn, $sql)) {
    error_log("Failed to create reviews table: " . mysqli_error($conn));
    die("ERROR: Could not create reviews table. " . mysqli_error($conn));
}

// Add foreign keys to reviews table
$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'reviews' 
        AND constraint_name = 'fk_reviews_paper'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE reviews 
            ADD CONSTRAINT fk_reviews_paper 
            FOREIGN KEY (paper_id) 
            REFERENCES papers(id) 
            ON DELETE CASCADE";
    if (!mysqli_query($conn, $sql)) {
        error_log("Failed to add paper foreign key to reviews: " . mysqli_error($conn));
        die("ERROR: Could not add paper foreign key to reviews. " . mysqli_error($conn));
    }
}

$sql = "SELECT COUNT(*) as count FROM information_schema.table_constraints 
        WHERE constraint_schema = DATABASE() 
        AND table_name = 'reviews' 
        AND constraint_name = 'fk_reviews_reviewer'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
if ($row['count'] == 0) {
    $sql = "ALTER TABLE reviews 
            ADD CONSTRAINT fk_reviews_reviewer 
            FOREIGN KEY (reviewer_id) 
            REFERENCES users(id) 
            ON DELETE SET NULL";
    if (!mysqli_query($conn, $sql)) {
        error_log("Failed to add reviewer foreign key to reviews: " . mysqli_error($conn));
        die("ERROR: Could not add reviewer foreign key to reviews. " . mysqli_error($conn));
    }
}
?>
