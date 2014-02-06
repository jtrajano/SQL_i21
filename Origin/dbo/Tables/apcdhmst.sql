CREATE TABLE [dbo].[apcdhmst] (
    [apcdh_vnd_no]           CHAR (10)       NOT NULL,
    [apcdh_cbk_no]           CHAR (2)        NOT NULL,
    [apcdh_ccd_ref_no]       CHAR (15)       NOT NULL,
    [apcdh_dealer_site]      CHAR (15)       NOT NULL,
    [apcdh_line_no]          SMALLINT        NOT NULL,
    [apcdh_dealer_site_type] CHAR (1)        NULL,
    [apcdh_terms]            CHAR (2)        NULL,
    [apcdh_pay_type]         CHAR (3)        NULL,
    [apcdh_post_net_gross]   CHAR (1)        NULL,
    [apcdh_gross_total]      DECIMAL (11, 2) NULL,
    [apcdh_fees_total]       DECIMAL (11, 2) NULL,
    [apcdh_net_total]        DECIMAL (11, 2) NULL,
    [apcdh_fees_to_ar_pct]   DECIMAL (4, 1)  NULL,
    [apcdh_fees_gl_acct]     DECIMAL (16, 8) NULL,
    [apcdh_gl_acct]          DECIMAL (16, 8) NULL,
    [apcdh_ar_cus_no]        CHAR (10)       NULL,
    [apcdh_user_id]          CHAR (16)       NULL,
    [apcdh_user_rev_dt]      CHAR (8)        NULL,
    [apcdh_user_time]        SMALLINT        NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apcdhmst] PRIMARY KEY NONCLUSTERED ([apcdh_vnd_no] ASC, [apcdh_cbk_no] ASC, [apcdh_ccd_ref_no] ASC, [apcdh_dealer_site] ASC, [apcdh_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iapcdhmst0]
    ON [dbo].[apcdhmst]([apcdh_vnd_no] ASC, [apcdh_cbk_no] ASC, [apcdh_ccd_ref_no] ASC, [apcdh_dealer_site] ASC, [apcdh_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[apcdhmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apcdhmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apcdhmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apcdhmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apcdhmst] TO PUBLIC
    AS [dbo];

