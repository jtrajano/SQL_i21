﻿CREATE TABLE [dbo].[gacommst] (
    [gacom_com_cd]               CHAR (3)        NOT NULL,
    [gacom_desc]                 CHAR (12)       NULL,
    [gacom_un_wgt]               DECIMAL (7, 3)  NULL,
    [gacom_cnsld_factor]         DECIMAL (7, 4)  NULL,
    [gacom_un_desc]              CHAR (3)        NULL,
    [gacom_un_min_prc]           DECIMAL (9, 5)  NULL,
    [gacom_un_max_prc]           DECIMAL (9, 5)  NULL,
    [gacom_dflt_bot]             CHAR (1)        NULL,
    [gacom_auto_dist_scale]      CHAR (1)        NULL,
    [gacom_allow_variety_yn]     CHAR (1)        NULL,
    [gacom_dpr_no_dec]           TINYINT         NULL,
    [gacom_crop_curr_rev_dt]     INT             NULL,
    [gacom_crop_new_rev_dt]      INT             NULL,
    [gacom_def_stor_schd_no]     TINYINT         NULL,
    [gacom_def_disc_schd_no]     TINYINT         NULL,
    [gacom_def_pur_text_no]      CHAR (2)        NULL,
    [gacom_def_sls_text_no]      CHAR (2)        NULL,
    [gacom_dflt_fees_lit]        CHAR (6)        NULL,
    [gacom_dflt_fees]            DECIMAL (7, 2)  NULL,
    [gacom_edi_cd]               CHAR (6)        NULL,
    [gacom_opt_1]                CHAR (3)        NULL,
    [gacom_opt_2]                CHAR (3)        NULL,
    [gacom_opt_3]                CHAR (3)        NULL,
    [gacom_opt_4]                CHAR (3)        NULL,
    [gacom_opt_5]                CHAR (3)        NULL,
    [gacom_opt_6]                CHAR (3)        NULL,
    [gacom_opt_7]                CHAR (3)        NULL,
    [gacom_opt_8]                CHAR (3)        NULL,
    [gacom_opt_9]                CHAR (3)        NULL,
    [gacom_opt_10]               CHAR (3)        NULL,
    [gacom_opt_11]               CHAR (3)        NULL,
    [gacom_opt_12]               CHAR (3)        NULL,
    [gacom_pat_cat]              CHAR (1)        NULL,
    [gacom_pat_cat_direct]       CHAR (1)        NULL,
    [gacom_fx_exposure_yn]       CHAR (1)        NULL,
    [gacom_cwb_inv_yn]           CHAR (1)        NULL,
    [gacom_load_at_udt_yn]       CHAR (1)        NULL,
    [gacom_ag_itm_no]            CHAR (13)       NULL,
    [gacom_disc_cd_1]            CHAR (2)        NULL,
    [gacom_disc_cd_2]            CHAR (2)        NULL,
    [gacom_disc_cd_3]            CHAR (2)        NULL,
    [gacom_disc_cd_4]            CHAR (2)        NULL,
    [gacom_disc_cd_5]            CHAR (2)        NULL,
    [gacom_disc_cd_6]            CHAR (2)        NULL,
    [gacom_disc_cd_7]            CHAR (2)        NULL,
    [gacom_disc_cd_8]            CHAR (2)        NULL,
    [gacom_disc_cd_9]            CHAR (2)        NULL,
    [gacom_gl_pur]               INT             NULL,
    [gacom_gl_dp_inc]            INT             NULL,
    [gacom_gl_strg_inc]          INT             NULL,
    [gacom_gl_strg_rcbl]         INT             NULL,
    [gacom_gl_frt_inc]           INT             NULL,
    [gacom_gl_int_inc]           INT             NULL,
    [gacom_gl_opt_inc]           INT             NULL,
    [gacom_gl_fees_inc]          INT             NULL,
    [gacom_gl_inv]               INT             NULL,
    [gacom_gl_beg_inv]           INT             NULL,
    [gacom_gl_end_inv]           INT             NULL,
    [gacom_gl_sls]               INT             NULL,
    [gacom_gl_strg_exp]          INT             NULL,
    [gacom_gl_broker]            INT             NULL,
    [gacom_gl_rail_frt]          INT             NULL,
    [gacom_gl_frt_exp]           INT             NULL,
    [gacom_gl_int_exp]           INT             NULL,
    [gacom_gl_opt_exp]           INT             NULL,
    [gacom_gl_fees_exp]          INT             NULL,
    [gacom_gl_dp_liab]           INT             NULL,
    [gacom_gl_disc_rcbl]         INT             NULL,
    [gacom_gl_cnt_eqty]          INT             NULL,
    [gacom_gl_cnt_pur_gain_loss] INT             NULL,
    [gacom_gl_cnt_sls_gain_loss] INT             NULL,
    [gacom_gl_cur_eqty]          INT             NULL,
    [gacom_gl_cur_pur_gain_loss] INT             NULL,
    [gacom_gl_cur_sls_gain_loss] INT             NULL,
    [gacom_wmp_whole]            DECIMAL (9, 5)  NULL,
    [gacom_wmp_broken]           DECIMAL (9, 5)  NULL,
    [gacom_loan_whole]           DECIMAL (9, 5)  NULL,
    [gacom_loan_broken]          DECIMAL (9, 5)  NULL,
    [gacom_std_whole_mill]       TINYINT         NULL,
    [gacom_std_total_mill]       TINYINT         NULL,
    [gacom_ckoff_desc]           CHAR (5)        NULL,
    [gacom_ckoff_all_st_ynvl]    CHAR (1)        NULL,
    [gacom_ins_desc]             CHAR (5)        NULL,
    [gacom_ins_all_st_yndc]      CHAR (1)        NULL,
    [gacom_oth_desc]             CHAR (5)        NULL,
    [gacom_oth_all_st_yndc]      CHAR (1)        NULL,
    [gacom_user_id]              CHAR (16)       NULL,
    [gacom_user_rev_dt]          INT             NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [gacom_allow_load_cnt_yn]    CHAR (1)        NULL,
    [gacom_load_cnt_over_un]     DECIMAL (11, 3) NULL,
    [gacom_load_cnt_under_un]    DECIMAL (11, 3) NULL,
    CONSTRAINT [k_gacommst] PRIMARY KEY NONCLUSTERED ([gacom_com_cd] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igacommst0]
    ON [dbo].[gacommst]([gacom_com_cd] ASC);

