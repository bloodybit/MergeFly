app.controller('DocsCtrl', function($scope, $rootScope, $http){

  // Init variables
  document.title = "Documents | Mergefy";
  getUserDocs();
  // GET USER DOCS
  function getUserDocs(){
    var obj = {};
    var data = {};
    obj.action = "getUserDocs";
    data.user_id = parseInt(window.localStorage['id']);
    obj.data = data;
    $http.post($rootScope.url, [obj]).success(function(res) {
    	console.log(res);
    	$scope.docs = res[0].data;
    }).error(function(error) {
    	alert("trovat un errore!", error);
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
