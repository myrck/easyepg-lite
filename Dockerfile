FROM curlimages/curl AS build

RUN \
    echo "**** download easyepg-lite ****" \
    && curl -sSL https://github.com/sunsettrack4/script.service.easyepg-lite/archive/5fd34170e505ac19818905af735ec3c996ed2e95.tar.gz | tar -xzvf- \
    && mv script.service.easyepg-lite-* easyepg-lite \
    && echo "**** remove unnecessary files ****" \
    && rm easyepg-lite/*.md \
    && rm easyepg-lite/*.png \
    && rm easyepg-lite/*.jpg \
    && rm easyepg-lite/addon.*

FROM python:3.14-alpine

RUN \
    echo "**** install dependencies ****" \
    && pip install --no-cache-dir \
        beautifulsoup4 \
        bottle \
        requests \
        xmltodict

WORKDIR /app

RUN addgroup -g 1000 easyepg \
    && adduser --shell /sbin/nologin --disabled-password \
    --no-create-home --uid 1000 --ingroup easyepg easyepg \
    && mkdir /data \
    && chown -R easyepg:easyepg /app /data

COPY --from=build --chown=easyepg:easyepg /home/curl_user/easyepg-lite /app
COPY --chown=easyepg:easyepg main.py .

USER easyepg

HEALTHCHECK --start-period=10s --start-interval=1s --interval=30s --timeout=5s --retries=3 \
    CMD wget --no-verbose -Y off --tries=1 --spider http://127.0.0.1:4000/ || exit 1

VOLUME /data
EXPOSE 4000

CMD ["python", "main.py"]
