<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Password Reset Code</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #f7f7f7; padding: 20px;">
    <div style="max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 8px; padding: 24px; box-shadow: 0 2px 6px rgba(0,0,0,0.1);">
        <h2 style="color: #0b6ab4;">Password Reset Request</h2>
        <p>Hello,</p>
        <p>We received a request to reset the password for your TaskConnect account. Use the code below to complete the process:</p>
        <div style="text-align: center; margin: 24px 0;">
            <span style="display: inline-block; font-size: 28px; letter-spacing: 6px; color: #0b6ab4; font-weight: bold; border: 2px solid #0b6ab4; border-radius: 6px; padding: 12px 24px;">
                {{ $code }}
            </span>
        </div>
        <p>This code will expire in 15 minutes. If you did not request a password reset, you can safely ignore this email.</p>
        <p>Thank you,<br/>The TaskConnect Team</p>
    </div>
</body>
</html>

