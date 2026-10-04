#!/usr/bin/env node

import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath, pathToFileURL } from "node:url";

const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(SCRIPT_DIR, "..");
const THREAD_ID = process.env.CODEX_THREAD_ID || `manual-${new Date().toISOString().replaceAll(/[:.]/g, "-")}`;
const WORKSPACE = path.join(ROOT, "outputs", THREAD_ID, "presentations", "presentation2024-latex");
const ASSET_DIR = path.join(WORKSPACE, "assets");
const EQ_DIR = path.join(WORKSPACE, "equations");
const PREVIEW_DIR = path.join(WORKSPACE, "preview");
const QA_DIR = path.join(WORKSPACE, "qa");
const PDF = path.join(SCRIPT_DIR, "presentation2024.pdf");
const PPTX = path.join(SCRIPT_DIR, "presentation2024-latex-rebuild.pptx");
const KEY = path.join(SCRIPT_DIR, "presentation2024.key");
const BACKUP = path.join(SCRIPT_DIR, "presentation2024.key.backup-2026-05-11");
const RENDER_EQUATIONS = path.join(SCRIPT_DIR, "render_equation_assets.mjs");

const RUNTIME = path.join(
  os.homedir(),
  ".cache",
  "codex-runtimes",
  "codex-primary-runtime",
  "dependencies",
  "node",
  "node_modules",
  "@oai",
  "artifact-tool",
  "dist",
  "artifact_tool.mjs",
);

const NODE = process.execPath;
const W = 1280;
const H = 720;
const FONT = "Helvetica Neue";
const BODY = "Helvetica Neue";
const BLACK = "#000000";
const RED = "#FF2A17";
const GREY = "#4A4A4A";
const TRANSPARENT = "#00000000";

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    encoding: "utf8",
    cwd: options.cwd || ROOT,
  });
  if (result.status !== 0) {
    throw new Error(
      [
        `${command} ${args.join(" ")} failed`,
        result.stdout.trim(),
        result.stderr.trim(),
      ]
        .filter(Boolean)
        .join("\n"),
    );
  }
  return result.stdout.trim();
}

async function assertFile(filePath) {
  await fs.access(filePath).catch(() => {
    throw new Error(`Missing required file: ${filePath}`);
  });
}

async function readBlob(filePath) {
  const bytes = await fs.readFile(filePath);
  return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
}

async function pngDimensions(filePath) {
  const bytes = await fs.readFile(filePath);
  if (bytes.length < 24 || bytes.toString("ascii", 1, 4) !== "PNG") {
    throw new Error(`Not a PNG file: ${filePath}`);
  }
  return {
    width: bytes.readUInt32BE(16),
    height: bytes.readUInt32BE(20),
  };
}

async function ensureDirs() {
  await fs.mkdir(ASSET_DIR, { recursive: true });
  await fs.mkdir(PREVIEW_DIR, { recursive: true });
  await fs.mkdir(QA_DIR, { recursive: true });
}

async function ensureBackup() {
  await assertFile(KEY);
  try {
    await fs.access(BACKUP);
  } catch {
    await fs.copyFile(KEY, BACKUP);
  }
}

