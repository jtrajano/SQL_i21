CREATE TABLE [dbo].[gastlmst] (
    [gastl_pur_sls_ind]      CHAR (1)        NOT NULL,
    [gastl_cus_no]           CHAR (10)       NOT NULL,
    [gastl_com_cd]           CHAR (3)        NOT NULL,
    [gastl_tic_no]           CHAR (10)       NOT NULL,
    [gastl_rec_type]         CHAR (1)        NOT NULL,
    [gastl_tie_breaker]      SMALLINT        NOT NULL,
    [gastl_seq_no]           SMALLINT        NOT NULL,
    [gastl_hst_type]         CHAR (1)        NULL,
    [gastl_loc_no]           CHAR (3)        NOT NULL,
    [gastl_spl_cus_no]       CHAR (10)       NULL,
    [gastl_spl_no]           CHAR (4)        NULL,
    [gastl_stl_amt]          DECIMAL (11, 2) NULL,
    [gastl_wthhld_amt]       DECIMAL (11, 2) NULL,
    [gastl_stl_rev_dt]       INT             NULL,
    [gastl_defer_pmt_rev_dt] INT             NULL,
    [gastl_defer_pmt_cnt_no] CHAR (8)        NULL,
    [gastl_pd_yn]            CHAR (1)        NULL,
    [gastl_man_auto_ind]     CHAR (1)        NULL,
    [gastl_chk_no]           CHAR (8)        NULL,
    [gastl_pmt_rev_dt]       INT             NULL,
    [gastl_pmt_audit_no]     CHAR (4)        NULL,
    [gastl_ivc_printed_yn]   CHAR (1)        NULL,
    [gastl_ivc_no]           CHAR (8)        NULL,
    [gastl_ivc_rev_dt]       INT             NULL,
    [gastl_audit_no]         CHAR (4)        NULL,
    [gastl_cus_ref_no]       CHAR (15)       NULL,
    [gastl_orig_type]        CHAR (1)        NULL,
    [gastl_rail_ref_no]      INT             NULL,
    [gastl_no_un]            DECIMAL (11, 3) NULL,
    [gastl_un_prc]           DECIMAL (9, 5)  NULL,
    [gastl_un_disc_adj]      DECIMAL (9, 6)  NULL,
    [gastl_un_disc_pd]       DECIMAL (9, 6)  NULL,
    [gastl_un_stor_pd]       DECIMAL (9, 6)  NULL,
    [gastl_ckoff_amt]        DECIMAL (7, 2)  NULL,
    [gastl_origin_state]     CHAR (2)        NULL,
    [gastl_ins_amt]          DECIMAL (7, 2)  NULL,
    [gastl_ins_state]        CHAR (2)        NULL,
    [gastl_tax3_amt]         DECIMAL (7, 2)  NULL,
    [gastl_tax3_state]       CHAR (2)        NULL,
    [gastl_fees_pd]          DECIMAL (7, 2)  NULL,
    [gastl_un_frt_rt]        DECIMAL (9, 5)  NULL,
    [gastl_un_cnt_fee]       DECIMAL (9, 5)  NULL,
    [gastl_un_roll_fee]      DECIMAL (9, 5)  NULL,
    [gastl_un_bot_basis]     DECIMAL (9, 5)  NULL,
    [gastl_bot]              CHAR (1)        NULL,
    [gastl_bot_option]       CHAR (5)        NULL,
    [gastl_tot_shrk_pct_wgt] DECIMAL (7, 4)  NULL,
    [gastl_disc_schd_no]     TINYINT         NULL,
    [gastl_disc_cd_1]        CHAR (2)        NULL,
    [gastl_disc_cd_2]        CHAR (2)        NULL,
    [gastl_disc_cd_3]        CHAR (2)        NULL,
    [gastl_disc_cd_4]        CHAR (2)        NULL,
    [gastl_disc_cd_5]        CHAR (2)        NULL,
    [gastl_disc_cd_6]        CHAR (2)        NULL,
    [gastl_disc_cd_7]        CHAR (2)        NULL,
    [gastl_disc_cd_8]        CHAR (2)        NULL,
    [gastl_disc_cd_9]        CHAR (2)        NULL,
    [gastl_disc_cd_10]       CHAR (2)        NULL,
    [gastl_disc_cd_11]       CHAR (2)        NULL,
    [gastl_disc_cd_12]       CHAR (2)        NULL,
    [gastl_reading_1]        DECIMAL (7, 3)  NULL,
    [gastl_reading_2]        DECIMAL (7, 3)  NULL,
    [gastl_reading_3]        DECIMAL (7, 3)  NULL,
    [gastl_reading_4]        DECIMAL (7, 3)  NULL,
    [gastl_reading_5]        DECIMAL (7, 3)  NULL,
    [gastl_reading_6]        DECIMAL (7, 3)  NULL,
    [gastl_reading_7]        DECIMAL (7, 3)  NULL,
    [gastl_reading_8]        DECIMAL (7, 3)  NULL,
    [gastl_reading_9]        DECIMAL (7, 3)  NULL,
    [gastl_reading_10]       DECIMAL (7, 3)  NULL,
    [gastl_reading_11]       DECIMAL (7, 3)  NULL,
    [gastl_reading_12]       DECIMAL (7, 3)  NULL,
    [gastl_disc_calc_1]      CHAR (1)        NULL,
    [gastl_disc_calc_2]      CHAR (1)        NULL,
    [gastl_disc_calc_3]      CHAR (1)        NULL,
    [gastl_disc_calc_4]      CHAR (1)        NULL,
    [gastl_disc_calc_5]      CHAR (1)        NULL,
    [gastl_disc_calc_6]      CHAR (1)        NULL,
    [gastl_disc_calc_7]      CHAR (1)        NULL,
    [gastl_disc_calc_8]      CHAR (1)        NULL,
    [gastl_disc_calc_9]      CHAR (1)        NULL,
    [gastl_disc_calc_10]     CHAR (1)        NULL,
    [gastl_disc_calc_11]     CHAR (1)        NULL,
    [gastl_disc_calc_12]     CHAR (1)        NULL,
    [gastl_un_disc_amt_1]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_2]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_3]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_4]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_5]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_6]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_7]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_8]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_9]    DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_10]   DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_11]   DECIMAL (9, 6)  NULL,
    [gastl_un_disc_amt_12]   DECIMAL (9, 6)  NULL,
    [gastl_shrk_what_1]      CHAR (1)        NULL,
    [gastl_shrk_what_2]      CHAR (1)        NULL,
    [gastl_shrk_what_3]      CHAR (1)        NULL,
    [gastl_shrk_what_4]      CHAR (1)        NULL,
    [gastl_shrk_what_5]      CHAR (1)        NULL,
    [gastl_shrk_what_6]      CHAR (1)        NULL,
    [gastl_shrk_what_7]      CHAR (1)        NULL,
    [gastl_shrk_what_8]      CHAR (1)        NULL,
    [gastl_shrk_what_9]      CHAR (1)        NULL,
    [gastl_shrk_what_10]     CHAR (1)        NULL,
    [gastl_shrk_what_11]     CHAR (1)        NULL,
    [gastl_shrk_what_12]     CHAR (1)        NULL,
    [gastl_shrk_pct_1]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_2]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_3]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_4]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_5]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_6]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_7]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_8]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_9]       DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_10]      DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_11]      DECIMAL (7, 4)  NULL,
    [gastl_shrk_pct_12]      DECIMAL (7, 4)  NULL,
    [gastl_tic_comment]      CHAR (30)       NULL,
    [gastl_dlvry_rev_dt]     INT             NOT NULL,
    [gastl_stor_schd_no]     TINYINT         NULL,
    [gastl_stor_tie_breaker] SMALLINT        NULL,
    [gastl_cnt_no]           CHAR (8)        NULL,
    [gastl_cnt_seq_no]       SMALLINT        NULL,
    [gastl_cnt_sub_no]       SMALLINT        NULL,
    [gastl_cnt_loc_wrtn]     CHAR (3)        NULL,
    [gastl_advanced_yn]      CHAR (1)        NULL,
    [gastl_as_is_disc]       DECIMAL (9, 5)  NULL,
    [gastl_gl_acct_no]       DECIMAL (16, 8) NULL,
    [gastl_frt_un]           DECIMAL (11, 3) NULL,
    [gastl_frt_rt]           DECIMAL (9, 5)  NULL,
    [gastl_adv_man_auto_ind] CHAR (1)        NULL,
    [gastl_adv_chk_no]       INT             NULL,
    [gastl_adv_reg_bas_ind]  CHAR (1)        NULL,
    [gastl_adj_ckoff_amt]    DECIMAL (7, 2)  NULL,
    [gastl_adj_ins_amt]      DECIMAL (7, 2)  NULL,
    [gastl_adj_tax3_amt]     DECIMAL (7, 2)  NULL,
    [gastl_adv_cnt_no]       CHAR (8)        NULL,
    [gastl_adv_to_cus_no]    CHAR (10)       NULL,
    [gastl_adv_cnt_loc]      CHAR (3)        NULL,
    [gastl_adj_csh_rcpt_yn]  CHAR (1)        NULL,
    [gastl_adv_audit_no]     CHAR (4)        NULL,
    [gastl_adv_tic_tie]      CHAR (3)        NULL,
    [gastl_adj_pay_pat_yn]   CHAR (1)        NULL,
    [gastl_rice_factor]      CHAR (1)        NULL,
    [gastl_wmp_whole]        DECIMAL (9, 5)  NULL,
    [gastl_wmp_broken]       DECIMAL (9, 5)  NULL,
    [gastl_loan_whole]       DECIMAL (9, 5)  NULL,
    [gastl_loan_broken]      DECIMAL (9, 5)  NULL,
    [gastl_currency]         CHAR (3)        NULL,
    [gastl_currency_rt]      DECIMAL (15, 8) NULL,
    [gastl_currency_cnt]     CHAR (8)        NULL,
    [gastl_cash_curr_rt]     DECIMAL (15, 8) NULL,
    [gastl_user_id]          CHAR (16)       NULL,
    [gastl_user_rev_dt]      CHAR (8)        NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gastlmst] PRIMARY KEY NONCLUSTERED ([gastl_pur_sls_ind] ASC, [gastl_cus_no] ASC, [gastl_com_cd] ASC, [gastl_tic_no] ASC, [gastl_rec_type] ASC, [gastl_tie_breaker] ASC, [gastl_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igastlmst0]
    ON [dbo].[gastlmst]([gastl_pur_sls_ind] ASC, [gastl_cus_no] ASC, [gastl_com_cd] ASC, [gastl_tic_no] ASC, [gastl_rec_type] ASC, [gastl_tie_breaker] ASC, [gastl_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igastlmst1]
    ON [dbo].[gastlmst]([gastl_tic_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igastlmst2]
    ON [dbo].[gastlmst]([gastl_loc_no] ASC, [gastl_com_cd] ASC, [gastl_dlvry_rev_dt] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gastlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gastlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gastlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gastlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gastlmst] TO PUBLIC
    AS [dbo];

