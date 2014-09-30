<?php
function csv_to_array($csv, $delimiter = ",", $enclosure = "\"", $escape = "\\", $terminator = "\n") {
    $r = array();
    $rows = explode($terminator,trim($csv));
    foreach ($rows as $row) {
        if (trim($row)) {
            $values = str_getcsv($row,$delimiter,$enclosure,$escape);
            if (!$values) $values = array_fill(0,$nc,null);
//            $r[] = array_combine($names,$values);
            array_push($r, $values);
        }
    }
    return $r;
} 

?>