CREATE TABLE [dbo].[gastrmst] (
    [gastr_pur_sls_ind]     CHAR (1)        NOT NULL,
    [gastr_cus_no]          CHAR (10)       NOT NULL,
    [gastr_com_cd]          CHAR (3)        NOT NULL,
    [gastr_stor_type]       TINYINT         NOT NULL,
    [gastr_tic_no]          CHAR (10)       NOT NULL,
    [gastr_loc_no]          CHAR (3)        NOT NULL,
    [gastr_tie_breaker]     SMALLINT        NOT NULL,
    [gastr_spl_cus_no]      CHAR (10)       NULL,
    [gastr_spl_no]          CHAR (4)        NULL,
    [gastr_dlvry_rev_dt]    INT             NOT NULL,
    [gastr_stl_rev_dt]      INT             NULL,
    [gastr_un_bal]          DECIMAL (11, 3) NULL,
    [gastr_orig_un]         DECIMAL (11, 3) NULL,
    [gastr_bin_no]          CHAR (5)        NOT NULL,
    [gastr_stor_schd_no]    TINYINT         NULL,
    [gastr_un_disc_due]     DECIMAL (9, 6)  NULL,
    [gastr_un_disc_pd]      DECIMAL (9, 6)  NULL,
    [gastr_un_stor_due]     DECIMAL (9, 6)  NULL,
    [gastr_un_stor_pd]      DECIMAL (9, 6)  NULL,
    [gastr_un_ins_rt]       DECIMAL (7, 4)  NULL,
    [gastr_ins_state]       CHAR (2)        NULL,
    [gastr_origin_state]    CHAR (2)        NULL,
    [gastr_fees_due]        DECIMAL (7, 2)  NULL,
    [gastr_fees_pd]         DECIMAL (7, 2)  NULL,
    [gastr_un_frt_rt]       DECIMAL (9, 5)  NULL,
    [gastr_cus_ref_no]      CHAR (15)       NULL,
    [gastr_tic_comment]     CHAR (30)       NULL,
    [gastr_disc_schd_no]    TINYINT         NULL,
    [gastr_disc_cd_1]       CHAR (2)        NULL,
    [gastr_disc_cd_2]       CHAR (2)        NULL,
    [gastr_disc_cd_3]       CHAR (2)        NULL,
    [gastr_disc_cd_4]       CHAR (2)        NULL,
    [gastr_disc_cd_5]       CHAR (2)        NULL,
    [gastr_disc_cd_6]       CHAR (2)        NULL,
    [gastr_disc_cd_7]       CHAR (2)        NULL,
    [gastr_disc_cd_8]       CHAR (2)        NULL,
    [gastr_disc_cd_9]       CHAR (2)        NULL,
    [gastr_disc_cd_10]      CHAR (2)        NULL,
    [gastr_disc_cd_11]      CHAR (2)        NULL,
    [gastr_disc_cd_12]      CHAR (2)        NULL,
    [gastr_reading_1]       DECIMAL (7, 3)  NULL,
    [gastr_reading_2]       DECIMAL (7, 3)  NULL,
    [gastr_reading_3]       DECIMAL (7, 3)  NULL,
    [gastr_reading_4]       DECIMAL (7, 3)  NULL,
    [gastr_reading_5]       DECIMAL (7, 3)  NULL,
    [gastr_reading_6]       DECIMAL (7, 3)  NULL,
    [gastr_reading_7]       DECIMAL (7, 3)  NULL,
    [gastr_reading_8]       DECIMAL (7, 3)  NULL,
    [gastr_reading_9]       DECIMAL (7, 3)  NULL,
    [gastr_reading_10]      DECIMAL (7, 3)  NULL,
    [gastr_reading_11]      DECIMAL (7, 3)  NULL,
    [gastr_reading_12]      DECIMAL (7, 3)  NULL,
    [gastr_disc_calc_1]     CHAR (1)        NULL,
    [gastr_disc_calc_2]     CHAR (1)        NULL,
    [gastr_disc_calc_3]     CHAR (1)        NULL,
    [gastr_disc_calc_4]     CHAR (1)        NULL,
    [gastr_disc_calc_5]     CHAR (1)        NULL,
    [gastr_disc_calc_6]     CHAR (1)        NULL,
    [gastr_disc_calc_7]     CHAR (1)        NULL,
    [gastr_disc_calc_8]     CHAR (1)        NULL,
    [gastr_disc_calc_9]     CHAR (1)        NULL,
    [gastr_disc_calc_10]    CHAR (1)        NULL,
    [gastr_disc_calc_11]    CHAR (1)        NULL,
    [gastr_disc_calc_12]    CHAR (1)        NULL,
    [gastr_un_disc_amt_1]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_2]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_3]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_4]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_5]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_6]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_7]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_8]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_9]   DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_10]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_11]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_amt_12]  DECIMAL (9, 6)  NULL,
    [gastr_shrk_what_1]     CHAR (1)        NULL,
    [gastr_shrk_what_2]     CHAR (1)        NULL,
    [gastr_shrk_what_3]     CHAR (1)        NULL,
    [gastr_shrk_what_4]     CHAR (1)        NULL,
    [gastr_shrk_what_5]     CHAR (1)        NULL,
    [gastr_shrk_what_6]     CHAR (1)        NULL,
    [gastr_shrk_what_7]     CHAR (1)        NULL,
    [gastr_shrk_what_8]     CHAR (1)        NULL,
    [gastr_shrk_what_9]     CHAR (1)        NULL,
    [gastr_shrk_what_10]    CHAR (1)        NULL,
    [gastr_shrk_what_11]    CHAR (1)        NULL,
    [gastr_shrk_what_12]    CHAR (1)        NULL,
    [gastr_shrk_pct_1]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_2]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_3]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_4]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_5]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_6]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_7]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_8]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_9]      DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_10]     DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_11]     DECIMAL (7, 4)  NULL,
    [gastr_shrk_pct_12]     DECIMAL (7, 4)  NULL,
    [gastr_un_disc_bill_1]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_2]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_3]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_4]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_5]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_6]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_7]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_8]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_9]  DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_10] DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_11] DECIMAL (9, 6)  NULL,
    [gastr_un_disc_bill_12] DECIMAL (9, 6)  NULL,
    [gastr_tot_shrk_prc]    DECIMAL (5, 2)  NULL,
    [gastr_tot_shrk_wgt]    DECIMAL (7, 4)  NULL,
    [gastr_dpa_or_rcpt_no]  INT             NULL,
    [gastr_takeout_yn]      CHAR (1)        NULL,
    [gastr_currency]        CHAR (3)        NULL,
    [gastr_currency_rt]     DECIMAL (15, 8) NULL,
    [gastr_currency_cnt]    CHAR (8)        NULL,
    [gastr_cosr_printed]    CHAR (1)        NULL,
    [gastr_user_id]         CHAR (16)       NULL,
    [gastr_user_rev_dt]     INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gastrmst] PRIMARY KEY NONCLUSTERED ([gastr_pur_sls_ind] ASC, [gastr_cus_no] ASC, [gastr_com_cd] ASC, [gastr_stor_type] ASC, [gastr_tic_no] ASC, [gastr_loc_no] ASC, [gastr_tie_breaker] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igastrmst0]
    ON [dbo].[gastrmst]([gastr_pur_sls_ind] ASC, [gastr_cus_no] ASC, [gastr_com_cd] ASC, [gastr_stor_type] ASC, [gastr_tic_no] ASC, [gastr_loc_no] ASC, [gastr_tie_breaker] ASC);


GO
CREATE NONCLUSTERED INDEX [Igastrmst1]
    ON [dbo].[gastrmst]([gastr_tic_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igastrmst2]
    ON [dbo].[gastrmst]([gastr_loc_no] ASC, [gastr_com_cd] ASC, [gastr_bin_no] ASC, [gastr_dlvry_rev_dt] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gastrmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gastrmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gastrmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gastrmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gastrmst] TO PUBLIC
    AS [dbo];

