﻿CREATE TABLE [dbo].[gaitrmst] (
    [gaitr_pur_sls_ind]    CHAR (1)        NOT NULL,
    [gaitr_loc_no]         CHAR (3)        NOT NULL,
    [gaitr_cus_no]         CHAR (10)       NOT NULL,
    [gaitr_com_cd]         CHAR (3)        NOT NULL,
    [gaitr_tic_no]         CHAR (10)       NOT NULL,
    [gaitr_ship_rev_dt]    INT             NOT NULL,
    [gaitr_rail_ref_no]    INT             NOT NULL,
    [gaitr_load_seq]       SMALLINT        NOT NULL,
    [gaitr_gross_wgt]      DECIMAL (13, 3) NULL,
    [gaitr_tare_wgt]       DECIMAL (13, 3) NULL,
    [gaitr_comment]        CHAR (30)       NULL,
    [gaitr_how_ship_ind]   CHAR (1)        NULL,
    [gaitr_trkr_no]        CHAR (10)       NULL,
    [gaitr_trkr_un_rt]     DECIMAL (9, 5)  NULL,
    [gaitr_cnt_no]         CHAR (8)        NULL,
    [gaitr_cnt_seq_no]     SMALLINT        NULL,
    [gaitr_cnt_sub_seq_no] SMALLINT        NULL,
    [gaitr_cnt_loc_no]     CHAR (3)        NULL,
    [gaitr_un_out]         DECIMAL (13, 3) NULL,
    [gaitr_process_tic_no] CHAR (15)       NOT NULL,
    [gaitr_rdg_yn]         CHAR (1)        NULL,
    [gaitr_disc_cd_1]      CHAR (2)        NULL,
    [gaitr_disc_cd_2]      CHAR (2)        NULL,
    [gaitr_disc_cd_3]      CHAR (2)        NULL,
    [gaitr_disc_cd_4]      CHAR (2)        NULL,
    [gaitr_disc_cd_5]      CHAR (2)        NULL,
    [gaitr_disc_cd_6]      CHAR (2)        NULL,
    [gaitr_disc_cd_7]      CHAR (2)        NULL,
    [gaitr_disc_cd_8]      CHAR (2)        NULL,
    [gaitr_disc_cd_9]      CHAR (2)        NULL,
    [gaitr_disc_cd_10]     CHAR (2)        NULL,
    [gaitr_disc_cd_11]     CHAR (2)        NULL,
    [gaitr_disc_cd_12]     CHAR (2)        NULL,
    [gaitr_reading_1]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_2]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_3]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_4]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_5]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_6]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_7]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_8]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_9]      DECIMAL (7, 3)  NULL,
    [gaitr_reading_10]     DECIMAL (7, 3)  NULL,
    [gaitr_reading_11]     DECIMAL (7, 3)  NULL,
    [gaitr_reading_12]     DECIMAL (7, 3)  NULL,
    [gaitr_disc_calc_1]    CHAR (1)        NULL,
    [gaitr_disc_calc_2]    CHAR (1)        NULL,
    [gaitr_disc_calc_3]    CHAR (1)        NULL,
    [gaitr_disc_calc_4]    CHAR (1)        NULL,
    [gaitr_disc_calc_5]    CHAR (1)        NULL,
    [gaitr_disc_calc_6]    CHAR (1)        NULL,
    [gaitr_disc_calc_7]    CHAR (1)        NULL,
    [gaitr_disc_calc_8]    CHAR (1)        NULL,
    [gaitr_disc_calc_9]    CHAR (1)        NULL,
    [gaitr_disc_calc_10]   CHAR (1)        NULL,
    [gaitr_disc_calc_11]   CHAR (1)        NULL,
    [gaitr_disc_calc_12]   CHAR (1)        NULL,
    [gaitr_un_disc_amt_1]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_2]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_3]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_4]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_5]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_6]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_7]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_8]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_9]  DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_10] DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_11] DECIMAL (9, 6)  NULL,
    [gaitr_un_disc_amt_12] DECIMAL (9, 6)  NULL,
    [gaitr_shrk_what_1]    CHAR (1)        NULL,
    [gaitr_shrk_what_2]    CHAR (1)        NULL,
    [gaitr_shrk_what_3]    CHAR (1)        NULL,
    [gaitr_shrk_what_4]    CHAR (1)        NULL,
    [gaitr_shrk_what_5]    CHAR (1)        NULL,
    [gaitr_shrk_what_6]    CHAR (1)        NULL,
    [gaitr_shrk_what_7]    CHAR (1)        NULL,
    [gaitr_shrk_what_8]    CHAR (1)        NULL,
    [gaitr_shrk_what_9]    CHAR (1)        NULL,
    [gaitr_shrk_what_10]   CHAR (1)        NULL,
    [gaitr_shrk_what_11]   CHAR (1)        NULL,
    [gaitr_shrk_what_12]   CHAR (1)        NULL,
    [gaitr_shrk_pct_1]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_2]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_3]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_4]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_5]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_6]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_7]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_8]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_9]     DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_10]    DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_11]    DECIMAL (7, 4)  NULL,
    [gaitr_shrk_pct_12]    DECIMAL (7, 4)  NULL,
    [gaitr_fees_pd]        DECIMAL (7, 2)  NULL,
    [gaitr_trkr_wgt]       DECIMAL (13, 3) NULL,
    [gaitr_disc_schd_no]   TINYINT         NULL,
    [gaitr_rail_entry_yn]  CHAR (1)        NULL,
    [gaitr_direct_rail_yn] CHAR (1)        NULL,
    [gaitr_pbhcu_ind]      CHAR (1)        NULL,
    [gaitr_bin_no]         CHAR (5)        NULL,
    [gaitr_schd_load_yn]   CHAR (1)        NULL,
    [gaitr_rail_split_seq] CHAR (2)        NULL,
    [gaitr_origin_state]   CHAR (2)        NULL,
    [gaitr_dest_state]     CHAR (2)        NULL,
    [gaitr_user_id]        CHAR (16)       NULL,
    [gaitr_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaitrmst] PRIMARY KEY NONCLUSTERED ([gaitr_pur_sls_ind] ASC, [gaitr_loc_no] ASC, [gaitr_cus_no] ASC, [gaitr_com_cd] ASC, [gaitr_tic_no] ASC, [gaitr_ship_rev_dt] ASC, [gaitr_rail_ref_no] ASC, [gaitr_load_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igaitrmst0]
    ON [dbo].[gaitrmst]([gaitr_pur_sls_ind] ASC, [gaitr_loc_no] ASC, [gaitr_cus_no] ASC, [gaitr_com_cd] ASC, [gaitr_tic_no] ASC, [gaitr_ship_rev_dt] ASC, [gaitr_rail_ref_no] ASC, [gaitr_load_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Igaitrmst1]
    ON [dbo].[gaitrmst]([gaitr_process_tic_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaitrmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaitrmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaitrmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaitrmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaitrmst] TO PUBLIC
    AS [dbo];

