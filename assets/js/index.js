let c = new Candy();

window.onload = function () {

  c.createCanvas(200, 200);
  c.fullScreen();
  
  let osc = c.createScreenBuffer('trails');

  let pattern = new CirclePattern();

  pattern.add(100, 0.03, rgba(255, 0, 0, 0.2));
  //biru 
  pattern.add(150, 0.08, rgb(40,134,229));
  //Merah
  pattern.add(10, 0.2, rgba(255,0,0,0.5));
  // ijo
  pattern.add(250, -0.005, rgba(0,255,115,0.2)); 
  // pattern.add(250, -0.005, rgb(113, 255, 0));

  osc.strokeWeight(0.5);
  animate();
    
  function animate() {

    c.clear('#171717');

    pattern.update();
    pattern.render(osc);      


    c.loop(animate);
  }
}