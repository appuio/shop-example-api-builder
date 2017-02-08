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
    SBT_VERSION=0.13.13.1-1 \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/bin:$PATH

# add the repository for SBT to the yum package manager
COPY bintray--sbt-rpm.repo /etc/yum.repos.d/bintray--sbt-rpm.repo

# install Java and SBT
RUN yum install -y \
        java-${JAVA_VERSION}-openjdk \
        java-${JAVA_VERSION}-openjdk-devel \
        sbt && \
    yum clean all -y

# copy the s2i scripts into the image
COPY ./.s2i/bin $STI_SCRIPTS_PATH

# chown the ivy directories to the correct user
RUN chown -R 1001:0 /opt/app-root && \
    chmod -R g+rw /opt/app-root && \
    chmod -R g+rx $STI_SCRIPTS_PATH

# expose the default Play! port
EXPOSE 9000

# switch to the user 1001
USER 1001

# initialize SBT
RUN sbt -ivy ${HOME}/.ivy2 about

# show usage info as a default command
CMD ["usage"]