














CREATE VIEW [dbo].[vwCPBusinessSummary]
AS
select
	A4GLIdentity = row_number() over (order by a.agstm_loc_no)
	,a.agstm_bill_to_cus
	,a.agstm_itm_no
	,a.agstm_loc_no
	,a.agstm_class
	,b.agitm_desc
	,b.agitm_un_desc
	,c.agcls_desc
	,a.agstm_adj_inv_yn
	,sum(a.agstm_fet_amt) as agstm_fet_amt
	,sum(a.agstm_set_amt) as agstm_set_amt
	,sum(a.agstm_sst_amt) as agstm_sst_amt
	,sum(a.agstm_ppd_amt_applied) as agstm_ppd_amt_applied
	,sum(a.agstm_un) as quantity
	,sum(a.agstm_sls) as itemamount
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
	--and (a.agstm_bill_to_cus = @agstm_bill_to_cus)
	--and (a.agstm_ship_rev_dt between @agstm_ship_rev_dt and @agstm_ship_rev_dt1)
group by
	a.agstm_bill_to_cus
	,a.agstm_itm_no
	,a.agstm_loc_no
	,a.agstm_class
	,b.agitm_desc
	,b.agitm_un_desc
	,c.agcls_desc
	,a.agstm_adj_inv_yn
--order by
--	a.agstm_bill_to_cus
--	,a.agstm_class
--	,a.agstm_itm_no
--	,a.agstm_loc_no


