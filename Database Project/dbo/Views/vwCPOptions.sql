













CREATE VIEW [dbo].[vwCPOptions]
AS
select
	a.A4GLIdentity
	,a.gaopt_status_ind
	,a.gaopt_bot_opt
	,a.gaopt_ref_no
	,gaopt_exp_rev_dt = (case len(convert(varchar, a.gaopt_exp_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gaopt_exp_rev_dt) AS CHAR(12)), 112) else null end)
	,a.gaopt_buy_sell
	,a.gaopt_put_call
	,a.gaopt_un_prem
	,a.gaopt_un_srvc_fee
	,a.gaopt_no_un
	,a.gaopt_un_strk_prc
	,a.gaopt_com_cd
	,a.gaopt_cus_no
	,b.gacom_desc
	,b.gacom_un_desc
	,a.gaopt_prcd_no_un
	,a.gaopt_prcd_un_prc
	,a.gaopt_un_target_prc
from
	gaoptmst a
left outer join
	gacommst b
	on a.gaopt_com_cd = b.gacom_com_cd 
--where
	--(a.gaopt_com_cd = @gaopt_com_cd)
	--and (a.gaopt_cus_no = @gaopt_cus_no)
	--and (a.gaopt_pur_sls_ind = @gaopt_pur_sls_ind)

