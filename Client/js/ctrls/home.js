app.controller('HomeCtrl', function ($http, $scope, $rootScope, $window) {

  document.title= "Dashboard | Mergefy";
  // Init
  $scope.invitationNav = true;
  getUser();
  getUserDocs();
  getNotifications();

  // Date
  var monthNames = [
    "January", "February", "March",
    "April", "May", "June", "July",
    "August", "September", "October",
    "November", "December"
  ];

  function checkTime(i) {
    return (i < 10) ? "0" + i : i;
  }

  var today = new Date();
  var day = today.getDate();
  var monthIndex = today.getMonth();
  var year = today.getFullYear();
  var min = checkTime(today.getMinutes());
  var hours = checkTime(today.getHours());
  $scope.clock = hours+":"+min;
  $scope.date = day + ' ' + monthNames[monthIndex] + ' ' + year;


  $scope.toggleInvitations = function( bool ) {
    $scope.invitationNav = bool;
  };

  //GET USER
  function getUser(){
    obj = {}; data = {};
    obj.action = "getUser";
    data.user_id = parseInt(window.localStorage['id']);
    obj.data = data;
    $http.post($rootScope.url, [obj]).success(function(ris) {
    	console.log(ris);
    	$scope.user = ris[0].data[0];
      window.localStorage['type'] = ris[0].data[0].type;
    }).error(function(errore) {
    	alert("trovat un errore!", errore);
    })
  }

  // GET USER DOCS
  function getUserDocs(){
    obj = {}; data = {};
    obj.action = "getUserDocs";
    data.user_id = parseInt(window.localStorage['id']);
    obj.data = data;
    $http.post($rootScope.url, [obj]).success(function(res) {
    	console.log(res);
    	$scope.documenti = res[0].data;
    }).error(function(error) {
    	alert("trovat un errore!", error);
    })
  }

  //GET ALL EVENTS AND GROUPS status
  function getNotifications(){
    user_id = parseInt(window.localStorage['id']);
    request = [
      {
        action: "getNotifications",
        data: {
          user_id: user_id
        }
      },
      {
        action: "getGroupsRequest",
        data: {
          user_id: user_id
        }
      }];
    console.log(request);
    $http.post($rootScope.url, request).success(function(res){
      console.log(res);
      $scope.events = res[0].data;
      $scope.groups = res[1].data;
    }).error(function(error){
      console.log("Error in events notifications", error);
      $scope.events = [];
    })
  }

  $scope.acceptMembership = function(groupid){
    request = {};
    data = {};
    request.action="acceptMembership";
    data.user_id = parseInt(window.localStorage['id']);
    data.group_id = parseInt(groupid);
    request.data = data;

    $http.post($rootScope.url, [request]).success(function(res) {
      console.log(res);
      getNotifications();
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }

  $scope.refuseMembership = function(groupid){
    request = {};
    data = {};
    request.action="refuseMembership";
    data.user_id = parseInt(window.localStorage['id']);
    data.group_id = parseInt(groupid);
    request.data = data;

    $http.post($rootScope.url, [request]).success(function(res) {
      console.log(res);
      getNotifications();
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }

  // GOTO SINGLE DOC
  $scope.goto = function(page, id) {
    if(page == 'home'){
      var link = "#/"
    }else{
      var link = "#/"+page+"/"+id;
    }
    console.log("clicked. Going to -> "+link)
    window.location.href=link;
  }
});
