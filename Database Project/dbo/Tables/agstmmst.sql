﻿CREATE TABLE [dbo].[agstmmst] (
    [agstm_bill_to_cus]      CHAR (10)       NOT NULL,
    [agstm_ivc_no]           CHAR (8)        NOT NULL,
    [agstm_key_loc_no]       CHAR (3)        NOT NULL,
    [agstm_line_no]          SMALLINT        NOT NULL,
    [agstm_rec_type]         CHAR (1)        NOT NULL,
    [agstm_ship_rev_dt]      INT             NOT NULL,
    [agstm_itm_no]           CHAR (13)       NOT NULL,
    [agstm_loc_no]           CHAR (3)        NOT NULL,
    [agstm_hdr_audit_no]     CHAR (4)        NULL,
    [agstm_type]             CHAR (1)        NULL,
    [agstm_ord_no]           CHAR (8)        NULL,
    [agstm_ord_rev_dt]       INT             NULL,
    [agstm_disc_rev_dt]      INT             NULL,
    [agstm_cash_tendered]    DECIMAL (11, 2) NULL,
    [agstm_chk_no]           CHAR (8)        NULL,
    [agstm_terms_desc]       CHAR (15)       NULL,
    [agstm_hdr_sold_to_cus]  CHAR (10)       NULL,
    [agstm_split_no]         CHAR (4)        NULL,
    [agstm_spl_exc_class]    CHAR (3)        NULL,
    [agstm_spl_pct]          DECIMAL (7, 4)  NULL,
    [agstm_po_no]            CHAR (15)       NULL,
    [agstm_hdr_comments]     CHAR (30)       NULL,
    [agstm_batch_no]         SMALLINT        NULL,
    [agstm_src_sys]          CHAR (3)        NULL,
    [agstm_pay_pat_yn]       CHAR (1)        NULL,
    [agstm_dmem_amt]         DECIMAL (11, 2) NULL,
    [agstm_dmem_gl_acct]     DECIMAL (16, 8) NULL,
    [agstm_hdr_slsmn_id]     CHAR (3)        NULL,
    [agstm_hdr_order_taker]  CHAR (3)        NULL,
    [agstm_hdr_currency]     CHAR (3)        NULL,
    [agstm_hdr_currency_rt]  DECIMAL (15, 8) NULL,
    [agstm_hdr_currency_cnt] CHAR (8)        NULL,
    [agstm_ppd_amt_applied]  DECIMAL (11, 2) NULL,
    [agstm_user_id]          CHAR (16)       NULL,
    [agstm_user_rev_dt]      INT             NULL,
    [agstm_user_time]        INT             NULL,
    [agstm_audit_no]         CHAR (4)        NULL,
    [agstm_dtl_type]         CHAR (1)        NULL,
    [agstm_class]            CHAR (3)        NULL,
    [agstm_un]               DECIMAL (11, 4) NULL,
    [agstm_sls]              DECIMAL (11, 2) NULL,
    [agstm_cgs]              DECIMAL (11, 2) NULL,
    [agstm_fet_amt]          DECIMAL (11, 2) NULL,
    [agstm_fet_rt]           DECIMAL (9, 6)  NULL,
    [agstm_set_amt]          DECIMAL (11, 2) NULL,
    [agstm_set_rt]           DECIMAL (9, 6)  NULL,
    [agstm_sst_amt]          DECIMAL (11, 2) NULL,
    [agstm_sst_rt]           DECIMAL (9, 6)  NULL,
    [agstm_sst_pu]           CHAR (1)        NULL,
    [agstm_sst_on_net]       DECIMAL (11, 2) NULL,
    [agstm_sst_on_fet]       DECIMAL (11, 2) NULL,
    [agstm_sst_on_set]       DECIMAL (11, 2) NULL,
    [agstm_sst_on_lc1]       DECIMAL (11, 2) NULL,
    [agstm_sst_on_lc2]       DECIMAL (11, 2) NULL,
    [agstm_sst_on_lc3]       DECIMAL (11, 2) NULL,
    [agstm_sst_on_lc4]       DECIMAL (11, 2) NULL,
    [agstm_sst_on_lc5]       DECIMAL (11, 2) NULL,
    [agstm_sst_on_lc6]       DECIMAL (11, 2) NULL,
    [agstm_lc1_amt]          DECIMAL (11, 2) NULL,
    [agstm_lc1_rt]           DECIMAL (9, 6)  NULL,
    [agstm_lc1_pu]           CHAR (1)        NULL,
    [agstm_lc1_on_net]       DECIMAL (11, 2) NULL,
    [agstm_lc1_on_fet]       DECIMAL (11, 2) NULL,
    [agstm_lc2_amt]          DECIMAL (11, 2) NULL,
    [agstm_lc2_rt]           DECIMAL (9, 6)  NULL,
    [agstm_lc2_pu]           CHAR (1)        NULL,
    [agstm_lc2_on_net]       DECIMAL (11, 2) NULL,
    [agstm_lc2_on_fet]       DECIMAL (11, 2) NULL,
    [agstm_lc3_amt]          DECIMAL (11, 2) NULL,
    [agstm_lc3_rt]           DECIMAL (9, 6)  NULL,
    [agstm_lc3_pu]           CHAR (1)        NULL,
    [agstm_lc3_on_net]       DECIMAL (11, 2) NULL,
    [agstm_lc3_on_fet]       DECIMAL (11, 2) NULL,
    [agstm_lc4_amt]          DECIMAL (11, 2) NULL,
    [agstm_lc4_rt]           DECIMAL (9, 6)  NULL,
    [agstm_lc4_pu]           CHAR (1)        NULL,
    [agstm_lc4_on_net]       DECIMAL (11, 2) NULL,
    [agstm_lc4_on_fet]       DECIMAL (11, 2) NULL,
    [agstm_lc5_amt]          DECIMAL (11, 2) NULL,
    [agstm_lc5_rt]           DECIMAL (9, 6)  NULL,
    [agstm_lc5_pu]           CHAR (1)        NULL,
    [agstm_lc5_on_net]       DECIMAL (11, 2) NULL,
    [agstm_lc5_on_fet]       DECIMAL (11, 2) NULL,
    [agstm_lc6_amt]          DECIMAL (11, 2) NULL,
    [agstm_lc6_rt]           DECIMAL (9, 6)  NULL,
    [agstm_lc6_pu]           CHAR (1)        NULL,
    [agstm_lc6_on_net]       DECIMAL (11, 2) NULL,
    [agstm_lc6_on_fet]       DECIMAL (11, 2) NULL,
    [agstm_tax_state]        CHAR (2)        NULL,
    [agstm_tax_auth_id1]     CHAR (3)        NULL,
    [agstm_tax_auth_id2]     CHAR (3)        NULL,
    [agstm_sst_ynp]          CHAR (1)        NULL,
    [agstm_sold_to_cus]      CHAR (10)       NULL,
    [agstm_dtl_split_no]     CHAR (4)        NULL,
    [agstm_slsmn_id]         CHAR (3)        NULL,
    [agstm_pkg_sold]         DECIMAL (11, 4) NULL,
    [agstm_pkg_ship]         DECIMAL (11, 4) NULL,
    [agstm_pak_desc]         CHAR (6)        NULL,
    [agstm_un_desc]          CHAR (3)        NULL,
    [agstm_un_per_pak]       DECIMAL (11, 6) NULL,
    [agstm_un_prc]           DECIMAL (11, 5) NULL,
    [agstm_cnt_no]           CHAR (8)        NULL,
    [agstm_ppd_cnt_yndm]     CHAR (1)        NULL,
    [agstm_disc]             DECIMAL (9, 2)  NULL,
    [agstm_outtax_rpt_ynl]   CHAR (1)        NULL,
    [agstm_gl_sls_acct]      DECIMAL (16, 8) NULL,
    [agstm_county]           CHAR (3)        NULL,
    [agstm_ppd_dep_per_un]   DECIMAL (11, 5) NULL,
    [agstm_lot_no_yn]        CHAR (1)        NULL,
    [agstm_load_no]          CHAR (8)        NULL,
    [agstm_applicator_no]    CHAR (10)       NULL,
    [agstm_adj_inv_yn]       CHAR (1)        NULL,
    [agstm_state]            CHAR (2)        NULL,
    [agstm_tank_no]          CHAR (4)        NULL,
    [agstm_lp_pct_full]      SMALLINT        NULL,
    [agstm_un_cost]          DECIMAL (11, 5) NULL,
    [agstm_currency]         CHAR (3)        NULL,
    [agstm_currency_rt]      DECIMAL (15, 8) NULL,
    [agstm_currency_cnt]     CHAR (8)        NULL,
    [agstm_hide_price_ynq]   CHAR (1)        NULL,
    [agstm_wn_xmit_rev_dt]   INT             NULL,
    [agstm_dtl_comments]     CHAR (33)       NULL,
    [agstm_split_cus]        CHAR (10)       NULL,
    [agstm_split_pct]        DECIMAL (7, 4)  NULL,
    [agstm_split_desc]       CHAR (30)       NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agstmmst] PRIMARY KEY NONCLUSTERED ([agstm_bill_to_cus] ASC, [agstm_ivc_no] ASC, [agstm_key_loc_no] ASC, [agstm_line_no] ASC, [agstm_rec_type] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagstmmst0]
    ON [dbo].[agstmmst]([agstm_bill_to_cus] ASC, [agstm_ivc_no] ASC, [agstm_key_loc_no] ASC, [agstm_line_no] ASC, [agstm_rec_type] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagstmmst1]
    ON [dbo].[agstmmst]([agstm_ship_rev_dt] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagstmmst2]
    ON [dbo].[agstmmst]([agstm_itm_no] ASC, [agstm_loc_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agstmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agstmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agstmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agstmmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agstmmst] TO PUBLIC
    AS [dbo];

