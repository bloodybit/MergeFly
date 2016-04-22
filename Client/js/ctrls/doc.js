app.controller('DocCtrl', function($scope, $rootScope, $http, Documento){

  // Init variables
  document.title = "Doc | Mergefy";
  console.log(document.title);
  console.log("Doc id: "+Documento.id);
  getPageContent();
  $('#errorPanel').fadeOut();
  // GET PAGE CONTENT
  function getPageContent(){
    var data = {}; var data1 = {};
    action1 = "getDoc";
    action2 = "getDocContent";
    action3 = "getUserDocs";
    data.doc_id = parseInt(Documento.id);
    data1.user_id = parseInt(window.localStorage['id']);
    // request object.
    obj = [
      {
        action: action1,
        data: data
      },
      {
        action: action2,
        data: data
      },
      {
        action: action3,
        data: data1
      }
    ]
    console.log("Richiedo: ");
    console.log(obj);
    $http.post($rootScope.url, obj).success(function(r) {
      console.log(r);
      $scope.doc = r[0].data[0];
      $scope.note = r[1].data;
      $scope.documenti = r[2].data;
    }).error(function(er) {
      console.log(er);
    })
  }

  $scope.importNote = function(noteId){
    var request = {};
    var data = {};
    request.action = "importNote";
    data.doc_id = parseInt(Documento.id);
    data.note_id = parseInt(noteId);
    data.user_id = parseInt(window.localStorage['id']);
    request.data = data;
    $http.post($rootScope.url, [request]).success(function(result) {
      console.log(result);
      if(result[0].data.errorInfo != undefined){
        console.log("errore");
        $scope.error = result[0].data.errorInfo[2];
        $('#errorPanel').fadeIn();
      }
    }).error(function(error) {
      console.log(error);
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
