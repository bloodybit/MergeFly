app.controller('LiveDocCtrl', function($scope, $rootScope, $http, $interval, Documento){

  // Init variables
  document.title = "Live Doc | Mergefy";
  $scope.toggle = false;
  $scope.clicked = false;
  $scope.selectedId = -1;
  var docTitle;
  getPageContent();
  //window.setInterval(getEventNotes, 3000);
  $interval(getEventNotes, 3000);

  function getEventNotes(){

    var request = {};
    var data = {};
    request.action = "getEventNotes";
    data.doc_id = parseInt(Documento.id);
    request.data = data;
    if(Documento.id != undefined){
      $http.post($rootScope.url, [request]).success(function(result) {
        console.log("Presi i nodi");
        $scope.nodi = result[0].data;
      }).error(function(error) {
        console.log(error);
      })
    }else{
      $interval.cancel(getEventNotes);
    }


  }

  // TOGGLE VIEW: used to toggle the "new note insertion" form.
  $scope.toggleView = function() {
    $scope.toggle = ($scope.toggle) ? false : true;
  };

  // EDIT DOC: used to toggle the possibility to edit the document.
  $scope.editDoc = function(nota) {
    $scope.selectedId = nota.$$hashKey;
  }

  // SAVE CHANGES
  $scope.saveChanges = function(newNote){
    $scope.selectedId = -1;
    var request = {};
    var data = {};
    request.action = "modifyNode";
    data.doc_id = parseInt(Documento.id);
    data.note_id = parseInt(newNote.note_id);
    data.title = newNote.title;
    data.content = newNote.content;
    data.description = newNote.description;
    request.data = data;
    console.log(request);
    $http.post($rootScope.url, [request]).success(function(result) {
      console.log(result);
    }).error(function(error) {
      console.log(error);
    })
  }

  // SHOW MODAL
  $scope.showModalNote = function(nota){
    $scope.modalNote = nota;
  }

  // SAVE DOC TITLE
  $scope.saveTitle = function(event, newTitle) {
    if(event.keyCode == 13){
      console.log("invio");
      $scope.docClicked= false;
      console.log(docTitle);
      if(newTitle != docTitle){
        var request = {};
        var data = {};
        request.action = "updateDocName";
        data.doc_id = parseInt(Documento.id);
        data.user_id = parseInt(window.localStorage['id']);
        data.name = newTitle;
        request.data = data;
        console.log(request);
        $http.post($rootScope.url, [request]).success(function(risult) {
          console.log(risult);
        }).error(function(error) {
          console.log(error);
        })
      }
    }
  }

  // EDIT TITLE
  $scope.editTitle= function(){
    $scope.docClicked= ($scope.docClicked) ? false: true;
  }

  // ADDNODO
  var obj0 = {};
  var data0 = {};
  var data1 = {};
  $scope.addNodo = function(data0){
    var url = $rootScope.url;
    action0 = "addNoteToDoc";
    data1.type = data0.type;
    data1.title = data0.title;
    if(data1.type === "image"){
      console.log("img",data0.content.filesize)
      data1.content = "data:"+data0.content.filetype+";base64,"+ data0.content.base64
    }else{
      console.log("noImmagine")
      data1.content = data0.content;
    }
    data1.description = data0.description;
    data1.document_id = parseInt(Documento.id);
    obj0.action = action0;
    obj0.data = data1;


    console.log(obj0);
    // if(data0.type != "image" || (data0.type === "image" && data0.content.filesize < "640000")){
     if(data0.type != "image" || data0.type === "image"){

      console.log(data0.content.filesize, "VA.");
      $http.post(url, [obj0]).success(function(risultato) {
      console.log(risultato);
      clearFields();
      //window.location.reload(true);
      getPageContent();
    }).error(function(er) {
      console.log(er);
    })
  } else {
    console.log(data0.content.filesize, "non va.");
    alert("Massima dimensione immagine 60kb. Riprova!");
    clearFields();
  }
  };

  //IMPORT NOTES
  $scope.importNote = function(note){
    var request = {};
    var data = {};
    request.action = "createNode";
    data.doc_id = parseInt(Documento.id);
    data.note_id = parseInt(note.id);
    request.data = data;
    console.log(request);

    $http.post($rootScope.url, [request]).success(function(result) {
      console.log(result);
      getPageContent();
    }).error(function(error) {
      console.log(error);
    })
  }

  // CLEAR FIELDS
  function clearFields(){
    obj0 = {};
    $scope.data = {};
    data0 = {};
    data1 = {};
  }

  // GET PAGE CONTENT
  // var obj = {};
  function getPageContent(){
    var data = {};
    action1 = "getDoc";
    action2 = "getDocContent";
    action3 = "getEventNotes";
    data.doc_id = parseInt(Documento.id);

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
        data: data
      }
    ]

    $http.post($rootScope.url, obj).success(function(r) {
      console.log(r);
      $scope.doc = r[0].data[0];
      $scope.note = r[1].data;
      $scope.nodi = r[2].data;
      angular.forEach( $scope.nodi, function(value, key){
        if(value.type === "image"){
          var image = value.content;
          value.imageWithPath = $rootScope.serverImages+image;
        }

      });
      docTitle = $scope.doc.name;
    }).error(function(er) {
      console.log(er);
    })
  }

  // DELETE NODE
  $scope.deleteNode = function(noteId){
    console.log(noteId);
    console.log(Documento.id);

    var request = {};
    var data = {};
    request.action = "deleteNode";
    data.doc_id = parseInt(Documento.id);
    data.note_id = parseInt(noteId);
    request.data = data;
    console.log(request);

    $http.post($rootScope.url, [request]).success(function(result) {
      console.log(result);
      getPageContent();
    }).error(function(error) {
      console.log(error);
    })
  }

  // CHANGE PAGE
  $scope.goto = function(page) {
    if(page == 'home'){
      var link = "#/"
    }else{
      var link = "#/"+page+"/";
    }
    console.log("clicked. Going to -> "+link)
    window.location.href=link;
  }

});
