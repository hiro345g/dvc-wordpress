# メール送信

ここでは、メール送信機能がうまく動作しないときのための確認方法を説明する。

まず、ログを確認するのにデバッグ情報があると見にくくなるので無効化しておく。

```bash
docker compose -p dvc-wordpress exec -u 0:0 php-apache \
    mv /usr/local/etc/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.disabled
docker compose -p dvc-wordpress exec php-apache \
    kill -HUP 1
```

## msmtp の利用

`php-apache` コンテナのメール送信については、`sendmail` の代わりに `msmtp` を使用している。

`${REPO_DIR}/app001/resources/dev/mail.php` にメール送信の動作確認用 PHP プログラムがある。

```php
<?php
$to = "user001@dev.internal";
$subject = "TEST";
$message = "This is TEST.\r\nHow are you?";
$headers = "From: noreply@dev.internal";
mail($to, $subject, $message, $headers);
```

ファイルの転送

```bash
cd ${REPO_DIR}
docker compose -p dvc-wordpress \
  cp app001/resources/dev/mail.php php-apache:/home/node/workspace/php/mail.php
```

送信テスト。`-u www-data` がうまく動作しない場合は `-u 1000` を指定すること。

```bash
docker compose -p dvc-wordpress exec -u www-data php-apache /usr/local/bin/php -f /home/node/workspace/php/mail.php
```

これで `mailpit` サービスのコンテナにメールが届いたらメール送信機能が正しく動作している。

### dev.internal（mailpit:1025）の利用

`php.ini` の設定変更（`SMTP = dev.internal` は `SMTP = mailpit` でも良い）

```bash
docker compose -p dvc-wordpress exec -u 0:0 php-apache sed -i 's/SMTP = localhost/SMTP = dev.internal/' /usr/local/etc/php/php.ini
docker compose -p dvc-wordpress exec -u 0:0 php-apache sed -i 's/smtp_port = 25/smtp_port = 1025/' /usr/local/etc/php/php.ini
```

設定変更の確認

```bash
$ docker compose -p dvc-wordpress exec -u 0:0 php-apache grep -A 5 "mail function" /usr/local/etc/php/php.ini
[mail function]
SMTP = dev.internal
smtp_port = 1025
mail.add_x_header = Off
mail.mixed_lf_and_crlf = Off
```

送信テスト

```bash
docker compose -p dvc-wordpress exec -u www-data php-apache /usr/local/bin/php -f /home/node/workspace/php/mail.php
```

## telnet での確認

mailpit にメールが届くことを確認するために、動作確認用の `telnet` コマンドをインストール

```bash
docker compose -p dvc-wordpress exec -u 0:0 php-apache bash -c 'apt-get update && apt-get install -y telnet'
```

`telnet` コマンドでメール送信

```bash
docker compose -p dvc-wordpress exec -u 0:0 php-apache bash -c 'telnet dev.internal 1025'
```

接続後の入力（入力の区切りに `#----` を入れてある）

```bash
EHLO localhost
#----
MAIL FROM:<noreply@dev.internal>
#----
RCPT TO:<user001@dev.internal>
#----
DATA
#----
From: noreply@dev.internal
To: user001@dev.internal
Subject: Telnet Test Mail

This is a test message from telnet.
.
#----
QUIT
```

実際のログ

```bash
$ docker compose -p dvc-wordpress exec -u 0:0 php-apache bash -c 'telnet dev.internal 1025'
Trying 172.30.0.2...
Connected to dev.internal.
Escape character is '^]'.
220 dev.internal Mailpit ESMTP Service ready
EHLO localhost
250-dev.internal greets localhost
250-SIZE 52428800
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 SMTPUTF8
MAIL FROM:<noreply@dev.internal>
250 2.1.0 Ok
RCPT TO:<user001@dev.internal>
250 2.1.5 Ok
DATA
354 Start mail input; end with <CR><LF>.<CR><LF>
Subject: Telnet Test Mail

This is a test message from telnet. 
.
250 2.0.0 Ok: queued as 32kKYD1ZxiYD97RXZ0Kwmj
QUIT
221 2.0.0 dev.internal Mailpit ESMTP Service closing transmission channel
Connection closed by foreign host.
```

受け取ったメールの Raw データ

```text
Message-ID: <25cjZBL9kWvnkxWVbGlAlJ@mailpit>
Return-Path: <noreply@dev.internal>
Received: from localhost (php-apache.dvc-wordpress-net. [172.30.0.4])
        by dev.internal (Mailpit) with SMTP
        for <user001@dev.internal>; Tue, 16 Jun 2026 13:33:59 +0000 (UTC)
From: noreply@dev.internal
To: user001@dev.internal
Subject: Telnet Test Mail

This is a test message from telnet.
```
