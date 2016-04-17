app.controller('EventsCtrl', function ($scope, $rootScope, $compile, $window,$http, NgMap) {
  document.title = "Events | Mergefy";
  $scope.eventsNavbar = true;
  $scope.loadComplete = false;
  $scope.changeEvents = function( bool ) {
    $scope.eventsNavbar = bool;
  };

  obj = {};
  data = {};
  data.user_id = parseInt(window.localStorage['id']);
  obj.action = "userNearEvents";
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position){
      $scope.$apply(function(){
        data.latitude = parseFloat(position.coords.latitude);
        data.longitude = parseFloat(position.coords.longitude);
        $scope.latitudine = data.latitude;
        $scope.longitudine = data.longitude;
        data.dist = parseInt("1000");
        obj.data = data;
        console.log("Posizione presa! ",obj);
        $http.post($rootScope.url, [obj]).success(function(result) {
          $scope.loadComplete = true;
          console.log(result[0].data);
          $scope.eventiVicini = result[0].data;
          // vai con l'altra
          objj = {};
          data = {};
          objj.action = "getUserEvents";
          data.user_id = parseInt(window.localStorage['id']);
          data.which = "all";
          objj.data = data;
          console.log(objj);
          $http.post($rootScope.url, [objj]).success(function(res) {
            console.log(res[0].data);
            $scope.eventiPartecipo = res[0].data;
          }).error(function(er) {
            console.log(er, "Errore in getUserEvents");
          });

          // stop

        }).error(function(error) {
          console.log(error,"Errore userNearEvents");
        })
      });
    });
  } else {
    console.log("else")
    data.latitude = parseInt("0");
    data.longitude = parseInt("0");
    data.dist = parseInt("100");
    obj.data = data;
    console.log("Nessuna posizione presa ",obj);
    $http.post(urlToNearEventsZero, obj).success(function(result) {
      console.log(result);
      $scope.eventiVicini = result;
    }).error(function(error) {
      console.log(error);
    })
  }
  $scope.gotoEvent = function(idEvent) {
    window.location.href="#/event/"+parseInt(idEvent);
  }







  // Ng map scope
  NgMap.getMap().then(function(map) {
    $scope.map = map;
    $scope.detail = function(event, eventoPart) {
      $scope.eventoVic = eventoPart;
      console.log(event)
      $scope.map.showInfoWindow('infoW', this);
    };
    console.log('markers', map.markers);
    //console.log('shapes', map.shapes);
  });

  function resize() {
    var center = this.map.getCenter();
    google.maps.event.trigger(map, "resize");
    navigator.geolocation.getCurrentPosition(function(position){
      $scope.$apply(function(){
        latt = parseFloat(position.coords.latitude);
        lonn = parseFloat(position.coords.longitude);
      });
    });
    map.setCenter(latt,lonn);

  }

  // google.maps.event.addDomListener(window, 'load', initialize);
  google.maps.event.addDomListener(window, "resize", resize);




});
