CREATE TABLE [dbo].[gascimst] (
    [gasci_loc_no]                CHAR (3)    NOT NULL,
    [gasci_scale_id]              CHAR (1)    NOT NULL,
    [gasci_addr]                  CHAR (30)   NULL,
    [gasci_addr2]                 CHAR (30)   NULL,
    [gasci_city]                  CHAR (20)   NULL,
    [gasci_state]                 CHAR (2)    NULL,
    [gasci_zip]                   CHAR (10)   NULL,
    [gasci_forms_co_yn]           CHAR (1)    NULL,
    [gasci_tic_format]            CHAR (1)    NULL,
    [gasci_last_weigher]          CHAR (12)   NULL,
    [gasci_office_copies]         TINYINT     NULL,
    [gasci_prt_spl_cpy_yn]        CHAR (1)    NULL,
    [gasci_wgt_num_dec]           TINYINT     NULL,
    [gasci_wgt_desc]              CHAR (3)    NULL,
    [gasci_comment_1]             CHAR (55)   NULL,
    [gasci_comment_2]             CHAR (55)   NULL,
    [gasci_comment_3]             CHAR (55)   NULL,
    [gasci_comment_4]             CHAR (55)   NULL,
    [gasci_comment_5]             CHAR (55)   NULL,
    [gasci_comment_6]             CHAR (55)   NULL,
    [gasci_one_tic_series_yno]    CHAR (1)    NULL,
    [gasci_ag_orders_yn]          CHAR (1)    NULL,
    [gasci_next_in_tic_no]        BIGINT      NULL,
    [gasci_next_out_tic_no]       BIGINT      NULL,
    [gasci_next_memo_tic_no]      BIGINT      NULL,
    [gasci_next_ag_tic_no]        BIGINT      NULL,
    [gasci_purge_days]            INT         NULL,
    [gasci_active_yn]             CHAR (1)    NULL,
    [gasci_scale_model]           CHAR (5)    NULL,
    [gasci_device]                CHAR (25)   NULL,
    [gasci_ntep_capacity]         CHAR (20)   NULL,
    [gasci_tic_printer]           CHAR (80)   NULL,
    [gasci_plant_printer]         CHAR (80)   NULL,
    [gasci_grader_active_yn]      CHAR (1)    NULL,
    [gasci_grader_model]          CHAR (5)    NULL,
    [gasci_prt_grade_tag_yn]      CHAR (1)    NULL,
    [gasci_multi_grader_yn]       CHAR (1)    NULL,
    [gasci_multi_grader_model]    CHAR (5)    NULL,
    [gasci_allow_spl_weighs_yn]   CHAR (1)    NULL,
    [gasci_xref_card_sz]          TINYINT     NULL,
    [gasci_otb_scale_id]          CHAR (1)    NULL,
    [gasci_override_tic_yn]       CHAR (1)    NULL,
    [gasci_zero_wgt_yn]           CHAR (1)    NULL,
    [gasci_remote_yn]             CHAR (1)    NULL,
    [gasci_auto_dist_yn]          CHAR (1)    NULL,
    [gasci_use_grade_kiosk_yn]    CHAR (1)    NULL,
    [gasci_remote_status]         CHAR (2)    NULL,
    [gasci_remote_path]           CHAR (50)   NULL,
    [gasci_prt_plant_ticket_ynkc] CHAR (1)    NULL,
    [gasci_show_tdnr]             CHAR (1)    NULL,
    [gasci_show2_tw]              CHAR (1)    NULL,
    [gasci_tic_ff_yn]             CHAR (1)    NULL,
    [gasci_user_id]               CHAR (16)   NULL,
    [gasci_user_rev_dt]           INT         NULL,
    [A4GLIdentity]                NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gascimst] PRIMARY KEY NONCLUSTERED ([gasci_loc_no] ASC, [gasci_scale_id] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igascimst0]
    ON [dbo].[gascimst]([gasci_loc_no] ASC, [gasci_scale_id] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gascimst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gascimst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gascimst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gascimst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gascimst] TO PUBLIC
    AS [dbo];

