CREATE TABLE [dbo].[jddbcmst] (
    [jddbc_bill_code]      INT         NOT NULL,
    [jddbc_description]    CHAR (64)   NULL,
    [jddbc_timestamp]      CHAR (25)   NULL,
    [jddbc_budget_billing] CHAR (1)    NOT NULL,
    [jddbc_alt_bill_code]  INT         NOT NULL,
    [jddbc_user_id]        CHAR (16)   NULL,
    [jddbc_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jddbcmst] PRIMARY KEY NONCLUSTERED ([jddbc_bill_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ijddbcmst0]
    ON [dbo].[jddbcmst]([jddbc_bill_code] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijddbcmst1]
    ON [dbo].[jddbcmst]([jddbc_budget_billing] ASC, [jddbc_alt_bill_code] ASC);

