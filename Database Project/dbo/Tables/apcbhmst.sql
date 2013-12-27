CREATE TABLE [dbo].[apcbhmst] (
    [apcbh_vnd_no]         CHAR (10)       NOT NULL,
    [apcbh_cbk_no]         CHAR (2)        NOT NULL,
    [apcbh_ccd_ref_no]     CHAR (15)       NOT NULL,
    [apcbh_dealer_site]    CHAR (15)       NOT NULL,
    [apcbh_line_no]        SMALLINT        NOT NULL,
    [apcbh_batch_no]       CHAR (15)       NOT NULL,
    [apcbh_pay_type]       CHAR (3)        NULL,
    [apcbh_post_net_gross] CHAR (1)        NULL,
    [apcbh_gross_total]    DECIMAL (11, 2) NULL,
    [apcbh_fees_total]     DECIMAL (11, 2) NULL,
    [apcbh_net_total]      DECIMAL (11, 2) NULL,
    [apcbh_user_id]        CHAR (16)       NULL,
    [apcbh_user_rev_dt]    CHAR (8)        NULL,
    [apcbh_user_time]      SMALLINT        NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apcbhmst] PRIMARY KEY NONCLUSTERED ([apcbh_vnd_no] ASC, [apcbh_cbk_no] ASC, [apcbh_ccd_ref_no] ASC, [apcbh_dealer_site] ASC, [apcbh_line_no] ASC, [apcbh_batch_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapcbhmst0]
    ON [dbo].[apcbhmst]([apcbh_vnd_no] ASC, [apcbh_cbk_no] ASC, [apcbh_ccd_ref_no] ASC, [apcbh_dealer_site] ASC, [apcbh_line_no] ASC, [apcbh_batch_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apcbhmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apcbhmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apcbhmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apcbhmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apcbhmst] TO PUBLIC
    AS [dbo];

