# ================================
# Build image
# ================================
FROM swift:6.1-noble AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
COPY ./Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire repo into container
COPY . .

RUN mkdir /staging

# Build the application, with optimizations, with static linking, and using jemalloc
RUN --mount=type=cache,target=/build/.build \
    swift build -c release \
        --product iOS5Team1 \
        --static-swift-stdlib \
        -Xlinker -ljemalloc && \
    cp "$(swift build -c release --show-bin-path)/iOS5Team1" /staging && \
    find -L "$(swift build -c release --show-bin-path)" -regex '.*\.resources$' -exec cp -Ra {} /staging \;

# Switch to the staging area
WORKDIR /staging

# Copy static swift backtracer binary
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Public & Resources move (if exists)
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM ubuntu:noble

# Install runtime dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y \
        libjemalloc2 \
        libmysqlclient21 \
        ca-certificates \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

# Create vapor user
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

COPY --from=build --chown=vapor:vapor /staging /app

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["./iOS5Team1"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
