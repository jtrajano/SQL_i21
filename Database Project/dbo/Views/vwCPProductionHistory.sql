CREATE VIEW [dbo].[vwCPProductionHistory]
AS
select
	a.A4GLIdentity
	,b.ssspl_desc
	,b.ssspl_rec_type
	,a.gaphs_spl_no
	,gaphs_dlvry_rev_dt = (case len(convert(varchar, a.gaphs_dlvry_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gaphs_dlvry_rev_dt) AS CHAR(12)), 112) else null end)
	,a.gaphs_loc_no
	,a.gaphs_tic_no
	,a.gaphs_gross_un
	,a.gaphs_wet_un
	,a.gaphs_net_un
	,a.gaphs_cus_no
	,a.gaphs_com_cd
	,c.gacom_desc
	,c.gacom_un_desc
	,a.gaphs_fees
    ,a.gaphs_gross_wgt
    ,a.gaphs_tare_wgt
    ,a.gaphs_cus_ref_no
    ,a.gaphs_pur_sls_ind
from
	gacommst c
	,gaphsmst a
left outer join
	sssplmst b 
	on a.gaphs_cus_no = b.ssspl_bill_to_cus
	and a.gaphs_spl_no = b.ssspl_split_no
	and b.ssspl_rec_type in ('G', 'B') 
where
	(c.gacom_com_cd = a.gaphs_com_cd)
	--and (a.gaphs_dlvry_rev_dt >= @gaphs_dlvry_rev_dt)
	--and (a.gaphs_dlvry_rev_dt <= @gaphs_dlvry_rev_dt1)
	--and (a.gaphs_cus_no = @gaphs_cus_no) 
    --and (a.gaphs_com_cd = @gaphs_com_cd)
    --and (a.gaphs_pur_sls_ind = @gaphs_pur_sls_ind)
--order by
	--a.gaphs_cus_no
	--,a.gaphs_spl_no
	--,a.gaphs_com_cd