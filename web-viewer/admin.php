<?php

require('admin-init.php');

$title = _("Administration console");

$submit_str = _("save");
$confirm_delete_str = _('Are you sure?');
$year_str = _("year");
$round_str = _("round");
$short_name_str = _("short");
$full_name_str = _("fullname");

$placeholder_year_str = _("2014");
$placeholder_round_str = _("1");
$placeholder_short_str = _("LKHB");
$placeholder_full_str = _("Havlíčkův Brod");

if (isset($_REQUEST['title']) && (strlen($_REQUEST['title']) > 0) )  {

  $year = $_REQUEST['year'];
  $round = (int)$_REQUEST['round'];
  $dirname = $config['datadir'].'/'.$year.'-'.$round.'-'.$_REQUEST['short'];

  if (isset($data[$year][$round])) {
    $content .= _("Error: cannot replace existing round"). ' '. $year. '/'.$round;
    require('template.php'); exit();
  }


  $data[$year][$round] = array(
    'title' => $_REQUEST['title'],
    'short' => $_REQUEST['short'],
  );

}

if (isset($_REQUEST['delete']) && isset($_REQUEST['year']) && isset($_REQUEST['round']) ) {
  $year = (int)$_REQUEST['year'];
  $round = (int)$_REQUEST['round'];
  if (!isset($data[$year][$round])) {
    $content .= _("Error: item doesn't exists");
  } else {

    $item = $data[$year][$round];
    $dir = sprintf("%s/%d-%d-%s", $config['datadir'], $year, $round, $item['short']);
    if (file_exists($dir) && is_dir($dir)) {
      rrmdir($dir);
    }

    unset($data[$year][$round]);
  }

  if (isset($data[$year]) && (count($data[$year]) == 0)) {
    unset($data[$year]);
  }
}

krsort ($data);
foreach ($data as $year => $item) {
  ksort($data[$year]);
}


$year_now = date('Y');
$round_now = 1;
if (isset($data[$year_now])) {
  foreach ($data[$year_now] as $round => $row) {
    $round_now = max($round_now, $round+1);
  }
}


$content .= "<ul>";
foreach ($data as $year => $rounds) {
  $content .= "<li> ". $year . "<ul>";
  foreach ($rounds as $round => $row) {
    $dir = sprintf("%s/%d-%d-%s", $config['datadir'], $year, $round, $row['short']);
    $count = files_in_dir($dir);
    $content .= "<li> ".$row['short'] . ' ' .$row['title']. ' (' .$count .') ' ;
    $content .= "<a href=\"admin-files.php?year=$year&amp;round=$round#\">"._("files")."</a> \n";
    $content .= "<a href=\"admin.php?delete&amp;year=$year&amp;round=$round#\" onclick=\"return confirm('$confirm_delete_str')\">"._("delete")."</a> </li>\n";
  }
  $content .= "</ul></li>\n\n";
}
$content .= "</ul>";

$content .= <<<EOF
  <br/> 
  <form action="admin.php" method="post" enctype="multipart/form-data">
    $year_str <input type="text" name="year" placeholder="$placeholder_year_str" value="$year_now" required /> <br/>
    $round_str <input type="text" name="round" placeholder="$placeholder_round_str" value="$round_now" required /> <br/>
    $short_name_str <input type="text" name="short" placeholder="$placeholder_short_str" required /> <br/>
    $full_name_str <input type="text" name="title" placeholder="$placeholder_full_str" required /> <br/>
    <input type="submit" value="$submit_str"/>
  </form>

  <br/>
EOF;

if (isset($footer_buttons)) {
  $content .= $footer_buttons;
}



file_put_contents($config['indexfile'], json_encode($data)) ;


require('template.php');

?>