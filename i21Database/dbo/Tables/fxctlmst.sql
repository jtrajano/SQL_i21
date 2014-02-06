CREATE TABLE [dbo].[fxctlmst] (
    [fxctl_key]                 TINYINT     NOT NULL,
    [fxctl_password]            CHAR (16)   NULL,
    [fxctl_kwik_list_ind]       CHAR (1)    NULL,
    [fxctl_curr_fiscal_ccyymm]  INT         NULL,
    [fxctl_last_post_ccyymm]    INT         NULL,
    [fxctl_tax_values_yn]       CHAR (1)    NULL,
    [fxctl_tx_last_post_ccyymm] INT         NULL,
    [fxctl_user_id]             CHAR (16)   NULL,
    [fxctl_user_rev_dt]         INT         NULL,
    [A4GLIdentity]              NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_fxctlmst] PRIMARY KEY NONCLUSTERED ([fxctl_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ifxctlmst0]
    ON [dbo].[fxctlmst]([fxctl_key] ASC);

