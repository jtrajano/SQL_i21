CREATE TABLE [dbo].[apccrmst] (
    [apccr_vnd_no]      CHAR (10)       NOT NULL,
    [apccr_cbk_no]      CHAR (2)        NOT NULL,
    [apccr_ccd_ref_no]  CHAR (15)       NOT NULL,
    [apccr_batch_no]    TINYINT         NOT NULL,
    [apccr_ap_type]     CHAR (1)        NULL,
    [apccr_date]        INT             NULL,
    [apccr_reference]   INT             NULL,
    [apccr_invoice]     CHAR (15)       NULL,
    [apccr_gross_total] DECIMAL (11, 2) NULL,
    [apccr_fees_total]  DECIMAL (11, 2) NULL,
    [apccr_net_total]   DECIMAL (11, 2) NULL,
    [apccr_loc_no]      CHAR (3)        NULL,
    [apccr_pay_ref_no]  CHAR (8)        NULL,
    [apccr_entry_date]  INT             NOT NULL,
    [apccr_entry_time]  INT             NOT NULL,
    [apccr_post_ccr_yn] CHAR (1)        NULL,
    [apccr_user_id]     CHAR (16)       NULL,
    [apccr_user_rev_dt] CHAR (8)        NULL,
    [apccr_user_time]   SMALLINT        NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apccrmst] PRIMARY KEY NONCLUSTERED ([apccr_vnd_no] ASC, [apccr_cbk_no] ASC, [apccr_ccd_ref_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapccrmst0]
    ON [dbo].[apccrmst]([apccr_vnd_no] ASC, [apccr_cbk_no] ASC, [apccr_ccd_ref_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapccrmst1]
    ON [dbo].[apccrmst]([apccr_vnd_no] ASC, [apccr_ccd_ref_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapccrmst2]
    ON [dbo].[apccrmst]([apccr_batch_no] ASC, [apccr_vnd_no] ASC, [apccr_ccd_ref_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapccrmst3]
    ON [dbo].[apccrmst]([apccr_entry_date] ASC, [apccr_entry_time] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apccrmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apccrmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apccrmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apccrmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apccrmst] TO PUBLIC
    AS [dbo];

