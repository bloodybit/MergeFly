<?php
/**
 * Created by IntelliJ IDEA.
 * User: riccardosibani
 * Date: 12/04/16
 * Time: 10:36
 */
 session_start();
require_once 'dompdf/autoload.inc.php';
require_once 'database.php';
require_once 'Functions/jsonUtilities.php';

// reference the Dompdf namespace
use Dompdf\Dompdf;
use Dompdf\Options;

//check post
$doc_id = (int) $_GET['request'];

$db = new Database();
$db->callProcedure('getDoc', array($doc_id));
$doc = $db->getResult();

if(isset($_SESSION['user_id']) && $_SESSION['user_id'] == $doc[0]['creator_id']){
  getDocumentPDF($doc);
} else {
  echo "Not autorized";
}

function getDocumentPDF($doc){
    // instantiate and use the dompdf class
    $dompdf = new Dompdf();


    $html = getHtml($doc);
    $dompdf->loadHtml($html);

    // (Optional) Setup the paper size and orientation
    $dompdf->setPaper('A4', 'portrait');

    // Render the HTML as PDF
    $dompdf->render();

    // Output the generated PDF to Browser
    $dompdf->stream("doc_".$doc[0]['name']);
}

function getHtml($doc){

    //get doc content
    $db = new Database();
    $db->callProcedure('getDocContent', array($doc[0]['id']));
    $docContent = $db->getResult();

    //print_r($docInfo);
    //print_r($docContent);
    //echo "<br><br>";

    //append the html code
    $html = "<body>";

    $html .= "<style>
                /* NO, STYLE GOES HERE */
                body {
                  padding: 50px 40px;
                  font-family: Arial, Helvetica, sans-serif;
                }
                header h4, header h6 {
                  color: #9E9E9E;
                  font-style: italic;
                }
                header h4 {
                  font-size: small;
                }
                article h3 {
                  margin: 20px 0 10px 0;
                }
                article h4{
                  font-style: italic;
                  font-size: 110%;
                  font-weight: lighter;
                  color: #9E9E9E;
                  margin: 10px 0 0 0px;
                }
                pre {
                  background-color: #E0E0E0;
                  border: 1px solid #BDBDBD;
                  border-radius: 4px;
                  padding: 5px 15px 15px 15px;
                  width: 70%;

                  white-space: pre-wrap;       /* CSS 3 */
                  white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
                  white-space: -pre-wrap;      /* Opera 4-6 */
                  white-space: -o-pre-wrap;    /* Opera 7 */
                  word-wrap: break-word;
                }
                </style>";

    $html .= "<header><h1>".$doc[0]['name']."</h1><h4> By " .$doc[0]['creator_name']." ". $doc[0]['creator_lastname']."<h6> on ". $doc[0]['creationdate'] ."</h6></h4></header>";

    $html .= "<article>";

    //Print the notes
    foreach($docContent as $note){
        $html .= "<div>";

        $html .= "<h3>".$note['title']."</h3>";

        switch ($note['type']){
            case "image":
                $html .= "<div>";
                $html .= "<h4>".$note['description']."</h4>";
                $html .= "<img src='images/". $note['content'] ."' style='width:600px'/><br>";
                $html .= "</div>";
                break;
            case "text":
                $html .= "<div>";
                $html .= "<h4>".$note['description']."</h4>";
                $html .= "<p>".$note['content']."</p>";
                $html .= "</div>";
                break;
            case "code":
                $html .= "<div>";
                $html .= "<h4>".$note['description']."</h4>";
                $html .= "<p><pre>".$note['content']."</pre></p>";
                $html .= "</div>";
                break;
            case "link":
                $html .= "<div>";
                $html .= '<a href="'. $note['content'] . '" >' . $note['description'] ."</a>";
                $html .= "</div>";
                break;
        }


        $html .= "</div>";
    }

    $html .= "</article></body>";
    //echo $html;
    return $html;
}
