<?php

function DMStoFloat($d, $m, $s, $dir) {
  $dir_val = ($dir == 'N' || $dir == 'E') ? (1.0) : -1.0;
//echo $d ."°". $m .".". $s . "<br/>";
  return ($dir_val * ( $d + $m/60.0 + $s/3600.0 ));
}


function parseIGC($filename) {
  $result = array();
  $data = explode("\n",file_get_contents($filename));
  foreach ($data as $line) {
    $type = substr($line, 0, 1);
    switch ($type) {
      case 'A':
//echo "A";
      break;
      case 'B':

        $item = array(
          'type' => 'B',
          'time' => (substr($line,1,2) * 3600 +  substr($line,3,2) * 60 + substr($line,5,2)),
          'lat' => DMStoFloat(substr($line,7,2), substr($line,9,2).".".substr($line,11,3), 0, substr($line,14,1)),
          'lon' => DMStoFloat(substr($line,15,3), substr($line,18,2).".".substr($line,20,3), 0, substr($line,23,1)),
          'valid' => (strlen($line) > 25) ? substr($line,25,1) : "",
          'alt_pres' => (strlen($line) > 25) ? substr($line,26,5): 0,
          'alt_gps' => (strlen($line) > 25) ? substr($line,31,5): 0,
          'accuracy' => (strlen($line) > 25) ? substr($line,36,3) : 0,
        );
        array_push($result, $item);
//echo "B";
      break;
      case 'E':
//echo "E";
      break;
      case 'H':
//echo "H";
      break;
      case 'L':
//echo "L";
      break;

    }
//    array_push($result, $line); 
  }

  return $result;

}

?>