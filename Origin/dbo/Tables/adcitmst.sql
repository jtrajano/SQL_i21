CREATE TABLE [dbo].[adcitmst] (
    [adcit_cus_no]              CHAR (10)       NOT NULL,
    [adcit_itm_no]              CHAR (13)       NOT NULL,
    [adcit_tank_no]             CHAR (4)        NOT NULL,
    [adcit_tank_desc]           CHAR (50)       NULL,
    [adcit_tank_cap]            INT             NULL,
    [adcit_tank_res]            INT             NULL,
    [adcit_fill_meth]           CHAR (1)        NULL,
    [adcit_dd_between_dlvry]    INT             NULL,
    [adcit_days_between_dlvry]  SMALLINT        NULL,
    [adcit_clock_loc_no]        CHAR (3)        NULL,
    [adcit_driver_id]           CHAR (3)        NULL,
    [adcit_rte_id]              CHAR (3)        NOT NULL,
    [adcit_seq_no]              SMALLINT        NOT NULL,
    [adcit_prnt_ivc_yn]         CHAR (1)        NULL,
    [adcit_prompt_pct_full_yn]  CHAR (1)        NULL,
    [adcit_last_gals_in_tank]   INT             NULL,
    [adcit_smr_gals_per_day]    DECIMAL (5, 2)  NULL,
    [adcit_wnt_gals_per_day]    DECIMAL (5, 2)  NULL,
    [adcit_un_prc_adj]          DECIMAL (9, 4)  NULL,
    [adcit_acct_status]         CHAR (1)        NULL,
    [adcit_sst_ynp]             CHAR (1)        NULL,
    [adcit_tax_state]           CHAR (2)        NULL,
    [adcit_tax_auth_id1]        CHAR (3)        NULL,
    [adcit_tax_auth_id2]        CHAR (3)        NULL,
    [adcit_adj_burn_rt_yn]      CHAR (1)        NULL,
    [adcit_ytd_gals_ty]         DECIMAL (11, 4) NULL,
    [adcit_ytd_gals_ly]         DECIMAL (11, 4) NULL,
    [adcit_tank_twp]            CHAR (10)       NULL,
    [adcit_last_rev_dt]         INT             NULL,
    [adcit_last_dd]             INT             NULL,
    [adcit_last_gals]           DECIMAL (11, 4) NULL,
    [adcit_last_burn_rt]        DECIMAL (5, 2)  NULL,
    [adcit_next_dd]             INT             NULL,
    [adcit_next_rev_dt]         INT             NULL,
    [adcit_tic_printed_yn]      CHAR (1)        NULL,
    [adcit_delv_tkt_no]         INT             NULL,
    [adcit_dlvry_instruction_1] CHAR (50)       NULL,
    [adcit_dlvry_instruction_2] CHAR (50)       NULL,
    [adcit_dlvry_instruction_3] CHAR (50)       NULL,
    [adcit_comment_1]           CHAR (50)       NULL,
    [adcit_comment_2]           CHAR (50)       NULL,
    [adcit_confidence_factor]   DECIMAL (5, 2)  NULL,
    [adcit_pct_remaining]       SMALLINT        NULL,
    [adcit_runout_rev_dt]       INT             NULL,
    [adcit_class_fill_option]   CHAR (1)        NULL,
    [adcit_user_id]             CHAR (16)       NULL,
    [adcit_user_rev_dt]         INT             NULL,
    [A4GLIdentity]              NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_adcitmst] PRIMARY KEY NONCLUSTERED ([adcit_cus_no] ASC, [adcit_itm_no] ASC, [adcit_tank_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iadcitmst0]
    ON [dbo].[adcitmst]([adcit_cus_no] ASC, [adcit_itm_no] ASC, [adcit_tank_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iadcitmst1]
    ON [dbo].[adcitmst]([adcit_itm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iadcitmst2]
    ON [dbo].[adcitmst]([adcit_rte_id] ASC, [adcit_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[adcitmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[adcitmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[adcitmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[adcitmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[adcitmst] TO PUBLIC
    AS [dbo];

