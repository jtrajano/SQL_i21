﻿CREATE TABLE [dbo].[agcusmst] (
    [agcus_key]               CHAR (10)       NOT NULL,
    [agcus_co_per_ind_cp]     CHAR (1)        NULL,
    [agcus_last_name]         CHAR (25)       NOT NULL,
    [agcus_first_name]        CHAR (25)       NOT NULL,
    [agcus_addr]              CHAR (30)       NULL,
    [agcus_addr2]             CHAR (30)       NULL,
    [agcus_city]              CHAR (20)       NULL,
    [agcus_state]             CHAR (2)        NULL,
    [agcus_zip]               CHAR (10)       NULL,
    [agcus_country]           CHAR (3)        NULL,
    [agcus_dlvry_point]       CHAR (2)        NULL,
    [agcus_county]            CHAR (3)        NULL,
    [agcus_phone]             CHAR (15)       NOT NULL,
    [agcus_phone_ext]         CHAR (4)        NULL,
    [agcus_phone2]            CHAR (15)       NULL,
    [agcus_phone2_ext]        CHAR (4)        NULL,
    [agcus_bill_to]           CHAR (10)       NULL,
    [agcus_contact]           CHAR (20)       NULL,
    [agcus_comments]          CHAR (30)       NULL,
    [agcus_tax_ynp]           CHAR (1)        NULL,
    [agcus_tax_state]         CHAR (2)        NULL,
    [agcus_tax_auth_id1]      CHAR (3)        NULL,
    [agcus_tax_auth_id2]      CHAR (3)        NULL,
    [agcus_tax_exempt]        CHAR (15)       NULL,
    [agcus_slsmn_id]          CHAR (3)        NULL,
    [agcus_stmt_cd]           CHAR (1)        NULL,
    [agcus_terms_cd]          TINYINT         NULL,
    [agcus_prc_lvl]           TINYINT         NULL,
    [agcus_srvchr_cd]         TINYINT         NULL,
    [agcus_pic_prc_yn]        CHAR (1)        NULL,
    [agcus_stmt_dtl_yn]       CHAR (1)        NULL,
    [agcus_stmt_fmt]          CHAR (1)        NULL,
    [agcus_acct_stat_x_1]     CHAR (1)        NULL,
    [agcus_acct_stat_x_2]     CHAR (1)        NULL,
    [agcus_acct_stat_x_3]     CHAR (1)        NULL,
    [agcus_acct_stat_x_4]     CHAR (1)        NULL,
    [agcus_acct_stat_x_5]     CHAR (1)        NULL,
    [agcus_acct_stat_x_6]     CHAR (1)        NULL,
    [agcus_acct_stat_x_7]     CHAR (1)        NULL,
    [agcus_acct_stat_x_8]     CHAR (1)        NULL,
    [agcus_acct_stat_x_9]     CHAR (1)        NULL,
    [agcus_acct_stat_x_10]    CHAR (1)        NULL,
    [agcus_acct_stat_x_11]    CHAR (1)        NULL,
    [agcus_acct_stat_x_12]    CHAR (1)        NULL,
    [agcus_acct_stat_x_13]    CHAR (1)        NULL,
    [agcus_acct_stat_x_14]    CHAR (1)        NULL,
    [agcus_acct_stat_x_15]    CHAR (1)        NULL,
    [agcus_acct_stat_x_16]    CHAR (1)        NULL,
    [agcus_acct_stat_x_17]    CHAR (1)        NULL,
    [agcus_acct_stat_x_18]    CHAR (1)        NULL,
    [agcus_acct_stat_x_19]    CHAR (1)        NULL,
    [agcus_acct_stat_x_20]    CHAR (1)        NULL,
    [agcus_ar_future]         DECIMAL (11, 2) NULL,
    [agcus_ar_per1]           DECIMAL (11, 2) NULL,
    [agcus_ar_per2]           DECIMAL (11, 2) NULL,
    [agcus_ar_per3]           DECIMAL (11, 2) NULL,
    [agcus_ar_per4]           DECIMAL (11, 2) NULL,
    [agcus_ar_per5]           DECIMAL (11, 2) NULL,
    [agcus_cred_reg]          DECIMAL (11, 2) NULL,
    [agcus_cred_ppd]          DECIMAL (11, 2) NULL,
    [agcus_pend_ivc]          DECIMAL (11, 2) NULL,
    [agcus_pend_pymt]         DECIMAL (11, 2) NULL,
    [agcus_ptd_pur]           INT             NULL,
    [agcus_ptd_sls]           DECIMAL (11, 2) NULL,
    [agcus_ptd_cgs]           DECIMAL (11, 2) NULL,
    [agcus_ytd_pur]           INT             NULL,
    [agcus_ytd_sls]           DECIMAL (11, 2) NULL,
    [agcus_ytd_cgs]           DECIMAL (11, 2) NULL,
    [agcus_lyr_pur]           INT             NULL,
    [agcus_lyr_sls]           DECIMAL (11, 2) NULL,
    [agcus_lyr_cgs]           DECIMAL (11, 2) NULL,
    [agcus_ytd_srvchr]        DECIMAL (9, 2)  NULL,
    [agcus_ytd_pay]           DECIMAL (11, 2) NULL,
    [agcus_ytd_disc]          DECIMAL (9, 2)  NULL,
    [agcus_budget_amt]        DECIMAL (9, 2)  NULL,
    [agcus_budget_amt_due]    DECIMAL (9, 2)  NULL,
    [agcus_budget_beg_mm]     TINYINT         NULL,
    [agcus_budget_end_mm]     TINYINT         NULL,
    [agcus_orig_rev_dt]       INT             NULL,
    [agcus_orig_user_id]      CHAR (16)       NULL,
    [agcus_cred_limit]        INT             NULL,
    [agcus_cred_stop_days]    SMALLINT        NULL,
    [agcus_last_ivc_rev_dt]   INT             NULL,
    [agcus_last_ivc_no]       CHAR (8)        NULL,
    [agcus_last_ivc_loc_no]   CHAR (3)        NULL,
    [agcus_last_crd_rev_dt]   INT             NULL,
    [agcus_last_pay_rev_dt]   INT             NULL,
    [agcus_last_pymt]         DECIMAL (11, 2) NULL,
    [agcus_last_stmt_rev_dt]  INT             NULL,
    [agcus_last_stmt_bal]     DECIMAL (11, 2) NULL,
    [agcus_last_ltr_name]     CHAR (8)        NULL,
    [agcus_high_cred]         DECIMAL (11, 2) NULL,
    [agcus_high_past_due]     DECIMAL (11, 2) NULL,
    [agcus_avg_days_pay]      SMALLINT        NULL,
    [agcus_avg_days_no_ivcs]  SMALLINT        NULL,
    [agcus_high_cred_rev_dt]  INT             NULL,
    [agcus_high_past_rev_dt]  INT             NULL,
    [agcus_dpa_cnt]           INT             NULL,
    [agcus_dpa_rev_dt]        INT             NULL,
    [agcus_cred_ga]           DECIMAL (11, 2) NULL,
    [agcus_gb_rcpt_no]        CHAR (6)        NULL,
    [agcus_ckoff_exempt_yn]   CHAR (1)        NULL,
    [agcus_ckoff_vol_yn]      CHAR (1)        NULL,
    [agcus_mkt_sign_yn]       CHAR (1)        NULL,
    [agcus_ga_origin_st]      CHAR (2)        NULL,
    [agcus_dflt_mkt_zone]     CHAR (3)        NULL,
    [agcus_active_yn]         CHAR (1)        NULL,
    [agcus_req_po_yn]         CHAR (1)        NULL,
    [agcus_bus_loc_no]        CHAR (3)        NULL,
    [agcus_mfg_cus_id]        CHAR (15)       NULL,
    [agcus_sst_exp_rev_dt]    INT             NULL,
    [agcus_lob1_slsmn]        CHAR (3)        NULL,
    [agcus_lob2_slsmn]        CHAR (3)        NULL,
    [agcus_lob3_slsmn]        CHAR (3)        NULL,
    [agcus_lob4_slsmn]        CHAR (3)        NULL,
    [agcus_lob5_slsmn]        CHAR (3)        NULL,
    [agcus_lob6_slsmn]        CHAR (3)        NULL,
    [agcus_lob7_slsmn]        CHAR (3)        NULL,
    [agcus_lob8_slsmn]        CHAR (3)        NULL,
    [agcus_lob9_slsmn]        CHAR (3)        NULL,
    [agcus_multi_currency_yn] CHAR (1)        NULL,
    [agcus_dflt_currency]     CHAR (3)        NULL,
    [agcus_1099_name]         CHAR (50)       NULL,
    [agcus_ga_hold_pay_yn]    CHAR (1)        NULL,
    [agcus_bad_addr_yn]       CHAR (1)        NULL,
    [agcus_ga_wthhld_yn]      CHAR (1)        NULL,
    [agcus_price_rule_set]    CHAR (2)        NULL,
    [agcus_user_id]           CHAR (16)       NULL,
    [agcus_user_rev_dt]       INT             NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agcusmst] PRIMARY KEY NONCLUSTERED ([agcus_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagcusmst0]
    ON [dbo].[agcusmst]([agcus_key] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagcusmst1]
    ON [dbo].[agcusmst]([agcus_last_name] ASC, [agcus_first_name] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagcusmst2]
    ON [dbo].[agcusmst]([agcus_phone] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_agcusmst_A4GLIdentity]
    ON [dbo].[agcusmst]([A4GLIdentity] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agcusmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agcusmst] TO PUBLIC
    AS [dbo];

