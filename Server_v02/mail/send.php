<?php


//echo "\1";

// $email and $message are the data that is being
// posted to this page from our html contact form
//$email = $_REQUEST['email'] ;
//$message = $_REQUEST['message'] ;

// When we unzipped PHPMailer, it unzipped to
// public_html/PHPMailer_5.2.0
require("PHPMailer_5.2.0/class.phpmailer.php");
require("lib/PHPMailer/PHPMailerAutoload.php");

function send($email, $message, $name)
{


   $mail = new PHPMailer();

// set mailer to use SMTP
   $mail->IsSMTP();


// enables SMTP debug information (for testing)
   $mail->SMTPDebug = 2;

// turn on SMTP authentication
   $mail->SMTPAuth = true;

// sets the prefix to the servier
   $mail->SMTPSecure = "tls";


// As this email.php script lives on the same server as our email server
// we are setting the HOST to localhost
// sets GMAIL as the SMTP server
   $mail->Host = "send.one.com";

// set the SMTP port for the GMAIL server
   $mail->Port = 587;


// When sending email using PHPMailer, you need to send from a valid email address
// In this case, we setup a test email account with the following credentials:
// email: send_from_PHPMailer@bradm.inmotiontesting.com
// pass: password
   $mail->Username = "info@polleg.it";  // SMTP username
   $mail->Password = "t0k15HiMa.VOLT"; // SMTP password

// $email is the user's email address the specified
// on our contact us page. We set this variable at
// the top of this page with:
// $email = $_REQUEST['email'] ;
   $mail->From = $email;

// below we want to set the email address we will be sending our email to.
   $mail->AddAddress($email, $name);

// set word wrap to 50 characters
   $mail->WordWrap = 50;
// set email format to HTML
   $mail->IsHTML(true);

   $mail->Subject = "You have received feedback from your website!";

// $message is the user's message they typed in
// on our contact us page. We set this variable at
// the top of this page with:
// $message = $_REQUEST['message'] ;
   $mail->Body = $message;


   if (!$mail->Send()) {
      echo "Message could not be sent. <p>";
      echo "Mailer Error: " . $mail->ErrorInfo;
      exit;
   }

   echo "Message has been sent";
}
