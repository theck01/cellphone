function valuePresent (input) {
  if(input == null || input == "") return false;
  return true;
}

function validateSetup() {
  var name_check = valuePresent($('#name_field').val());
  var title_check = valuePresent($('#title_field').val());
  var cell_check = valuePresent($('input:radio[name=cells]:checked').val());
  var dropper_check = valuePresent($('input:radio[name=dropper]:checked').val());
  
  if(!name_check){
    alert("The name field is required");
    return false;
  }
  if(!title_check){
    alert("The title field is required");
    return false;
  }
  if(!cell_check){
    alert("Make sure that the Leica Suite provides a good view of your cells and that the Leica Suite is shut down before continuing");
    return false;
  }
  if(!dropper_check){
    alert("Make sure that the dropper is placed in the proper position on the slide");
    return false;
  }

  return true;
}




