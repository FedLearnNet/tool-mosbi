from pathlib import Path
from typing import Optional

from pyfedappwrap.learning.app_types import BaseSelfLearnedApp
from typing_extensions import override

from config import MyAppConfig, MyAppInputConfig, MyAppOutputConfig
from model import mosbi


class MyAPP(BaseSelfLearnedApp[MyAppConfig, MyAppInputConfig, MyAppOutputConfig]):

    def __init__(self):
        super().__init__()

    def run_algorithm(self, data: MyAppInputConfig) -> MyAppOutputConfig:
        output_dir = Path("./output")
        output_dir.mkdir(exist_ok=True, parents=True)
        data.data.to_csv("used.csv", index=False)
        results = mosbi(
            data_file_path=Path("used.csv"),
            output_dir=output_dir,
            n_randomizations=self.config.n_randomizations,
            margin=self.config.margin,
            metric=self.config.metric,
            n_steps=self.config.n_steps,
            sn_ratio=self.config.sn_ratio,
        )
        return MyAppOutputConfig(
            adjacency_heatmap=results["adjacency_heatmap"],
            histograms=results["histograms"],
            network_by_algorithm=results["network_by_algorithm"],
            network_plot=results["network_plot"],
        )

    @override
    def get_test_data(self) -> Optional[dict[str, Path]]:
        return {"data": Path("data/A.n_genes=500,m=4,std=1,overlap=no.exprs_z.tsv")}
