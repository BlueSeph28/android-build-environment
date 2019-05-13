FROM ubuntu:18.04

MAINTAINER BlueSeph28 - Luis Fernando López Ruiz

WORKDIR /android-project

ENV VERSION_SDK_TOOLS "4333796"
ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools"

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# Remember always first update apt-get
RUN apt-get update

# Installing packages
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
    bzip2 \
    curl \
    git-core \
    html2text \
    openjdk-8-jdk \
    libc6-i386 \
    lib32stdc++6 \
    lib32gcc1 \
    lib32ncurses5 \
    lib32z1 \
    unzip \
    locales \
    zipalign \
    python-pip \
    python-setuptools \
    awscli && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8
RUN locale-gen $LANG

RUN pip install google-api-python-client && pip install oauth2client && pip install pyOpenSSL

RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > /sdk.zip && \
    unzip /sdk.zip -d /sdk && \
    rm -v /sdk.zip

# Accept Terms and conditions of ANDROID SDK
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

ADD basic_upload_apks_service_account.py /android-project
ADD run.sh /android-project

ENTRYPOINT [ "bash", "/run.sh" ]