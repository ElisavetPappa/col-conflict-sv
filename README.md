Analysis code and results for the study

# Understanding Sexual Violence in the Colombian Armed Conflict: Victim Characteristics, Spatial Clustering, and Temporal Contagion


<p align="center">
	<a href="https://en.wikipedia.org/wiki/R_(programming_language)"><img
		alt="R Programming Language"
		src="https://img.shields.io/badge/Language-R-%232268BB.svg"></a>
	<a href="https://en.wikipedia.org/wiki/Project_Jupyter#Jupyter_Notebook"><img
		alt="Jupyter Notebook"
		src="https://img.shields.io/badge/Jupyter-Notebook-68B7EB"></a>
	<a href="https://opensource.org/licenses/MIT"><img
		alt="MIT License"
		src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
</p>

### Publication status
In preparation

### Archive contents
This archive contains the [R](https://en.wikipedia.org/wiki/R_(programming_language)) code for the analyses reported in the above study. The code is presented as [Jupyter notebooks](https://jupyter-notebook-beginner-guide.readthedocs.io/en/latest/what_is_jupyter.html) which are documents that combine both code and the output in a form that can be viewed online, but also re-run and the results reproduced when accompanied by the original dataset.

1.  [Pappa_et_al_EntireConflict.ipynb](https://github.com/ElisavetPappa/col-conflic-sv/blob/main/Pappa_et_al_EntireConflict.ipynb) - Jupyter notebook with reproducible analysis for 1964-2024
2.  [Pappa_et_al_2014-2024.ipynb](https://github.com/ElisavetPappa/col-conflic-sv/blob/main/Pappa_et_al_2014-2024.ipynb) - Jupyter notebook with reproducible analysis for 2014-2024
3.  [Output](https://github.com/ElisavetPappa/col-conflic-sv/tree/main/Output) - Directory with figures saved to storage by the Jupyter Notebooks 
4.  [Data](https://github.com/ElisavetPappa/col-conflic-sv/tree/main/Data) - Directory with the open data used in these analyses

The NCMH dataset used in the LGCP and Hawkes process model analyses is the open dataset from the Centro Nacional de Memoria Histórica which can be [accessed here](https://micrositios.centrodememoriahistorica.gov.co/observatorio/portal-de-datos/base-de-datos/). Because this data is updated monthly, we provide the files we used containing the exact data used in our study in the Data folder for reproducibility. This also contains open data for yearly population by municipio which is automatically downloaded and saved by the analysis code if it doesn't already exist using the [ColOpenData](https://epiverse-trace.github.io/ColOpenData/) package.

### Platform and package versions

To aid reproducibility, the platform (hardware, operating system), R language version, and package versions used to generate the results are automatically generated at runtime and reported at the end of the Jupyter notebook.
