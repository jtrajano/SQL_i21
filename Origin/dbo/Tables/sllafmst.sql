﻿CREATE TABLE [dbo].[sllafmst] (
    [sllaf_type]             CHAR (3)    NOT NULL,
    [sllaf_type_desc]        CHAR (20)   NULL,
    [sllaf_field_desc_1]     CHAR (20)   NULL,
    [sllaf_field_desc_2]     CHAR (20)   NULL,
    [sllaf_field_desc_3]     CHAR (20)   NULL,
    [sllaf_field_desc_4]     CHAR (20)   NULL,
    [sllaf_field_desc_5]     CHAR (20)   NULL,
    [sllaf_field_desc_6]     CHAR (20)   NULL,
    [sllaf_field_desc_7]     CHAR (20)   NULL,
    [sllaf_field_desc_8]     CHAR (20)   NULL,
    [sllaf_field_desc_9]     CHAR (20)   NULL,
    [sllaf_field_desc_10]    CHAR (20)   NULL,
    [sllaf_field_desc_11]    CHAR (20)   NULL,
    [sllaf_field_desc_12]    CHAR (20)   NULL,
    [sllaf_field_desc_13]    CHAR (20)   NULL,
    [sllaf_field_desc_14]    CHAR (20)   NULL,
    [sllaf_field_desc_15]    CHAR (20)   NULL,
    [sllaf_active_yn_1]      CHAR (1)    NULL,
    [sllaf_active_yn_2]      CHAR (1)    NULL,
    [sllaf_active_yn_3]      CHAR (1)    NULL,
    [sllaf_active_yn_4]      CHAR (1)    NULL,
    [sllaf_active_yn_5]      CHAR (1)    NULL,
    [sllaf_active_yn_6]      CHAR (1)    NULL,
    [sllaf_active_yn_7]      CHAR (1)    NULL,
    [sllaf_active_yn_8]      CHAR (1)    NULL,
    [sllaf_active_yn_9]      CHAR (1)    NULL,
    [sllaf_active_yn_10]     CHAR (1)    NULL,
    [sllaf_active_yn_11]     CHAR (1)    NULL,
    [sllaf_active_yn_12]     CHAR (1)    NULL,
    [sllaf_active_yn_13]     CHAR (1)    NULL,
    [sllaf_active_yn_14]     CHAR (1)    NULL,
    [sllaf_active_yn_15]     CHAR (1)    NULL,
    [sllaf_alpha_num_ind_1]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_2]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_3]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_4]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_5]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_6]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_7]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_8]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_9]  CHAR (1)    NULL,
    [sllaf_alpha_num_ind_10] CHAR (1)    NULL,
    [sllaf_alpha_num_ind_11] CHAR (1)    NULL,
    [sllaf_alpha_num_ind_12] CHAR (1)    NULL,
    [sllaf_alpha_num_ind_13] CHAR (1)    NULL,
    [sllaf_alpha_num_ind_14] CHAR (1)    NULL,
    [sllaf_alpha_num_ind_15] CHAR (1)    NULL,
    [sllaf_max_1]            TINYINT     NULL,
    [sllaf_max_2]            TINYINT     NULL,
    [sllaf_max_3]            TINYINT     NULL,
    [sllaf_max_4]            TINYINT     NULL,
    [sllaf_max_5]            TINYINT     NULL,
    [sllaf_max_6]            TINYINT     NULL,
    [sllaf_max_7]            TINYINT     NULL,
    [sllaf_max_8]            TINYINT     NULL,
    [sllaf_max_9]            TINYINT     NULL,
    [sllaf_max_10]           TINYINT     NULL,
    [sllaf_max_11]           TINYINT     NULL,
    [sllaf_max_12]           TINYINT     NULL,
    [sllaf_max_13]           TINYINT     NULL,
    [sllaf_max_14]           TINYINT     NULL,
    [sllaf_max_15]           TINYINT     NULL,
    [sllaf_edit_1]           CHAR (4)    NULL,
    [sllaf_edit_2]           CHAR (4)    NULL,
    [sllaf_edit_3]           CHAR (4)    NULL,
    [sllaf_edit_4]           CHAR (4)    NULL,
    [sllaf_edit_5]           CHAR (4)    NULL,
    [sllaf_edit_6]           CHAR (4)    NULL,
    [sllaf_edit_7]           CHAR (4)    NULL,
    [sllaf_edit_8]           CHAR (4)    NULL,
    [sllaf_edit_9]           CHAR (4)    NULL,
    [sllaf_edit_10]          CHAR (4)    NULL,
    [sllaf_edit_11]          CHAR (4)    NULL,
    [sllaf_edit_12]          CHAR (4)    NULL,
    [sllaf_edit_13]          CHAR (4)    NULL,
    [sllaf_edit_14]          CHAR (4)    NULL,
    [sllaf_edit_15]          CHAR (4)    NULL,
    [sllaf_format_1]         CHAR (8)    NULL,
    [sllaf_format_2]         CHAR (8)    NULL,
    [sllaf_format_3]         CHAR (8)    NULL,
    [sllaf_format_4]         CHAR (8)    NULL,
    [sllaf_format_5]         CHAR (8)    NULL,
    [sllaf_format_6]         CHAR (8)    NULL,
    [sllaf_format_7]         CHAR (8)    NULL,
    [sllaf_format_8]         CHAR (8)    NULL,
    [sllaf_format_9]         CHAR (8)    NULL,
    [sllaf_format_10]        CHAR (8)    NULL,
    [sllaf_format_11]        CHAR (8)    NULL,
    [sllaf_format_12]        CHAR (8)    NULL,
    [sllaf_format_13]        CHAR (8)    NULL,
    [sllaf_format_14]        CHAR (8)    NULL,
    [sllaf_format_15]        CHAR (8)    NULL,
    [sllaf_user_id]          CHAR (16)   NULL,
    [sllaf_user_rev_dt]      INT         NULL,
    [A4GLIdentity]           NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sllafmst] PRIMARY KEY NONCLUSTERED ([sllaf_type] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isllafmst0]
    ON [dbo].[sllafmst]([sllaf_type] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[sllafmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sllafmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sllafmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sllafmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sllafmst] TO PUBLIC
    AS [dbo];

