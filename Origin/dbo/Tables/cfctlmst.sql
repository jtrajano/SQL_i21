CREATE TABLE [dbo].[cfctlmst] (
    [cfctl_record_no]                TINYINT     NOT NULL,
    [cfctl_password]                 CHAR (16)   NULL,
    [cfctl_ap_installed_yn]          CHAR (1)    NULL,
    [cfctl_reminder_notice1]         CHAR (60)   NULL,
    [cfctl_reminder_notice2]         CHAR (60)   NULL,
    [cfctl_vnd_no]                   CHAR (10)   NULL,
    [cfctl_next_ivc_no]              CHAR (8)    NULL,
    [cfctl_months_to_keep_history]   SMALLINT    NULL,
    [cfctl_last_hist_purge_dt]       INT         NULL,
    [cfctl_ivc_printer]              CHAR (80)   NULL,
    [cfctl_use_pdv_yn]               CHAR (1)    NULL,
    [cfctl_prc_for_adj_ps]           CHAR (1)    NULL,
    [cfctl_chkbk]                    CHAR (2)    NULL,
    [cfctl_vehl_req_yn]              CHAR (1)    NULL,
    [cfctl_cost_to_use_for_sp]       CHAR (1)    NULL,
    [cfctl_ar_dm_yn]                 CHAR (1)    NULL,
    [cfctl_acct_stat_misc_vehl]      CHAR (1)    NULL,
    [cfctl_embosser_device]          CHAR (12)   NULL,
    [cfctl_use_cnt_yn]               CHAR (1)    NULL,
    [cfctl_dflt_cnt_loc_no]          CHAR (3)    NULL,
    [cfctl_price_to_use_for_sp]      CHAR (1)    NULL,
    [cfctl_site_or_vehl_desc_on_ivc] CHAR (1)    NULL,
    [cfctl_def_network_id]           CHAR (3)    NULL,
    [cfctl_add_piggyback_to_sst_yn]  CHAR (1)    NULL,
    [cfctl_ivc_comment1]             CHAR (70)   NULL,
    [cfctl_ivc_comment2]             CHAR (70)   NULL,
    [cfctl_ivc_comment3]             CHAR (70)   NULL,
    [cfctl_auto_blend_yn]            CHAR (1)    NULL,
    [cfctl_pr_co_add]                CHAR (1)    NULL,
    [cfctl_pr_remit_pg]              CHAR (1)    NULL,
    [cfctl_ivc_pgm_name]             CHAR (8)    NULL,
    [cfctl_ivc_prt_prc_wtax_yn]      CHAR (1)    NULL,
    [cfctl_next_sum_ivc_no]          CHAR (6)    NULL,
    [cfctl_sum_invc_single_loc_yn]   CHAR (1)    NULL,
    [cfctl_sum_invc_single_loc]      CHAR (3)    NULL,
    [cfctl_user_id]                  CHAR (16)   NULL,
    [cfctl_user_rev_dt]              INT         NULL,
    [A4GLIdentity]                   NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfctlmst] PRIMARY KEY NONCLUSTERED ([cfctl_record_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfctlmst0]
    ON [dbo].[cfctlmst]([cfctl_record_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfctlmst] TO PUBLIC
    AS [dbo];

