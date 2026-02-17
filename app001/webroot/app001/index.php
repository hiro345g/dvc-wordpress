<?php require_once 'config.php'; ?>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>App001 - PHP Application</title>
    <link rel="stylesheet" href="<?php echo BASE_URL; ?>/static/app001.style.css">
    <link rel="stylesheet" href="<?php echo BASE_URL; ?>/static/common.css">
</head>
<body>
    <div class="container">
        <h1>Welcome to App001!</h1>
        <p>This is an example of a PHP application co-existing with WordPress.</p>

        <h2>PHP Output:</h2>
        <pre>
<?php
echo "app001\n";
echo (empty($_SERVER['HTTPS']) ? 'http://' : 'https://') . htmlspecialchars($_SERVER['HTTP_HOST']) . htmlspecialchars($_SERVER['REQUEST_URI']);
// 実行結果例: http://localhost:8080/app001?id=1 [1, 2, 5]
?>
        </pre>

        <h2>Navigation:</h2>
        <ul class="menu">
            <li><a href="static/index.html">Go to Static HTML Examples</a></li>
            <li><a href="../info.php">View PHP Info</a></li>
        </ul>
    </div>
</body>
</html>