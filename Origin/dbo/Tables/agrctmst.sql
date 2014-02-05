﻿CREATE TABLE [dbo].[agrctmst] (
    [agrct_vnd_no]            CHAR (10)       NOT NULL,
    [agrct_ord_no]            CHAR (8)        NOT NULL,
    [agrct_rcpt_seq_no]       TINYINT         NOT NULL,
    [agrct_line_no]           SMALLINT        NOT NULL,
    [agrct_bill_lading_no]    CHAR (15)       NULL,
    [agrct_batch_no]          SMALLINT        NULL,
    [agrct_rev_dt]            INT             NULL,
    [agrct_loc_no]            CHAR (3)        NULL,
    [agrct_origin]            CHAR (20)       NULL,
    [agrct_carrier]           CHAR (10)       NULL,
    [agrct_fob_point]         CHAR (10)       NULL,
    [agrct_del_point]         CHAR (10)       NULL,
    [agrct_frt_variance_amt]  DECIMAL (9, 2)  NULL,
    [agrct_calcd_total]       DECIMAL (9, 2)  NULL,
    [agrct_frt_total]         DECIMAL (9, 2)  NULL,
    [agrct_carrier_rate]      DECIMAL (11, 5) NULL,
    [agrct_frt_alloc_wcn]     CHAR (1)        NULL,
    [agrct_frt_billed_by_von] CHAR (1)        NULL,
    [agrct_prepaid_yn]        CHAR (1)        NULL,
    [agrct_po_loc_no]         CHAR (3)        NULL,
    [agrct_hdr_currency]      CHAR (3)        NULL,
    [agrct_hdr_currency_rt]   DECIMAL (15, 8) NULL,
    [agrct_hdr_currency_cnt]  CHAR (8)        NULL,
    [agrct_user_id]           CHAR (16)       NULL,
    [agrct_user_rev_dt]       INT             NULL,
    [agrct_itm_no]            CHAR (13)       NULL,
    [agrct_gross_pkg]         DECIMAL (11, 4) NULL,
    [agrct_net_pkg]           DECIMAL (11, 4) NULL,
    [agrct_un_cost]           DECIMAL (11, 5) NULL,
    [agrct_if_rt]             DECIMAL (9, 6)  NULL,
    [agrct_if_amt]            DECIMAL (11, 2) NULL,
    [agrct_fet_rt]            DECIMAL (9, 6)  NULL,
    [agrct_fet_amt]           DECIMAL (11, 2) NULL,
    [agrct_set_rt]            DECIMAL (9, 6)  NULL,
    [agrct_set_amt]           DECIMAL (11, 2) NULL,
    [agrct_sst_ynp]           CHAR (1)        NULL,
    [agrct_sst_rt]            DECIMAL (9, 6)  NULL,
    [agrct_sst_pu]            CHAR (1)        NULL,
    [agrct_sst_amt]           DECIMAL (11, 2) NULL,
    [agrct_sst_on_net]        DECIMAL (11, 2) NULL,
    [agrct_sst_on_fet]        DECIMAL (11, 2) NULL,
    [agrct_sst_on_set]        DECIMAL (11, 2) NULL,
    [agrct_sst_on_lc1]        DECIMAL (11, 2) NULL,
    [agrct_sst_on_lc2]        DECIMAL (11, 2) NULL,
    [agrct_sst_on_lc3]        DECIMAL (11, 2) NULL,
    [agrct_sst_on_lc4]        DECIMAL (11, 2) NULL,
    [agrct_sst_on_lc5]        DECIMAL (11, 2) NULL,
    [agrct_sst_on_lc6]        DECIMAL (11, 2) NULL,
    [agrct_lc1_rt]            DECIMAL (9, 6)  NULL,
    [agrct_lc1_amt]           DECIMAL (11, 2) NULL,
    [agrct_lc1_pu]            CHAR (1)        NULL,
    [agrct_lc1_on_net]        DECIMAL (11, 2) NULL,
    [agrct_lc1_on_fet]        DECIMAL (11, 2) NULL,
    [agrct_lc2_rt]            DECIMAL (9, 6)  NULL,
    [agrct_lc2_amt]           DECIMAL (11, 2) NULL,
    [agrct_lc2_pu]            CHAR (1)        NULL,
    [agrct_lc2_on_net]        DECIMAL (11, 2) NULL,
    [agrct_lc2_on_fet]        DECIMAL (11, 2) NULL,
    [agrct_lc3_rt]            DECIMAL (9, 6)  NULL,
    [agrct_lc3_amt]           DECIMAL (11, 2) NULL,
    [agrct_lc3_pu]            CHAR (1)        NULL,
    [agrct_lc3_on_net]        DECIMAL (11, 2) NULL,
    [agrct_lc3_on_fet]        DECIMAL (11, 2) NULL,
    [agrct_lc4_rt]            DECIMAL (9, 6)  NULL,
    [agrct_lc4_amt]           DECIMAL (11, 2) NULL,
    [agrct_lc4_pu]            CHAR (1)        NULL,
    [agrct_lc4_on_net]        DECIMAL (11, 2) NULL,
    [agrct_lc4_on_fet]        DECIMAL (11, 2) NULL,
    [agrct_lc5_rt]            DECIMAL (9, 6)  NULL,
    [agrct_lc5_amt]           DECIMAL (11, 2) NULL,
    [agrct_lc5_pu]            CHAR (1)        NULL,
    [agrct_lc5_on_net]        DECIMAL (11, 2) NULL,
    [agrct_lc5_on_fet]        DECIMAL (11, 2) NULL,
    [agrct_lc6_rt]            DECIMAL (9, 6)  NULL,
    [agrct_lc6_amt]           DECIMAL (11, 2) NULL,
    [agrct_lc6_pu]            CHAR (1)        NULL,
    [agrct_lc6_on_net]        DECIMAL (11, 2) NULL,
    [agrct_lc6_on_fet]        DECIMAL (11, 2) NULL,
    [agrct_tax_state]         CHAR (2)        NULL,
    [agrct_tax_auth_id1]      CHAR (3)        NULL,
    [agrct_tax_auth_id2]      CHAR (3)        NULL,
    [agrct_frt_un_cost]       DECIMAL (11, 5) NULL,
    [agrct_lot_no_yn]         CHAR (1)        NULL,
    [agrct_backord_yn]        CHAR (1)        NULL,
    [agrct_dtl_comments]      CHAR (33)       NULL,
    [agrct_dtl_desc]          CHAR (33)       NULL,
    [agrct_gl_acct]           DECIMAL (16, 8) NULL,
    [agrct_gross_net_ind]     CHAR (1)        NULL,
    [agrct_pur_dtl_line_no]   SMALLINT        NULL,
    [agrct_currency]          CHAR (3)        NULL,
    [agrct_currency_rt]       DECIMAL (15, 8) NULL,
    [agrct_currency_cnt]      CHAR (8)        NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agrctmst] PRIMARY KEY NONCLUSTERED ([agrct_vnd_no] ASC, [agrct_ord_no] ASC, [agrct_rcpt_seq_no] ASC, [agrct_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagrctmst0]
    ON [dbo].[agrctmst]([agrct_vnd_no] ASC, [agrct_ord_no] ASC, [agrct_rcpt_seq_no] ASC, [agrct_line_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agrctmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agrctmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agrctmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agrctmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agrctmst] TO PUBLIC
    AS [dbo];

