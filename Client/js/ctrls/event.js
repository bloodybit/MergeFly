app.controller('EventCtrl', function($rootScope, $scope, $http,$window){

  // INFO
  document.title = "Add Event | Mergefy";
  console.log("Contoller EventCtrl attivato");
  $scope.premium = window.localStorage['type'] == 'premium';

  /* INIT */
  // vars
  $scope.partecipantList = []; // partecipantList to send to the Server
  $scope.searchPlace = "";
  $scope.searchUser = "";
  $scope.new = {};
  placeToAdd = {};
  // functions
  getCategories();

  /**** Funcitons activated as the contoller loads ****/
  function getCategories(){
    // Get all categories
    var request = {};
    request.action = "getCategories";
    request.data = {},
    $http.post($rootScope.url, [request]).success(function(result) {
      console.log(result);
      $scope.categories = result[0].data;
    }).error(function(error) {
      console.log(error, "Errore nel caricamento delle categorie.");
    })
  }

  // SEARCH USER
  $scope.$watch('searchUser', function() {

    var searchUser = $scope.searchUser;
    if (((searchUser.length % 2) == 0) && (searchUser.length >= 2)) {
      $scope.results = [];
      ob = {};
      dat = {};
      ob.action = "searchUser";
      dat.text = searchUser;
      ob.data = dat;
      $http.post($rootScope.url, [ob]).success(function(res) {
        console.log(res);
        $scope.results = res[0].data;
      }).error(function(error) {
        console.log(error, "non vaaaa");
      })
    }
    if(searchUser.length == 0) {$scope.results = [];}
  })

  // PUSH TO ARRAY
  // add partecipant to the list that will be sent to the Server
  $scope.pushToarray = function(id) {
    if ($scope.partecipantList.indexOf(id) == -1) {
      $scope.partecipantList.push(id);
      console.log($scope.partecipantList);
    }
  }

  // CREAR ARRAY
  $scope.clearArray = function() {
    $scope.searchUser = "";
    $scope.partecipantList = [];
    console.log("No partecipants");
    console.log($scope.partecipantList);
  }

  // SEARCH PLACE
  $scope.$watch('searchPlace', function() {
    noPlace = false;
    searchPlace = $scope.searchPlace;
    console.log(searchPlace);

    if ($scope.newPlace != true && searchPlace.length >= 1) {
      // reset the list of places
      $scope.places = [];
      // create request object
      request = {};
      params = {};
      params.chars = searchPlace;

      request.action = "searchPlaces";
      request.data = params;
      // post
      $http.post($rootScope.url, [request]).success(function(results) {
        console.log(results[0].data.length);
        if(results[0].data.length == 0){
          noPlace = true;
          $scope.places = [{noPlace: true, message: "No place found"}];
          $scope.new.name = searchPlace;
          console.log($scope.places);
        }else{
          noPlace= false;
          $scope.places = results[0].data;
        }
      }).error(function(error) {
        console.log(error, "Errore nell caricamento dei nomi");
      })
    }
    if((searchPlace.length == 0 || !angular.isUndefined(searchPlace) ) && noPlace == false) {$scope.places = [];}
  });

  // SET PLACE
  $scope.setPlace = function(place){
    console.log(place);
    if(!angular.isUndefined(place.noPlace) && place.noPlace == true){
      console.log("nuovo")
      $scope.newPlace = true;
      $scope.places = [];
    }else{
      console.log("vecchio")
      $scope.iddi = place.id;
      $scope.newPlace = false;
      $scope.selectedPlace = place;
      $scope.searchPlace = place.name;
      $scope.places = [];
    }
  }

  // NEW PLACE
  $scope.$watch('new', function() {
    console.log("watched");
    var urlToGmaps = "http://maps.google.com/maps/api/geocode/json?address="+$scope.new.address+"+"+$scope.new.city+"&sensor=false";
    $http.get(urlToGmaps).success(function (data) {
      console.log(data.results[0].geometry.location);
      placeToAdd.address= $scope.new.address;
      placeToAdd.city= $scope.new.city;
      placeToAdd.latitude= data.results[0].geometry.location.lat;
      placeToAdd.longitude= data.results[0].geometry.location.lng;
    });
  }, true);

  // ADD PLACE
  $scope.createPlace = function() {
    console.log("createPlace")
    if ($scope.newPlace === true) {
      placeToAdd.name = $scope.new.name;
      placeToAdd.cap = $scope.place.cap;
      placeToAdd.nation= $scope.place.nation;
      console.log(placeToAdd);

      var request = {};
      var params = {};
      request.action = "addPlace";
      request.data = placeToAdd;

      $http.post($rootScope.url, [request]).success(function(results) {
        console.log(results);
        lastid = results[0].data[0].lastid;
        createEvent(lastid);

      }).error(function(error) {
        console.log(error, "Errore nell caricamento dei nomi");
      })
    } else {
      createEvent($scope.iddi);
    }

  }

  // CREATE EVENT
  function createEvent(placeid){
    console.log($scope.event);

    var params = {};
    params = $scope.event;
    params.place_id= parseInt(placeid);
    params.creator_id= parseInt(window.localStorage['id']);

    var request1 = {
      action: "addEvent",
      data: params
    };
    console.log(request1);

    $http.post($rootScope.url, [request1]).success(function(res) {
      console.log(res);
      $scope.results = res[0].data;
      var lastid = res[0].data[0].lastid;
      addPartecipant(lastid);
      goto('event', lastid);
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }

  // ADD PARTECIPANT
  function addPartecipant(eventid){
    console.log(eventid);
    request = [];
    action = "addPartecipant";
    if($scope.partecipantList.length != 0){
      angular.forEach( $scope.partecipantList, function(value, key){
        data = {};
        data.event_id = parseInt(eventid);
        data.user_id = parseInt(value.id);
        data.status = "waiting";
        request.push({
          action: action,
          data: data
        });

      });
      console.log(request);
      //aggiungo partecipanti all'evento
      $http.post($rootScope.url, request).success(function(results) {
        console.log(results);

      }).error(function(error) {
        console.log(error, "Errore nella aggiunta dei partecipanti");
      })
    }
  }

  // GO TO PAGE
  function goto(page, id) {
  	var link = "#/"+page+"/"+id;
    window.location.href = $rootScope.urlClient+link;
  }

  /*
  POST createEvent
  */

  // per verifiche by ludo -> da cancellare!!!
  // var createEventLinkToPost = "file.json";
  // $http.get(createEventLinkToPost).success(function(data) {
  //   console.log(data);
  // })
  // fine verifiche da cancellareeeeeeee
  // $scope.vm = {};
  // var adesso = new Date();
  // year = adesso.getFullYear();
  // month = adesso.getMonth();
  // monthh = month+1;
  // day = adesso.getDate();
  // console.log(year, month, monthh, day);
  // $scope.vm.dataStart = new Date(year, month, day);
  // $scope.vm.dataEnd = new Date(year, monthh, day);
  $scope.createEv = function(dataObj) {
    console.log("createEvent")
    if (!angular.isUndefined(dataObj)) {
      count = 0;
      angular.forEach(dataObj, function(v, k) {
        count++;
      });
      if ((count===10)||(count===11)||(count===13)) {
        console.log(JSON.stringify(dataObj))
        // GEOCODING start
        var urlToGmaps = "http://maps.google.com/maps/api/geocode/json?address="+dataObj.address+"+"+dataObj.city+"&sensor=false";
        $http.get(urlToGmaps).success(function (data) {
          console.log(data.results[0].geometry.location);
          // GEOCODING end
          dataObj.lat = data.results[0].geometry.location.lat;
          dataObj.lng = data.results[0].geometry.location.lng;
          // faccio la post
          var createEventLinkToPost = $rootScope.url+"?action=addEvent&model=event";
          $http.post(createEventLinkToPost, dataObj).success(function(data, status, headers, config) {
            console.info(JSON.stringify(data));
            $scope.data = data;
          }).error(function(data, status, headers, config) {
            console.log(data, config);
            alert("Errore nell'invio della POST: " + JSON.stringify({data: data}));
          });
        }).error(function (data) {
          alert("Errore nell'invio della POST: " + JSON.stringify({data: data}));
        });


      }
      else {
        console.log("Errore conteggio dati","Non hai compilato tutti i campi!")
      }
    } else {
      console.log("Errore nell'invio del form","Il form risulta essere vuoto.")
    }
  }

});
