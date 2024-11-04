# 2024 U.S Presidential Election Forecast
## Overview
This paper uses a poll-of-polls approach and a Bayesian model to predict the 2024 Presidential Election results between Harris and Trump. A poll-of-polls is a statistical method that uses multiple datasets instead of just one for more accurate analysis. The prediction suggests that Harris will receive 47.75% of the popular vote.

The aggreagated dataset can be found at: https://projects.fivethirtyeight.com/polls/president-general/2024/national/.

## File Structure
The repo is structured as:
-   `paper` contains the files used to generate the paper, including the Quarto document and reference bibliography, as well as the PDF of the paper. 
-   `scripts` contains the R scripts used to simulate, download, clean, test the data, and the script used to create the model, as well as an out-of-sample testing that shows the model is not overfit.
-   `model` contains the model generated.
-   `other` contains the sketches and chats with ChatGPT.
-   `data` contains the raw and cleaned datasets used to forecast the election.

## LLM Usage
ChatGPT was used to generate and modify codes, as well as improving writings. Chats could be found in `other/llm`.

