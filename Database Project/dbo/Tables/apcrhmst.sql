CREATE TABLE [dbo].[apcrhmst] (
    [apcrh_vnd_no]      CHAR (10)       NOT NULL,
    [apcrh_cbk_no]      CHAR (2)        NOT NULL,
    [apcrh_ccd_ref_no]  CHAR (15)       NOT NULL,
    [apcrh_batch_no]    TINYINT         NULL,
    [apcrh_ap_type]     CHAR (1)        NULL,
    [apcrh_date]        INT             NOT NULL,
    [apcrh_reference]   INT             NULL,
    [apcrh_invoice]     CHAR (15)       NULL,
    [apcrh_gross_total] DECIMAL (11, 2) NULL,
    [apcrh_fees_total]  DECIMAL (11, 2) NULL,
    [apcrh_net_total]   DECIMAL (11, 2) NULL,
    [apcrh_loc_no]      CHAR (3)        NULL,
    [apcrh_pay_ref_no]  CHAR (8)        NULL,
    [apcrh_entry_date]  INT             NULL,
    [apcrh_entry_time]  INT             NULL,
    [apcrh_audit_no]    SMALLINT        NULL,
    [apcrh_reversal_yn] CHAR (1)        NULL,
    [apcrh_reversed_yn] CHAR (1)        NULL,
    [apcrh_user_id]     CHAR (16)       NULL,
    [apcrh_user_rev_dt] CHAR (8)        NULL,
    [apcrh_user_time]   SMALLINT        NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apcrhmst] PRIMARY KEY NONCLUSTERED ([apcrh_vnd_no] ASC, [apcrh_cbk_no] ASC, [apcrh_ccd_ref_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapcrhmst0]
    ON [dbo].[apcrhmst]([apcrh_vnd_no] ASC, [apcrh_cbk_no] ASC, [apcrh_ccd_ref_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapcrhmst1]
    ON [dbo].[apcrhmst]([apcrh_date] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apcrhmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apcrhmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apcrhmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apcrhmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apcrhmst] TO PUBLIC
    AS [dbo];

