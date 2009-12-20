var countdown = {
	init: function() {
  	countdown.remaining = countdown.max - $(countdown.obj).val().length;
  	if (countdown.remaining > countdown.max) {
  		$(countdown.obj).val($(countdown.obj).val().substring(0,countdown.max));
  	}
  	$(countdown.obj).siblings(".remaining").html(countdown.remaining + " characters remaining.");
 	},
	max: null,
  remaining: null,
  obj: null
};

$(document).ready(function(){					
  //REST links
  $(".restLink").each(function() {
    var klass = $(this).attr("class");
    var method = klass.split(" ")[klass.split(" ").length - 1];
    
    $(this).click(function() {
      var f = document.createElement('form');
      f.style.display = 'none'; 
      this.parentNode.appendChild(f); 
      f.method = 'POST'; 
      f.action = this.href;
      var m = document.createElement('input'); 
      m.setAttribute('type', 'hidden'); 
      m.setAttribute('name', '_method');
      m.setAttribute('value', method); 
      f.appendChild(m);
      f.submit(); 
      return false;
    });       
  });
                  
	//CountDown								
	$(".countdown").each(function() {
    $(this).focus(function() {
    	var c = $(this).attr("class");
      countdown.max = parseInt(c.match(/limit_[0-9]{1,}_/)[0].match(/[0-9]{1,}/)[0]);
      countdown.obj = this;
      iCount = setInterval(countdown.init,500);
    }).blur(function() {
        countdown.init();
        clearInterval(iCount);
    });
	});
});

