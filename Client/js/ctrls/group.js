app.controller('GroupCtrl', function ($scope, $http, $location, $rootScope, Gruppo) {
  document.title = "Group| Mergefy";

  getGroupInfo();

  $scope.hasRights = "false";
  if (parseInt(Gruppo.id)) {
    $scope.cane = true;
  }
  $scope.showhide = function () {
    $scope.cane = false;
  }
  $scope.edit = false;

  gruppo = {}
  $scope.editGroup = function() {
    $scope.edit ? $scope.edit= false: $scope.edit= true;

  };

  $scope.leaveGroup = function(){
    request = {};
    data = {};
    request.action="removeMember";
    data.user_id = parseInt(window.localStorage['id']);
    data.group_id = parseInt(Gruppo.id);
    request.data = data;

    $http.post($rootScope.url, [request]).success(function(res) {
      console.log(res);
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })


  }

  $scope.saveChanges = function(gruppo) {
    $scope.edit = false;

    obj = {}; data = {};
    obj.action = "updateGroup";
    data.group_id = parseInt(gruppo.id);
    data.name = gruppo.name;
    if(gruppo.content === undefined){
      data.image = gruppo.image;
    }else{
      data.image = "data:"+gruppo.content.filetype+";base64,"+gruppo.content.base64;
    }
    data.description = gruppo.description;
    obj.data = data;
    console.log(obj)
    $http.post($rootScope.url, [obj]).success(function(r) {
      console.log(r)
    }).error(function(err) {
      console.log(err, "non va");
    })
  };


  function getGroupInfo(){
    obj = {}; data = {}; data1 = {}; data2 = {};
    action = "getUserGroups";
    data.user_id = parseInt(window.localStorage['id']);
    data11 = data;
    action1 = "getGroupInfo";
    data1.group_id = parseInt(Gruppo.id);
    data10 = data1;
    action2 = "getGroupMembers";
    action3 = "getEventsGroupByUserId";
    data2.user_id = parseInt(window.localStorage['id']);
    data2.group_id = parseInt(Gruppo.id);

    action4 = "getDocumentsGroupByUserId";

    obj = [
      {
        "action": action,
        "data": data11
      },
      {
        "action": action1,
        "data": data10
      },
      {
        "action": action2,
        "data": data10
      },
      {
        "action": action3,
        "data": data2
      },
      {
        "action": action4,
        "data": data2
      }
    ];
    console.log(obj);
    $http.post($rootScope.url, obj).success(function(res) {
      console.log(res);
      $scope.groups = res[0].data;
      angular.forEach( $scope.groups, function(value, key){
        var image = value.group_image;
        if(image.indexOf('http') ==-1){
          value.group_image = $rootScope.serverImages+value.group_image;
        }
      });

      rr = res[1].data;
      for (i = 0; i<rr.length; i++){
        $scope.gruppo = rr[i];
        var image = $scope.gruppo.image;
        if(image.indexOf('http') ==-1){
          $scope.gruppo.image = $rootScope.serverImages+$scope.gruppo.image;
        }

      }

      angular.forEach(res[2].data, function(value, key) {
        if(value.user_id == window.localStorage['id']){
          if(value.role == 'admin'){
            $scope.hasRights = true;
            $scope.admin = value;
          }else {
            $scope.hasRights = false;
          }
        }else{
          if(value.role == 'admin'){
            $scope.admin = value;
          }
        }

        var memberImage = value.image_profile;
        if(memberImage.indexOf('http') ==-1){
          value.image_profile = $rootScope.serverImages+value.image_profile;
        }


      });
      $scope.membri = res[2].data;
      $scope.events = res[3].data;
      $scope.docs = res[4].data;

    }).error(function(err) {
      console.log(err, "non vaaaa");
    })
  }
  // CHANGE PAGE
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
