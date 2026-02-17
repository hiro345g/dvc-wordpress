<?php
// Define a base path for the application.
// This assumes the application is in a directory directly under the web root.
// We use `basename(__DIR__)` to get the folder name (e.g., 'app001') dynamically.
$app_folder = basename(__DIR__);
define('BASE_URL', '/' . $app_folder);
?>
