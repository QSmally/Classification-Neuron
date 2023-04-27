
# Classification Neuron

A demo to classify points in a graph to a given group using linear regression.

## Compilation

**Docker**:

```bash
$ docker build -t neuron .
$ docker run --rm -it -v "$(pwd)/Demo:/mnt" neuron
neuron% # Demo/ is now mounted to /mnt
neuron% classifier # <args...>
```

**Native (Zig compiler)**:

```bash
$ zig build
$ ./zig-out/bin/classifier # <args...>
```

Or alternatively, use the run step of the Zig build system:

```bash
$ zig build run -- # <args...>
```

# Tests

Unit tests are included for the training implementation:

```bash
$ zig build test
```

## Usage

See `Demo/`, `Demo/dataset_0/` and `Demo/run/points_0/` for details about the in-/output formats.

**Train**: from an annotated points (x/y/group) dataset, trains the model using linear regression
and outputs the model weights to stdout.

`classifier train <annotated points>`

```bash
$ classifier train dataset_0/annotated.json # dry run
$ classifier train dataset_0/annotated.json > dataset/weights.json # save output
```

**SVG**: from any type of points file, converts it to an SVG format and outputs it to stdout.

`classifier svg <any points>`

```bash
$ classifier svg run/points_0.json # dry run
$ classifier svg dataset_0/annotated.json # dry run, colours annotated points
$ classifier svg dataset_0/annotated.json > dataset_0/annotated.svg # save output
```

**Test**: from a weights file generated with `classifier train`, runs a points file through the
model and compares the calculated result with the associated annotation to see if it's correct. It
outputs the log to stdout.

`classifier test <weights> <annotated points>`

```bash
$ classifier test dataset_0/weights.json dataset_0/annotated.json # through trained dataset
$ classifier test dataset_0/weights.json dataset_0/annotated.test.json # through unseen dataset
```

**Run**: from a weights file generated with `classifier train`, runs a directory of points files
through the model and outputs it to `<directory>/<dataset>/<image>/` along with the SVG of both
in-/output.

`classifier run <weights> <points directory>`

```bash
$ classifier run dataset_0/weights.json run/ # output written to run/dataset_0/*/...
```
