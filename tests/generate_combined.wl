(* Generate combined side-by-side comparison images *)
n = 128;
outDir = DirectoryName[$InputFileName];
If[outDir == "", outDir = Directory[] <> "/"];

tests = {"box", "lines", "gaussian", "diagonal"};

Do[
  s = Import[outDir <> name <> "_spatial.png"];
  a = Import[outDir <> name <> "_amplitude.png"];
  p = Import[outDir <> name <> "_phase.png"];
  combined = ImageAssemble[{{
    ImageResize[s, 256],
    ImageResize[a, 256],
    ImageResize[p, 256]
  }}];
  Export[outDir <> name <> "_comparison.png", combined];
  Print["Combined: " <> name];
  ,
  {name, tests}
];
Print["Done."];
