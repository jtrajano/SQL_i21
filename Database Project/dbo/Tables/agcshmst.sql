CREATE TABLE [dbo].[agcshmst] (
    [agcsh_key]             TINYINT         NOT NULL,
    [agcsh_old_ar_bal]      DECIMAL (11, 2) NULL,
    [agcsh_sales]           DECIMAL (11, 2) NULL,
    [agcsh_acct_sales]      DECIMAL (11, 2) NULL,
    [agcsh_rec_on_acct]     DECIMAL (11, 2) NULL,
    [agcsh_unapplied]       DECIMAL (11, 2) NULL,
    [agcsh_credits_issued]  DECIMAL (11, 2) NULL,
    [agcsh_refunds]         DECIMAL (11, 2) NULL,
    [agcsh_debits_issued]   DECIMAL (11, 2) NULL,
    [agcsh_discounts_taken] DECIMAL (11, 2) NULL,
    [agcsh_cash_sale_disc]  DECIMAL (11, 2) NULL,
    [agcsh_srvchr]          DECIMAL (11, 2) NULL,
    [agcsh_write_offs]      DECIMAL (11, 2) NULL,
    [agcsh_other_inc]       DECIMAL (11, 2) NULL,
    [agcsh_calc_dep]        DECIMAL (11, 2) NULL,
    [agcsh_user_id]         CHAR (16)       NULL,
    [agcsh_user_rev_dt]     INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agcshmst] PRIMARY KEY NONCLUSTERED ([agcsh_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagcshmst0]
    ON [dbo].[agcshmst]([agcsh_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agcshmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agcshmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agcshmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agcshmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agcshmst] TO PUBLIC
    AS [dbo];

