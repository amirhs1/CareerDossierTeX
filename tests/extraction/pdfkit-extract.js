#!/usr/bin/env osascript -l JavaScript
// pdfkit-extract.js — extract a PDF's text layer through Apple PDFKit.
//
// Poppler (pdftotext) recovers interword spaces from glyph geometry, so it
// cannot see the failure mode in issue #72. PDFKit's `PDFDocument.string`
// treats /ActualText as authoritative and concatenates the spans directly,
// which is what Preview, Quick Look, Spotlight, Safari, and macOS copy/paste
// all do. This script exposes that consumer path to the fixture runner.
//
// macOS only. The runner skips it elsewhere; see run.sh.
//
// Usage: osascript -l JavaScript pdfkit-extract.js /path/to/file.pdf
ObjC.import('Quartz');

function run(argv) {
  if (argv.length !== 1) {
    throw new Error('usage: pdfkit-extract.js <file.pdf>');
  }
  const url = $.NSURL.fileURLWithPath($(argv[0]));
  const doc = $.PDFDocument.alloc.initWithURL(url);
  if (!doc.js) {
    throw new Error('PDFKit could not open ' + argv[0]);
  }
  return ObjC.unwrap(doc.string);
}
