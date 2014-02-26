IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPBABusinessSummary')
	DROP VIEW vwCPBABusinessSummary

GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPBABusinessSummary]
		AS
		select
			A4GLIdentity = row_number() over (order by a.agstm_loc_no)
			,strCustomerNo = a.agstm_bill_to_cus
			,strItem = a.agstm_itm_no
			,strLocation = a.agstm_loc_no
			,strClass = a.agstm_class
			,strDescription = b.agitm_desc
			,strUnitDescription = b.agitm_un_desc
			,strClassDescription = c.agcls_desc
			,strAdjustmentInventory = a.agstm_adj_inv_yn
			,a.agstm_fet_amt
			,a.agstm_set_amt
			,a.agstm_sst_amt
			,a.agstm_ppd_amt_applied
			,dblQuantity = a.agstm_un
			,dblAmount = a.agstm_sls
			,dtmShipmentDate = (case len(convert(varchar, a.agstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
			,dblTotalAmount = 0.00
		from
			agstmmst a
		left outer join
			agclsmst c
			on a.agstm_class = c.agcls_cd
		left outer join
			agitmmst b
			on a.agstm_itm_no = b.agitm_no
			and a.agstm_loc_no = b.agitm_loc_no 
		where
			(a.agstm_rec_type = ''5'')
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPBABusinessSummary]
		AS
			select
			A4GLIdentity = row_number() over (order by a.ptstm_loc_no)
			,strCustomerNo = a.ptstm_bill_to_cus
			,strItem = a.ptstm_itm_no
			,strLocation = a.ptstm_loc_no
			,strClass = a.ptstm_class
			,strDescription = b.ptitm_desc
			,strUnitDescription = b.ptitm_unit
			,strClassDescription = c.ptcls_desc
			,strAdjustmentInventory = a.ptstm_adj_inv_yn
			,agstm_fet_amt = a.ptstm_fet_amt
			,agstm_set_amt = a.ptstm_set_amt
			,agstm_sst_amt = a.ptstm_sst_amt
			,agstm_ppd_amt_applied = null--a.agstm_ppd_amt_applied
			,dblQuantity = a.ptstm_un
			,dblAmount = null--a.agstm_sls
			,dtmShipmentDate = (case len(convert(varchar, a.ptstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.ptstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
			,dblTotalAmount = 0.00
		from
			ptstmmst a
		left outer join
			ptclsmst c
			on a.ptstm_class = c.ptcls_class
		left outer join
			ptitmmst b
			on a.ptstm_itm_no = b.ptitm_itm_no
			and a.ptstm_loc_no = b.ptitm_loc_no 
		where
			(a.ptstm_rec_type = ''5'')
		')

GO
