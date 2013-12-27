﻿CREATE TABLE [dbo].[glctlmst] (
    [glctl_key]                 TINYINT     NOT NULL,
    [glctl_password]            CHAR (16)   NULL,
    [glctl_curr_yr]             SMALLINT    NULL,
    [glctl_curr_per]            TINYINT     NULL,
    [glctl_entry_yr]            SMALLINT    NULL,
    [glctl_entry_per]           TINYINT     NULL,
    [glctl_ret_earn_main]       INT         NULL,
    [glctl_ret_earn_sub]        INT         NULL,
    [glctl_bgt_type_1]          CHAR (1)    NULL,
    [glctl_bgt_type_2]          CHAR (1)    NULL,
    [glctl_bgt_type_3]          CHAR (1)    NULL,
    [glctl_bgt_type_4]          CHAR (1)    NULL,
    [glctl_bgt_type_5]          CHAR (1)    NULL,
    [glctl_bgt_type_6]          CHAR (1)    NULL,
    [glctl_bgt_desc_1]          CHAR (15)   NULL,
    [glctl_bgt_desc_2]          CHAR (15)   NULL,
    [glctl_bgt_desc_3]          CHAR (15)   NULL,
    [glctl_bgt_desc_4]          CHAR (15)   NULL,
    [glctl_bgt_desc_5]          CHAR (15)   NULL,
    [glctl_bgt_desc_6]          CHAR (15)   NULL,
    [glctl_curr_rpt_yr]         SMALLINT    NULL,
    [glctl_post_all_yn]         CHAR (1)    NULL,
    [glctl_reorg_lock_yn]       CHAR (1)    NULL,
    [glctl_reorg_lock_file]     CHAR (8)    NULL,
    [glctl_accounting_period]   TINYINT     NULL,
    [glctl_ret_earn_by_pc_yn]   CHAR (1)    NULL,
    [glctl_view_ret_earn_yn]    CHAR (1)    NULL,
    [glctl_allow_correcting_yn] CHAR (1)    NULL,
    [glctl_import_mult_co]      CHAR (1)    NULL,
    [glctl_next_jrnl_no]        SMALLINT    NULL,
    [glctl_user_fld_desc_1]     CHAR (12)   NULL,
    [glctl_user_fld_desc_2]     CHAR (12)   NULL,
    [glctl_budget_csv_filename] CHAR (50)   NULL,
    [glctl_trb_csv_filename]    CHAR (50)   NULL,
    [glctl_tran_table]          CHAR (3)    NULL,
    [glctl_csv_filename]        CHAR (50)   NULL,
    [glctl_csv_bud_export]      CHAR (50)   NULL,
    [glctl_csv_fsf_export]      CHAR (50)   NULL,
    [glctl_csv_mgn_export]      CHAR (50)   NULL,
    [glctl_user_id]             CHAR (16)   NULL,
    [glctl_user_rev_dt]         INT         NULL,
    [A4GLIdentity]              NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glctlmst] PRIMARY KEY NONCLUSTERED ([glctl_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iglctlmst0]
    ON [dbo].[glctlmst]([glctl_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[glctlmst] TO PUBLIC
    AS [dbo];

