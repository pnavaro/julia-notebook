FROM quay.io/jupyteronopenshift/s2i-minimal-notebook-py36:2.5.1

USER root

RUN yum update --assumeyes --skip-broken && \
    yum -y install epel-release && \
    yum -y update && \
    yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/nalimilan/julia/repo/epel-7/nalimilan-julia-epel-7.repo && \
    yum install --assumeyes julia && \
    yum clean all

ENV XDG_CACHE_HOME=/opt/app-root/src/.cache

USER 1001

RUN julia -e 'using Pkg; Pkg.update(); Pkg.add("IJulia"); ' && \
    julia -e 'using IJulia; ' 

CMD [ "/opt/app-root/builder/run" ]
