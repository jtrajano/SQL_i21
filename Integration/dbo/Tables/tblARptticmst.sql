/****** Object:  Table [dbo].[tblARptticmst]    Script Date: 08/30/2016 06:58:46 ******/
CREATE TABLE [dbo].[tblARptticmst](
	[pttic_cus_no] [char](10) NOT NULL,
	[pttic_tic_no] [char](6) NOT NULL,
	[pttic_line_no] [smallint] NOT NULL,
	[pttic_po_no] [char](15) NOT NULL,
	[pttic_ivc_no] [char](6) NULL,
	[pttic_rev_dt] [int] NULL,
	[pttic_type] [char](1) NULL,
	[pttic_adj_inv_yn] [char](1) NULL,
	[pttic_actual_total] [decimal](11, 2) NULL,
	[pttic_computed_total] [decimal](11, 2) NULL,
	[pttic_ship_total] [decimal](11, 2) NULL,
	[pttic_bill_to_cus_no] [char](10) NULL,
	[pttic_comments] [char](30) NULL,
	[pttic_ship_type] [char](1) NULL,
	[pttic_status_ind] [char](1) NULL,
	[pttic_gl_acct] [decimal](16, 8) NULL,
	[pttic_check_no] [char](6) NULL,
	[pttic_pay_type] [char](3) NULL,
	[pttic_slsmn_id] [char](3) NULL,
	[pttic_lp_pct_full] [smallint] NULL,
	[pttic_pic_printed_yn] [char](1) NULL,
	[pttic_kl_beg_rdg] [decimal](11, 3) NULL,
	[pttic_kl_end_rdg] [decimal](11, 3) NULL,
	[pttic_req_ship_rev_dt] [int] NULL,
	[pttic_ship_rev_dt] [int] NULL,
	[pttic_itm_no] [char](10) NOT NULL,
	[pttic_unit_prc] [decimal](11, 5) NULL,
	[pttic_qty_orig] [decimal](10, 3) NULL,
	[pttic_qty_posted_todate] [decimal](10, 3) NULL,
	[pttic_qty_ship] [decimal](10, 3) NULL,
	[pttic_qty_bckord] [decimal](10, 3) NULL,
	[pttic_fet_amt] [decimal](11, 2) NULL,
	[pttic_set_amt] [decimal](11, 2) NULL,
	[pttic_sst_amt] [decimal](11, 2) NULL,
	[pttic_sst_on_net] [decimal](11, 2) NULL,
	[pttic_sst_on_fet] [decimal](11, 2) NULL,
	[pttic_sst_on_set] [decimal](11, 2) NULL,
	[pttic_sst_on_lc1] [decimal](11, 2) NULL,
	[pttic_sst_on_lc2] [decimal](11, 2) NULL,
	[pttic_sst_on_lc3] [decimal](11, 2) NULL,
	[pttic_sst_on_lc4] [decimal](11, 2) NULL,
	[pttic_sst_on_lc5] [decimal](11, 2) NULL,
	[pttic_sst_on_lc6] [decimal](11, 2) NULL,
	[pttic_sst_on_lc7] [decimal](11, 2) NULL,
	[pttic_sst_on_lc8] [decimal](11, 2) NULL,
	[pttic_sst_on_lc9] [decimal](11, 2) NULL,
	[pttic_sst_on_lc10] [decimal](11, 2) NULL,
	[pttic_sst_on_lc11] [decimal](11, 2) NULL,
	[pttic_sst_on_lc12] [decimal](11, 2) NULL,
	[pttic_lc1_amt] [decimal](11, 2) NULL,
	[pttic_lc2_amt] [decimal](11, 2) NULL,
	[pttic_lc3_amt] [decimal](11, 2) NULL,
	[pttic_lc4_amt] [decimal](11, 2) NULL,
	[pttic_lc5_amt] [decimal](11, 2) NULL,
	[pttic_lc6_amt] [decimal](11, 2) NULL,
	[pttic_lc7_amt] [decimal](11, 2) NULL,
	[pttic_lc8_amt] [decimal](11, 2) NULL,
	[pttic_lc9_amt] [decimal](11, 2) NULL,
	[pttic_lc10_amt] [decimal](11, 2) NULL,
	[pttic_lc11_amt] [decimal](11, 2) NULL,
	[pttic_lc12_amt] [decimal](11, 2) NULL,
	[pttic_lc1_on_net] [decimal](11, 2) NULL,
	[pttic_lc1_on_fet] [decimal](11, 2) NULL,
	[pttic_lc2_on_net] [decimal](11, 2) NULL,
	[pttic_lc2_on_fet] [decimal](11, 2) NULL,
	[pttic_lc3_on_net] [decimal](11, 2) NULL,
	[pttic_lc3_on_fet] [decimal](11, 2) NULL,
	[pttic_lc4_on_net] [decimal](11, 2) NULL,
	[pttic_lc4_on_fet] [decimal](11, 2) NULL,
	[pttic_lc5_on_net] [decimal](11, 2) NULL,
	[pttic_lc5_on_fet] [decimal](11, 2) NULL,
	[pttic_lc6_on_net] [decimal](11, 2) NULL,
	[pttic_lc6_on_fet] [decimal](11, 2) NULL,
	[pttic_lc7_on_net] [decimal](11, 2) NULL,
	[pttic_lc7_on_fet] [decimal](11, 2) NULL,
	[pttic_lc8_on_net] [decimal](11, 2) NULL,
	[pttic_lc8_on_fet] [decimal](11, 2) NULL,
	[pttic_lc9_on_net] [decimal](11, 2) NULL,
	[pttic_lc9_on_fet] [decimal](11, 2) NULL,
	[pttic_lc10_on_net] [decimal](11, 2) NULL,
	[pttic_lc10_on_fet] [decimal](11, 2) NULL,
	[pttic_lc11_on_net] [decimal](11, 2) NULL,
	[pttic_lc11_on_fet] [decimal](11, 2) NULL,
	[pttic_lc12_on_net] [decimal](11, 2) NULL,
	[pttic_lc12_on_fet] [decimal](11, 2) NULL,
	[pttic_ship_fet_amt] [decimal](11, 2) NULL,
	[pttic_ship_set_amt] [decimal](11, 2) NULL,
	[pttic_ship_sst_amt] [decimal](11, 2) NULL,
	[ship_sst_on_net] [decimal](11, 2) NULL,
	[ship_sst_on_fet] [decimal](11, 2) NULL,
	[ship_sst_on_set] [decimal](11, 2) NULL,
	[ship_sst_on_lc1] [decimal](11, 2) NULL,
	[ship_sst_on_lc2] [decimal](11, 2) NULL,
	[ship_sst_on_lc3] [decimal](11, 2) NULL,
	[ship_sst_on_lc4] [decimal](11, 2) NULL,
	[ship_sst_on_lc5] [decimal](11, 2) NULL,
	[ship_sst_on_lc6] [decimal](11, 2) NULL,
	[ship_sst_on_lc7] [decimal](11, 2) NULL,
	[ship_sst_on_lc8] [decimal](11, 2) NULL,
	[ship_sst_on_lc9] [decimal](11, 2) NULL,
	[ship_sst_on_lc10] [decimal](11, 2) NULL,
	[ship_sst_on_lc11] [decimal](11, 2) NULL,
	[ship_sst_on_lc12] [decimal](11, 2) NULL,
	[pttic_ship_lc1_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc2_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc3_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc4_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc5_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc6_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc7_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc8_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc9_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc10_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc11_amt] [decimal](11, 2) NULL,
	[pttic_ship_lc12_amt] [decimal](11, 2) NULL,
	[ship_lc1_on_net] [decimal](11, 2) NULL,
	[ship_lc1_on_fet] [decimal](11, 2) NULL,
	[ship_lc2_on_net] [decimal](11, 2) NULL,
	[ship_lc2_on_fet] [decimal](11, 2) NULL,
	[ship_lc3_on_net] [decimal](11, 2) NULL,
	[ship_lc3_on_fet] [decimal](11, 2) NULL,
	[ship_lc4_on_net] [decimal](11, 2) NULL,
	[ship_lc4_on_fet] [decimal](11, 2) NULL,
	[ship_lc5_on_net] [decimal](11, 2) NULL,
	[ship_lc5_on_fet] [decimal](11, 2) NULL,
	[ship_lc6_on_net] [decimal](11, 2) NULL,
	[ship_lc6_on_fet] [decimal](11, 2) NULL,
	[ship_lc7_on_net] [decimal](11, 2) NULL,
	[ship_lc7_on_fet] [decimal](11, 2) NULL,
	[ship_lc8_on_net] [decimal](11, 2) NULL,
	[ship_lc8_on_fet] [decimal](11, 2) NULL,
	[ship_lc9_on_net] [decimal](11, 2) NULL,
	[ship_lc9_on_fet] [decimal](11, 2) NULL,
	[ship_lc10_on_net] [decimal](11, 2) NULL,
	[ship_lc10_on_fet] [decimal](11, 2) NULL,
	[ship_lc11_on_net] [decimal](11, 2) NULL,
	[ship_lc11_on_fet] [decimal](11, 2) NULL,
	[ship_lc12_on_net] [decimal](11, 2) NULL,
	[ship_lc12_on_fet] [decimal](11, 2) NULL,
	[pttic_tax_key] [char](18) NULL,
	[pttic_tax_cls_id] [char](2) NULL,
	[pttic_disc_amt] [decimal](11, 2) NULL,
	[pttic_disc_days] [smallint] NULL,
	[pttic_terms_disc_amt] [decimal](11, 2) NULL,
	[pttic_terms_disc_days] [smallint] NULL,
	[pttic_acct_stat] [char](1) NULL,
	[pttic_src_sys] [char](1) NULL,
	[pttic_batch_no] [tinyint] NULL,
	[pttic_delete_ind] [char](1) NULL,
	[pttic_release_no] [char](15) NULL,
	[pttic_received_by] [char](20) NULL,
	[pttic_carrier_key] [char](10) NULL,
	[pttic_trk_id] [char](3) NULL,
	[pttic_terms_code] [tinyint] NULL,
	[pttic_itm_loc_no] [char](3) NULL,
	[pttic_bln_ovride_yn] [char](1) NULL,
	[pttic_cash_tendered] [decimal](11, 2) NULL,
	[pttic_cnt_cus_no] [char](10) NULL,
	[pttic_cnt_no] [char](6) NULL,
	[pttic_cnt_line_no] [smallint] NULL,
	[pttic_ppd_cnt_ynd] [char](1) NULL,
	[pttic_csn_rpt_tax_yn] [char](1) NULL,
	[pttic_tic_status] [char](1) NULL,
	[pttic_dlvry_pickup_ind] [char](1) NULL,
	[pttic_sst_exempt_pct] [decimal](6, 5) NULL,
	[pttic_set_exempt_pct] [decimal](6, 5) NULL,
	[pttic_sst_exempt_qty] [decimal](10, 3) NULL,
	[pttic_set_exempt_qty] [decimal](10, 3) NULL,
	[pttic_hold_reason] [char](2) NULL,
	[pttic_hold_notify] [char](1) NULL,
	[pttic_computed_prepaid] [decimal](11, 2) NULL,
	[pttic_ship_prepaid] [decimal](11, 2) NULL,
	[pttic_itm_disc_amt] [decimal](7, 2) NULL,
	[pttic_sst_tax_dols] [decimal](9, 2) NULL,
	[pttic_sst_exempt_dols] [decimal](9, 2) NULL,
	[pttic_sst_exempt_inc_dols] [decimal](9, 2) NULL,
	[pttic_sst_exempt_inc_qty] [decimal](8, 3) NULL,
	[pttic_tm_mtr_read] [decimal](11, 4) NULL,
	[pttic_tm_perf_id] [char](3) NULL,
	[pttic_tank_no] [smallint] NULL,
	[pttic_cnt_cus_type] [char](1) NULL,
	[pttic_bol_no] [char](15) NULL,
	[pttic_driver_no] [char](3) NULL,
	[pttic_quote_ref_no] [char](8) NULL,
	[pttic_vnd_no] [char](10) NULL,
	[pttic_prc_on_tr_dly] [char](1) NULL,
	[pttic_ord_rack_time] [smallint] NULL,
	[pttic_dtl_comments] [char](35) NULL,
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

ALTER TABLE [dbo].[tblARptticmst] ADD  DEFAULT (getdate()) FOR [dtmDateImported]
GO


