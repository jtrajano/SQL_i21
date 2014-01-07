CREATE VIEW [dbo].[vwCPBABusinessSummaryServiceCharge]
AS
select
	dblCharge = isnull(agpay_amt, 0)
	,strCustomerNo = agpay_cus_no
	,dtmDate = (case len(convert(varchar, agpay_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, agpay_orig_rev_dt) AS CHAR(12)), 112) else null end)
	,strServiceCharge = 'N'
	,id = row_number() over (order by agpay_orig_rev_dt)
from
	agpaymst
where
	(agpay_chk_no = 'CHARGE' or agpay_ref_no = 'CHARGE')
--	and (agpay_cus_no = @agpay_cus_no)
--	and (agpay_orig_rev_dt >= @agpay_orig_rev_dt)
--	and (agpay_orig_rev_dt <= @agpay_orig_rev_dt1)
union all
select
	dblCharge = isnull(agivc_net_amt, 0)
	,strCustomerNo = agivc_bill_to_cus
	,dtmDate = (case len(convert(varchar, agivc_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, agivc_orig_rev_dt) AS CHAR(12)), 112) else null end)
	,strServiceCharge = 'Y'
	,id = row_number() over (order by agivc_orig_rev_dt)
from
	agivcmst
where
	(agivc_po_no = 'SERVICE CHARGE' or agivc_po_no = 'SRVC CHRG')
--	and (agivc_bill_to_cus = @agivc_bill_to_cus)
--	and (agivc_orig_rev_dt >= @agivc_orig_rev_dt)
--	and (agivc_orig_rev_dt <= @agivc_orig_rev_dt1)