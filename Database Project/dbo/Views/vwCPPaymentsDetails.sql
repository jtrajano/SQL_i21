﻿CREATE VIEW [dbo].[vwCPPaymentsDetails]
AS
select
	strCustomerNo = rtrim(ltrim(c.agcus_first_name)) + ' ' + rtrim(ltrim(c.agcus_last_name))
	,strCheckNo = agpay_chk_no
	,dblAmount = agpay_amt
	,strLocationNo = agpay_ivc_loc_no
	,strCreditInd = agpay_cred_ind
	,strReferenceNo = agpay_ref_no
	,dtmDate = (case len(convert(varchar, agpay_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, agpay_orig_rev_dt) AS CHAR(12)), 112) else null end)
	,strNote = agpay_note
	,strInvoiceNo = agpay_ivc_no
from
	agpaymst a, agcusmst c where c.agcus_key = agpay_cus_no
--where agpay_orig_rev_dt between 20120816 and 20131211 and agpay_cus_no = '0000000505'
union all
select
	strCustomerNo = rtrim(ltrim(c.agcus_first_name)) + ' ' + rtrim(ltrim(c.agcus_last_name))
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
left outer join
	agcusmst c on c.agcus_key = a.agpye_cus_no
--where a.agpye_rev_dt between 20120816 and 20131211 and a.agpye_cus_no = '0000000505'
union all
SELECT
	strCustomerNo = rtrim(ltrim(c.agcus_first_name)) + ' ' + rtrim(ltrim(c.agcus_last_name))
	,strCheckNo = 'Unapplied'
	,dblAmount = SUM(a.agcrd_amt - a.agcrd_amt_used)
	,strLocationNo = a.agcrd_loc_no
	,strCreditInd = a.agcrd_cred_ind
	,strReferenceNo = a.agcrd_ref_no
	,dtmDate = (case len(convert(varchar, a.agcrd_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agcrd_rev_dt) AS CHAR(12)), 112) else null end)
	,strNote = a.agcrd_note
	,strInvoiceNo = null
FROM
	agcrdmst a, agcusmst c
WHERE
	(a.agcrd_amt_used <> a.agcrd_amt)
	AND (a.agcrd_type IN ('P', 'A'))
	and c.agcus_key = a.agcrd_cus_no
--	and agcrd_rev_dt between 20120816 and 20131211 and agcrd_cus_no = '0000000505'
GROUP BY
	c.agcus_first_name
	,c.agcus_last_name
	,a.agcrd_loc_no
	,a.agcrd_cred_ind
	,a.agcrd_ref_no
	,a.agcrd_rev_dt
	,a.agcrd_cus_no
	,a.agcrd_note