height = 12;
thickness = 1.0;
tabHeight = 3.8;
tabThickness = 0.8;
tabHoleDiameter = 4.2;
depth = 10.3;

module up(n) {
  translate([0, 0, n]) children();
};

module down(n) {
  translate([0, 0, -n]) children();
};

module donut(height, thickness, d) {
  difference() {
    cylinder(height, d=d);
    translate([0, 0, -1])
    cylinder(height + 2, d=d - thickness * 2);
  }
}

module prism(l, w, h){
  polyhedron(
    points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
    faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
  );
}

module drawBody() {
  difference() {
    union() {
      // pointer
      hull() {
        translate([0, -0.25, height])
        cube([5.0, 0.5, 0.5]);

        translate([0, -0.25, 0])
        cube([5.5, 0.5, 1]);
      }

      // body
      difference() {
        cylinder(height, d1=10, d2=9);

        // decoration
        t = 0.2;
        translate([0, 0, height - t - 0.1])
        donut(t + 0.2, thickness, d=9.05);
      }
    };

    // hole
    translate([0, 0, -1])
    cylinder(depth + 1, d1=8, d2=7.5);
  }
}

module drawTab() {
  difference() {
    translate([0, 0, depth - tabHeight])
    cylinder(tabHeight + thickness / 2, d=tabHoleDiameter + tabThickness * 2);

    translate([0, 0, -1])
    cylinder(100, d=tabHoleDiameter);

    translate([-3.1, -0.8, depth - tabHeight - 1])
    cube([6.2, 1.6, tabHeight + 2]);

    translate([0, 0, depth - 2.5])
    cylinder(0.4, d=4.5);
  }
}

module drawKnob() {
  difference() {
    union() {
      drawBody();

      rotate(90)
      drawTab();
    }

    for (n=[1:17]) {
      rotate(360 / 18 * n)
      hull() {
        translate([5 - 0.1, 0, 1.8])
        cube([0.4, 0.7, 0.1], true);
        translate([4.5 - 0.1, 0, height])
        cube([0.2, 0.7, 0.1], true);
      };
    };
  }
}

module drawConnect(fudge) {
  rotate(90)
  union() {
    // translate([0, 0, depth - tabHeight - 1])
    // cylinder(1, d1=7.5 - fudge, d2=tabHoleDiameter);
    // cylinder(depth - tabHeight - 1, d=7.5 - fudge);

    // tabHoleDiameter = 4.2
    translate([0, 0, depth - tabHeight])
    cylinder(tabHeight - fudge, d=tabHoleDiameter-fudge);

    translate([-3.1 + fudge / 2, -0.8 + fudge / 2, 0])
    cube([6.2 - fudge, 1.6 - fudge, depth - fudge]);

    translate([0, 0, depth - 2.5])
    cylinder(0.4, d=4.5 - fudge);
  };
}

module shellBase() {
  down = 3;

  up(3 - down) cylinder(5, d=6.5);

  up(7 - down) cylinder(6.5, d1=7.5, d2=7.0);

  up(3.7) drawConnect(fudge=0.2);
};

module grayShell() {
  height = 17;
  cylinder(1, d=6.2);

  up(1) difference() {
    d = 9.2;
    fudge = 0.01;
    height = 2;
    cylinder(height, d=d);
    translate([d / 2 - 0.8, -5, -fudge]) cube([5, 10, height / 2 + fudge]);
  };

  up(3) shellBase();
};

module grayShaft() {
  height = 17;
  innerDepth = 10;
  stopDepth = 5;

  difference() {
    grayShell();
    down(1) cylinder(innerDepth + 1, d=3.4);
  };

  fudge = 0.2;
  d = 1.2;
  r = d / 2;
  translate([0, 1.7, stopDepth + r - fudge])
  rotate([90, 0, 0])
  translate([1.7 + r - 1.2, 0, 0])
  cylinder(3.4, d=d);
};

module halfCylinder(height, d) {
  difference() {
    cylinder(height, d=d);
    translate([-d/2, -d, -1]) cube([d, d, height + 2]);
  };
}

module whiteShaft() {
  height = 22.2;
  shellBaseHeight = 14.0;
  platformH = 8.2;
  platformD = 9.1; // 9.0 ~ 9.2
  platformT = 2.2;
  innerDepth = 17.0;
  innerD= (platformD - platformT * 2);
  innerR= innerD/2;
  stopDepth = 4.1; // 4.0 ~ 4.2
  cutAxelW = 3.1; // 3.0 ~ 3.2

  assert(height - shellBaseHeight == platformH);
  assert(innerD >= 4.2);

  rotate(90) difference() {
    union() {
      up(height - shellBaseHeight) shellBase();
      cylinder(platformH, d=platformD);
    };

    down(1) cylinder(innerDepth + 1, d=innerD);

    fudge = 0.2;
    translate([platformD / 2 - 0.8, -4, -fudge])
    cube([1, 8, 0.8 + fudge]);
  };

  w = innerD - cutAxelW;
  translate([0, innerR, stopDepth])
  rotate([0, 180, 0])
  translate([-innerR, -w, -1])
  prism(innerD, w, 1);

  translate([0, cutAxelW - innerR, stopDepth + 1])
  halfCylinder(innerDepth - stopDepth - 0.99, d=innerD);
};

$fs = 0.05;

translate([-10, 0, 0]) {
  color("tan") drawKnob();
};

translate([0, 10, 0]) {
  color("gray") grayShaft();
};

translate([0, -10, 0]) {
  color("white") rotate(-90) whiteShaft();
};
