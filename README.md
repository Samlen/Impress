# Impress

Version 0.1.0

PROJECT:	  Pesticide Uganda
PURPOSE: 	  Analysis of neuro test scores with yearly pesticide exposure scores
Git hub:    git@github.com:Samlen/Impress.git
FILENAME:   NeuroPesticides_all outcomes
PATH:		    "../data/raw/Analysis_Exposure_Neuro_clean.dta"
CREATED: 	  01.05.2019       
AUTHOR:     S Fuhrimann
DATA IN:  	Analysis_Exposure_Neuro_clean.dta
DATA OUT: 	
UPDATES:	  SF - 09.01.2020 update according to paper draft version 2
NOTES:	    # 14 neuro different test scores, 298 obs, 256 complete for all neur tests
            # Linear regression models
            
How to get started:
  Scripts are written in R
  Different steps are outlined in each R script under --> # Content
  Make sure that all the packages are installed in R studio --> # 0. Library

## Project organization

```
.
├── .gitignore
├── CITATION.md
├── LICENSE.md
├── README.md
├── requirements.txt
├── bin                <- Compiled and external code, ignored by git (PG)
│   └── external       <- Any external source code, ignored by git (RO)
├── config             <- Configuration files (HW)
├── data               <- All project data, ignored by git
│   ├── processed      <- The final, canonical data sets for modeling. (PG)
│   ├── raw            <- The original, immutable data dump. (RO)
│   └── temp           <- Intermediate data that has been transformed. (PG)
├── docs               <- Documentation notebook for users (HW)
│   ├── manuscript     <- Manuscript source, e.g., LaTeX, Markdown, etc. (HW)
│   └── reports        <- Other project reports and notebooks (e.g. Jupyter, .Rmd) (HW)
├── results
│   ├── figures        <- Figures for the manuscript or reports (PG)
│   └── output         <- Other output for the manuscript or reports (PG)
└── src                <- Source code for this project (HW)


```


## License

This project is licensed under the terms of the [MIT License](/LICENSE.md)

## Citation

Please [cite this project as described here](/CITATION.md).
