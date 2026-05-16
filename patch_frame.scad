// =============================================================================
// Finisher Patch Frame
// =============================================================================


// ========================== USER SETTINGS ==============================
/* [Output] */
//  Export the full frame, shell only, or loose front inlay to reduce filament changes
part = "frame"; // [frame,frame_shell,front_inlay]

/* [Patch Text] */
// Top text embossed above the patch opening (e.g. race date)
top_text = "";
// Bottom text embossed below the patch opening (e.g. finish time)
bottom_text = "";      

/* [Text Style] */
// Verify the exact font name in OpenSCAD Help -> Font List on the target system.
// Font used for both text lines
text_font  = "Oswald:style=Bold"; // ["Oswald:style=Bold","Barlow Semi Condensed:style=Bold","Barlow Condensed:style=Bold"]
// mm, letter height for the date line
date_size  = 8;                   
// mm, letter height for the finish-time line
time_size  = 11;
// mm, emboss height above the front inlay surface
text_raise = 1.0;

/* [Mounting Options] */
// Add a hidden keyhole hanger on the back for wall mounting
hanger_enabled     = true;
// Add hidden dovetail slots so frames can link side-to-side
connectors_enabled = false;

// ============================= HEXAGON — FLAT-TOP REGULAR ===================
// All dimensions derive from hex_side so the tile stays exactly regular.
/* [Overall Size] */
// mm, length of one outer hexagon side
hex_side     = 80;

// ================== PATCH (Size of HYROX 25/26 patches) =====================
// The patch is a tall rectangle (bounding box ~60 x 95 mm). We mount it in
// landscape orientation, so "patch width" is the long horizontal edge.
/* [Patch Pocket] */
// mm, patch width in the frame's landscape orientation
patch_w     = 95;
// mm, patch height in the frame's landscape orientation
patch_h     = 60;
// mm, extra fit clearance around the patch on each side
patch_tol   = 0.6;
// mm, pocket depth for the patch body
patch_depth = 2.4;

/* [Appearance] */
// Color for the shell, rim, and outer body
frame_body_color = "white";
 // Color for the recessed front inlay around the patch
frame_face_color = "black";

/* [Hidden] */
hex_width    = hex_side * 2;       // point-to-point
hex_height   = hex_side * sqrt(3); // flat-to-flat
hex_shoulder = hex_side / 2;       // point inset from the flats


// ========================== LAYER STACK ================================
// z = 0 is the wall side. Total frame thickness = body_thick + well_depth.
body_thick            = 5.0;                     // mm, solid back/body thickness
face_thick            = patch_depth + 1.0;       // Thickness of the separate front inlay layer
rim_lift              = 2.4;                     // mm, how far the outer frame stands above the face
well_depth            = face_thick + rim_lift;   // Total recess depth above the body
frame_total_thick     = body_thick + well_depth; // mm, overall frame thickness at the outer perimeter
rim_width             = 8;                       // mm, visible frame rim width from the outer edge inward
front_inlay_clearance = 0.15;                    // mm, glue-up clearance per side for the loose front inlay


// ============================= DOVETAIL CONNECTORS ===========================
conn_mouth_w         = 9;    // mm, narrow visible opening of each dovetail slot
conn_lock_w          = 13;   // mm, wider locking width deeper inside the frame
conn_depth           = 9;    // mm, inward reach of the dovetail slot
conn_tol             = 0.25; // mm, extra side clearance for connector fit
slot_mouth_overshoot = 0.3;  // mm, slight extension past the edge for a clean opening


// ============================= HANGER ========================================
hanger_d          = 8.0;  // mm, round clearance for the nail or screw head
hanger_shaft_d    = 2.8;  // mm, narrow slot width for the nail or screw shaft
hanger_drop       = 8;    // mm, downward travel from the round hole into the slot
hanger_y_off      = 26;   // mm, hole center offset down from the top flat
hanger_front_wall = 1.0;  // mm, material left between the hanger slot and the front face


// ============================= BOOLEAN TWEAKS ================================
bool_eps = 0.01; // mm, tiny overlap used to keep boolean cuts robust
conn_slot_h = body_thick - 0.8 + bool_eps; // mm, connector slot depth with a fixed front cover


// ============================= RENDER QUALITY ================================
$fa = 2;
$fs = 0.4;


// =============================================================================
// SANITY CHECKS
// =============================================================================

function is_valid_part(p) =
  p == "frame" ||
  p == "frame_shell" ||
  p == "front_inlay";

function face_inner_side(clearance = 0) =
  hex_side - 2 * (rim_width + clearance) / sqrt(3);
function face_inner_height(clearance = 0) =
  hex_height - 2 * (rim_width + clearance);
function face_inner_half_width_at_y(y, clearance = 0) =
  let(side = face_inner_side(clearance))
  side - abs(y) / sqrt(3);

