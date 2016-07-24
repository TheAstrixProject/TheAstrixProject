$(document).ready(function(){
  $('#info').mouseenter(function(){
    $(this).animate({
      height: '+=60'
    },500,function(){
      $(this).append("<a href='index.html'><h3 class='dropdown'>How To Play</h3></a>" +
      "<a href='team.html'><h3 class='dropdown'>The Designers</h3></a>" +
      "<a href='index.html'><h3 class='dropdown'>Changelog</h3></a>");
    });
  });
  $('.tabs').mouseleave(function(){
    $('.dropdown').remove();
    $(this).animate({
      height: '-=60'
    },500,function(){});
  });
  $('.header h1').offset({ top: 20, left: 20 })
  var $header = $('#header');
  var initialLeft = $header.offset().left;
  var initialTop = $header.offset().top;
  $(document).scroll(function(){
    var newTop = $(this).scrollTop();
    $('#header').offset({ top: newTop, left: initialLeft})
  })
  $('*').mouseenter(function(){
    console.log(this);
  })
});
