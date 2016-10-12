/****** Object:  Table [dbo].[tblARagordmst]    Script Date: 08/30/2016 06:58:46 ******/
CREATE TABLE [dbo].[tblARagordmst](
	[agord_cus_no] [char](10) NOT NULL,
	[agord_ord_no] [char](8) NOT NULL,
	[agord_loc_no] [char](3) NOT NULL,
	[agord_line_no] [smallint] NOT NULL,
	[agord_ivc_no] [char](8) NOT NULL,
	[agord_batch_no] [smallint] NULL,
	[agord_ord_rev_dt] [int] NULL,
	[agord_req_ship_rev_dt] [int] NULL,
	[agord_ship_rev_dt] [int] NULL,
	[agord_type] [char](1) NULL,
	[agord_bill_to_cus] [char](10) NULL,
	[agord_bill_to_split] [char](4) NULL,
	[agord_cash_tendered] [decimal](11, 2) NULL,
	[agord_order_total] [decimal](11, 2) NULL,
	[agord_ship_total] [decimal](11, 2) NULL,
	[agord_disc_total] [decimal](9, 2) NULL,
	[agord_slsmn_id] [char](3) NULL,
	[agord_po_no] [char](15) NOT NULL,
	[agord_terms_cd] [tinyint] NULL,
	[agord_comments] [char](30) NULL,
	[agord_ship_type] [char](1) NULL,
	[agord_srv_chg_cd] [tinyint] NULL,
	[agord_adj_inv_yn] [char](1) NULL,
	[agord_tank_no] [char](4) NULL,
	[agord_lp_pct_full] [smallint] NULL,
	[agord_itm_no] [char](13) NOT NULL,
	[agord_dtl_comments] [char](33) NULL,
	[agord_un_prc] [decimal](11, 5) NULL,
	[agord_pkg_sold] [decimal](11, 4) NULL,
	[agord_un_sold] [decimal](11, 4) NULL,
	[agord_fet_amt] [decimal](11, 2) NULL,
	[agord_fet_rt] [decimal](9, 6) NULL,
	[agord_set_amt] [decimal](11, 2) NULL,
	[agord_set_rt] [decimal](9, 6) NULL,
	[agord_sst_amt] [decimal](11, 2) NULL,
	[agord_sst_rt] [decimal](9, 6) NULL,
	[agord_sst_pu] [char](1) NULL,
	[agord_sst_on_net] [decimal](11, 2) NULL,
	[agord_sst_on_fet] [decimal](11, 2) NULL,
	[agord_sst_on_set] [decimal](11, 2) NULL,
	[agord_sst_on_lc1] [decimal](11, 2) NULL,
	[agord_sst_on_lc2] [decimal](11, 2) NULL,
	[agord_sst_on_lc3] [decimal](11, 2) NULL,
	[agord_sst_on_lc4] [decimal](11, 2) NULL,
	[agord_sst_on_lc5] [decimal](11, 2) NULL,
	[agord_sst_on_lc6] [decimal](11, 2) NULL,
	[agord_lc1_amt] [decimal](11, 2) NULL,
	[agord_lc1_rt] [decimal](9, 6) NULL,
	[agord_lc1_pu] [char](1) NULL,
	[agord_lc1_on_net] [decimal](11, 2) NULL,
	[agord_lc1_on_fet] [decimal](11, 2) NULL,
	[agord_lc2_amt] [decimal](11, 2) NULL,
	[agord_lc2_rt] [decimal](9, 6) NULL,
	[agord_lc2_pu] [char](1) NULL,
	[agord_lc2_on_net] [decimal](11, 2) NULL,
	[agord_lc2_on_fet] [decimal](11, 2) NULL,
	[agord_lc3_amt] [decimal](11, 2) NULL,
	[agord_lc3_rt] [decimal](9, 6) NULL,
	[agord_lc3_pu] [char](1) NULL,
	[agord_lc3_on_net] [decimal](11, 2) NULL,
	[agord_lc3_on_fet] [decimal](11, 2) NULL,
	[agord_lc4_amt] [decimal](11, 2) NULL,
	[agord_lc4_rt] [decimal](9, 6) NULL,
	[agord_lc4_pu] [char](1) NULL,
	[agord_lc4_on_net] [decimal](11, 2) NULL,
	[agord_lc4_on_fet] [decimal](11, 2) NULL,
	[agord_lc5_amt] [decimal](11, 2) NULL,
	[agord_lc5_rt] [decimal](9, 6) NULL,
	[agord_lc5_pu] [char](1) NULL,
	[agord_lc5_on_net] [decimal](11, 2) NULL,
	[agord_lc5_on_fet] [decimal](11, 2) NULL,
	[agord_lc6_amt] [decimal](11, 2) NULL,
	[agord_lc6_rt] [decimal](9, 6) NULL,
	[agord_lc6_pu] [char](1) NULL,
	[agord_lc6_on_net] [decimal](11, 2) NULL,
	[agord_lc6_on_fet] [decimal](11, 2) NULL,
	[agord_pkg_ship] [decimal](11, 4) NULL,
	[agord_un_ship] [decimal](11, 4) NULL,
	[agord_ship_fet_amt] [decimal](11, 2) NULL,
	[agord_ship_fet_rt] [decimal](9, 6) NULL,
	[agord_ship_set_amt] [decimal](11, 2) NULL,
	[agord_ship_set_rt] [decimal](9, 6) NULL,
	[agord_ship_sst_amt] [decimal](11, 2) NULL,
	[agord_ship_sst_rt] [decimal](9, 6) NULL,
	[agord_ship_sst_pu] [char](1) NULL,
	[ship_sst_on_net] [decimal](11, 2) NULL,
	[ship_sst_on_fet] [decimal](11, 2) NULL,
	[ship_sst_on_set] [decimal](11, 2) NULL,
	[ship_sst_on_lc1] [decimal](11, 2) NULL,
	[ship_sst_on_lc2] [decimal](11, 2) NULL,
	[ship_sst_on_lc3] [decimal](11, 2) NULL,
	[ship_sst_on_lc4] [decimal](11, 2) NULL,
	[ship_sst_on_lc5] [decimal](11, 2) NULL,
	[ship_sst_on_lc6] [decimal](11, 2) NULL,
	[agord_ship_lc1_amt] [decimal](11, 2) NULL,
	[agord_ship_lc1_rt] [decimal](9, 6) NULL,
	[agord_ship_lc1_pu] [char](1) NULL,
	[ship_lc1_on_net] [decimal](11, 2) NULL,
	[ship_lc1_on_fet] [decimal](11, 2) NULL,
	[agord_ship_lc2_amt] [decimal](11, 2) NULL,
	[agord_ship_lc2_rt] [decimal](9, 6) NULL,
	[agord_ship_lc2_pu] [char](1) NULL,
	[ship_lc2_on_net] [decimal](11, 2) NULL,
	[ship_lc2_on_fet] [decimal](11, 2) NULL,
	[agord_ship_lc3_amt] [decimal](11, 2) NULL,
	[agord_ship_lc3_rt] [decimal](9, 6) NULL,
	[agord_ship_lc3_pu] [char](1) NULL,
	[ship_lc3_on_net] [decimal](11, 2) NULL,
	[ship_lc3_on_fet] [decimal](11, 2) NULL,
	[agord_ship_lc4_amt] [decimal](11, 2) NULL,
	[agord_ship_lc4_rt] [decimal](9, 6) NULL,
	[agord_ship_lc4_pu] [char](1) NULL,
	[ship_lc4_on_net] [decimal](11, 2) NULL,
	[ship_lc4_on_fet] [decimal](11, 2) NULL,
	[agord_ship_lc5_amt] [decimal](11, 2) NULL,
	[agord_ship_lc5_rt] [decimal](9, 6) NULL,
	[agord_ship_lc5_pu] [char](1) NULL,
	[ship_lc5_on_net] [decimal](11, 2) NULL,
	[ship_lc5_on_fet] [decimal](11, 2) NULL,
	[agord_ship_lc6_amt] [decimal](11, 2) NULL,
	[agord_ship_lc6_rt] [decimal](9, 6) NULL,
	[agord_ship_lc6_pu] [char](1) NULL,
	[ship_lc6_on_net] [decimal](11, 2) NULL,
	[ship_lc6_on_fet] [decimal](11, 2) NULL,
	[agord_tax_state] [char](2) NULL,
	[agord_tax_auth_id1] [char](3) NULL,
	[agord_tax_auth_id2] [char](3) NULL,
	[agord_county] [char](3) NULL,
	[agord_ppd_dep_per_un] [decimal](11, 5) NULL,
	[agord_lot_no_yn] [char](1) NULL,
	[agord_load_no] [char](8) NULL,
	[agord_bckord_yn] [char](1) NULL,
	[agord_cnt_cus_no] [char](10) NULL,
	[agord_cnt_no] [char](8) NULL,
	[agord_cnt_line_no] [smallint] NULL,
	[agord_blend_yn] [char](1) NULL,
	[agord_disc_amt] [decimal](9, 2) NULL,
	[agord_ppd_cnt_yndm] [char](1) NULL,
	[agord_gl_acct] [decimal](16, 8) NULL,
	[agord_applicator_no] [char](10) NULL,
	[agord_acct_stat] [char](1) NULL,
	[agord_sst_ynp] [char](1) NULL,
	[agord_un_cost] [decimal](11, 5) NULL,
	[agord_src_sys] [char](3) NULL,
	[agord_pay_pat_yn] [char](1) NULL,
	[agord_prc_lvl] [tinyint] NULL,
	[agord_dlvr_pkup_ind] [char](1) NULL,
	[agord_currency] [char](3) NULL,
	[agord_currency_rt] [decimal](15, 8) NULL,
	[agord_currency_cnt] [char](8) NULL,
	[agord_hide_price_ynq] [char](1) NULL,
	[agord_order_taker] [char](3) NULL,
	[agord_xfer_exp_yn] [char](1) NULL,
	[agord_ingr_on_ivc_yn] [char](1) NULL,
	[agord_gb_updated_yn] [char](1) NULL,
	[agord_tm_mtr_read] [decimal](11, 4) NULL,
	[agord_tm_perf_id] [char](3) NULL,
	[agord_nutri_file_name] [char](50) NULL,
	[agord_user_id] [char](16) NULL,
	[agord_user_rev_dt] [int] NULL,
	[agord_user_time] [int] NULL,
	[agord_no_of_months] [tinyint] NULL,
	[agord_final_due_dt] [int] NULL,	
	[A4GLIdentity] [numeric](9, 0) NOT NULL,
	[intInvoiceId] [int] NULL,
	[dtmDateImported] [datetime] NOT NULL,
	[intId] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[intId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblARagordmst] ADD  DEFAULT (getdate()) FOR [dtmDateImported]
GO


