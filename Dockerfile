FROM quay.io/jupyteronopenshift/s2i-minimal-notebook-py36:2.5.1

USER root

ARG julia_version="1.5.3"
ARG julia_checksum="f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1"
ENV JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia \
    JULIA_VERSION="${julia_version}"

WORKDIR /tmp

RUN mkdir "/opt/julia-${JULIA_VERSION}" && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/$(echo "${JULIA_VERSION}" | cut -d. -f 1,2)"/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" && \
    echo "${julia_checksum} *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf "julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -C "/opt/julia-${JULIA_VERSION}" --strip-components=1 && \
    rm "/tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

RUN mkdir /etc/julia && \
    mkdir "${JULIA_PKGDIR}" && \
    chown "${NB_USER}" "${JULIA_PKGDIR}" && \
    fix-permissions "${JULIA_PKGDIR}"

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src && \
    rm -rf /tmp/scripts && \
    mv /tmp/src/.s2i/bin /tmp/scripts

ENV XDG_CACHE_HOME=/opt/app-root/src/.cache

USER 1001

RUN /tmp/scripts/assemble

RUN julia -e 'using Pkg; Pkg.update(); Pkg.add("IJulia"); ' && \
    julia -e 'using IJulia; ' 

CMD [ "/opt/app-root/builder/run" ]
