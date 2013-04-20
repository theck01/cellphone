
/* array helper function*/
function newArray(value, length) {
  var ary = []
  while (length--) {
    ary[length] = value;
  }
  return ary;
}


/* page wide access to most recent chart data */

/* JQuery variables for DOM */
var $chart;
var $cell_img;
var $cell_img_path;
var $state_header;
var $time_left_header;

/* histogram variables */
var histogram = newArray(0,256);
var average_intensity = 128;
var threshold = 128;


function sizeChart(){
  $chart.height($chart.width()*0.75);
}


function updateChart(){

  x_labels = newArray("", 256);
  for(var i=0; i<256; i+=50) x_labels[i] = i.toString();

  $chart.highcharts({
    chart: { 
      type: 'column',
      zoomType: 'xy'
    },
    plotOptions: { 
      column: {
        pointPadding: 0, borderWidth:0, groupPadding: 0, shadow: false
      }
    },
    title: { text: 'Fluorescence Intensity' },
    xAxis: { 
      categories: x_labels,
      plotBands: [
      { 
        color: 'red', 
        from : threshold.toString(),
        to: (threshold+1).toString(),
        label: { 
          text: 'Threshold = ' + threshold, 
          rotation: 270, 
          x: 15,
          y: 100
        }
      },
      { 
        color: 'orange', 
        from : average_intensity.toString(),
        to: (average_intensity+1).toString(),
        label: { 
          text: 'Average Intensity', 
          rotation: 270, 
          x: 15,
          y: 100
        }
      }]
    },
    yAxis: { title: { text: "Normalized Intensity" } },
    series: [{ name: 'Current Image', data: histogram }],
    legend: { enabled: false }
  });
}


function updateData() {

  /* request and update most recent img path from server */
  $.ajax({
    url: '/api/recent_img', 
    dataType: 'json', 
    success: function (data) {
      var img_path = data['path'];
      $cell_img.attr("src", img_path);
    }
  });

  /* request and update settings from server */
  $.ajax({
    url: '/api/settings',
    dataType: 'json',
    success: function (data) {
      threshold = data['threshold'];
    }
  });

  /* request and update image histogram from server */
  sizeChart();
  $.ajax({
    url: '/api/histogram', 
    dataType: 'json', 
    success: function (data) {
      histogram = data['histogram'];
      average_intensity = data['average'];
      updateChart();
    }
  });

  updateStatus();
}


/* request and update status and time left */
function updateStatus() {
  $.ajax({
    url: '/api/state',
    dataType: 'json',
    success: function (data) {
      var state = data['state'];
      var hours = data['hours_left'];
      var minutes = data['minutes_left'];
      console.log(data);

      $state_header.text('Status: ' + state);
      minutes_str = (minutes < 10 ? '0' : '') + minutes;
      $time_left_header.text("Time Left: " + hours + "h" + minutes_str + "m");
    }
  });
}


function manualDose() {
  $.ajax({
    url: '/api/manual_dose',
    type: 'POST',
    async: false
  });
  updateStatus();
}


$(function () {
  $chart = $("#chart");
  $cell_img = $("#cell_img");
  $state_header = $("#state");
  $time_left_header = $("#time_left");

  updateData();
  setInterval(updateData, 7500);
});


$(window).resize(function (event){
  sizeChart();
  updateChart();
});
