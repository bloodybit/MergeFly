<?php

if((!isset($_SESSION['user_id'])) && ($_SESSION['login'] != "login_Ok") && (!is_int($_SESSION['user_id']))){
  ?>
  <head>

    <!-- Meta-Information -->
    <title>Login | Mergefy</title>
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

  </head>
  <nav class="navbar transparent navbar-fixed-top" role="navigation">
    <div class="" style="padding:0 15px;"><!--container-->
      <!-- Brand and toggle get grouped for better mobile display -->
      <div class="navbar-header">
        <a class="navbar-brand" style="padding: 5px 5px;" href="#"><img src="css/img/logo0.png" style="height: 100%; width:auto; "></a>

      </div>
      <form method="post" action="index.php?act=login" class="navbar-form navbar-right" role="search">

        <div class="form-group">
          <h4>Login:</h4>
        </div>
        <div class="form-group">
          <input name="emailL" class="form-control" name="username" type="text" id="email" placeholder="your@mail.com" required="" autofocus="">

        </div>
        <div class="form-group">
          <input name="passwordL" type="password" class="form-control" placeholder="Password" id="password" required="">

        </div>
          <input type="submit" class="btn btn-secondary" name="submitLog" value="Login">
      </form>
    </div>
    </div><!-- /.container-fluid -->
  </nav>
  <div class="container homepage" style="overflow:scroll;">
    <div class="col-md-12">
      <div class="col-md-3"></div>

      <div class="col-md-6">
        <div style="background-color:#ffffff; padding:20px; margin-top:10%">
          <form method="post" class="form" action="index.php?act=register">
            <div class="form-group">
              <label for="name">Name:</label>
              <input name="name" type="text" class="form-control" id="text" placeholder="es: John">
            </div>
            <div class="form-group">
              <label for="lastname">Lastname:</label>
              <input name="lastname" class="form-control" type="text" placeholder="es: Doe">
            </div>
            <div class="form-group">
              <label for="born">Date of Birth:</label>
              <input name="born" class="form-control" type="date" placeholder="Insert title...">
            </div>
            <div class="form-group">
              <label for="type">Type of Subscription:</label>
              <select name="type">
                <option value="49">Basic</option>
                <option value="1">Premium</option>
              </select>
            </div>
            <div class="form-group">
              <label for="email">Mail:</label>
              <input name="email" class="form-control" type="email" id="email" placeholder="your@mail.com">
            </div>
            <div class="form-group">
              <label for="password">Password:</label>
              <input name="password" class="form-control" min="8" type="password" id="password">
            </div>
            <div class="form-group">
              <label for="repeatPassword">Repeat:</label>
              <input name="repeatPassword" class="form-control" type="password" id="repeatPassword">
            </div>
            <input type="submit" class="btn btn-secondary btn-block" name="submitReg" value="Registration">
          </form>
        </div>
      </div>
      <div class="col-md-3"></div>
    </div>
  </div>
  <?php
  if ((isset($_REQUEST['act'])) && ($_REQUEST['act'] == "login") && (isset($_POST['submitLog']))) {
    if(isset($_POST['emailL']) && isset($_POST['passwordL'])){
      include_once '../Server_v02/database.php';
      $email = htmlspecialchars($_POST['emailL']);
      $password = htmlspecialchars($_POST['passwordL']);
      $db = new Database();
      $db->callProcedure('login', array($email, md5($password), 1, 1));
      if(!empty($db->getErrors())) {
        print_r($db->getErrors());
        die("<br>Username o password non corretti!<br>");
      } else {
        $result = $db->getResult();
        if(count($result)==1 && $result[0]!='m'){
          //Login has a good end
          $_SESSION['user_id'] = (int) $result[0]['id'];
          $_SESSION['login'] = "login_Ok";
        }
        ?>
        <script type="text/javascript">
        window.location="<?php echo $_SERVER['PHP_SELF']; ?>";
        </script>
        <?php
      }
    }
  } elseif ((isset($_REQUEST['act'])) && ($_REQUEST['act'] == "register") && (isset($_POST['submitReg']))) {
    if(isset($_POST['name']) && isset($_POST['lastname']) && isset($_POST['born']) && isset($_POST['email']) && isset($_POST['password']) && isset($_POST['repeatPassword'])){
      include_once '../Server_v02/database.php';
      $name = htmlspecialchars($_POST['name']);
      $lastname = htmlspecialchars($_POST['lastname']);
      $born = htmlspecialchars($_POST['born']);
      $type = (int) htmlspecialchars($_POST['type']);
      $mail = htmlspecialchars($_POST['email']);
      $password = htmlspecialchars($_POST['password']);
      $password2 = htmlspecialchars($_POST['repeatPassword']);


      if(($password==$password2) && strlen($password) >= 7){
        //We can create the user
        //Upload to database
        $db = new Database();
        $db->callProcedure('insertUser', array($name, $lastname, $born, $type, NULL, md5($password), $mail));
        //send mail here
        include_once "../Server_v02/mail/mail.php";
        var_dump(array($name, $lastname, $born, $type, 'null', md5($password), $mail));
        if(!empty($db->getErrors())) {
          die(print_r($db->getErrors()));
        } else {
          $res = $db->getResult();
          // print_r($res);
          echo "<br><hr><br>";
          echo $res[0]['last_id'];
          $_SESSION['user_id'] = (int) $res[0]['last_id'];
          $_SESSION['login'] = "login_Ok";
          // print_r($db->getResult());
          // die();
        }
        ?>
        <script type="text/javascript">
        window.location="<?php echo $_SERVER['PHP_SELF']; ?>";
        </script>
        <?php
      } else{
        die("password error");
      }
    }
  } else {
    die("");
  }
}
elseif ((isset($_REQUEST['act'])) && ($_REQUEST['act'] == "logout") && (isset($_REQUEST['userIdentifier'])) && ($_SESSION['login'] == "login_Ok") && (isset($_SESSION['user_id']))){
  // header("Refresh:100; url=".$_SERVER['PHP_SELF']);
  echo("<h1 align=center>Ciao e grazie!!!!!</h1>");
  sleep(2);
  unset($_SESSION['login']);
  unset($_SESSION['user_id']);
  session_destroy();
  ?>
  <script type="text/javascript">
  window.location="<?php echo $_SERVER['PHP_SELF']; ?>";
  </script>
  <?php
}
?>
