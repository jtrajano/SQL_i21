CREATE TABLE [dbo].[prckmmst] (
    [prckm_dept_no]         SMALLINT       NOT NULL,
    [prckm_emp]             CHAR (10)      NOT NULL,
    [prckm_chk_type]        CHAR (1)       NOT NULL,
    [prckm_code]            CHAR (1)       NOT NULL,
    [prckm_no]              CHAR (8)       NOT NULL,
    [prckm_chk_date]        INT            NOT NULL,
    [prckm_qtrno]           TINYINT        NULL,
    [prckm_period_date]     INT            NULL,
    [prckm_ddp_bnk_code]    CHAR (4)       NULL,
    [prckm_dir_dep_acct]    CHAR (17)      NULL,
    [prckm_gross]           DECIMAL (9, 2) NULL,
    [prckm_deductions]      DECIMAL (9, 2) NULL,
    [prckm_taxes]           DECIMAL (9, 2) NULL,
    [prckm_net_pay]         DECIMAL (9, 2) NULL,
    [prckm_fed_taxable]     DECIMAL (9, 2) NULL,
    [prckm_ss_taxable]      DECIMAL (9, 2) NULL,
    [prckm_med_taxable]     DECIMAL (9, 2) NULL,
    [prckm_fui_taxable]     DECIMAL (9, 2) NULL,
    [prckm_sui_taxable]     DECIMAL (9, 2) NULL,
    [prckm_state_taxable]   DECIMAL (9, 2) NULL,
    [prckm_city_taxable]    DECIMAL (9, 2) NULL,
    [prckm_cnty_taxable]    DECIMAL (9, 2) NULL,
    [prckm_schdist_taxable] DECIMAL (9, 2) NULL,
    [prckm_print_stub_yn]   CHAR (1)       NULL,
    [prckm_prenote_yn]      CHAR (1)       NULL,
    [prckm_user_id]         CHAR (16)      NULL,
    [prckm_user_rev_dt]     INT            NULL,
    [A4GLIdentity]          NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prckmmst] PRIMARY KEY NONCLUSTERED ([prckm_dept_no] ASC, [prckm_emp] ASC, [prckm_chk_type] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprckmmst0]
    ON [dbo].[prckmmst]([prckm_dept_no] ASC, [prckm_emp] ASC, [prckm_chk_type] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprckmmst1]
    ON [dbo].[prckmmst]([prckm_emp] ASC, [prckm_chk_date] ASC, [prckm_dept_no] ASC, [prckm_chk_type] ASC);


GO
CREATE NONCLUSTERED INDEX [Iprckmmst2]
    ON [dbo].[prckmmst]([prckm_code] ASC, [prckm_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iprckmmst3]
    ON [dbo].[prckmmst]([prckm_chk_date] ASC, [prckm_dept_no] ASC, [prckm_emp] ASC, [prckm_chk_type] ASC);

