GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPurchasesDetail')
	DROP VIEW vwCPPurchasesDetail
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPPurchasesDetail')
	DROP VIEW vyuCPPurchasesDetail
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPPurchasesDetail]
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
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPPurchasesDetail]
		AS
		select
			a.A4GLIdentity
			,agstm_bill_to_cus = a.ptstm_bill_to_cus
			,agstm_itm_no = a.ptstm_itm_no
			,agstm_sls = a.ptstm_net
			,agstm_un = a.ptstm_un
			,agstm_un_desc = a.ptstm_un_desc
			,agstm_loc_no = a.ptstm_loc_no
			,agstm_ship_rev_dt = (case len(convert(varchar, a.ptstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.ptstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
			,a.ptstm_un_prc * a.ptstm_ship_total as agstm_un_prc
			,agstm_ivc_no = a.ptstm_ivc_no
			,agitm_desc = b.ptitm_desc
		from
			ptstmmst a --agstmmst a
		left outer join
			ptitmmst b --agitmmst b
			on
				a.ptstm_loc_no = b.ptitm_loc_no
				and a.ptstm_itm_no = b.ptitm_itm_no 
		where
			(a.ptstm_rec_type = 5)
		')
GO
