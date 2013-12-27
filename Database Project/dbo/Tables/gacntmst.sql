CREATE TABLE [dbo].[gacntmst] (
    [gacnt_pur_sls_ind]      CHAR (1)        NOT NULL,
    [gacnt_cus_no]           CHAR (10)       NOT NULL,
    [gacnt_com_cd]           CHAR (3)        NOT NULL,
    [gacnt_loc_no]           CHAR (3)        NOT NULL,
    [gacnt_cnt_no]           CHAR (8)        NOT NULL,
    [gacnt_seq_no]           SMALLINT        NOT NULL,
    [gacnt_sub_seq_no]       SMALLINT        NOT NULL,
    [gacnt_cnt_rev_dt]       INT             NULL,
    [gacnt_cnt_time]         SMALLINT        NULL,
    [gacnt_beg_ship_rev_dt]  INT             NULL,
    [gacnt_due_rev_dt]       INT             NULL,
    [gacnt_defer_pmt_rev_dt] INT             NULL,
    [gacnt_trk_rail_ind]     CHAR (1)        NULL,
    [gacnt_pbhcu_ind]        CHAR (1)        NULL,
    [gacnt_no_un]            DECIMAL (11, 3) NULL,
    [gacnt_un_bal]           DECIMAL (11, 3) NULL,
    [gacnt_un_bal_unprc]     DECIMAL (11, 3) NULL,
    [gacnt_un_bal_transit]   DECIMAL (11, 3) NULL,
    [gacnt_sched_un]         DECIMAL (11, 3) NULL,
    [gacnt_dp_cnt_max_un]    DECIMAL (11, 3) NULL,
    [gacnt_un_bot_prc]       DECIMAL (9, 5)  NULL,
    [gacnt_bot]              CHAR (1)        NULL,
    [gacnt_bot_option]       CHAR (5)        NULL,
    [gacnt_un_bot_basis]     DECIMAL (9, 5)  NULL,
    [gacnt_un_frt_basis]     DECIMAL (9, 5)  NULL,
    [gacnt_as_is_disc]       DECIMAL (9, 5)  NULL,
    [gacnt_cnt_fee_un]       DECIMAL (9, 5)  NULL,
    [gacnt_roll_fee_un]      DECIMAL (9, 5)  NULL,
    [gacnt_un_cash_prc]      DECIMAL (9, 5)  NULL,
    [gacnt_cnt_fill_no]      CHAR (5)        NULL,
    [gacnt_mkt_zone]         CHAR (3)        NULL,
    [gacnt_option]           TINYINT         NULL,
    [gacnt_variety_cd]       CHAR (2)        NULL,
    [gacnt_last_cnt_seq_no]  SMALLINT        NULL,
    [gacnt_last_cnt_sub_no]  SMALLINT        NULL,
    [gacnt_last_hst_seq_no]  INT             NULL,
    [gacnt_int_rt]           DECIMAL (7, 4)  NULL,
    [gacnt_carry_per_day]    DECIMAL (9, 6)  NULL,
    [gacnt_disc_dca_ind]     CHAR (1)        NULL,
    [gacnt_disc_schd_no]     TINYINT         NULL,
    [gacnt_stor_schd_no]     TINYINT         NULL,
    [gacnt_text_no]          CHAR (2)        NULL,
    [gacnt_signed_yn]        CHAR (1)        NULL,
    [gacnt_printed_yn]       CHAR (1)        NULL,
    [gacnt_printed_lbl_yn]   CHAR (1)        NULL,
    [gacnt_buyer]            CHAR (15)       NULL,
    [gacnt_seller]           CHAR (15)       NULL,
    [gacnt_comments]         CHAR (15)       NULL,
    [gacnt_cus_cnt_no]       CHAR (10)       NULL,
    [gacnt_remarks_1]        CHAR (40)       NULL,
    [gacnt_remarks_2]        CHAR (40)       NULL,
    [gacnt_remarks_3]        CHAR (40)       NULL,
    [gacnt_remarks_4]        CHAR (40)       NULL,
    [gacnt_remarks_5]        CHAR (40)       NULL,
    [gacnt_remarks_6]        CHAR (40)       NULL,
    [gacnt_remarks_7]        CHAR (40)       NULL,
    [gacnt_remarks_8]        CHAR (40)       NULL,
    [gacnt_remarks_9]        CHAR (40)       NULL,
    [gacnt_loads_cnt_yn]     CHAR (1)        NULL,
    [gacnt_un_per_load]      DECIMAL (11, 3) NULL,
    [gacnt_orig_no_loads]    INT             NULL,
    [gacnt_applied_no_loads] INT             NULL,
    [gacnt_frt_trk_rt]       DECIMAL (9, 5)  NULL,
    [gacnt_avg_car_grade]    CHAR (1)        NULL,
    [gacnt_bill_to_cus]      CHAR (10)       NULL,
    [gacnt_broker_no]        CHAR (10)       NULL,
    [gacnt_brk_posted_yn]    CHAR (1)        NULL,
    [gacnt_broker_un_rt]     DECIMAL (9, 5)  NULL,
    [gacnt_broker_gl_acct]   DECIMAL (16, 8) NULL,
    [gacnt_origin]           CHAR (20)       NULL,
    [gacnt_destination]      CHAR (20)       NULL,
    [gacnt_grade_cd]         CHAR (1)        NULL,
    [gacnt_weight_cd]        CHAR (1)        NULL,
    [gacnt_fob_prc_basis]    CHAR (13)       NULL,
    [gacnt_frt_cus_1]        CHAR (10)       NULL,
    [gacnt_frt_cus_2]        CHAR (10)       NULL,
    [gacnt_frt_cus_3]        CHAR (10)       NULL,
    [gacnt_frt_type_1]       CHAR (1)        NULL,
    [gacnt_frt_type_2]       CHAR (1)        NULL,
    [gacnt_frt_type_3]       CHAR (1)        NULL,
    [gacnt_frt_rail_rt_1]    DECIMAL (11, 6) NULL,
    [gacnt_frt_rail_rt_2]    DECIMAL (11, 6) NULL,
    [gacnt_frt_rail_rt_3]    DECIMAL (11, 6) NULL,
    [gacnt_frt_gl_acct_1]    DECIMAL (16, 8) NULL,
    [gacnt_frt_gl_acct_2]    DECIMAL (16, 8) NULL,
    [gacnt_frt_gl_acct_3]    DECIMAL (16, 8) NULL,
    [gacnt_frt_currency]     CHAR (3)        NULL,
    [gacnt_frt_currency_rt]  DECIMAL (15, 8) NULL,
    [gacnt_frt_currency_cnt] CHAR (8)        NULL,
    [gacnt_currency]         CHAR (3)        NULL,
    [gacnt_currency_rt]      DECIMAL (15, 8) NULL,
    [gacnt_currency_cnt]     CHAR (8)        NULL,
    [gacnt_wmp_whole]        DECIMAL (9, 5)  NULL,
    [gacnt_wmp_broken]       DECIMAL (9, 5)  NULL,
    [gacnt_loan_whole]       DECIMAL (9, 5)  NULL,
    [gacnt_loan_broken]      DECIMAL (9, 5)  NULL,
    [gacnt_orig_no_un]       DECIMAL (11, 3) NULL,
    [gacnt_orig_un_basis]    DECIMAL (9, 5)  NULL,
    [gacnt_orig_bot_un_prc]  DECIMAL (9, 5)  NULL,
    [gacnt_orig_bot_option]  CHAR (5)        NULL,
    [gacnt_eom_no_un]        DECIMAL (11, 3) NULL,
    [gacnt_eom_un_basis]     DECIMAL (9, 5)  NULL,
    [gacnt_eom_bot_un_prc]   DECIMAL (9, 5)  NULL,
    [gacnt_eom_bot_option]   CHAR (5)        NULL,
    [gacnt_prv_no_un]        DECIMAL (11, 3) NULL,
    [gacnt_prv_un_basis]     DECIMAL (9, 5)  NULL,
    [gacnt_prv_bot_un_prc]   DECIMAL (9, 5)  NULL,
    [gacnt_prv_bot_option]   CHAR (5)        NULL,
    [gacnt_user_id]          CHAR (16)       NULL,
    [gacnt_user_rev_dt]      INT             NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gacntmst] PRIMARY KEY NONCLUSTERED ([gacnt_pur_sls_ind] ASC, [gacnt_cus_no] ASC, [gacnt_com_cd] ASC, [gacnt_loc_no] ASC, [gacnt_cnt_no] ASC, [gacnt_seq_no] ASC, [gacnt_sub_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igacntmst0]
    ON [dbo].[gacntmst]([gacnt_pur_sls_ind] ASC, [gacnt_cus_no] ASC, [gacnt_com_cd] ASC, [gacnt_loc_no] ASC, [gacnt_cnt_no] ASC, [gacnt_seq_no] ASC, [gacnt_sub_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igacntmst1]
    ON [dbo].[gacntmst]([gacnt_cnt_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gacntmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gacntmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gacntmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gacntmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gacntmst] TO PUBLIC
    AS [dbo];

