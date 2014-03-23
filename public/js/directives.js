bangman.directive('bmTimer', function() {

  var diameter = 150,
      stroke = 3,
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
        .attr("class", "bbw-timer")
        .attr("width", diameter)
        .attr("height", diameter)
        .append("g")
        .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");

      var meter = svg.append("g")
        .attr("class", "progress-meter");

      meter.append("path")
        .datum({ endAngle: twoPi })
        .attr("class", "background")
        .attr("d", arc);

      var foreground = meter.append("path")
        .datum({ endAngle: twoPi })
        .attr("class", "foreground")
        .attr("d", arc);

      var text = meter.append("text")
        .attr("text-anchor", "middle")
        .attr("class", "value")
        .attr("dy", ".35em");

      var label = meter.append("text")
        .attr("text-anchor", "middle")
        .attr("class", "label")
        .attr("dy", "2.3em")
        .text("sec")

      // see http://bl.ocks.org/mbostock/5100636
      arcTween = function(transition, newAngle) {
        transition.attrTween("d", function(d) {
          var interpolate = d3.interpolate(d.endAngle, newAngle);
          return function(t) {
            d.endAngle = interpolate(t);
            return arc(d);
          };
        });
      };

      scope.$watch("time", function (newVal, oldVal) {
        if (newVal) {
          foreground.transition().duration(200).call(arcTween, twoPi * newVal / scope.duration);
          text.text(newVal);
        }
      });
    }
  };
});
