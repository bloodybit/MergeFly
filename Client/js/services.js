app.directive('stringToTimestamp', function() {
  return {
    require: 'ngModel',
    link: function(scope, ele, attr, ngModel) {
      // view to model
      ngModel.$formatters.push(function (modelValue) {
        if (modelValue) {
          return new Date(modelValue);
        } else {
          return null;
        }
      });
        // $parsers.push(function(value) {
        //   console.log("push"+value)
        //   return Date.parse(value);
        // });
      }
    }
  });
