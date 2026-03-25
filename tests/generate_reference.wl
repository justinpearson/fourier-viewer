(* Generate reference 2D DFT data using Wolfram Language *)
(* FourierParameters -> {1, -1} matches standard DFT: no normalization on forward *)

n = 128;
outDir = DirectoryName[$InputFileName];
If[outDir == "", outDir = Directory[] <> "/"];

(* === Test 1: Box === *)
box = Table[
  If[48 <= x < 80 && 48 <= y < 80, 255.0, 0.0],
  {y, 0, n - 1}, {x, 0, n - 1}
];

(* === Test 2: Lines === *)
lines = Table[
  If[Mod[y, 12] < 3, 200.0, 0.0],
  {y, 0, n - 1}, {x, 0, n - 1}
];

(* === Test 3: Gaussian === *)
sigma = n / 10.0;
gaussian = Table[
  255.0 * Exp[-((x - 64)^2 + (y - 64)^2) / (2 sigma^2)],
  {y, 0, n - 1}, {x, 0, n - 1}
];

(* === Test 4: Diagonal sinusoid === *)
diagonal = Table[
  127.0 + 127.0 * Sin[2 Pi (x + y) * 4 / n],
  {y, 0, n - 1}, {x, 0, n - 1}
];

(* Compute FFTs and export *)
tests = {
  {"box", box},
  {"lines", lines},
  {"gaussian", gaussian},
  {"diagonal", diagonal}
};

Do[
  {name, spatial} = test;
  ft = Fourier[spatial, FourierParameters -> {1, -1}];
  result = <|
    "N" -> n,
    "spatial" -> Flatten[spatial],
    "freqReal" -> Flatten[Re[ft]],
    "freqImag" -> Flatten[Im[ft]]
  |>;
  Export[outDir <> name <> "_reference.json", result, "JSON"];
  Print["Exported: " <> name <> "_reference.json"];
  (* Quick sanity: print DC component *)
  Print["  DC = " <> ToString[ft[[1, 1]]]];
  Print["  Spatial sum = " <> ToString[Total[spatial, 2]]];
  ,
  {test, tests}
];

Print["Done."];
