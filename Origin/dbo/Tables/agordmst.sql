CREATE TABLE [dbo].[agordmst] (
    [agord_cus_no]          CHAR (10)       NOT NULL,
    [agord_ord_no]          CHAR (8)        NOT NULL,
    [agord_loc_no]          CHAR (3)        NOT NULL,
    [agord_line_no]         SMALLINT        NOT NULL,
    [agord_ivc_no]          CHAR (8)        NOT NULL,
    [agord_batch_no]        SMALLINT        NULL,
    [agord_ord_rev_dt]      INT             NULL,
    [agord_req_ship_rev_dt] INT             NULL,
    [agord_ship_rev_dt]     INT             NULL,
    [agord_type]            CHAR (1)        NULL,
    [agord_bill_to_cus]     CHAR (10)       NULL,
    [agord_bill_to_split]   CHAR (4)        NULL,
    [agord_cash_tendered]   DECIMAL (11, 2) NULL,
    [agord_order_total]     DECIMAL (11, 2) NULL,
    [agord_ship_total]      DECIMAL (11, 2) NULL,
    [agord_disc_total]      DECIMAL (9, 2)  NULL,
    [agord_slsmn_id]        CHAR (3)        NULL,
    [agord_po_no]           CHAR (15)       NOT NULL,
    [agord_terms_cd]        TINYINT         NULL,
    [agord_comments]        CHAR (30)       NULL,
    [agord_ship_type]       CHAR (1)        NULL,
    [agord_srv_chg_cd]      TINYINT         NULL,
    [agord_adj_inv_yn]      CHAR (1)        NULL,
    [agord_tank_no]         CHAR (4)        NULL,
    [agord_lp_pct_full]     SMALLINT        NULL,
    [agord_itm_no]          CHAR (13)       NOT NULL,
    [agord_dtl_comments]    CHAR (33)       NULL,
    [agord_un_prc]          DECIMAL (11, 5) NULL,
    [agord_pkg_sold]        DECIMAL (11, 4) NULL,
    [agord_un_sold]         DECIMAL (11, 4) NULL,
    [agord_fet_amt]         DECIMAL (11, 2) NULL,
    [agord_fet_rt]          DECIMAL (9, 6)  NULL,
    [agord_set_amt]         DECIMAL (11, 2) NULL,
    [agord_set_rt]          DECIMAL (9, 6)  NULL,
    [agord_sst_amt]         DECIMAL (11, 2) NULL,
    [agord_sst_rt]          DECIMAL (9, 6)  NULL,
    [agord_sst_pu]          CHAR (1)        NULL,
    [agord_sst_on_net]      DECIMAL (11, 2) NULL,
    [agord_sst_on_fet]      DECIMAL (11, 2) NULL,
    [agord_sst_on_set]      DECIMAL (11, 2) NULL,
    [agord_sst_on_lc1]      DECIMAL (11, 2) NULL,
    [agord_sst_on_lc2]      DECIMAL (11, 2) NULL,
    [agord_sst_on_lc3]      DECIMAL (11, 2) NULL,
    [agord_sst_on_lc4]      DECIMAL (11, 2) NULL,
    [agord_sst_on_lc5]      DECIMAL (11, 2) NULL,
    [agord_sst_on_lc6]      DECIMAL (11, 2) NULL,
    [agord_lc1_amt]         DECIMAL (11, 2) NULL,
    [agord_lc1_rt]          DECIMAL (9, 6)  NULL,
    [agord_lc1_pu]          CHAR (1)        NULL,
    [agord_lc1_on_net]      DECIMAL (11, 2) NULL,
    [agord_lc1_on_fet]      DECIMAL (11, 2) NULL,
    [agord_lc2_amt]         DECIMAL (11, 2) NULL,
    [agord_lc2_rt]          DECIMAL (9, 6)  NULL,
    [agord_lc2_pu]          CHAR (1)        NULL,
    [agord_lc2_on_net]      DECIMAL (11, 2) NULL,
    [agord_lc2_on_fet]      DECIMAL (11, 2) NULL,
    [agord_lc3_amt]         DECIMAL (11, 2) NULL,
    [agord_lc3_rt]          DECIMAL (9, 6)  NULL,
    [agord_lc3_pu]          CHAR (1)        NULL,
    [agord_lc3_on_net]      DECIMAL (11, 2) NULL,
    [agord_lc3_on_fet]      DECIMAL (11, 2) NULL,
    [agord_lc4_amt]         DECIMAL (11, 2) NULL,
    [agord_lc4_rt]          DECIMAL (9, 6)  NULL,
    [agord_lc4_pu]          CHAR (1)        NULL,
    [agord_lc4_on_net]      DECIMAL (11, 2) NULL,
    [agord_lc4_on_fet]      DECIMAL (11, 2) NULL,
    [agord_lc5_amt]         DECIMAL (11, 2) NULL,
    [agord_lc5_rt]          DECIMAL (9, 6)  NULL,
    [agord_lc5_pu]          CHAR (1)        NULL,
    [agord_lc5_on_net]      DECIMAL (11, 2) NULL,
    [agord_lc5_on_fet]      DECIMAL (11, 2) NULL,
    [agord_lc6_amt]         DECIMAL (11, 2) NULL,
    [agord_lc6_rt]          DECIMAL (9, 6)  NULL,
    [agord_lc6_pu]          CHAR (1)        NULL,
    [agord_lc6_on_net]      DECIMAL (11, 2) NULL,
    [agord_lc6_on_fet]      DECIMAL (11, 2) NULL,
    [agord_pkg_ship]        DECIMAL (11, 4) NULL,
    [agord_un_ship]         DECIMAL (11, 4) NULL,
    [agord_ship_fet_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_fet_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_set_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_set_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_sst_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_sst_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_sst_pu]     CHAR (1)        NULL,
    [ship_sst_on_net]       DECIMAL (11, 2) NULL,
    [ship_sst_on_fet]       DECIMAL (11, 2) NULL,
    [ship_sst_on_set]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc1]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc2]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc3]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc4]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc5]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc6]       DECIMAL (11, 2) NULL,
    [agord_ship_lc1_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_lc1_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_lc1_pu]     CHAR (1)        NULL,
    [ship_lc1_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc1_on_fet]       DECIMAL (11, 2) NULL,
    [agord_ship_lc2_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_lc2_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_lc2_pu]     CHAR (1)        NULL,
    [ship_lc2_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc2_on_fet]       DECIMAL (11, 2) NULL,
    [agord_ship_lc3_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_lc3_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_lc3_pu]     CHAR (1)        NULL,
    [ship_lc3_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc3_on_fet]       DECIMAL (11, 2) NULL,
    [agord_ship_lc4_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_lc4_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_lc4_pu]     CHAR (1)        NULL,
    [ship_lc4_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc4_on_fet]       DECIMAL (11, 2) NULL,
    [agord_ship_lc5_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_lc5_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_lc5_pu]     CHAR (1)        NULL,
    [ship_lc5_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc5_on_fet]       DECIMAL (11, 2) NULL,
    [agord_ship_lc6_amt]    DECIMAL (11, 2) NULL,
    [agord_ship_lc6_rt]     DECIMAL (9, 6)  NULL,
    [agord_ship_lc6_pu]     CHAR (1)        NULL,
    [ship_lc6_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc6_on_fet]       DECIMAL (11, 2) NULL,
    [agord_tax_state]       CHAR (2)        NULL,
    [agord_tax_auth_id1]    CHAR (3)        NULL,
    [agord_tax_auth_id2]    CHAR (3)        NULL,
    [agord_county]          CHAR (3)        NULL,
    [agord_ppd_dep_per_un]  DECIMAL (11, 5) NULL,
    [agord_lot_no_yn]       CHAR (1)        NULL,
    [agord_load_no]         CHAR (8)        NULL,
    [agord_bckord_yn]       CHAR (1)        NULL,
    [agord_cnt_cus_no]      CHAR (10)       NULL,
    [agord_cnt_no]          CHAR (8)        NULL,
    [agord_cnt_line_no]     SMALLINT        NULL,
    [agord_blend_yn]        CHAR (1)        NULL,
    [agord_disc_amt]        DECIMAL (9, 2)  NULL,
    [agord_ppd_cnt_yndm]    CHAR (1)        NULL,
    [agord_gl_acct]         DECIMAL (16, 8) NULL,
    [agord_applicator_no]   CHAR (10)       NULL,
    [agord_acct_stat]       CHAR (1)        NULL,
    [agord_sst_ynp]         CHAR (1)        NULL,
    [agord_un_cost]         DECIMAL (11, 5) NULL,
    [agord_src_sys]         CHAR (3)        NULL,
    [agord_pay_pat_yn]      CHAR (1)        NULL,
    [agord_prc_lvl]         TINYINT         NULL,
    [agord_dlvr_pkup_ind]   CHAR (1)        NULL,
    [agord_currency]        CHAR (3)        NULL,
    [agord_currency_rt]     DECIMAL (15, 8) NULL,
    [agord_currency_cnt]    CHAR (8)        NULL,
    [agord_hide_price_ynq]  CHAR (1)        NULL,
    [agord_order_taker]     CHAR (3)        NULL,
    [agord_xfer_exp_yn]     CHAR (1)        NULL,
    [agord_ingr_on_ivc_yn]  CHAR (1)        NULL,
    [agord_gb_updated_yn]   CHAR (1)        NULL,
    [agord_tm_mtr_read]     DECIMAL (11, 4) NULL,
    [agord_tm_perf_id]      CHAR (3)        NULL,
    [agord_user_id]         CHAR (16)       NULL,
    [agord_user_rev_dt]     INT             NULL,
    [agord_user_time]       INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agordmst] PRIMARY KEY NONCLUSTERED ([agord_cus_no] ASC, [agord_ord_no] ASC, [agord_loc_no] ASC, [agord_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagordmst0]
    ON [dbo].[agordmst]([agord_cus_no] ASC, [agord_ord_no] ASC, [agord_loc_no] ASC, [agord_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagordmst1]
    ON [dbo].[agordmst]([agord_ivc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagordmst2]
    ON [dbo].[agordmst]([agord_po_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagordmst3]
    ON [dbo].[agordmst]([agord_itm_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agordmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agordmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agordmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agordmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agordmst] TO PUBLIC
    AS [dbo];

