<?php

require('config.php');
require('csv.php');
require('igc.php');
require('geo.php');

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

////////////////////////////////////////////////////////////////////////////////////

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

// 600px
$content =<<<EOF
  <div id="map" style="top:0; left:0; width:100%; height: 600px; "></div>
  <h1 style="position: absolute; left: 100px; top: 10px;">$posadka_nazev</h1>
  <canvas id="alt_canvas" width="2000" height="300" style="width: 100%; height: 300px;">
    <script src="./leaflet.js"></script>

    <script>
    var icao =  L.tileLayer('http://193.0.231.23/tiles/cz/icao/{z}/{x}/{y}.png', {
      'tms': true,
      'maxZoom': 11,
    });
    var cza = L.tileLayer('http://pcmlich.fit.vutbr.cz/map/tiles/{z}/{x}/{y}.png');


    var osm = L.tileLayer('http://a.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
      '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
      'Imagery © <a href="http://mapbox.com">Mapbox</a>',
    });

    var google = L.tileLayer('http://mts0.google.com/vt/lyrs=m@248407269&hl=x-local&x={x}&y={y}&z={z}&s=Galileo', {
      attribution: 'Map data &copy; Google 2012'
    });

    var satelite = L.tileLayer('http://khms1.google.com/kh/v=144&src=app&x={x}&y={y}&z={z}&s=', {
      attribution: 'Map data &copy; Google 2012'
    });

    var prosoar = L.tileLayer('http://prosoar.de/airspace/{z}/{x}/{y}.png',{
      attribution: 'prosoar.de'
    });

    var baseMaps = {
      "Openstreetmap": osm, 
      "Google Roadmap" : google,
      "Google Satelite" : satelite,
//      "ICAO": icao,
//      "Aviation": cza,
    };
    var overlayMaps = {
      "Airspace" : prosoar
    }



    var map = L.map('map', {
        zoomAnimation: false,
        fadeAnimation: false,
//            layers: [ osm, google, satelite, icao, cza ],
            layers: [ osm, prosoar ],
        } ).setView([49.8043055, 15.4768055], 8);

        L.control.layers(baseMaps, overlayMaps).addTo(map);


EOF;


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
      $content .= "ppcoords_$ppc.push([".$polypt['lat'].", ".$polypt['lon']."]);\n";
  }
  $content .= <<<EOF
  var pt_line_$ppc = L.polyline(ppcoords_$ppc, { color: '#$color', weight: 2, opacity: 0.8}).addTo(map);
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
    $content .= "ptcoords_$i.push([".$prevPt['lat'].", ".$prevPt['lon']."]);\n";
    $content .= "ptcoords_$i.push([".$pt['lat'].", ".$pt['lon']."]);\n";
    $content .= <<<EOF
    var ptline_$i = L.polyline(ptcoords_$i, { color: '#0000ff', weight: 2, opacity: 0.8}).addTo(map);

EOF;

    break;
    case 'polyline':

    $content .= "var ptcoords_$i = [];\n";
    $content .= "ptcoords_$i.push([".$prevPt['lat'].", ".$prevPt['lon']."]);\n";
    $poly = getPoly($c['ptr']);
    foreach ($poly['points'] as $polypt) {
      $content .= "ptcoords_$i.push([".$polypt['lat'].", ".$polypt['lon']."]);\n";
    }
    $content .= "ptcoords_$i.push([".$pt['lat'].", ".$pt['lon']."]);\n";
    $content .= <<<EOF
    var ptline_$i = L.polyline(ptcoords_$i, { color: '#0000ff', weight: 2, opacity: 0.8}).addTo(map);
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
    $content .= "ptcoords_$i.push([".$prevPt['lat'].", ".$prevPt['lon']."]);\n";
    foreach ($arcData as $arcPt) {
      $content .= "ptcoords_$i.push([".$arcPt['lat'].", ".$arcPt['lon']."]);\n";
    }
    $content .= "ptcoords_$i.push([".$pt['lat'].", ".$pt['lon']."]);\n";
    $content .= <<<EOF
    var ptline_$i = L.polyline(ptcoords_$i, { color: '#0000ff', weight: 2, opacity: 0.8}).addTo(map);
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
    var circle_$i = L.circle([$lat,$lon], $radius, { color: '#0000ff', weight: 2, opacity: 0.8, fill: false}).addTo(map);

EOF;

  }
  if ($show_gate) {
    $c1 = getCoord_distance_bearing($lat, $lon, $angle%360, $radius);
    $c2 = getCoord_distance_bearing($lat, $lon, (180+$angle)%360, $radius);
    $c3 = getCoord_distance_bearing($lat, $lon, (270+$angle)%360, $radius*0.2);


    $content .= "var coords_$i = [];\n";
    $content .= "coords_$i.push([".$c1[0].", ".$c1[1]."]);\n";
    $content .= "coords_$i.push([".$c2[0].", ".$c2[1]."]);\n";
    $content .= "coords_$i.push([".$c3[0].", ".$c3[1]."]);\n";
    $content .= "coords_$i.push([".$c1[0].", ".$c1[1]."]);\n";

    $content .= <<<EOF
  var polyline_$i = L.polyline(coords_$i, { color: '#0000ff', weight: 2, opacity: 0.8}).addTo(map);
EOF;

  }

  $prevType = $c['type'];
  $i++;
}

  $content .= "var gpsCoords = [];\n";
  $content .= "var alt_data = [];\n";
  foreach ($igc as $rec) {
      if ($rec['time'] < $start_time) {
          continue;
      }

      $content .= "gpsCoords.push([".$rec['lat'].", ".$rec['lon']."]);\n";
      $content .= "alt_data.push([".$rec['time'].", ".(int)$rec['alt_gps'] ."]);\n";
  }


  $content .= <<<EOF
  var gps = L.polyline(gpsCoords, { color: '#ff0000', weight: 2, opacity: 0.8}).addTo(map);

var bounds = [[$min_lat, $min_lon], [$max_lat, $max_lon]];
map.fitBounds(bounds);


/// draw elevation profile of flight

var c = document.getElementById("alt_canvas");
var ctx = c.getContext("2d");
ctx.moveTo(0,0);

var min_alt = alt_data[0][1];
var max_alt = alt_data[0][1];
for (var i = 1; i < alt_data.length; i++) {
  var alt = alt_data[i][1];
  min_alt = Math.min(min_alt, alt);
  max_alt = Math.max(max_alt, alt);
}

function between(value, in_min, in_max, out_min, out_max) {
  return ((value-in_min)/(in_max-in_min)*(out_max-out_min))+out_min
}

var alt = alt_data[0][1];
var y = between(alt, min_alt, max_alt, 0, c.height);
ctx.moveTo(0, c.height-y);

for (var i = 1; i < alt_data.length; i++) {
  alt = alt_data[i][1];
  var y = between(alt, min_alt, max_alt, 0, c.height);
  var x = between(i, 0, alt_data.length, 0, c.width);
  ctx.lineTo(x, c.height-y);
}
ctx.stroke();
</script>

EOF;


require('template-empty.php');
//require('template.php');
?>