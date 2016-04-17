<?php
/**
* Created by IntelliJ IDEA.
* User: riccardosibani
* Date: 13/03/16
* Time: 10:25
*/
 
session_start();
 
if(isset($_SERVER['HTTP_ORIGIN'])){
  header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
  header("Access-Control-Allow-Credentials: true");
  header("Access-Control-Max-Age: 86400"); //cache for 1 day
}
 
//Access-Control Headers are received during OPTIONS requests
if($_SERVER['REQUEST_METHOD'] == 'OPTIONS'){
 
  if(isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD'])){
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
  }
  if(isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'])){
    header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");
  }
  exit(0);
}
 
include_once "database.php";
include_once "Functions/jsonUtilities.php";
include_once "server.php";
 
if(isset($test) && $test){
  //prepare the parameters in advance
  echo "--- DEV MODE ---- <br><br><br><br>";
  $operations = $input;
} else {
  $operations = file_get_contents("php://input");
}
 
if(((isset($operations) || (!empty($operations)) || (!is_null($operations)))) && ((isset($_SESSION['user_id'])) && ($_SESSION['login'] == "login_Ok"))){
 
  $operations = json_decode($operations);
  $results = array();
  //Analyze every query from frontend
  foreach($operations as $operation){
    $execute = new Server();
    $result = $execute->execute($operation);
    $result = array(
      "action" => $operation->action,
      "data" => $result
    );
    array_push($results, $result);
  }
 
  echo json_encode($results);
}