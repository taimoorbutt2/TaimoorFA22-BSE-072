-- First create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS onlinepapersub;
USE onlinepapersub;

-- Drop tables in reverse order to avoid foreign key constraints
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS papers;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

-- Create base tables first without foreign keys

-- Create users table (base table)
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    institution VARCHAR(255),
    role ENUM('author', 'reviewer', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create categories table (independent)
CREATE TABLE IF NOT EXISTS categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

-- Create papers table (depends on users and categories)
CREATE TABLE IF NOT EXISTS papers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    abstract TEXT NOT NULL,
    keywords VARCHAR(255),
    file_path VARCHAR(255) NOT NULL,
    category_id INT,
    author_id INT,
    status ENUM('submitted', 'under_review', 'accepted', 'rejected', 'revision_required') DEFAULT 'submitted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create reviews table (depends on papers and users)
CREATE TABLE IF NOT EXISTS reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paper_id INT,
    reviewer_id INT,
    comments TEXT,
    score INT,
    recommendation ENUM('accept', 'minor_revision', 'major_revision', 'reject'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create assignments table (depends on papers and users)
CREATE TABLE IF NOT EXISTS assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paper_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_paper_id (paper_id),
    KEY idx_reviewer_id (reviewer_id),
    KEY idx_paper_reviewer (paper_id, reviewer_id)
) ENGINE=InnoDB;

-- Add foreign key constraints after all tables are created

-- Add foreign keys to papers table
ALTER TABLE papers
    ADD CONSTRAINT fk_papers_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

ALTER TABLE papers
    ADD CONSTRAINT fk_papers_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

-- Add foreign keys to reviews table
ALTER TABLE reviews
    ADD CONSTRAINT fk_reviews_paper FOREIGN KEY (paper_id) REFERENCES papers(id) ON DELETE CASCADE;

ALTER TABLE reviews
    ADD CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE SET NULL;

-- Ensure assignments table has no invalid reviewer_id values
DELETE FROM assignments WHERE reviewer_id IS NOT NULL AND reviewer_id NOT IN (SELECT id FROM users);

-- Add foreign keys to assignments table
ALTER TABLE assignments
    ADD CONSTRAINT fk_assignments_paper FOREIGN KEY (paper_id) REFERENCES papers(id) ON DELETE CASCADE;

ALTER TABLE assignments
    ADD CONSTRAINT fk_assignments_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE SET NULL;

-- Insert some sample categories
INSERT INTO categories (name, description) VALUES
('Computer Science', 'Research papers related to computer science and technology'),
('Engineering', 'Engineering research and development papers'),
('Mathematics', 'Mathematical research and theories'),
('Natural Sciences', 'Research in natural sciences and biology');

-- Insert a default admin user
INSERT INTO users (name, email, password, role) VALUES
('Admin User', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');
-- Note: The password is 'password' (hashed using bcrypt)