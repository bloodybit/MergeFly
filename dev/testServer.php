<?php

include_once "../Server/database.php";
include_once "../Server/server.php";

$test = true;
$model = 'user';
$action = "login";
$data = "{
	\"mail\": \"mail@mail.com\",
	\"password\": \"HASHEDPASS\",
    \"lat\": 44.12345,
    \"lng\": 11.98765

}";

include_once "../Server/handler.php";
