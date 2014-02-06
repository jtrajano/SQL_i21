CREATE TABLE [dbo].[glmgnmst] (
    [glmgn_no]              SMALLINT    NOT NULL,
    [glmgn_line_no]         INT         NOT NULL,
    [glmgn_type_code]       CHAR (3)    NULL,
    [glmgn_type_crl]        CHAR (1)    NULL,
    [glmgn_title]           CHAR (50)   NULL,
    [glmgn_no_cols]         TINYINT     NULL,
    [glmgn_stmt_width]      SMALLINT    NULL,
    [glmgn_round_ndt]       CHAR (1)    NULL,
    [glmgn_whole_units_yn]  CHAR (1)    NULL,
    [glmgn_landscape_yn]    CHAR (1)    NULL,
    [glmgn_col_title1_1]    CHAR (17)   NULL,
    [glmgn_col_title1_2]    CHAR (17)   NULL,
    [glmgn_col_title1_3]    CHAR (17)   NULL,
    [glmgn_col_title1_4]    CHAR (17)   NULL,
    [glmgn_col_title1_5]    CHAR (17)   NULL,
    [glmgn_col_title1_6]    CHAR (17)   NULL,
    [glmgn_col_title1_7]    CHAR (17)   NULL,
    [glmgn_col_title1_8]    CHAR (17)   NULL,
    [glmgn_col_title1_9]    CHAR (17)   NULL,
    [glmgn_col_title1_10]   CHAR (17)   NULL,
    [glmgn_col_title1_11]   CHAR (17)   NULL,
    [glmgn_col_title1_12]   CHAR (17)   NULL,
    [glmgn_col_title2_1]    CHAR (17)   NULL,
    [glmgn_col_title2_2]    CHAR (17)   NULL,
    [glmgn_col_title2_3]    CHAR (17)   NULL,
    [glmgn_col_title2_4]    CHAR (17)   NULL,
    [glmgn_col_title2_5]    CHAR (17)   NULL,
    [glmgn_col_title2_6]    CHAR (17)   NULL,
    [glmgn_col_title2_7]    CHAR (17)   NULL,
    [glmgn_col_title2_8]    CHAR (17)   NULL,
    [glmgn_col_title2_9]    CHAR (17)   NULL,
    [glmgn_col_title2_10]   CHAR (17)   NULL,
    [glmgn_col_title2_11]   CHAR (17)   NULL,
    [glmgn_col_title2_12]   CHAR (17)   NULL,
    [glmgn_col_year_1]      TINYINT     NULL,
    [glmgn_col_year_2]      TINYINT     NULL,
    [glmgn_col_year_3]      TINYINT     NULL,
    [glmgn_col_year_4]      TINYINT     NULL,
    [glmgn_col_year_5]      TINYINT     NULL,
    [glmgn_col_year_6]      TINYINT     NULL,
    [glmgn_col_year_7]      TINYINT     NULL,
    [glmgn_col_year_8]      TINYINT     NULL,
    [glmgn_col_year_9]      TINYINT     NULL,
    [glmgn_col_year_10]     TINYINT     NULL,
    [glmgn_col_year_11]     TINYINT     NULL,
    [glmgn_col_year_12]     TINYINT     NULL,
    [glmgn_col_content_1]   CHAR (1)    NULL,
    [glmgn_col_content_2]   CHAR (1)    NULL,
    [glmgn_col_content_3]   CHAR (1)    NULL,
    [glmgn_col_content_4]   CHAR (1)    NULL,
    [glmgn_col_content_5]   CHAR (1)    NULL,
    [glmgn_col_content_6]   CHAR (1)    NULL,
    [glmgn_col_content_7]   CHAR (1)    NULL,
    [glmgn_col_content_8]   CHAR (1)    NULL,
    [glmgn_col_content_9]   CHAR (1)    NULL,
    [glmgn_col_content_10]  CHAR (1)    NULL,
    [glmgn_col_content_11]  CHAR (1)    NULL,
    [glmgn_col_content_12]  CHAR (1)    NULL,
    [glmgn_col_act_bud_1]   CHAR (1)    NULL,
    [glmgn_col_act_bud_2]   CHAR (1)    NULL,
    [glmgn_col_act_bud_3]   CHAR (1)    NULL,
    [glmgn_col_act_bud_4]   CHAR (1)    NULL,
    [glmgn_col_act_bud_5]   CHAR (1)    NULL,
    [glmgn_col_act_bud_6]   CHAR (1)    NULL,
    [glmgn_col_act_bud_7]   CHAR (1)    NULL,
    [glmgn_col_act_bud_8]   CHAR (1)    NULL,
    [glmgn_col_act_bud_9]   CHAR (1)    NULL,
    [glmgn_col_act_bud_10]  CHAR (1)    NULL,
    [glmgn_col_act_bud_11]  CHAR (1)    NULL,
    [glmgn_col_act_bud_12]  CHAR (1)    NULL,
    [glmgn_col_bud_type_1]  CHAR (1)    NULL,
    [glmgn_col_bud_type_2]  CHAR (1)    NULL,
    [glmgn_col_bud_type_3]  CHAR (1)    NULL,
    [glmgn_col_bud_type_4]  CHAR (1)    NULL,
    [glmgn_col_bud_type_5]  CHAR (1)    NULL,
    [glmgn_col_bud_type_6]  CHAR (1)    NULL,
    [glmgn_col_bud_type_7]  CHAR (1)    NULL,
    [glmgn_col_bud_type_8]  CHAR (1)    NULL,
    [glmgn_col_bud_type_9]  CHAR (1)    NULL,
    [glmgn_col_bud_type_10] CHAR (1)    NULL,
    [glmgn_col_bud_type_11] CHAR (1)    NULL,
    [glmgn_col_bud_type_12] CHAR (1)    NULL,
    [glmgn_grp1_beg_col]    TINYINT     NULL,
    [glmgn_grp1_end_col]    TINYINT     NULL,
    [glmgn_grp1_head_1]     CHAR (50)   NULL,
    [glmgn_grp1_head_2]     CHAR (50)   NULL,
    [glmgn_grp2_beg_col]    TINYINT     NULL,
    [glmgn_grp2_end_col]    TINYINT     NULL,
    [glmgn_grp2_head_1]     CHAR (50)   NULL,
    [glmgn_grp2_head_2]     CHAR (50)   NULL,
    [glmgn_hdr_description] CHAR (50)   NULL,
    [glmgn_ftr_description] CHAR (50)   NULL,
    [glmgn_dsc_description] CHAR (50)   NULL,
    [glmgn_dtl_desc]        CHAR (30)   NULL,
    [glmgn_dtl_accm_no]     TINYINT     NULL,
    [glmgn_dtl_dc]          CHAR (1)    NULL,
    [glmgn_dtl_dollarsign]  TINYINT     NULL,
    [glmgn_dtl_beg1_8_1]    INT         NULL,
    [glmgn_dtl_beg1_8_2]    INT         NULL,
    [glmgn_dtl_beg1_8_3]    INT         NULL,
    [glmgn_dtl_beg1_8_4]    INT         NULL,
    [glmgn_dtl_beg1_8_5]    INT         NULL,
    [glmgn_dtl_beg1_8_6]    INT         NULL,
    [glmgn_dtl_beg1_8_7]    INT         NULL,
    [glmgn_dtl_beg1_8_8]    INT         NULL,
    [glmgn_dtl_beg1_8_9]    INT         NULL,
    [glmgn_dtl_beg1_8_10]   INT         NULL,
    [glmgn_dtl_beg1_8_11]   INT         NULL,
    [glmgn_dtl_beg1_8_12]   INT         NULL,
    [glmgn_dtl_end1_8_1]    INT         NULL,
    [glmgn_dtl_end1_8_2]    INT         NULL,
    [glmgn_dtl_end1_8_3]    INT         NULL,
    [glmgn_dtl_end1_8_4]    INT         NULL,
    [glmgn_dtl_end1_8_5]    INT         NULL,
    [glmgn_dtl_end1_8_6]    INT         NULL,
    [glmgn_dtl_end1_8_7]    INT         NULL,
    [glmgn_dtl_end1_8_8]    INT         NULL,
    [glmgn_dtl_end1_8_9]    INT         NULL,
    [glmgn_dtl_end1_8_10]   INT         NULL,
    [glmgn_dtl_end1_8_11]   INT         NULL,
    [glmgn_dtl_end1_8_12]   INT         NULL,
    [glmgn_dtl_sub9_16_1]   INT         NULL,
    [glmgn_dtl_sub9_16_2]   INT         NULL,
    [glmgn_dtl_sub9_16_3]   INT         NULL,
    [glmgn_dtl_sub9_16_4]   INT         NULL,
    [glmgn_dtl_sub9_16_5]   INT         NULL,
    [glmgn_dtl_sub9_16_6]   INT         NULL,
    [glmgn_dtl_sub9_16_7]   INT         NULL,
    [glmgn_dtl_sub9_16_8]   INT         NULL,
    [glmgn_dtl_sub9_16_9]   INT         NULL,
    [glmgn_dtl_sub9_16_10]  INT         NULL,
    [glmgn_dtl_sub9_16_11]  INT         NULL,
    [glmgn_dtl_sub9_16_12]  INT         NULL,
    [glmgn_dtl_bea_1]       CHAR (1)    NULL,
    [glmgn_dtl_bea_2]       CHAR (1)    NULL,
    [glmgn_dtl_bea_3]       CHAR (1)    NULL,
    [glmgn_dtl_bea_4]       CHAR (1)    NULL,
    [glmgn_dtl_bea_5]       CHAR (1)    NULL,
    [glmgn_dtl_bea_6]       CHAR (1)    NULL,
    [glmgn_dtl_bea_7]       CHAR (1)    NULL,
    [glmgn_dtl_bea_8]       CHAR (1)    NULL,
    [glmgn_dtl_bea_9]       CHAR (1)    NULL,
    [glmgn_dtl_bea_10]      CHAR (1)    NULL,
    [glmgn_dtl_bea_11]      CHAR (1)    NULL,
    [glmgn_dtl_bea_12]      CHAR (1)    NULL,
    [glmgn_blnk_no_lines]   TINYINT     NULL,
    [glmgn_accm_no]         TINYINT     NULL,
    [glmgn_accm_on_off]     TINYINT     NULL,
    [glmgn_accm_dc]         CHAR (1)    NULL,
    [glmgn_tot_no]          TINYINT     NULL,
    [glmgn_tot_desc]        CHAR (30)   NULL,
    [glmgn_tot_accm_no]     TINYINT     NULL,
    [glmgn_tot_dc]          CHAR (1)    NULL,
    [glmgn_tot_dollarsign]  TINYINT     NULL,
    [glmgn_tot_force_units] TINYINT     NULL,
    [glmgn_clr_tot_no]      TINYINT     NULL,
    [glmgn_underline_type]  CHAR (1)    NULL,
    [glmgn_user_id]         CHAR (16)   NULL,
    [glmgn_user_rev_dt]     INT         NULL,
    [A4GLIdentity]          NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glmgnmst] PRIMARY KEY NONCLUSTERED ([glmgn_no] ASC, [glmgn_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglmgnmst0]
    ON [dbo].[glmgnmst]([glmgn_no] ASC, [glmgn_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[glmgnmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glmgnmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glmgnmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glmgnmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glmgnmst] TO PUBLIC
    AS [dbo];

