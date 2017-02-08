FROM openjdk:8-jdk

MAINTAINER Roland Schläfli <roland.schlaefli@vshn.net>

# set labels used in OpenShift to describe the builder image
LABEL \
    io.k8s.description="Platform for building Scala Play! applications" \
    io.k8s.display-name="builder scala-play" \
    io.openshift.expose-services="9000:http" \
    io.openshift.tags="builder,scala,play" \
    # location of the STI scripts inside the image.
    io.openshift.s2i.scripts-url=image:///usr/libexec/s2i

ENV \
    SBT_VERSION=0.13.13 \
    HOME=/opt/app-root\
    PATH=/opt/app-root/bin:$PATH

# install SBT and other packages
RUN \
    apt-get update && \
    apt-get install -y apt-transport-https && \
    echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    apt-get update && \
    apt-get install -y sbt=$SBT_VERSION && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# copy the S2I scripts to /usr/libexec/s2i as specified in label above
COPY ./.s2i/bin/ /usr/libexec/s2i

# add a non root user and make it the owner of the application directory
RUN \
    mkdir /opt/app-root && \
    useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin -c "Default Application User" default && \
    chown -R 1001:0 /opt/app-root

# switch to the created 1001 user for execution
USER 1001
WORKDIR $HOME

# expose the default play app port
EXPOSE 9000

# set the default CMD for the image
CMD ["usage"]
