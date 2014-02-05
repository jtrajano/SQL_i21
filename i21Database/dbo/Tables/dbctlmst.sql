CREATE TABLE [dbo].[dbctlmst] (
    [dbctl_key]                TINYINT         NOT NULL,
    [dbctl_cbk_no]             CHAR (2)        NULL,
    [dbctl_bond_series]        CHAR (4)        NULL,
    [dbctl_last_bond_no]       INT             NULL,
    [dbctl_dflt_int_rt]        DECIMAL (6, 4)  NULL,
    [dbctl_gl_cash]            DECIMAL (16, 8) NULL,
    [dbctl_gl_bond]            DECIMAL (16, 8) NULL,
    [dbctl_gl_tax_wh]          DECIMAL (16, 8) NULL,
    [dbctl_gl_int_exp]         DECIMAL (16, 8) NULL,
    [dbctl_chk_prtr_name]      CHAR (80)       NULL,
    [dbctl_withheld_pct]       DECIMAL (4, 2)  NULL,
    [dbctl_last_chk_no]        INT             NULL,
    [dbctl_chk_comment_1]      CHAR (40)       NULL,
    [dbctl_chk_comment_2]      CHAR (40)       NULL,
    [dbctl_chk_comment_3]      CHAR (40)       NULL,
    [dbctl_chk_cycle_ind]      CHAR (1)        NULL,
    [dbctl_calc_yr_days]       SMALLINT        NULL,
    [dbctl_check_format_cs]    CHAR (1)        NULL,
    [dbctl_laser_down_lines]   TINYINT         NULL,
    [dbctl_invest_type]        CHAR (1)        NULL,
    [dbctl_gl_accrued_int]     DECIMAL (16, 8) NULL,
    [dbctl_setup_mode_yn]      CHAR (1)        NULL,
    [dbctl_compound_int_yn]    CHAR (1)        NULL,
    [dbctl_early_withdraw_pct] DECIMAL (4, 2)  NULL,
    [dbctl_user_id]            CHAR (16)       NULL,
    [dbctl_user_rev_dt]        INT             NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_dbctlmst] PRIMARY KEY NONCLUSTERED ([dbctl_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Idbctlmst0]
    ON [dbo].[dbctlmst]([dbctl_key] ASC);

