/****** Object:  StoredProcedure [dbo].[uspARImportInvoiceBackupPTTICMST]    Script Date: 08/11/2016 07:38:16 ******/
CREATE PROCEDURE [dbo].[uspARImportInvoiceBackupPTTICMST]
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@totalptticmst INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;

IF @transCount = 0 BEGIN TRANSACTION

--BACK UP ptticmst
IF OBJECT_ID('dbo.tmp_ptticmstImport') IS NOT NULL DROP TABLE tmp_ptticmstImport

CREATE TABLE tmp_ptticmstImport(
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
	[intBackupId]			INT NULL, --Use this to update the linking between the back up and created voucher
	[intId]			INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [k_tmpptticmst] PRIMARY KEY NONCLUSTERED (
			[pttic_cus_no] ASC,
			[pttic_tic_no] ASC,
			[pttic_line_no] ASC
	)
)

--BACK UP RECORDS TO BE IMPORTED FROM ptticmst
IF @DateFrom IS NULL --ONE TIME IMPORT
BEGIN
	INSERT INTO tmp_ptticmstImport
	(       [pttic_cus_no]
           ,[pttic_tic_no]
           ,[pttic_line_no]
           ,[pttic_po_no]
           ,[pttic_ivc_no]
           ,[pttic_rev_dt]
           ,[pttic_type]
           ,[pttic_adj_inv_yn]
           ,[pttic_actual_total]
           ,[pttic_computed_total]
           ,[pttic_ship_total]
           ,[pttic_bill_to_cus_no]
           ,[pttic_comments]
           ,[pttic_ship_type]
           ,[pttic_status_ind]
           ,[pttic_gl_acct]
           ,[pttic_check_no]
           ,[pttic_pay_type]
           ,[pttic_slsmn_id]
           ,[pttic_lp_pct_full]
           ,[pttic_pic_printed_yn]
           ,[pttic_kl_beg_rdg]
           ,[pttic_kl_end_rdg]
           ,[pttic_req_ship_rev_dt]
           ,[pttic_ship_rev_dt]
           ,[pttic_itm_no]
           ,[pttic_unit_prc]
           ,[pttic_qty_orig]
           ,[pttic_qty_posted_todate]
           ,[pttic_qty_ship]
           ,[pttic_qty_bckord]
           ,[pttic_fet_amt]
           ,[pttic_set_amt]
           ,[pttic_sst_amt]
           ,[pttic_sst_on_net]
           ,[pttic_sst_on_fet]
           ,[pttic_sst_on_set]
           ,[pttic_sst_on_lc1]
           ,[pttic_sst_on_lc2]
           ,[pttic_sst_on_lc3]
           ,[pttic_sst_on_lc4]
           ,[pttic_sst_on_lc5]
           ,[pttic_sst_on_lc6]
           ,[pttic_sst_on_lc7]
           ,[pttic_sst_on_lc8]
           ,[pttic_sst_on_lc9]
           ,[pttic_sst_on_lc10]
           ,[pttic_sst_on_lc11]
           ,[pttic_sst_on_lc12]
           ,[pttic_lc1_amt]
           ,[pttic_lc2_amt]
           ,[pttic_lc3_amt]
           ,[pttic_lc4_amt]
           ,[pttic_lc5_amt]
           ,[pttic_lc6_amt]
           ,[pttic_lc7_amt]
           ,[pttic_lc8_amt]
           ,[pttic_lc9_amt]
           ,[pttic_lc10_amt]
           ,[pttic_lc11_amt]
           ,[pttic_lc12_amt]
           ,[pttic_lc1_on_net]
           ,[pttic_lc1_on_fet]
           ,[pttic_lc2_on_net]
           ,[pttic_lc2_on_fet]
           ,[pttic_lc3_on_net]
           ,[pttic_lc3_on_fet]
           ,[pttic_lc4_on_net]
           ,[pttic_lc4_on_fet]
           ,[pttic_lc5_on_net]
           ,[pttic_lc5_on_fet]
           ,[pttic_lc6_on_net]
           ,[pttic_lc6_on_fet]
           ,[pttic_lc7_on_net]
           ,[pttic_lc7_on_fet]
           ,[pttic_lc8_on_net]
           ,[pttic_lc8_on_fet]
           ,[pttic_lc9_on_net]
           ,[pttic_lc9_on_fet]
           ,[pttic_lc10_on_net]
           ,[pttic_lc10_on_fet]
           ,[pttic_lc11_on_net]
           ,[pttic_lc11_on_fet]
           ,[pttic_lc12_on_net]
           ,[pttic_lc12_on_fet]
           ,[pttic_ship_fet_amt]
           ,[pttic_ship_set_amt]
           ,[pttic_ship_sst_amt]
           ,[ship_sst_on_net]
           ,[ship_sst_on_fet]
           ,[ship_sst_on_set]
           ,[ship_sst_on_lc1]
           ,[ship_sst_on_lc2]
           ,[ship_sst_on_lc3]
           ,[ship_sst_on_lc4]
           ,[ship_sst_on_lc5]
           ,[ship_sst_on_lc6]
           ,[ship_sst_on_lc7]
           ,[ship_sst_on_lc8]
           ,[ship_sst_on_lc9]
           ,[ship_sst_on_lc10]
           ,[ship_sst_on_lc11]
           ,[ship_sst_on_lc12]
           ,[pttic_ship_lc1_amt]
           ,[pttic_ship_lc2_amt]
           ,[pttic_ship_lc3_amt]
           ,[pttic_ship_lc4_amt]
           ,[pttic_ship_lc5_amt]
           ,[pttic_ship_lc6_amt]
           ,[pttic_ship_lc7_amt]
           ,[pttic_ship_lc8_amt]
           ,[pttic_ship_lc9_amt]
           ,[pttic_ship_lc10_amt]
           ,[pttic_ship_lc11_amt]
           ,[pttic_ship_lc12_amt]
           ,[ship_lc1_on_net]
           ,[ship_lc1_on_fet]
           ,[ship_lc2_on_net]
           ,[ship_lc2_on_fet]
           ,[ship_lc3_on_net]
           ,[ship_lc3_on_fet]
           ,[ship_lc4_on_net]
           ,[ship_lc4_on_fet]
           ,[ship_lc5_on_net]
           ,[ship_lc5_on_fet]
           ,[ship_lc6_on_net]
           ,[ship_lc6_on_fet]
           ,[ship_lc7_on_net]
           ,[ship_lc7_on_fet]
           ,[ship_lc8_on_net]
           ,[ship_lc8_on_fet]
           ,[ship_lc9_on_net]
           ,[ship_lc9_on_fet]
           ,[ship_lc10_on_net]
           ,[ship_lc10_on_fet]
           ,[ship_lc11_on_net]
           ,[ship_lc11_on_fet]
           ,[ship_lc12_on_net]
           ,[ship_lc12_on_fet]
           ,[pttic_tax_key]
           ,[pttic_tax_cls_id]
           ,[pttic_disc_amt]
           ,[pttic_disc_days]
           ,[pttic_terms_disc_amt]
           ,[pttic_terms_disc_days]
           ,[pttic_acct_stat]
           ,[pttic_src_sys]
           ,[pttic_batch_no]
           ,[pttic_delete_ind]
           ,[pttic_release_no]
           ,[pttic_received_by]
           ,[pttic_carrier_key]
           ,[pttic_trk_id]
           ,[pttic_terms_code]
           ,[pttic_itm_loc_no]
           ,[pttic_bln_ovride_yn]
           ,[pttic_cash_tendered]
           ,[pttic_cnt_cus_no]
           ,[pttic_cnt_no]
           ,[pttic_cnt_line_no]
           ,[pttic_ppd_cnt_ynd]
           ,[pttic_csn_rpt_tax_yn]
           ,[pttic_tic_status]
           ,[pttic_dlvry_pickup_ind]
           ,[pttic_sst_exempt_pct]
           ,[pttic_set_exempt_pct]
           ,[pttic_sst_exempt_qty]
           ,[pttic_set_exempt_qty]
           ,[pttic_hold_reason]
           ,[pttic_hold_notify]
           ,[pttic_computed_prepaid]
           ,[pttic_ship_prepaid]
           ,[pttic_itm_disc_amt]
           ,[pttic_sst_tax_dols]
           ,[pttic_sst_exempt_dols]
           ,[pttic_sst_exempt_inc_dols]
           ,[pttic_sst_exempt_inc_qty]
           ,[pttic_tm_mtr_read]
           ,[pttic_tm_perf_id]
           ,[pttic_tank_no]
           ,[pttic_cnt_cus_type]
           ,[pttic_bol_no]
           ,[pttic_driver_no]
           ,[pttic_quote_ref_no]
           ,[pttic_vnd_no]
           ,[pttic_prc_on_tr_dly]
           ,[pttic_ord_rack_time]
           ,[pttic_dtl_comments]
           ,[A4GLIdentity])

	SELECT
			[pttic_cus_no]  =   A.[pttic_cus_no],
			[pttic_tic_no]	=   A.[pttic_tic_no],
			[pttic_line_no]	=   A.[pttic_line_no],
			[pttic_po_no]	=   A.[pttic_po_no],
			[pttic_ivc_no]	=   A.[pttic_ivc_no],
			[pttic_rev_dt]	=   A.[pttic_rev_dt],
			[pttic_type]	=   A.[pttic_type],
			[pttic_adj_inv_yn]	=   A.[pttic_adj_inv_yn],
			[pttic_actual_total]	=   A.[pttic_actual_total],
			[pttic_computed_total]	=   A.[pttic_computed_total],
			[pttic_ship_total]	=   A.[pttic_ship_total],
			[pttic_bill_to_cus_no]	=   A.[pttic_bill_to_cus_no],
			[pttic_comments]	=   A.[pttic_comments],
			[pttic_ship_type]	=   A.[pttic_ship_type],
			[pttic_status_ind]	=   A.[pttic_status_ind],
			[pttic_gl_acct]	=   A.[pttic_gl_acct],
			[pttic_check_no]	=   A.[pttic_check_no],
			[pttic_pay_type]	=   A.[pttic_pay_type],
			[pttic_slsmn_id]	=   A.[pttic_slsmn_id],
			[pttic_lp_pct_full]	=   A.[pttic_lp_pct_full],
			[pttic_pic_printed_yn]	=   A.[pttic_pic_printed_yn],
			[pttic_kl_beg_rdg]	=   A.[pttic_kl_beg_rdg],
			[pttic_kl_end_rdg]	=   A.[pttic_kl_end_rdg],
			[pttic_req_ship_rev_dt]	=   A.[pttic_req_ship_rev_dt],
			[pttic_ship_rev_dt]	=   A.[pttic_ship_rev_dt],
			[pttic_itm_no]	=   A.[pttic_itm_no],
			[pttic_unit_prc]	=   A.[pttic_unit_prc],
			[pttic_qty_orig]	=   A.[pttic_qty_orig],
			[pttic_qty_posted_todate]	=   A.[pttic_qty_posted_todate],
			[pttic_qty_ship]	=   A.[pttic_qty_ship],
			[pttic_qty_bckord]	=   A.[pttic_qty_bckord],
			[pttic_fet_amt]	=   A.[pttic_fet_amt],
			[pttic_set_amt]	=   A.[pttic_set_amt],
			[pttic_sst_amt]	=   A.[pttic_sst_amt],
			[pttic_sst_on_net]	=   A.[pttic_sst_on_net],
			[pttic_sst_on_fet]	=   A.[pttic_sst_on_fet],
			[pttic_sst_on_set]	=   A.[pttic_sst_on_set],
			[pttic_sst_on_lc1]	=   A.[pttic_sst_on_lc1],
			[pttic_sst_on_lc2]	=   A.[pttic_sst_on_lc2],
			[pttic_sst_on_lc3]	=   A.[pttic_sst_on_lc3],
			[pttic_sst_on_lc4]	=   A.[pttic_sst_on_lc4],
			[pttic_sst_on_lc5]	=   A.[pttic_sst_on_lc5],
			[pttic_sst_on_lc6]	=   A.[pttic_sst_on_lc6],
			[pttic_sst_on_lc7]	=   A.[pttic_sst_on_lc7],
			[pttic_sst_on_lc8]	=   A.[pttic_sst_on_lc8],
			[pttic_sst_on_lc9]	=   A.[pttic_sst_on_lc9],
			[pttic_sst_on_lc10]	=   A.[pttic_sst_on_lc10],
			[pttic_sst_on_lc11]	=   A.[pttic_sst_on_lc11],
			[pttic_sst_on_lc12]	=   A.[pttic_sst_on_lc12],
			[pttic_lc1_amt]	=   A.[pttic_lc1_amt],
			[pttic_lc2_amt]	=   A.[pttic_lc2_amt],
			[pttic_lc3_amt]	=   A.[pttic_lc3_amt],
			[pttic_lc4_amt]	=   A.[pttic_lc4_amt],
			[pttic_lc5_amt]	=   A.[pttic_lc5_amt],
			[pttic_lc6_amt]	=   A.[pttic_lc6_amt],
			[pttic_lc7_amt]	=   A.[pttic_lc7_amt],
			[pttic_lc8_amt]	=   A.[pttic_lc8_amt],
			[pttic_lc9_amt]	=   A.[pttic_lc9_amt],
			[pttic_lc10_amt]	=   A.[pttic_lc10_amt],
			[pttic_lc11_amt]	=   A.[pttic_lc11_amt],
			[pttic_lc12_amt]	=   A.[pttic_lc12_amt],
			[pttic_lc1_on_net]	=   A.[pttic_lc1_on_net],
			[pttic_lc1_on_fet]	=   A.[pttic_lc1_on_fet],
			[pttic_lc2_on_net]	=   A.[pttic_lc2_on_net],
			[pttic_lc2_on_fet]	=   A.[pttic_lc2_on_fet],
			[pttic_lc3_on_net]	=   A.[pttic_lc3_on_net],
			[pttic_lc3_on_fet]	=   A.[pttic_lc3_on_fet],
			[pttic_lc4_on_net]	=   A.[pttic_lc4_on_net],
			[pttic_lc4_on_fet]	=   A.[pttic_lc4_on_fet],
			[pttic_lc5_on_net]	=   A.[pttic_lc5_on_net],
			[pttic_lc5_on_fet]	=   A.[pttic_lc5_on_fet],
			[pttic_lc6_on_net]	=   A.[pttic_lc6_on_net],
			[pttic_lc6_on_fet]	=   A.[pttic_lc6_on_fet],
			[pttic_lc7_on_net]	=   A.[pttic_lc7_on_net],
			[pttic_lc7_on_fet]	=   A.[pttic_lc7_on_fet],
			[pttic_lc8_on_net]	=   A.[pttic_lc8_on_net],
			[pttic_lc8_on_fet]	=   A.[pttic_lc8_on_fet],
			[pttic_lc9_on_net]	=   A.[pttic_lc9_on_net],
			[pttic_lc9_on_fet]	=   A.[pttic_lc9_on_fet],
			[pttic_lc10_on_net]	=   A.[pttic_lc10_on_net],
			[pttic_lc10_on_fet]	=   A.[pttic_lc10_on_fet],
			[pttic_lc11_on_net]	=   A.[pttic_lc11_on_net],
			[pttic_lc11_on_fet]	=   A.[pttic_lc11_on_fet],
			[pttic_lc12_on_net]	=   A.[pttic_lc12_on_net],
			[pttic_lc12_on_fet]	=   A.[pttic_lc12_on_fet],
			[pttic_ship_fet_amt]	=   A.[pttic_ship_fet_amt],
			[pttic_ship_set_amt]	=   A.[pttic_ship_set_amt],
			[pttic_ship_sst_amt]	=   A.[pttic_ship_sst_amt],
			[ship_sst_on_net]	=   A.[ship_sst_on_net],
			[ship_sst_on_fet]	=   A.[ship_sst_on_fet],
			[ship_sst_on_set]	=   A.[ship_sst_on_set],
			[ship_sst_on_lc1]	=   A.[ship_sst_on_lc1],
			[ship_sst_on_lc2]	=   A.[ship_sst_on_lc2],
			[ship_sst_on_lc3]	=   A.[ship_sst_on_lc3],
			[ship_sst_on_lc4]	=   A.[ship_sst_on_lc4],
			[ship_sst_on_lc5]	=   A.[ship_sst_on_lc5],
			[ship_sst_on_lc6]	=   A.[ship_sst_on_lc6],
			[ship_sst_on_lc7]	=   A.[ship_sst_on_lc7],
			[ship_sst_on_lc8]	=   A.[ship_sst_on_lc8],
			[ship_sst_on_lc9]	=   A.[ship_sst_on_lc9],
			[ship_sst_on_lc10]	=   A.[ship_sst_on_lc10],
			[ship_sst_on_lc11]	=   A.[ship_sst_on_lc11],
			[ship_sst_on_lc12]	=   A.[ship_sst_on_lc12],
			[pttic_ship_lc1_amt]	=   A.[pttic_ship_lc1_amt],
			[pttic_ship_lc2_amt]	=   A.[pttic_ship_lc2_amt],
			[pttic_ship_lc3_amt]	=   A.[pttic_ship_lc3_amt],
			[pttic_ship_lc4_amt]	=   A.[pttic_ship_lc4_amt],
			[pttic_ship_lc5_amt]	=   A.[pttic_ship_lc5_amt],
			[pttic_ship_lc6_amt]	=   A.[pttic_ship_lc6_amt],
			[pttic_ship_lc7_amt]	=   A.[pttic_ship_lc7_amt],
			[pttic_ship_lc8_amt]	=   A.[pttic_ship_lc8_amt],
			[pttic_ship_lc9_amt]	=   A.[pttic_ship_lc9_amt],
			[pttic_ship_lc10_amt]	=   A.[pttic_ship_lc10_amt],
			[pttic_ship_lc11_amt]	=   A.[pttic_ship_lc11_amt],
			[pttic_ship_lc12_amt]	=   A.[pttic_ship_lc12_amt],
			[ship_lc1_on_net]	=   A.[ship_lc1_on_net],
			[ship_lc1_on_fet]	=   A.[ship_lc1_on_fet],
			[ship_lc2_on_net]	=   A.[ship_lc2_on_net],
			[ship_lc2_on_fet]	=   A.[ship_lc2_on_fet],
			[ship_lc3_on_net]	=   A.[ship_lc3_on_net],
			[ship_lc3_on_fet]	=   A.[ship_lc3_on_fet],
			[ship_lc4_on_net]	=   A.[ship_lc4_on_net],
			[ship_lc4_on_fet]	=   A.[ship_lc4_on_fet],
			[ship_lc5_on_net]	=   A.[ship_lc5_on_net],
			[ship_lc5_on_fet]	=   A.[ship_lc5_on_fet],
			[ship_lc6_on_net]	=   A.[ship_lc6_on_net],
			[ship_lc6_on_fet]	=   A.[ship_lc6_on_fet],
			[ship_lc7_on_net]	=   A.[ship_lc7_on_net],
			[ship_lc7_on_fet]	=   A.[ship_lc7_on_fet],
			[ship_lc8_on_net]	=   A.[ship_lc8_on_net],
			[ship_lc8_on_fet]	=   A.[ship_lc8_on_fet],
			[ship_lc9_on_net]	=   A.[ship_lc9_on_net],
			[ship_lc9_on_fet]	=   A.[ship_lc9_on_fet],
			[ship_lc10_on_net]	=   A.[ship_lc10_on_net],
			[ship_lc10_on_fet]	=   A.[ship_lc10_on_fet],
			[ship_lc11_on_net]	=   A.[ship_lc11_on_net],
			[ship_lc11_on_fet]	=   A.[ship_lc11_on_fet],
			[ship_lc12_on_net]	=   A.[ship_lc12_on_net],
			[ship_lc12_on_fet]	=   A.[ship_lc12_on_fet],
			[pttic_tax_key]	=   A.[pttic_tax_key],
			[pttic_tax_cls_id]	=   A.[pttic_tax_cls_id],
			[pttic_disc_amt]	=   A.[pttic_disc_amt],
			[pttic_disc_days]	=   A.[pttic_disc_days],
			[pttic_terms_disc_amt]	=   A.[pttic_terms_disc_amt],
			[pttic_terms_disc_days]	=   A.[pttic_terms_disc_days],
			[pttic_acct_stat]	=   A.[pttic_acct_stat],
			[pttic_src_sys]	=   A.[pttic_src_sys],
			[pttic_batch_no]	=   A.[pttic_batch_no],
			[pttic_delete_ind]	=   A.[pttic_delete_ind],
			[pttic_release_no]	=   A.[pttic_release_no],
			[pttic_received_by]	=   A.[pttic_received_by],
			[pttic_carrier_key]	=   A.[pttic_carrier_key],
			[pttic_trk_id]	=   A.[pttic_trk_id],
			[pttic_terms_code]	=   A.[pttic_terms_code],
			[pttic_itm_loc_no]	=   A.[pttic_itm_loc_no],
			[pttic_bln_ovride_yn]	=   A.[pttic_bln_ovride_yn],
			[pttic_cash_tendered]	=   A.[pttic_cash_tendered],
			[pttic_cnt_cus_no]	=   A.[pttic_cnt_cus_no],
			[pttic_cnt_no]	=   A.[pttic_cnt_no],
			[pttic_cnt_line_no]	=   A.[pttic_cnt_line_no],
			[pttic_ppd_cnt_ynd]	=   A.[pttic_ppd_cnt_ynd],
			[pttic_csn_rpt_tax_yn]	=   A.[pttic_csn_rpt_tax_yn],
			[pttic_tic_status]	=   A.[pttic_tic_status],
			[pttic_dlvry_pickup_ind]	=   A.[pttic_dlvry_pickup_ind],
			[pttic_sst_exempt_pct]	=   A.[pttic_sst_exempt_pct],
			[pttic_set_exempt_pct]	=   A.[pttic_set_exempt_pct],
			[pttic_sst_exempt_qty]	=   A.[pttic_sst_exempt_qty],
			[pttic_set_exempt_qty]	=   A.[pttic_set_exempt_qty],
			[pttic_hold_reason]	=   A.[pttic_hold_reason],
			[pttic_hold_notify]	=   A.[pttic_hold_notify],
			[pttic_computed_prepaid]	=   A.[pttic_computed_prepaid],
			[pttic_ship_prepaid]	=   A.[pttic_ship_prepaid],
			[pttic_itm_disc_amt]	=   A.[pttic_itm_disc_amt],
			[pttic_sst_tax_dols]	=   A.[pttic_sst_tax_dols],
			[pttic_sst_exempt_dols]	=   A.[pttic_sst_exempt_dols],
			[pttic_sst_exempt_inc_dols]	=   A.[pttic_sst_exempt_inc_dols],
			[pttic_sst_exempt_inc_qty]	=   A.[pttic_sst_exempt_inc_qty],
			[pttic_tm_mtr_read]	=   A.[pttic_tm_mtr_read],
			[pttic_tm_perf_id]	=   A.[pttic_tm_perf_id],
			[pttic_tank_no]	=   A.[pttic_tank_no],
			[pttic_cnt_cus_type]	=   A.[pttic_cnt_cus_type],
			[pttic_bol_no]	=   A.[pttic_bol_no],
			[pttic_driver_no]	=   A.[pttic_driver_no],
			[pttic_quote_ref_no]	=   A.[pttic_quote_ref_no],
			[pttic_vnd_no]	=   A.[pttic_vnd_no],
			[pttic_prc_on_tr_dly]	=   A.[pttic_prc_on_tr_dly],
			[pttic_ord_rack_time]	=   A.[pttic_ord_rack_time],
			[pttic_dtl_comments]	=   A.[pttic_dtl_comments],
			[A4GLIdentity]          =   A.[A4GLIdentity]
	FROM ptticmst A
	WHERE A.pttic_type <> 'O'
