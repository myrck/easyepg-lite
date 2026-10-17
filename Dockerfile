FROM curlimages/curl@sha256:a134550be58ab783810e613ae96fd253c38f7bdd16d9bf9be350700c7a29ac06 AS build

ARG EASYEPG_LITE_SHA="49bdfe5400e8cdadcd9df1f4245263080f7c30ab"

RUN \
    echo "**** download easyepg-lite ****" && \
    curl -sSL https://github.com/sunsettrack4/script.service.easyepg-lite/archive/${EASYEPG_LITE_SHA}.tar.gz | tar -xzvf- && \
    mv script.service.easyepg-lite-* easyepg-lite && \
    echo "**** remove unnecessary files ****" && \
    rm easyepg-lite/*.md && \
    rm easyepg-lite/*.png && \
    rm easyepg-lite/*.jpg && \
    rm easyepg-lite/addon.*

FROM python:3.15-alpine@sha256:2699b90f4d562a22e2dd076c82f964032f64814204bff36d271a54ba4cc2c7e2

RUN \
    echo "**** install dependencies ****" && \
    pip install --no-cache-dir \
        beautifulsoup4 \
        bottle \
        requests \
        xmltodict

WORKDIR /app

RUN addgroup -g 1000 easyepg && \
    adduser --shell /sbin/nologin --disabled-password \
        --no-create-home --uid 1000 --ingroup easyepg easyepg && \
    mkdir /data && \
    chown -R easyepg:easyepg /app /data && \
    chmod 777 /app /data

COPY --from=build --chown=easyepg:easyepg /home/curl_user/easyepg-lite /app
COPY --chown=easyepg:easyepg main.py .

RUN \
    echo "**** apply workarounds to work on this docker ****" && \
    echo "Channel DB must be writable for everyone ..." && \
    chmod -R 777 /app/resources/data/db

USER easyepg

HEALTHCHECK --start-period=10s --start-interval=1s --interval=30s --timeout=5s --retries=3 \
    CMD wget --no-verbose -Y off --tries=1 --spider http://127.0.0.1:4000/ || exit 1

VOLUME /data
EXPOSE 4000

CMD ["python", "main.py"]
