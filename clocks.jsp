<html>
	<head>
		<title>Clocks</title>
		<script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
		<script src="impDate.js"></script>
		<script>
			/* Based on w3Schools tutorial: http://www.w3schools.com/canvas/default.asp */
			var ctx;
			var radius;
			var clocks = {};
			var selClock;
			
			$(document).ready(function() {
				$.ajax({
					url: "clocks.json",
					dataType: "json",
					async: false,
					cache: false,
					success: function(json) {
						$.each(json.types, function(idx, type) {
							clocks[type.type] = type;
							
							$("#clockSelect").append($("<option />").val(type.type).text(type.name));
						});
					}
				});
				
				var winHeight = window.innerHeight * 0.9;
				var winWidth = window.innerWidth;
				var size;
				
				/*if($.urlParam("clock") != null) {
					$("#clockSelect option").val($.urlParam("clock"));
				}*/
				
				if(winHeight < winWidth) {
					size = winHeight;
				} else {
					size = winWidth;
				}
				
				var canvas = $("#clocks")[0];
				ctx = canvas.getContext("2d");
				
				ctx.canvas.width = size;
				ctx.canvas.height = size;
				
				radius = canvas.height / 2;
				ctx.translate(radius, radius);
				radius = radius * 0.90
				
				setInterval(drawClock, 100);
			});
			
			function drawClock() {
				selClock = clocks[$("#clockSelect").val()];
				
				drawFace(ctx, radius);
				drawNumbers(ctx, radius);
				drawTime(ctx, radius);
			}

			function drawFace(ctx, radius) {
				var grad;

				ctx.beginPath();
				ctx.arc(0, 0, radius, 0, 2*Math.PI);
				ctx.fillStyle = 'white';
				ctx.fill();

				ctx.beginPath();
				ctx.arc(0, 0, radius*0.1, 0, 2*Math.PI);
				ctx.fillStyle = '#333';
				ctx.fill();
			}
			
			function drawNumbers(ctx, radius) {
				var ang;
				var num;
				ctx.font = radius*0.15 + "px arial";
				ctx.textBaseline="middle";
				ctx.textAlign="center";
				
				for(num = 1; num <= selClock.maxNum; num++) {
					drawNum(num, (selClock.maxNum / 2));
				}
			}
			
			function drawNum(num, dist) {
				ang = num * Math.PI / dist;
				ctx.rotate(ang);
				ctx.translate(0, -radius*0.85);
				ctx.rotate(-ang);
				ctx.fillText(num.toString(), 0, 0);
				ctx.rotate(ang);
				ctx.translate(0, radius*0.85);
				ctx.rotate(-ang);
			}
			
			function drawTime(ctx, radius){
				var now;
        $("#debug").html("");
				switch(selClock.source) {
					case "standard":
						var dt = new Date();
            //$("#debug").html(dt.getHours() + ":" + dt.getMinutes() + ":" + dt.getSeconds() + "<br/>");
						now = dt.getSeconds();
						now += dt.getMinutes() * 60;
						now += dt.getHours() * 3600;
						//now += dt.getMilliseconds() / 1000;
						break;
					case "decimal":
						now = new Date().getImpYearFracTime();
						break;
				}
				
				//for(var i = 0; i < 3; i++) {
        $.each(selClock.hands, function(idx, val) {
          var itemp = (selClock.hands.length - 1) - idx;
          
          if(itemp == 0) {
            itemp++;
          }
          
          var power = Math.pow(val, itemp);
					var nowTemp = (now / power);
					drawHand(ctx, nowTemp * Math.PI / (selClock.maxNum / 2), radius * (0.5 + (0.2 * idx)), radius * (0.07 - (0.02 * idx)));
					
          //$("#debug").html($("#debug").html() + nowTemp + " | " + now + "<br/>");
					now %= power;
				});
				
				/*if($("#clockSelect").val() == "standard") {
					var now = new Date();
					var hour = now.getHours();
					var minute = now.getMinutes();
					var second = now.getSeconds();
					//hour
					hour=hour%12;
					hour=(hour*Math.PI/6)+(minute*Math.PI/(6*60))+(second*Math.PI/(360*60));
					drawHand(ctx, hour, radius*0.5, radius*0.07);
					//minute
					minute=(minute*Math.PI/30)+(second*Math.PI/(30*60));
					drawHand(ctx, minute, radius*0.8, radius*0.07);
					// second
					second=(second*Math.PI/30);
					drawHand(ctx, second, radius*0.9, radius*0.02);
				} else if ($("#clockSelect").val() == "imperial") {
					var now = new Date().getImpYearFracTime();
					$("#impOut").html("");
					$("#impOut").html("" + now);
					
					for(var i = 0; i < 3; i++) {
						var nowTemp = now / Math.pow(10,(2 - i));
						drawHand(ctx, nowTemp * Math.PI / 5, radius * (0.5 + (0.2 * i)), radius * (0.07 - (0.02 * i)));
						
						now %= Math.pow(10,(2 - i));
					}
				}*/
			}

			function drawHand(ctx, pos, length, width) {
        if(length > radius) {
          length = radius * 0.99;
        }
        
				ctx.beginPath();
				ctx.lineWidth = width;
				ctx.lineCap = "round";
				ctx.moveTo(0,0);
				ctx.rotate(pos);
				ctx.lineTo(0, -length);
				ctx.stroke();
				ctx.rotate(-pos);
			}
			
			$.urlParam = function(name){
				var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
				if (results==null){
				   return null;
				}
				else{
				   return results[1] || 0;
				}
			}
		</script>
		<style>
			div {
				width: 100%;
			}
			
			#selectDiv {
				height: 5%;
			}
			
			#clockDiv {
				height: 90%;
			}
			
			canvas {
				background-color: #333;
			}
		</style>
	</head>
	<body>
		<div id="selectDiv">
			<select id="clockSelect">
			</select>
		</div>
    <div id="debug"></div>
		<canvas id="clocks" width="100" height="100"></canvas>
	</body>
</html>
