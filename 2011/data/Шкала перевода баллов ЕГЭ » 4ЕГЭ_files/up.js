$(document).ready(function() {
	
	$('body').append('<div class="rjrprk"><div class="button-up">▲ Наверх</div></div>');
		
	$ (window).scroll (function () {
		if ($ (this).scrollTop () > 300) {
			$ ('.button-up').fadeIn();
		} else {
			$ ('.button-up').fadeOut();
		}
	});
	
	$('.button-up').click(function(){
		$('body,html').animate({
            scrollTop: 0
        }, 100);
        return false;
	});
	
	$('.button-up').hover(function() {
			$(this).animate({
				'opacity':'1',
			}).css({'background-color':'#E1E7ED','color':'#45688E'});
		}, function(){
			$(this).animate({
				'opacity':'0.7'
			}).css({'background':'none','color':'#45688E'});;
	});
		
});