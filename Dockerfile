FROM curlimages/curl@sha256:58adaa4e8dca9c988bae2aba4ab3434a0bb2da16bbe3f92dec39ec7785166777 AS build

ARG EASYEPG_LITE_SHA="836823d0ace717cbaa70ed3d7c874ca5de585fb3"

RUN \
    echo "**** download easyepg-lite ****" && \
    curl -sSL https://github.com/sunsettrack4/script.service.easyepg-lite/archive/${EASYEPG_LITE_SHA}.tar.gz | tar -xzvf- && \
    mv script.service.easyepg-lite-* easyepg-lite && \
    echo "**** remove unnecessary files ****" && \
    rm easyepg-lite/*.md && \
    rm easyepg-lite/*.png && \
    rm easyepg-lite/*.jpg && \
    rm easyepg-lite/addon.*

FROM python:3.14-alpine@sha256:c6ead215bfd31f1e433d968853b7a769989117115b728874824e6c0a27cb96fc

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
