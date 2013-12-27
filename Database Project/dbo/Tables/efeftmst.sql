CREATE TABLE [dbo].[efeftmst] (
    [efeft_eft_type_cv]            CHAR (1)        NOT NULL,
    [efeft_eft_no]                 CHAR (10)       NOT NULL,
    [efeft_src_sys]                CHAR (2)        NOT NULL,
    [efeft_active_yn]              CHAR (1)        NULL,
    [efeft_bnk_no]                 CHAR (4)        NULL,
    [efeft_account_no]             CHAR (17)       NULL,
    [efeft_acct_type]              CHAR (1)        NULL,
    [efeft_effective_date]         INT             NULL,
    [efeft_notify_yn]              CHAR (1)        NULL,
    [efeft_pull_tax_separate_yn]   CHAR (1)        NULL,
    [efeft_pull_type_bfis]         CHAR (1)        NULL,
    [efeft_stmt_disc_pct]          DECIMAL (3, 1)  NULL,
    [efeft_flat_amt]               DECIMAL (11, 2) NULL,
    [efeft_refund_bdgt_credits_yn] CHAR (1)        NULL,
    [efeft_last_prenote_date]      INT             NULL,
    [efeft_last_prenote_time]      INT             NULL,
    [efeft_last_stmt_date_pulled]  INT             NULL,
    [efeft_last_bdgt_mnth_pulled]  TINYINT         NULL,
    [efeft_last_tx_pulled_thru]    INT             NULL,
    [efeft_user_id]                CHAR (16)       NULL,
    [efeft_user_rev_dt]            INT             NULL,
    [A4GLIdentity]                 NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [efeft_acct_class_cp]          CHAR (1)        NULL,
    CONSTRAINT [k_efeftmst] PRIMARY KEY NONCLUSTERED ([efeft_eft_type_cv] ASC, [efeft_eft_no] ASC, [efeft_src_sys] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iefeftmst0]
    ON [dbo].[efeftmst]([efeft_eft_type_cv] ASC, [efeft_eft_no] ASC, [efeft_src_sys] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iefeftmst1]
    ON [dbo].[efeftmst]([efeft_eft_no] ASC, [efeft_eft_type_cv] ASC, [efeft_src_sys] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[efeftmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[efeftmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[efeftmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[efeftmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[efeftmst] TO PUBLIC
    AS [dbo];

