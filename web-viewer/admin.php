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

$content = '';

if (isset($_REQUEST['logout'])) {
  unset($_SESSION['auth']);
}

if ( isset($_REQUEST['user']) && ($_REQUEST['user'] == $config['user']) && ($_REQUEST['pass'] == $config['pass'])) {
  $_SESSION['auth'] = 1;
}

$home_str = _("home");

if (!isset($_SESSION['auth'])) {
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
  $content .= "<a href=\"admin.php?logout\">"._("logout")."</a> <a href=\"index.php\">$home_str</a>";
}

$data = (file_exists($config['indexfile'])) ? json_decode(file_get_contents($config['indexfile']), true) : array();

$submit_str = _("submit");
$year_str = _("year");
$round_str = _("round");
$short_name_str = _("short");
$full_name_str = _("fullname");
$zip_files_str = _("zip files");

$placeholder_year_str = _("2014");
$placeholder_round_str = _("1");
$placeholder_short_str = _("LKHB");
$placeholder_full_str = _("Havlíčkův Brod");

if (isset($_REQUEST['title']) && (strlen($_REQUEST['title']) > 0) )  {

  $content .= "<pre>".print_r($_REQUEST, true). "</pre>";
  $content .= "<pre>".print_r($_FILES, true). "</pre>";

  $year = $_REQUEST['year'];
  $round = (int)$_REQUEST['round'];
  $dirname = $config['datadir'].'/'.$year.'-'.$round.'-'.$_REQUEST['short'];

  if (isset($data[$year][$round])) {
    $content .= _("Error: cannot replace existing round"). ' '. $year. '/'.$round;
//    require('template.php'); exit();
  }


  if ($_FILES['zip']['error'] !== UPLOAD_ERR_OK) {
    $content .= upload_code_to_message($_FILES['zip']['error']);
    require('template.php'); exit();
  }

   $zip = zip_open($_FILES['zip']['tmp_name']);
   if (!is_resource($zip)) {
    $content .= _("Error: cannot open zip");
//    require('template.php'); exit();
   }

   mkdir($dirname);

   while ($zip_entry = zip_read($zip)) {
     if (zip_entry_open($zip,$zip_entry,"r")) {
       $fstream = zip_entry_read($zip_entry, zip_entry_filesize($zip_entry));
       $fullname = $dirname .'/'. basename(zip_entry_name($zip_entry));
       file_put_contents($fullname, $fstream);
       zip_entry_close($zip_entry);
     }
   }
   zip_close($zip);
//  $dirname;



  $data[$year][$round] = array(
    'title' => $_REQUEST['title'],
    'short' => $_REQUEST['short'],
  );

}

$year_now = date('Y');
$round_now = 1;
if (isset($data[$year_now])) {
  foreach ($data[$year_now] as $round => $row) {
    $round_now = max($round_now, $round+1);
  }
}

$content .= <<<EOF
  <form action="admin.php" method="post" enctype="multipart/form-data">
    $year_str <input type="text" name="year" placeholder="$placeholder_year_str" value="$year_now" required /> <br/>
    $round_str <input type="text" name="round" placeholder="$placeholder_round_str" value="$round_now" required /> <br/>
    $short_name_str <input type="text" name="short" placeholder="$placeholder_short_str" required /> <br/>
    $full_name_str <input type="text" name="title" placeholder="$placeholder_full_str" required /> <br/>
    $zip_files_str <input type="file" name="zip" /> <br/>
    <input type="submit" value="$submit_str"/>
  </form>
EOF;

$content .= "<ul>";
foreach ($data as $year => $rounds) {
  $content .= "<li> ". $year . "<ul>";
  foreach ($rounds as $round => $row) {
    $content .= "<li> ".$row['short'] . ' ' .$row['title']. " <a href=\"#\">"._("delete")."</a> </li>";
  }
  $content .= "</ul></li>";
}
$content .= "</ul>";

file_put_contents($config['indexfile'], json_encode($data)) ;

require('template.php');

?>