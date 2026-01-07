<?php
require_once __DIR__ . '/../../models/User.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit();
}

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate input
if (empty($data->email) || empty($data->password)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Email and password are required'
    ]);
    exit();
}

// Get user
$user = new User();
$userData = $user->getUserByEmail(trim($data->email));

// Check if user exists
if (!$userData) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email or password'
    ]);
    exit();
}

// Verify password
if (!$user->verifyPassword($data->password, $userData['password'])) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email or password'
    ]);
    exit();
}

// Generate simple token (for now, just base64 encode user id and timestamp)
// In production, use JWT library
$token = base64_encode(json_encode([
    'user_id' => $userData['id'],
    'email' => $userData['email'],
    'timestamp' => time()
]));

http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Login successful',
    'data' => [
        'token' => $token,
        'user' => [
            'id' => $userData['id'],
            'name' => $userData['name'],
            'email' => $userData['email'],
            'created_at' => $userData['created_at']
        ]
    ]
]);
?>
