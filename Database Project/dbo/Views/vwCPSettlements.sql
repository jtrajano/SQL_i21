CREATE VIEW [dbo].[vwCPSettlements]
AS
select
	gastl_rec_type
	,gastl_no_un
	,gastl_stl_amt
	,gastl_loc_no
	,gastl_stl_rev_dt = (case len(convert(varchar, gastl_stl_rev_dt)) when 8 then convert(date, cast(convert(varchar, gastl_stl_rev_dt) AS CHAR(12)), 112) else null end)
	,gastl_tic_no
	,gastl_spl_no
	,gastl_ivc_no
	,gastl_defer_pmt_rev_dt = (case len(convert(varchar, gastl_defer_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, gastl_defer_pmt_rev_dt) AS CHAR(12)), 112) else null end)
	,gastl_cnt_no
	,gastl_pd_yn = (case gastl_pd_yn when 'Y' then 'P' else 'U' end)
	,gastl_cus_no
	,gastl_com_cd
	,gastl_tie_breaker
	,gastl_chk_no
	,gastl_un_prc
	,gastl_pur_sls_ind
	,gastl_pmt_rev_dt = (case len(convert(varchar, gastl_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, gastl_pmt_rev_dt) AS CHAR(12)), 112) else null end)
	,A4GLIdentity
from
	gastlmst
where
	(gastl_rec_type <> 'F')
	--and (gastl_pd_yn <> 'Y')
	--and (gastl_cus_no = @gastl_cus_no)
	--and (gastl_stl_rev_dt >= @gastl_stl_rev_dt)
	--and (gastl_stl_rev_dt <= @gastl_stl_rev_dt1)
	--and (gastl_com_cd = @gastl_com_cd)
	--and (gastl_pur_sls_ind = @gastl_pur_sls_ind)