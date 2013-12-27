CREATE TABLE [dbo].[apcbemst] (
    [apcbe_vnd_no]         CHAR (10)       NOT NULL,
    [apcbe_cbk_no]         CHAR (2)        NOT NULL,
    [apcbe_ccd_ref_no]     CHAR (15)       NOT NULL,
    [apcbe_dealer_site]    CHAR (15)       NOT NULL,
    [apcbe_line_no]        SMALLINT        NOT NULL,
    [apcbe_batch_no]       CHAR (15)       NOT NULL,
    [apcbe_pay_type]       CHAR (3)        NULL,
    [apcbe_post_net_gross] CHAR (1)        NULL,
    [apcbe_gross_total]    DECIMAL (11, 2) NULL,
    [apcbe_fees_total]     DECIMAL (11, 2) NULL,
    [apcbe_net_total]      DECIMAL (11, 2) NULL,
    [apcbe_user_id]        CHAR (16)       NULL,
    [apcbe_user_rev_dt]    CHAR (8)        NULL,
    [apcbe_user_time]      SMALLINT        NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apcbemst] PRIMARY KEY NONCLUSTERED ([apcbe_vnd_no] ASC, [apcbe_cbk_no] ASC, [apcbe_ccd_ref_no] ASC, [apcbe_dealer_site] ASC, [apcbe_line_no] ASC, [apcbe_batch_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapcbemst0]
    ON [dbo].[apcbemst]([apcbe_vnd_no] ASC, [apcbe_cbk_no] ASC, [apcbe_ccd_ref_no] ASC, [apcbe_dealer_site] ASC, [apcbe_line_no] ASC, [apcbe_batch_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apcbemst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apcbemst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apcbemst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apcbemst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apcbemst] TO PUBLIC
    AS [dbo];