async function ensureAssets() {
  const crops = [
    { name: "slide02_scatter.png", page: 1, crop: "760x700+1040+300" },
    { name: "slide05_iwp2_plot.png", page: 4, crop: "900x800+80+230" },
    { name: "slide07_tiwp2_plot.png", page: 6, crop: "900x800+70+230" },
    { name: "slide09_mgp_plot.png", page: 8, crop: "900x800+70+230" },
    { name: "slide10_comparison_plots.png", page: 9, crop: "1840x790+40+250" },
    { name: "slide17_stratified_plot.png", page: 16, crop: "1540x790+210+260" },
  ];

  for (const crop of crops) {
    run("magick", [
      `${PDF}[${crop.page}]`,
      "-crop",
      crop.crop,
      "+repage",
      "-alpha",
      "remove",
      "-background",
      "white",
      path.join(ASSET_DIR, crop.name),
    ]);
  }

  run("magick", [
    path.join(ROOT, "output", "sim5_coverage_rate_caseB.pdf"),
    "-density",
    "180",
    "-alpha",
    "remove",
    "-background",
    "white",
    path.join(ASSET_DIR, "sim5_coverage_rate_caseB.png"),
  ]);
  run("magick", [
    path.join(ROOT, "output", "sim5_interval_width_caseB.pdf"),
    "-density",
    "180",
    "-alpha",
    "remove",
    "-background",
    "white",
    path.join(ASSET_DIR, "sim5_interval_width_caseB.png"),
  ]);

  return {
    scatter: path.join(ASSET_DIR, "slide02_scatter.png"),
    iwp2: path.join(ASSET_DIR, "slide05_iwp2_plot.png"),
    tiwp2: path.join(ASSET_DIR, "slide07_tiwp2_plot.png"),
    mgp: path.join(ASSET_DIR, "slide09_mgp_plot.png"),
    comparison: path.join(ASSET_DIR, "slide10_comparison_plots.png"),
    stratified: path.join(ASSET_DIR, "slide17_stratified_plot.png"),
    caseAcoverage: path.join(ROOT, "output", "sim5_coverage_rate_caseA.png"),
    caseAwidth: path.join(ROOT, "output", "sim5_interval_width_caseA.png"),
    caseBcoverage: path.join(ASSET_DIR, "sim5_coverage_rate_caseB.png"),
    caseBwidth: path.join(ASSET_DIR, "sim5_interval_width_caseB.png"),
  };
}

async function renderEquations() {
  run(NODE, [RENDER_EQUATIONS, "--outdir", EQ_DIR]);
  const manifest = JSON.parse(await fs.readFile(path.join(EQ_DIR, "manifest.json"), "utf8"));
  return Object.fromEntries(manifest.equations.map((entry) => [entry.id, entry.path]));
}

function addShape(slide, geometry, x, y, w, h, options = {}) {
  return slide.shapes.add({
    geometry,
    position: { left: x, top: y, width: w, height: h },
    fill: options.fill ?? TRANSPARENT,
    line: options.line ?? { style: "solid", fill: TRANSPARENT, width: 0 },
    name: options.name,
  });
}

function addText(slide, text, x, y, w, h, options = {}) {
  const shape = addShape(slide, "rect", x, y, w, h, options);
  shape.text = text;
  shape.text.fontSize = options.fontSize ?? 30;
  shape.text.typeface = options.typeface ?? BODY;
  shape.text.color = options.color ?? BLACK;
  shape.text.bold = Boolean(options.bold);
  shape.text.alignment = options.align ?? "left";
  shape.text.verticalAlignment = options.valign ?? "top";
  shape.text.insets = options.insets ?? { left: 0, right: 0, top: 0, bottom: 0 };
  return shape;
}

function addBackground(slide) {
  addShape(slide, "rect", 0, 0, W, H, {
    fill: "#FFFFFF",
    line: { style: "solid", fill: "#FFFFFF", width: 0 },
  });
}

function title(slide, text, x = 65, y = 70, w = 1120, h = 78, size = 48) {
  addText(slide, text, x, y, w, h, { fontSize: size, typeface: FONT, bold: true });
}

function subtitle(slide, text, x, y, w, h, size = 23) {
  addText(slide, text, x, y, w, h, { fontSize: size, typeface: BODY, bold: true });
}

async function image(slide, filePath, x, y, w, h, fit = "contain") {
  const img = slide.images.add({ blob: await readBlob(filePath), fit, alt: path.basename(filePath) });
  img.position = { left: x, top: y, width: w, height: h };
  return img;
}

async function eq(slide, eqs, id, x, y, w, h) {
  if (!eqs[id]) throw new Error(`Unknown equation asset: ${id}`);
  const dims = await pngDimensions(eqs[id]);
  const scale = Math.min(w / dims.width, h / dims.height);
  return image(slide, eqs[id], x, y, dims.width * scale, dims.height * scale, "contain");
}

