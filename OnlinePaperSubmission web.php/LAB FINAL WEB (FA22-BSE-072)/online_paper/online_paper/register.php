<?php
session_start();
require_once 'config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = mysqli_real_escape_string($conn, $_POST['name']);
    $email = mysqli_real_escape_string($conn, $_POST['email']);
    $password = password_hash($_POST['password'], PASSWORD_DEFAULT);
    $role = mysqli_real_escape_string($conn, $_POST['role']);
    
    // Validate email format
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $error = "Invalid email format";
    }

    // Check if email already exists
    $check_email = "SELECT id FROM users WHERE email = ?";
    if ($stmt = mysqli_prepare($conn, $check_email)) {
        mysqli_stmt_bind_param($stmt, "s", $email);
        mysqli_stmt_execute($stmt);
        mysqli_stmt_store_result($stmt);
        if (mysqli_stmt_num_rows($stmt) > 0) {
            $error = "Email already registered";
        }
        mysqli_stmt_close($stmt);
    } else {
        $error = "Database error";
    }

    if (!isset($error)) {
        $sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
        if ($stmt = mysqli_prepare($conn, $sql)) {
            mysqli_stmt_bind_param($stmt, "ssss", $name, $email, $password, $role);
            if (mysqli_stmt_execute($stmt)) {
                header("Location: index.php?success=Registration successful");
                exit();
            } else {
                $error = "Registration failed: " . mysqli_stmt_error($stmt);
            }
            mysqli_stmt_close($stmt);
        } else {
            $error = "Database error: " . mysqli_error($conn);
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Online Paper Submission System</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Auth Container */
        .container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #00ffcc 0%, #3300ff 50%, #ff00cc 100%);
            padding: 20px;
            overflow: hidden;
            position: relative;
        }

        /* Particle Animation */
        .container::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(0, 255, 204, 0.2) 0%, transparent 70%);
            animation: pulse 10s infinite alternate;
            z-index: 0;
        }

        .container::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(45deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.2));
            animation: shine 5s infinite;
            z-index: 1;
        }

        @keyframes pulse {
            0% { transform: scale(0.5); opacity: 0.5; }
            100% { transform: scale(1.5); opacity: 0.1; }
        }

        @keyframes shine {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        /* Card */
        .card {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 450px;
            padding: 2.5rem;
            position: relative;
            z-index: 2;
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 255, 204, 0.3);
        }

        /* Header */
        .card h2 {
            text-align: center;
            color: #000000; /* Black text for header */
            margin-bottom: 1.5rem;
            font-size: 1.5rem;
            font-weight: 600;
            text-shadow: 0 0 5px rgba(0, 255, 204, 0.3);
            animation: pulseText 1.5s infinite alternate;
        }

        @keyframes pulseText {
            0% { transform: scale(1); }
            100% { transform: scale(1.05); }
        }

        /* Form Group */
        .form-group {
            margin-bottom: 1.5rem;
            position: relative;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #000000; /* Black text for labels */
            font-weight: 500;
            text-shadow: 0 0 2px rgba(255, 255, 255, 0.5);
        }

        .form-group input, .form-group select {
            width: 100%;
            padding: 0.8rem 1.2rem;
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.1);
            color: #000000; /* Black text for input fields */
            box-shadow: inset 0 0 5px rgba(0, 255, 204, 0.2);
        }

        .form-group input:focus, .form-group select:focus {
            border-color: #00ffcc;
            box-shadow: 0 0 10px #00ffcc, inset 0 0 5px #00ffcc;
            outline: none;
        }

        /* Submit Button */
        .submit-btn {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, #00ffcc, #ff00cc);
            border: none;
            border-radius: 8px;
            color: #000000; /* Black text for button */
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            text-shadow: 0 0 5px rgba(0, 255, 204, 0.5);
            position: relative;
            overflow: hidden;
        }

        .submit-btn::after {
            content: '';
            position: absolute;
            width: 0;
            height: 100%;
            background: rgba(255, 255, 255, 0.2);
            top: 0;
            left: 0;
            transition: width 0.3s ease;
        }

        .submit-btn:hover::after {
            width: 100%;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px #00ffcc, 0 0 30px #ff00cc;
        }

        .submit-btn:active {
            transform: translateY(0);
        }

        /* Error Message */
        .error-message {
            background: rgba(255, 107, 107, 0.9);
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            border: 2px solid #ff6b6b;
            color: #000000; /* Black text for error message */
            animation: shake 0.5s ease-in-out, fadeIn 0.3s ease-out;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }

        @keyframes fadeIn {
            0% { opacity: 0; }
            100% { opacity: 1; }
        }

        /* Login Link */
        .login-link {
            text-align: center;
            margin-top: 1.5rem;
            color: #000000; /* Black text for login link */
        }

        .login-link a {
            color: #00ffcc;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s ease, text-shadow 0.3s ease;
        }

        .login-link a:hover {
            color: #ff00cc;
            text-shadow: 0 0 10px #ff00cc;
        }

        /* Responsive Design */
        @media (max-width: 480px) {
            .card {
                padding: 1.5rem;
            }

            .card h2 {
                font-size: 1.3rem;
            }

            .form-group input, .form-group select {
                padding: 0.7rem 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h2>Registration Form</h2>
            <?php if (isset($error)): ?>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i>
                    <span><?php echo htmlspecialchars($error); ?></span>
                </div>
            <?php endif; ?>
            <form method="POST" action="">
                <div class="form-group">
                    <label for="name">Full Name:</label>
                    <input type="text" name="name" id="name" required>
                </div>
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" name="email" id="email" required>
                </div>
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" name="password" id="password" required>
                </div>
                <div class="form-group">
                    <label for="role">Role:</label>
                    <select name="role" id="role" required>
                        <option value="author">Author</option>
                        <option value="reviewer">Reviewer</option>
                    </select>
                </div>
                <button type="submit" class="submit-btn">
                    <i class="fas fa-user-plus"></i> Create Account
                </button>
            </form>
            <p class="login-link">Already have an account? <a href="index.php">Login here</a></p>
        </div>
    </div>

    <script>
        // Slide-up animation for card
        const card = document.querySelector('.card');
        card.style.transform = 'translateY(50px)';
        card.style.opacity = '0';
        setTimeout(() => {
            card.style.transition = 'transform 0.6s ease-out, opacity 0.6s ease-out';
            card.style.transform = 'translateY(0)';
            card.style.opacity = '1';
        }, 100);

        // Floating animation for form groups
        const formGroups = document.querySelectorAll('.form-group');
        formGroups.forEach((group, index) => {
            group.style.animation = `float ${2 + index * 0.2}s infinite ease-in-out`;
        });

        // Pulsing effect for submit button
        const submitBtn = document.querySelector('.submit-btn');
        setInterval(() => {
            submitBtn.style.boxShadow = '0 0 15px #00ffcc, 0 0 30px #3300ff, 0 0 40px #ff00cc';
            setTimeout(() => {
                submitBtn.style.boxShadow = '0 5px 15px rgba(0, 255, 204, 0.3)';
            }, 500);
        }, 2000);

        // Particle animation
        function createParticle() {
            const particle = document.createElement('div');
            particle.classList.add('particle');
            particle.style.left = Math.random() * 100 + 'vw';
            particle.style.animationDuration = Math.random() * 5 + 5 + 's';
            particle.style.animationDelay = Math.random() * 2 + 's';
            document.querySelector('.container').appendChild(particle);
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