<?php

$config = array(
  'user' => 'laa',
  'pass' => 'laa',
  'indexfile' => './files/index.json',
  'datadir' => './files',
);

date_default_timezone_set('Europe/Prague');
setlocale(LC_ALL, 'cs_CZ.UTF-8');
setlocale(LC_NUMERIC, 'en_US.UTF-8');
bindtextdomain('messages', './locale');
textdomain('messages');

session_start();


?>