module _sanity() {
  pocket_w = pocket_width();
  pocket_h = pocket_height();
  pocket_half_y = pocket_h / 2;
  min_face_half_w = face_inner_half_width_at_y(pocket_half_y, front_inlay_clearance);
  min_face_h = face_inner_height(front_inlay_clearance);
  hanger_top_margin = hanger_y_off - hanger_d / 2;
  hanger_top_slot_y = hex_height / 2 - hanger_y_off + hanger_drop;

  assert(is_valid_part(part),
      str("Unknown part '", part,
          "'. Use frame, frame_shell, or front_inlay."));
  assert(front_inlay_clearance >= 0,
      "front_inlay_clearance must be non-negative");
  assert(face_inner_side(front_inlay_clearance) > 0,
      "rim_width + front_inlay_clearance leaves no usable front inlay");
  assert(pocket_h < min_face_h,
      "patch pocket height exceeds the recessed face insert height");
  assert(pocket_w / 2 < min_face_half_w,
      "patch pocket reaches the sloped face edges; reduce patch size/tolerance or increase the usable face area");
  assert(conn_mouth_w + 2 * conn_tol < conn_lock_w,
      "dovetail mouth width too close to lock width — will not hold");
  assert(conn_depth > rim_width,
      "conn_depth must exceed rim_width so the slot reaches under the recessed face layer");
  assert(conn_mouth_w + 2 * conn_tol < hex_side,
      "dovetail mouth width exceeds the available edge length");
  assert(conn_lock_w + 2 * conn_tol < hex_side,
      "dovetail lock width too large for the hex side length");
  assert(hanger_front_wall >= 0 && hanger_front_wall < body_thick,
      "hanger_front_wall must stay non-negative and below body_thick");
  assert(hanger_top_margin > 0,
      "hanger hole breaches the top flat; increase hanger_y_off or reduce hanger_d");
  assert(hanger_top_slot_y < hex_height / 2,
      "hanger slot breaches the top flat; reduce hanger_drop or increase hanger_y_off");
  assert(face_thick > patch_depth,
      "face_thick must exceed patch_depth so the pocket stays inside the recessed face layer");
  assert(rim_lift > 0,
      "rim_lift must stay visibly positive so the outer frame stands proud of the face");
}
_sanity();


// =============================================================================
// 2D PRIMITIVES
// =============================================================================

// Corner order matches hex_shape(): CCW, flat-top, starting at the right point.
function hex_corners() = [
  [ hex_width / 2,  0             ],
  [ hex_shoulder,   hex_height / 2],
  [-hex_shoulder,   hex_height / 2],
  [-hex_width / 2,  0             ],
  [-hex_shoulder,  -hex_height / 2],
  [ hex_shoulder,  -hex_height / 2]
];

// Regular flat-top hexagon centred on the origin, with CCW winding.
module hex_shape() {
  polygon(hex_corners());
}

// Inset the hex by a perpendicular distance d.
module hex_inset(d) {
  offset(r = -d) hex_shape();
}

// Mouth sits on y = 0 and widens toward +y up to depth L.
module dovetail_profile(mouth, lock, depth) {
  polygon([
    [-mouth / 2, 0],
    [ mouth / 2, 0],
    [ lock / 2,  depth],
    [-lock / 2,  depth]
  ]);
}

// =============================================================================
// EDGE HELPERS
// =============================================================================

function edge_mid(p1, p2) = [
  (p1[0] + p2[0]) / 2,
  (p1[1] + p2[1]) / 2
];

// For a CCW polygon, the outward normal of edge p1→p2 is (dy, -dx).
function edge_outward_angle(p1, p2) =
  let(dx = p2[0] - p1[0], dy = p2[1] - p1[1])
  atan2(-dx, dy);

module on_edge(edge_i, offset = [0, 0, 0]) {
  corners = hex_corners();
  p1 = corners[edge_i];
  p2 = corners[(edge_i + 1) % 6];
  mid = edge_mid(p1, p2);
  ang = edge_outward_angle(p1, p2);

  translate(offset)
    translate([mid[0], mid[1], 0])
      rotate([0, 0, ang + 90])
        children();
}

// Slot shape cut into the frame body after the caller orients it to an edge.
module connector_slot_cutout() {
  translate([0, 0, -bool_eps])
    linear_extrude(height = conn_slot_h)
      translate([0, -slot_mouth_overshoot, 0])
        dovetail_profile(
          conn_mouth_w + 2 * conn_tol,
          conn_lock_w + 2 * conn_tol,
          conn_depth + slot_mouth_overshoot
        );
}

function connector_slot_mouth_w() = conn_mouth_w + 2 * conn_tol;
function connector_slot_lock_w() = conn_lock_w + 2 * conn_tol;
function connector_slot_depth() = conn_depth + slot_mouth_overshoot;
function connector_key_height() = conn_slot_h - bool_eps;
function connector_key_mouth_w(side_clearance = 0.04) =
  connector_slot_mouth_w() - 2 * side_clearance;
function connector_key_lock_w(side_clearance = 0.04) =
  connector_slot_lock_w() - 2 * side_clearance;
