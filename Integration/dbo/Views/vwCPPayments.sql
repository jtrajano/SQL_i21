﻿IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPayments')
	DROP VIEW vwCPPayments

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPPayments]
		AS
		select
			p.A4GLIdentity
			,l.agloc_name
			,p.agpay_chk_no
			,p.agpay_ref_no
			,p.agpay_batch_no
			,agpay_orig_rev_dt = (case len(convert(varchar, p.agpay_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, p.agpay_orig_rev_dt) AS CHAR(12)), 112) else null end)
			,p.agpay_ivc_no
			,p.agpay_seq_no
			,p.agpay_amt
		from
			agpaymst p
			,aglocmst l
		where
		 p.agpay_loc_no = l.agloc_loc_no
		')
GO

-- PT VIEW 
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPPayments]
		AS
			select
			p.A4GLIdentity
			,agloc_name = l.ptloc_name
			,agpay_chk_no = p.ptpay_check_no
			,agpay_ref_no = p.ptpay_ref_no
			,agpay_batch_no = p.ptpay_batch_no
			,agpay_orig_rev_dt = (case len(convert(varchar, p.ptpay_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, p.ptpay_orig_rev_dt) AS CHAR(12)), 112) else null end)
			,agpay_ivc_no = p.ptpay_invc_no
			,agpay_seq_no = p.ptpay_orig_cr_seq_no
			,agpay_amt = p.ptpay_amt
		from
			ptpaymst p --agpaymst p
			,ptlocmst l --aglocmst l
		where
		 p.ptpay_loc_no = l.ptloc_loc_no
		')
GO

