<?php
function airspace_color($type) {
   $array = array(
      'FIR' => "#000000",
      'CTA' => "#000000",
      'TMA' => "#000080",
      'MTMA' => "#000080",
      'CTR' => "#000080",
      'MCTR' => "#000080",
      'TRA' => "#ff0000",
      'TSA' => "#c4a000",
      'R' => "#ff0000",
      'D' => "#ff0000",
      'P' => "#ff0000",
      '' => "#000000",
   );

  if (!array_key_exists($type, $array)) {
    $type = '';
  }
  return $array[$type];
}

function styleToString($index) {
  $array = array(
   'Unknown',
   'Normal',
   'AirfieldGrass',
   'Outlanding',
   'GliderSite',
   'AirfieldSolid',
   'MtPass',
   'MtTop',
   'Sender',
   'Vor',
   'Ndb',
   'CoolTower',
   'Dam',
   'Tunnel',
   'Bridge',
   'PowerPlant',
   'Castle',
   'Intersection',
  );
  $index = (int)$index;
  if (!array_key_exists($index, $array)) {
    $index = 0;
  }
  return $array[$index];

}


function objectMinZoom($type) {
  $array = array(
      '' => 1,
      'FIR' => 1,
      'CTA' => 1,
      'TMA' => 1,
      'MTMA' => 1,
      'CTR' => 1,
      'MCTR' => 1,
      'TRA' => 1,
      'TSA' => 1,
      'R' => 1,
      'D' => 1,
      'P' => 1,
      'Unknown' => 1,
      'Normal' => 1,
      'AirfieldGrass' => 8,
      'Outlanding' => 8,
      'GliderSite' => 8,
      'AirfieldSolid' => 1,
      'MtPass' => 14,
      'MtTop' => 14,
      'Sender' => 14,
      'Vor' => 14,
      'Ndb' => 14,
      'CoolTower' => 14,
      'Dam' => 14,
      'Tunnel' => 14,
      'Bridge' => 14,
      'PowerPlant' => 14,
      'Castle' => 14,
      'Intersection' => 14,
      'EntryPoint' => 8,
  );
  if (!array_key_exists($type, $array)) {
    $index = 0;
  }
  return $array[$type];
}

function objectMaxZoom($type) {
  $array = array(
      '' => 16,
      'FIR' => 16,
      'CTA' => 16,
      'TMA' => 16,
      'MTMA' => 16,
      'CTR' => 16,
      'MCTR' => 16,
      'TRA' => 16,
      'TSA' => 16,
      'R' => 16,
      'D' => 16,
      'P' => 16,
      'Unknown' => 16,
      'Normal' => 16,
      'AirfieldGrass' => 16,
      'Outlanding' => 16,
      'GliderSite' => 16,
      'AirfieldSolid' => 16,
      'MtPass' => 16,
      'MtTop' => 16,
      'Sender' => 16,
      'Vor' => 16,
      'Ndb' => 16,
      'CoolTower' => 16,
      'Dam' => 16,
      'Tunnel' => 16,
      'Bridge' => 16,
      'PowerPlant' => 16,
      'Castle' => 16,
      'Intersection' => 16,
      'EntryPoint' => 16,
  );
  if (!array_key_exists($type, $array)) {
    $index = 0;
  }
  return $array[$type];
}


?>