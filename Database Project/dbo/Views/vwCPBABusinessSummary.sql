CREATE VIEW [dbo].[vwCPBABusinessSummary]
	AS select
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
	(a.agstm_rec_type = '5')
--	and (a.agstm_bill_to_cus = '0000000505')
--	and (a.agstm_ship_rev_dt between @agstm_ship_rev_dt and @agstm_ship_rev_dt1)
--group by
--	a.agstm_bill_to_cus
--	,a.agstm_itm_no
--	,a.agstm_loc_no
--	,a.agstm_class
--	,b.agitm_desc
--	,b.agitm_un_desc
--	,c.agcls_desc
--	,a.agstm_adj_inv_yn
--	,a.agstm_ship_rev_dt
--order by
--	a.agstm_bill_to_cus
--	,a.agstm_class
--	,a.agstm_itm_no
--	,a.agstm_loc_no
