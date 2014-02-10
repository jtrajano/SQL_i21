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
	--and (a.agstm_ship_rev_dt >= @agstm_ship_rev_dt)
	--and (a.agstm_ship_rev_dt <= @agstm_ship_rev_dt1)
	--and (a.agstm_bill_to_cus = @agstm_bill_to_cus)
	--and (a.agstm_itm_no = @agstm_itm_no)