<?php

$RAD_TO_DEG = 180/M_PI;
$DEG_TO_RAD = 1/$RAD_TO_DEG;
$NM_TO_M = 1852;
$M_TO_NM = 1 / $NM_TO_M;
$EARTH_RADIUS_IN_METERS = 6372797.560856;
$ARC_GRANULARITY = 0.1; //M_PI/10;


function distToAngle($distInMeters) {
  global $EARTH_RADIUS_IN_METERS, $RAD_TO_DEG;
  $angleRad = asin($distInMeters/$EARTH_RADIUS_IN_METERS);
  $angleDeg = $angleRad * $RAD_TO_DEG;
  return $angleDeg;
}
/*
function distToAngle($distInNauticalMiles) {
  global $NM_TO_M, $EARTH_RADIUS_IN_METERS, $RAD_TO_DEG;
  $dist = $NM_TO_M * $distInNauticalMiles;
  $angleRad = asin($dist/$EARTH_RADIUS_IN_METERS);
  $angleDeg = $angleRad * $RAD_TO_DEG;
  return $angleDeg;
}
*/

function computeArcPoint($clat, $clon, $r, $partAngle) {
  global $DEG_TO_RAD;
  $lon = sin($partAngle) * $r;
  $lat = cos($partAngle) * $r;
  $rlat = $clat + $lat;
  $rlon = $clon + $lon / cos ($rlat*$DEG_TO_RAD);
  return array('lat' => $rlat, 'lon' => $rlon);
}


function insertCircle($pos, $radius) {
  global $ARC_GRANULARITY;

  $r = distToAngle($radius);

  $clat = $pos['lat'];
  $clon = $pos['lon'];

  $result = array();
  for ($k = 0; $k < 2*M_PI; $k += $ARC_GRANULARITY) {
    array_push($result, computeArcPoint($clat, $clon, $r, $k));
  }

  return $result;
}

function arcInRadians($from, $to) {
  global $DEG_TO_RAD;
  $latitudeArc  = ($from['lat'] - $to['lat']) * $DEG_TO_RAD;
  $longitudeArc = ($from['lon'] - $to['lon']) * $DEG_TO_RAD;
  $latitudeH = sin($latitudeArc * 0.5);
  $latitudeH *= $latitudeH;
  $lontitudeH = sin($longitudeArc * 0.5);
  $lontitudeH *= $lontitudeH;
  $tmp = cos($from['lat']*$DEG_TO_RAD) * cos($to['lat']*$DEG_TO_RAD);
  return 2.0 * asin(sqrt($latitudeH + $tmp*$lontitudeH));

}

function distanceInMeters($from, $to) {
  global $EARTH_RADIUS_IN_METERS;
  return $EARTH_RADIUS_IN_METERS*arcInRadians($from, $to);
}

/**
  * @param $center - geographical point where is the center of the arc e.g array('lat' => 49.1, 'lon' => 16.2)
  * @param $start - geographical point where to start arc
  * @param $end - geographicl point where to end arc
  * @param $cw - clock wise 
  */


