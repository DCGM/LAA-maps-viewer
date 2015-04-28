<?php

// specification see at
// http://www.fai.org/gnss-recording-devices/igc-approved-flight-recorders

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
    $item = array(
      'type' => $type
    );

    switch ($type) {
      // Single Instance Data Records (A, H, I, J, C, D, G Records)
      case 'A': //  FR ID NUMBER
       $item = array(
         'type' => $type,
         'manufacturer' => substr($line, 1, 3),
         'unique_id' => substr($line, 4, 3),
         'id_extension' => substr($line, 7),
       );
        array_push($result, $item);
      break;
      case 'H': // FILEHEADER
          $header[substr($line,0,4)] = substr ($line, 5);
      break;
      case 'I': // Extension to the fix (B) record
      break;
      case 'J': // Extension to the K record
      break;
      case 'C': // Task
      break;
      case 'D': // Differential GPS
      break;
      case 'G': // Security
      break;

      // Multiple Instance Data Records (B, E, F, K, L Records)
      case 'B': // FIX
        $item = array(
          'type' => $type,
          'time' => (substr($line,1,2) * 3600 +  substr($line,3,2) * 60 + substr($line,5,2)),
          'lat' => DMStoFloat(substr($line,7,2), substr($line,9,2).".".substr($line,11,3), 0, substr($line,14,1)),
          'lon' => DMStoFloat(substr($line,15,3), substr($line,18,2).".".substr($line,20,3), 0, substr($line,23,1)),
          'valid' => (strlen($line) > 25) ? substr($line,25,1) : "",
          'alt_pres' => (strlen($line) > 25) ? substr($line,26,5): 0,
          'alt_gps' => (strlen($line) > 25) ? substr($line,31,5): 0,
          'accuracy' => (strlen($line) > 25) ? substr($line,36,3) : 0,
        );
        array_push($result, $item);
      break;
      case 'E': // EVENTS
      break;
      case 'F': // Satellite constellation
      break;
      case 'K': // Data needed less frequently than fixes
      break;
      case 'L': // Log book / comments
      break;
    }
//    array_push($result, $line); 
  }
  echo "<pre>".print_r($header, true)."</pre>";

  return $result;

}

?>