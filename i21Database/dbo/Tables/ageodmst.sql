﻿CREATE TABLE [dbo].[ageodmst] (
    [agaud_trans_type]         CHAR (2)        NOT NULL,
    [agaud_key_data]           CHAR (29)       NOT NULL,
    [agaudbln_itm_class]       CHAR (3)        NULL,
    [agaudbln_itm_desc]        CHAR (35)       NULL,
    [agaudbln_rev_dt]          INT             NULL,
    [agaudbln_ingr_itm_no]     CHAR (13)       NULL,
    [agaudbln_ingr_itm_desc]   CHAR (35)       NULL,
    [agaudbln_ingr_lbs]        DECIMAL (11, 4) NULL,
    [agaudbln_comments]        CHAR (30)       NULL,
    [agaudbln_gb_updated_yn]   CHAR (1)        NULL,
    [agaudbln_user_id]         CHAR (16)       NULL,
    [agaudbln_user_rev_dt]     INT             NULL,
    [agaudcrd_type]            CHAR (1)        NULL,
    [agaudcrd_ref_no]          CHAR (8)        NULL,
    [agaudcrd_amt]             DECIMAL (11, 2) NULL,
    [agaudcrd_amt_used]        DECIMAL (11, 2) NULL,
    [agaudcrd_cred_ind]        CHAR (1)        NULL,
    [agaudcrd_acct_no]         DECIMAL (16, 8) NULL,
    [agaudcrd_loc_no]          CHAR (3)        NULL,
    [agaudcrd_note]            CHAR (15)       NULL,
    [agaudcrd_batch_no]        SMALLINT        NULL,
    [agaudcrd_currency]        CHAR (3)        NULL,
    [agaudcrd_currency_rt]     DECIMAL (15, 8) NULL,
    [agaudcrd_currency_cnt]    CHAR (8)        NULL,
    [agaudcrd_pay_type]        CHAR (1)        NULL,
    [agaudcrd_user_id]         CHAR (16)       NULL,
    [agaudcrd_user_rev_dt]     INT             NULL,
    [agaudinc_reversal_yn]     CHAR (1)        NULL,
    [agaudinc_rev_dt]          INT             NULL,
    [agaudinc_amt]             DECIMAL (11, 2) NULL,
    [agaudinc_gl_acct]         DECIMAL (16, 8) NULL,
    [agaudinc_comment]         CHAR (30)       NULL,
    [agaudinc_batch_no]        SMALLINT        NULL,
    [agaudinc_pay_type]        CHAR (1)        NULL,
    [agaudinc_currency]        CHAR (3)        NULL,
    [agaudinc_currency_rt]     DECIMAL (15, 8) NULL,
    [agaudinc_currency_cnt]    CHAR (8)        NULL,
    [agaudinc_user_id]         CHAR (16)       NULL,
    [agaudinc_user_rev_dt]     INT             NULL,
    [agaudord_ivc_no]          CHAR (8)        NULL,
    [agaudord_batch_no]        SMALLINT        NULL,
    [agaudord_ord_rev_dt]      INT             NULL,
    [agaudord_req_ship_rev_dt] INT             NULL,
    [agaudord_ship_rev_dt]     INT             NULL,
    [agaudord_type]            CHAR (1)        NULL,
    [agaudord_bill_to_cus]     CHAR (10)       NULL,
    [agaudord_bill_to_split]   CHAR (4)        NULL,
    [agaudord_cash_tendered]   DECIMAL (11, 2) NULL,
    [agaudord_order_total]     DECIMAL (11, 2) NULL,
    [agaudord_ship_total]      DECIMAL (11, 2) NULL,
    [agaudord_disc_total]      DECIMAL (9, 2)  NULL,
    [agaudord_slsmn_id]        CHAR (3)        NULL,
    [agaudord_po_no]           CHAR (15)       NULL,
    [agaudord_terms_cd]        TINYINT         NULL,
    [agaudord_comments]        CHAR (30)       NULL,
    [agaudord_ship_type]       CHAR (1)        NULL,
    [agaudord_srv_chg_cd]      TINYINT         NULL,
    [agaudord_adj_inv_yn]      CHAR (1)        NULL,
    [agaudord_tank_no]         CHAR (4)        NULL,
    [agaudord_lp_pct_full]     SMALLINT        NULL,
    [agaudord_itm_no]          CHAR (13)       NULL,
    [agaudord_dtl_comments]    CHAR (33)       NULL,
    [agaudord_un_prc]          DECIMAL (11, 5) NULL,
    [agaudord_pkg_sold]        DECIMAL (11, 4) NULL,
    [agaudord_un_sold]         DECIMAL (11, 4) NULL,
    [agaudord_fet_amt]         DECIMAL (11, 2) NULL,
    [agaudord_fet_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_set_amt]         DECIMAL (11, 2) NULL,
    [agaudord_set_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_sst_amt]         DECIMAL (11, 2) NULL,
    [agaudord_sst_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_sst_pu]          CHAR (1)        NULL,
    [agaudord_sst_on_net]      DECIMAL (11, 2) NULL,
    [agaudord_sst_on_fet]      DECIMAL (11, 2) NULL,
    [agaudord_sst_on_set]      DECIMAL (11, 2) NULL,
    [agaudord_sst_on_lc1]      DECIMAL (11, 2) NULL,
    [agaudord_sst_on_lc2]      DECIMAL (11, 2) NULL,
    [agaudord_sst_on_lc3]      DECIMAL (11, 2) NULL,
    [agaudord_sst_on_lc4]      DECIMAL (11, 2) NULL,
    [agaudord_sst_on_lc5]      DECIMAL (11, 2) NULL,
    [agaudord_sst_on_lc6]      DECIMAL (11, 2) NULL,
    [agaudord_lc1_amt]         DECIMAL (11, 2) NULL,
    [agaudord_lc1_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_lc1_pu]          CHAR (1)        NULL,
    [agaudord_lc1_on_net]      DECIMAL (11, 2) NULL,
    [agaudord_lc1_on_fet]      DECIMAL (11, 2) NULL,
    [agaudord_lc2_amt]         DECIMAL (11, 2) NULL,
    [agaudord_lc2_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_lc2_pu]          CHAR (1)        NULL,
    [agaudord_lc2_on_net]      DECIMAL (11, 2) NULL,
    [agaudord_lc2_on_fet]      DECIMAL (11, 2) NULL,
    [agaudord_lc3_amt]         DECIMAL (11, 2) NULL,
    [agaudord_lc3_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_lc3_pu]          CHAR (1)        NULL,
    [agaudord_lc3_on_net]      DECIMAL (11, 2) NULL,
    [agaudord_lc3_on_fet]      DECIMAL (11, 2) NULL,
    [agaudord_lc4_amt]         DECIMAL (11, 2) NULL,
    [agaudord_lc4_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_lc4_pu]          CHAR (1)        NULL,
    [agaudord_lc4_on_net]      DECIMAL (11, 2) NULL,
    [agaudord_lc4_on_fet]      DECIMAL (11, 2) NULL,
    [agaudord_lc5_amt]         DECIMAL (11, 2) NULL,
    [agaudord_lc5_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_lc5_pu]          CHAR (1)        NULL,
    [agaudord_lc5_on_net]      DECIMAL (11, 2) NULL,
    [agaudord_lc5_on_fet]      DECIMAL (11, 2) NULL,
    [agaudord_lc6_amt]         DECIMAL (11, 2) NULL,
    [agaudord_lc6_rt]          DECIMAL (9, 6)  NULL,
    [agaudord_lc6_pu]          CHAR (1)        NULL,
    [agaudord_lc6_on_net]      DECIMAL (11, 2) NULL,
    [agaudord_lc6_on_fet]      DECIMAL (11, 2) NULL,
    [agaudord_pkg_ship]        DECIMAL (11, 4) NULL,
    [agaudord_un_ship]         DECIMAL (11, 4) NULL,
    [agaudord_ship_fet_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_fet_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_set_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_set_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_sst_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_sst_pu]     CHAR (1)        NULL,
    [agaudord_ship_sst_on_net] DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_on_fet] DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_on_set] DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_on_lc1] DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_on_lc2] DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_on_lc3] DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_on_lc4] DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_on_lc5] DECIMAL (11, 2) NULL,
    [agaudord_ship_sst_on_lc6] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc1_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_lc1_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_lc1_pu]     CHAR (1)        NULL,
    [agaudord_ship_lc1_on_net] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc1_on_fet] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc2_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_lc2_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_lc2_pu]     CHAR (1)        NULL,
    [agaudord_ship_lc2_on_net] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc2_on_fet] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc3_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_lc3_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_lc3_pu]     CHAR (1)        NULL,
    [agaudord_ship_lc3_on_net] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc3_on_fet] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc4_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_lc4_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_lc4_pu]     CHAR (1)        NULL,
    [agaudord_ship_lc4_on_net] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc4_on_fet] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc5_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_lc5_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_lc5_pu]     CHAR (1)        NULL,
    [agaudord_ship_lc5_on_net] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc5_on_fet] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc6_amt]    DECIMAL (11, 2) NULL,
    [agaudord_ship_lc6_rt]     DECIMAL (9, 6)  NULL,
    [agaudord_ship_lc6_pu]     CHAR (1)        NULL,
    [agaudord_ship_lc6_on_net] DECIMAL (11, 2) NULL,
    [agaudord_ship_lc6_on_fet] DECIMAL (11, 2) NULL,
    [agaudord_tax_state]       CHAR (2)        NULL,
    [agaudord_tax_auth_id1]    CHAR (3)        NULL,
    [agaudord_tax_auth_id2]    CHAR (3)        NULL,
    [agaudord_county]          CHAR (3)        NULL,
    [agaudord_ppd_dep_per_un]  DECIMAL (11, 5) NULL,
    [agaudord_lot_no_yn]       CHAR (1)        NULL,
    [agaudord_load_no]         CHAR (8)        NULL,
    [agaudord_bckord_yn]       CHAR (1)        NULL,
    [agaudord_cnt_cus_no]      CHAR (10)       NULL,
    [agaudord_cnt_no]          CHAR (8)        NULL,
    [agaudord_cnt_line_no]     SMALLINT        NULL,
    [agaudord_blend_yn]        CHAR (1)        NULL,
    [agaudord_disc_amt]        DECIMAL (9, 2)  NULL,
    [agaudord_ppd_cnt_yndm]    CHAR (1)        NULL,
    [agaudord_gl_acct]         DECIMAL (16, 8) NULL,
    [agaudord_applicator_no]   CHAR (10)       NULL,
    [agaudord_acct_stat]       CHAR (1)        NULL,
    [agaudord_sst_ynp]         CHAR (1)        NULL,
    [agaudord_un_cost]         DECIMAL (11, 5) NULL,
    [agaudord_src_sys]         CHAR (1)        NULL,
    [agaudord_pay_pat_yn]      CHAR (1)        NULL,
    [agaudord_prc_lvl]         TINYINT         NULL,
    [agaudord_dlvr_pkup_ind]   CHAR (1)        NULL,
    [agaudord_currency]        CHAR (3)        NULL,
    [agaudord_currency_rt]     DECIMAL (15, 8) NULL,
    [agaudord_currency_cnt]    CHAR (8)        NULL,
    [agaudord_hide_price_ynq]  CHAR (1)        NULL,
    [agaudord_order_taker]     CHAR (3)        NULL,
    [agaudord_xfer_exp_yn]     CHAR (1)        NULL,
    [agaudord_ingr_on_ivc_yn]  CHAR (1)        NULL,
    [agaudord_gb_updated_yn]   CHAR (1)        NULL,
    [agaudord_user_id]         CHAR (16)       NULL,
    [agaudord_user_rev_dt]     INT             NULL,
    [agaudord_user_time]       INT             NULL,
    [agaudpay_rev_dt]          INT             NULL,
    [agaudpay_chk_no]          CHAR (8)        NULL,
    [agaudpay_amt]             DECIMAL (11, 2) NULL,
    [agaudpay_acct_no]         DECIMAL (16, 8) NULL,
    [agaudpay_ref_no]          CHAR (8)        NULL,
    [agaudpay_orig_rev_dt]     INT             NULL,
    [agaudpay_cred_ind]        CHAR (1)        NULL,
    [agaudpay_cred_origin]     CHAR (1)        NULL,
    [agaudpay_batch_no]        SMALLINT        NULL,
    [agaudpay_pay_type]        CHAR (1)        NULL,
    [agaudpay_loc_no]          CHAR (3)        NULL,
    [agaudpay_note]            CHAR (15)       NULL,
    [agaudpay_audit_no]        CHAR (4)        NULL,
    [agaudpay_user_id]         CHAR (16)       NULL,
    [agaudpay_user_rev_dt]     INT             NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [agaudopy_record]          CHAR (829)      NULL,
    [agaudopy_detail_info]     CHAR (82)       NULL,
    [agaudopy_rev_dt]          INT             NULL,
    [agaudopy_chk_no]          CHAR (8)        NULL,
    [agaudopy_amt]             DECIMAL (11, 2) NULL,
    [agaudopy_acct_no]         DECIMAL (16, 8) NULL,
    [agaudopy_ref_no]          CHAR (8)        NULL,
    [agaudopy_orig_rev_dt]     INT             NULL,
    [agaudopy_cred_ind]        CHAR (1)        NULL,
    [agaudopy_cred_origin]     CHAR (1)        NULL,
    [agaudopy_batch_no]        SMALLINT        NULL,
    [agaudopy_pay_type]        CHAR (1)        NULL,
    [agaudopy_loc_no]          CHAR (3)        NULL,
    [agaudopy_note]            CHAR (15)       NULL,
    [agaudopy_audit_no]        CHAR (4)        NULL,
    [agaudopy_user_id]         CHAR (16)       NULL,
    [agaudopy_user_rev_dt]     INT             NULL,
    CONSTRAINT [k_ageodmst] PRIMARY KEY NONCLUSTERED ([agaud_trans_type] ASC, [agaud_key_data] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iageodmst0]
    ON [dbo].[ageodmst]([agaud_trans_type] ASC, [agaud_key_data] ASC);

