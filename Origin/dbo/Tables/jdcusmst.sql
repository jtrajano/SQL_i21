CREATE TABLE [dbo].[jdcusmst] (
    [jdcus_patron_no]      CHAR (10)   NOT NULL,
    [jdcus_product_line]   CHAR (10)   NOT NULL,
    [jdcus_cus_no]         CHAR (16)   NOT NULL,
    [jdcus_cus_name]       CHAR (64)   NULL,
    [jdcus_account_use]    CHAR (1)    NULL,
    [jdcus_restrict_acct]  CHAR (1)    NULL,
    [jdcus_preferred_acct] CHAR (4)    NULL,
    [jdcus_po_no_req]      CHAR (1)    NULL,
    [jdcus_locale]         CHAR (5)    NULL,
    [jdcus_timestamp]      CHAR (25)   NULL,
    [jdcus_budget_billing] CHAR (1)    NULL,
    [jdcus_user_id]        CHAR (16)   NULL,
    [jdcus_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jdcusmst] PRIMARY KEY NONCLUSTERED ([jdcus_patron_no] ASC, [jdcus_product_line] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ijdcusmst0]
    ON [dbo].[jdcusmst]([jdcus_patron_no] ASC, [jdcus_product_line] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdcusmst1]
    ON [dbo].[jdcusmst]([jdcus_patron_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdcusmst2]
    ON [dbo].[jdcusmst]([jdcus_cus_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[jdcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[jdcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[jdcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[jdcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[jdcusmst] TO PUBLIC
    AS [dbo];

