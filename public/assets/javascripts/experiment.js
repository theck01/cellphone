
$(function () {

  var $cell_img = $("#cell_img");
  var $cell_img_path = $("#cell_img_path");

  setInterval(function () {

    var img_path;

    /* request most recent img path from server */
    $.ajax({
      async: false, 
      url: '/recent_img', 
      dataType: 'json', 
      success: function (data) {
        img_path = data['path'];
        $.each(data, function (key, val) {
          console.log('Key: ' + key + ', Value: ' + val);
        });
        console.log(data);
        console.log(data.path);
      }
    });

    $cell_img.attr("src", img_path);
    $cell_img_path.text(img_path);
    console.log('Loaded image ' + img_path);
  }, 7500);
});

