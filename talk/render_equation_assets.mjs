#!/usr/bin/env node

import fs from "node:fs/promises";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const EQUATIONS = [
  { id: "s02_model", tex: String.raw`\bullet\; y_i = f(x_i) + \epsilon_i` },
  { id: "s02_unknown", tex: String.raw`\bullet\; f \;\text{ is the unknown function of interest}` },
  { id: "s02_smooth", tex: String.raw`\bullet\; f \;\text{ assumed } \textcolor{red}{\text{smooth}}` },
  { id: "s02_cinf", tex: String.raw`-\;\text{Mathematicians say } f \in C^\infty` },
  { id: "s02_norm", tex: String.raw`-\;\text{Statisticians look at certain } \textcolor{red}{\text{norm }} \lVert f\rVert_L` },

  {
    id: "s03_objective",
    tex: String.raw`\sum_{i=1}^{n}\left(y_i-f(x_i)\right)^2+\lambda\int\left(f''(x)\right)^2\,dx.`,
  },
  { id: "s03_norm", tex: String.raw`\lVert f\rVert_L^2=\lVert Lf\rVert_2^2 \qquad \text{with } L=D^2` },
  { id: "s03_sde", tex: String.raw`D^2 f(x)=\sigma \xi(x), \qquad \sigma=1/\sqrt{\lambda}` },
  { id: "s03_iwp", tex: String.raw`\text{Integrated Wiener Process: } f\sim \operatorname{IWP}_2(\sigma)` },
  { id: "s03_null", tex: String.raw`\bullet\; \operatorname{Null}\{L\}=\operatorname{span}\{1,x\}` },
  { id: "s03_smooth", tex: String.raw`\bullet\; \text{Smooth means } f(x)\approx a+bx` },

  { id: "s04_iwp_base", tex: String.raw`\bullet\; \text{E.g. } f\sim \operatorname{IWP}_2(\sigma)\to \text{ base model } \operatorname{Null}\{L\}=\operatorname{span}\{1,x\}` },
  { id: "s04_known_m", tex: String.raw`\bullet\; \text{What if we know } f\approx a+bm(x) \text{ for some } m(x)?` },

  { id: "s05_nonlin", tex: String.raw`\bullet\; f \text{ is highly nonlinear at } x\approx 0` },
  { id: "s05_sigma", tex: String.raw`\bullet\; \operatorname{IWP}_2(\sigma) \text{ estimates a large } \sigma` },

  { id: "s06_define", tex: String.raw`\bullet\; \text{Now define } x^*=m(x) \qquad f(x):=\tilde f(m(x)):=\tilde f(x^*)` },
  { id: "s06_assume", tex: String.raw`\bullet\; \text{Assume } \tilde f(x^*)\sim \operatorname{IWP}_2(\sigma)` },
  { id: "s06_base", tex: String.raw`\bullet\; \text{The base model becomes } \operatorname{span}\{1,x^*\}=\operatorname{span}\{1,m(x)\}` },
  { id: "s06_call", tex: String.raw`\bullet\; \text{We call it the transformed-IWP2, } f\sim \operatorname{tIWP}_2(\sigma)` },

  { id: "s07_prior", tex: String.raw`\bullet\; \text{Using the } \operatorname{tIWP}_2(\sigma) \text{ prior for } f` },
  { id: "s07_m", tex: String.raw`\bullet\; \text{The generating } m(x)=\log(x)` },
  { id: "s07_pred", tex: String.raw`\bullet\; \text{Prediction: } a+b\log(x)` },

  { id: "s08_recall", tex: String.raw`\bullet\; \text{Recall if } Lf=\sigma\xi, \text{ the base model of } f \text{ is } \operatorname{Null}\{L\}` },
  { id: "s08_define", tex: String.raw`\bullet\; \text{Define } L=D^2-\alpha(x)D, \text{ where } \alpha(x) \text{ is Lebesgue square integrable.}` },
  { id: "s08_null", tex: String.raw`\bullet\; \text{Then } \operatorname{Null}\{L\}=\operatorname{span}\{1,D^{-1}\exp(D^{-1}\alpha)\}` },
  { id: "s08_m", tex: String.raw`\bullet\; \text{Let } m=D^{-1}\exp(D^{-1}\alpha),\quad \alpha=D^2m/Dm \text{ (relative curvature)}` },
  { id: "s08_any", tex: String.raw`\bullet\; \text{Any reasonable monotone } m(x) \text{ can be written this way (Ramsay, 1997)}` },
  { id: "s08_call", tex: String.raw`\bullet\; \text{We call it the monotone-induced GP, } f\sim \operatorname{mGP}(\sigma)` },

  { id: "s09_prior", tex: String.raw`\bullet\; \text{Using the } \operatorname{mGP}(\sigma) \text{ prior for } f` },
  { id: "s09_m", tex: String.raw`\bullet\; \text{The generating } m(x)=\log(x)` },
  { id: "s09_pred", tex: String.raw`\bullet\; \text{Prediction: } a+b\log(x)` },

  { id: "s12_prop", text: true, tex: String.raw`\textbf{Proposition 1 (t-IWP as time varying mGP):} If $f\sim \operatorname{tIWP}(\sigma)$ generated\\ by a monotone function $m(x)$ and define $\alpha(x)=m''(x)/m'(x)$, then` },
  { id: "s12_main", tex: String.raw`L f(x)=\sigma(x)\xi(x)` },
  { id: "s12_where", tex: String.raw`\text{where } L=D^2-\alpha(x)D \text{ and } \sigma(x)=\sigma\left[m'(x)^{3/2}\right].` },

  { id: "s13_when", tex: String.raw`\bullet\; \text{When } m(x)=\sqrt{x},\quad m'(x)=\frac{1}{2\sqrt{x}}` },
  { id: "s13_sigma", tex: String.raw`\bullet\; \sigma(x)=\left[\sigma m'(x)^{3/2}\right]\approx 0 \text{ when } x \text{ is large}` },
  { id: "s13_assume", tex: String.raw`\bullet\; \operatorname{tIWP}_2(\sigma) \text{ assumes there is no deviation from base model when } x \text{ is large}` },

  { id: "s14_psd", tex: String.raw`\sigma_x(h)=\operatorname{SD}\left[f(x+h)\mid f(u):u\le x\right].` },
  { id: "s14_depends", tex: String.raw`\bullet\; \text{Unlike } \operatorname{IWP}_2,\text{ this quantity depends on both } x \text{ and } h \text{ for } \operatorname{tIWP}_2 \text{ and mGP}` },
  { id: "s14_infty", tex: String.raw`\bullet\; \text{What will happen if } x\to \infty?` },

  { id: "s15_mgp_assume", tex: String.raw`\text{Assume } \alpha(x)=-\frac{1}{a(x+c)} \text{ where } a\ne 0. \text{ For the M-GP defined by } \alpha(x)` },
  { id: "s15_mgp_limit", tex: String.raw`\sigma^2(h)=\lim_{x\to\infty}\sigma_x^2(h)=\frac{\sigma^2 h^3}{3}.` },
  { id: "s15_tiwp_assume1", tex: String.raw`\text{Assume } \alpha(x)=-\frac{1}{a(x+c)} \text{ where } a\ge 0. \text{ For the t-IWP2 defined by a monotone transformation}` },
  { id: "s15_tiwp_assume2", tex: String.raw`m(x) \text{ such that } m'(x)/m''(x)=\alpha(x), \text{ the limiting PSD is}` },
  { id: "s15_tiwp_limit", tex: String.raw`\sigma^2(h)=\lim_{x\to\infty}\sigma_x^2(h)=0.` },

  { id: "s16_a", tex: String.raw`\bullet\; f\sim \operatorname{mGP} \text{ induced by } m(x)=\sqrt{x}, \text{ with } \sigma_0(20)=1` },
  { id: "s16_b", tex: String.raw`\bullet\; f\sim \operatorname{tIWP}_2 \text{ induced by } m(x)=\sqrt{x}, \text{ with } \sigma_0(20)=1` },
  { id: "s16_prior", tex: String.raw`\bullet\; \text{Exponential priors used on } \sigma_0(20) \text{ with higher, correct or lower medians.}` },
];

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const key = argv[i];
    if (!key.startsWith("--")) throw new Error(`Unexpected argument: ${key}`);
    const value = argv[i + 1];
    if (!value || value.startsWith("--")) {
      args[key.slice(2)] = true;
    } else {
      args[key.slice(2)] = value;
      i += 1;
    }
  }
  return args;
}

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    encoding: "utf8",
    cwd: options.cwd,
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
}

