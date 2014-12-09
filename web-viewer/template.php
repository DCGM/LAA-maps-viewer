<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html>
<head>
  <title> LAA </title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <link rel="stylesheet" href="./style.css" type="text/css" />
  <link rel="stylesheet" href="./uploadfile.css" type="text/css" />
</head>
<body>
    <div id="container">


<?php 
if (isset($title)) { 
  echo "<h1>$title</h1>\n\n";
}
echo $content; 
?>

    </div>

</body>
</html>