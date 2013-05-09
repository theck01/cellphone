
/* array helper function*/
function newArray(value, length) {
  var ary = []
  while (length--) {
    ary[length] = value;
  }
  return ary;
}


/* JQuery variables for DOM updates */
var $chart;
var $cell_img;
var $logarea;
var $note_field;
var $pause_button;
var $resume_button;
var $state_header;
var $time_left_header;

/* histogram variables */
var histogram = newArray(0,256);
var average_intensity = 128;
var threshold = 128;


/* send pause request to server and update affected elements */
function pauseExperiment() {
  $.ajax({
    url: '/api/pause',
    type: 'POST',
    async: false
  });
  $pause_button.replaceWith($resume_button);
  updateStatus();
}


/* send resume request to server and update affected elements */
function resumeExperiment() {
  $.ajax({
    url: '/api/resume',
    type: 'POST',
    async: false
  });
  $resume_button.replaceWith($pause_button);
  updateStatus();
}

/* send a user note to the server and update logs */
function sendNote(){
  var note = $note_field.val();
  $.ajax({
    url: '/api/note',
    type: 'POST',
    async: false,
    data: { note: note }
  });
  $note_field.val('');
  updateLogs();
}


/* resize the chart to current page size */
function sizeChart(){
  $chart.height($chart.width()*0.75);
}


/* resize the logging area to current page size */
function sizeLogArea(){
  var font_size = parseInt($logarea.css('font-size').match(/\d+/g));
  var rows = Math.round(($logarea.width()*0.6)/font_size);
  $logarea.attr('rows', rows);
}

/* update the contents of the chart */
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
          y: 60
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
          y: 60
        }
      }]
    },
    yAxis: { title: { text: "Normalized Intensity" } },
    series: [{ name: 'Current Image', data: histogram }],
    legend: { enabled: false }
  });
}


/* request refresh for most elements on the page */
function updateData() {

  /* request and update settings from server */
  $.ajax({
    url: '/api/settings',
    async: 'false',
    dataType: 'json',
    success: function (data) {
      threshold = data['threshold'];
    }
  });

  /* request and update most recent img path from server */
  $.ajax({
    url: '/api/recent_img', 
    dataType: 'json', 
    success: function (data) {
      var img_path = data['path'];
      $cell_img.attr("src", img_path);
    }
  });

  /* request and update image histogram from server */
  $.ajax({
    url: '/api/histogram', 
    dataType: 'json', 
    success: function (data) {
      histogram = data['histogram'];
      average_intensity = data['average'];
      updateChart();
    }
  });

  updateLogs();
  updateStatus();
}


/* request and display logs up to this point */
function updateLogs() {
  $.ajax({
    url: '/api/logs',
    dataType: 'text',
    success: function (data) {
      console.log(data);
      $logarea.val(data);
    }
  });
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

      $state_header.text('Status: ' + state);
      minutes_str = (minutes < 10 ? '0' : '') + minutes;
      $time_left_header.text("Time Left: " + hours + "h" + minutes_str + "m");
    }
  });
}


/* manually set a dose on the server and update affected fields */
function manualDose() {
  $.ajax({
    url: '/api/manual_dose',
    type: 'POST',
    async: false
  });
  updateLogs();
  updateStatus();
}


$(function () {
  $chart = $("#chart");
  $cell_img = $("#cell_img");
  $logarea = $("#logarea");
  $note_field = $("#note_field");
  $pause_button = $("#pause_button");
  $resume_button = $("#resume_button");
  $state_header = $("#state");
  $time_left_header = $("#time_left");

  $.ajax({
    url: '/api/state',
    dataType: 'json',
    success: function (data) {
      if(data['paused'] == 'true')
        $pause_button.detach();
      else
        $resume_button.detach();
    }
  });

  sizeChart();
  sizeLogArea();
  updateData();
  setInterval(updateData, 7500);
});


$(window).resize(function (event){
  sizeChart();
  sizeLogArea();
  updateData();
});
