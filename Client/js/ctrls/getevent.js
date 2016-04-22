app.controller("GetEventCtrl", function($rootScope, $scope, $http, $window, Evento){
  document.title = "Event | Mergefy";


  getAll();

  //TODO MI MARCA SOLO GLI EVENTI VICINI.
  function getAll(){
    data1 = {}; data2 = {};
    action1 = "getEvent";
    data1.event_id = parseInt(Evento.id);
    data1.user_id = parseInt(window.localStorage['id']);
    data10 = data1;
    action2 = "getEventPartecipants";
    data2.event_id = parseInt(Evento.id);
    data20 = data2;
    action3 = "getPartecipationStatus";

    obj = [
      {
        "action": action1,
        "data": data10
      },
      {
        "action": action2,
        "data": data20
      },
      {
        "action":action3,
        "data":data10
      }
    ];

    $http.post($rootScope.url, obj).success(function(res) {
      console.log(res)
      resGetEvent = res[0].data;
      $scope.partecipanti = res[1].data;
      angular.forEach( $scope.partecipanti, function(value, key){
        var image = value.image_profile;
        if(image.indexOf('http') ==-1){
          value.image_profile = $rootScope.serverImages+value.image_profile;
        }
      });
      for (i = 0; i<resGetEvent.length; i++){
          $scope.evento = resGetEvent[i];
      }
      var creatorImage = $scope.evento.creator_image_profile;
      if(creatorImage.indexOf('http') ==-1){
        $scope.evento.creator_image_profile = $rootScope.serverImages+$scope.evento.creator_image_profile;
      }

      if (typeof $scope.evento === "undefined") {
        console.log("Nessun risultato, non puoi vedere questo evento")
        //window.location.href=$rootScope.urlClient+"index.html#/events";
      } else {
        console.log("Hai il diritto di vedere questo evento");
      }
      if(typeof res[2].data[0] != "undefined"){
        $scope.evento.status = res[2].data[0].status;
      }

    }).error(function(error) {
      console.log(error, "Errore durante la comunicazione");
    })
  }

  $scope.partecipate = function(){
    var request = {};
    var data = {};
    request.action = "addPartecipant";
    data.event_id = parseInt(Evento.id);
    data.user_id = parseInt(window.localStorage['id']);
    data.status = "accepted";
    request.data = data;
    $http.post($rootScope.url, [request]).success(function(res) {
      console.log(res);
      getAll();
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }

  $scope.updatePartecipationStatus = function(status){
    var request = {};
    var data = {};
    request.action = "updatePartecipationStatus";
    data.event_id = parseInt(Evento.id);
    data.user_id = parseInt(window.localStorage['id']);
    data.status = status;
    request.data = data;
    $http.post($rootScope.url, [request]).success(function(res) {
      console.log(res);
      getAll();
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }
  /* APRI MAPPA */
  $scope.openMap = function(aaa, evento){
    var link = "http://maps.apple.com/maps?q="+evento.latitude+","+evento.longitude;
    $window.location.href = link;
    $window.open(link, "_system", 'location=no');
  }

  // crea documento
  $scope.createDoc = function(nomeEvento){
    // da sistemare
    obj = {};
    obj.action = "createDoc";
    data = {};
    data.creator_id = parseInt(window.localStorage['id']);
    data.name = nomeEvento;
    data.event_id = parseInt(Evento.id);
    data.event_visibility_type = $scope.evento.event_type;
    obj.data = data;
    console.log(obj);
    $http.post($rootScope.url, [obj]).success(function(res) {
      console.log(res);
      var link = "#/livedoc/"+res[0].data[0].returned_id;
      // console.log(link)
      window.location.href = $rootScope.urlClient+link;
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })

  }
});
