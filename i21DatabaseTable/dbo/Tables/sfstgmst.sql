CREATE TABLE [dbo].[sfstgmst] (
    [sfstg_cus_no]            CHAR (10)       NOT NULL,
    [sfstg_stg_id]            CHAR (10)       NOT NULL,
    [sfstg_seq_no]            TINYINT         NOT NULL,
    [sfstg_desc]              CHAR (30)       NULL,
    [sfstg_animal_cd]         CHAR (1)        NULL,
    [sfstg_stage_opt_wd]      CHAR (1)        NULL,
    [sfstg_rcp_cus_no]        CHAR (10)       NULL,
    [sfstg_start_wgt]         DECIMAL (7, 2)  NULL,
    [sfstg_end_wgt]           DECIMAL (7, 2)  NULL,
    [sfstg_rcp_no]            CHAR (10)       NULL,
    [sfstg_feed_per_head]     DECIMAL (9, 4)  NULL,
    [sfstg_over_tol]          DECIMAL (9, 4)  NULL,
    [sfstg_under_tol]         DECIMAL (9, 4)  NULL,
    [sfstg_grp_id]            CHAR (14)       NOT NULL,
    [sfstg_act_feed_wgt]      DECIMAL (11, 4) NULL,
    [sfstg_act_feed_per_head] DECIMAL (9, 4)  NULL,
    [sfstg_act_cost_per_head] DECIMAL (9, 4)  NULL,
    [sfstg_act_feed_cost]     DECIMAL (11, 2) NULL,
    [sfstg_act_drug_cost]     DECIMAL (11, 2) NULL,
    [sfstg_act_dlvy_cost]     DECIMAL (11, 2) NULL,
    [sfstg_act_current_head]  INT             NULL,
    [sfstg_stg_complete_yn]   CHAR (1)        NULL,
    [sfstg_shrk_pct]          DECIMAL (5, 2)  NULL,
    [sfstg_user_id]           CHAR (16)       NULL,
    [sfstg_user_rev_dt]       INT             NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sfstgmst] PRIMARY KEY NONCLUSTERED ([sfstg_cus_no] ASC, [sfstg_stg_id] ASC, [sfstg_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isfstgmst0]
    ON [dbo].[sfstgmst]([sfstg_cus_no] ASC, [sfstg_stg_id] ASC, [sfstg_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Isfstgmst1]
    ON [dbo].[sfstgmst]([sfstg_grp_id] ASC);

