GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPendingPayments')
	DROP VIEW vwCPPendingPayments
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPPendingPayments')
	DROP VIEW vyuCPPendingPayments
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPPendingPayments]
		AS
		select
			a.agpye_chk_no
			,agpye_rev_dt = (case len(convert(varchar, a.agpye_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agpye_rev_dt) AS CHAR(12)), 112) else null end)
			,agpye_amt = sum(a.agpye_amt)
			,b.agivc_bill_to_cus
			,A4GLIdentity = row_number() over (order by a.agpye_chk_no)
		from agpyemst a
		left outer join agivcmst b
			on a.agpye_cus_no = b.agivc_bill_to_cus
			and a.agpye_inc_ref = b.agivc_ivc_no
			and a.agpye_ivc_loc_no = b.agivc_loc_no 
		group by 
			a.agpye_chk_no
			,agpye_rev_dt
			,b.agivc_bill_to_cus

		')

GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPPendingPayments]
		AS
		select
			a.ptpye_check_no
			,agpye_rev_dt = (case len(convert(varchar, a.ptpye_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.ptpye_rev_dt) AS CHAR(12)), 112) else null end)
			,agpye_amt = sum(a.ptpye_amt)
			,b.ptivc_cus_no
			,A4GLIdentity = row_number() over (order by a.ptpye_check_no)
		from ptpyemst a --agpyemst a
		left outer join ptivcmst b --agivcmst b
			on a.ptpye_cus_no = b.ptivc_cus_no
			and a.ptpye_inc_ref = b.ptivc_invc_no
			and a.ptpye_ivc_loc_no = b.ptivc_loc_no 
		group by 
			a.ptpye_check_no
			,ptpye_rev_dt
			,b.ptivc_cus_no
		')
GO
