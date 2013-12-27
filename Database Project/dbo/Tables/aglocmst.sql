CREATE TABLE [dbo].[aglocmst] (
    [agloc_loc_no]                CHAR (3)        NOT NULL,
    [agloc_name]                  CHAR (30)       NULL,
    [agloc_addr]                  CHAR (30)       NULL,
    [agloc_addr2]                 CHAR (30)       NULL,
    [agloc_city]                  CHAR (20)       NULL,
    [agloc_state]                 CHAR (2)        NULL,
    [agloc_zip]                   CHAR (10)       NULL,
    [agloc_country]               CHAR (3)        NULL,
    [agloc_phone]                 CHAR (15)       NULL,
    [agloc_inv_by_loc_ynd]        CHAR (1)        NULL,
    [agloc_tax_by_loc_only_ynv]   CHAR (1)        NULL,
    [agloc_tax_state]             CHAR (2)        NULL,
    [agloc_tax_auth_id1]          CHAR (3)        NULL,
    [agloc_tax_auth_id2]          CHAR (3)        NULL,
    [agloc_csh_drwr_yn]           CHAR (1)        NULL,
    [agloc_csh_drwr_dev_id]       CHAR (80)       NULL,
    [agloc_reg_tape_yn]           CHAR (1)        NULL,
    [agloc_reg_tape_prtr]         CHAR (80)       NULL,
    [agloc_bar_code_prtr]         CHAR (80)       NULL,
    [agloc_pic_prtr_name]         CHAR (80)       NULL,
    [agloc_ivc_prtr_name]         CHAR (80)       NULL,
    [agloc_cnt_prtr_name]         CHAR (80)       NULL,
    [agloc_last_ivc_no]           INT             NULL,
    [agloc_last_ord_no]           INT             NULL,
    [agloc_ord_for_ivc_yn]        CHAR (1)        NULL,
    [agloc_override_ord_ivc_yn]   CHAR (1)        NULL,
    [agloc_ivc_type_phs7]         CHAR (1)        NULL,
    [agloc_upc_ord_yn]            CHAR (1)        NULL,
    [agloc_upc_rct_yn]            CHAR (1)        NULL,
    [agloc_upc_search_ui]         CHAR (1)        NULL,
    [agloc_upc_phy_yn]            CHAR (1)        NULL,
    [agloc_upc_pur_yn]            CHAR (1)        NULL,
    [agloc_mixer_size]            DECIMAL (9, 4)  NULL,
    [agloc_override_mixer_yn]     CHAR (1)        NULL,
    [agloc_even_batch_yn]         CHAR (1)        NULL,
    [agloc_cash_rcts_ynr]         CHAR (1)        NULL,
    [agloc_cash_tender_yn]        CHAR (1)        NULL,
    [agloc_dd_clock_loc]          CHAR (3)        NULL,
    [agloc_season_ind_sw]         CHAR (1)        NULL,
    [agloc_summer_chng_rev_dt]    INT             NULL,
    [agloc_dlv_tic_prtr]          CHAR (80)       NULL,
    [agloc_dlv_tic_no]            INT             NULL,
    [agloc_dflt_lp_pct_full]      SMALLINT        NULL,
    [agloc_dlv_tic_fmt]           CHAR (1)        NULL,
    [agloc_rdg_entry_meth_ad]     CHAR (1)        NULL,
    [agloc_fill_by_class_yn]      CHAR (1)        NULL,
    [agloc_fill_class]            CHAR (3)        NULL,
    [agloc_base_temp]             SMALLINT        NULL,
    [agloc_winter_chng_rev_dt]    INT             NULL,
    [agloc_winter_accum_dd]       INT             NULL,
    [agloc_custom_blend_yn]       CHAR (1)        NULL,
    [agloc_dflt_dlvr_pkup_ind]    CHAR (1)        NULL,
    [agloc_ord_sec2_req_yn]       CHAR (1)        NULL,
    [agloc_item_warning_yn]       CHAR (1)        NULL,
    [agloc_skip_slsmn_dflt_ynrs]  CHAR (1)        NULL,
    [agloc_skip_terms_dflt_yn]    CHAR (1)        NULL,
    [agloc_override_pat_yn]       CHAR (1)        NULL,
    [agloc_dflt_tic_type_ois]     CHAR (1)        NULL,
    [agloc_dflt_pic_tkt_type_pms] CHAR (1)        NULL,
    [agloc_wn_retailer_ic_cd]     BIGINT          NULL,
    [agloc_prc1_desc]             CHAR (12)       NULL,
    [agloc_prc2_desc]             CHAR (12)       NULL,
    [agloc_prc3_desc]             CHAR (12)       NULL,
    [agloc_prc4_desc]             CHAR (12)       NULL,
    [agloc_prc5_desc]             CHAR (12)       NULL,
    [agloc_prc6_desc]             CHAR (12)       NULL,
    [agloc_prc7_desc]             CHAR (12)       NULL,
    [agloc_prc8_desc]             CHAR (12)       NULL,
    [agloc_prc9_desc]             CHAR (12)       NULL,
    [agloc_gl_profit_center]      INT             NULL,
    [agloc_frt_exp_acct_no]       DECIMAL (16, 8) NULL,
    [agloc_frt_inc_acct_no]       DECIMAL (16, 8) NULL,
    [agloc_cash]                  DECIMAL (16, 8) NULL,
    [agloc_srvchr]                DECIMAL (16, 8) NULL,
    [agloc_disc_taken]            DECIMAL (16, 8) NULL,
    [agloc_over_short]            DECIMAL (16, 8) NULL,
    [agloc_ccfee_percent]         DECIMAL (16, 8) NULL,
    [agloc_write_off]             DECIMAL (16, 8) NULL,
    [agloc_gl_div_col]            TINYINT         NULL,
    [agloc_disc_by_lob_yn]        CHAR (1)        NULL,
    [agloc_use_addr_ynal]         CHAR (1)        NULL,
    [agloc_prt_cnt_bal_ynu]       CHAR (1)        NULL,
    [agloc_prt_ivc_med_tags_yn]   CHAR (1)        NULL,
    [agloc_prt_pic_med_tags_yn]   CHAR (1)        NULL,
    [agloc_ivc_prt_ipo]           CHAR (1)        NULL,
    [agloc_ivc_comment1]          CHAR (78)       NULL,
    [agloc_ivc_comment2]          CHAR (78)       NULL,
    [agloc_ivc_comment3]          CHAR (78)       NULL,
    [agloc_ivc_comment4]          CHAR (78)       NULL,
    [agloc_ivc_comment5]          CHAR (78)       NULL,
    [agloc_pic_comment1]          CHAR (78)       NULL,
    [agloc_pic_comment2]          CHAR (78)       NULL,
    [agloc_pic_comment3]          CHAR (78)       NULL,
    [agloc_pic_comment4]          CHAR (78)       NULL,
    [agloc_pic_comment5]          CHAR (78)       NULL,
    [agloc_default_carrier]       CHAR (10)       NULL,
    [agloc_auto_dep_yn]           CHAR (1)        NULL,
    [agloc_gen_ovr_short_yn]      CHAR (1)        NULL,
    [agloc_oth_inc_cd]            CHAR (2)        NULL,
    [agloc_oth_inc_cus_no]        CHAR (10)       NULL,
    [agloc_upd_cost_yn]           CHAR (1)        NULL,
    [agloc_lot_warning_yns]       CHAR (1)        NULL,
    [agloc_var_pct]               DECIMAL (5, 2)  NULL,
    [agloc_po_prt_pu]             CHAR (1)        NULL,
    [agloc_active_yn]             CHAR (1)        NULL,
    [agloc_agroguide_yn]          CHAR (1)        NULL,
    [agloc_merchant]              CHAR (10)       NULL,
    [agloc_send_to_et_yn]         CHAR (1)        NULL,
    [agloc_user_id]               CHAR (16)       NULL,
    [agloc_user_rev_dt]           CHAR (8)        NULL,
    [A4GLIdentity]                NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aglocmst] PRIMARY KEY NONCLUSTERED ([agloc_loc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iaglocmst0]
    ON [dbo].[aglocmst]([agloc_loc_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[aglocmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[aglocmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[aglocmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[aglocmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[aglocmst] TO PUBLIC
    AS [dbo];