function connector_key_depth(end_clearance = 0.08) =
  connector_slot_depth() - end_clearance;

module connector_key_profile(side_clearance = 0.04, end_clearance = 0.08) {
  depth = connector_key_depth(end_clearance);

  assert(side_clearance >= 0,
      "connector side_clearance must be non-negative");
  assert(end_clearance >= 0,
      "connector end_clearance must be non-negative");
  assert(connector_key_mouth_w(side_clearance) > 0,
      "connector mouth width collapses; reduce side_clearance");
  assert(connector_key_lock_w(side_clearance) > connector_key_mouth_w(side_clearance),
      "connector lock width must stay wider than the mouth");
  assert(depth > 0,
      "connector depth collapses; reduce end_clearance");

  union() {
    dovetail_profile(
      connector_key_mouth_w(side_clearance),
      connector_key_lock_w(side_clearance),
      depth
    );

    mirror([0, 1, 0])
      dovetail_profile(
        connector_key_mouth_w(side_clearance),
        connector_key_lock_w(side_clearance),
        depth
      );
  }
}

module connector_key(
    side_clearance = 0.04,
    end_clearance = 0.08,
    lead_in = 0.25,
    key_color = frame_body_color) {
  key_h = connector_key_height();
  lead_h = min(lead_in, key_h);
  straight_h = key_h - lead_h;

  assert(key_h > 0,
      "connector key height must stay positive");
  assert(lead_in >= 0,
      "connector lead_in must be non-negative");
  assert(lead_h < connector_key_mouth_w(side_clearance) / 2,
      "connector lead_in is too large for the mouth width");
  assert(lead_h < connector_key_depth(end_clearance),
      "connector lead_in is too large for the key depth");

  color(key_color)
    union() {
      if (lead_h > 0)
        hull() {
          linear_extrude(height = bool_eps)
            offset(delta = -lead_h)
              connector_key_profile(side_clearance, end_clearance);

          translate([0, 0, lead_h - bool_eps])
            linear_extrude(height = bool_eps)
              connector_key_profile(side_clearance, end_clearance);
        }

      if (straight_h > 0)
        translate([0, 0, lead_h])
          linear_extrude(height = straight_h)
            connector_key_profile(side_clearance, end_clearance);
    }
}

// =============================================================================
// FRAME
// =============================================================================

function pocket_width() = patch_w + 2 * patch_tol;
function pocket_height() = patch_h + 2 * patch_tol;
function face_inner_top_y(clearance = 0) =
  hex_height / 2 - rim_width - clearance;
function text_band_y(clearance = 0) =
  (face_inner_top_y(clearance) + pocket_height() / 2) / 2;

module frame_shell() {
  // Body shell for split builds and the integrated frame alike.
  color(frame_body_color)
    difference() {
      union() {
        linear_extrude(height = body_thick)
          hex_shape();

        translate([0, 0, body_thick])
          linear_extrude(height = well_depth)
            difference() {
              hex_shape();
              hex_inset(rim_width);
            }
      }

      if (connectors_enabled)
        for (i = [0:5])
          on_edge(i)
            connector_slot_cutout();

      if (hanger_enabled) {
        hole_h = body_thick - hanger_front_wall;
        keyhole_y = hex_height / 2 - hanger_y_off;

        translate([0, keyhole_y, -bool_eps]) {
          cylinder(h = hole_h + bool_eps, d = hanger_d);
          translate([-hanger_shaft_d / 2, 0, 0])
            cube([hanger_shaft_d, hanger_drop, hole_h + bool_eps]);
        }
      }
    }
}

module front_inlay_shape(clearance = 0) {
  hex_inset(rim_width + clearance);
}

module front_inlay(z0 = 0, clearance = 0) {
  pocket_w = pocket_width();
  pocket_h = pocket_height();
  top_text_y = text_band_y(clearance);
  bottom_text_y = -top_text_y;

  color(frame_face_color)
    translate([0, 0, z0])
      difference() {
        linear_extrude(height = face_thick)
          front_inlay_shape(clearance);

        translate([0, 0, face_thick - patch_depth])
          linear_extrude(height = patch_depth + bool_eps)
            square([pocket_w, pocket_h], center = true);
      }

  color(frame_body_color) {
    translate([0, top_text_y, z0 + face_thick])
      linear_extrude(height = text_raise)
        text(top_text, size = date_size, font = text_font,
             halign = "center", valign = "center");

    translate([0, bottom_text_y, z0 + face_thick])
      linear_extrude(height = text_raise)
        text(bottom_text, size = time_size, font = text_font,
             halign = "center", valign = "center");
  }
}

module frame() {
  frame_shell();
  front_inlay(z0 = body_thick);
}


// =============================================================================
// RENDER DISPATCH
// =============================================================================

if (part == "frame")
  frame();
else if (part == "frame_shell")
  frame_shell();
else if (part == "front_inlay")
  front_inlay(clearance = front_inlay_clearance);
