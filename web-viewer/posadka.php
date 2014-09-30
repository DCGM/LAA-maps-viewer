<?php

require('config.php');
require('csv.php');
require('igc.php');
require('geo.php');

if (!isset($_REQUEST['id'])) {
  header('location: index.php');
  exit();
}

$dir = $config['datadir'].'/'.basename($_REQUEST['id']);
$posadky_file = $dir."/posadky.csv";
if (!file_exists($dir) || !file_exists($posadky_file)) {
  header('location: index.php');
  exit();
}

$crew = isset($_REQUEST['crew']) ? (int)$_REQUEST['crew'] : 0;

$posadky = csv_to_array(file_get_contents($posadky_file), ";","\"");

if ($crew < 0 || $crew > count($posadky)) {
  header('location: index.php');
  exit();
}
 

$posadka = $posadky[$crew];
$kat = $posadka[1];


$start_time = 3600 * substr($posadka[3], 0,2) + 60* substr($posadka[3], 3,2) + substr($posadka[3], 6,2);

if (count($posadka) < 5) {
 die('incorrect format');
}
$posadka_nazev = $posadka[0];
$track_file = $dir ."/track.json";
$igc_file = $dir."/".$posadka[4];

if (!file_exists($track_file)) {
  die('track not found!');
}

if (!file_exists($igc_file)) {
  die('igc file not found!');
}

//$debug = print_r($posadka, true);

$igc = parseIGC($igc_file);

//echo "<pre>".print_r($igc, true)."</pre>";;
//foreach ($igc as $rec) {
//  print_r($rec['lat']. " ". $rec['lon']);
//  print_r($rec['time']);
//}


$content =<<<EOF

