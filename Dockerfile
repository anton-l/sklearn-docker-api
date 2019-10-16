FROM continuumio/miniconda3:4.7.10

# run the CMD below using bash
ENTRYPOINT [ "/bin/bash", "-c" ]

# other containers on the same docker network will be able to access this port
EXPOSE 5000

# default environment variables
ENV APP_MODULE=api:app
ENV HOST=0.0.0.0
ENV PORT=5000
ENV WORKERS=2
ENV LOG_LEVEL=info

RUN set -x \
     && apt-get update \
     && apt-get install --no-install-recommends --no-install-suggests -y libpq-dev build-essential \
     && rm -rf /var/lib/apt/lists/*

# update conda, pre-install base dependencies
RUN pip uninstall -y setuptools && conda install setuptools \
      && conda update -y conda \
      && conda install -y pip numpy scipy  \
      && pip install uvicorn

# update conda base env and cleanup caches
COPY ./conda-env.yml /app/conda-env.yml
RUN conda env update -n base -f /app/conda-env.yml && conda clean --all

# copy the sources
COPY . /app
# "cd" to the app directory
WORKDIR /app

# run uvicorn server with path to the main app
CMD ["uvicorn --host $HOST --port $PORT --workers $WORKERS --log-level $LOG_LEVEL \"$APP_MODULE\""]