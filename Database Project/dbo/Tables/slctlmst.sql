CREATE TABLE [dbo].[slctlmst] (
    [slctl_key]              TINYINT     NOT NULL,
    [slctl_password]         CHAR (16)   NULL,
    [slctl_single_slsmn_yn]  CHAR (1)    NULL,
    [slctl_default_slsmn_id] CHAR (3)    NULL,
    [slctl_postnet_code_yn]  CHAR (1)    NULL,
    [slctl_cus_import_type]  CHAR (2)    NULL,
    [slctl_cus_import_path]  CHAR (50)   NULL,
    [slctl_alt_editor]       CHAR (20)   NULL,
    [slctl_cls_name1]        CHAR (8)    NULL,
    [slctl_cls_name2]        CHAR (8)    NULL,
    [slctl_cls_name3]        CHAR (8)    NULL,
    [slctl_cls_name4]        CHAR (8)    NULL,
    [slctl_cls_name5]        CHAR (8)    NULL,
    [slctl_import_program]   CHAR (8)    NULL,
    [slctl_import_parmlist]  CHAR (40)   NULL,
    [slctl_host_remote_hr]   CHAR (1)    NULL,
    [slctl_site_id]          CHAR (3)    NULL,
    [slctl_pt_import_rev_dt] INT         NULL,
    [slctl_lead_prg_days]    SMALLINT    NULL,
    [slctl_todo_prg_days]    SMALLINT    NULL,
    [slctl_log_prg_days]     SMALLINT    NULL,
    [slctl_user_id]          CHAR (16)   NULL,
    [slctl_user_rev_dt]      INT         NULL,
    [A4GLIdentity]           NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slctlmst] PRIMARY KEY NONCLUSTERED ([slctl_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Islctlmst0]
    ON [dbo].[slctlmst]([slctl_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[slctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[slctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[slctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[slctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[slctlmst] TO PUBLIC
    AS [dbo];

