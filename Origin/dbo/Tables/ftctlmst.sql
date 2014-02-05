CREATE TABLE [dbo].[ftctlmst] (
    [ftctl_key]                   TINYINT     NOT NULL,
    [ftctl_retain_history_mo]     SMALLINT    NULL,
    [ftctl_retain_guides_mo]      TINYINT     NULL,
    [ftctl_last_purge_rev_dt]     INT         NULL,
    [ftctl_last_fgt_purge_rev_dt] INT         NULL,
    [ftctl_beg_addon_class]       CHAR (3)    NULL,
    [ftctl_end_addon_class]       CHAR (3)    NULL,
    [ftctl_retain_restrict_mo]    SMALLINT    NULL,
    [ftctl_last_rst_purge_rev_dt] INT         NULL,
    [ftctl_use_dec_on_anal_yn]    CHAR (1)    NULL,
    [ftctl_post_on_ship_yn]       CHAR (1)    NULL,
    [ftctl_missing_density_yn]    CHAR (1)    NULL,
    [ftctl_user_id]               CHAR (16)   NULL,
    [ftctl_user_rev_dt]           CHAR (8)    NULL,
    [A4GLIdentity]                NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftctlmst] PRIMARY KEY NONCLUSTERED ([ftctl_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iftctlmst0]
    ON [dbo].[ftctlmst]([ftctl_key] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[ftctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ftctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ftctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ftctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ftctlmst] TO PUBLIC
    AS [dbo];

