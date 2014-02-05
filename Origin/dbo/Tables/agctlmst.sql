﻿CREATE TABLE [dbo].[agctlmst] (
    [agctl_key]                     TINYINT         NOT NULL,
    [agctl_password]                CHAR (16)       NULL,
    [agctl_cst_password]            CHAR (16)       NULL,
    [agctl_crd_password]            CHAR (16)       NULL,
    [agctl_bdgt_password]           CHAR (16)       NULL,
    [agctl_sl_inter_yn]             CHAR (1)        NULL,
    [agctl_ap_inter_yn]             CHAR (1)        NULL,
    [agctl_ga_inter_yn]             CHAR (1)        NULL,
    [agctl_apply_ga_cnts_yn]        CHAR (1)        NULL,
    [agctl_ga_allow_od_yn]          CHAR (1)        NULL,
    [agctl_curr_pd]                 TINYINT         NULL,
    [agctl_farmland_org_no]         CHAR (5)        NULL,
    [agctl_cost_convert_cd]         CHAR (10)       NULL,
    [agctl_vnd_no]                  CHAR (10)       NULL,
    [agctl_min_srvchr]              DECIMAL (7, 2)  NULL,
    [agctl_fml1_desc]               CHAR (15)       NULL,
    [agctl_fml2_desc]               CHAR (15)       NULL,
    [agctl_fml3_desc]               CHAR (15)       NULL,
    [agctl_fml4_desc]               CHAR (15)       NULL,
    [agctl_max_ivc_avg_days_pay]    SMALLINT        NULL,
    [agctl_co_rup_dealer_no]        INT             NULL,
    [agctl_last_po_no]              INT             NULL,
    [agctl_last_cnt_no]             INT             NULL,
    [agctl_next_eod_run_no]         SMALLINT        NULL,
    [agctl_next_inv_run_no]         SMALLINT        NULL,
    [agctl_next_itm_adj_xfr_no]     SMALLINT        NULL,
    [agctl_forms_co_yn]             CHAR (1)        NULL,
    [agctl_auto_archive_eod]        CHAR (1)        NULL,
    [agctl_ord_cash_audit_yn]       CHAR (1)        NULL,
    [agctl_ord_county_upd_yn]       CHAR (1)        NULL,
    [agctl_allow_post_all_yn]       CHAR (1)        NULL,
    [agctl_allow_all_phys_updt_yn]  CHAR (1)        NULL,
    [agctl_allow_ovr_cred_ynw]      CHAR (1)        NULL,
    [agctl_adb_srvchr_yn]           CHAR (1)        NULL,
    [agctl_sc_on_sc_yn]             CHAR (1)        NULL,
    [agctl_apply_disc_yno]          CHAR (1)        NULL,
    [agctl_item_audit_yna]          CHAR (1)        NULL,
    [agctl_stmt_bdgt_pastdue_yn]    CHAR (1)        NULL,
    [agctl_stmt_cash_sales_yn]      CHAR (1)        NULL,
    [agctl_stmt_future_ivcs_ynf]    CHAR (1)        NULL,
    [agctl_stmt_ivc_dtl_yn]         CHAR (1)        NULL,
    [agctl_stmt_postnet_yn]         CHAR (1)        NULL,
    [agctl_stmt_tearoff_ref_no_ind] CHAR (1)        NULL,
    [agctl_stmt_recap_ynpb]         CHAR (1)        NULL,
    [agctl_stmt_type]               CHAR (1)        NULL,
    [agctl_stmt_prtr_name]          CHAR (80)       NULL,
    [agctl_fill_cnt_by_cls_yn]      CHAR (1)        NULL,
    [agctl_cnt_itm_warn_yn]         CHAR (1)        NULL,
    [agctl_sp_by_bs]                CHAR (1)        NULL,
    [agctl_upd_xfer_last_cost_yn]   CHAR (1)        NULL,
    [agctl_upd_bln_last_cost_yn]    CHAR (1)        NULL,
    [agctl_upd_last_cost_yn]        CHAR (1)        NULL,
    [agctl_upd_std_cost_wfrt_yn]    CHAR (1)        NULL,
    [agctl_phs_purge_rev_dt]        INT             NULL,
    [agctl_inv_close_rev_dt]        INT             NULL,
    [agctl_stmt_close_rev_dt]       INT             NULL,
    [agctl_ivc_purge_rev_dt]        INT             NULL,
    [agctl_sls_purge_rev_dt]        INT             NULL,
    [agctl_inc_purge_rev_dt]        INT             NULL,
    [agctl_iar_purge_rev_dt]        INT             NULL,
    [agctl_sa_cost_ind]             CHAR (1)        NULL,
    [agctl_gl_payables_ind]         CHAR (1)        NULL,
    [agctl_slsmn_by_lob_yn]         CHAR (1)        NULL,
    [agctl_req_mkt_zone_yn]         CHAR (1)        NULL,
    [agctl_aw_doc_order_num_yn]     CHAR (1)        NULL,
    [agctl_bln_gl_acct_pv]          CHAR (1)        NULL,
    [agctl_eod_in_prc_yn]           CHAR (1)        NULL,
    [agctl_updt_grain_yn]           CHAR (1)        NULL,
    [agctl_stmt_ppd_by_invc_yn]     CHAR (1)        NULL,
    [agctl_eom_in_process]          CHAR (1)        NULL,
    [agctl_stmt_exc_tax_yn]         CHAR (1)        NULL,
    [agctl_auto_split_yn]           CHAR (1)        NULL,
    [agctl_user_id]                 CHAR (16)       NULL,
    [agctl_user_rev_dt]             INT             NULL,
    [agc13_seed_tag_prtr]           CHAR (80)       NULL,
    [agc14_wn_submitter_ic_cd]      BIGINT          NULL,
    [agc14_wn_batch_id_no]          INT             NULL,
    [agc14_wn_beg_season_rev_dt]    INT             NULL,
    [agc14_wn_end_season_rev_dt]    INT             NULL,
    [agc14_wn_export_path]          CHAR (50)       NULL,
    [agc15_ae_cus_acct_stat]        CHAR (10)       NULL,
    [agc15_ae_import_max_copy]      SMALLINT        NULL,
    [agc15_ae_import_next_copy]     SMALLINT        NULL,
    [agc15_ae_route_translate]      CHAR (1)        NULL,
    [agc15_ae_last_cus_export_dt]   INT             NULL,
    [agc15_ae_import_path]          CHAR (50)       NULL,
    [agc15_ae_export_path]          CHAR (50)       NULL,
    [agc15_ae_archive_path]         CHAR (50)       NULL,
    [agc15_ae_beg_cls_cd]           CHAR (3)        NULL,
    [agc15_ae_end_cls_cd]           CHAR (3)        NULL,
    [agc15_ae_sst_item]             CHAR (10)       NULL,
    [agc15_ae_csd_min]              DECIMAL (5, 2)  NULL,
    [agc15_ovd_cnt_sst_yn]          CHAR (1)        NULL,
    [agc15_ae_export_interval]      TINYINT         NULL,
    [agc16_mc_default_pay_type]     TINYINT         NULL,
    [agc16_mc_default_loc_no]       CHAR (3)        NULL,
    [agc16_mc_ver]                  DECIMAL (4, 2)  NULL,
    [agc16_mc_import_path]          CHAR (50)       NULL,
    [agc16_mc_export_path]          CHAR (50)       NULL,
    [agc16_mc_archive_path]         CHAR (50)       NULL,
    [agc16_mc_charge_sst_by_lc]     CHAR (1)        NULL,
    [agcar_co_ptd_pur]              DECIMAL (11, 2) NULL,
    [agcar_co_ptd_sls]              DECIMAL (11, 2) NULL,
    [agcar_co_ptd_cgs]              DECIMAL (11, 2) NULL,
    [agcar_co_ytd_pur]              DECIMAL (11, 2) NULL,
    [agcar_co_ytd_sls]              DECIMAL (11, 2) NULL,
    [agcar_co_ytd_cgs]              DECIMAL (11, 2) NULL,
    [agcar_co_dr_ar]                DECIMAL (11, 2) NULL,
    [agcar_co_cred_reg]             DECIMAL (11, 2) NULL,
    [agcar_future_desc]             CHAR (12)       NULL,
    [agcar_future_bal]              DECIMAL (11, 2) NULL,
    [agcar_per1_desc]               CHAR (12)       NULL,
    [agcar_per1_rev_dt]             INT             NULL,
    [agcar_per1_bal]                DECIMAL (11, 2) NULL,
    [agcar_per2_desc]               CHAR (12)       NULL,
    [agcar_per2_rev_dt]             INT             NULL,
    [agcar_per2_bal]                DECIMAL (11, 2) NULL,
    [agcar_per3_desc]               CHAR (12)       NULL,
    [agcar_per3_rev_dt]             INT             NULL,
    [agcar_per3_bal]                DECIMAL (11, 2) NULL,
    [agcar_per4_desc]               CHAR (12)       NULL,
    [agcar_per4_rev_dt]             INT             NULL,
    [agcar_per4_bal]                DECIMAL (11, 2) NULL,
    [agcar_per5_desc]               CHAR (12)       NULL,
    [agcar_per5_rev_dt]             INT             NULL,
    [agcar_per5_bal]                DECIMAL (11, 2) NULL,
    [agcar_gl_rev_dt]               INT             NULL,
    [agcar_co_cred_ppd]             DECIMAL (11, 2) NULL,
    [agcar_co_cred_ga]              DECIMAL (11, 2) NULL,
    [agcar_cc_fees_1]               DECIMAL (3, 2)  NULL,
    [agcar_cc_fees_2]               DECIMAL (3, 2)  NULL,
    [agcar_cc_fees_3]               DECIMAL (3, 2)  NULL,
    [agcar_cc_fees_4]               DECIMAL (3, 2)  NULL,
    [agcar_cc_fees_5]               DECIMAL (3, 2)  NULL,
    [agcar_cc_fees_6]               DECIMAL (3, 2)  NULL,
    [agcar_cc_fees_7]               DECIMAL (3, 2)  NULL,
    [agcar_cc_fees_8]               DECIMAL (3, 2)  NULL,
    [agcar_cc_fees_9]               DECIMAL (3, 2)  NULL,
    [agcgl_ar]                      DECIMAL (16, 8) NULL,
    [agcgl_srvchr]                  DECIMAL (16, 8) NULL,
    [agcgl_disc_taken]              DECIMAL (16, 8) NULL,
    [agcgl_ppd]                     DECIMAL (16, 8) NULL,
    [agcgl_spl_variance]            DECIMAL (16, 8) NULL,
    [agcgl_pend_ap]                 DECIMAL (16, 8) NULL,
    [agcgl_write_off]               DECIMAL (16, 8) NULL,
    [agcgl_collect_fet_yn]          CHAR (1)        NULL,
    [agcgl_collect_set_yn]          CHAR (1)        NULL,
    [agcgl_collect_lc1_yn]          CHAR (1)        NULL,
    [agcgl_collect_lc2_yn]          CHAR (1)        NULL,
    [agcgl_collect_lc3_yn]          CHAR (1)        NULL,
    [agcgl_collect_lc4_yn]          CHAR (1)        NULL,
    [agcgl_collect_lc5_yn]          CHAR (1)        NULL,
    [agcgl_collect_lc6_yn]          CHAR (1)        NULL,
    [agct2_pay_desc_1]              CHAR (12)       NULL,
    [agct2_pay_desc_2]              CHAR (12)       NULL,
    [agct2_pay_desc_3]              CHAR (12)       NULL,
    [agct2_pay_desc_4]              CHAR (12)       NULL,
    [agct2_pay_desc_5]              CHAR (12)       NULL,
    [agct2_pay_desc_6]              CHAR (12)       NULL,
    [agct2_pay_desc_7]              CHAR (12)       NULL,
    [agct2_pay_desc_8]              CHAR (12)       NULL,
    [agct2_pay_desc_9]              CHAR (12)       NULL,
    [agct2_pay_ind_1]               CHAR (1)        NULL,
    [agct2_pay_ind_2]               CHAR (1)        NULL,
    [agct2_pay_ind_3]               CHAR (1)        NULL,
    [agct2_pay_ind_4]               CHAR (1)        NULL,
    [agct2_pay_ind_5]               CHAR (1)        NULL,
    [agct2_pay_ind_6]               CHAR (1)        NULL,
    [agct2_pay_ind_7]               CHAR (1)        NULL,
    [agct2_pay_ind_8]               CHAR (1)        NULL,
    [agct2_pay_ind_9]               CHAR (1)        NULL,
    [agct2_pay_gl_acct_1]           DECIMAL (16, 8) NULL,
    [agct2_pay_gl_acct_2]           DECIMAL (16, 8) NULL,
    [agct2_pay_gl_acct_3]           DECIMAL (16, 8) NULL,
    [agct2_pay_gl_acct_4]           DECIMAL (16, 8) NULL,
    [agct2_pay_gl_acct_5]           DECIMAL (16, 8) NULL,
    [agct2_pay_gl_acct_6]           DECIMAL (16, 8) NULL,
    [agct2_pay_gl_acct_7]           DECIMAL (16, 8) NULL,
    [agct2_pay_gl_acct_8]           DECIMAL (16, 8) NULL,
    [agct2_pay_gl_acct_9]           DECIMAL (16, 8) NULL,
    [agct3_assign_cus_no_yn]        CHAR (1)        NULL,
    [agct3_last_cus_no]             BIGINT          NULL,
    [agct7_lob1_desc]               CHAR (12)       NULL,
    [agct7_lob2_desc]               CHAR (12)       NULL,
    [agct7_lob3_desc]               CHAR (12)       NULL,
    [agct7_lob4_desc]               CHAR (12)       NULL,
    [agct7_lob5_desc]               CHAR (12)       NULL,
    [agct7_lob6_desc]               CHAR (12)       NULL,
    [agct7_lob7_desc]               CHAR (12)       NULL,
    [agct7_lob8_desc]               CHAR (12)       NULL,
    [agct7_lob9_desc]               CHAR (12)       NULL,
    [agct8_branch_no_1]             TINYINT         NULL,
    [agct8_branch_no_2]             TINYINT         NULL,
    [agct8_branch_no_3]             TINYINT         NULL,
    [agct8_branch_no_4]             TINYINT         NULL,
    [agct8_branch_no_5]             TINYINT         NULL,
    [agct8_branch_no_6]             TINYINT         NULL,
    [agct8_branch_no_7]             TINYINT         NULL,
    [agct8_branch_no_8]             TINYINT         NULL,
    [agct8_branch_no_9]             TINYINT         NULL,
    [agct8_branch_no_10]            TINYINT         NULL,
    [agct8_loc_no_1]                CHAR (3)        NULL,
    [agct8_loc_no_2]                CHAR (3)        NULL,
    [agct8_loc_no_3]                CHAR (3)        NULL,
    [agct8_loc_no_4]                CHAR (3)        NULL,
    [agct8_loc_no_5]                CHAR (3)        NULL,
    [agct8_loc_no_6]                CHAR (3)        NULL,
    [agct8_loc_no_7]                CHAR (3)        NULL,
    [agct8_loc_no_8]                CHAR (3)        NULL,
    [agct8_loc_no_9]                CHAR (3)        NULL,
    [agct8_loc_no_10]               CHAR (3)        NULL,
    [agct8_crop_terms_cd_1]         TINYINT         NULL,
    [agct8_crop_terms_cd_2]         TINYINT         NULL,
    [agct8_crop_terms_cd_3]         TINYINT         NULL,
    [agct8_crop_terms_cd_4]         TINYINT         NULL,
    [agct8_crop_terms_cd_5]         TINYINT         NULL,
    [agct8_crop_terms_cd_6]         TINYINT         NULL,
    [agct8_crop_terms_cd_7]         TINYINT         NULL,
    [agct8_crop_terms_cd_8]         TINYINT         NULL,
    [agct8_crop_terms_cd_9]         TINYINT         NULL,
    [agct8_crop_terms_cd_10]        TINYINT         NULL,
    [agct8_ag_terms_cd_1]           TINYINT         NULL,
    [agct8_ag_terms_cd_2]           TINYINT         NULL,
    [agct8_ag_terms_cd_3]           TINYINT         NULL,
    [agct8_ag_terms_cd_4]           TINYINT         NULL,
    [agct8_ag_terms_cd_5]           TINYINT         NULL,
    [agct8_ag_terms_cd_6]           TINYINT         NULL,
    [agct8_ag_terms_cd_7]           TINYINT         NULL,
    [agct8_ag_terms_cd_8]           TINYINT         NULL,
    [agct8_ag_terms_cd_9]           TINYINT         NULL,
    [agct8_ag_terms_cd_10]          TINYINT         NULL,
    [agct8_ppd_terms_cd]            TINYINT         NULL,
    [agct8_ppd_terms_cd2]           TINYINT         NULL,
    [agct8_dflt_pay_type]           CHAR (1)        NULL,
    [agct8_crstmt_path]             CHAR (50)       NULL,
    [agct8_crbill_path]             CHAR (50)       NULL,
    [agct8_import_path]             CHAR (50)       NULL,
    [agct8_export_path]             CHAR (50)       NULL,
    [agct8_interface_type]          CHAR (1)        NULL,
    [agct8_type_import]             CHAR (1)        NULL,
    [agecf_sender_id_tic]           CHAR (18)       NULL,
    [agecf_mobil_buyback_yn]        CHAR (1)        NULL,
    [agecf_mobil_receiver_id]       CHAR (18)       NULL,
    [agecf_mbb_serial_no_n]         INT             NULL,
    [agecf_edi_dflt_contact]        CHAR (20)       NULL,
    [agecf_edi_dflt_phone]          CHAR (20)       NULL,
    [agecf_sender_id_pur]           CHAR (18)       NULL,
    [agmcf_stock_cus_no]            CHAR (10)       NULL,
    [agmcf_last_stock_ord]          INT             NULL,
    [agmcf_apec_installed_yn]       CHAR (1)        NULL,
    [agmcf_apec_bridge_path]        CHAR (50)       NULL,
    [A4GLIdentity]                  NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [agctl_eom_password]            CHAR (4)        NULL,
    [agctl_gi_doc_order_num_yn]     CHAR (1)        NULL,
    CONSTRAINT [k_agctlmst] PRIMARY KEY NONCLUSTERED ([agctl_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagctlmst0]
    ON [dbo].[agctlmst]([agctl_key] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agctlmst] TO PUBLIC
    AS [dbo];

