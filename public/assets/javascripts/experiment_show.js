
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
var $cell_img;
var $cell_img_path;
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


function requestData() {
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
    }
  });

  /* request and update image histogram from server */
  $.ajax({
    async: false, 
    url: '/api/histogram', 
    dataType: 'json', 
    success: function (data) {
      histogram = data['histogram'];
      average_intensity = data['average'];
      updateChart();
    }
  });
}

  
function manualDose() {
  $.post('/api/manual_dose');
}


$(function () {
  $chart = $("#chart");
  $cell_img = $("#cell_img");
  $cell_img_path = $("#cell_img_path");

  // retrieve threshold from server
  $.ajax({
    async: false,
    url: '/api/settings', 
    dataType: 'json',
    success: function (data) {
      threshold = data['threshold'];
    }
  });

  sizeChart();
  requestData();
  setInterval(requestData, 7500);
});


$(window).resize(function (event){
  sizeChart();
  updateChart();
});