function bullet(slide, text, x, y, w, h = 36, size = 23) {
  addText(slide, `• ${text}`, x, y, w, h, { fontSize: size, typeface: BODY });
}

async function slide01(presentation) {
  const slide = presentation.slides.add();
  addBackground(slide);
  addText(slide, "Model-based Smoothing for Near-Monotone\nFunctions: Two Possible Approaches", 170, 282, 940, 95, {
    fontSize: 31,
    typeface: FONT,
    bold: true,
    align: "center",
  });
  addText(slide, "Ziang Zhang,     Patrick Brown,     Jamie Stafford", 375, 430, 530, 30, {
    fontSize: 11,
    typeface: FONT,
    bold: true,
    align: "center",
  });
  addText(slide, "2024.08.12", 600, 488, 90, 22, {
    fontSize: 10,
    typeface: FONT,
    bold: true,
    align: "center",
  });
}

async function slide02(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "The classical smoothing problem:", 65, 75, 1130, 85, 52);
  await eq(slide, eqs, "s02_model", 78, 222, 420, 42);
  await eq(slide, eqs, "s02_unknown", 78, 290, 560, 42);
  await eq(slide, eqs, "s02_smooth", 78, 358, 430, 42);
  addText(slide, "BUT, what does smooth mean here?", 78, 482, 590, 42, { fontSize: 29, bold: true });
  await eq(slide, eqs, "s02_cinf", 78, 548, 475, 42);
  await eq(slide, eqs, "s02_norm", 78, 610, 600, 42);
  await image(slide, assets.scatter, 706, 205, 460, 410);
}

async function slide03(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "How Statisticians View Smoothing", 65, 58, 720, 58, 38);
  await eq(slide, eqs, "s03_objective", 610, 130, 515, 48);
  await eq(slide, eqs, "s03_norm", 610, 190, 500, 46);
  await eq(slide, eqs, "s03_sde", 155, 315, 455, 46);
  await eq(slide, eqs, "s03_iwp", 640, 315, 455, 46);
  await eq(slide, eqs, "s03_null", 140, 450, 460, 42);
  bullet(slide, "Linear functions are not penalized", 140, 513, 650, 34, 25);
  await eq(slide, eqs, "s03_smooth", 140, 575, 460, 42);
}

async function slide04(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Model-based Smoothing", 65, 92, 900, 74, 48);
  bullet(slide, "Smoothing can be viewed as doing shrinkage", 76, 235, 1040, 35, 25);
  bullet(slide, "f is shrunk toward the base model (a set of simple functions)", 76, 290, 1040, 35, 25);
  await eq(slide, eqs, "s04_iwp_base", 76, 344, 930, 45);
  bullet(slide, "Base model specifies the “direction” of the shrinkage", 76, 402, 1040, 35, 25);
  await eq(slide, eqs, "s04_known_m", 76, 456, 700, 45);
}

async function slide05(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Fitting an IWP2 to the data", 65, 60, 1100, 82, 54);
  await image(slide, assets.iwp2, 80, 165, 585, 505);
  await eq(slide, eqs, "s05_nonlin", 710, 300, 500, 46);
  await eq(slide, eqs, "s05_sigma", 710, 365, 500, 46);
  bullet(slide, "IWP gives a linear prediction", 710, 430, 505, 42, 30);
  bullet(slide, "With HUGE prediction interval", 710, 495, 505, 42, 30);
}

async function slide06(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "An Intuitive Approach:", 480, 96, 520, 60, 43);
  subtitle(slide, "Transforming the IWP2: t-IWP2", 480, 165, 520, 35, 21);
  await eq(slide, eqs, "s06_define", 480, 238, 700, 54);
  await eq(slide, eqs, "s06_assume", 480, 312, 440, 45);
  await eq(slide, eqs, "s06_base", 480, 382, 700, 50);
  await eq(slide, eqs, "s06_call", 480, 454, 620, 50);
}

