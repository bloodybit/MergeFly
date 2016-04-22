/*

var map;
function initialize() {
  var latitude = 44.488851,
    longitude = 11.297554,
    center = new google.maps.LatLng(latitude,longitude),
    mapOptions = {
      center: center,
      zoom: 14,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      scrollwheel: false
    };

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

  setMarkers(center, map);
}

function setMarkers(center, map) {

  latLng = new google.maps.LatLng(44.488851, 11.297554);
  var marker = new google.maps.Marker({
    position: latLng,
    map: map,
    title: "Polyflash di Boiani Alberto"
  });

}

function resize() {
  var center = map.getCenter();
  google.maps.event.trigger(map, "resize");
  map.setCenter(center);
}

google.maps.event.addDomListener(window, 'load', initialize);
google.maps.event.addDomListener(window, "resize", resize);
*/
