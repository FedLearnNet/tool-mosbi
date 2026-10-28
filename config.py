from pathlib import Path
from typing import Any

from pydantic.dataclasses import dataclass
from pyfedappwrap.learning.run_runfig import AppConfig, AppInputConfig, AppOutputConfig

@dataclass
class MyAppConfig(AppConfig):
    n_randomizations: int = 5
    margin: str = "both"
    metric: str = "Bray-Curtis"
    n_steps: int = 100
    sn_ratio: bool = True


@dataclass
class MyAppInputConfig(AppInputConfig):
    data: Any = None


# outputs
@dataclass
class MyAppOutputConfig(AppOutputConfig):
    adjacency_heatmap: Path | None = None
    histograms: Path | None = None
    network_by_algorithm: Path | None = None
    network_plot: Path | None = None