function insertArcII($center, $start, $end, $cw) {
//  global $M_TO_NM;
//  $r = 0.5 * ( distToAngle(distanceInMeters($start, $center) * $M_TO_NM) + distToAngle(distanceInMeters($end, $center) * $M_TO_NM) );
//  $r = 0.5 * ( distToAngle(distanceInMeters($start, $center)) + distToAngle(distanceInMeters($end, $center)) );
//  $r = 0.5 * ( distToAngle(distanceInMeters($start, $center)) + distToAngle(distanceInMeters($end, $center)) );

  $middle = array( 'lat' => 0.5* ($start['lat']+$end['lat']), 'lon' => 0.5* ($start['lon'] + $end['lon']));
  $distance = distanceInMeters($middle, $center);

  $angle = getBearingTo($start['lat'], $start['lon'], $end['lat'], $end['lon']);

  $centerA = getCoord_distance_bearing($middle['lat'], $middle['lon'], $angle+90, $distance);
  $centerB = getCoord_distance_bearing($middle['lat'], $middle['lon'], $angle+270, $distance);

  $d1 = get_distance($centerA[0], $centerA[1], $center['lat'], $center['lon']);
  $d2 = get_distance($centerB[0], $centerB[1], $center['lat'], $center['lon']);
  $distance = get_distance($start['lat'], $start['lon'], $centerA[0], $centerA[1]);

    if ($d1 < $d2) {
        $center['lat'] = $centerA[0];
        $center['lon'] = $centerA[1];
    } else {
        $center['lat'] = $centerB[0];
        $center['lon'] = $centerB[1];
    }

  $a1 = angleRad($center, $start);
  $a2 = angleRad($center, $end);

  $result = array();
  array_push($result, $start);

  $result = array_merge($result, insertMidArc($center, $a1, $a2, $cw, distToAngle($distance)));
  
  array_push($result, $end);

  return $result;
}


function insertMidArc($center, $from, $to, $cw, $r) {
  global $ARC_GRANULARITY;
  $result = array();
  if ($cw) {
    if ($to < $from) {
      $to += 2*M_PI;
    }
    for ($angle = $from + $ARC_GRANULARITY; $angle < $to; $angle += $ARC_GRANULARITY) {
       array_push($result, computeArcPoint($center['lat'], $center['lon'], $r, $angle));
    }
  } else {
    if ($from < $to) {
      $from += 2*M_PI;
    }
//echo rad2deg($from). " ". rad2deg($to). "<br/>";
    for ($angle = $from - $ARC_GRANULARITY; $angle > $to; $angle -= $ARC_GRANULARITY) {
//echo rad2deg($angle)."<br/>";
       array_push($result, computeArcPoint($center['lat'], $center['lon'], $r, $angle));
    }
  }
  return $result;
}

function angleRad($center, $poi) {
  global $DEG_TO_RAD;
  $lat = $poi['lat'] - $center['lat'];
  $lon = ($poi['lon'] - $center['lon']) * cos ($poi['lat']*$DEG_TO_RAD);
  return atan2($lon, $lat);
}

function deg2num($lat, $lon, $zoom) {
    $rad = deg2rad(fmod($lat, 90));
    $maxTileNo = pow(2, $zoom) - 1;
    $n = $maxTileNo + 1;
    $xtile = ((fmod($lon,180.0)) + 180.0) / 360.0 * $n;
    $ytile = (1.0 - log(tan($rad) + (1.0 / cos($rad))) / M_PI) / 2.0 * $n;
    return array($xtile, $ytile);
}

function getBearingTo($lat, $lon, $tlat, $tlon) {
    $lat1 = $lat * (M_PI/180.0);
    $lat2 = $tlat * (M_PI/180.0);

    $dlon = ($tlon - $lon) * (M_PI/180.0);
    $y = sin($dlon) * cos($lat2);
    $x = cos($lat1) * sin($lat2) - sin($lat1) * cos($lat2) * cos($dlon);
    return fmod((360 + (atan2($y, $x)) * (180.0/M_PI)), 360);
}



function pointInPolygon($polygon, $point) {
    $nvert = count($polygon);
    $c = false;

    for($i = 0, $j = $nvert - 1; $i < $nvert; $j = $i++) {
        $aLat = $polygon[$i]['lat'];
        $aLon = $polygon[$i]['lon'];
        $bLat = $polygon[$j]['lat'];
        $bLon = $polygon[$j]['lon'];

        if (
                ( ( ($aLon) >= $point['lon'] ) != ($bLon >= $point['lon']) ) &&
                ($point['lat'] <= ($bLat - $aLat) * ($point['lon'] - $aLon) / ($bLon - $aLon) + $aLat)
                )
            $c = !$c;

    }

    return $c;
}


