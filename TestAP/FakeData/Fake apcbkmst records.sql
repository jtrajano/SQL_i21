CREATE PROCEDURE [AP].[Fake apcbkmst records]
AS

EXEC tSQLt.FakeTable 'apcbkmst_origin', @Identity = 1

SET IDENTITY_INSERT apcbkmst_origin ON
INSERT [dbo].[apcbkmst_origin] (
	[apcbk_no]
	,[apcbk_currency]
	,[apcbk_password]
	,[apcbk_desc]
	,[apcbk_bank_acct_no]
	,[apcbk_comment]
	,[apcbk_show_bal_yn]
	,[apcbk_prompt_align_yn]
	,[apcbk_chk_clr_ord_dn]
	,[apcbk_import_export_yn]
	,[apcbk_export_cbk_no]
	,[apcbk_stmt_lock_rev_dt]
	,[apcbk_gl_close_rev_dt]
	,[apcbk_bal]
	,[apcbk_next_chk_no]
	,[apcbk_next_eft_no]
	,[apcbk_check_format_cs]
	,[apcbk_laser_down_lines]
	,[apcbk_prtr_checks]
	,[apcbk_auto_assign_trx_yn]
	,[apcbk_next_trx_no]
	,[apcbk_transit_route]
	,[apcbk_ach_company_id]
	,[apcbk_ach_bankname]
	,[apcbk_gl_cash]
	,[apcbk_gl_ap]
	,[apcbk_gl_disc]
	,[apcbk_gl_wthhld]
	,[apcbk_gl_curr]
	,[apcbk_active_yn]
	,[apcbk_bnk_no]
	,[apcbk_user_id]
	,[apcbk_user_rev_dt]
	,[A4GLIdentity]
	)
VALUES (
	N'01'
	,N'USD'
	,NULL
	,N'CO-BANK                       '
	,N'1032967452          '
	,NULL
	,N'Y'
	,N'N'
	,N'N'
	,N'N'
	,N'01'
	,0
	,20160331
	,CAST(190626.33 AS DECIMAL(11, 2))
	,194380
	,3820
	,N'S'
	,5
	,N'LASERCHECKS                                                                     '
	,N'Y'
	,10462
	,0
	,NULL
	,NULL
	,CAST(103100.00000000 AS DECIMAL(16, 8))
	,CAST(210500.00000000 AS DECIMAL(16, 8))
	,CAST(539500.00099090 AS DECIMAL(16, 8))
	,CAST(223000.00000000 AS DECIMAL(16, 8))
	,CAST(0.00000000 AS DECIMAL(16, 8))
	,N'Y'
	,NULL
	,N'HLEE            '
	,20160427
	,CAST(1 AS NUMERIC(9, 0))
	)
SET IDENTITY_INSERT apcbkmst_origin OFF