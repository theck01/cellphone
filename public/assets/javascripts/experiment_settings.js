function valuePresent (input) {
  if(input == null || input == "") return false;
  return true;
}

function floatCheck (input) {
  if(!valuePresent(input)) return false;

  var val = parseFloat(input);

  if(isNaN(val)) return false;
  if(val < 0) return false;

  return true;
}

function intCheck (input) {
  if(!valuePresent(input)) return false;

  var val = parseFloat(input);

  if(isNaN(val)) return false;
  if(val < 0) return false;
  if(Math.floor(val) != val) return false;

  return true;
}

function minutesCheck (input) {
  if(!valuePresent(input)) return false;

  var val = parseFloat(input);

  if(isNaN(val)) return false;
  if(Math.floor(val) != val) return false;
  if(val < 0) return false;
  if(val > 59) return false;

  return true;
}


function validateSettings() {
  var dosage_check = floatCheck($('#dosage_field').val());
  var hours_check = intCheck($('#hours_field').val());
  var minutes_check = minutesCheck($('#minutes_field').val());
  var threshold_check = intCheck($('#threshold_field').val());

  if(!dosage_check){
    alert("The dosage field must contain a positive decimal value");
    return false;
  }
  if(!hours_check){
    alert("The hours field must contain a positive integer value");
    return false;
  }
  if(!minutes_check){
    alert("The minutes field must contain a positive integer between 0 and 59");
    return false;
  }
  if(!threshold_check){
    alert("The threshold field must contain a positive integer value");
    return false;
  }

  return true;
}

$(function () {
  $.getJSON('/api/settings', function (data) {
    $('#dosage_field').val(data['dosage']);
    $('#hours_field').val(data['hours']);
    $('#minutes_field').val(data['minutes']);
    $('#threshold_field').val(data['threshold']);
    $("#size"+data['syringe']).attr('checked', 'checked');
  });
});
