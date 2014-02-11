bangman.directive('bmTimer', function() {

  var diameter = 100,
      stroke = 10,
      twoPi = 2 * Math.PI;

  return {
    restrict: 'E',
    scope: {
      duration: '=',
      time: '='
    },
    link: function (scope, element, attrs) {
      var arc = d3.svg.arc()
        .startAngle(0)
        .innerRadius(diameter / 2 - stroke)
        .outerRadius(diameter / 2);

      var svg = d3.select(element[0]).append("svg")
        .attr("width", diameter)
        .attr("height", diameter)
        .append("g")
        .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");

      var meter = svg.append("g")
        .attr("class", "progress-meter");

      meter.append("path")
        .attr("class", "background")
        .attr("d", arc.endAngle(twoPi));

      var foreground = meter.append("path")
        .attr("class", "foreground");

      var text = meter.append("text")
        .attr("text-anchor", "middle")
        .attr("dy", ".35em");

      scope.$watch('time', function (newVal, oldVal) {
        if (newVal) {
          foreground.attr("d", arc.endAngle(twoPi * newVal / scope.duration));
          text.text(newVal);
        }
      });
    }
  };
});
