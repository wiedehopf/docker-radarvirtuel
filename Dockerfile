FROM ghcr.io/sdr-enthusiasts/docker-baseimage:mlatclient as downloader

FROM ghcr.io/sdr-enthusiasts/docker-baseimage:python

ENV PRIVATE_MLAT="false" \
    MLAT_INPUT_TYPE="dump1090"

COPY --from=downloader /mlatclient.tgz /src/mlatclient.tgz

# hadolint ignore=DL3008,SC2086,SC2039,SC2068,DL3003,DL3015,SC3054
RUN set -x && \
    # define packages needed for installation and general management of the container:
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    KEPT_PACKAGES+=(procps aptitude) && \
    KEPT_PACKAGES+=(psmisc) && \
    # Git and net-tools are needed to install and run @Mikenye's HealthCheck framework
    # TEMP_PACKAGES+=(git) && \
    # These are needed to compile and install the mlat_client:
    # TEMP_PACKAGES+=(build-essential) && \
    # TEMP_PACKAGES+=(debhelper) && \
    # TEMP_PACKAGES+=(python3-dev) && \
    # TEMP_PACKAGES+=(python3-distutils-extra) && \
    #
    # Install all these packages:
    apt-get update -q -y && \
    apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" -y --no-install-recommends  --no-install-suggests \
    ${KEPT_PACKAGES[@]} \
    ${TEMP_PACKAGES[@]} && \
    #
    # Compile and Install the mlat_client
    # mkdir -p /git && \
    # pushd /git && \
    # git clone --depth 1 $URL_MLAT_CLIENT_REPO && \
    # cd mlat-client && \
    # ./setup.py install && \
    # ln -s /usr/local/bin/mlat-client /usr/bin/mlat-client && \
    # popd && \
    # rm -rf /git && \
    #
    # New - install mlatclient that was copied in from downloader image
    tar zxf /src/mlatclient.tgz -C / && \
    #
    # Clean up
    # apt-get remove -q -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -q -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -y && \
    apt-get clean -q -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
    #
    # Do some stuff for kx1t's convenience:
    echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
    echo "alias nano=\"nano -l\"" >> /root/.bashrc

COPY rootfs/ /

# Add healthcheck
HEALTHCHECK --start-period=60s --interval=600s CMD /home/healthcheck/healthcheck.sh
