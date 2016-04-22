<?php
session_start();
require_once("../Server_v02/toInc.php");
?>
<!DOCTYPE html>
<!--[if lt IE 7]>
<html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>
<html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>
<html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!-->
<html class="no-js"> <!--<![endif]-->
<head>

  <!-- Meta-Information -->
  <title>{{page.title}} | Mergefy</title>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="description" content="ACME Inc.">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" href="css/image/favicon.ico">
  <link href="css/image/favicon.ico" rel="icon">
  <!-- Vendor: Bootstrap Stylesheets http://getbootstrap.com -->
  <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
  <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
  <link href="http://maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">

  <!-- Our Website CSS Styles -->
  <link rel="stylesheet" href="css/main.css">
  <link rel="stylesheet" href="css/add.css">
  <link rel="stylesheet" href="css/datepicker.css">


</head>
<body ng-app="tutorialWebApp">
  <?php

  if((isset($_SESSION['user_id'])) && ($_SESSION['login'] == "login_Ok")) {
    ?>
    <script>
    window.localStorage['id'] = "<?php echo $_SESSION['user_id']; ?>";
    window.localStorage['error'] = false;
    </script>
    <?php
  } else {
    session_destroy();
    ?>
    <script>
    console.log("errrrrorrrre")
    window.localStorage.removeItem("id");
    // if ((window.localStorage['error'] == "false") || (typeof window.localStorage['error'] == "undefined")) {
    //   window.localStorage['error'] = true;
    //   window.location.reload(true);
    // }

    </script>
    <?php
  }
  ?>
  <!--[if lt IE 7]>
  <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade
  your browser</a> to improve your experience.</p>
  <![endif]-->

  <nav class="navbar transparent navbar-fixed-top" role="navigation">
    <div class="" style="padding:0 15px;"><!--container-->
      <!-- Brand and toggle get grouped for better mobile display -->
      <div class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar" style="background-color:#388DD1;"></span>
          <span class="icon-bar" style="background-color:#388DD1;"></span>
          <span class="icon-bar" style="background-color:#388DD1;"></span>
        </button>
        <a class="navbar-brand" style="padding: 5px 5px;" href="#"><img src="css/img/logo0.png" style="height: 100%; width:auto; "></a>
      </div>

      <!-- Collect the nav links, forms, and other content for toggling -->
      <div class="collapse navbar-collapse navbar-right" id="navbar-collapse" style="background-color:#ffffff;">

        <ul class="nav navbar-nav">
          <li><a href="#/">Home</a></li>
          <li><a href="#/docs">Documents</a></li>
          <li><a href="#/events">Events</a></li>
          <li><a href="#/addevent">+Event</a></li>
          <li><a href="#/groups">Groups</a></li>
          <li><a href="#/profile">Profile</a></li>
          <li><a href="./index.php?act=logout&userIdentifier=<?php echo $_SESSION['user_id']; ?>&angularShits"><span class="glyphicon glyphicon-lock"></span></a></li>
        </ul>
      </div><!-- /.navbar-collapse -->
    </div><!-- /.container-fluid -->
  </nav>

  <div ng-view class="scene"></div>


  <!-- Vendor: Javascripts -->
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
  <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
   <script src="js/bootstrap-datepicker.js"></script>

  <!-- Vendor: Angular, followed by our custom Javascripts -->
  <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.18/angular.min.js"></script>
  <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.18/angular-route.min.js"></script>
  <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
  <script src="js/ng-map.min.js"></script>
  <script src="js/angular-base64-upload/src/angular-base64-upload.js"></script>
  <!-- Our Website Javascripts -->
  <!-- <script src="js/dist/app.min.js"></script> -->
  <script src="js/main.js"></script>
  <script src="js/ctrls/livedoc.js"></script>
  <script src="js/ctrls/docs.js"></script>
  <script src="js/ctrls/doc.js"></script>
  <script src="js/ctrls/addgroup.js"></script>
  <script src="js/ctrls/event.js"></script>
  <script src="js/ctrls/events.js"></script>
  <script src="js/ctrls/getevent.js"></script>
  <script src="js/ctrls/group.js"></script>
  <script src="js/ctrls/groups.js"></script>
  <script src="js/ctrls/home.js"></script>
  <script src="js/ctrls/profile.js"></script>
  <script src="js/services.js"></script>
</body>
</html>
