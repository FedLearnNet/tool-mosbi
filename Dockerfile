FROM ghcr.io/fedlearnnet/python-tool-api/base-r-dep-biocmanager:0.7.15.dev

USER 0
ENV MAKEFLAGS=-j2
RUN apk add --no-cache cmake

RUN R -q -e 'options(repos = c(CRAN = "https://cloud.r-project.org"), Ncpus = 2); \
    dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE, showWarnings = FALSE); \
    if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager", lib = Sys.getenv("R_LIBS_USER")); \
    .libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths())); \
    install.packages(c("colorspace", "flexclust", "additivityTests", "tidyr", "ggplot2"), lib = Sys.getenv("R_LIBS_USER")); \
    install.packages("https://cran.r-project.org/src/contrib/Archive/biclust/biclust_2.0.3.1.tar.gz", repos = NULL, type = "source", lib = Sys.getenv("R_LIBS_USER")); \
    BiocManager::install(c("QUBIC", "mosbi"), ask = FALSE, update = FALSE, lib = Sys.getenv("R_LIBS_USER")); \
    if (!requireNamespace("mosbi", quietly = TRUE)) stop("mosbi did not install")'

USER 0
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chown -R nonroot:nonroot /app /opt/venv /usr/lib/R /usr/share/R /app/R/ \
 && chmod -R u+rwX,g+rwX /app /opt/venv /usr/lib/R /usr/share/R /app/R/

ENV MPLBACKEND=Agg

USER nonroot:nonroot

CMD ["python", "-m", "main"]
