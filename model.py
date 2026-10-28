from typing import Literal
from pathlib import Path


def mosbi(
        data_file_path: Path,
        output_dir: Path,
        n_randomizations: int = 5,
        margin: Literal["row", "column", "mean", "both"] = "both",
        metric: Literal[
            "Bray-Curtis", "Jaccard", "Overlap Coefficient", "Fowlkes-Mallows"
        ] = "Bray-Curtis",
        n_steps: int = 100,
        sn_ratio: bool = True,
        error_threshold: float = 0.05,
        prob_scale: bool = False,
        prl: bool = False,
        plot_edge_dist: bool = True,
        return_plot_data: bool = False,
) -> dict[str, Path]:
    import ryp
    """
    A simple API for executing Multi-algorithm Ensemble Biclustering Method (MoSBi), 2022.
    Executes an R script with provided parameters, including MOSBI parameters.

    Args:
        data_file_path (str): Path to the input data file.
        output_dir (str): Path to the output directory.
        n_randomizations (int): Number of randomizations for cut-off estimation.
        margin: Margin for similarity computation
        metric (int): Similarity metric: 1=Bray-Curtis, 2=Jaccard, 3=Overlap Coefficient, 4=Fowlkes–Mallows
        n_steps (int): Number of points where the cut-off is evaluated.
        sn_ratio (bool): Compute signal-to-noise ratio if True, else use error_threshold
        error_threshold (float): Threshold for estimating the random overlaps
        prob_scale (bool): Scale similarity by probability of overlap
        prl (bool): Use multiple cores if MARGIN is "both"
        plot_edge_dist (bool): Show plots for cut-off estimation
        return_plot_data (bool): Internal use only


    See Also:
        - https://www.pnas.org/doi/full/10.1073/pnas.2118210119
    """

    metrics = {
        "Bray-Curtis": 1,
        "Jaccard": 2,
        "Overlap Coefficient": 3,
        "Fowlkes-Mallows": 4,
    }
    metric_int = metrics.get(metric, None)
    assert (
            metric_int is not None
    ), f"Unknown similarity metric '{metric}'. Available metrics [{', '.join(metrics.keys())}]"

    assert n_randomizations >= 1, "n_randomizations must be a positive integer."
    assert n_steps >= 1, "n_steps must be a positive integer."
    assert 0 <= error_threshold <= 1, "error_threshold must be between 0 and 1."

    # read script
    r_script_path = Path(__file__).parent / "mosbi_script.R"
    assert r_script_path.exists()
    with open(r_script_path, "r") as r_file:
        r_script: str = r_file.read()

    # Here we'd modify the script to insert the parameters.
    # The script (mosbi_script.R) expects arguments from the command line.
    # I don't want to change this behavior as someone might want to use
    # the script as it is (outside of this code).
    # So we'd replace usage of command line arguments.
    # This will look ugly for sure lol.

    # remove this piece of code
    r_script = r_script.replace(
        """args <- get("args", envir = .GlobalEnv)

if (length(args) < 11) {
    stop("File path and output path are required!", call.=FALSE)
}""",
        "",
    )

    # Painfully replace args[*] in the script.
    # The ordering of parameters must match usage in code.
    param_args = [
        data_file_path.as_posix(),
        output_dir.as_posix(),
        str(n_randomizations),
        margin,
        str(metric_int),
        str(n_steps),
        str(plot_edge_dist).upper(),
        str(sn_ratio).upper(),
        str(error_threshold),
        str(return_plot_data).upper(),
        str(prob_scale).upper(),
        str(prl).upper(),
    ]
    for idx, param in enumerate(param_args, start=1):
        r_script = r_script.replace(f"args[{idx}]", f'"{param}"')

    print(f"Executing R script {r_script_path} with parameters...")
    print(r_script)
    ryp.r(r_script)
    print(f"R script {r_script_path} has been executed successfully!")

    return {
        "adjacency_heatmap": output_dir / "bicluster_adjacency_heatmap.png",
        "histograms": output_dir / "bicluster_histograms.png",
        "network_by_algorithm": output_dir / "bicluster_network_by_algorithm.png",
        "network_plot": output_dir / "bicluster_network_plot.png",
    }
