<?php
include_once "../Server/database.php";
include_once "../Server/server.php";

$test = true;
$model = 'event';
$action = "userNearEvents";
$arr = array('user_id' => 1, 'distance' => 100);
$data = json_encode($arr);

include_once "../Server/handler.php";
