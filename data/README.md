# Data Source & Instructions

The raw dataset used in this project is the **Brazilian E-Commerce Public Dataset by Olist**, available on Kaggle.

- **Source:** [Kaggle - Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Format:** CSV files (anonymized real commercial data containing ~100k orders from 2016 to 2018).

## Note on Repository Storage
To keep this repository lightweight, the raw `.csv` files and the generated `ecommerce.db` file are excluded via `.gitignore`. 

### Setup Instructions:
1. Download the zip archive directly from the Kaggle link above.
2. Extract all `.csv` files into this `data/` folder.
3. Run the setup script from the project root:
   ```bash
   python scripts/setup_database.py
