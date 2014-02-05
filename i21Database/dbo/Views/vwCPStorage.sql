CREATE VIEW [dbo].[vwCPStorage]
AS
select
	gastr_stor_type
	,gastr_loc_no
	,gastr_dlvry_rev_dt = (case len(convert(varchar, gastr_dlvry_rev_dt)) when 8 then convert(date, cast(convert(varchar, gastr_dlvry_rev_dt) AS CHAR(12)), 112) else null end)
	,gastr_tic_no
	,gastr_spl_no
	,gastr_dpa_or_rcpt_no
	,gastr_un_disc_due
	,gastr_un_disc_pd
	,gastr_un_stor_due
	,gastr_stor_schd_no
	,gastr_un_bal
	,gastr_cus_no
	,gastr_com_cd
	,gastr_tie_breaker
	,gastr_un_stor_pd
	,gastr_pur_sls_ind
	,A4GLIdentity
from
	gastrmst
where
	(gastr_un_bal > 0)
	--and (gastr_cus_no = @gastr_cus_no)
	--and (gastr_pur_sls_ind = @gastr_pur_sls_ind)
	--and (gastr_com_cd = @gastr_com_cd)
    --and (gastr_tic_no = @gastr_tic_no)