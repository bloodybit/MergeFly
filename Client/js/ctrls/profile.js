app.controller("ProfileCtrl", function($rootScope, $scope, $http, $window){

  document.title = "Profile | Mergefy";
  getProfile();

  function getProfile(){
    data = {};
    action1 = "getUser";
    data.user_id = parseInt(window.localStorage['id']);
    action2 = "getUserDocs";
    action3 = "getUserGroups";
    obj = [
      {
        "action": action1,
        "data": data
      },
      {
        "action": action2,
        "data": data
      },
      {
        "action": action3,
        "data": data
      }
    ];
    console.log(JSON.stringify(obj));
    $http.post($rootScope.url, obj).success(function(res) {
      console.log(res);
      $scope.user = res[0].data[0];
      var image = $scope.user.image_profile;
      if(image.indexOf('http') ==-1){
        $scope.user.image_profile = $rootScope.serverImages+$scope.user.image_profile;
      }
      $scope.docs = res[1].data;
      $scope.groups = res[2].data;

    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }


  // switch page on button pression
  $scope.goto = function(page) {
    if(page == 'home'){
      var link = "#/"
    }else{
      var link = "#/"+page+"/";
    }
    console.log("clicked. Going to -> "+link)
    window.location.href=link;
  }

  // activate edit view
  $scope.clicked = false;
  $scope.edit = function(){
    $scope.clicked ? $scope.clicked = false : $scope.clicked = true;
  }

  // update user info
  $scope.update = function(user) {
    $scope.clicked = false;
    obj = {};
    data = {};
    obj.action = "updateUser";
    data.id = parseInt(window.localStorage['id']);
    data.name = user.name;
    data.lastname = user.lastname;
    data.mail = user.mail;
    data.born = user.born;
    console.log(user.content);
    if(user.content === undefined){
      data.image_profile = user.image_profile;
    }else{
      data.image_profile = "data:"+user.content.filetype+";base64,"+user.content.base64;
    }
    obj.data = data;
    console.log(obj);
    $http.post($rootScope.url, [obj]).success(function(res) {
      console.log(res);
      getProfile();
    }).error(function(er) {
      console.log(er, "Errore in updateUser");
    });
  }

});
