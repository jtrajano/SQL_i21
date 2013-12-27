CREATE TABLE [dbo].[agpurmst] (
    [agpur_vnd_no]            CHAR (10)       NOT NULL,
    [agpur_ord_no]            CHAR (8)        NOT NULL,
    [agpur_line_no]           SMALLINT        NOT NULL,
    [agpur_next_rct_seq]      TINYINT         NULL,
    [agpur_ord_rev_dt]        INT             NULL,
    [agpur_exp_rev_dt]        INT             NULL,
    [agpur_loc_no]            CHAR (3)        NULL,
    [agpur_note1]             CHAR (20)       NULL,
    [agpur_note2]             CHAR (20)       NULL,
    [agpur_po_printed_yn]     CHAR (1)        NULL,
    [agpur_ordered_by]        CHAR (20)       NULL,
    [agpur_approved_by]       CHAR (20)       NULL,
    [agpur_ord_prepaid_yn]    CHAR (1)        NULL,
    [agpur_frt_billed_by_von] CHAR (1)        NULL,
    [agpur_total_weight]      DECIMAL (11, 2) NULL,
    [agpur_terms_desc]        CHAR (15)       NULL,
    [agpur_bol_no]            CHAR (15)       NULL,
    [agpur_carrier]           CHAR (10)       NULL,
    [agpur_origin]            CHAR (20)       NULL,
    [agpur_user_id]           CHAR (16)       NULL,
    [agpur_user_rev_dt]       INT             NULL,
    [agpur_ord_pkg]           DECIMAL (13, 4) NULL,
    [agpur_ord_un_cost]       DECIMAL (11, 5) NULL,
    [agpur_itm_no]            CHAR (13)       NULL,
    [agpur_rcv_pkg]           DECIMAL (13, 4) NULL,
    [agpur_fet_yn]            CHAR (1)        NULL,
    [agpur_set_yn]            CHAR (1)        NULL,
    [agpur_sst_ynp]           CHAR (1)        NULL,
    [agpur_lc1_yn]            CHAR (1)        NULL,
    [agpur_lc2_yn]            CHAR (1)        NULL,
    [agpur_lc3_yn]            CHAR (1)        NULL,
    [agpur_lc4_yn]            CHAR (1)        NULL,
    [agpur_lc5_yn]            CHAR (1)        NULL,
    [agpur_lc6_yn]            CHAR (1)        NULL,
    [agpur_if_yn]             CHAR (1)        NULL,
    [agpur_pending_pkg]       DECIMAL (13, 4) NULL,
    [agpur_backord_yn]        CHAR (1)        NULL,
    [agpur_dtl_comments]      CHAR (33)       NULL,
    [agpur_dtl_desc]          CHAR (33)       NULL,
    [agpur_gl_acct]           DECIMAL (16, 8) NULL,
    [agpur_vpx_itm_no]        CHAR (15)       NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agpurmst] PRIMARY KEY NONCLUSTERED ([agpur_vnd_no] ASC, [agpur_ord_no] ASC, [agpur_line_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagpurmst0]
    ON [dbo].[agpurmst]([agpur_vnd_no] ASC, [agpur_ord_no] ASC, [agpur_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagpurmst1]
    ON [dbo].[agpurmst]([agpur_ord_no] ASC, [agpur_vnd_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agpurmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agpurmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agpurmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agpurmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agpurmst] TO PUBLIC
    AS [dbo];

