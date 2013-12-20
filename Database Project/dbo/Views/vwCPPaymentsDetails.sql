













CREATE VIEW [dbo].[vwCPPaymentsDetails]
AS
select
	strCustomerNo = agpay_cus_no
	,strCheckNo = agpay_chk_no
	,dblAmount = agpay_amt
	,strLocationNo = agpay_ivc_loc_no
	,strCreditInd = agpay_cred_ind
	,strReferenceNo = agpay_ref_no
	,dtmDate = (case len(convert(varchar, agpay_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, agpay_orig_rev_dt) AS CHAR(12)), 112) else null end)
	,strNote = agpay_note
	,strInvoiceNo = agpay_ivc_no
from
	agpaymst a
--where agpay_orig_rev_dt between 20120816 and 20131211 and agpay_cus_no = '0000000505'
union all
select
	strCustomerNo = a.agpye_cus_no
	,strCheckNo = a.agpye_chk_no
	,dblAmount = a.agpye_amt
	,strLocationNo = a.agpye_ivc_loc_no
	,strCreditInd = a.agpye_cred_ind
	,strReferenceNo = a.agpye_ref_no
	,dtmDate = (case len(convert(varchar, a.agpye_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agpye_rev_dt) AS CHAR(12)), 112) else null end)
	,strNote = a.agpye_note
	,strInvoiceNo = b.agivc_ivc_no
from
	agpyemst a
left outer join
	agivcmst b on a.agpye_cus_no = b.agivc_bill_to_cus
	and a.agpye_inc_ref = b.agivc_ivc_no
	and a.agpye_ivc_loc_no = b.agivc_loc_no 
--where a.agpye_rev_dt between 20120816 and 20131211 and a.agpye_cus_no = '0000000505'
union all
SELECT
	strCustomerNo = agcrd_cus_no
	,strCheckNo = 'Unapplied'
	,dblAmount = SUM(agcrd_amt - agcrd_amt_used)
	,strLocationNo = agcrd_loc_no
	,strCreditInd = agcrd_cred_ind
	,strReferenceNo = agcrd_ref_no
	,dtmDate = (case len(convert(varchar, agcrd_rev_dt)) when 8 then convert(date, cast(convert(varchar, agcrd_rev_dt) AS CHAR(12)), 112) else null end)
	,strNote = agcrd_note
	,strInvoiceNo = null
FROM
	agcrdmst
WHERE
	(agcrd_amt_used <> agcrd_amt)
	AND (agcrd_type IN ('P', 'A'))
--	and agcrd_rev_dt between 20120816 and 20131211 and agcrd_cus_no = '0000000505'
GROUP BY
	agcrd_cus_no
	,agcrd_loc_no
	,agcrd_cred_ind
	,agcrd_ref_no
	,agcrd_rev_dt
	,agcrd_cus_no
	,agcrd_note



