<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
	echo "ciao\n<br>\n";
	$data = json_decode(file_get_contents("php://input"));
  echo json_encode($data);
?>
