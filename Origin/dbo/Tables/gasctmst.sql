﻿CREATE TABLE [dbo].[gasctmst] (
    [gasct_loc_no]              CHAR (3)        NOT NULL,
    [gasct_scale_id]            CHAR (1)        NOT NULL,
    [gasct_in_out_ind]          CHAR (1)        NOT NULL,
    [gasct_tic_no]              CHAR (10)       NOT NULL,
    [gasct_open_close_ind]      CHAR (1)        NOT NULL,
    [gasct_tic_type]            CHAR (1)        NULL,
    [gasct_orig_tic_type]       CHAR (1)        NULL,
    [gasct_void_yn]             CHAR (1)        NULL,
    [gasct_rev_dt]              INT             NULL,
    [gasct_weigher]             CHAR (12)       NULL,
    [gasct_truck_id]            CHAR (16)       NULL,
    [gasct_driver]              CHAR (12)       NULL,
    [gasct_driver_on_yn]        CHAR (1)        NULL,
    [gasct_gross_manual_yn]     CHAR (1)        NULL,
    [gasct_gross_wgt]           DECIMAL (13, 3) NULL,
    [gasct_gross_rev_dt]        INT             NULL,
    [gasct_gross_time]          INT             NULL,
    [gasct_gross_un]            DECIMAL (11, 3) NULL,
    [gasct_tare_manual_yn]      CHAR (1)        NULL,
    [gasct_tare_wgt]            DECIMAL (13, 3) NULL,
    [gasct_tare_rev_dt]         INT             NULL,
    [gasct_tare_time]           INT             NULL,
    [gasct_net_un]              DECIMAL (11, 3) NULL,
    [gasct_com_cd]              CHAR (3)        NULL,
    [gasct_cus_no]              CHAR (10)       NULL,
    [gasct_spl_no]              CHAR (4)        NULL,
    [gasct_fees]                DECIMAL (7, 2)  NULL,
    [gasct_dist_option]         CHAR (1)        NULL,
    [gasct_defer_rev_dt]        INT             NULL,
    [gasct_disc_schd_no]        TINYINT         NULL,
    [gasct_disc_cd_1]           CHAR (2)        NULL,
    [gasct_disc_cd_2]           CHAR (2)        NULL,
    [gasct_disc_cd_3]           CHAR (2)        NULL,
    [gasct_disc_cd_4]           CHAR (2)        NULL,
    [gasct_disc_cd_5]           CHAR (2)        NULL,
    [gasct_disc_cd_6]           CHAR (2)        NULL,
    [gasct_disc_cd_7]           CHAR (2)        NULL,
    [gasct_disc_cd_8]           CHAR (2)        NULL,
    [gasct_disc_cd_9]           CHAR (2)        NULL,
    [gasct_disc_cd_10]          CHAR (2)        NULL,
    [gasct_disc_cd_11]          CHAR (2)        NULL,
    [gasct_disc_cd_12]          CHAR (2)        NULL,
    [gasct_reading_1]           DECIMAL (7, 3)  NULL,
    [gasct_reading_2]           DECIMAL (7, 3)  NULL,
    [gasct_reading_3]           DECIMAL (7, 3)  NULL,
    [gasct_reading_4]           DECIMAL (7, 3)  NULL,
    [gasct_reading_5]           DECIMAL (7, 3)  NULL,
    [gasct_reading_6]           DECIMAL (7, 3)  NULL,
    [gasct_reading_7]           DECIMAL (7, 3)  NULL,
    [gasct_reading_8]           DECIMAL (7, 3)  NULL,
    [gasct_reading_9]           DECIMAL (7, 3)  NULL,
    [gasct_reading_10]          DECIMAL (7, 3)  NULL,
    [gasct_reading_11]          DECIMAL (7, 3)  NULL,
    [gasct_reading_12]          DECIMAL (7, 3)  NULL,
    [gasct_disc_calc_1]         CHAR (1)        NULL,
    [gasct_disc_calc_2]         CHAR (1)        NULL,
    [gasct_disc_calc_3]         CHAR (1)        NULL,
    [gasct_disc_calc_4]         CHAR (1)        NULL,
    [gasct_disc_calc_5]         CHAR (1)        NULL,
    [gasct_disc_calc_6]         CHAR (1)        NULL,
    [gasct_disc_calc_7]         CHAR (1)        NULL,
    [gasct_disc_calc_8]         CHAR (1)        NULL,
    [gasct_disc_calc_9]         CHAR (1)        NULL,
    [gasct_disc_calc_10]        CHAR (1)        NULL,
    [gasct_disc_calc_11]        CHAR (1)        NULL,
    [gasct_disc_calc_12]        CHAR (1)        NULL,
    [gasct_un_disc_amt_1]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_2]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_3]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_4]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_5]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_6]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_7]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_8]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_9]       DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_10]      DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_11]      DECIMAL (9, 6)  NULL,
    [gasct_un_disc_amt_12]      DECIMAL (9, 6)  NULL,
    [gasct_shrk_what_1]         CHAR (1)        NULL,
    [gasct_shrk_what_2]         CHAR (1)        NULL,
    [gasct_shrk_what_3]         CHAR (1)        NULL,
    [gasct_shrk_what_4]         CHAR (1)        NULL,
    [gasct_shrk_what_5]         CHAR (1)        NULL,
    [gasct_shrk_what_6]         CHAR (1)        NULL,
    [gasct_shrk_what_7]         CHAR (1)        NULL,
    [gasct_shrk_what_8]         CHAR (1)        NULL,
    [gasct_shrk_what_9]         CHAR (1)        NULL,
    [gasct_shrk_what_10]        CHAR (1)        NULL,
    [gasct_shrk_what_11]        CHAR (1)        NULL,
    [gasct_shrk_what_12]        CHAR (1)        NULL,
    [gasct_shrk_pct_1]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_2]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_3]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_4]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_5]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_6]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_7]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_8]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_9]          DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_10]         DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_11]         DECIMAL (7, 4)  NULL,
    [gasct_shrk_pct_12]         DECIMAL (7, 4)  NULL,
    [gasct_comment]             CHAR (60)       NULL,
    [gasct_times_printed]       SMALLINT        NULL,
    [gasct_spl_pct_1]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_2]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_3]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_4]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_5]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_6]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_7]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_8]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_9]           DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_10]          DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_11]          DECIMAL (7, 3)  NULL,
    [gasct_spl_pct_12]          DECIMAL (7, 3)  NULL,
    [gasct_spl_option_1]        CHAR (1)        NULL,
    [gasct_spl_option_2]        CHAR (1)        NULL,
    [gasct_spl_option_3]        CHAR (1)        NULL,
    [gasct_spl_option_4]        CHAR (1)        NULL,
    [gasct_spl_option_5]        CHAR (1)        NULL,
    [gasct_spl_option_6]        CHAR (1)        NULL,
    [gasct_spl_option_7]        CHAR (1)        NULL,
    [gasct_spl_option_8]        CHAR (1)        NULL,
    [gasct_spl_option_9]        CHAR (1)        NULL,
    [gasct_spl_option_10]       CHAR (1)        NULL,
    [gasct_spl_option_11]       CHAR (1)        NULL,
    [gasct_spl_option_12]       CHAR (1)        NULL,
    [gasct_plant_prt_ind]       CHAR (1)        NULL,
    [gasct_grade_prt_ind]       CHAR (1)        NULL,
    [gasct_tic_comment]         CHAR (30)       NULL,
    [gasct_un_prc]              DECIMAL (9, 5)  NULL,
    [gasct_trkr_no]             CHAR (10)       NULL,
    [gasct_trkr_un_rt]          DECIMAL (9, 5)  NULL,
    [gasct_cus_ref_no]          CHAR (15)       NULL,
    [gasct_frt_deduct_yn]       CHAR (1)        NULL,
    [gasct_split_wgt_yn]        CHAR (1)        NULL,
    [gasct_spl_gross_wgt1]      DECIMAL (13, 3) NULL,
    [gasct_spl_gross_wgt2]      DECIMAL (13, 3) NULL,
    [gasct_spl_tare_wgt1]       DECIMAL (13, 3) NULL,
    [gasct_spl_tare_wgt2]       DECIMAL (13, 3) NULL,
    [gasct_currency]            CHAR (3)        NULL,
    [gasct_currency_rt]         DECIMAL (15, 8) NULL,
    [gasct_currency_cnt]        CHAR (8)        NULL,
    [gasct_bin_no]              CHAR (5)        NULL,
    [gasct_zeelan_loc]          CHAR (3)        NULL,
    [gasct_zeelan_bin]          CHAR (2)        NULL,
    [gasct_cnt_no]              CHAR (8)        NULL,
    [gasct_cnt_seq]             SMALLINT        NULL,
    [gasct_cnt_sub]             SMALLINT        NULL,
    [gasct_cnt_loc]             CHAR (3)        NULL,
    [gasct_xfr_to_loc]          CHAR (3)        NULL,
    [gasct_itm_no]              CHAR (13)       NULL,
    [gasct_ivc_no]              CHAR (8)        NOT NULL,
    [gasct_load_loc_no]         CHAR (3)        NULL,
    [gasct_load_no]             CHAR (8)        NULL,
    [gasct_orig_gross_wgt]      DECIMAL (13, 3) NULL,
    [gasct_orig_tare_wgt]       DECIMAL (13, 3) NULL,
    [gasct_graph_tab_tic_hit]   CHAR (1)        NULL,
    [gasct_graph_tab_gra_hit]   CHAR (1)        NULL,
    [gasct_graph_tab_cus_hit]   CHAR (1)        NULL,
    [gasct_graph_tab_wgt_hit]   CHAR (1)        NULL,
    [gasct_graph_tab_oth_hit]   CHAR (1)        NULL,
    [gasct_graph_grades_hit_1]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_2]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_3]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_4]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_5]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_6]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_7]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_8]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_9]  CHAR (1)        NULL,
    [gasct_graph_grades_hit_10] CHAR (1)        NULL,
    [gasct_graph_grades_hit_11] CHAR (1)        NULL,
    [gasct_graph_grades_hit_12] CHAR (1)        NULL,
    [gasct_axel_no]             CHAR (1)        NULL,
    [gasct_void_dt]             INT             NULL,
    [gasct_user_id]             CHAR (16)       NULL,
    [gasct_user_rev_dt]         INT             NULL,
    [A4GLIdentity]              NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gasctmst] PRIMARY KEY NONCLUSTERED ([gasct_loc_no] ASC, [gasct_scale_id] ASC, [gasct_in_out_ind] ASC, [gasct_tic_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igasctmst0]
    ON [dbo].[gasctmst]([gasct_loc_no] ASC, [gasct_scale_id] ASC, [gasct_in_out_ind] ASC, [gasct_tic_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Igasctmst1]
    ON [dbo].[gasctmst]([gasct_open_close_ind] ASC, [gasct_loc_no] ASC, [gasct_scale_id] ASC, [gasct_in_out_ind] ASC, [gasct_tic_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igasctmst2]
    ON [dbo].[gasctmst]([gasct_ivc_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gasctmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gasctmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gasctmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gasctmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gasctmst] TO PUBLIC
    AS [dbo];

