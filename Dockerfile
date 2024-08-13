FROM python:3.11-bookworm as builder

RUN apt-get update && apt-get -y upgrade && apt-get install -y cmake && apt-get -y clean && mkdir  -p /app/ && python3 -m venv /app/.venv 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
COPY requirements.txt /app/
RUN cd app && source .venv/bin/activate && pip3 install -r requirements.txt 

FROM python:3.11-bookworm as runtime-image
RUN apt-get update && apt-get -y upgrade && apt-get -y clean
RUN useradd --create-home --shell /bin/sh  --uid 8000 opencost
COPY --from=builder /app /app 
COPY src/opencost_parquet_exporter.py /app/opencost_parquet_exporter.py
COPY src/data_types.json /app/data_types.json
COPY src/rename_cols.json /app/rename_cols.json
COPY src/ignore_alloc_keys.json /app/ignore_alloc_keys.json
RUN chmod 755 /app/opencost_parquet_exporter.py && chown -R opencost /app/  
USER opencost
ENV PATH="/app/.venv/bin:$PATH"
CMD ["/app/opencost_parquet_exporter.py"]
ENTRYPOINT ["/app/.venv/bin/python3"]
