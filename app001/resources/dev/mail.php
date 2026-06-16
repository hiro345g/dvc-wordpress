<?php
$to = "user001@dev.internal";
$subject = "TEST";
$message = "This is TEST.\r\nHow are you?";
$headers = "From: noreply@dev.internal";
mail($to, $subject, $message, $headers);