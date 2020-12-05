FROM quay.io/jupyteronopenshift/s2i-minimal-notebook-py36:2.5.1

USER root

RUN yum update --assumeyes --skip-broken && \
    yum -y install epel-release && \
    yum -y update && \
    yum install --assumeyes gfortran && \
    yum clean all

ENV XDG_CACHE_HOME=/opt/app-root/src/.cache

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.5.3

WORKDIR /tmp

RUN mkdir "/opt/julia-${JULIA_VERSION}" && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/$(echo "${JULIA_VERSION}" | cut -d. -f 1,2)"/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" && \
    echo "fd6d8cadaed678174c3caefb92207a3b0e8da9f926af6703fb4d1e4e4f50610a *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf "julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -C "/opt/julia-${JULIA_VERSION}" --strip-components=1 && \
    rm "/tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

WORKDIR $HOME

USER 1001

RUN julia -e 'using Pkg; Pkg.update(); Pkg.add("IJulia"); ' && \
    julia -e 'using IJulia; ' 

CMD [ "/opt/app-root/builder/run" ]
