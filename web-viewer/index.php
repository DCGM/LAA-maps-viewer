<?php

require('config.php');


$title = "Pohár Petra Tučka";
$content = '';


$data = (file_exists($config['indexfile'])) ? json_decode(file_get_contents($config['indexfile']), true) : array();

if (count($data) == 0) {
  $content .= _("No competition entered");
}


$content .= "<ul>";
foreach ($data as $year => $rounds) {
  $content .= "<li> ". $year . "<ul>\n";
  foreach ($rounds as $round => $row) {
    $content .= "<li> <a href=\"soutez.php?id=".$year.'-'.$round.'-'.$row['short']."\">". 
($round.". kolo"). ' ' .$row['title']. "</a></li>\n";
  }
  $content .= "</ul></li>\n";
}

$content .= "</ul>\n\n";

$admin_btn = _('admin');
if (isset($_SESSION['auth'])) {
  $content .= "<a href=\"admin.php\">$admin_btn</a>";
}

  require('template.php');
?>

