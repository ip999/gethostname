###################################################################################################
## Builder
####################################################################################################
FROM rust:latest AS builder

RUN apt update && apt install -y musl-tools musl-dev
RUN update-ca-certificates

# Create appuser
ENV USER=rustapp
ENV UID=10001
ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=6666

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR /app

COPY ./ .

RUN rustup default nightly
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --target x86_64-unknown-linux-musl --release
RUN strip -s /app/target/x86_64-unknown-linux-musl/release/rustapp
####################################################################################################
## Final image
####################################################################################################
FROM scratch

# Import from builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /app

# Copy our build
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/rustapp ./

# Use an unprivileged user.
USER rustapp:rustapp

CMD ["/app/rustapp"]
