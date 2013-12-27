CREATE TABLE [dbo].[agocamst] (
    [agoca_cus_no]          CHAR (10)       NOT NULL,
    [agoca_ord_no]          CHAR (8)        NOT NULL,
    [agoca_loc_no]          CHAR (3)        NOT NULL,
    [agoca_line_no]         SMALLINT        NOT NULL,
    [agoca_stamp_rev_dt]    INT             NOT NULL,
    [agoca_stamp_time]      INT             NOT NULL,
    [agoca_ivc_no]          CHAR (8)        NULL,
    [agoca_batch_no]        SMALLINT        NULL,
    [agoca_ord_rev_dt]      INT             NULL,
    [agoca_req_ship_rev_dt] INT             NULL,
    [agoca_ship_rev_dt]     INT             NULL,
    [agoca_type]            CHAR (1)        NULL,
    [agoca_bill_to_cus]     CHAR (10)       NULL,
    [agoca_bill_to_split]   CHAR (4)        NULL,
    [agoca_cash_tendered]   DECIMAL (11, 2) NULL,
    [agoca_order_total]     DECIMAL (11, 2) NULL,
    [agoca_ship_total]      DECIMAL (11, 2) NULL,
    [agoca_disc_total]      DECIMAL (9, 2)  NULL,
    [agoca_slsmn_id]        CHAR (3)        NULL,
    [agoca_po_no]           CHAR (15)       NULL,
    [agoca_terms_cd]        TINYINT         NULL,
    [agoca_comments]        CHAR (30)       NULL,
    [agoca_ship_type]       CHAR (1)        NULL,
    [agoca_srv_chg_cd]      TINYINT         NULL,
    [agoca_adj_inv_yn]      CHAR (1)        NULL,
    [agoca_tank_no]         CHAR (4)        NULL,
    [agoca_lp_pct_full]     SMALLINT        NULL,
    [agoca_itm_no]          CHAR (13)       NULL,
    [agoca_dtl_comments]    CHAR (33)       NULL,
    [agoca_un_prc]          DECIMAL (11, 5) NULL,
    [agoca_pkg_sold]        DECIMAL (11, 4) NULL,
    [agoca_un_sold]         DECIMAL (11, 4) NULL,
    [agoca_fet_amt]         DECIMAL (11, 2) NULL,
    [agoca_fet_rt]          DECIMAL (9, 6)  NULL,
    [agoca_set_amt]         DECIMAL (11, 2) NULL,
    [agoca_set_rt]          DECIMAL (9, 6)  NULL,
    [agoca_sst_amt]         DECIMAL (11, 2) NULL,
    [agoca_sst_rt]          DECIMAL (9, 6)  NULL,
    [agoca_sst_pu]          CHAR (1)        NULL,
    [agoca_sst_on_net]      DECIMAL (11, 2) NULL,
    [agoca_sst_on_fet]      DECIMAL (11, 2) NULL,
    [agoca_sst_on_set]      DECIMAL (11, 2) NULL,
    [agoca_sst_on_lc1]      DECIMAL (11, 2) NULL,
    [agoca_sst_on_lc2]      DECIMAL (11, 2) NULL,
    [agoca_sst_on_lc3]      DECIMAL (11, 2) NULL,
    [agoca_sst_on_lc4]      DECIMAL (11, 2) NULL,
    [agoca_sst_on_lc5]      DECIMAL (11, 2) NULL,
    [agoca_sst_on_lc6]      DECIMAL (11, 2) NULL,
    [agoca_lc1_amt]         DECIMAL (11, 2) NULL,
    [agoca_lc1_rt]          DECIMAL (9, 6)  NULL,
    [agoca_lc1_pu]          CHAR (1)        NULL,
    [agoca_lc1_on_net]      DECIMAL (11, 2) NULL,
    [agoca_lc1_on_fet]      DECIMAL (11, 2) NULL,
    [agoca_lc2_amt]         DECIMAL (11, 2) NULL,
    [agoca_lc2_rt]          DECIMAL (9, 6)  NULL,
    [agoca_lc2_pu]          CHAR (1)        NULL,
    [agoca_lc2_on_net]      DECIMAL (11, 2) NULL,
    [agoca_lc2_on_fet]      DECIMAL (11, 2) NULL,
    [agoca_lc3_amt]         DECIMAL (11, 2) NULL,
    [agoca_lc3_rt]          DECIMAL (9, 6)  NULL,
    [agoca_lc3_pu]          CHAR (1)        NULL,
    [agoca_lc3_on_net]      DECIMAL (11, 2) NULL,
    [agoca_lc3_on_fet]      DECIMAL (11, 2) NULL,
    [agoca_lc4_amt]         DECIMAL (11, 2) NULL,
    [agoca_lc4_rt]          DECIMAL (9, 6)  NULL,
    [agoca_lc4_pu]          CHAR (1)        NULL,
    [agoca_lc4_on_net]      DECIMAL (11, 2) NULL,
    [agoca_lc4_on_fet]      DECIMAL (11, 2) NULL,
    [agoca_lc5_amt]         DECIMAL (11, 2) NULL,
    [agoca_lc5_rt]          DECIMAL (9, 6)  NULL,
    [agoca_lc5_pu]          CHAR (1)        NULL,
    [agoca_lc5_on_net]      DECIMAL (11, 2) NULL,
    [agoca_lc5_on_fet]      DECIMAL (11, 2) NULL,
    [agoca_lc6_amt]         DECIMAL (11, 2) NULL,
    [agoca_lc6_rt]          DECIMAL (9, 6)  NULL,
    [agoca_lc6_pu]          CHAR (1)        NULL,
    [agoca_lc6_on_net]      DECIMAL (11, 2) NULL,
    [agoca_lc6_on_fet]      DECIMAL (11, 2) NULL,
    [agoca_pkg_ship]        DECIMAL (11, 4) NULL,
    [agoca_un_ship]         DECIMAL (11, 4) NULL,
    [agoca_ship_fet_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_fet_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_set_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_set_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_sst_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_sst_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_sst_pu]     CHAR (1)        NULL,
    [ship_sst_on_net]       DECIMAL (11, 2) NULL,
    [ship_sst_on_fet]       DECIMAL (11, 2) NULL,
    [ship_sst_on_set]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc1]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc2]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc3]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc4]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc5]       DECIMAL (11, 2) NULL,
    [ship_sst_on_lc6]       DECIMAL (11, 2) NULL,
    [agoca_ship_lc1_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_lc1_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_lc1_pu]     CHAR (1)        NULL,
    [ship_lc1_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc1_on_fet]       DECIMAL (11, 2) NULL,
    [agoca_ship_lc2_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_lc2_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_lc2_pu]     CHAR (1)        NULL,
    [ship_lc2_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc2_on_fet]       DECIMAL (11, 2) NULL,
    [agoca_ship_lc3_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_lc3_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_lc3_pu]     CHAR (1)        NULL,
    [ship_lc3_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc3_on_fet]       DECIMAL (11, 2) NULL,
    [agoca_ship_lc4_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_lc4_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_lc4_pu]     CHAR (1)        NULL,
    [ship_lc4_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc4_on_fet]       DECIMAL (11, 2) NULL,
    [agoca_ship_lc5_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_lc5_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_lc5_pu]     CHAR (1)        NULL,
    [ship_lc5_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc5_on_fet]       DECIMAL (11, 2) NULL,
    [agoca_ship_lc6_amt]    DECIMAL (11, 2) NULL,
    [agoca_ship_lc6_rt]     DECIMAL (9, 6)  NULL,
    [agoca_ship_lc6_pu]     CHAR (1)        NULL,
    [ship_lc6_on_net]       DECIMAL (11, 2) NULL,
    [ship_lc6_on_fet]       DECIMAL (11, 2) NULL,
    [agoca_tax_state]       CHAR (2)        NULL,
    [agoca_tax_auth_id1]    CHAR (3)        NULL,
    [agoca_tax_auth_id2]    CHAR (3)        NULL,
    [agoca_county]          CHAR (3)        NULL,
    [agoca_ppd_dep_per_un]  DECIMAL (11, 5) NULL,
    [agoca_lot_no_yn]       CHAR (1)        NULL,
    [agoca_load_no]         CHAR (8)        NULL,
    [agoca_bckord_yn]       CHAR (1)        NULL,
    [agoca_cnt_cus_no]      CHAR (10)       NULL,
    [agoca_cnt_no]          CHAR (8)        NULL,
    [agoca_cnt_line_no]     SMALLINT        NULL,
    [agoca_blend_yn]        CHAR (1)        NULL,
    [agoca_disc_amt]        DECIMAL (9, 2)  NULL,
    [agoca_ppd_cnt_yndm]    CHAR (1)        NULL,
    [agoca_gl_acct]         DECIMAL (16, 8) NULL,
    [agoca_applicator_no]   CHAR (10)       NULL,
    [agoca_acct_stat]       CHAR (1)        NULL,
    [agoca_sst_ynp]         CHAR (1)        NULL,
    [agoca_un_cost]         DECIMAL (11, 5) NULL,
    [agoca_src_sys]         CHAR (3)        NULL,
    [agoca_pay_pat_yn]      CHAR (1)        NULL,
    [agoca_prc_lvl]         TINYINT         NULL,
    [agoca_dlvr_pkup_ind]   CHAR (1)        NULL,
    [agoca_currency]        CHAR (3)        NULL,
    [agoca_currency_rt]     DECIMAL (15, 8) NULL,
    [agoca_currency_cnt]    CHAR (8)        NULL,
    [agoca_hide_price_ynq]  CHAR (1)        NULL,
    [agoca_order_taker]     CHAR (3)        NULL,
    [agoca_xfer_exp_yn]     CHAR (1)        NULL,
    [agoca_ingr_on_ivc_yn]  CHAR (1)        NULL,
    [agoca_gb_updated_yn]   CHAR (1)        NULL,
    [agoca_audit_cd]        CHAR (1)        NULL,
    [agoca_user_id]         CHAR (10)       NULL,
    [agoca_user_rev_dt]     INT             NULL,
    [agoca_user_time]       INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agocamst] PRIMARY KEY NONCLUSTERED ([agoca_cus_no] ASC, [agoca_ord_no] ASC, [agoca_loc_no] ASC, [agoca_line_no] ASC, [agoca_stamp_rev_dt] ASC, [agoca_stamp_time] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagocamst0]
    ON [dbo].[agocamst]([agoca_cus_no] ASC, [agoca_ord_no] ASC, [agoca_loc_no] ASC, [agoca_line_no] ASC, [agoca_stamp_rev_dt] ASC, [agoca_stamp_time] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagocamst1]
    ON [dbo].[agocamst]([agoca_stamp_rev_dt] ASC, [agoca_stamp_time] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agocamst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agocamst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agocamst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agocamst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agocamst] TO PUBLIC
    AS [dbo];

