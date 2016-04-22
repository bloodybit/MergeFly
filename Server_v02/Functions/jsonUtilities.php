<?php


class JsonUtilities{

    public static function fromJsonToArray($json) {

        $sending = array();
        foreach($json as $key=>$value){
            array_push($sending, $value);
        }

        return $sending;
    }
}