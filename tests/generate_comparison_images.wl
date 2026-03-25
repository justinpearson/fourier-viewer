(* Generate visual comparison images: spatial + amplitude + phase for each test *)

n = 128;
outDir = DirectoryName[$InputFileName];
If[outDir == "", outDir = Directory[] <> "/"];

(* Build test images *)
box = Table[If[48 <= x < 80 && 48 <= y < 80, 255.0, 0.0], {y, 0, n-1}, {x, 0, n-1}];
lines = Table[If[Mod[y, 12] < 3, 200.0, 0.0], {y, 0, n-1}, {x, 0, n-1}];
sigma = n / 10.0;
gaussian = Table[255.0 Exp[-((x-64)^2 + (y-64)^2)/(2 sigma^2)], {y, 0, n-1}, {x, 0, n-1}];
diagonal = Table[127.0 + 127.0 Sin[2 Pi (x+y) 4/n], {y, 0, n-1}, {x, 0, n-1}];

tests = {{"box", box}, {"lines", lines}, {"gaussian", gaussian}, {"diagonal", diagonal}};

Do[
  {name, spatial} = test;
  ft = Fourier[spatial, FourierParameters -> {1, -1}];

  (* FFT shift: move DC to center *)
  shifted = RotateLeft[ft, {n/2, n/2}];

  amp = Abs[shifted];
  phase = Arg[shifted];

  (* Spatial image: normalize to [0,1] *)
  spatialImg = Image[spatial / Max[spatial]];

  (* Amplitude: log scale, normalized *)
  logAmp = Log[1 + amp];
  ampImg = Image[logAmp / Max[logAmp]];

  (* Phase: map [-Pi, Pi] to [0, 1] *)
  phaseImg = Image[(phase + Pi) / (2 Pi)];

  (* Export individual images *)
  Export[outDir <> name <> "_spatial.png", spatialImg];
  Export[outDir <> name <> "_amplitude.png", ampImg];
  Export[outDir <> name <> "_phase.png", phaseImg];

  (* Side-by-side comparison *)
  combined = ImageAssemble[{{
    Labeled[ImageResize[spatialImg, 256], Style["Spatial", White, 12], Bottom],
    Labeled[ImageResize[ampImg, 256], Style["Amplitude (log)", White, 12], Bottom],
    Labeled[ImageResize[phaseImg, 256], Style["Phase", White, 12], Bottom]
  }}];
  Export[outDir <> name <> "_comparison.png", combined];

  Print["Exported: " <> name];
  ,
  {test, tests}
];

Print["Done generating comparison images."];