async function slide07(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Fitting an tIWP2 to the data", 65, 70, 900, 70, 46);
  await image(slide, assets.tiwp2, 65, 165, 600, 505);
  await eq(slide, eqs, "s07_prior", 755, 310, 430, 42);
  await eq(slide, eqs, "s07_m", 755, 365, 390, 42);
  await eq(slide, eqs, "s07_pred", 755, 420, 350, 42);
}

async function slide08(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "There is another approach...", 252, 96, 760, 55, 40);
  subtitle(slide, "Why don't we define a new operator?", 252, 168, 550, 35, 25);
  await eq(slide, eqs, "s08_recall", 252, 232, 850, 42);
  await eq(slide, eqs, "s08_define", 252, 289, 900, 42);
  await eq(slide, eqs, "s08_null", 252, 347, 780, 42);
  await eq(slide, eqs, "s08_m", 252, 405, 870, 42);
  await eq(slide, eqs, "s08_any", 252, 463, 850, 42);
  await eq(slide, eqs, "s08_call", 252, 521, 720, 42);
}

async function slide09(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Fitting a mGP to the data", 65, 68, 900, 70, 47);
  await image(slide, assets.mgp, 65, 165, 600, 505);
  await eq(slide, eqs, "s09_prior", 755, 310, 430, 42);
  await eq(slide, eqs, "s09_m", 755, 365, 390, 42);
  await eq(slide, eqs, "s09_pred", 755, 420, 350, 42);
}

async function slide10(presentation, assets) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Comparing the two new approaches:", 55, 72, 1160, 80, 52);
  await image(slide, assets.comparison, 45, 175, 1190, 505);
}

async function slide11(presentation) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Comparing the two approaches..", 65, 102, 850, 60, 43);
  bullet(slide, "The tIWP and mGP provided similar posterior mean", 250, 300, 850, 35, 25);
  bullet(slide, "The prediction interval from mGP is wider", 250, 360, 850, 35, 25);
  bullet(slide, "Which approach should we use?", 250, 420, 850, 35, 25);
  bullet(slide, "Well, we can show that tIWP is equivalent to a particular type of mGP", 250, 480, 850, 35, 25);
}

async function slide12(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "tIWP2 is a time varying mGP", 480, 98, 600, 50, 35);
  await eq(slide, eqs, "s12_prop", 480, 220, 650, 95);
  await eq(slide, eqs, "s12_main", 605, 360, 330, 45);
  await eq(slide, eqs, "s12_where", 480, 455, 650, 45);
}

async function slide13(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Some implications...", 65, 92, 700, 55, 40);
  subtitle(slide, "Transforming coordinate imposes implicit assumption", 65, 170, 720, 35, 24);
  await eq(slide, eqs, "s13_when", 65, 250, 650, 50);
  await eq(slide, eqs, "s13_sigma", 65, 313, 750, 50);
  await eq(slide, eqs, "s13_assume", 65, 376, 920, 50);
  bullet(slide, "This is a HUGE assumption!", 65, 443, 600, 36, 24);
}

async function slide14(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Looking at the PSD (Zhang et.al, 2024):", 65, 94, 1080, 55, 36);
  bullet(slide, "σ is not interpretable across different models", 92, 225, 1030, 35, 25);
  bullet(slide, "Prior elicitation based on the h-step predictive standard deviation (PSD)", 92, 283, 1030, 35, 25);
  await eq(slide, eqs, "s14_psd", 370, 345, 585, 52);
  await eq(slide, eqs, "s14_depends", 92, 475, 1010, 45);
  await eq(slide, eqs, "s14_infty", 92, 533, 475, 45);
}

async function slide15(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Two different limits...", 65, 78, 900, 75, 51);
  addText(slide, "Corollary 1 (Limiting PSD of M-GP):", 125, 210, 680, 40, {
    fontSize: 25,
    bold: true,
    color: GREY,
  });
  await eq(slide, eqs, "s15_mgp_assume", 125, 270, 1030, 48);
  await eq(slide, eqs, "s15_mgp_limit", 485, 365, 470, 55);
  addText(slide, "Corollary 2 (Limiting PSD of t-IWP2):", 125, 488, 720, 40, {
    fontSize: 25,
    bold: true,
    color: GREY,
  });
  await eq(slide, eqs, "s15_tiwp_assume1", 125, 548, 1040, 42);
  await eq(slide, eqs, "s15_tiwp_assume2", 125, 605, 1010, 42);
  await eq(slide, eqs, "s15_tiwp_limit", 520, 668, 440, 38);
}

