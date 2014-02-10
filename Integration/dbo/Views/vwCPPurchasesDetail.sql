IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPurchasesDetail')
	DROP VIEW vwCPPurchasesDetail

GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPPurchasesDetail]
		AS
		select
			a.A4GLIdentity
			,a.agstm_bill_to_cus
			,a.agstm_itm_no
			,a.agstm_sls
			,a.agstm_un
			,a.agstm_un_desc
			,a.agstm_loc_no
			,agstm_ship_rev_dt = (case len(convert(varchar, a.agstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
			,a.agstm_un_prc * (a.agstm_un_per_pak * a.agstm_pkg_ship) as agstm_un_prc
			,a.agstm_ivc_no
			,b.agitm_desc
		from
			agstmmst a
		left outer join
			agitmmst b
			on
				a.agstm_loc_no = b.agitm_loc_no
				and a.agstm_itm_no = b.agitm_no 
		where
			(a.agstm_rec_type = 5)
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPPurchasesDetail]
		AS
		select ''PETRO here'' XX
		')
GO
