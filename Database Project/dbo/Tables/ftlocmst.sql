CREATE TABLE [dbo].[ftlocmst] (
    [ftloc_no]                  CHAR (3)       NOT NULL,
    [ftloc_comment]             CHAR (30)      NULL,
    [ftloc_name]                CHAR (30)      NULL,
    [ftloc_phone_no]            CHAR (15)      NULL,
    [ftloc_worksheet_printer]   CHAR (80)      NULL,
    [ftloc_field_map_dir]       CHAR (60)      NULL,
    [ftloc_deflt_mixer_9]       TINYINT        NULL,
    [ftloc_round_up_scale_yn]   CHAR (1)       NULL,
    [ftloc_round_scale_lbs]     SMALLINT       NULL,
    [ftloc_deflt_batch_no]      SMALLINT       NULL,
    [ftloc_equal_batches_yn]    CHAR (1)       NULL,
    [ftloc_mg_pct]              DECIMAL (3, 1) NULL,
    [ftloc_b_pct]               DECIMAL (3, 1) NULL,
    [ftloc_mn_pct]              DECIMAL (3, 1) NULL,
    [ftloc_zn_pct]              DECIMAL (3, 1) NULL,
    [ftloc_s_pct]               DECIMAL (3, 1) NULL,
    [ftloc_fe_pct]              DECIMAL (3, 1) NULL,
    [ftloc_cu_pct]              DECIMAL (3, 1) NULL,
    [ftloc_ca_pct]              DECIMAL (3, 1) NULL,
    [ftloc_lime_pct]            DECIMAL (3, 1) NULL,
    [ftloc_next_guide_id]       BIGINT         NULL,
    [ftloc_enter_spray_yno]     CHAR (1)       NULL,
    [ftloc_guar_anal_on_ivc_yn] CHAR (1)       NULL,
    [ftloc_dir_on_wrksht_yn]    CHAR (1)       NULL,
    [ftloc_no_wrksht_copies]    TINYINT        NULL,
    [ftloc_workorder_printer]   CHAR (80)      NULL,
    [ftloc_prt_pest_log_yn]     CHAR (1)       NULL,
    [ftloc_user_id]             CHAR (16)      NULL,
    [ftloc_user_rev_dt]         INT            NULL,
    [A4GLIdentity]              NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ftlocmst] PRIMARY KEY NONCLUSTERED ([ftloc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iftlocmst0]
    ON [dbo].[ftlocmst]([ftloc_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ftlocmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ftlocmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ftlocmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ftlocmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ftlocmst] TO PUBLIC
    AS [dbo];

