#!/usr/bin/env osascript -l JavaScript
// aws-vault-colorbox.js — a colored, auto-sized toast with a click-to-close
// button, used by aws-vault-notify's "colorbox" backend. Called as:
//   osascript -l JavaScript aws-vault-colorbox.js <title> <body> <fillHex> <textHex> <secs> [slot]
// Renders on whichever screen currently has the mouse cursor (not the fixed
// menu-bar screen). secs > 0 auto-dismisses after that many seconds; secs <= 0
// means no auto-dismiss — it stays up until the close button is clicked (used
// by aws-vault-notify for purple/red: high-severity boxes that should stay
// visible until acknowledged). Touch ID stays the only real gate regardless —
// this is just the readable, color-coded hint, and it runs in a backgrounded
// process the caller never waits on. `slot` (from notify_colorbox's
// concurrent-process count) cascades this box downward so parallel calls
// don't land on top of each other.
ObjC.import('Cocoa');

function run(argv) {
  var title = argv[0] || "Title";
  var body = argv[1] || "Body text";
  var fillHex = argv[2] || "#0A84FF";
  var textHex = argv[3] || "#FFFFFF";
  var secs = parseFloat(argv[4] || "6");
  var slot = parseInt(argv[5] || "0", 10) || 0;
  var shouldClose = false;

  function hexColor(hex, alpha) {
    hex = hex.replace('#', '');
    var r = parseInt(hex.substr(0, 2), 16) / 255.0;
    var g = parseInt(hex.substr(2, 2), 16) / 255.0;
    var b = parseInt(hex.substr(4, 2), 16) / 255.0;
    return $.NSColor.colorWithRedGreenBlueAlpha(r, g, b, alpha === undefined ? 1.0 : alpha);
  }

  var W = 420, PAD = 20;
  var TITLE_H = 22, GAP_SEP_TITLE = 8, SEP_H = 1, GAP_BODY_SEP = 10;
  var BODY_MIN_H = 20, BODY_MAX_H = 300;

  var textColor = hexColor(textHex, 1.0);
  var bodyFont = $.NSFont.monospacedSystemFontOfSizeWeight(13, 0);

  // measure body height for the fixed width before laying anything out, so
  // the box auto-expands to fit the text instead of a hardcoded height.
  var measureField = $.NSTextField.alloc.initWithFrame($.NSMakeRect(0, 0, W - 2 * PAD, 10000));
  measureField.font = bodyFont;
  measureField.stringValue = body;
  measureField.cell.wraps = true;
  var measured = measureField.cell.cellSizeForBounds($.NSMakeRect(0, 0, W - 2 * PAD, 10000));
  var bodyH = Math.max(BODY_MIN_H, Math.min(BODY_MAX_H, measured.height));

  var bodyY = PAD;
  var sepY = bodyY + bodyH + GAP_BODY_SEP;
  var titleY = sepY + SEP_H + GAP_SEP_TITLE;
  var H = titleY + TITLE_H + PAD;

  // place on whichever screen currently has the mouse cursor, not the fixed
  // menu-bar (mainScreen) display — matters on a 2-monitor setup.
  var mouseLoc = $.NSEvent.mouseLocation;
  var screens = $.NSScreen.screens;
  var targetFrame = $.NSScreen.mainScreen.frame;
  var count = screens.count;
  for (var i = 0; i < count; i++) {
    var f = screens.objectAtIndex(i).frame;
    if (mouseLoc.x >= f.origin.x && mouseLoc.x <= f.origin.x + f.size.width &&
        mouseLoc.y >= f.origin.y && mouseLoc.y <= f.origin.y + f.size.height) {
      targetFrame = f;
      break;
    }
  }
  var STACK_STEP = 115; // fixed cascade step; a much-taller box can still overlap the next slot
  var x = targetFrame.origin.x + targetFrame.size.width - W - 24;
  var y = targetFrame.origin.y + targetFrame.size.height - H - 48 - slot * STACK_STEP;

  var win = $.NSWindow.alloc.initWithContentRectStyleMaskBackingDefer(
    $.NSMakeRect(x, y, W, H), 0, 2, false
  );
  win.level = 1000;
  win.collectionBehavior = 1 | 1024;
  win.opaque = false;
  win.backgroundColor = $.NSColor.clearColor;
  win.hasShadow = true;
  // must accept mouse events for the close button to be clickable at all —
  // ok trade-off: it's a small corner box, and only intercepts clicks while shown.
  win.ignoresMouseEvents = false;

  var box = $.NSBox.alloc.initWithFrame($.NSMakeRect(0, 0, W, H));
  box.boxType = 4;
  box.titlePosition = 0;
  box.cornerRadius = 14;
  box.borderWidth = 0;
  box.fillColor = hexColor(fillHex, 1.0);
  win.contentView.addSubview(box);

  // title: bold, single line, truncates instead of wrapping/overlapping.
  // Narrower than the full width to leave room for the close button.
  var CLOSE_W = 20, CLOSE_GAP = 6;
  var titleField = $.NSTextField.alloc.initWithFrame(
    $.NSMakeRect(PAD, titleY, W - 2 * PAD - CLOSE_W - CLOSE_GAP, TITLE_H));
  titleField.stringValue = title;
  titleField.editable = false;
  titleField.bezeled = false;
  titleField.drawsBackground = false;
  titleField.textColor = textColor;
  titleField.font = $.NSFont.boldSystemFontOfSize(15);
  titleField.cell.lineBreakMode = 4; // NSLineBreakByTruncatingTail

  // close button — target/action via a registered delegate class, since
  // that's how JXA wires a real click callback back into this script.
  // registerSubclass's return value doesn't bridge — the registered class
  // must be looked up afterward via $.ClassName instead.
  ObjC.registerSubclass({
    name: 'AwsVaultColorboxCloseDelegate',
    methods: {
      'closeClicked:': {
        types: ['void', ['id']],
        implementation: function (sender) { shouldClose = true; }
      }
    }
  });
  var closeDelegate = $.AwsVaultColorboxCloseDelegate.alloc.init;
  var closeBtn = $.NSButton.alloc.initWithFrame($.NSMakeRect(
    W - PAD - CLOSE_W, titleY + (TITLE_H - CLOSE_W) / 2, CLOSE_W, CLOSE_W));
  closeBtn.title = "✕";
  closeBtn.bordered = false;
  closeBtn.font = $.NSFont.systemFontOfSize(13);
  closeBtn.target = closeDelegate;
  closeBtn.action = 'closeClicked:';

  // thin separator between title and body
  var sep = $.NSBox.alloc.initWithFrame(
    $.NSMakeRect(PAD, sepY, W - 2 * PAD, SEP_H));
  sep.boxType = 4;
  sep.titlePosition = 0;
  sep.cornerRadius = 0;
  sep.borderWidth = 0;
  sep.fillColor = hexColor(textHex, 0.25);

  // body: monospaced (mostly a shell command + paths), left-aligned,
  // word-wrapped. NSAttributedString doesn't bridge via JXA here, so font/
  // color are set directly on the field instead (same as titleField).
  var bodyField = $.NSTextField.alloc.initWithFrame(
    $.NSMakeRect(PAD, bodyY, W - 2 * PAD, bodyH));
  bodyField.stringValue = body;
  bodyField.editable = false;
  bodyField.bezeled = false;
  bodyField.drawsBackground = false;
  bodyField.textColor = textColor;
  bodyField.font = bodyFont;
  bodyField.cell.wraps = true;
  bodyField.cell.lineBreakMode = 0; // NSLineBreakByWordWrapping

  win.contentView.addSubview(sep);
  win.contentView.addSubview(titleField);
  win.contentView.addSubview(closeBtn);
  win.contentView.addSubview(bodyField);
  win.makeKeyAndOrderFront(this);

  // Real event pump (not just a sleep loop) so the close button's click is
  // actually dequeued and dispatched. secs <= 0 means no auto-dismiss —
  // it only exits when shouldClose flips true from closeClicked:.
  var app = $.NSApplication.sharedApplication;
  var hasDeadline = secs > 0;
  var endDate = hasDeadline ? $.NSDate.dateWithTimeIntervalSinceNow(secs) : null;
  var NSEventMaskAny = 0xFFFFFFFF;
  while (!shouldClose && (!hasDeadline || $.NSDate.date.compare(endDate) < 0)) {
    var until = $.NSDate.dateWithTimeIntervalSinceNow(0.1);
    var event = app.nextEventMatchingMaskUntilDateInModeDequeue(NSEventMaskAny, until, 'kCFRunLoopDefaultMode', true);
    if (event) app.sendEvent(event);
  }
}