$earth_radius = 6371000;



function getCoord_distance_bearing($lat, $lon, $bear, $dist) {
  global $earth_radius ;
  $lat1 = deg2rad($lat);
  $lon1 = deg2rad($lon);
  $brng = deg2rad($bear);
  $R = $earth_radius ; //polomer zeme
  $d = $dist/$R;  // uhlova vzdalenost

  $dlat = $d * cos ( $brng );
  if (abs($dlat) < 1E-10) {
    $dlat = 0;
  }

  $lat2 = $lat1 + $dlat;
  $dphi = log(tan($lat2/2+M_PI_4)/tan($lat1/2+M_PI_4));
  $q = (($dphi != 0) && is_finite($dlat/$dphi) ) ? $dlat/$dphi : cos($lat1);  // E-W line gives dPhi=0
  $dlon = $d*sin($brng)/$q;

  if (abs($lat2) > M_PI_2) {
    $lat2 = ($lat2 > 0) ? M_PI-$lat2 : -M_PI-$lat2;
  }
  $lon2 = fmod($lon1+$dlon+3*M_PI,2*M_PI) - M_PI;

  return array(rad2deg($lat2),rad2deg($lon2));
//  return array("lat" => rad2deg($lat2), "lon" => rad2deg($lon2));
}


 
# Spherical Law of Cosines

function get_distance($lat1, $lon1, $lat2, $lon2) {
  return get_distance_rad(deg2rad($lat1), deg2rad($lon1), deg2rad($lat2), deg2rad($lon2));
}

function get_distance_rad($lat1, $lon1, $lat2, $lon2) {
  global $earth_radius;

        $tmp = sin($lat1) * sin($lat2) + cos($lat1) * cos($lat2) * cos($lon2 - $lon1);
        $distance = $earth_radius  *  acos($tmp);

        return $distance;
}



function line_intersection($Ax, $Ay, $Bx, $By, $Cx, $Cy, $Dx, $Dy, &$X = 0, &$Y = 0) {


  //  Fail if either line is undefined.
  if ($Ax==$Bx && $Ay==$By || $Cx==$Dx && $Cy==$Dy) return false;

  //  Fail if the segments share an end-point.
  if ($Ax==$Cx && $Ay==$Cy || $Bx==$Cx && $By==$Cy
  ||  $Ax==$Dx && $Ay==$Dy || $Bx==$Dx && $By==$Dy) {
    return false; }

  //  (1) Translate the system so that point A is on the origin.
  $Bx-=$Ax; $By-=$Ay;
  $Cx-=$Ax; $Cy-=$Ay;
  $Dx-=$Ax; $Dy-=$Ay;

  //  Discover the length of segment A-B.
  $distAB=sqrt($Bx*$Bx+$By*$By);

  //  (2) Rotate the system so that point B is on the positive X axis.
  $theCos=$Bx/$distAB;
  $theSin=$By/$distAB;
  $newX=$Cx*$theCos+$Cy*$theSin;
  $Cy  =$Cy*$theCos-$Cx*$theSin; $Cx=$newX;
  $newX=$Dx*$theCos+$Dy*$theSin;
  $Dy  =$Dy*$theCos-$Dx*$theSin; $Dx=$newX;


  //  Fail if segment C-D doesn't cross line A-B.
  if ($Cy<0. && $Dy<0. || $Cy>=0. && $Dy>=0.) return false;

  //  (3) Discover the position of the intersection point along line A-B.
  $ABpos=$Dx+($Cx-$Dx)*$Dy/($Dy-$Cy);

  //  Fail if segment C-D crosses line A-B outside of segment A-B.
  if ($ABpos<0. || $ABpos>$distAB) return false;

  //  (4) Apply the discovered position to line A-B in the original coordinate system.
  $X=$Ax+$ABpos*$theCos;
  $Y=$Ay+$ABpos*$theSin;

  //  Success.
  return true;
}

?>