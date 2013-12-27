CREATE TABLE [dbo].[efctlmst] (
    [efctl_key]                  TINYINT     NOT NULL,
    [efctl_password]             CHAR (16)   NULL,
    [efctl_cbk_no]               CHAR (2)    NULL,
    [efctl_pull_tax_separate_yn] CHAR (1)    NULL,
    [efctl_apply_credits_yn]     CHAR (1)    NULL,
    [efctl_pay_type]             CHAR (3)    NULL,
    [efctl_export_file_name]     CHAR (30)   NULL,
    [efctl_export_path]          CHAR (50)   NULL,
    [efctl_next_export_file_no]  SMALLINT    NULL,
    [efctl_balance_ach_yn]       CHAR (1)    NULL,
    [efctl_retain_history_mo]    SMALLINT    NULL,
    [efctl_last_hist_purge_dt]   INT         NULL,
    [efctl_current_effect_date]  INT         NULL,
    [efctl_deposit_loc_no]       CHAR (3)    NULL,
    [efctl_summarize_ach_yn]     CHAR (1)    NULL,
    [efctl_cvt1]                 CHAR (1)    NULL,
    [efctl_cvt2]                 CHAR (1)    NULL,
    [efctl_cvt3]                 CHAR (1)    NULL,
    [efctl_cvt4]                 CHAR (1)    NULL,
    [efctl_cvt5]                 CHAR (1)    NULL,
    [efctl_cvt6]                 CHAR (1)    NULL,
    [efctl_cvt7]                 CHAR (1)    NULL,
    [efctl_cvt8]                 CHAR (1)    NULL,
    [efctl_cvt9]                 CHAR (1)    NULL,
    [efctl_cvt10]                CHAR (1)    NULL,
    [efctl_cvt11]                CHAR (1)    NULL,
    [efctl_cvt12]                CHAR (1)    NULL,
    [efctl_cvt13]                CHAR (1)    NULL,
    [efctl_cvt14]                CHAR (1)    NULL,
    [efctl_cvt15]                CHAR (1)    NULL,
    [efctl_cvt16]                CHAR (1)    NULL,
    [efctl_cvt17]                CHAR (1)    NULL,
    [efctl_cvt18]                CHAR (1)    NULL,
    [efctl_cvt19]                CHAR (1)    NULL,
    [efctl_cvt20]                CHAR (1)    NULL,
    [efctl_user_id]              CHAR (16)   NULL,
    [efctl_user_rev_dt]          INT         NULL,
    [A4GLIdentity]               NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_efctlmst] PRIMARY KEY NONCLUSTERED ([efctl_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iefctlmst0]
    ON [dbo].[efctlmst]([efctl_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[efctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[efctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[efctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[efctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[efctlmst] TO PUBLIC
    AS [dbo];

