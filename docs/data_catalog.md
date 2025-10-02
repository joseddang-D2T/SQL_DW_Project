# Data Dictionary for GOLD layer (only required for End users)
## Overview
The GOLD layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of DIMENSION and FACT tables for specific business metrics

### 1. gold.F_SALE_V

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
  `sd.sls_prd_key = dp.PRODUCT_NUMBER`
- **Customers**:  
  `sd.sls_cust_id = dc.CUSTOMER_ID`

---

#### Business Notes
- Prices and sales values are divided by 100 to standardise values (stored as cents in source).  
- This view acts as the **fact sales table** for reporting and analytics across orders, customers, and products.  
