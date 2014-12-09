<?php



require('admin-init.php');

$list_btn = _("overview");
$save_btn = _("upload");

$delete_btn = _("delete");
$delete_all_btn = _("delete all");
$delete_confirm_str = _("Are you sure?");

$uploadDragAndDropStr = _('Drag and Drop Files');
$uploadAbortStr = _('Abort');
$uploadCancelStr = _('Cancel');
$uploadDoneStr = _('Done');
$uploadMultiDragErrorStr = _('Multi Drag Error');
$uploadExtErrorStr = _('Ext Error');
$uploadSizeErrorStr = _('Size Error');
$uploadErrorStr = _('Error: ');



if (!isset($_REQUEST['round'])) {
//print_r($_REQUEST);
  $content .= _("Error: round is not set!");
  require('template.php');
  exit();
}

if (!isset($_REQUEST['year'])) {
  $content .= _("Error: year not found!");
  require('template.php');
  exit();
}


$round = (int)$_REQUEST['round'];
$year = (int)$_REQUEST['year'];
if (!isset($data[$year][$round])) {
  $content .= _("Error: round not found!");
  require('template.php');
  exit();
}
$item = $data[$year][$round];
$title =  $item['title'];

$dirname = sprintf("%s/%d-%d-%s", $config['datadir'], $year, $round, $item['short']);

$content .= $dirname ."/</br><br/>";

if (!file_exists($dirname) || !is_dir($dirname)) {
  mkdir($dirname);
}

if (isset($_REQUEST['delete'])) {
  $filename = $_REQUEST['filename'];
  unlink("$dirname/$filename");
}

if (isset($_REQUEST['delete_all'])) {
  rrmdir($dirname);
  mkdir($dirname);
}


$count = 0;
$files_array = array();
if ($handle = opendir($dirname)) {

    while (false !== ($entry = readdir($handle))) {
        if ($entry == '.') {
          continue;
        }
        if ($entry == '..') {
          continue;
        }
        array_push($files_array, $entry);
        $count++;
    }

    closedir($handle);
}
sort($files_array);

foreach ($files_array as $entry) {
        $content .= "$entry <a href=\"admin-files.php?year=$year&amp;round=$round&amp;delete&amp;filename=".urlencode($entry)."\" onclick=\"return confirm('$delete_confirm_str')\">$delete_btn</a> <br/>\n";
}

$content .=" <br/> "._("Count of files: "). "<span id=\"count\">$count</span>";


$content .= <<<EOF

<div id="newfiles" class="newfiles"></div>

<br/> <br/>

<div id="fileuploader">Upload</div>



<br/>

  <a href="admin.php">$list_btn</a>
  <a href="admin-files.php?delete_all&amp;year=$year&amp;round=$round" onclick="return confirm('$delete_confirm_str')">$delete_all_btn</a> 



<script src="js/jquery.min.js"></script>
<script src="js/jquery.uploadfile.min.js"></script>

<script>
$(document).ready(function()
{
    $("#fileuploader").uploadFile({
      url:"admin-files-ajax.php",
      fileName:"files",
      formData: {"year": $year,"round": $round},
      afterUploadAll:function() {
         location.replace("./admin-files.php?year=$year&round=$round");
      },
      dragDropStr: "$uploadDragAndDropStr",
      abortStr:"$uploadAbortStr",
      cancelStr:"$uploadCancelStr",
      doneStr:"$uploadDoneStr",
      multiDragErrorStr: "$uploadMultiDragErrorStr",
      extErrorStr:"$uploadExtErrorStr",
      sizeErrorStr:"$uploadSizeErrorStr",
      uploadErrorStr:"$uploadErrorStr"

    });
});
</script>




EOF;

if (isset($footer_buttons)) {
  $content .= $footer_buttons;
}


require('template.php');

?>