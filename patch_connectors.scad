use <hyrox_patch_frame.scad>

// =============================================================================
// Patch Frame Connectors
// =============================================================================


// ============================= OUTPUT ========================================
connector_count = 1;        // [1:8] Number of loose connectors laid out for printing
connector_gap   = 6;        // mm, gap between printed connectors
key_color       = "white";


// ============================= FIT ===========================================
press_side_clearance = 0.04; // mm per side, intentionally tight press-fit
press_end_clearance  = 0.08; // mm, keep a tiny stop clearance at each slot end
lead_in              = 0.25; // mm, bottom-side taper so the key starts cleanly


// ============================= RENDER QUALITY ================================
$fa = 2;
$fs = 0.4;


module _sanity() {
  assert(connector_count >= 1,
      "connector_count must be at least 1");
  assert(connector_gap >= 0,
      "connector_gap must be non-negative");
  assert(connector_key_height() >= 1.5,
      "connector key height is too shallow to print reliably");
}
_sanity();


module connector_pack() {
  pitch = connector_key_lock_w(press_side_clearance) + connector_gap;

  for (i = [0:connector_count - 1])
    translate([(i - (connector_count - 1) / 2) * pitch, 0, 0])
      connector_key(
        side_clearance = press_side_clearance,
        end_clearance = press_end_clearance,
        lead_in = lead_in,
        key_color = key_color
      );
}


connector_pack();