function texDocument(entry) {
  const body = entry.text
    ? String.raw`\begin{minipage}{7.6in}\raggedright\fontsize{22}{28}\selectfont ${entry.tex}\end{minipage}`
    : String.raw`{\fontsize{28}{34}\selectfont $\displaystyle ${entry.tex}$}`;
  return String.raw`\documentclass[border=2pt]{standalone}
\usepackage[T1]{fontenc}
\usepackage{amsmath,amssymb,mathtools,bm}
\usepackage{xcolor}
\usepackage{lmodern}
\newcommand{\IWP}{\operatorname{IWP}}
\newcommand{\tIWP}{\operatorname{tIWP}}
\newcommand{\mGP}{\operatorname{mGP}}
\begin{document}
${body}
\end{document}
`;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const outDir = path.resolve(args.outdir || path.join(ROOT, "outputs", "manual", "presentations", "presentation2024-latex", "equations"));
  await fs.mkdir(outDir, { recursive: true });
  const workDir = path.join(outDir, "_tex");
  await fs.mkdir(workDir, { recursive: true });

  const latex = args.latex || "/Library/TeX/texbin/latex";
  const dvipng = args.dvipng || "/Library/TeX/texbin/dvipng";
  const manifest = [];

  for (const entry of EQUATIONS) {
    const texPath = path.join(workDir, `${entry.id}.tex`);
    const dviPath = path.join(workDir, `${entry.id}.dvi`);
    const pngPath = path.join(outDir, `${entry.id}.png`);
    await fs.writeFile(texPath, texDocument(entry), "utf8");
    run(latex, ["-interaction=nonstopmode", "-halt-on-error", path.basename(texPath)], { cwd: workDir });
    run(dvipng, ["-T", "tight", "-D", "450", "-bg", "Transparent", "-o", pngPath, dviPath], { cwd: workDir });
    manifest.push({ id: entry.id, path: pngPath, tex: entry.tex, text: Boolean(entry.text) });
  }

  const manifestPath = path.join(outDir, "manifest.json");
  await fs.writeFile(manifestPath, `${JSON.stringify({ equations: manifest }, null, 2)}\n`, "utf8");
  console.log(JSON.stringify({ outDir, manifestPath, count: manifest.length }, null, 2));
}

main().catch((error) => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
