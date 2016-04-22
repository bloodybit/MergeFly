<?php
/**
 * Created by IntelliJ IDEA.
 * User: riccardosibani
 * Date: 13/03/16
 * Time: 10:44
 */

$test = true;
$input = "[
  {
    \"action\" : \"login\",
    \"data\" : {
      \"userpassword\": \"HASHEDPASS\",
      \"usermail\": \"mail@mail.com\",
      \"lat\": 44.12345,
      \"lng\": 11.98765
    }
  },
  {
    \"action\" : \"getPlace\",
    \"data\": {
      \"idI\": 1
    }
  },
  {
    \"action\":\"getEvent\",
    \"data\":{
        \"eventid\":2,
        \"userid\":1
    }
  }
]";

include_once "../Server_v02/handler.php";
