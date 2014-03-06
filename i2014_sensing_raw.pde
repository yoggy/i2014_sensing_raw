import java.util.Vector;

float speed = 100;
int history = 5000;

int fire_counter = 0;

Table csv;
int current_idx = 0;
LineChart line_chart_s;
LineChart line_chart_t;
AnalogClock clock;

void setup() {
  size(800, 400);
  csv = loadTable("data.csv");
  line_chart_s = new LineChart(history, #00ff00);
  line_chart_t = new LineChart(history, #ff0000);
  clock = new AnalogClock(50, 50, 40);
  
  background(0, 0, 0);
}

void draw() {
  int s, t = 0;
  for (int i = 0; i < speed; ++i) {
    TableRow row = csv.getRow(current_idx);

    s = row.getInt(0);
    t = row.getInt(1);

    line_chart_s.add(s);
    line_chart_t.add(t);

    if (t < s) fire();

    current_idx ++;
    if (csv.getRowCount() <= current_idx) {
      println("loop");
      current_idx = 0;
    }
  }

  fill(0, 100 * fire_counter / 30, 100 * fire_counter / 30);
  rect(0, 0, width, height);
  
  line_chart_s.draw();
  line_chart_t.draw();

  draw_clock();
  
  if (fire_counter > 0) {
    fire_counter --;
  }
}

void draw_clock() {
  fill(#00ff00);
  int base = 13 * 60 * 60;
  int t = base + current_idx / 30;

  int h = t / 60 / 60;
  int m = (t / 60 - h * 60);
  int s = t - h * 60 * 60 - m * 60;

  clock.draw(h, m, s);
}

void fire() {
  fire_counter = 30;
}

class LineChart {
  Vector vals = new Vector();
  int max_size = 1024;
  color c;

  LineChart(int size) {
    max_size = size;
    c = #00ff00;
  }

  LineChart(int size, color c) {
    max_size = size;
    this.c = c;
  }

  int get(int idx) {
    return ((Integer)vals.get(idx)).intValue();
  }

  void add(int val) {
    vals.add(val);
    if (vals.size() > max_size) {
      vals.remove(0);
      vals.trimToSize();
    }
  }

  void draw() {
    noFill();
    stroke(this.c);
    strokeWeight(1);
    float step_x = width / (float)(max_size);
    float step_y =  (height / 1024.0);
    for (int i = 0; i < vals.size() - 1; ++i) {    
      float x0 = (i  ) * step_x;
      float x1 = (i+1) * step_x;
      float y0 = ((Integer)vals.get(i  )).intValue() * step_y;
      float y1 = ((Integer)vals.get(i+1)).intValue() * step_y;
      line(x0, y0, x1, y1);
    }
  }

  int max_val(int n) {
    int max_val = 0;
    int st = vals.size() - n;
    if (st < 0) st = 0;
    int et = vals.size() - 1;
    for (int i = st; i <= et; ++i) {
      int v = (Integer)vals.get(i);
      if (v > max_val) max_val = v;
    }
    return max_val;
  }
}

class AnalogClock {
  public PVector center = new PVector(50, 50);
  public int radius = 20;

  AnalogClock(int x, int y, int radius) {
    this.center = new PVector(x, y);
    this.radius = radius;
  }
  
  void draw_clock_line(float s, float e, float angle) {
    float vx = sin(angle * 2 * PI);
    float vy = -cos(angle * 2 * PI);
    float sp_x = center.x + s * radius * vx;
    float sp_y = center.y + s * radius * vy;
    float ep_x = center.x + e * radius * vx;
    float ep_y = center.y + e * radius * vy;
    line(sp_x, sp_y, ep_x, ep_y);
  }

  void draw(int h, int m, int s) {
    stroke(#00ff00);
    noFill();
    strokeWeight(4);
    ellipse(center.x, center.y, radius * 2, radius * 2);

    strokeWeight(4);
    for (int i = 0; i < 12; ++i) {
      draw_clock_line(0.9, 1.0, i / 12.0);
    }

    float angle_h = h / 12.0 + m / 12.0 /60.0;
    strokeWeight(4);
    draw_clock_line(0.0, 0.5, angle_h);

    float angle_m = m / 60.0 + s / 60.0 / 60.0;
    strokeWeight(3);
    draw_clock_line(0.0, 0.7, angle_m);

    float angle_s = s / 60.0;
    strokeWeight(2);
    draw_clock_line(0.0, 0.80, angle_s);
  }
}