END
ELSE
BEGIN
	INSERT INTO tmp_ptticmstImport
	(       [pttic_cus_no]
           ,[pttic_tic_no]
           ,[pttic_line_no]
           ,[pttic_po_no]
           ,[pttic_ivc_no]
           ,[pttic_rev_dt]
           ,[pttic_type]
           ,[pttic_adj_inv_yn]
           ,[pttic_actual_total]
           ,[pttic_computed_total]
           ,[pttic_ship_total]
           ,[pttic_bill_to_cus_no]
           ,[pttic_comments]
           ,[pttic_ship_type]
           ,[pttic_status_ind]
           ,[pttic_gl_acct]
           ,[pttic_check_no]
           ,[pttic_pay_type]
           ,[pttic_slsmn_id]
           ,[pttic_lp_pct_full]
           ,[pttic_pic_printed_yn]
           ,[pttic_kl_beg_rdg]
           ,[pttic_kl_end_rdg]
           ,[pttic_req_ship_rev_dt]
           ,[pttic_ship_rev_dt]
           ,[pttic_itm_no]
           ,[pttic_unit_prc]
           ,[pttic_qty_orig]
           ,[pttic_qty_posted_todate]
           ,[pttic_qty_ship]
           ,[pttic_qty_bckord]
           ,[pttic_fet_amt]
           ,[pttic_set_amt]
           ,[pttic_sst_amt]
           ,[pttic_sst_on_net]
           ,[pttic_sst_on_fet]
           ,[pttic_sst_on_set]
           ,[pttic_sst_on_lc1]
           ,[pttic_sst_on_lc2]
           ,[pttic_sst_on_lc3]
           ,[pttic_sst_on_lc4]
           ,[pttic_sst_on_lc5]
           ,[pttic_sst_on_lc6]
           ,[pttic_sst_on_lc7]
           ,[pttic_sst_on_lc8]
           ,[pttic_sst_on_lc9]
           ,[pttic_sst_on_lc10]
           ,[pttic_sst_on_lc11]
           ,[pttic_sst_on_lc12]
           ,[pttic_lc1_amt]
           ,[pttic_lc2_amt]
           ,[pttic_lc3_amt]
           ,[pttic_lc4_amt]
           ,[pttic_lc5_amt]
           ,[pttic_lc6_amt]
           ,[pttic_lc7_amt]
           ,[pttic_lc8_amt]
           ,[pttic_lc9_amt]
           ,[pttic_lc10_amt]
           ,[pttic_lc11_amt]
           ,[pttic_lc12_amt]
           ,[pttic_lc1_on_net]
           ,[pttic_lc1_on_fet]
           ,[pttic_lc2_on_net]
           ,[pttic_lc2_on_fet]
           ,[pttic_lc3_on_net]
           ,[pttic_lc3_on_fet]
           ,[pttic_lc4_on_net]
           ,[pttic_lc4_on_fet]
           ,[pttic_lc5_on_net]
           ,[pttic_lc5_on_fet]
           ,[pttic_lc6_on_net]
           ,[pttic_lc6_on_fet]
           ,[pttic_lc7_on_net]
           ,[pttic_lc7_on_fet]
           ,[pttic_lc8_on_net]
           ,[pttic_lc8_on_fet]
           ,[pttic_lc9_on_net]
           ,[pttic_lc9_on_fet]
           ,[pttic_lc10_on_net]
           ,[pttic_lc10_on_fet]
           ,[pttic_lc11_on_net]
           ,[pttic_lc11_on_fet]
           ,[pttic_lc12_on_net]
           ,[pttic_lc12_on_fet]
           ,[pttic_ship_fet_amt]
           ,[pttic_ship_set_amt]
           ,[pttic_ship_sst_amt]
           ,[ship_sst_on_net]
           ,[ship_sst_on_fet]
           ,[ship_sst_on_set]
           ,[ship_sst_on_lc1]
           ,[ship_sst_on_lc2]
           ,[ship_sst_on_lc3]
           ,[ship_sst_on_lc4]
           ,[ship_sst_on_lc5]
           ,[ship_sst_on_lc6]
           ,[ship_sst_on_lc7]
           ,[ship_sst_on_lc8]
           ,[ship_sst_on_lc9]
           ,[ship_sst_on_lc10]
           ,[ship_sst_on_lc11]
           ,[ship_sst_on_lc12]
           ,[pttic_ship_lc1_amt]
           ,[pttic_ship_lc2_amt]
           ,[pttic_ship_lc3_amt]
           ,[pttic_ship_lc4_amt]
           ,[pttic_ship_lc5_amt]
           ,[pttic_ship_lc6_amt]
           ,[pttic_ship_lc7_amt]
           ,[pttic_ship_lc8_amt]
           ,[pttic_ship_lc9_amt]
           ,[pttic_ship_lc10_amt]
           ,[pttic_ship_lc11_amt]
           ,[pttic_ship_lc12_amt]
           ,[ship_lc1_on_net]
           ,[ship_lc1_on_fet]
           ,[ship_lc2_on_net]
           ,[ship_lc2_on_fet]
           ,[ship_lc3_on_net]
           ,[ship_lc3_on_fet]
           ,[ship_lc4_on_net]
           ,[ship_lc4_on_fet]
           ,[ship_lc5_on_net]
           ,[ship_lc5_on_fet]
           ,[ship_lc6_on_net]
           ,[ship_lc6_on_fet]
           ,[ship_lc7_on_net]
           ,[ship_lc7_on_fet]
           ,[ship_lc8_on_net]
           ,[ship_lc8_on_fet]
           ,[ship_lc9_on_net]
           ,[ship_lc9_on_fet]
           ,[ship_lc10_on_net]
           ,[ship_lc10_on_fet]
           ,[ship_lc11_on_net]
           ,[ship_lc11_on_fet]
           ,[ship_lc12_on_net]
           ,[ship_lc12_on_fet]
           ,[pttic_tax_key]
           ,[pttic_tax_cls_id]
           ,[pttic_disc_amt]
           ,[pttic_disc_days]
           ,[pttic_terms_disc_amt]
           ,[pttic_terms_disc_days]
           ,[pttic_acct_stat]
           ,[pttic_src_sys]
           ,[pttic_batch_no]
           ,[pttic_delete_ind]
           ,[pttic_release_no]
           ,[pttic_received_by]
           ,[pttic_carrier_key]
           ,[pttic_trk_id]
           ,[pttic_terms_code]
           ,[pttic_itm_loc_no]
           ,[pttic_bln_ovride_yn]
           ,[pttic_cash_tendered]
           ,[pttic_cnt_cus_no]
           ,[pttic_cnt_no]
           ,[pttic_cnt_line_no]
           ,[pttic_ppd_cnt_ynd]
           ,[pttic_csn_rpt_tax_yn]
           ,[pttic_tic_status]
           ,[pttic_dlvry_pickup_ind]
           ,[pttic_sst_exempt_pct]
           ,[pttic_set_exempt_pct]
           ,[pttic_sst_exempt_qty]
           ,[pttic_set_exempt_qty]
           ,[pttic_hold_reason]
           ,[pttic_hold_notify]
           ,[pttic_computed_prepaid]
           ,[pttic_ship_prepaid]
           ,[pttic_itm_disc_amt]
           ,[pttic_sst_tax_dols]
           ,[pttic_sst_exempt_dols]
           ,[pttic_sst_exempt_inc_dols]
           ,[pttic_sst_exempt_inc_qty]
           ,[pttic_tm_mtr_read]
           ,[pttic_tm_perf_id]
           ,[pttic_tank_no]
           ,[pttic_cnt_cus_type]
           ,[pttic_bol_no]
           ,[pttic_driver_no]
           ,[pttic_quote_ref_no]
           ,[pttic_vnd_no]
           ,[pttic_prc_on_tr_dly]
           ,[pttic_ord_rack_time]
           ,[pttic_dtl_comments]
           ,[A4GLIdentity])

	SELECT
			[pttic_cus_no]  =   A.[pttic_cus_no],
			[pttic_tic_no]	=   A.[pttic_tic_no],
			[pttic_line_no]	=   A.[pttic_line_no],
			[pttic_po_no]	=   A.[pttic_po_no],
			[pttic_ivc_no]	=   A.[pttic_ivc_no],
			[pttic_rev_dt]	=   A.[pttic_rev_dt],
			[pttic_type]	=   A.[pttic_type],
			[pttic_adj_inv_yn]	=   A.[pttic_adj_inv_yn],
			[pttic_actual_total]	=   A.[pttic_actual_total],
			[pttic_computed_total]	=   A.[pttic_computed_total],
			[pttic_ship_total]	=   A.[pttic_ship_total],
			[pttic_bill_to_cus_no]	=   A.[pttic_bill_to_cus_no],
			[pttic_comments]	=   A.[pttic_comments],
			[pttic_ship_type]	=   A.[pttic_ship_type],
			[pttic_status_ind]	=   A.[pttic_status_ind],
			[pttic_gl_acct]	=   A.[pttic_gl_acct],
			[pttic_check_no]	=   A.[pttic_check_no],
			[pttic_pay_type]	=   A.[pttic_pay_type],
			[pttic_slsmn_id]	=   A.[pttic_slsmn_id],
			[pttic_lp_pct_full]	=   A.[pttic_lp_pct_full],
			[pttic_pic_printed_yn]	=   A.[pttic_pic_printed_yn],
			[pttic_kl_beg_rdg]	=   A.[pttic_kl_beg_rdg],
			[pttic_kl_end_rdg]	=   A.[pttic_kl_end_rdg],
			[pttic_req_ship_rev_dt]	=   A.[pttic_req_ship_rev_dt],
			[pttic_ship_rev_dt]	=   A.[pttic_ship_rev_dt],
			[pttic_itm_no]	=   A.[pttic_itm_no],
			[pttic_unit_prc]	=   A.[pttic_unit_prc],
			[pttic_qty_orig]	=   A.[pttic_qty_orig],
			[pttic_qty_posted_todate]	=   A.[pttic_qty_posted_todate],
			[pttic_qty_ship]	=   A.[pttic_qty_ship],
			[pttic_qty_bckord]	=   A.[pttic_qty_bckord],
			[pttic_fet_amt]	=   A.[pttic_fet_amt],
			[pttic_set_amt]	=   A.[pttic_set_amt],
			[pttic_sst_amt]	=   A.[pttic_sst_amt],
			[pttic_sst_on_net]	=   A.[pttic_sst_on_net],
			[pttic_sst_on_fet]	=   A.[pttic_sst_on_fet],
			[pttic_sst_on_set]	=   A.[pttic_sst_on_set],
			[pttic_sst_on_lc1]	=   A.[pttic_sst_on_lc1],
			[pttic_sst_on_lc2]	=   A.[pttic_sst_on_lc2],
			[pttic_sst_on_lc3]	=   A.[pttic_sst_on_lc3],
			[pttic_sst_on_lc4]	=   A.[pttic_sst_on_lc4],
			[pttic_sst_on_lc5]	=   A.[pttic_sst_on_lc5],
			[pttic_sst_on_lc6]	=   A.[pttic_sst_on_lc6],
			[pttic_sst_on_lc7]	=   A.[pttic_sst_on_lc7],
			[pttic_sst_on_lc8]	=   A.[pttic_sst_on_lc8],
			[pttic_sst_on_lc9]	=   A.[pttic_sst_on_lc9],
			[pttic_sst_on_lc10]	=   A.[pttic_sst_on_lc10],
			[pttic_sst_on_lc11]	=   A.[pttic_sst_on_lc11],
			[pttic_sst_on_lc12]	=   A.[pttic_sst_on_lc12],
			[pttic_lc1_amt]	=   A.[pttic_lc1_amt],
			[pttic_lc2_amt]	=   A.[pttic_lc2_amt],
			[pttic_lc3_amt]	=   A.[pttic_lc3_amt],
			[pttic_lc4_amt]	=   A.[pttic_lc4_amt],
			[pttic_lc5_amt]	=   A.[pttic_lc5_amt],
			[pttic_lc6_amt]	=   A.[pttic_lc6_amt],
			[pttic_lc7_amt]	=   A.[pttic_lc7_amt],
			[pttic_lc8_amt]	=   A.[pttic_lc8_amt],
			[pttic_lc9_amt]	=   A.[pttic_lc9_amt],
			[pttic_lc10_amt]	=   A.[pttic_lc10_amt],
			[pttic_lc11_amt]	=   A.[pttic_lc11_amt],
			[pttic_lc12_amt]	=   A.[pttic_lc12_amt],
			[pttic_lc1_on_net]	=   A.[pttic_lc1_on_net],
			[pttic_lc1_on_fet]	=   A.[pttic_lc1_on_fet],
			[pttic_lc2_on_net]	=   A.[pttic_lc2_on_net],
			[pttic_lc2_on_fet]	=   A.[pttic_lc2_on_fet],
			[pttic_lc3_on_net]	=   A.[pttic_lc3_on_net],
			[pttic_lc3_on_fet]	=   A.[pttic_lc3_on_fet],
			[pttic_lc4_on_net]	=   A.[pttic_lc4_on_net],
			[pttic_lc4_on_fet]	=   A.[pttic_lc4_on_fet],
			[pttic_lc5_on_net]	=   A.[pttic_lc5_on_net],
			[pttic_lc5_on_fet]	=   A.[pttic_lc5_on_fet],
			[pttic_lc6_on_net]	=   A.[pttic_lc6_on_net],
			[pttic_lc6_on_fet]	=   A.[pttic_lc6_on_fet],
			[pttic_lc7_on_net]	=   A.[pttic_lc7_on_net],
			[pttic_lc7_on_fet]	=   A.[pttic_lc7_on_fet],
			[pttic_lc8_on_net]	=   A.[pttic_lc8_on_net],
			[pttic_lc8_on_fet]	=   A.[pttic_lc8_on_fet],
			[pttic_lc9_on_net]	=   A.[pttic_lc9_on_net],
			[pttic_lc9_on_fet]	=   A.[pttic_lc9_on_fet],
			[pttic_lc10_on_net]	=   A.[pttic_lc10_on_net],
			[pttic_lc10_on_fet]	=   A.[pttic_lc10_on_fet],
			[pttic_lc11_on_net]	=   A.[pttic_lc11_on_net],
			[pttic_lc11_on_fet]	=   A.[pttic_lc11_on_fet],
			[pttic_lc12_on_net]	=   A.[pttic_lc12_on_net],
			[pttic_lc12_on_fet]	=   A.[pttic_lc12_on_fet],
			[pttic_ship_fet_amt]	=   A.[pttic_ship_fet_amt],
			[pttic_ship_set_amt]	=   A.[pttic_ship_set_amt],
			[pttic_ship_sst_amt]	=   A.[pttic_ship_sst_amt],
			[ship_sst_on_net]	=   A.[ship_sst_on_net],
			[ship_sst_on_fet]	=   A.[ship_sst_on_fet],
			[ship_sst_on_set]	=   A.[ship_sst_on_set],
			[ship_sst_on_lc1]	=   A.[ship_sst_on_lc1],
			[ship_sst_on_lc2]	=   A.[ship_sst_on_lc2],
			[ship_sst_on_lc3]	=   A.[ship_sst_on_lc3],
			[ship_sst_on_lc4]	=   A.[ship_sst_on_lc4],
			[ship_sst_on_lc5]	=   A.[ship_sst_on_lc5],
			[ship_sst_on_lc6]	=   A.[ship_sst_on_lc6],
			[ship_sst_on_lc7]	=   A.[ship_sst_on_lc7],
			[ship_sst_on_lc8]	=   A.[ship_sst_on_lc8],
			[ship_sst_on_lc9]	=   A.[ship_sst_on_lc9],
			[ship_sst_on_lc10]	=   A.[ship_sst_on_lc10],
			[ship_sst_on_lc11]	=   A.[ship_sst_on_lc11],
			[ship_sst_on_lc12]	=   A.[ship_sst_on_lc12],
			[pttic_ship_lc1_amt]	=   A.[pttic_ship_lc1_amt],
			[pttic_ship_lc2_amt]	=   A.[pttic_ship_lc2_amt],
			[pttic_ship_lc3_amt]	=   A.[pttic_ship_lc3_amt],
			[pttic_ship_lc4_amt]	=   A.[pttic_ship_lc4_amt],
			[pttic_ship_lc5_amt]	=   A.[pttic_ship_lc5_amt],
			[pttic_ship_lc6_amt]	=   A.[pttic_ship_lc6_amt],
			[pttic_ship_lc7_amt]	=   A.[pttic_ship_lc7_amt],
			[pttic_ship_lc8_amt]	=   A.[pttic_ship_lc8_amt],
			[pttic_ship_lc9_amt]	=   A.[pttic_ship_lc9_amt],
			[pttic_ship_lc10_amt]	=   A.[pttic_ship_lc10_amt],
			[pttic_ship_lc11_amt]	=   A.[pttic_ship_lc11_amt],
			[pttic_ship_lc12_amt]	=   A.[pttic_ship_lc12_amt],
			[ship_lc1_on_net]	=   A.[ship_lc1_on_net],
			[ship_lc1_on_fet]	=   A.[ship_lc1_on_fet],
			[ship_lc2_on_net]	=   A.[ship_lc2_on_net],
			[ship_lc2_on_fet]	=   A.[ship_lc2_on_fet],
			[ship_lc3_on_net]	=   A.[ship_lc3_on_net],
			[ship_lc3_on_fet]	=   A.[ship_lc3_on_fet],
			[ship_lc4_on_net]	=   A.[ship_lc4_on_net],
			[ship_lc4_on_fet]	=   A.[ship_lc4_on_fet],
			[ship_lc5_on_net]	=   A.[ship_lc5_on_net],
			[ship_lc5_on_fet]	=   A.[ship_lc5_on_fet],
			[ship_lc6_on_net]	=   A.[ship_lc6_on_net],
			[ship_lc6_on_fet]	=   A.[ship_lc6_on_fet],
			[ship_lc7_on_net]	=   A.[ship_lc7_on_net],
			[ship_lc7_on_fet]	=   A.[ship_lc7_on_fet],
			[ship_lc8_on_net]	=   A.[ship_lc8_on_net],
			[ship_lc8_on_fet]	=   A.[ship_lc8_on_fet],
			[ship_lc9_on_net]	=   A.[ship_lc9_on_net],
			[ship_lc9_on_fet]	=   A.[ship_lc9_on_fet],
			[ship_lc10_on_net]	=   A.[ship_lc10_on_net],
			[ship_lc10_on_fet]	=   A.[ship_lc10_on_fet],
			[ship_lc11_on_net]	=   A.[ship_lc11_on_net],
			[ship_lc11_on_fet]	=   A.[ship_lc11_on_fet],
			[ship_lc12_on_net]	=   A.[ship_lc12_on_net],
			[ship_lc12_on_fet]	=   A.[ship_lc12_on_fet],
			[pttic_tax_key]	=   A.[pttic_tax_key],
			[pttic_tax_cls_id]	=   A.[pttic_tax_cls_id],
			[pttic_disc_amt]	=   A.[pttic_disc_amt],
			[pttic_disc_days]	=   A.[pttic_disc_days],
			[pttic_terms_disc_amt]	=   A.[pttic_terms_disc_amt],
			[pttic_terms_disc_days]	=   A.[pttic_terms_disc_days],
			[pttic_acct_stat]	=   A.[pttic_acct_stat],
			[pttic_src_sys]	=   A.[pttic_src_sys],
			[pttic_batch_no]	=   A.[pttic_batch_no],
			[pttic_delete_ind]	=   A.[pttic_delete_ind],
			[pttic_release_no]	=   A.[pttic_release_no],
			[pttic_received_by]	=   A.[pttic_received_by],
			[pttic_carrier_key]	=   A.[pttic_carrier_key],
			[pttic_trk_id]	=   A.[pttic_trk_id],
			[pttic_terms_code]	=   A.[pttic_terms_code],
			[pttic_itm_loc_no]	=   A.[pttic_itm_loc_no],
			[pttic_bln_ovride_yn]	=   A.[pttic_bln_ovride_yn],
			[pttic_cash_tendered]	=   A.[pttic_cash_tendered],
			[pttic_cnt_cus_no]	=   A.[pttic_cnt_cus_no],
			[pttic_cnt_no]	=   A.[pttic_cnt_no],
			[pttic_cnt_line_no]	=   A.[pttic_cnt_line_no],
			[pttic_ppd_cnt_ynd]	=   A.[pttic_ppd_cnt_ynd],
			[pttic_csn_rpt_tax_yn]	=   A.[pttic_csn_rpt_tax_yn],
			[pttic_tic_status]	=   A.[pttic_tic_status],
			[pttic_dlvry_pickup_ind]	=   A.[pttic_dlvry_pickup_ind],
			[pttic_sst_exempt_pct]	=   A.[pttic_sst_exempt_pct],
			[pttic_set_exempt_pct]	=   A.[pttic_set_exempt_pct],
			[pttic_sst_exempt_qty]	=   A.[pttic_sst_exempt_qty],
			[pttic_set_exempt_qty]	=   A.[pttic_set_exempt_qty],
			[pttic_hold_reason]	=   A.[pttic_hold_reason],
			[pttic_hold_notify]	=   A.[pttic_hold_notify],
			[pttic_computed_prepaid]	=   A.[pttic_computed_prepaid],
			[pttic_ship_prepaid]	=   A.[pttic_ship_prepaid],
			[pttic_itm_disc_amt]	=   A.[pttic_itm_disc_amt],
			[pttic_sst_tax_dols]	=   A.[pttic_sst_tax_dols],
			[pttic_sst_exempt_dols]	=   A.[pttic_sst_exempt_dols],
			[pttic_sst_exempt_inc_dols]	=   A.[pttic_sst_exempt_inc_dols],
			[pttic_sst_exempt_inc_qty]	=   A.[pttic_sst_exempt_inc_qty],
			[pttic_tm_mtr_read]	=   A.[pttic_tm_mtr_read],
			[pttic_tm_perf_id]	=   A.[pttic_tm_perf_id],
			[pttic_tank_no]	=   A.[pttic_tank_no],
			[pttic_cnt_cus_type]	=   A.[pttic_cnt_cus_type],
			[pttic_bol_no]	=   A.[pttic_bol_no],
			[pttic_driver_no]	=   A.[pttic_driver_no],
			[pttic_quote_ref_no]	=   A.[pttic_quote_ref_no],
			[pttic_vnd_no]	=   A.[pttic_vnd_no],
			[pttic_prc_on_tr_dly]	=   A.[pttic_prc_on_tr_dly],
			[pttic_ord_rack_time]	=   A.[pttic_ord_rack_time],
			[pttic_dtl_comments]	=   A.[pttic_dtl_comments],
			[A4GLIdentity]          =   A.[A4GLIdentity]
	FROM ptticmst A
	WHERE A.pttic_type <> 'O'
	AND 1 = (CASE WHEN CONVERT(DATE, CAST(A.pttic_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END)
END

IF OBJECT_ID('tempdb..#tmpUnostedInvoiceBackupId') IS NOT NULL DROP TABLE #tmpUnostedInvoiceBackupId
CREATE TABLE #tmpUnostedInvoiceBackupId(intBackupId INT, intId INT)

MERGE INTO tblARptticmst AS destination
USING
(
SELECT 
	  [pttic_cus_no]
     ,[pttic_tic_no]
     ,[pttic_line_no]
     ,[pttic_po_no]
     ,[pttic_ivc_no]
     ,[pttic_rev_dt]
     ,[pttic_type]
     ,[pttic_adj_inv_yn]
     ,[pttic_actual_total]
     ,[pttic_computed_total]
     ,[pttic_ship_total]
     ,[pttic_bill_to_cus_no]
     ,[pttic_comments]
     ,[pttic_ship_type]
     ,[pttic_status_ind]
     ,[pttic_gl_acct]
     ,[pttic_check_no]
     ,[pttic_pay_type]
     ,[pttic_slsmn_id]
     ,[pttic_lp_pct_full]
     ,[pttic_pic_printed_yn]
     ,[pttic_kl_beg_rdg]
     ,[pttic_kl_end_rdg]
     ,[pttic_req_ship_rev_dt]
     ,[pttic_ship_rev_dt]
     ,[pttic_itm_no]
     ,[pttic_unit_prc]
     ,[pttic_qty_orig]
     ,[pttic_qty_posted_todate]
     ,[pttic_qty_ship]
     ,[pttic_qty_bckord]
     ,[pttic_fet_amt]
     ,[pttic_set_amt]
     ,[pttic_sst_amt]
     ,[pttic_sst_on_net]
     ,[pttic_sst_on_fet]
     ,[pttic_sst_on_set]
     ,[pttic_sst_on_lc1]
     ,[pttic_sst_on_lc2]
     ,[pttic_sst_on_lc3]
     ,[pttic_sst_on_lc4]
     ,[pttic_sst_on_lc5]
     ,[pttic_sst_on_lc6]
     ,[pttic_sst_on_lc7]
     ,[pttic_sst_on_lc8]
     ,[pttic_sst_on_lc9]
     ,[pttic_sst_on_lc10]
     ,[pttic_sst_on_lc11]
     ,[pttic_sst_on_lc12]
     ,[pttic_lc1_amt]
     ,[pttic_lc2_amt]
     ,[pttic_lc3_amt]
     ,[pttic_lc4_amt]
     ,[pttic_lc5_amt]
     ,[pttic_lc6_amt]
     ,[pttic_lc7_amt]
     ,[pttic_lc8_amt]
     ,[pttic_lc9_amt]
     ,[pttic_lc10_amt]
     ,[pttic_lc11_amt]
     ,[pttic_lc12_amt]
     ,[pttic_lc1_on_net]
     ,[pttic_lc1_on_fet]
     ,[pttic_lc2_on_net]
     ,[pttic_lc2_on_fet]
     ,[pttic_lc3_on_net]
     ,[pttic_lc3_on_fet]
     ,[pttic_lc4_on_net]
     ,[pttic_lc4_on_fet]
     ,[pttic_lc5_on_net]
     ,[pttic_lc5_on_fet]
     ,[pttic_lc6_on_net]
     ,[pttic_lc6_on_fet]
     ,[pttic_lc7_on_net]
     ,[pttic_lc7_on_fet]
     ,[pttic_lc8_on_net]
     ,[pttic_lc8_on_fet]
     ,[pttic_lc9_on_net]
     ,[pttic_lc9_on_fet]
     ,[pttic_lc10_on_net]
     ,[pttic_lc10_on_fet]
     ,[pttic_lc11_on_net]
     ,[pttic_lc11_on_fet]
     ,[pttic_lc12_on_net]
     ,[pttic_lc12_on_fet]
     ,[pttic_ship_fet_amt]
     ,[pttic_ship_set_amt]
     ,[pttic_ship_sst_amt]
     ,[ship_sst_on_net]
     ,[ship_sst_on_fet]
     ,[ship_sst_on_set]
     ,[ship_sst_on_lc1]
     ,[ship_sst_on_lc2]
     ,[ship_sst_on_lc3]
     ,[ship_sst_on_lc4]
     ,[ship_sst_on_lc5]
     ,[ship_sst_on_lc6]
     ,[ship_sst_on_lc7]
     ,[ship_sst_on_lc8]
     ,[ship_sst_on_lc9]
     ,[ship_sst_on_lc10]
     ,[ship_sst_on_lc11]
     ,[ship_sst_on_lc12]
     ,[pttic_ship_lc1_amt]
     ,[pttic_ship_lc2_amt]
     ,[pttic_ship_lc3_amt]
     ,[pttic_ship_lc4_amt]
     ,[pttic_ship_lc5_amt]
     ,[pttic_ship_lc6_amt]
     ,[pttic_ship_lc7_amt]
     ,[pttic_ship_lc8_amt]
     ,[pttic_ship_lc9_amt]
     ,[pttic_ship_lc10_amt]
     ,[pttic_ship_lc11_amt]
     ,[pttic_ship_lc12_amt]
     ,[ship_lc1_on_net]
     ,[ship_lc1_on_fet]
     ,[ship_lc2_on_net]
     ,[ship_lc2_on_fet]
     ,[ship_lc3_on_net]
     ,[ship_lc3_on_fet]
     ,[ship_lc4_on_net]
     ,[ship_lc4_on_fet]
     ,[ship_lc5_on_net]
     ,[ship_lc5_on_fet]
     ,[ship_lc6_on_net]
     ,[ship_lc6_on_fet]
     ,[ship_lc7_on_net]
     ,[ship_lc7_on_fet]
     ,[ship_lc8_on_net]
     ,[ship_lc8_on_fet]
     ,[ship_lc9_on_net]
     ,[ship_lc9_on_fet]
     ,[ship_lc10_on_net]
     ,[ship_lc10_on_fet]
     ,[ship_lc11_on_net]
     ,[ship_lc11_on_fet]
     ,[ship_lc12_on_net]
     ,[ship_lc12_on_fet]
     ,[pttic_tax_key]
     ,[pttic_tax_cls_id]
     ,[pttic_disc_amt]
     ,[pttic_disc_days]
     ,[pttic_terms_disc_amt]
     ,[pttic_terms_disc_days]
     ,[pttic_acct_stat]
     ,[pttic_src_sys]
     ,[pttic_batch_no]
     ,[pttic_delete_ind]
     ,[pttic_release_no]
     ,[pttic_received_by]
     ,[pttic_carrier_key]
     ,[pttic_trk_id]
     ,[pttic_terms_code]
     ,[pttic_itm_loc_no]
     ,[pttic_bln_ovride_yn]
     ,[pttic_cash_tendered]
     ,[pttic_cnt_cus_no]
     ,[pttic_cnt_no]
     ,[pttic_cnt_line_no]
     ,[pttic_ppd_cnt_ynd]
     ,[pttic_csn_rpt_tax_yn]
     ,[pttic_tic_status]
     ,[pttic_dlvry_pickup_ind]
     ,[pttic_sst_exempt_pct]
     ,[pttic_set_exempt_pct]
     ,[pttic_sst_exempt_qty]
     ,[pttic_set_exempt_qty]
     ,[pttic_hold_reason]
     ,[pttic_hold_notify]
     ,[pttic_computed_prepaid]
     ,[pttic_ship_prepaid]
     ,[pttic_itm_disc_amt]
     ,[pttic_sst_tax_dols]
     ,[pttic_sst_exempt_dols]
     ,[pttic_sst_exempt_inc_dols]
     ,[pttic_sst_exempt_inc_qty]
     ,[pttic_tm_mtr_read]
     ,[pttic_tm_perf_id]
     ,[pttic_tank_no]
     ,[pttic_cnt_cus_type]
     ,[pttic_bol_no]
     ,[pttic_driver_no]
     ,[pttic_quote_ref_no]
     ,[pttic_vnd_no]
     ,[pttic_prc_on_tr_dly]
     ,[pttic_ord_rack_time]
     ,[pttic_dtl_comments]	
	 ,[A4GLIdentity]		
	 ,[intId]
FROM tmp_ptticmstImport	
) AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	  [pttic_cus_no]
     ,[pttic_tic_no]
     ,[pttic_line_no]
     ,[pttic_po_no]
     ,[pttic_ivc_no]
     ,[pttic_rev_dt]
     ,[pttic_type]
     ,[pttic_adj_inv_yn]
     ,[pttic_actual_total]
     ,[pttic_computed_total]
     ,[pttic_ship_total]
     ,[pttic_bill_to_cus_no]
     ,[pttic_comments]
     ,[pttic_ship_type]
     ,[pttic_status_ind]
     ,[pttic_gl_acct]
     ,[pttic_check_no]
     ,[pttic_pay_type]
     ,[pttic_slsmn_id]
     ,[pttic_lp_pct_full]
     ,[pttic_pic_printed_yn]
     ,[pttic_kl_beg_rdg]
     ,[pttic_kl_end_rdg]
     ,[pttic_req_ship_rev_dt]
     ,[pttic_ship_rev_dt]
     ,[pttic_itm_no]
     ,[pttic_unit_prc]
     ,[pttic_qty_orig]
     ,[pttic_qty_posted_todate]
     ,[pttic_qty_ship]
     ,[pttic_qty_bckord]
     ,[pttic_fet_amt]
     ,[pttic_set_amt]
     ,[pttic_sst_amt]
     ,[pttic_sst_on_net]
     ,[pttic_sst_on_fet]
     ,[pttic_sst_on_set]
     ,[pttic_sst_on_lc1]
     ,[pttic_sst_on_lc2]
     ,[pttic_sst_on_lc3]
     ,[pttic_sst_on_lc4]
     ,[pttic_sst_on_lc5]
     ,[pttic_sst_on_lc6]
     ,[pttic_sst_on_lc7]
     ,[pttic_sst_on_lc8]
     ,[pttic_sst_on_lc9]
     ,[pttic_sst_on_lc10]
     ,[pttic_sst_on_lc11]
     ,[pttic_sst_on_lc12]
     ,[pttic_lc1_amt]
     ,[pttic_lc2_amt]
     ,[pttic_lc3_amt]
     ,[pttic_lc4_amt]
     ,[pttic_lc5_amt]
     ,[pttic_lc6_amt]
     ,[pttic_lc7_amt]
     ,[pttic_lc8_amt]
     ,[pttic_lc9_amt]
     ,[pttic_lc10_amt]
     ,[pttic_lc11_amt]
     ,[pttic_lc12_amt]
     ,[pttic_lc1_on_net]
     ,[pttic_lc1_on_fet]
     ,[pttic_lc2_on_net]
     ,[pttic_lc2_on_fet]
     ,[pttic_lc3_on_net]
     ,[pttic_lc3_on_fet]
     ,[pttic_lc4_on_net]
     ,[pttic_lc4_on_fet]
     ,[pttic_lc5_on_net]
     ,[pttic_lc5_on_fet]
     ,[pttic_lc6_on_net]
     ,[pttic_lc6_on_fet]
     ,[pttic_lc7_on_net]
     ,[pttic_lc7_on_fet]
     ,[pttic_lc8_on_net]
     ,[pttic_lc8_on_fet]
     ,[pttic_lc9_on_net]
     ,[pttic_lc9_on_fet]
     ,[pttic_lc10_on_net]
     ,[pttic_lc10_on_fet]
     ,[pttic_lc11_on_net]
     ,[pttic_lc11_on_fet]
     ,[pttic_lc12_on_net]
     ,[pttic_lc12_on_fet]
     ,[pttic_ship_fet_amt]
     ,[pttic_ship_set_amt]
     ,[pttic_ship_sst_amt]
     ,[ship_sst_on_net]
     ,[ship_sst_on_fet]
     ,[ship_sst_on_set]
     ,[ship_sst_on_lc1]
     ,[ship_sst_on_lc2]
     ,[ship_sst_on_lc3]
     ,[ship_sst_on_lc4]
     ,[ship_sst_on_lc5]
     ,[ship_sst_on_lc6]
     ,[ship_sst_on_lc7]
     ,[ship_sst_on_lc8]
     ,[ship_sst_on_lc9]
     ,[ship_sst_on_lc10]
     ,[ship_sst_on_lc11]
     ,[ship_sst_on_lc12]
     ,[pttic_ship_lc1_amt]
     ,[pttic_ship_lc2_amt]
     ,[pttic_ship_lc3_amt]
     ,[pttic_ship_lc4_amt]
     ,[pttic_ship_lc5_amt]
     ,[pttic_ship_lc6_amt]
     ,[pttic_ship_lc7_amt]
     ,[pttic_ship_lc8_amt]
     ,[pttic_ship_lc9_amt]
     ,[pttic_ship_lc10_amt]
     ,[pttic_ship_lc11_amt]
     ,[pttic_ship_lc12_amt]
     ,[ship_lc1_on_net]
     ,[ship_lc1_on_fet]
     ,[ship_lc2_on_net]
     ,[ship_lc2_on_fet]
     ,[ship_lc3_on_net]
     ,[ship_lc3_on_fet]
     ,[ship_lc4_on_net]
     ,[ship_lc4_on_fet]
     ,[ship_lc5_on_net]
     ,[ship_lc5_on_fet]
     ,[ship_lc6_on_net]
     ,[ship_lc6_on_fet]
     ,[ship_lc7_on_net]
     ,[ship_lc7_on_fet]
     ,[ship_lc8_on_net]
     ,[ship_lc8_on_fet]
     ,[ship_lc9_on_net]
     ,[ship_lc9_on_fet]
     ,[ship_lc10_on_net]
     ,[ship_lc10_on_fet]
     ,[ship_lc11_on_net]
     ,[ship_lc11_on_fet]
     ,[ship_lc12_on_net]
     ,[ship_lc12_on_fet]
     ,[pttic_tax_key]
     ,[pttic_tax_cls_id]
     ,[pttic_disc_amt]
     ,[pttic_disc_days]
     ,[pttic_terms_disc_amt]
     ,[pttic_terms_disc_days]
     ,[pttic_acct_stat]
     ,[pttic_src_sys]
     ,[pttic_batch_no]
     ,[pttic_delete_ind]
     ,[pttic_release_no]
     ,[pttic_received_by]
     ,[pttic_carrier_key]
     ,[pttic_trk_id]
     ,[pttic_terms_code]
     ,[pttic_itm_loc_no]
     ,[pttic_bln_ovride_yn]
     ,[pttic_cash_tendered]
     ,[pttic_cnt_cus_no]
     ,[pttic_cnt_no]
     ,[pttic_cnt_line_no]
     ,[pttic_ppd_cnt_ynd]
     ,[pttic_csn_rpt_tax_yn]
     ,[pttic_tic_status]
     ,[pttic_dlvry_pickup_ind]
     ,[pttic_sst_exempt_pct]
     ,[pttic_set_exempt_pct]
     ,[pttic_sst_exempt_qty]
     ,[pttic_set_exempt_qty]
     ,[pttic_hold_reason]
     ,[pttic_hold_notify]
     ,[pttic_computed_prepaid]
     ,[pttic_ship_prepaid]
     ,[pttic_itm_disc_amt]
     ,[pttic_sst_tax_dols]
     ,[pttic_sst_exempt_dols]
     ,[pttic_sst_exempt_inc_dols]
     ,[pttic_sst_exempt_inc_qty]
     ,[pttic_tm_mtr_read]
     ,[pttic_tm_perf_id]
     ,[pttic_tank_no]
     ,[pttic_cnt_cus_type]
     ,[pttic_bol_no]
     ,[pttic_driver_no]
     ,[pttic_quote_ref_no]
     ,[pttic_vnd_no]
     ,[pttic_prc_on_tr_dly]
     ,[pttic_ord_rack_time]
     ,[pttic_dtl_comments]	
	 ,[A4GLIdentity]		
)
VALUES
(
	  [pttic_cus_no]
     ,[pttic_tic_no]
     ,[pttic_line_no]
     ,[pttic_po_no]
     ,[pttic_ivc_no]
     ,[pttic_rev_dt]
     ,[pttic_type]
     ,[pttic_adj_inv_yn]
     ,[pttic_actual_total]
     ,[pttic_computed_total]
     ,[pttic_ship_total]
     ,[pttic_bill_to_cus_no]
     ,[pttic_comments]
     ,[pttic_ship_type]
     ,[pttic_status_ind]
     ,[pttic_gl_acct]
     ,[pttic_check_no]
     ,[pttic_pay_type]
     ,[pttic_slsmn_id]
     ,[pttic_lp_pct_full]
     ,[pttic_pic_printed_yn]
     ,[pttic_kl_beg_rdg]
     ,[pttic_kl_end_rdg]
     ,[pttic_req_ship_rev_dt]
     ,[pttic_ship_rev_dt]
     ,[pttic_itm_no]
     ,[pttic_unit_prc]
     ,[pttic_qty_orig]
     ,[pttic_qty_posted_todate]
     ,[pttic_qty_ship]
     ,[pttic_qty_bckord]
     ,[pttic_fet_amt]
     ,[pttic_set_amt]
     ,[pttic_sst_amt]
     ,[pttic_sst_on_net]
     ,[pttic_sst_on_fet]
     ,[pttic_sst_on_set]
     ,[pttic_sst_on_lc1]
     ,[pttic_sst_on_lc2]
     ,[pttic_sst_on_lc3]
     ,[pttic_sst_on_lc4]
     ,[pttic_sst_on_lc5]
     ,[pttic_sst_on_lc6]
     ,[pttic_sst_on_lc7]
     ,[pttic_sst_on_lc8]
     ,[pttic_sst_on_lc9]
     ,[pttic_sst_on_lc10]
     ,[pttic_sst_on_lc11]
     ,[pttic_sst_on_lc12]
     ,[pttic_lc1_amt]
     ,[pttic_lc2_amt]
     ,[pttic_lc3_amt]
     ,[pttic_lc4_amt]
     ,[pttic_lc5_amt]
     ,[pttic_lc6_amt]
     ,[pttic_lc7_amt]
     ,[pttic_lc8_amt]
     ,[pttic_lc9_amt]
     ,[pttic_lc10_amt]
     ,[pttic_lc11_amt]
     ,[pttic_lc12_amt]
     ,[pttic_lc1_on_net]
     ,[pttic_lc1_on_fet]
     ,[pttic_lc2_on_net]
     ,[pttic_lc2_on_fet]
     ,[pttic_lc3_on_net]
     ,[pttic_lc3_on_fet]
     ,[pttic_lc4_on_net]
     ,[pttic_lc4_on_fet]
     ,[pttic_lc5_on_net]
     ,[pttic_lc5_on_fet]
     ,[pttic_lc6_on_net]
     ,[pttic_lc6_on_fet]
     ,[pttic_lc7_on_net]
     ,[pttic_lc7_on_fet]
     ,[pttic_lc8_on_net]
     ,[pttic_lc8_on_fet]
     ,[pttic_lc9_on_net]
     ,[pttic_lc9_on_fet]
     ,[pttic_lc10_on_net]
     ,[pttic_lc10_on_fet]
     ,[pttic_lc11_on_net]
     ,[pttic_lc11_on_fet]
     ,[pttic_lc12_on_net]
     ,[pttic_lc12_on_fet]
     ,[pttic_ship_fet_amt]
     ,[pttic_ship_set_amt]
     ,[pttic_ship_sst_amt]
     ,[ship_sst_on_net]
     ,[ship_sst_on_fet]
     ,[ship_sst_on_set]
     ,[ship_sst_on_lc1]
     ,[ship_sst_on_lc2]
     ,[ship_sst_on_lc3]
     ,[ship_sst_on_lc4]
     ,[ship_sst_on_lc5]
     ,[ship_sst_on_lc6]
     ,[ship_sst_on_lc7]
     ,[ship_sst_on_lc8]
     ,[ship_sst_on_lc9]
     ,[ship_sst_on_lc10]
     ,[ship_sst_on_lc11]
     ,[ship_sst_on_lc12]
     ,[pttic_ship_lc1_amt]
     ,[pttic_ship_lc2_amt]
     ,[pttic_ship_lc3_amt]
     ,[pttic_ship_lc4_amt]
     ,[pttic_ship_lc5_amt]
     ,[pttic_ship_lc6_amt]
     ,[pttic_ship_lc7_amt]
     ,[pttic_ship_lc8_amt]
     ,[pttic_ship_lc9_amt]
     ,[pttic_ship_lc10_amt]
     ,[pttic_ship_lc11_amt]
     ,[pttic_ship_lc12_amt]
     ,[ship_lc1_on_net]
     ,[ship_lc1_on_fet]
     ,[ship_lc2_on_net]
     ,[ship_lc2_on_fet]
     ,[ship_lc3_on_net]
     ,[ship_lc3_on_fet]
     ,[ship_lc4_on_net]
     ,[ship_lc4_on_fet]
     ,[ship_lc5_on_net]
     ,[ship_lc5_on_fet]
     ,[ship_lc6_on_net]
     ,[ship_lc6_on_fet]
     ,[ship_lc7_on_net]
     ,[ship_lc7_on_fet]
     ,[ship_lc8_on_net]
     ,[ship_lc8_on_fet]
     ,[ship_lc9_on_net]
     ,[ship_lc9_on_fet]
     ,[ship_lc10_on_net]
     ,[ship_lc10_on_fet]
     ,[ship_lc11_on_net]
     ,[ship_lc11_on_fet]
     ,[ship_lc12_on_net]
     ,[ship_lc12_on_fet]
     ,[pttic_tax_key]
     ,[pttic_tax_cls_id]
     ,[pttic_disc_amt]
     ,[pttic_disc_days]
     ,[pttic_terms_disc_amt]
     ,[pttic_terms_disc_days]
     ,[pttic_acct_stat]
     ,[pttic_src_sys]
     ,[pttic_batch_no]
     ,[pttic_delete_ind]
     ,[pttic_release_no]
     ,[pttic_received_by]
     ,[pttic_carrier_key]
     ,[pttic_trk_id]
     ,[pttic_terms_code]
     ,[pttic_itm_loc_no]
     ,[pttic_bln_ovride_yn]
     ,[pttic_cash_tendered]
     ,[pttic_cnt_cus_no]
     ,[pttic_cnt_no]
     ,[pttic_cnt_line_no]
     ,[pttic_ppd_cnt_ynd]
     ,[pttic_csn_rpt_tax_yn]
     ,[pttic_tic_status]
     ,[pttic_dlvry_pickup_ind]
     ,[pttic_sst_exempt_pct]
     ,[pttic_set_exempt_pct]
     ,[pttic_sst_exempt_qty]
     ,[pttic_set_exempt_qty]
     ,[pttic_hold_reason]
     ,[pttic_hold_notify]
     ,[pttic_computed_prepaid]
     ,[pttic_ship_prepaid]
     ,[pttic_itm_disc_amt]
     ,[pttic_sst_tax_dols]
     ,[pttic_sst_exempt_dols]
     ,[pttic_sst_exempt_inc_dols]
     ,[pttic_sst_exempt_inc_qty]
     ,[pttic_tm_mtr_read]
     ,[pttic_tm_perf_id]
     ,[pttic_tank_no]
     ,[pttic_cnt_cus_type]
     ,[pttic_bol_no]
     ,[pttic_driver_no]
     ,[pttic_quote_ref_no]
     ,[pttic_vnd_no]
     ,[pttic_prc_on_tr_dly]
     ,[pttic_ord_rack_time]
     ,[pttic_dtl_comments]	
	 ,[A4GLIdentity]		
)
OUTPUT inserted.intId, SourceData.intId INTO #tmpUnostedInvoiceBackupId;

SET @totalptticmst = @@ROWCOUNT;

--UPDATE temp data for the back up link
UPDATE A
	SET A.intBackupId = B.intBackupId
FROM tmp_ptticmstImport A
INNER JOIN #tmpUnostedInvoiceBackupId B ON A.intId = B.intId

DELETE A
FROM ptticmst A
INNER JOIN tmp_ptticmstImport B 
ON A.[pttic_cus_no] = B.[pttic_cus_no] AND A.pttic_ivc_no = B.pttic_ivc_no AND A.A4GLIdentity = B.A4GLIdentity

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorBackingUp NVARCHAR(500) = ERROR_MESSAGE();
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR(@errorBackingUp, 16, 1);
END CATCH

GO


