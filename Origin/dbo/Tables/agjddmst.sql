CREATE TABLE [dbo].[agjddmst] (
    [agjdd_period]              INT             NOT NULL,
    [agjdd_acct1_8]             INT             NOT NULL,
    [agjdd_acct9_16]            INT             NOT NULL,
    [agjdd_src_id]              CHAR (3)        NOT NULL,
    [agjdd_src_seq]             CHAR (5)        NOT NULL,
    [agjdd_line_no]             INT             NOT NULL,
    [agjdd_dtl_line_no]         INT             NOT NULL,
    [agjdd_tran_amt]            DECIMAL (11, 2) NULL,
    [agjdd_tran_units]          DECIMAL (16, 4) NULL,
    [agjdd_tran_rev_dt]         INT             NULL,
    [agjdd_dr_cr_ind]           CHAR (1)        NULL,
    [agjdd_drill_rec_type]      CHAR (2)        NULL,
    [agjdd_drill_area]          CHAR (60)       NULL,
    [agjdd_bi_cus_no]           CHAR (10)       NULL,
    [agjdd_bi_ivc_no]           CHAR (8)        NULL,
    [agjdd_bi_loc_no]           CHAR (3)        NULL,
    [agjdd_bi_line_no]          CHAR (3)        NULL,
    [agjdd_sc_bi_cus_no]        CHAR (10)       NULL,
    [agjdd_sc_bi_ivc_no]        CHAR (8)        NULL,
    [agjdd_sc_bi_loc_no]        CHAR (3)        NULL,
    [agjdd_sc_bi_line_no]       CHAR (3)        NULL,
    [agjdd_cp_bi_cus_no]        CHAR (10)       NULL,
    [agjdd_cp_bi_ivc_no]        CHAR (8)        NULL,
    [agjdd_cp_bi_loc_no]        CHAR (3)        NULL,
    [agjdd_cp_bi_line_no]       CHAR (3)        NULL,
    [agjdd_oi_bi_cus_no]        CHAR (10)       NULL,
    [agjdd_oi_bi_ivc_no]        CHAR (8)        NULL,
    [agjdd_oi_bi_loc_no]        CHAR (3)        NULL,
    [agjdd_oi_bi_line_no]       CHAR (3)        NULL,
    [agjdd_oi_bi_oth_inc_cd]    CHAR (2)        NULL,
    [agjdd_ad_bln_itm_no]       CHAR (13)       NULL,
    [agjdd_ad_bln_loc_no]       CHAR (3)        NULL,
    [agjdd_ad_bln_seq_no]       CHAR (2)        NULL,
    [agjdd_ad_bln_rev_dt]       INT             NULL,
    [agjdd_ad_bln_tie_breaker]  CHAR (4)        NULL,
    [agjdd_ad_bln_line_no]      CHAR (2)        NULL,
    [agjdd_ad_bln_desc]         CHAR (13)       NULL,
    [agjdd_ad_bln_ivc_no]       CHAR (8)        NULL,
    [agjdd_xf_bln_itm_no]       CHAR (13)       NULL,
    [agjdd_xf_bln_loc_no]       CHAR (3)        NULL,
    [agjdd_xf_bln_seq_no]       CHAR (2)        NULL,
    [agjdd_xf_bln_rev_dt]       INT             NULL,
    [agjdd_xf_bln_tie_breaker]  CHAR (4)        NULL,
    [agjdd_xf_bln_line_no]      CHAR (2)        NULL,
    [agjdd_xf_bln_desc]         CHAR (13)       NULL,
    [agjdd_xf_bln_ivc_no]       CHAR (8)        NULL,
    [agjdd_ml_bln_itm_no]       CHAR (13)       NULL,
    [agjdd_ml_bln_loc_no]       CHAR (3)        NULL,
    [agjdd_ml_bln_seq_no]       CHAR (2)        NULL,
    [agjdd_ml_bln_rev_dt]       INT             NULL,
    [agjdd_ml_bln_tie_breaker]  CHAR (4)        NULL,
    [agjdd_ml_bln_line_no]      CHAR (2)        NULL,
    [agjdd_ml_bln_desc]         CHAR (13)       NULL,
    [agjdd_ml_bln_ivc_no]       CHAR (8)        NULL,
    [agjdd_oth_bln_itm_no]      CHAR (13)       NULL,
    [agjdd_oth_bln_loc_no]      CHAR (3)        NULL,
    [agjdd_oth_bln_seq_no]      CHAR (2)        NULL,
    [agjdd_oth_bln_rev_dt]      INT             NULL,
    [agjdd_oth_bln_tie_breaker] CHAR (4)        NULL,
    [agjdd_oth_bln_line_no]     CHAR (2)        NULL,
    [agjdd_oth_bln_desc]        CHAR (13)       NULL,
    [agjdd_oth_bln_ivc_no]      CHAR (8)        NULL,
    [agjdd_rct_vnd_no]          CHAR (10)       NULL,
    [agjdd_rct_ord_no]          CHAR (8)        NULL,
    [agjdd_rct_seq_no]          CHAR (2)        NULL,
    [agjdd_rct_line_no]         CHAR (3)        NULL,
    [agjdd_rv_rct_vnd_no]       CHAR (10)       NULL,
    [agjdd_rv_rct_ord_no]       CHAR (8)        NULL,
    [agjdd_rv_rct_seq_no]       CHAR (2)        NULL,
    [agjdd_rv_rct_line_no]      CHAR (3)        NULL,
    [A4GLIdentity]              NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agjddmst] PRIMARY KEY NONCLUSTERED ([agjdd_period] ASC, [agjdd_acct1_8] ASC, [agjdd_acct9_16] ASC, [agjdd_src_id] ASC, [agjdd_src_seq] ASC, [agjdd_line_no] ASC, [agjdd_dtl_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagjddmst0]
    ON [dbo].[agjddmst]([agjdd_period] ASC, [agjdd_acct1_8] ASC, [agjdd_acct9_16] ASC, [agjdd_src_id] ASC, [agjdd_src_seq] ASC, [agjdd_line_no] ASC, [agjdd_dtl_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agjddmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agjddmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agjddmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agjddmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agjddmst] TO PUBLIC
    AS [dbo];

