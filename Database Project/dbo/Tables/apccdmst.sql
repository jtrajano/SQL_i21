CREATE TABLE [dbo].[apccdmst] (
    [apccd_vnd_no]           CHAR (10)       NOT NULL,
    [apccd_cbk_no]           CHAR (2)        NOT NULL,
    [apccd_ccd_ref_no]       CHAR (15)       NOT NULL,
    [apccd_dealer_site]      CHAR (15)       NOT NULL,
    [apccd_line_no]          SMALLINT        NOT NULL,
    [apccd_dealer_site_type] CHAR (1)        NULL,
    [apccd_terms]            CHAR (2)        NULL,
    [apccd_pay_type]         CHAR (3)        NULL,
    [apccd_post_net_gross]   CHAR (1)        NULL,
    [apccd_gross_total]      DECIMAL (11, 2) NULL,
    [apccd_fees_total]       DECIMAL (11, 2) NULL,
    [apccd_net_total]        DECIMAL (11, 2) NULL,
    [apccd_user_id]          CHAR (16)       NULL,
    [apccd_user_rev_dt]      CHAR (8)        NULL,
    [apccd_user_time]        SMALLINT        NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [apccd_ar_cus_no]        CHAR (10)       NULL,
    CONSTRAINT [k_apccdmst] PRIMARY KEY NONCLUSTERED ([apccd_vnd_no] ASC, [apccd_cbk_no] ASC, [apccd_ccd_ref_no] ASC, [apccd_dealer_site] ASC, [apccd_line_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapccdmst0]
    ON [dbo].[apccdmst]([apccd_vnd_no] ASC, [apccd_cbk_no] ASC, [apccd_ccd_ref_no] ASC, [apccd_dealer_site] ASC, [apccd_line_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apccdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apccdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apccdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apccdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apccdmst] TO PUBLIC
    AS [dbo];

