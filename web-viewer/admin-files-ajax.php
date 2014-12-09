<?php

require('config.php');


$d = array(
  'files' => $_FILES,
  'request' => $_REQUEST
);
file_put_contents("./files/tmp.json", json_encode(print_r($d, true)));

function formatError($error) {

  header('content-type: application/json');
  echo json_encode(
    array(
      'jquery-upload-file-error' => $error
    )
  );

  exit();
}

if (!isset($_SESSION['auth'])) {
  formatError('authentication failed');
}



if (!isset($_REQUEST['year']) || !isset($_REQUEST['round'])) {
  formatError('year/round not set');
}

$data = (file_exists($config['indexfile'])) ? json_decode(file_get_contents($config['indexfile']), true) : array();

$year = (int)$_REQUEST['year'];
$round = (int)$_REQUEST['round'];

if (!isset($data[$year][$round])) {
  formatError('item not set');
}


if (!isset($_FILES['files']['name'][0])) {
  formatError('no file selected');
}

$item = $data[$year][$round];


$upload_result = array();

  if (!is_array($_FILES['files']['error'])) {
    $error = $_FILES['files']['error'];
    $tmp_name = $_FILES['files']['tmp_name'];
    $filename = sprintf("%s/%d-%d-%s/%s", $config['datadir'], $_REQUEST['year'], $_REQUEST['round'], $item['short'], $_FILES['files']['name']);

    if ($error == UPLOAD_ERR_OK) {
      move_uploaded_file($tmp_name, $filename);
    } else {
      formatError('upload error: '.$error);
    }
  } else {
    formatError('upload error: is_array');
  }



header('content-type: application/json');
echo json_encode(array(
  "files" => $upload_result,
));

?>