async function slide16(presentation, assets, eqs) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "A Simulation Study", 65, 105, 700, 55, 39);
  subtitle(slide, "Which model is more robust to model-misspecification?", 65, 170, 760, 35, 24);
  bullet(slide, "In scenario A, we consider:", 65, 230, 1040, 32, 22);
  await eq(slide, eqs, "s16_a", 95, 280, 820, 42);
  bullet(slide, "In scenario B, we consider:", 65, 335, 1040, 32, 22);
  await eq(slide, eqs, "s16_b", 95, 385, 820, 42);
  bullet(slide, "For both case, we compute the point-wise coverage rate and interval width.", 65, 445, 1040, 32, 22);
  await eq(slide, eqs, "s16_prior", 65, 500, 920, 42);
}

async function slide17(presentation, assets) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "A Stratified Comparison...", 65, 82, 900, 70, 49);
  await image(slide, assets.stratified, 220, 175, 890, 505);
}

async function slide18(presentation, assets) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Scenario A", 65, 85, 500, 75, 52);
  await image(slide, assets.caseAcoverage, 45, 230, 585, 380);
  await image(slide, assets.caseAwidth, 650, 230, 585, 380);
}

async function slide19(presentation, assets) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Scenario B", 65, 85, 500, 75, 52);
  await image(slide, assets.caseBcoverage, 45, 225, 585, 390);
  await image(slide, assets.caseBwidth, 650, 225, 585, 390);
}

async function slide20(presentation) {
  const slide = presentation.slides.add();
  addBackground(slide);
  title(slide, "Conclusion", 65, 112, 500, 55, 41);
  bullet(slide, "Both approaches can be used for near-monotone smoothing", 260, 300, 820, 35, 25);
  bullet(slide, "Both are computationally efficient through state-space or FEM", 260, 360, 820, 35, 25);
  bullet(slide, "Which one is better? Depending on how does f deviate from the base model", 260, 420, 870, 35, 25);
  bullet(slide, "Under model-misspecification, mGP appears more robust", 260, 480, 820, 35, 25);
}

async function slide21(presentation) {
  const slide = presentation.slides.add();
  addBackground(slide);
  addText(
    slide,
    "Ramsay, J. O. (1998). Estimating smooth monotone functions. Journal of the Royal\nStatistical Society: Series B (Statistical Methodology), 60(2), 365-375.\n\nZhang, Z., Stringer, A., Brown, P., & Stafford, J. (2024). Model-based smoothing with\nintegrated wiener processes and overlapping splines. Journal of Computational and\nGraphical Statistics, 1-13.",
    480,
    315,
    660,
    120,
    { fontSize: 14, typeface: BODY },
  );
  bullet(slide, "For more details about this work, see:", 480, 455, 640, 32, 21);
  bullet(slide, "aguerozz.github.io/summary_M_GP", 535, 505, 540, 32, 18);
  title(slide, "Reference", 470, 602, 350, 50, 36);
}

async function buildDeck(artifact, assets, eqs) {
  const { Presentation } = artifact;
  const presentation = Presentation.create({ slideSize: { width: W, height: H } });
  const builders = [
    slide01,
    slide02,
    slide03,
    slide04,
    slide05,
    slide06,
    slide07,
    slide08,
    slide09,
    slide10,
    slide11,
    slide12,
    slide13,
    slide14,
    slide15,
    slide16,
    slide17,
    slide18,
    slide19,
    slide20,
    slide21,
  ];
  for (const builder of builders) {
    await builder(presentation, assets, eqs);
  }
  return presentation;
}

