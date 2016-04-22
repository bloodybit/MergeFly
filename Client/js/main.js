var app = angular.module('tutorialWebApp', [
  'ngRoute', 'ngMap', 'naif.base64'
]);

angular.module('tutorialWebApp').filter('cut', function () {
        return function (value, wordwise, max, tail) {
            if (!value) return '';

            max = parseInt(max, 10);
            if (!max) return value;
            if (value.length <= max) return value;

            value = value.substr(0, max);
            if (wordwise) {
                var lastspace = value.lastIndexOf(' ');
                if (lastspace != -1) {
                    value = value.substr(0, lastspace);
                }
            }

            return value + (tail || ' …');
        };
    });


/**
* Configure the Routes
*/
app.config(['$routeProvider', function ($routeProvider) {
  $routeProvider
  // Home
  .when("/", {templateUrl: "partials/home.html", controller: "HomeCtrl"})
  // Pages
  .when("/events", {templateUrl: "partials/events.html",controller: "EventsCtrl"})
  .when("/livedoc/:id", {templateUrl: "partials/livedoc.html", controller: "LiveDocCtrl",resolve:{Documento:function($routeParams){return $routeParams;}}})
  .when("/docs", {templateUrl: "partials/docs.html", controller: "DocsCtrl"})
  .when("/doc/:id", {templateUrl: "partials/doc.html", controller: "DocCtrl",resolve:{Documento:function($routeParams){return $routeParams;}}})
  .when("/profile", {templateUrl: "partials/profile.html", controller: "ProfileCtrl"})
  .when("/groups", {templateUrl: "partials/groups.html", controller: "GroupsCtrl"})
  .when("/group/:id", {templateUrl: "partials/group.html", controller: "GroupCtrl",resolve:{Gruppo:function($routeParams){return $routeParams;}}})
  .when("/addevent", {templateUrl: "partials/addevent.html", controller: "EventCtrl"})
  .when("/event/:id",{templateUrl:"partials/event.html",controller:"GetEventCtrl",resolve:{Evento:function($routeParams){return $routeParams;}}})
  // .when("/group/:id", {templateUrl: "partials/groups.html", controller: "GroupCtrl"})
  .when("/addgroup", {templateUrl: "partials/addgroup.html", controller: "AddGroupCtrl"})
  // Blog
  .when("/blog", {templateUrl: "partials/blog.html", controller: "BlogCtrl"})
  .when("/blog/post", {templateUrl: "partials/blog_item.html", controller: "BlogCtrl"})
  // else 404
  .otherwise("/404", {templateUrl: "partials/404.html", controller: "PageCtrl"});
}]);

app.run(function($rootScope, NgMap) {
  // window.localStorage['id'] = 2;
  document.title = "Dashboard | Mergefy";
  var personalFolder = "MDEF";
  $rootScope.url = "http://polleg.it/"+personalFolder+"/Server_v02/handler.php";
  $rootScope.urlClient = "http://polleg.it/"+personalFolder+"/Client/";
  $rootScope.serverImages = "http://polleg.it/"+personalFolder+"/Server_v02/images/";
  $rootScope.urlPDF = "http://polleg.it/"+personalFolder+"/Server_v02/toPDF.php";
  NgMap.getMap().then(function(map) {
    $rootScope.map = map;
  });
});
