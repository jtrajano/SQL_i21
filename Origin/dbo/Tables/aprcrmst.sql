CREATE TABLE [dbo].[aprcrmst] (
    [aprcr_vnd_no]            CHAR (10)       NOT NULL,
    [aprcr_invoice_no]        CHAR (12)       NOT NULL,
    [aprcr_cbk_no]            CHAR (2)        NOT NULL,
    [aprcr_alt_grp_no]        CHAR (2)        NOT NULL,
    [aprcr_alt_vnd_no]        CHAR (10)       NOT NULL,
    [aprcr_alt_invoice_no]    CHAR (12)       NOT NULL,
    [aprcr_grp_no]            CHAR (2)        NOT NULL,
    [aprcr_alt2_cbk_no]       CHAR (2)        NOT NULL,
    [aprcr_alt2_vnd_no]       CHAR (10)       NOT NULL,
    [aprcr_alt2_invoice_no]   CHAR (12)       NOT NULL,
    [aprcr_invoice_amt]       DECIMAL (9, 2)  NULL,
    [aprcr_disc_amt]          DECIMAL (9, 2)  NULL,
    [aprcr_pur_ord_no]        CHAR (8)        NULL,
    [aprcr_comment_1]         CHAR (40)       NULL,
    [aprcr_pymt_type_fv]      CHAR (1)        NULL,
    [aprcr_start_rev_dt]      INT             NULL,
    [aprcr_final_rev_dt]      INT             NULL,
    [aprcr_pymt_duration_fi]  CHAR (1)        NULL,
    [aprcr_no_pymts]          SMALLINT        NULL,
    [aprcr_tot_amt]           DECIMAL (11, 2) NULL,
    [aprcr_no_pymts_to_date]  SMALLINT        NULL,
    [aprcr_amt_paid_to_date]  DECIMAL (11, 2) NULL,
    [aprcr_last_invoice_date] INT             NULL,
    [aprcr_currency]          CHAR (3)        NULL,
    [aprcr_currency_rt]       DECIMAL (15, 8) NULL,
    [aprcr_currency_cnt]      CHAR (8)        NULL,
    [aprcr_user_id]           CHAR (16)       NULL,
    [aprcr_user_rev_dt]       INT             NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aprcrmst] PRIMARY KEY NONCLUSTERED ([aprcr_vnd_no] ASC, [aprcr_invoice_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iaprcrmst0]
    ON [dbo].[aprcrmst]([aprcr_vnd_no] ASC, [aprcr_invoice_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iaprcrmst1]
    ON [dbo].[aprcrmst]([aprcr_cbk_no] ASC, [aprcr_alt_grp_no] ASC, [aprcr_alt_vnd_no] ASC, [aprcr_alt_invoice_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iaprcrmst2]
    ON [dbo].[aprcrmst]([aprcr_grp_no] ASC, [aprcr_alt2_cbk_no] ASC, [aprcr_alt2_vnd_no] ASC, [aprcr_alt2_invoice_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[aprcrmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[aprcrmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[aprcrmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[aprcrmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[aprcrmst] TO PUBLIC
    AS [dbo];

