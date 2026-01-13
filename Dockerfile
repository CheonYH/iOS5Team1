# ================================
# Build image
# ================================
FROM swift:6.1-noble AS build

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev

WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

COPY . .

RUN mkdir /staging

RUN --mount=type=cache,target=/build/.build \
    swift build -c release \
        --product iOS5Team1 \
        --static-swift-stdlib \
        -Xlinker -ljemalloc && \
    cp "$(swift build -c release --show-bin-path)/iOS5Team1" /staging && \
    find -L "$(swift build -c release --show-bin-path)" -regex '.*\.resources$' -exec cp -Ra {} /staging \;

WORKDIR /staging

RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM ubuntu:noble

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y \
        libjemalloc2 \
        libmysqlclient21 \
        ca-certificates \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

COPY --from=build --chown=vapor:vapor /staging /app

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

USER vapor:vapor

EXPOSE 8080

# 핵심 변경
CMD ["./iOS5Team1", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "$PORT"]
