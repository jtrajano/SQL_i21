CREATE TABLE [dbo].[apcrrmst] (
    [apcrr_vnd_no]      CHAR (10)   NOT NULL,
    [apcrr_cbk_no]      CHAR (2)    NOT NULL,
    [apcrr_ccd_ref_no]  CHAR (15)   NOT NULL,
    [apcrr_new_ref_no]  CHAR (15)   NULL,
    [apcrr_rev_date]    INT         NULL,
    [apcrr_batch_no]    TINYINT     NULL,
    [apcrr_entry_date]  INT         NULL,
    [apcrr_entry_time]  INT         NULL,
    [apcrr_post_rev_yn] CHAR (1)    NULL,
    [apcrr_reference]   CHAR (8)    NULL,
    [apcrr_pay_ref_no]  CHAR (8)    NULL,
    [apcrr_invoice]     CHAR (15)   NULL,
    [apcrr_user_id]     CHAR (16)   NULL,
    [apcrr_user_rev_dt] CHAR (8)    NULL,
    [apcrr_user_time]   SMALLINT    NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apcrrmst] PRIMARY KEY NONCLUSTERED ([apcrr_vnd_no] ASC, [apcrr_cbk_no] ASC, [apcrr_ccd_ref_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapcrrmst0]
    ON [dbo].[apcrrmst]([apcrr_vnd_no] ASC, [apcrr_cbk_no] ASC, [apcrr_ccd_ref_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apcrrmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apcrrmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apcrrmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apcrrmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apcrrmst] TO PUBLIC
    AS [dbo];

