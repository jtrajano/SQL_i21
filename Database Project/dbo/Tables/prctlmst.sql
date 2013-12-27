CREATE TABLE [dbo].[prctlmst] (
    [prctl_key]                  TINYINT         NOT NULL,
    [prctl_reorg_lock_yn]        CHAR (1)        NULL,
    [prctl_reorg_lock_file]      CHAR (8)        NULL,
    [prctl_report_co]            CHAR (2)        NULL,
    [prctl_auto_id_yn]           CHAR (1)        NULL,
    [prctl_high_id]              BIGINT          NULL,
    [prctl_limit1]               INT             NULL,
    [prctl_limit2]               INT             NULL,
    [prctl_limit3]               INT             NULL,
    [prctl_limit4]               INT             NULL,
    [prctl_limit5]               INT             NULL,
    [prctl_last_pay_dt]          INT             NULL,
    [prctl_cbk_no]               CHAR (2)        NULL,
    [prctl_next_check]           INT             NULL,
    [prctl_next_dir_dep]         INT             NULL,
    [prctl_alt1_desc]            CHAR (20)       NULL,
    [prctl_alt2_desc]            CHAR (20)       NULL,
    [prctl_alt3_desc]            CHAR (20)       NULL,
    [prctl_alt4_desc]            CHAR (20)       NULL,
    [prctl_cp_indiv]             CHAR (1)        NULL,
    [prctl_cp_voids]             CHAR (1)        NULL,
    [prctl_cp_standard]          CHAR (1)        NULL,
    [prctl_cp_maint_log]         CHAR (1)        NULL,
    [prctl_cp_entry]             CHAR (1)        NULL,
    [prctl_cp_calc]              CHAR (1)        NULL,
    [prctl_cp_checks]            CHAR (1)        NULL,
    [prctl_cp_supplements]       CHAR (1)        NULL,
    [prctl_cp_check_register]    CHAR (1)        NULL,
    [prctl_cp_dd_register]       CHAR (1)        NULL,
    [prctl_cp_vsp_summary]       CHAR (1)        NULL,
    [prctl_cp_ded_summary]       CHAR (1)        NULL,
    [prctl_cp_tax_summary]       CHAR (1)        NULL,
    [prctl_cp_distribution]      CHAR (1)        NULL,
    [prctl_cp_update_gl]         CHAR (1)        NULL,
    [prctl_cp_emp_ledgers]       CHAR (1)        NULL,
    [prctl_cp_clear_tranfiles]   CHAR (1)        NULL,
    [prctl_cp_update_ap]         CHAR (1)        NULL,
    [prctl_cp_payables_list]     CHAR (1)        NULL,
    [prctl_cp_csv_loaded]        CHAR (1)        NULL,
    [prctl_cp_check_date]        INT             NULL,
    [prctl_cp_qtrno]             TINYINT         NULL,
    [prctl_cp_period_start_date] INT             NULL,
    [prctl_cp_period_end_date]   INT             NULL,
    [prctl_curr_year]            SMALLINT        NULL,
    [prctl_ovt_cutoff]           SMALLINT        NULL,
    [prctl_salaried_ovt_cutoff]  SMALLINT        NULL,
    [prctl_hours_rnd_qth]        CHAR (1)        NULL,
    [prctl_keep_no_years]        TINYINT         NULL,
    [prctl_gen_ach_file]         TINYINT         NULL,
    [prctl_send_names_to_cw]     TINYINT         NULL,
    [prctl_password]             CHAR (8)        NULL,
    [prctl_gl_summ_detail]       TINYINT         NULL,
    [prctl_print_vac_on_checks]  TINYINT         NULL,
    [prctl_check_form_no]        TINYINT         NULL,
    [prctl_update_cbk_chknos]    TINYINT         NULL,
    [prctl_printer_name]         CHAR (80)       NULL,
    [prctl_ap_batchno]           TINYINT         NULL,
    [prctl_exp_taxes_by_pc]      TINYINT         NULL,
    [prctl_prcvt1_update]        CHAR (1)        NULL,
    [prctl_ach_file_name]        CHAR (60)       NULL,
    [prctl_check_advance]        TINYINT         NULL,
    [prctl_ach_bank]             CHAR (4)        NULL,
    [prctl_accrual_acct_9]       TINYINT         NULL,
    [prctl_accrual_acct]         DECIMAL (16, 8) NULL,
    [prctl_csv_load_name]        CHAR (60)       NULL,
    [prctl_7_inch_check]         TINYINT         NULL,
    [prctl_401k_prog]            CHAR (8)        NULL,
    [prctl_gl_detail_by_emp]     TINYINT         NULL,
    [prctl_941s_prog]            CHAR (8)        NULL,
    [prctl_suppress_ssno_yn]     CHAR (1)        NULL,
    [prctl_balance_ach_file]     TINYINT         NULL,
    [prctl_print_empr_cont_9]    TINYINT         NULL,
    [prctl_print_sck_on_checks]  TINYINT         NULL,
    [prctl_print_per_on_checks]  TINYINT         NULL,
    [prctl_user_id]              CHAR (16)       NULL,
    [prctl_user_rev_dt]          INT             NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prctlmst] PRIMARY KEY NONCLUSTERED ([prctl_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iprctlmst0]
    ON [dbo].[prctlmst]([prctl_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[prctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[prctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[prctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[prctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[prctlmst] TO PUBLIC
    AS [dbo];

