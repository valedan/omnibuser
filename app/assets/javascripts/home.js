// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready(function() {
  clearFeedback();
  enableInput();
  $("#q").val("");
  $("#request_form").on("ajax:success", function(e, data, status, xhr){
    clearFeedback();
    disableInput();
    startQueries(xhr);
  }).on("ajax:error", function(e, xhr, status, error){
    updateErrors(xhr.responseJSON.status);
  })

});


function startQueries(request) {
  var request = jQuery.parseJSON(request.responseText);
  initializeProgress();
  $.ajax({
    url: '/scrape/' + request.id,
    type: "POST",
    dataType: "json"
  }).done(function(id){

  }).fail(function(jqXHR, textStatus, errorThrown){
  });
  var interval = 2000;
  function checkStatus() {
    $.ajax({
      type: 'GET',
      url: '/requests/' + request.id,
      dataType: 'json'
    }).always(function(request, status){
      if (request.complete !== true) {
        if (request.current_chapters === null || request.total_chapters === null) {
        } else {
          updateProgress(request.current_chapters, request.total_chapters);
        }
        setTimeout(checkStatus, interval);
      } else{
        if (request.status == "Success") {
          enableInput();
          updateDownload(request.aws_url);
        } else{
          enableInput();
          updateErrors(request.status);
        }
      }
    });
  }
  setTimeout(checkStatus, interval);
}

function disableInput(){
  $("#submit").hide();
  $("input").prop("disabled", true);
}

function enableInput(){
  $("input").prop("disabled", false);
  $("#submit").show();
}

function clearFeedback(){
  $("#download").hide();
  $("#error-explanation").hide();
  $("#progressbar").hide();
  $("#error-container").empty();
  $("#download").empty();

}
function updateErrors(html){
  $("#download").hide();
  $("#progressbar").hide();
  $("#error-container").empty();
  $("#error-container").append("<span>error: </span> <p>" + html + "</p>");
  $("#error-explanation").show();
}
function updateDownload(aws_url){
  $("#error-explanation").hide();
  $("#progressbar").hide();
  $("#download").empty();
  $("#download").append("<a download class='button' id='downloadLink' href='" + aws_url + "'> Download Ebook </a>");
  $("#download").show();
}

function initializeProgress(){
  $("#error-explanation").hide();
  $("#download").hide();
  $(".progress-label").text( "Loading..." );
  $("#progressbar").show();


  $( "#progressbar" ).progressbar({
    value: false,
    change: function() {
      if ($( "#progressbar" ).progressbar( "value" ) !== false) {
        $( ".progress-label" ).text( $( "#progressbar" ).progressbar( "value" ) + "/" + $( "#progressbar" ).progressbar( "option", "max" ) );
      }

    },
    complete: function() {
      $( ".progress-label" ).text( "Creating Ebook..." );
    }
  });
}

function updateProgress(current, total){
  $( "#progressbar" ).progressbar( "option", "max", total );
  $( "#progressbar" ).progressbar( "value", current );

}
