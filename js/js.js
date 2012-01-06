if (document.location.host == 'benubois.github.com' || document.location.host == 'benubois.com') {
	window.location = 'http://subscribeapp.com'
}
window.subscribe = {};
subscribe.init = {
	trackLink: function () {
		$('.ga-track').on('click', function (e) {
			_gaq._trackEvent('Outbound Links', $(this).prop('href'));
			setTimeout(function () {
				
				// document.location = $(this).prop('href');
			}, 100);
			return false;
		});
	}
}
$(document).ready(function() {
	$.each(subscribe.init, 
		function(i,item) {
			item();
		}
	);
});