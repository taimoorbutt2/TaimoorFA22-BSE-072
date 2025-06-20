<?php
session_start();
require_once 'config/database.php';

if (isset($_POST['login'])) {
    $email = mysqli_real_escape_string($conn, $_POST['email']);
    $password = $_POST['password'];
    $role = mysqli_real_escape_string($conn, $_POST['role']);

    $sql = "SELECT id, name, email, password, role FROM users WHERE email = ? AND role = ?";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "ss", $email, $role);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if ($user = mysqli_fetch_assoc($result)) {
        if (password_verify($password, $user['password'])) {
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['role'] = $user['role'];
            $_SESSION['user_name'] = $user['name'];
            
            switch ($role) {
                case 'author':
                    header("Location: author/dashboard.php");
                    break;
                case 'reviewer':
                    header("Location: reviewer/dashboard.php");
                    break;
                case 'admin':
                    header("Location: admin/dashboard.php");
                    break;
            }
            exit();
        }
    }
    $error = "Invalid credentials";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Paper Submission System</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/login.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <div class="auth-container">
        <div class="auth-box">
            <div class="auth-header">
                <h1><i class="fas fa-graduation-cap"></i> Online Paper Submission System</h1>
                <p class="tagline">Welcome to the academic paper submission platform</p>
            </div>

            <div class="auth-content">
                <div class="auth-form">
                    <h2><i class="fas fa-sign-in-alt"></i> Login</h2>
                    
                    <?php if (isset($error)): ?>
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle"></i>
                            <span><?php echo $error; ?></span>
                        </div>
                    <?php endif; ?>

                    <form method="POST" action="" id="loginForm">
                        <div class="form-group">
                            <label for="role">
                                <i class="fas fa-user"></i>
                                Role:
                            </label>
                            <select name="role" id="role" required class="form-control">
                                <option value="author">Author <i class="fas fa-pencil-alt"></i></option>
                                <option value="reviewer">Reviewer <i class="fas fa-eye"></i></option>
                                <option value="admin">Admin <i class="fas fa-cog"></i></option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="email">
                                <i class="fas fa-envelope"></i>
                                Email:
                            </label>
                            <input type="email" name="email" id="email" required class="form-control" placeholder="Enter your email">
                        </div>

                        <div class="form-group">
                            <label for="password">
                                <i class="fas fa-lock"></i>
                                Password:
                            </label>
                            <div class="password-container">
                                <input type="password" name="password" id="password" required class="form-control" placeholder="Enter your password">
                                <i class="fas fa-eye" id="togglePassword"></i>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" name="login" class="auth-btn">
                                <i class="fas fa-sign-in-alt"></i>
                                Login
                            </button>
                        </div>
                    </form>

                    <div class="auth-footer">
                        <p>Don't have an account? <a href="register.php" class="auth-link">Register</a></p>
                       
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="assets/js/login.js"></script>
    <script>
        // Slide-up animation for auth-box
        const authBox = document.querySelector('.auth-box');
        authBox.style.transform = 'translateY(50px)';
        authBox.style.opacity = '0';
        setTimeout(() => {
            authBox.style.transition = 'transform 0.6s ease-out, opacity 0.6s ease-out';
            authBox.style.transform = 'translateY(0)';
            authBox.style.opacity = '1';
        }, 100);

        // Floating animation for form groups
        const formGroups = document.querySelectorAll('.form-group');
        formGroups.forEach((group, index) => {
            group.style.animation = `float ${2 + index * 0.2}s infinite ease-in-out`;
        });

        // Pulsing effect for login button
        const loginBtn = document.querySelector('.auth-btn');
        setInterval(() => {
            loginBtn.style.boxShadow = '0 0 15px #00ffcc, 0 0 30px #3300ff, 0 0 40px #ff00cc';
            setTimeout(() => {
                loginBtn.style.boxShadow = '0 5px 15px rgba(0, 255, 204, 0.3)';
            }, 500);
        }, 2000);

        // Particle animation
        function createParticle() {
            const particle = document.createElement('div');
            particle.classList.add('particle');
            particle.style.left = Math.random() * 100 + 'vw';
            particle.style.animationDuration = Math.random() * 5 + 5 + 's';
            particle.style.animationDelay = Math.random() * 2 + 's';
            document.querySelector('.auth-container').appendChild(particle);
            setTimeout(() => particle.remove(), 10000);
        }
        setInterval(createParticle, 500);
    </script>
    <style>
        .particle {
            position: absolute;
            width: 5px;
            height: 5px;
            background: rgba(255, 0, 204, 0.8);
            border-radius: 50%;
            animation: rise 5s infinite linear;
            z-index: 0;
        }
        @keyframes rise {
            0% { transform: translateY(100vh); opacity: 1; }
            100% { transform: translateY(-10vh); opacity: 0; }
        }
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
    </style>
</body>
</html>