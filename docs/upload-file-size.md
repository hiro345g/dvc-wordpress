# ファイルアップロードサイズ制限の緩和

WordPress のファイルアップロードサイズ制限の緩和をするには、WordPress フォルダのルートにおく `.htaccess` へ次の指定を追加。

```htaccess
php_value upload_max_filesize 512M
php_value post_max_size 512M
php_value memory_limit 256M
php_value max_execution_time 300
php_value max_input_time 300
```

Nginx を使っている場合は、WordPress フォルダのルートに次の内容で `.user.ini` を用意。

```ini
upload_max_filesize = 512M
post_max_size = 512M
memory_limit = 256M
max_execution_time = 300
max_input_time = 300
```

`wp-config.php` を編集。`/* That's all, stop editing! Happy publishing. */` より前に、次の行を追加。

```php
@ini_set( 'upload_max_filesize', '512M' );
@ini_set( 'post_max_size', '512M' );
@ini_set( 'memory_limit', '256M' );
@ini_set( 'max_execution_time', '300' );
@ini_set( 'max_input_time', '300' );
```
