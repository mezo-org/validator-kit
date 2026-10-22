# skip-mev/connect is archived, so its published images and binaries keep the
# Go toolchain they were released with. This rebuilds the same connect release
# with a newer Go. Based on upstream contrib/images/connect.sidecar.prod.Dockerfile.
FROM golang:1.26.10-bookworm@sha256:632dff7351799a5a9954a48dc06670ade72ee44e8c351cdc0e5a57af2fea21af AS builder

ARG CONNECT_VERSION=v2.1.2
# Commit of the CONNECT_VERSION tag. Update both together.
ARG CONNECT_COMMIT=7355199cc4b18ff6d7f2f07ec877b64875b57527

# Stops the go.mod toolchain line from switching the build to another Go version.
ENV GOTOOLCHAIN=local

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN git clone --depth 1 --branch ${CONNECT_VERSION} https://github.com/skip-mev/connect /src/connect \
    && test "$(git -C /src/connect rev-parse HEAD)" = "${CONNECT_COMMIT}"

WORKDIR /src/connect

# `make build` runs `go mod tidy`, which can edit go.mod and add a -dirty
# suffix to the default TAG.
RUN make build TAG=${CONNECT_VERSION}

RUN for bin in build/*; do \
        test "$(go version "${bin}" | cut -d ' ' -f 2)" = "$(go env GOVERSION)" || exit 1; \
    done \
    && echo "${CONNECT_VERSION}-$(go env GOVERSION)" > /src/build-tag

# Export with `docker buildx build --target binaries --output type=local,dest=<dir>`.
FROM scratch AS binaries

COPY --from=builder /src/connect/build/ /
COPY --from=builder /src/build-tag /

FROM gcr.io/distroless/base-debian12:debug@sha256:0a5b69081973d7069cbeab49c24851dd517887767e934fc8e6f808ea08770ef4
EXPOSE 8080 8002

COPY --from=builder /src/connect/build/* /usr/local/bin/

WORKDIR /usr/local/bin/
CMD [ "connect" ]
