
FROM homebrew/brew AS compiler

RUN brew update && brew install zig

WORKDIR /build
COPY . /build
RUN zig build -Drelease-safe

FROM ubuntu:20.04 AS output

COPY --from=compiler /build/zig-out/bin /usr/bin
CMD ["/bin/bash"]
