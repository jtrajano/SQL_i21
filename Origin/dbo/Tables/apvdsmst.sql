CREATE TABLE [dbo].[apvdsmst] (
    [apvds_vnd_no]           CHAR (10)       NOT NULL,
    [apvds_dealer_site_no]   CHAR (15)       NOT NULL,
    [apvds_co_owned_yn]      CHAR (1)        NULL,
    [apvds_desc]             CHAR (30)       NULL,
    [apvds_ar_pay_type]      CHAR (3)        NULL,
    [apvds_ar_cus_no]        CHAR (10)       NULL,
    [apvds_gl_acct]          DECIMAL (16, 8) NULL,
    [apvds_dealer_site_type] CHAR (1)        NULL,
    [apvds_fees_to_ar_pct]   DECIMAL (4, 1)  NULL,
    [apvds_fees_gl_acct]     DECIMAL (16, 8) NULL,
    [apvds_post_net_gross]   CHAR (1)        NULL,
    [apvds_user_id]          CHAR (16)       NULL,
    [apvds_user_rev_dt]      CHAR (8)        NULL,
    [apvds_user_time]        SMALLINT        NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [apvds_mer_cat_cd]       SMALLINT        NULL,
    [apvds_trans_type_rptd]  CHAR (1)        NULL,
    CONSTRAINT [k_apvdsmst] PRIMARY KEY NONCLUSTERED ([apvds_vnd_no] ASC, [apvds_dealer_site_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iapvdsmst0]
    ON [dbo].[apvdsmst]([apvds_vnd_no] ASC, [apvds_dealer_site_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[apvdsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apvdsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apvdsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apvdsmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apvdsmst] TO PUBLIC
    AS [dbo];

