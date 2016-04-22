
<?php


require_once ('../Server_v02/mail/PHPMailer_5.2.0/class.phpmailer.php');

$mailSender             = new PHPMailer(); // defaults to using php "mail()"

$body             = "<body style=\"margin: 10px;\">
                          <div style=\"width: 640px; font-family: Arial, Helvetica, sans-serif; font-size: 11px;\">
                          <div align=\"center\"><img src=\"../Server_v02/mail/PHPMailer_5.2.0/examples/images/mergefly.jpg\"></div><br>
                          <br>
                          &nbsp;<h1>Welcome to MergeFly!</h1>
                          <br>
                          <p style=\"font-size: 14px;\">We hope you will enjoy our envirenment and your friends knowledge. Start and <strong>Share</strong> notes with your mates!<br>
                          styles.</p>
                          <h2>Visit <a href='http://polleg.it/MDEF'>MergeFly</a>!</h2>
                          <br>
                              <p style=\"font-size: 14px;\">Since this is an alpha version, please help us with your feedback and remarkable observation!</p>
                          <br />
                              <h3>Something weird?</h3> <p style=\"font-size: 14px;\">Tell us! Mail to <a href=\"mailto:info@polleg.it?Subject=Chuy,%20it%20isn't%20working!\">our address!</a></p>

                          <br />
                              <p style=\"font-size: 18px;\">Your Credential: <br>- mail: ". $mail ."<br>- password: ". $password . "</p>
                          <img src=\"../Server_v02/mail/PHPMailer_5.2.0/examples/images/polleg.png\"></div>
                          <p>Polleg.it:<br />
                          Author: Riccardo Sibani (riccardo.sibani@polleg.it)<br />
                          Author: Filippo Boiani (filippo.boiani@polleg.it)<br /></p>
                          </body>";
$body             = eregi_replace("[\]",'',$body);

$mailSender->AddReplyTo("info@polleg.it","Polleg.it");

$mailSender->SetFrom('info@polleg.it', 'Polleg.it');

$mailSender->AddReplyTo("info@polleg.it","Polleg.it");

$address = $mail;
$mailSender->AddAddress($address, $name . " " . $lastname);

$mailSender->Subject    = "Welcome to MergeFly, " . $name . " " . $lastname;

$mailSender->AltBody    = "Your Registration has been Successful! Start Sharing!"; // optional, comment out and test

$mailSender->MsgHTML($body);


if (!$mailSender->Send()) {
  echo "Message could not be sent. <p>";
  echo "Mailer Error: " . $mailSender->ErrorInfo;
  exit;
}

echo "Message has been sent";
?>



