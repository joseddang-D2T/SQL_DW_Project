# Data Dictionary for GOLD layer (only required for End users)
## Overview
The Gold layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of DIMENSION and FACT tables for specific business metrics

### 1.gold.D_CUSTOMER_V

#### Description
The `gold.D_CUSTOMER_V` view provides a customer dimension, integrating CRM and ERP customer records.  
It consolidates key demographic, location, and lifecycle attributes, generating a surrogate key for consistent reference in analytics.  

---

#### Source Tables
- `silver.crm_cust_info` (Core customer information from CRM)
- `silver.erp_cust_az12` (ERP customer demographics such as birthdate)
- `silver.erp_loc_a101` (ERP customer location data)

---

#### Columns

| Column Name     | Data Type     | Description |
|-----------------|--------------|-------------|
| `CUSTOMER_KEY`   | INT           | Surrogate key generated via `ROW_NUMBER()` for dimensional joins. |
| `CUSTOMER_ID`    | STRING / INT  | Business identifier for the customer. |
| `CUSTOMER_NUMBER`| STRING / INT  | Internal customer reference number. |
| `FIRST_NAME`     | STRING        | Customer’s first name. |
| `LAST_NAME`      | STRING        | Customer’s last name. |
| `COUNTRY`        | STRING        | Country of the customer (from ERP location). Defaults to `'n/a'` if missing. |
| `MARITAL_STATUS` | STRING        | Marital status of the customer. |
| `GENDER`         | STRING        | Gender of the customer; taken from CRM if available, else ERP gender mapping, defaulting to `'n/a'`. |
| `BIRTHDATE`      | DATE          | Date of birth of the customer (from ERP). |
| `CREATE_DATE`    | DATE          | Date when the customer record was created. |

---

#### Joins

- **Customer demographics**:  
  `crm_cust_info.cst_key = erp_cust_az12.cid`
- **Customer location**:  
  `crm_cust_info.cst_key = erp_loc_a101.cid`

---

#### Business Notes
- Surrogate `CUSTOMER_KEY` provides stable joins for fact tables.  
- Null handling rules:  
  - `COUNTRY` defaults to `'n/a'` if not found in ERP location.  
  - `GENDER` is chosen from CRM when available, otherwise from ERP, else defaults to `'n/a'`.  
- Only customers with **non-null `cst_id`** are included in the view.  

### 2.gold.D_PRODUCTS_V

#### Description
The `gold.D_PRODUCTS_V` view provides a dimension table for product information.  
It standardises product attributes from CRM and ERP systems, including category, subcategory, cost, and effective start dates.  

---

#### Source Tables
- `silver.crm_prd_info` (Product master information from CRM)
- `silver.erp_px_cat_g1v2` (ERP product category and subcategory mapping)

---

#### Columns

| Column Name    | Data Type     | Description |
|----------------|--------------|-------------|
| `PRODUCT_KEY`   | INT           | Surrogate key generated using `ROW_NUMBER()` for uniqueness. |
| `PRODUCT_ID`    | STRING / INT  | Business identifier of the product. |
| `PRODUCT_NUMBER`| STRING / INT  | Internal product number (source system key). |
| `PRODUCT_NAME`  | STRING        | Name of the product. |
| `CATEGORY_ID`   | STRING / INT  | Identifier of the category from source system. |
| `CATEGORY`      | STRING        | Product category. |
| `SUBCATEGORY`   | STRING        | Product subcategory. |
| `MAINTENANCE`   | STRING / FLAG | Maintenance classification flag from ERP categories. |
| `PRODUCT_COST`  | DECIMAL       | Cost of the product. |
| `PRODUCT_LINE`  | STRING        | Product line classification. |
| `START_DATE`    | DATE          | Start date when the product became effective. |
<!-- | `END_DATE` | DATE | End date of the product (excluded in this view). -->  

---

#### Joins

- **Category Mapping**:  
  `crm_prd_info.cat_id = erp_px_cat_g1v2.id`

---

#### Business Notes
- Only **active products** are included (`pi.prd_end_dt IS NULL`).  
- A surrogate key (`PRODUCT_KEY`) is generated to ensure stable dimensional joins.  
- Product end date is excluded in this version for simplicity.  

### 3. gold.F_SALE_V

#### Description
The `gold.F_SALE_V` view represents sales transaction data at the order line level.  
It integrates details from CRM sales, product, and customer dimensions to provide a unified sales fact view.  

---

#### Source Tables
- `silver.crm_sales_details` (Sales detail records)
- `gold.D_PRODUCTS_V` (Product dimension)
- `gold.D_CUSTOMER_V` (Customer dimension)

---

#### Columns

| Column Name   | Data Type        | Description |
|---------------|-----------------|-------------|
| `ORDER_NUMBER` | STRING / VARCHAR | Unique identifier for the sales order. |
| `ORDER_DATE`   | DATE             | Date when the sales order was created. |
| `SHIP_DATE`    | DATE             | Date when the order was shipped. |
| `DUE_DATE`     | DATE             | Date when the order was due. |
| `CUSTOMER_KEY` | INT              | Surrogate key reference from `D_CUSTOMER_V`. |
| `PRODUCT_KEY`  | INT              | Surrogate key reference from `D_PRODUCTS_V`. |
| `QUANTITY`     | INT              | Quantity of product sold. |
| `UNIT_PRICE`   | DECIMAL(10,2)    | Unit price of the product (converted from cents). |
| `SALE_VALUE`   | DECIMAL(10,2)    | Total sales value (converted from cents). |

---

#### Joins

- **Products**:  
  `crm_sales_details.sls_prd_key = D_PRODUCTS_V.PRODUCT_NUMBER`
- **Customers**:  
  `crm_sales_details.sls_cust_id = D_CUSTOMER_V.CUSTOMER_ID`

---

#### Business Notes
- Prices and sales values are divided by 100 to standardise values (stored as cents in source).  
- This view acts as the **fact sales table** for reporting and analytics across orders, customers, and products.  
