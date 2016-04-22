<?php
include_once "../Server/Objects/user.php";
include_once "../Server/database.php";
include_once "../Server/Functions/jsonUtilities.php";

$data = "{
	\"model\": \"user\",
	\"action\": \"login\",
	\"param\": {
		\"mail\": \"mail@mail.com\",
		\"password\": \"HASHEDPASS\",
		\"lat\": \"44.12345\",
		\"lng\": \"11.98765\"
	}
}";

$usr = new User();

$usr->login($data);
