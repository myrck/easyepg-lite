FROM curlimages/curl@sha256:935d9100e9ba842cdb060de42472c7ca90cfe9a7c96e4dacb55e79e560b3ff40 AS build

ARG EASYEPG_LITE_SHA="d91ea803fab8d016cc7733f7adc2ee1ad81aa7a4"

RUN \
    echo "**** download easyepg-lite ****" && \
    curl -sSL https://github.com/sunsettrack4/script.service.easyepg-lite/archive/${EASYEPG_LITE_SHA}.tar.gz | tar -xzvf- && \
    mv script.service.easyepg-lite-* easyepg-lite && \
    echo "**** remove unnecessary files ****" && \
    rm easyepg-lite/*.md && \
    rm easyepg-lite/*.png && \
    rm easyepg-lite/*.jpg && \
    rm easyepg-lite/addon.*

FROM python:3.14-alpine@sha256:8373231e1e906ddfb457748bfc032c4c06ada8c759b7b62d9c73ec2a3c56e710

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
