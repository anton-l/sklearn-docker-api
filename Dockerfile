FROM continuumio/miniconda3:4.7.10

# run the CMD below using bash
ENTRYPOINT [ "/bin/bash", "-c" ]

# other containers on the same docker network will be able to access this port
EXPOSE 5000

# default environment variables
ENV APP_MODULE=service.api:app
ENV HOST=0.0.0.0
ENV PORT=5000
ENV WORKERS=2
ENV LOG_LEVEL=info

# update packages and install anything that we may need later (compilers for conda and git for remote pip installs)
RUN apt-get update \
     && apt-get install --no-install-recommends --no-install-suggests -y build-essential git \
     && rm -rf /var/lib/apt/lists/*

# update conda
RUN pip uninstall -y setuptools && conda install setuptools nomkl \
      && conda update -y conda

# update conda base env and cleanup caches
COPY ./conda-env.yml /app/conda-env.yml
RUN conda env update -n base -f /app/conda-env.yml && conda clean --all

# create and use a non-root user for security reasons
RUN useradd -ms /bin/bash dummy
USER dummy

# copy the sources and models inside the container
COPY ./service   /app/service
COPY ./models    /app/models
# "cd" to the service directory
WORKDIR /app

ENV PYTHONPATH=/app
# run uvicorn server with path to the main app
CMD ["uvicorn --host $HOST --port $PORT --workers $WORKERS --log-level $LOG_LEVEL \"$APP_MODULE\""]
