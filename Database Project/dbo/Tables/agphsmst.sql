﻿CREATE TABLE [dbo].[agphsmst] (
    [agphs_vnd_no]                CHAR (10)       NOT NULL,
    [agphs_ord_no]                CHAR (8)        NOT NULL,
    [agphs_rcpt_seq]              TINYINT         NOT NULL,
    [agphs_line_no]               SMALLINT        NOT NULL,
    [agphs_verified_yn]           CHAR (1)        NOT NULL,
    [agphs_vnd_ivc_no]            CHAR (15)       NOT NULL,
    [agphs_filler_area]           CHAR (3)        NOT NULL,
    [agphs_rct_rev_dt]            INT             NOT NULL,
    [agphs_pend_ap_gl_acct]       DECIMAL (16, 8) NULL,
    [agphs_pend_ap_gl_amt]        DECIMAL (11, 2) NULL,
    [agphs_bill_lading]           CHAR (15)       NULL,
    [agphs_origin]                CHAR (20)       NULL,
    [agphs_carrier]               CHAR (10)       NULL,
    [agphs_fob_point]             CHAR (10)       NULL,
    [agphs_del_point]             CHAR (10)       NULL,
    [agphs_verify_rev_dt]         INT             NULL,
    [agphs_calc_total]            DECIMAL (9, 2)  NULL,
    [agphs_frt_alloc_wcn]         CHAR (1)        NULL,
    [agphs_tax_st]                CHAR (2)        NULL,
    [agphs_src_sys]               CHAR (3)        NULL,
    [agphs_frt_billed_by_von]     CHAR (1)        NULL,
    [agphs_rcvd_prepaid_yn]       CHAR (1)        NULL,
    [agphs_invc_prepaid_yn]       CHAR (1)        NULL,
    [agphs_hdr_loc_no]            CHAR (3)        NULL,
    [agphs_rcvd_frt_gl_acct]      DECIMAL (16, 8) NULL,
    [agphs_rcvd_frt_amt]          DECIMAL (9, 2)  NULL,
    [agphs_rcvd_frt_variance_amt] DECIMAL (9, 2)  NULL,
    [agphs_invc_frt_gl_acct]      DECIMAL (16, 8) NULL,
    [agphs_invc_frt_amt]          DECIMAL (9, 2)  NULL,
    [agphs_invc_frt_variance_amt] DECIMAL (9, 2)  NULL,
    [agphs_audit_no]              CHAR (4)        NULL,
    [agphs_carrier_ivc_no]        CHAR (15)       NULL,
    [agphs_pend_ap_gl_posted_yn]  CHAR (1)        NULL,
    [agphs_hdr_currency]          CHAR (3)        NULL,
    [agphs_hdr_currency_rt]       DECIMAL (15, 8) NULL,
    [agphs_hdr_currency_cnt]      CHAR (8)        NULL,
    [agphs_user_id]               CHAR (16)       NULL,
    [agphs_user_rev_dt]           INT             NULL,
    [agphs_itm_no]                CHAR (13)       NULL,
    [agphs_loc_no]                CHAR (3)        NULL,
    [agphs_tax_cls_cd]            CHAR (2)        NULL,
    [agphs_lot_no_yn]             CHAR (1)        NULL,
    [agphs_desc_override]         CHAR (33)       NULL,
    [agphs_un_desc]               CHAR (3)        NULL,
    [agphs_lbs_per_un]            DECIMAL (9, 4)  NULL,
    [agphs_un_per_pak]            DECIMAL (11, 6) NULL,
    [agphs_rcvd_gross_un]         DECIMAL (11, 4) NULL,
    [agphs_rcvd_net_un]           DECIMAL (11, 4) NULL,
    [agphs_rcvd_un]               DECIMAL (11, 4) NULL,
    [agphs_rcvd_un_cst]           DECIMAL (11, 5) NULL,
    [agphs_rcvd_frt_un_cst]       DECIMAL (11, 5) NULL,
    [agphs_rcvd_fet_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_set_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_if_rt]            DECIMAL (7, 4)  NULL,
    [agphs_rcvd_sst_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_lc1_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_lc2_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_lc3_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_lc4_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_lc5_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_lc6_rt]           DECIMAL (9, 6)  NULL,
    [agphs_rcvd_if_amt]           DECIMAL (11, 2) NULL,
    [agphs_rcvd_fet_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_set_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_pu]           CHAR (1)        NULL,
    [agphs_rcvd_sst_on_net]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_on_set]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_on_lc1]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_on_lc2]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_on_lc3]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_on_lc4]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_on_lc5]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_sst_on_lc6]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc1_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc1_pu]           CHAR (1)        NULL,
    [agphs_rcvd_lc1_on_net]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc1_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc2_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc2_pu]           CHAR (1)        NULL,
    [agphs_rcvd_lc2_on_net]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc2_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc3_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc3_pu]           CHAR (1)        NULL,
    [agphs_rcvd_lc3_on_net]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc3_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc4_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc4_pu]           CHAR (1)        NULL,
    [agphs_rcvd_lc4_on_net]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc4_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc5_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc5_pu]           CHAR (1)        NULL,
    [agphs_rcvd_lc5_on_net]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc5_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc6_amt]          DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc6_pu]           CHAR (1)        NULL,
    [agphs_rcvd_lc6_on_net]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_lc6_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_rcvd_gl_acct]          DECIMAL (16, 8) NULL,
    [agphs_rcvd_gl_amt]           DECIMAL (11, 2) NULL,
    [agphs_invc_un]               DECIMAL (11, 4) NULL,
    [agphs_invc_un_cst]           DECIMAL (11, 5) NULL,
    [agphs_invc_frt_un_cst]       DECIMAL (11, 5) NULL,
    [agphs_invc_fet_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_set_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_if_rt]            DECIMAL (7, 4)  NULL,
    [agphs_invc_sst_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_lc1_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_lc2_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_lc3_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_lc4_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_lc5_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_lc6_rt]           DECIMAL (9, 6)  NULL,
    [agphs_invc_if_amt]           DECIMAL (11, 2) NULL,
    [agphs_invc_fet_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_set_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_sst_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_sst_pu]           CHAR (1)        NULL,
    [agphs_invc_sst_on_net]       DECIMAL (11, 2) NULL,
    [agphs_invc_sst_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_invc_sst_on_set]       DECIMAL (11, 2) NULL,
    [agphs_invc_sst_on_lc1]       DECIMAL (11, 2) NULL,
    [agphs_invc_sst_on_lc2]       DECIMAL (11, 2) NULL,
    [agphs_invc_sst_on_lc3]       DECIMAL (11, 2) NULL,
    [agphs_invc_sst_on_lc4]       DECIMAL (11, 2) NULL,
    [agphs_invc_sst_on_lc5]       DECIMAL (11, 2) NULL,
    [agphs_invc_sst_on_lc6]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc1_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_lc1_pu]           CHAR (1)        NULL,
    [agphs_invc_lc1_on_net]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc1_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc2_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_lc2_pu]           CHAR (1)        NULL,
    [agphs_invc_lc2_on_net]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc2_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc3_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_lc3_pu]           CHAR (1)        NULL,
    [agphs_invc_lc3_on_net]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc3_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc4_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_lc4_pu]           CHAR (1)        NULL,
    [agphs_invc_lc4_on_net]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc4_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc5_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_lc5_pu]           CHAR (1)        NULL,
    [agphs_invc_lc5_on_net]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc5_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc6_amt]          DECIMAL (11, 2) NULL,
    [agphs_invc_lc6_pu]           CHAR (1)        NULL,
    [agphs_invc_lc6_on_net]       DECIMAL (11, 2) NULL,
    [agphs_invc_lc6_on_fet]       DECIMAL (11, 2) NULL,
    [agphs_invc_gl_acct]          DECIMAL (16, 8) NULL,
    [agphs_invc_gl_amt]           DECIMAL (11, 2) NULL,
    [agphs_gross_net_ind]         CHAR (1)        NULL,
    [agphs_tax_state]             CHAR (2)        NULL,
    [agphs_tax_auth_id1]          CHAR (3)        NULL,
    [agphs_tax_auth_id2]          CHAR (3)        NULL,
    [agphs_sst_ynp]               CHAR (1)        NULL,
    [agphs_currency]              CHAR (3)        NULL,
    [agphs_currency_rt]           DECIMAL (15, 8) NULL,
    [agphs_currency_cnt]          CHAR (8)        NULL,
    [A4GLIdentity]                NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agphsmst] PRIMARY KEY NONCLUSTERED ([agphs_vnd_no] ASC, [agphs_ord_no] ASC, [agphs_rcpt_seq] ASC, [agphs_line_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagphsmst0]
    ON [dbo].[agphsmst]([agphs_vnd_no] ASC, [agphs_ord_no] ASC, [agphs_rcpt_seq] ASC, [agphs_line_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iagphsmst1]
    ON [dbo].[agphsmst]([agphs_verified_yn] ASC, [agphs_vnd_no] ASC, [agphs_ord_no] ASC, [agphs_rcpt_seq] ASC, [agphs_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagphsmst2]
    ON [dbo].[agphsmst]([agphs_vnd_ivc_no] ASC, [agphs_filler_area] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagphsmst3]
    ON [dbo].[agphsmst]([agphs_rct_rev_dt] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agphsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agphsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agphsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agphsmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agphsmst] TO PUBLIC
    AS [dbo];

