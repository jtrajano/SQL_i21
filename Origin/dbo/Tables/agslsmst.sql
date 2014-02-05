CREATE TABLE [dbo].[agslsmst] (
    [agsls_slsmn_id]       CHAR (3)        NOT NULL,
    [agsls_name]           CHAR (30)       NULL,
    [agsls_addr1]          CHAR (30)       NULL,
    [agsls_addr2]          CHAR (30)       NULL,
    [agsls_city]           CHAR (20)       NULL,
    [agsls_state]          CHAR (2)        NULL,
    [agsls_zip]            CHAR (10)       NULL,
    [agsls_country]        CHAR (3)        NULL,
    [agsls_phone]          CHAR (15)       NULL,
    [agsls_sales_ty_1]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_2]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_3]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_4]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_5]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_6]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_7]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_8]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_9]     DECIMAL (11, 2) NULL,
    [agsls_sales_ty_10]    DECIMAL (11, 2) NULL,
    [agsls_sales_ty_11]    DECIMAL (11, 2) NULL,
    [agsls_sales_ty_12]    DECIMAL (11, 2) NULL,
    [agsls_sales_ly_1]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_2]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_3]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_4]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_5]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_6]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_7]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_8]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_9]     DECIMAL (11, 2) NULL,
    [agsls_sales_ly_10]    DECIMAL (11, 2) NULL,
    [agsls_sales_ly_11]    DECIMAL (11, 2) NULL,
    [agsls_sales_ly_12]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_1]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_2]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_3]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_4]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_5]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_6]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_7]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_8]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_9]    DECIMAL (11, 2) NULL,
    [agsls_profit_ty_10]   DECIMAL (11, 2) NULL,
    [agsls_profit_ty_11]   DECIMAL (11, 2) NULL,
    [agsls_profit_ty_12]   DECIMAL (11, 2) NULL,
    [agsls_profit_ly_1]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_2]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_3]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_4]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_5]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_6]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_7]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_8]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_9]    DECIMAL (11, 2) NULL,
    [agsls_profit_ly_10]   DECIMAL (11, 2) NULL,
    [agsls_profit_ly_11]   DECIMAL (11, 2) NULL,
    [agsls_profit_ly_12]   DECIMAL (11, 2) NULL,
    [agsls_email]          CHAR (50)       NULL,
    [agsls_textmsg_email]  CHAR (50)       NULL,
    [agsls_dispatch_email] CHAR (1)        NULL,
    [agsls_et_driver_yn]   CHAR (1)        NULL,
    [agsls_user_id]        CHAR (16)       NULL,
    [agsls_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [agsls_et_loc_no]      CHAR (3)        NULL,
    CONSTRAINT [k_agslsmst] PRIMARY KEY NONCLUSTERED ([agsls_slsmn_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagslsmst0]
    ON [dbo].[agslsmst]([agsls_slsmn_id] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agslsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agslsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agslsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agslsmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agslsmst] TO PUBLIC
    AS [dbo];

