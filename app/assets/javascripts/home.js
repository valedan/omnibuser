// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready(function() {
  console.log("ready fired");
  clearFeedback();
  enableInput();
  $("#q").val("");
  $("#request_form").on("ajax:success", function(e, data, status, xhr){
    console.log("request success triggered");
    console.log(e);
    console.log(data);
    console.log(status);
    console.log(xhr);
    clearFeedback();
    disableInput();
    startQueries(xhr);
  }).on("ajax:error", function(e, xhr, status, error){
    console.log("request fail triggered");
    console.log(e);
    console.log(xhr);
    console.log(status);
    console.log(error);
  })
});


function startQueries(request) {
  var request = jQuery.parseJSON(request.responseText);
  console.log(request);
  console.log(request.id);
  initializeProgress();
  $.ajax({
    url: '/scrape/' + request.id,
    type: "POST",
    dataType: "json"
  }).done(function(id){
    enableInput();
    updateDownload(id);
  }).fail(function(jqXHR, textStatus, errorThrown){
    //updateErrors("Sorry, something went wrong. Please try again.");
    console.log("ajax fail results");
    console.log(jqXHR);
    console.log(textStatus);
    console.log(errorThrown);
  });
  var interval = 1000;
  function checkStatus() {
    $.ajax({
      type: 'GET',
      url: '/requests/' + request.id,
      dataType: 'json'
    }).always(function(request, status){
      console.log(request);
      console.log(request.complete);
      if (request.complete !== true) {
        if (request.current_chapters === null || request.total_chapters === null) {
        } else {
          updateProgress(request.current_chapters, request.total_chapters);
        }
        setTimeout(checkStatus, interval);
      } else{
        if (request.status !== "Success") {
          enableInput();
          updateErrors(request.status);
        }
      }
    });
  }
  setTimeout(checkStatus, interval);
}

// $(function() {
//   $("#download").on("click", "a", function(e) {
//     e.preventDefault();
//     console.log(this);
//     console.log(this.href);
//     $.post(this.href);
//   });
// });

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
function updateDownload(id){
  $("#error-explanation").hide();
  $("#progressbar").hide();
  $("#download").empty();
  var href = location.origin + "/documents/" + id;
  $("#download").append("<a class='button' id='downloadLink' href='" + href + "'> Download Ebook </a>");
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
      $( ".progress-label" ).text( "Complete!" );
    }
  });
}

function updateProgress(current, total){
  $( "#progressbar" ).progressbar( "option", "max", total );
  $( "#progressbar" ).progressbar( "value", current );

}
