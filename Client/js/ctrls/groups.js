app.controller('GroupsCtrl', function($scope, $location, $http, $rootScope) {
  document.title = "Groups | Mergefy";
  $scope.searchtext = "";
  $scope.cane = false;
  $scope.hasRights = false;
  getUserGroups();


  function getUserGroups(){
    obj = {};
    data = {};
    obj.action = "getUserGroups";
    data.user_id = parseInt(window.localStorage['id']);
    obj.data = data;

    $http.post($rootScope.url, [obj]).success(function(res) {
      console.log(res);
      $scope.groups = res[0].data;
      angular.forEach( $scope.groups, function(value, key){
        var image = value.group_image;
        if(image.indexOf('http') ==-1){
          value.group_image = $rootScope.serverImages+value.group_image;
        }
      });

    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }


  $scope.view = function(id) {
    var link = "#/group/" + id;
    console.log("clicked on a group link. Going to -> " + link)
    window.location.href = link;
  }

  $scope.showhide = function() {
    $scope.cane = false;
  }

  $scope.$watch('searchtext', function() {

    var searchtext = $scope.searchtext;
    if (((searchtext.length % 3) == 0) && (searchtext.length >= 3)) {
      ob = {};
      dat = {};
      ob.action = "searchUser";
      dat.text = searchtext;
      ob.data = dat;
      $http.post($rootScope.url, [ob]).success(function(res) {
        console.log(res);
        $scope.results = res[0].data;
      }).error(function(error) {
        console.log(error, "non vaaaa");
      })
    }
    if(searchtext.length == 0) {$scope.results = [];}
  })

  $scope.partecipantList = [];

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

  $scope.creaGruppo = function(m, p) {
    console.log(m, p);
    data1 = {};
    action1 = "createGroup";
    data1.name = m.name;
    data1.description = m.description;
    if(m.image === undefined){
      data1.image = "null";
      console.log("undef");
    }else{
      console.log("dentro");
      data1.image = "data:"+m.image.filetype+";base64,"+m.image.base64;
    }

    data1.admin_id = parseInt(window.localStorage['id']);
    push = [
      {
        action: action1,
        data: data1
      }
    ];
    console.log(data1);

    $http.post($rootScope.url, push).success(function(rez) {
      console.log(rez);
      var new_group_id = rez[0].data[0].lastid;
      arr = [];
      for (i = 0; i < p.length; i++)
      {
          arr.push({action:"addMember", data:{user_id: parseInt(p[i].id), group_id: parseInt(new_group_id)}})
      }
      console.log(arr);
      $http.post($rootScope.url, arr).then(function(data) {
        console.log(data);
        window.location.reload();

      })
    }).error(function(error) {
      console.log(error, "non vaaaa");
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
      getUserGroups();
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
      getUserGroups();
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }



});
