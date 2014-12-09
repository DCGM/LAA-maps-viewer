<?php

require('config.php');
require('csv.php');
$content ="";

if (!isset($_REQUEST['id'])) {
  header('location: index.php');
  exit();
}

$id = $_REQUEST['id'];
$dir = $config['datadir'].'/'.basename($_REQUEST['id']);
$posadky_file = "$dir/posadky.csv";
if (!file_exists("$dir") || !file_exists($posadky_file)) {
  header('location: index.php');
  exit();
}

$posadky = csv_to_array(file_get_contents($posadky_file), ";","\"");
$kat_array = array();
foreach ($posadky as $index => $p) {
  if (trim($p[0]) == "") {
    continue;
  }
  array_push($kat_array, $p[1]);
}
$kat_array = array_unique($kat_array);
sort($kat_array);


$debug = print_r($posadky, true);


$content .= <<<EOF

<h2>Celkové výsledky</h2>

<ul>

EOF;
foreach ($kat_array as $kat) {
  $content .= <<<EOF
  <li><a href="$dir/vysledky $kat.pdf">$kat</a></li>
EOF;
}

$content .= <<<EOF
</ul>

EOF;


$content .= <<<EOF

<h2>Výsledky jednotlivých posádek</h2>

 <ul>
EOF;


foreach ($posadky as $index => $p) {
  if (trim($p[0]) == "") {
    continue;
  }

  $content .= "<li> ".$p[0]." <a href=\"posadka.php?id=$id&crew=$index\">mapa</a> <a href=\"./".$dir."/".rawurlencode($p[2]).".pdf\">tabulka</a> </li>\n";
}

$content .= <<<EOF

 </ul>

EOF;



require('template.php');

?>