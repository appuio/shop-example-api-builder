# extend the base image provided by OpenShift
FROM openshift/base-centos7

# set labels used in OpenShift to describe the builder image
LABEL \
    io.k8s.description="Platform for building Scala Play! applications" \
    io.k8s.display-name="scala-play" \
    io.openshift.expose-services="9000:http" \
    io.openshift.tags="builder,scala,play" \
    # location of the STI scripts inside the image.
    io.openshift.s2i.scripts-url=image://$STI_SCRIPTS_PATH

# specify wanted versions of Java and SBT
ENV JAVA_VERSION=1.8.0 \
    SBT_VERSION=0.13.13.1 \
    HOME=/opt/app-root \
    PATH=/opt/app-root/bin:$PATH

# add the repository for SBT to the yum package manager
COPY bintray--sbt-rpm.repo /etc/yum.repos.d/bintray--sbt-rpm.repo

# install Java and SBT
RUN yum install -y \
        java-${JAVA_VERSION}-openjdk \
        java-${JAVA_VERSION}-openjdk-devel \
        sbt-${SBT_VERSION} && \
    yum clean all -y

# initialize SBT
RUN sbt -ivy /opt/app-root/src/.ivy2 about

# chown the ivy directories to the correct user
RUN chown -R 1001:0 /opt/app-root/src && \
    chmod -R g+rw /opt/app-root/src /usr/libexec/s2i

# copy the s2i scripts into the image
COPY ./.s2i/bin $STI_SCRIPTS_PATH

# expose the default Play! port
EXPOSE 9000

# switch to the user 1001
USER 1001

# show usage info as a default command
CMD ["usage"]