ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_VERSION

# Create Working Directory
WORKDIR /app

# Install enoceanmqtt and requirements
RUN apk add --no-cache python3 py3-pip git && \
    python3 -m pip install --upgrade pip && \
    pip3 install pyyaml && \
    pip3 install tinydb && \
    pip3 install git+https://github.com/mak-gitdev/enocean.git && \
    git clone https://github.com/embyt/enocean-mqtt.git && \
    cd enocean-mqtt && python3 setup.py develop && cd .. && \
    if [ "${BUILD_VERSION}" = "head" ]; then \
        echo "Installing from repository head" && \
        git clone -b develop --single-branch --depth 1 https://github.com/mak-gitdev/HA_enoceanmqtt.git ; \
    else \
        if [ -z "${BUILD_VERSION##*.*.*}" ]; then \
            echo "Installing development version ${BUILD_VERSION%-*}" ; \
        else \
            echo "Installing stable version ${BUILD_VERSION%-*}" ; \
        fi; \
        wget -nv -O "/app.tar.gz" \
            "https://github.com/mak-gitdev/HA_enoceanmqtt/archive/refs/tags/${BUILD_VERSION%-*}.tar.gz" && \
        echo "Extracting /app.tar.gz" && tar xzf "/app.tar.gz" && \
        rm "/app.tar.gz" && \
        mv -v "HA_enoceanmqtt-${BUILD_VERSION%-*}" HA_enoceanmqtt ; \
    fi; \
    cp -rf HA_enoceanmqtt/enoceanmqtt enocean-mqtt && \
    rm -rf HA_enoceanmqtt

# Copy data for add-on
COPY run.sh .
RUN chmod a+x run.sh

CMD [ "/app/run.sh" ]
