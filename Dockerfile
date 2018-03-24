FROM alpine:latest
ENV NAME sftp
ENV SSH_USER cornelius
ENV SSH_UID 1234
ENV AUTHORIZED_KEYS ""
WORKDIR /ssh
COPY ["./ssh", "/ssh"]
RUN ["/bin/sh", "/ssh/bin/build.sh"]
EXPOSE 22/tcp
VOLUME ["/ssh/"]
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/sh", "/ssh/bin/init.sh"]

