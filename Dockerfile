FROM ubuntu:18.04

RUN apt-get update && apt-get install -y  \
      openssh-client \
      openssh-server \
      build-essential \
      libmpich-dev && \
    rm -rf /var/lib/apt/lists/*

ARG USER=mpi
ENV USER ${USER}
ENV USER_HOME /home/${USER}
RUN adduser --disabled-password ${USER} && \
    echo "${USER}   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R ${USER}:${USER} ${USER_HOME}

# ENV HYDRA_HOST_FILE /etc/opt/hosts
# RUN echo "export HYDRA_HOST_FILE=${HYDRA_HOST_FILE}" >> /etc/profile && \
#     touch ${HYDRA_HOST_FILE} && \
#     chown ${USER}:${USER} ${HYDRA_HOST_FILE}

ENV SSHDIR ${USER_HOME}/.ssh
COPY ssh/ ${SSHDIR}/
RUN sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config && \
    sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config && \
    passwd -u ${USER} && \
    mkdir -p ${SSHDIR} && mkdir /run/sshd && \
    cat ${SSHDIR}/*.pub >> ${SSHDIR}/authorized_keys && \
    chmod -R 600 ${SSHDIR}/* && \
    chown -R ${USER}:${USER} ${SSHDIR} && \
    echo "StrictHostKeyChecking no" > ${SSHDIR}/config

ENV TESTDIR ${USER_HOME}/test
RUN mkdir ${TESTDIR}
COPY test/ ${TESTDIR}
RUN mpicc -o ${TESTDIR}/test ${TESTDIR}/test.c

ENTRYPOINT service ssh start && tail -f /dev/null