CREATE VIEW [dbo].[vwCPPendingPayments]
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
/*
select
	a.agpye_ivc_loc_no
	,a.agpye_cred_ind
	,a.agpye_chk_no
	,a.agpye_ref_no
	,agpye_rev_dt = (case len(convert(varchar, a.agpye_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agpye_rev_dt) AS CHAR(12)), 112) else null end)
	,a.agpye_amt
	,a.agpye_note
	,b.agivc_ivc_no
	,b.agivc_bill_to_cus
	,a.A4GLIdentity
from agpyemst a
left outer join agivcmst b
	on a.agpye_cus_no = b.agivc_bill_to_cus
	and a.agpye_inc_ref = b.agivc_ivc_no
	and a.agpye_ivc_loc_no = b.agivc_loc_no 
*/