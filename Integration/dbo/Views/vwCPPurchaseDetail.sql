IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPurchaseDetail')
	DROP VIEW vwCPPurchaseDetail
GO

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPPurchaseDetail]
		AS
		select distinct
			a.A4GLIdentity
			,a.agstm_bill_to_cus
			,a.agstm_itm_no
			,a.agstm_loc_no
			,a.agstm_ivc_no
			,agstm_ship_rev_dt = (case len(convert(varchar, a.agstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
			,b.agitm_desc
			,a.agstm_un
			,a.agstm_un_desc
			,a.agstm_un_prc * (a.agstm_pkg_ship * a.agstm_un_per_pak) as agstm_amount
		from
			agstmmst a
			,agitmmst b
		where
			a.agstm_itm_no = b.agitm_no
			and (a.agstm_rec_type = 5)
		')
GO

-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPPurchaseDetail]
		AS
		SELECT DISTINCT
			A4GLIdentity = 0
			,agstm_bill_to_cus  = ''''
			,agstm_itm_no = ''''
			,agstm_loc_no = ''''
			,agstm_ivc_no = ''''
			,stm_ship_rev_dt = getdate()
			,agitm_desc = ''''
			,agstm_un = ''''
			,agstm_un_desc = ''''
			,agstm_amount = 0
		')
GO