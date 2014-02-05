﻿CREATE TABLE [dbo].[glfssmst] (
    [glfss_no]              SMALLINT    NOT NULL,
    [glfss_type]            CHAR (1)    NULL,
    [glfss_desc]            CHAR (30)   NULL,
    [glfss_round_ndt]       CHAR (1)    NULL,
    [glfss_col_desc_1_1]    CHAR (17)   NULL,
    [glfss_col_desc_1_2]    CHAR (17)   NULL,
    [glfss_col_desc_1_3]    CHAR (17)   NULL,
    [glfss_col_desc_1_4]    CHAR (17)   NULL,
    [glfss_col_desc_1_5]    CHAR (17)   NULL,
    [glfss_col_desc_1_6]    CHAR (17)   NULL,
    [glfss_col_desc_1_7]    CHAR (17)   NULL,
    [glfss_col_desc_1_8]    CHAR (17)   NULL,
    [glfss_col_desc_1_9]    CHAR (17)   NULL,
    [glfss_col_desc_1_10]   CHAR (17)   NULL,
    [glfss_col_desc_1_11]   CHAR (17)   NULL,
    [glfss_col_desc_1_12]   CHAR (17)   NULL,
    [glfss_col_desc_2_1]    CHAR (17)   NULL,
    [glfss_col_desc_2_2]    CHAR (17)   NULL,
    [glfss_col_desc_2_3]    CHAR (17)   NULL,
    [glfss_col_desc_2_4]    CHAR (17)   NULL,
    [glfss_col_desc_2_5]    CHAR (17)   NULL,
    [glfss_col_desc_2_6]    CHAR (17)   NULL,
    [glfss_col_desc_2_7]    CHAR (17)   NULL,
    [glfss_col_desc_2_8]    CHAR (17)   NULL,
    [glfss_col_desc_2_9]    CHAR (17)   NULL,
    [glfss_col_desc_2_10]   CHAR (17)   NULL,
    [glfss_col_desc_2_11]   CHAR (17)   NULL,
    [glfss_col_desc_2_12]   CHAR (17)   NULL,
    [glfss_col_year_1]      TINYINT     NULL,
    [glfss_col_year_2]      TINYINT     NULL,
    [glfss_col_year_3]      TINYINT     NULL,
    [glfss_col_year_4]      TINYINT     NULL,
    [glfss_col_year_5]      TINYINT     NULL,
    [glfss_col_year_6]      TINYINT     NULL,
    [glfss_col_year_7]      TINYINT     NULL,
    [glfss_col_year_8]      TINYINT     NULL,
    [glfss_col_year_9]      TINYINT     NULL,
    [glfss_col_year_10]     TINYINT     NULL,
    [glfss_col_year_11]     TINYINT     NULL,
    [glfss_col_year_12]     TINYINT     NULL,
    [glfss_col_content_1]   CHAR (1)    NULL,
    [glfss_col_content_2]   CHAR (1)    NULL,
    [glfss_col_content_3]   CHAR (1)    NULL,
    [glfss_col_content_4]   CHAR (1)    NULL,
    [glfss_col_content_5]   CHAR (1)    NULL,
    [glfss_col_content_6]   CHAR (1)    NULL,
    [glfss_col_content_7]   CHAR (1)    NULL,
    [glfss_col_content_8]   CHAR (1)    NULL,
    [glfss_col_content_9]   CHAR (1)    NULL,
    [glfss_col_content_10]  CHAR (1)    NULL,
    [glfss_col_content_11]  CHAR (1)    NULL,
    [glfss_col_content_12]  CHAR (1)    NULL,
    [glfss_col_act_bud_1]   CHAR (1)    NULL,
    [glfss_col_act_bud_2]   CHAR (1)    NULL,
    [glfss_col_act_bud_3]   CHAR (1)    NULL,
    [glfss_col_act_bud_4]   CHAR (1)    NULL,
    [glfss_col_act_bud_5]   CHAR (1)    NULL,
    [glfss_col_act_bud_6]   CHAR (1)    NULL,
    [glfss_col_act_bud_7]   CHAR (1)    NULL,
    [glfss_col_act_bud_8]   CHAR (1)    NULL,
    [glfss_col_act_bud_9]   CHAR (1)    NULL,
    [glfss_col_act_bud_10]  CHAR (1)    NULL,
    [glfss_col_act_bud_11]  CHAR (1)    NULL,
    [glfss_col_act_bud_12]  CHAR (1)    NULL,
    [glfss_col_bud_type_1]  CHAR (1)    NULL,
    [glfss_col_bud_type_2]  CHAR (1)    NULL,
    [glfss_col_bud_type_3]  CHAR (1)    NULL,
    [glfss_col_bud_type_4]  CHAR (1)    NULL,
    [glfss_col_bud_type_5]  CHAR (1)    NULL,
    [glfss_col_bud_type_6]  CHAR (1)    NULL,
    [glfss_col_bud_type_7]  CHAR (1)    NULL,
    [glfss_col_bud_type_8]  CHAR (1)    NULL,
    [glfss_col_bud_type_9]  CHAR (1)    NULL,
    [glfss_col_bud_type_10] CHAR (1)    NULL,
    [glfss_col_bud_type_11] CHAR (1)    NULL,
    [glfss_col_bud_type_12] CHAR (1)    NULL,
    [glfss_form_width]      SMALLINT    NULL,
    [glfss_landscape_yn]    CHAR (1)    NULL,
    [glfss_whole_units_yn]  CHAR (1)    NULL,
    [glfss_user_id]         CHAR (16)   NULL,
    [glfss_user_rev_dt]     INT         NULL,
    [A4GLIdentity]          NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glfssmst] PRIMARY KEY NONCLUSTERED ([glfss_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglfssmst0]
    ON [dbo].[glfssmst]([glfss_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[glfssmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glfssmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glfssmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glfssmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glfssmst] TO PUBLIC
    AS [dbo];

