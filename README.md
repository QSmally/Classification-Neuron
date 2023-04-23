
# Classification Neuron

A demo to classify points in a graph to a given group using linear regression.

## Build

**Docker**:

```bash
$ docker build -t neuron .
$ docker run --rm -it -v "$(pwd)/Demo:/mnt" neuron
neuron% classifier # ...
```

**Native (Zig compiler)**:

```bash
$ zig build
$ ./zig-out/bin/classifier # ...
```

## Usage

See the `Demo/` subdirectories for more information about the in-/output formats.

* **Train**: trains from an `annotated.json` dataset and outputs a `weights.json` (W: uses I/O redirection)
    - Generic interface: `classifier train <input/dataset.json> > <output/weights.json>`
    - Docker: `classifier train /mnt/dataset_0/annotated.json > /mnt/dataset_0/weights.json`
    - Native: `./zig-out/bin/classifier train ./Demo/dataset_0/annotated.json > ./Demo/dataset_0/weights.json`
* **Test**: tests the generated `weights.json` on a particular annotated dataset
    - Generic interface: `classifier test <input/dataset.json> <input/weights.json>`
    - Docker: `classifier test /mnt/dataset_0/annotated_test.json /mnt/dataset_0/weights.json`
    - Native: `./zig-out/bin/classifier test ./Demo/dataset_0/annotated_test.json ./Demo/dataset_0/weights.json`
* **Run**: runs the generated `weights.json` on a particular non-annotated set of inputs
    - Generic interface: `classifier run <input/weights.json> <input/images/> <output/images/>`
    - Docker: `classifier run /mnt/dataset_0/weights.json /mnt/inputs/ /mnt/outputs/`
    - Native: `./zig-out/bin/classifier run ./Demo/dataset_0/weights.json ./Demo/inputs/ ./Demo/outputs/`

# Test

```bash
$ zig test Sources/trainer.zig
```