async function exportPreviews(presentation) {
  const previewPaths = [];
  for (let i = 0; i < presentation.slides.count; i += 1) {
    const slide = presentation.slides.getItem(i);
    const output = path.join(PREVIEW_DIR, `slide-${String(i + 1).padStart(2, "0")}.png`);
    const png = await presentation.export({ slide, format: "png", scale: 1 });
    await fs.writeFile(output, Buffer.from(await png.arrayBuffer()));
    previewPaths.push(output);
  }
  const contactSheet = path.join(PREVIEW_DIR, "contact-sheet.png");
  run("magick", ["montage", ...previewPaths, "-thumbnail", "320x180", "-tile", "3x7", "-geometry", "+12+12", contactSheet]);
  const originalContact = path.join(PREVIEW_DIR, "original-contact-sheet.png");
  run("magick", ["montage", `${PDF}[0-20]`, "-thumbnail", "320x180", "-tile", "3x7", "-geometry", "+12+12", originalContact]);
  const sideBySide = path.join(PREVIEW_DIR, "original-vs-rebuild-contact.png");
  run("magick", [originalContact, contactSheet, "+append", sideBySide]);
  return { previewPaths, contactSheet, originalContact, sideBySide };
}

function importPptxToKeynote() {
  const scriptPath = path.join(WORKSPACE, "import_to_keynote.applescript");
  const script = `
set pptxPath to POSIX file "${PPTX}"
set keyPath to POSIX file "${KEY}"
tell application "Keynote"
  activate
  open pptxPath
  delay 3
  set docRef to front document
  set nSlides to count of slides of docRef
  save docRef in keyPath
  close docRef saving no
end tell
return nSlides
`;
  return fs.writeFile(scriptPath, script, "utf8").then(() => {
    const result = spawnSync("/usr/bin/osascript", [scriptPath], { encoding: "utf8" });
    return {
      scriptPath,
      ok: result.status === 0,
      stdout: result.stdout.trim(),
      stderr: result.stderr.trim(),
      status: result.status,
    };
  });
}

async function main() {
  await assertFile(PDF);
  await assertFile(RENDER_EQUATIONS);
  await assertFile(RUNTIME);
  await assertFile(path.join(ROOT, "output", "sim5_coverage_rate_caseA.png"));
  await assertFile(path.join(ROOT, "output", "sim5_interval_width_caseA.png"));
  await assertFile(path.join(ROOT, "output", "sim5_coverage_rate_caseB.pdf"));
  await assertFile(path.join(ROOT, "output", "sim5_interval_width_caseB.pdf"));
  await ensureDirs();
  await ensureBackup();

  const assets = await ensureAssets();
  const eqs = await renderEquations();
  const artifact = await import(pathToFileURL(RUNTIME).href);
  const presentation = await buildDeck(artifact, assets, eqs);
  const preview = await exportPreviews(presentation);

  const { PresentationFile } = artifact;
  const pptx = await PresentationFile.exportPptx(presentation);
  await pptx.save(PPTX);
  const pptxStat = await fs.stat(PPTX);

  const keynoteImport = await importPptxToKeynote();
  const keyStat = await fs.stat(KEY).catch(() => undefined);
  const manifest = {
    workspace: WORKSPACE,
    pptx: PPTX,
    pptxBytes: pptxStat.size,
    key: KEY,
    keyBytes: keyStat?.size,
    backup: BACKUP,
    slideCount: presentation.slides.count,
    equationCount: Object.keys(eqs).length,
    preview,
    keynoteImport,
    nonEditableAssets: [
      "LaTeX-rendered equation PNG assets are embedded for math-heavy content.",
      "Cropped plot panels from talk/presentation2024.pdf are embedded on slides 2, 5, 7, 9, 10, and 17.",
      "Simulation panels from output/sim5_* are embedded on slides 18 and 19.",
    ],
  };
  await fs.writeFile(path.join(QA_DIR, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
  console.log(JSON.stringify(manifest, null, 2));

  if (!keynoteImport.ok) {
    process.exitCode = 2;
  }
}

main().catch((error) => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