<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script type="text/javascript">
  function initialize() {

    var myLatlng = new google.maps.LatLng(49,16);
    var myOptions = {
      zoom: 8,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    panControl: true,
    zoomControl: true,
    scaleControl: true,

    }

    var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

EOF;


function getPoint($pid) {
  global $track;
  foreach ($track['points'] as $p) {
    if ($p['pid'] == $pid) {
      return $p;
    }
  }
  return array( 'lat' => 0, 'lon' => 0, 'name' => '', 'pid' => -1 );
}

function getPoly($cid) {
  global $track;
  foreach ($track['poly'] as $p) {
    if ($p['cid'] == $cid) {
      return $p;
    }
  }
  return array( 'cid' => -1, 'color' => 'FF0000', 'name' => '', 'points' => array());
}

$track = json_decode(file_get_contents($track_file), true);
$track_kat = array(
  'conn' => array()
);
foreach ($track['tracks'] as $t) {
  if ($t['name'] == $kat) {
    $track_kat = $t;
  }
}

$min_lat = $min_lon = 360;
$max_lat = $max_lon = -360;
$i = 0;

$prevType = 'none';

$ppc = 0;
foreach ($track_kat['poly'] as $kat_poly) {
  $poly = getPoly($kat_poly['cid']);
  $color = $poly['color'];
  $content .= "var ppcoords_$ppc = [];\n";
  foreach ($poly['points'] as $polypt) {
      $content .= "ppcoords_$ppc.push(new google.maps.LatLng(".$polypt['lat'].", ".$polypt['lon']."));\n";
  }
      $content .= <<<EOF
        var ptline_$ppc = new google.maps.Polyline({
      path: ppcoords_$ppc,
      strokeColor: "#$color",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      map: map
    });
EOF;
  $ppc++;
}

foreach ($track_kat['conn'] as $c) {
  $prevPt = isset($pt) ? $pt : null;
  $pt = getPoint($c['pid']);
  $min_lat = min($min_lat, $pt['lat']);
  $min_lon = min($min_lon, $pt['lon']);
  $max_lat = max($max_lat, $pt['lat']);
  $max_lon = max($max_lon, $pt['lon']);
//  echo "<pre><b>".print_r($pt, true)."</b></pre>";
//  echo "<pre>".print_r($c, true)."</pre>";
  if ($i != 0) {
  switch ($c['type']) {
    case 'none':
    break;
    case 'line':
      
    $content .= "var ptcoords_$i = [];\n";
    $content .= "ptcoords_$i.push(new google.maps.LatLng(".$prevPt['lat'].", ".$prevPt['lon']."));\n";
    $content .= "ptcoords_$i.push(new google.maps.LatLng(".$pt['lat'].", ".$pt['lon']."));\n";
    $content .= <<<EOF
    var ptline_$i = new google.maps.Polyline({
      path: ptcoords_$i,
      strokeColor: "#0000ff",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      map: map
    });
EOF;

    break;
    case 'polyline':
    $content .= "var ptcoords_$i = [];\n";
    $content .= "ptcoords_$i.push(new google.maps.LatLng(".$prevPt['lat'].", ".$prevPt['lon']."));\n";
    $poly = getPoly($c['ptr']);
    foreach ($poly['points'] as $polypt) {
      $content .= "ptcoords_$i.push(new google.maps.LatLng(".$polypt['lat'].", ".$polypt['lon']."));\n";
    }
    $content .= "ptcoords_$i.push(new google.maps.LatLng(".$pt['lat'].", ".$pt['lon']."));\n";
    $content .= <<<EOF
    var ptline_$i = new google.maps.Polyline({
      path: ptcoords_$i,
      strokeColor: "#0000ff",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      map: map
    });
EOF;

    break;
    case 'arc1':
    case 'arc2':
    $cw = $c['type'] != 'arc1';
    $center = getPoint($c['ptr']);

//    $arcRadius =  0.5 * (
//      rad2deg(asin( distanceInMeters($pt, $center) /$EARTH_RADIUS_IN_METERS)) +
//      rad2deg(asin( distanceInMeters($prevPt, $center) /$EARTH_RADIUS_IN_METERS))
//    );

//    $arcData = insertMidArc($center, 0, M_PI, $cw, $arcRadius);
    $arcData = insertArcII($center, $prevPt, $pt, $cw);
//print_r($arcData);

    $content .= "var ptcoords_$i = [];\n";
    $content .= "ptcoords_$i.push(new google.maps.LatLng(".$prevPt['lat'].", ".$prevPt['lon']."));\n";
    foreach ($arcData as $arcPt) {
      $content .= "ptcoords_$i.push(new google.maps.LatLng(".$arcPt['lat'].", ".$arcPt['lon']."));\n";
    }
    $content .= "ptcoords_$i.push(new google.maps.LatLng(".$pt['lat'].", ".$pt['lon']."));\n";
    $content .= <<<EOF
    var ptline_$i = new google.maps.Polyline({
      path: ptcoords_$i,
      strokeColor: "#0000ff",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      map: map
    });
EOF;
//    print_r($arcData);

    break;
  }
  }
  $lat = $pt['lat']; $lon = $pt['lon']; $name = $pt['name'];
  $radius = ($c['radius'] != -1) ? $c['radius'] : $track_kat['default_radius'];
  $flags = ($c['flags'] != -1) ? $c['flags'] : $track_kat['default_flags'];
  $angle = ($c['angle'] != -1) ? $c['angle'] : $c['computed_angle'];
  $tp_enabled = (($flags & 1) == 1);
  $show_gate = ($flags > 1);
//  echo $tp_enabled. " ". $show_gate;
  if ($tp_enabled) {
    $content .= <<<EOF
    var circle_$i = new google.maps.Circle({
        strokeColor: '#0000ff',
        strokeOpacity: 0.8,
        strokeWeight: 2,
        fillOpacity: 0,
        map: map,
        center: new google.maps.LatLng($lat,$lon),
        radius: $radius,
      }); 

EOF;
  }
  if ($show_gate) {
    $c1 = getCoord_distance_bearing($lat, $lon, $angle%360, $radius);
    $c2 = getCoord_distance_bearing($lat, $lon, (180+$angle)%360, $radius);
    $c3 = getCoord_distance_bearing($lat, $lon, (270+$angle)%360, $radius*0.2);
    $content .= "var coords_$i = [];\n";
    $content .= "coords_$i.push(new google.maps.LatLng(".$c1[0].", ".$c1[1]."));\n";
    $content .= "coords_$i.push(new google.maps.LatLng(".$c2[0].", ".$c2[1]."));\n";
    $content .= "coords_$i.push(new google.maps.LatLng(".$c3[0].", ".$c3[1]."));\n";
    $content .= "coords_$i.push(new google.maps.LatLng(".$c1[0].", ".$c1[1]."));\n";
//      echo "$lat $lon <br/>";

    $content .= <<<EOF
    var polyline_$i = new google.maps.Polyline({
      path: coords_$i,
      strokeColor: "#0000ff",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      map: map
    });
EOF;
  }

/*
    $content .= <<<EOF
    var marker_$i = new google.maps.Marker({
        position: new google.maps.LatLng($lat,$lon),
        map: map,
        title:"$name",
    });
EOF;
*/

  $prevType = $c['type'];
  $i++;
}

//  echo $i. ": " . $name . "<br/>\n";

//echo "<pre>".print_r ($track, true). "</pre>";
/*
    $content .= <<<EOF
    var marker_$i = new google.maps.Marker({
        position: new google.maps.LatLng($lat,$lon),
        map: map,
        title:"$name",
    });
EOF;
*/

/*
    $color = substr($task->getElementsByTagName("color")->item(0)->childNodes->item(0)->wholeText, 2, 6);
    $coords = preg_split('/\s+/', $coords);

    $content .= "var coords_$i = [];\n";
    $geom_array = array();

    foreach ($coords as $c) {
      list($lon, $lat) = explode(",",$c);
      array_push($geom_array, array("lat" => $lat, "lon" => $lon));
      $content .= "coords_$i.push(new google.maps.LatLng($lat, $lon));\n";
//      echo "$lat $lon <br/>";
    }

    $content .= <<<EOF
    var polyline_$i = new google.maps.Polyline({
      path: coords_$i,
      strokeColor: "#$color",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      map: map
    });

EOF;
*/
//    echo " ".print_r($coords);

//  echo "<br/> <br/>\n";


$content .= "    var gpsCoords = [];";


foreach ($igc as $rec) {
  if ($rec['time'] < $start_time) {
    continue;
  }

  $content .= " gpsCoords.push(new google.maps.LatLng(".$rec['lat'].", ".$rec['lon']."));\n";

}


$content .= <<<EOF

  var bounds = new google.maps.LatLngBounds();
  bounds.extend(new google.maps.LatLng($min_lat, $min_lon));
  bounds.extend(new google.maps.LatLng($max_lat, $max_lon));
  map.fitBounds(bounds);

  // Construct the polygon
  // Note that we don't specify an array or arrays, but instead just
  // a simple array of LatLngs in the paths property
  var gps = new google.maps.Polyline({
    path: gpsCoords,
    strokeColor: "#ff0000",
    strokeOpacity: 0.8,
    strokeWeight: 2,
      map: map
  });


EOF;



// style="position:absolute; top:0; left:0; width:100%; height:100%;"
$content .= <<<EOF
  }
</script>
  <div id="map_canvas" style="width: 800px; height: 600px;"></div>
  <h1 style="position: absolute; left: 100px; top: 10px;">$posadka_nazev</h1>

<script type="text/javascript">initialize()</script>



EOF;

//  

require('template-empty.php');
//require('template.php');
?>