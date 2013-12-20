
















CREATE VIEW [dbo].[vwCPGABusinessSummary]
AS
select
	a.A4GLIdentity
	,a.gastl_com_cd
	,a.gastl_pd_yn
	,a.gastl_rec_type
	,a.gastl_un_prc
	,a.gastl_cus_no
	,a.gastl_pur_sls_ind
	,a.gastl_no_un
	,a.gastl_stl_amt
	,a.gastl_un_disc_pd
	,a.gastl_un_disc_adj
	,a.gastl_un_stor_pd
	,a.gastl_ckoff_amt
	,a.gastl_ins_amt
	,a.gastl_fees_pd
	,a.gastl_un_frt_rt
	,a.gastl_loc_no
	,a.gastl_tic_no
	,a.gastl_spl_no
	,a.gastl_cnt_no
	,a.gastl_shrk_what_1
	,a.gastl_shrk_what_2
	,a.gastl_shrk_what_3
	,a.gastl_shrk_what_4
	,a.gastl_shrk_what_5
	,a.gastl_shrk_what_6
	,a.gastl_shrk_what_7
	,a.gastl_shrk_what_8
	,a.gastl_shrk_what_9
    ,a.gastl_shrk_what_10
    ,a.gastl_shrk_what_11
    ,a.gastl_shrk_what_12
    ,a.gastl_chk_no
    ,a.gastl_un_disc_amt_1
    ,a.gastl_un_disc_amt_2
    ,a.gastl_un_disc_amt_3
    ,a.gastl_un_disc_amt_4
    ,a.gastl_un_disc_amt_5
    ,a.gastl_un_disc_amt_6
    ,a.gastl_un_disc_amt_7
    ,a.gastl_un_disc_amt_8
    ,a.gastl_un_disc_amt_9
    ,a.gastl_un_disc_amt_10
    ,a.gastl_un_disc_amt_11
    ,a.gastl_un_disc_amt_12
    ,a.gastl_shrk_pct_1
    ,a.gastl_shrk_pct_2
    ,a.gastl_shrk_pct_3
    ,a.gastl_shrk_pct_4
    ,a.gastl_shrk_pct_5
    ,a.gastl_shrk_pct_6
    ,a.gastl_shrk_pct_7
    ,a.gastl_shrk_pct_8
    ,a.gastl_shrk_pct_9
    ,a.gastl_shrk_pct_10
    ,a.gastl_shrk_pct_11
    ,a.gastl_shrk_pct_12
    ,gastl_stl_rev_dt = (case len(convert(varchar, a.gastl_stl_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gastl_stl_rev_dt) AS CHAR(12)), 112) else null end)
    ,gastl_pmt_rev_dt = (case len(convert(varchar, a.gastl_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gastl_pmt_rev_dt) AS CHAR(12)), 112) else null end)
    ,0.00 as Storage
    ,0.00 as Drying
    ,0.00 as Discount
    ,0.00 as Gross
    ,'' as Type,0.00 as Units
    ,a.gastl_adj_ckoff_amt
    ,a.gastl_frt_rt
    ,a.gastl_adj_ins_amt
    ,a.gastl_frt_un
    ,b.gacom_ckoff_desc
    ,b.gacom_ins_desc
    ,'' as TypeDetails
    ,0.00 as Chk_Ins
from
	gastlmst a
	,gacommst b
where
	(a.gastl_pur_sls_ind = 'P')
	and (a.gastl_com_cd = b.gacom_com_cd)
	--and (a.gastl_cus_no = @gastl_cus_no)
	--and (a.gastl_stl_rev_dt >= @gastl_stl_rev_dt)
	--and (a.gastl_stl_rev_dt <= @gastl_stl_rev_dt1)
	--and (a.gastl_pmt_rev_dt >= @gastl_pmt_rev_dt)
	--and (a.gastl_pmt_rev_dt <= @gastl_pmt_rev_dt1)
	--and (a.gastl_com_cd = @gastl_com_cd)

