# mosbi

Identifies molecular signatures with MoSBi ensemble biclustering and exports biclusters and reports.

## Runtime inputs

The Dockerfile installs R/Bioconductor packages required by the MoSBi bridge.

## Inputs and outputs

### Inputs

| Name | Type | Description |
| --- | --- | --- |
| `data` | CSV | TSV file |

### Outputs

| Name | Type | Description |
| --- | --- | --- |
| `adjacency_heatmap` | IMAGE |  |
| `histograms` | IMAGE |  |
| `network_by_algorithm` | IMAGE |  |
| `network_plot` | IMAGE |  |

## Configuration

| Name | Default | Description |
| --- | --- | --- |
| `n_randomizations` | `5` | Number of randomizations for cut-off estimation. |
| `margin` | `both` | Margin for similarity computation |
| `metric` | `Bray-Curtis` | Similarity metric |
| `n_steps` | `100` | Number of points where the cut-off is evaluated |
| `sn_ratio` | `true` | Compute signal-to-noise ratio if True, else use error_threshold |

## Development

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
cp .env.example .env
# Set APP_ID and platform URLs before connecting.
python main.py
```

The Docker base image provides the FL-Net API. `requirements.txt` lists additional
runtime dependencies; `requirements-dev.txt` includes the API for local development.
Runtime datasets and trained models must be supplied separately; see `data/README.md`.

Build with `docker build -t tool-mosbi .`.
