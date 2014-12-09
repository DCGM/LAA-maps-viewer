<?php

require('config.php');

function upload_code_to_message($code) {
  $array = array(
    UPLOAD_ERR_INI_SIZE => _("The uploaded file exceeds the upload_max_filesize directive in php.ini"),
    UPLOAD_ERR_FORM_SIZE => _("The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form"),
    UPLOAD_ERR_PARTIAL => _("The uploaded file was only partially uploaded"),
    UPLOAD_ERR_NO_FILE => _("No file was uploaded"),
    UPLOAD_ERR_NO_TMP_DIR => _("Missing a temporary folder"),
    UPLOAD_ERR_CANT_WRITE => _("Failed to write file to disk"),
    UPLOAD_ERR_EXTENSION =>_("File upload stopped by extension"),
  );

  if (!array_key_exists($code, $array)) {
    return "Unknown upload error";
  }
  return $array[$code];

}

function rrmdir($dir) {
 if (is_dir($dir)) {
    $objects = scandir($dir);
    foreach ($objects as $object) {
      if ($object != "." && $object != "..") {
        if (filetype($dir."/".$object) == "dir") {
          rrmdir($dir."/".$object);
        } else {
          unlink($dir."/".$object);
        }
      }
    }
    reset($objects);
    rmdir($dir);
  }
}

function files_in_dir($dir) {
  if (!file_exists($dir) || !is_dir($dir)) {
    return 0;
  }
  $count = 0;
  if ($handle = opendir($dir)) {
    while (false !== ($entry = readdir($handle))) {
        $count++;
    }
    $count -= 2;
    closedir($handle);
  }
  return $count;
}

$content = '';

if (isset($_REQUEST['logout'])) {
  unset($_SESSION['auth']);
}

if ( isset($_REQUEST['user']) && ($_REQUEST['user'] == $config['user']) && ($_REQUEST['pass'] == $config['pass'])) {
  $_SESSION['auth'] = 1;
}

$home_str = _("user");

if (!isset($_SESSION['auth'])) {
  $title = _("Login");
  $login_str = _("login");
  $content .= <<<EOF
  <form action="admin.php" method="post">
    <input type="text" name="user" /> <input type="password" name="pass"/> <input type="submit" value="$login_str" />
  </form>
  <br/>
  <a href="index.php">$home_str</a>
EOF;
  require('template.php'); exit();
} else {
  $footer_buttons  = '';
  $footer_buttons .= "<a href=\"index.php\">$home_str</a> ";
  $footer_buttons .= "<a href=\"admin.php?logout\">"._("logout")."</a> ";
}

$data = (file_exists($config['indexfile'])) ? json_decode(file_get_contents($config['indexfile']), true) : array();


?>