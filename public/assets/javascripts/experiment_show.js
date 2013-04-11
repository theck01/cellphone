
/* array helper function*/
function newArray(value, length) {
  var ary = []
  while (length--) {
    ary[length] = value;
  }
  return ary;
}

/* page wide access to most recent chart data */
var $chart;
var histogram = newArray(0,256);
var hist_step = 0.025;


function updateChart(){

  /* update chart size */
  $chart.height($histogram.width());

  var context = $chart.get(0).getContext("2d");
  var new_chart = new Chart(context);

  var labels = 
  var chart_options = {
    scaleOverride: true,
    scaleSteps: 10,
    scaleStepWidth: hist_step,
    barValueSpacing: 0,
    barDatasetSpacing: 0,
  };


  var chart_data = {
    labels: [],
    datasets: [{
      fillColor: "rgba(151,187,205,0.5)",
      strokeColor: "rgba(151,187,205,0.5)",
      data: histogram
    }]
  }
}

  
$(function () {

  var $cell_img = $("#cell_img");
  var $cell_img_path = $("#cell_img_path");
  var histogram = $("#histogram").get(0)

  setInterval(function () {

    var img_path;

    /* request and update most recent img path from server */
    $.ajax({
      async: false, 
      url: '/api/recent_img', 
      dataType: 'json', 
      success: function (data) {
        img_path = data['path'];
        $cell_img.attr("src", img_path);
        $cell_img_path.text(img_path);
        console.log('New image: ' + img_path);
      }
    });

    /* request and update image histogram from server */
    $.ajax({
      async: false, 
      url: '/api/histogram', 
      dataType: 'json', 
      success: function (data) {
        histogram = data['histogram'];


        console.log('Updated chart with data: ' + histogram);
      }
    });
  }, 7500);
});


$(window).resize();

