/****** Object:  View [dbo].[vwCPDatabaseDate]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPDatabaseDate]'))
EXEC dbo.sp_executesql @statement = N'


















CREATE VIEW [dbo].[vwCPDatabaseDate]
AS
select
	id = 1
	,dbdate = GETDATE()



'
GO
/****** Object:  View [dbo].[vwCPBABusinessSummaryServiceCharge]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPBABusinessSummaryServiceCharge]'))
EXEC dbo.sp_executesql @statement = N'




















CREATE VIEW [dbo].[vwCPBABusinessSummaryServiceCharge]
AS
select
	dblCharge = isnull(agpay_amt, 0)
	,strCustomerNo = agpay_cus_no
	,dtmDate = (case len(convert(varchar, agpay_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, agpay_orig_rev_dt) AS CHAR(12)), 112) else null end)
	,strServiceCharge = ''N''
	,id = row_number() over (order by agpay_orig_rev_dt)
from
	agpaymst
where
	(agpay_chk_no = ''CHARGE'' or agpay_ref_no = ''CHARGE'')
--	and (agpay_cus_no = @agpay_cus_no)
--	and (agpay_orig_rev_dt >= @agpay_orig_rev_dt)
--	and (agpay_orig_rev_dt <= @agpay_orig_rev_dt1)
union all
select
	dblCharge = isnull(agivc_net_amt, 0)
	,strCustomerNo = agivc_bill_to_cus
	,dtmDate = (case len(convert(varchar, agivc_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, agivc_orig_rev_dt) AS CHAR(12)), 112) else null end)
	,strServiceCharge = ''Y''
	,id = row_number() over (order by agivc_orig_rev_dt)
from
	agivcmst
where
	(agivc_po_no = ''SERVICE CHARGE'' or agivc_po_no = ''SRVC CHRG'')
--	and (agivc_bill_to_cus = @agivc_bill_to_cus)
--	and (agivc_orig_rev_dt >= @agivc_orig_rev_dt)
--	and (agivc_orig_rev_dt <= @agivc_orig_rev_dt1)


'
GO
/****** Object:  View [dbo].[vwCPBABusinessSummary]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPBABusinessSummary]'))
EXEC dbo.sp_executesql @statement = N'


















CREATE VIEW [dbo].[vwCPBABusinessSummary]
AS
select
	A4GLIdentity = row_number() over (order by a.agstm_loc_no)
	,strCustomerNo = a.agstm_bill_to_cus
	,strItem = a.agstm_itm_no
	,strLocation = a.agstm_loc_no
	,strClass = a.agstm_class
	,strDescription = b.agitm_desc
	,strUnitDescription = b.agitm_un_desc
	,strClassDescription = c.agcls_desc
	,strAdjustmentInventory = a.agstm_adj_inv_yn
	,a.agstm_fet_amt
	,a.agstm_set_amt
	,a.agstm_sst_amt
	,a.agstm_ppd_amt_applied
	,dblQuantity = a.agstm_un
	,dblAmount = a.agstm_sls
	,dtmShipmentDate = (case len(convert(varchar, a.agstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
	,dblTotalAmount = 0.00
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
	(a.agstm_rec_type = ''5'')
--	and (a.agstm_bill_to_cus = ''0000000505'')
--	and (a.agstm_ship_rev_dt between @agstm_ship_rev_dt and @agstm_ship_rev_dt1)
--group by
--	a.agstm_bill_to_cus
--	,a.agstm_itm_no
--	,a.agstm_loc_no
--	,a.agstm_class
--	,b.agitm_desc
--	,b.agitm_un_desc
--	,c.agcls_desc
--	,a.agstm_adj_inv_yn
--	,a.agstm_ship_rev_dt
--order by
--	a.agstm_bill_to_cus
--	,a.agstm_class
--	,a.agstm_itm_no
--	,a.agstm_loc_no

'
GO
/****** Object:  View [dbo].[vwCPPurchaseDetail]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPurchaseDetail]'))
EXEC dbo.sp_executesql @statement = N'













CREATE VIEW [dbo].[vwCPPurchaseDetail]
AS

select distinct
	a.A4GLIdentity
	,a.agstm_bill_to_cus
	,a.agstm_itm_no
	,a.agstm_loc_no
	,a.agstm_ivc_no
	,agstm_ship_rev_dt = (case len(convert(varchar, a.agstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
	,b.agitm_desc
	,a.agstm_un
	,a.agstm_un_desc
	,a.agstm_un_prc * (a.agstm_pkg_ship * a.agstm_un_per_pak) as agstm_amount
from
	agstmmst a
	,agitmmst b
where
	a.agstm_itm_no = b.agitm_no
	and (a.agstm_rec_type = 5)
	--and (a.agstm_ship_rev_dt >= @agstm_ship_rev_dt)
	--and (a.agstm_ship_rev_dt <= @agstm_ship_rev_dt1)
	--and (a.agstm_bill_to_cus = @agstm_bill_to_cus)
	--and (a.agstm_itm_no = @agstm_itm_no)

'
GO
/****** Object:  View [dbo].[vwCPProductionHistory]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPProductionHistory]'))
EXEC dbo.sp_executesql @statement = N'













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
	and b.ssspl_rec_type in (''G'', ''B'') 
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

'
GO
/****** Object:  View [dbo].[vwCPPrepaidCredits]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPrepaidCredits]'))
EXEC dbo.sp_executesql @statement = N'





CREATE VIEW [dbo].[vwCPPrepaidCredits]
AS
select 
	A4GLIdentity = row_number() over (order by agcrd_loc_no)
	,agcrd_cus_no
	,agcrd_loc_no
	,agcrd_cred_ind
	,agcrd_ref_no
	,agcrd_rev_dt = (case len(convert(varchar, agcrd_rev_dt)) when 8 then convert(date, cast(convert(varchar, agcrd_rev_dt) AS CHAR(12)), 112) else null end)
	,sum(agcrd_amt - agcrd_amt_used) as agcrd_amt
from agcrdmst
where
	(agcrd_cred_ind = ''P'')
	and (agcrd_amt - agcrd_amt_used <> 0)
group by
	agcrd_cus_no
	,agcrd_loc_no
	,agcrd_cred_ind
	,agcrd_ref_no
	,agcrd_rev_dt




'
GO
/****** Object:  View [dbo].[vwCPPendingPayments]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPendingPayments]'))
EXEC dbo.sp_executesql @statement = N'










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



'
GO
/****** Object:  View [dbo].[vwCPPendingInvoices]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPendingInvoices]'))
EXEC dbo.sp_executesql @statement = N'


--select * from agordmst




CREATE VIEW [dbo].[vwCPPendingInvoices]
AS
SELECT DISTINCT
	a.agord_ivc_no
	,a.agord_ord_no
	,agord_ord_rev_dt = (case len(convert(varchar, a.agord_ord_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agord_ord_rev_dt) AS CHAR(12)), 112) else null end)
	,a.agord_type
	,a.agord_bill_to_split
	,a.agord_loc_no
	,b.agtrm_desc
	,a.agord_po_no
	,a.agord_order_total
	,a.agord_line_no
	,a.agord_bill_to_cus
	,a.agord_ship_type
	,a.agord_ship_total
	,a.A4GLIdentity
FROM
	agordmst AS a
INNER JOIN
	agtrmmst AS b 
	ON
		a.agord_terms_cd = b.agtrm_key_n
WHERE
	(a.agord_line_no = 1)
	AND (a.agord_type IN (''I'', ''B'', ''D'', ''C'', ''O''))
	AND (a.agord_ship_total <> 0)


'
GO
/****** Object:  View [dbo].[vwCPPaymentsDetails]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPaymentsDetails]'))
EXEC dbo.sp_executesql @statement = N'














CREATE VIEW [dbo].[vwCPPaymentsDetails]
AS
select
	strCustomerNo = rtrim(ltrim(c.agcus_first_name)) + '' '' + rtrim(ltrim(c.agcus_last_name))
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
--where agpay_orig_rev_dt between 20120816 and 20131211 and agpay_cus_no = ''0000000505''
union all
select
	strCustomerNo = rtrim(ltrim(c.agcus_first_name)) + '' '' + rtrim(ltrim(c.agcus_last_name))
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
--where a.agpye_rev_dt between 20120816 and 20131211 and a.agpye_cus_no = ''0000000505''
union all
SELECT
	strCustomerNo = rtrim(ltrim(c.agcus_first_name)) + '' '' + rtrim(ltrim(c.agcus_last_name))
	,strCheckNo = ''Unapplied''
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
	AND (a.agcrd_type IN (''P'', ''A''))
	and c.agcus_key = a.agcrd_cus_no
--	and agcrd_rev_dt between 20120816 and 20131211 and agcrd_cus_no = ''0000000505''
GROUP BY
	c.agcus_first_name
	,c.agcus_last_name
	,a.agcrd_loc_no
	,a.agcrd_cred_ind
	,a.agcrd_ref_no
	,a.agcrd_rev_dt
	,a.agcrd_cus_no
	,a.agcrd_note




'
GO
/****** Object:  View [dbo].[vwCPPayments]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPayments]'))
EXEC dbo.sp_executesql @statement = N'











CREATE VIEW [dbo].[vwCPPayments]
AS
select
	p.A4GLIdentity
	,l.agloc_name
	,p.agpay_chk_no
	,p.agpay_ref_no
	,p.agpay_batch_no
	,agpay_orig_rev_dt = (case len(convert(varchar, p.agpay_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, p.agpay_orig_rev_dt) AS CHAR(12)), 112) else null end)
	,p.agpay_ivc_no
	,p.agpay_seq_no
	,p.agpay_amt
from
	agpaymst p
	,aglocmst l
where
 p.agpay_loc_no = l.agloc_loc_no
 --and (p.agpay_cus_no = @agpay_cus_no)
 --and (p.agpay_chk_no = @agpay_chk_no)
--order by p.agpay_orig_rev_dt

'
GO
/****** Object:  View [dbo].[vwCPOrders]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPOrders]'))
EXEC dbo.sp_executesql @statement = N'












CREATE VIEW [dbo].[vwCPOrders]
AS
SELECT DISTINCT
	a.A4GLIdentity
	,a.agord_ord_no
	,agord_ord_rev_dt = (case len(convert(varchar, a.agord_ord_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agord_ord_rev_dt) AS CHAR(12)), 112) else null end)
	,a.agord_type
	,a.agord_bill_to_split
	,a.agord_loc_no
	,b.agtrm_desc
	,a.agord_po_no
	,a.agord_order_total
	,a.agord_line_no
	,a.agord_bill_to_cus
	,a.agord_ship_type
	,a.agord_ship_total
	,a.agord_ivc_no
FROM
	agordmst AS a
INNER JOIN
	agtrmmst AS b
	ON a.agord_terms_cd = b.agtrm_key_n
WHERE
	--(a.agord_cus_no = @agord_cus_no)
	--AND (a.agord_ord_rev_dt >= @agord_ord_rev_dt_to)
	--AND (a.agord_ord_rev_dt <= @agord_ord_rev_dt_from)
	(a.agord_line_no = 1)
	--AND (a.agord_type LIKE @agord_type)
	AND (a.agord_type <> ''Q'')



'
GO
/****** Object:  View [dbo].[vwCPOptions]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPOptions]'))
EXEC dbo.sp_executesql @statement = N'














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
	,a.gaopt_pur_sls_ind
from
	gaoptmst a
left outer join
	gacommst b
	on a.gaopt_com_cd = b.gacom_com_cd 
--where
	--(a.gaopt_com_cd = @gaopt_com_cd)
	--and (a.gaopt_cus_no = @gaopt_cus_no)
	--and (a.gaopt_pur_sls_ind = @gaopt_pur_sls_ind)


'
GO
/****** Object:  View [dbo].[vwCPInvoicesCreditsReports]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPInvoicesCreditsReports]'))
EXEC dbo.sp_executesql @statement = N'













CREATE VIEW [dbo].[vwCPInvoicesCreditsReports]
AS
select
	strCompanyName = rtrim(ltrim(c.coctl_co_name))
	,strCompanyAddress = rtrim(ltrim(c.coctl_co_addr))
	,strCompanyAddress2 = rtrim(ltrim(c.coctl_co_addr2))
	,strCompanyCityStateZip = rtrim(ltrim(c.coctl_co_city)) + '', '' + rtrim(ltrim(c.coctl_co_state)) + '' '' + rtrim(ltrim(c.coctl_co_zip))
	,strCustomerName = rtrim(ltrim(t.agcus_first_name)) + '' '' + rtrim(ltrim(t.agcus_last_name))
	,strCustomerAddress = rtrim(ltrim(t.agcus_addr))
	,strCustomerCityStateZip = rtrim(ltrim(t.agcus_city)) + '', '' + rtrim(ltrim(t.agcus_state)) + '' '' + rtrim(ltrim(t.agcus_zip))
	,strInvoiceNo = rtrim(ltrim(v.agivc_ivc_no))
	,dtmOrderDate = (case len(convert(varchar, d.agstm_ord_rev_dt)) when 8 then convert(date, cast(convert(varchar, d.agstm_ord_rev_dt) AS CHAR(12)), 112) else null end)
	,strAccountNo = rtrim(ltrim(t.agcus_key))
	,strOrderNo = rtrim(ltrim(v.agivc_ivc_no))
	,strPONo = rtrim(ltrim(v.agivc_po_no))
	,dtmShipDate = (case len(convert(varchar, d.agstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, d.agstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
	,strTerms = rtrim(ltrim(d.agstm_terms_desc))
	,strSalesMan = rtrim(ltrim(v.agivc_slsmn_no))
	,strLocationNo = rtrim(ltrim(v.agivc_loc_no))
	,strComment = rtrim(ltrim(v.agivc_comment))
	,strItemNo = rtrim(ltrim(dd.agstm_itm_no))
	,strDescription = ''''
	,strUnitsSold = convert(nvarchar, round(dd.agstm_un, 4)) + '' '' + rtrim(ltrim(dd.agstm_un_desc))
	,dblUnitrice = round(dd.agstm_un_prc, 4)
	,dblExtended = convert(decimal(10,2),(dd.agstm_un * dd.agstm_un_prc))
	,strTax = ''GROUND WATER TAX''
	,strTaxUnitsSold = convert(nvarchar, round(dd.agstm_un, 4)) + '' '' + dd.agstm_un_desc
	,dblTaxUnitPrice = round(cast(dd.agstm_lc1_rt as float), 4)
	--,dblTaxExtended = convert(decimal(10,2), (((dd.agstm_un * dd.agstm_un_prc) * dd.agstm_lc1_rt)/100))
	,dblTaxExtended = convert(decimal(10,2), ((dd.agstm_pkg_ship * dd.agstm_un_per_pak) * dd.agstm_un_prc))
from coctlmst c, agcusmst t, agivcmst v, agstmmst d, agstmmst dd
where v.agivc_bill_to_cus = t.agcus_key
	and d.agstm_bill_to_cus = t.agcus_key
	and d.agstm_ivc_no = v.agivc_ivc_no
	and d.agstm_rec_type = 1
	and dd.agstm_bill_to_cus = t.agcus_key
	and dd.agstm_ivc_no = v.agivc_ivc_no
	and dd.agstm_rec_type = 5
	--and t.agcus_key = ''0000000505''
	--and v.agivc_ivc_no = ''00222145''


'
GO
/****** Object:  View [dbo].[vwCPInvoicesCredits]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPInvoicesCredits]'))
EXEC dbo.sp_executesql @statement = N'



CREATE VIEW [dbo].[vwCPInvoicesCredits]
AS

select
	a.A4GLIdentity
	,a.agivc_bill_to_cus
	,a.agivc_ivc_no
	,a.agivc_loc_no
	,a.agivc_type
	,a.agivc_status
	,agivc_rev_dt = (case len(convert(varchar, a.agivc_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agivc_rev_dt) AS CHAR(12)), 112) else null end)
	,a.agivc_comment
	,a.agivc_po_no
	,a.agivc_sold_to_cus
	,a.agivc_slsmn_no
	,a.agivc_slsmn_tot
	,a.agivc_net_amt
	,a.agivc_slstx_amt
    ,a.agivc_srvchr_amt
	,a.agivc_disc_amt
	,a.agivc_amt_paid
	,a.agivc_bal_due
	,a.agivc_pend_disc
	,a.agivc_no_payments
    ,a.agivc_adj_inv_yn
	,a.agivc_srvchr_cd
	,agivc_disc_rev_dt = (case len(convert(varchar, a.agivc_disc_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agivc_disc_rev_dt) AS CHAR(12)), 112) else null end)
	,agivc_net_rev_dt = (case len(convert(varchar, a.agivc_net_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agivc_net_rev_dt) AS CHAR(12)), 112) else null end)
	,a.agivc_src_sys
	,a.agivc_orig_rev_dt--agivc_orig_rev_dt = (case len(convert(varchar, a.agivc_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agivc_orig_rev_dt) AS CHAR(12)), 112) else null end)
    ,a.agivc_split_no
	,a.agivc_pd_days_old
	,a.agivc_eft_ivc_paid_yn
	,a.agivc_terms_code
	,b.agloc_name
	,c.agcrd_amt
    ,c.agcrd_amt_used
from agivcmst a 
	left outer join aglocmst b 
		on a.agivc_loc_no = b.agloc_loc_no 
	left outer join agcrdmst c 
		on a.agivc_bill_to_cus = c.agcrd_cus_no 
		and a.agivc_orig_rev_dt = c.agcrd_rev_dt 
		and a.agivc_ivc_no = c.agcrd_ref_no
		
--where a.agivc_bill_to_cus = ''0000000505''


'
GO
/****** Object:  View [dbo].[vwCPGAContracts]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPGAContracts]'))
EXEC dbo.sp_executesql @statement = N'









CREATE VIEW [dbo].[vwCPGAContracts]
AS
select
	a.gacnt_loc_no
	,a.gacnt_cnt_no
	,a.gacnt_seq_no
	,gacnt_due_rev_dt = (case len(convert(varchar, a.gacnt_due_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gacnt_due_rev_dt) AS CHAR(12)), 112) else null end)
	,a.gacnt_comments
	,a.gacnt_trk_rail_ind
	,a.gacnt_pbhcu_ind
	,a.gacnt_un_bot_basis
	,a.gacnt_un_cash_prc
	,a.gacnt_un_bot_prc
	,a.gacnt_com_cd
	,a.gacnt_cus_no
	,b.gacom_desc
	,a.gacnt_un_bal
	,a.gacnt_un_bal_unprc
	,status = (case when a.gacnt_un_bal > 0 then ''Open'' else ''Closed'' end)
	,a.gacnt_pur_sls_ind
	,a.gacnt_un_frt_basis
	,'''' as Remarks
	,a.gacnt_remarks_1
	,a.gacnt_remarks_2
	,a.gacnt_remarks_3
	,a.gacnt_remarks_4
	,a.gacnt_remarks_5
	,a.gacnt_remarks_6
	,a.gacnt_remarks_7
	,a.gacnt_remarks_8
	,a.gacnt_remarks_9
	,a.A4GLIdentity
from
	gacntmst a
left outer join
	gacommst b
	on a.gacnt_com_cd = b.gacom_com_cd
--where
--	(a.gacnt_cus_no = @gacnt_cus_no)
--	and (a.gacnt_com_cd = @gacnt_com_cd)
--	and (a.gacnt_pur_sls_ind = @gacnt_pur_sls_ind)

'
GO
/****** Object:  View [dbo].[vwCPGABusinessSummary]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPGABusinessSummary]'))
EXEC dbo.sp_executesql @statement = N'


















CREATE VIEW [dbo].[vwCPGABusinessSummary]
AS
WITH GAS
AS 
(
	SELECT 
	 CASE WHEN (ISNULL(a.gastl_shrk_what_1, '''') <> '''' and a.gastl_shrk_what_1 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_1)
		  WHEN (ISNULL(a.gastl_shrk_what_1, '''') <> '''' and a.gastl_shrk_what_1 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_1 + a.gastl_shrk_pct_1 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_2, '''') <> '''' and a.gastl_shrk_what_2 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_2)
		  WHEN (ISNULL(a.gastl_shrk_what_2, '''') <> '''' and a.gastl_shrk_what_2 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_2 + a.gastl_shrk_pct_2 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_3, '''') <> '''' and a.gastl_shrk_what_3 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_3)
		  WHEN (ISNULL(a.gastl_shrk_what_3, '''') <> '''' and a.gastl_shrk_what_3 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_3 + a.gastl_shrk_pct_3 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_4, '''') <> '''' and a.gastl_shrk_what_4 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_4)
		  WHEN (ISNULL(a.gastl_shrk_what_4, '''') <> '''' and a.gastl_shrk_what_4 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_4 + a.gastl_shrk_pct_4 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_5, '''') <> '''' and a.gastl_shrk_what_5 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_5)
		  WHEN (ISNULL(a.gastl_shrk_what_5, '''') <> '''' and a.gastl_shrk_what_5 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_5 + a.gastl_shrk_pct_5 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_6, '''') <> '''' and a.gastl_shrk_what_6 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_6)
		  WHEN (ISNULL(a.gastl_shrk_what_6, '''') <> '''' and a.gastl_shrk_what_6 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_6 + a.gastl_shrk_pct_6 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_7, '''') <> '''' and a.gastl_shrk_what_7 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_7)
		  WHEN (ISNULL(a.gastl_shrk_what_7, '''') <> '''' and a.gastl_shrk_what_7 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_7 + a.gastl_shrk_pct_7 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_8, '''') <> '''' and a.gastl_shrk_what_8 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_8)
		  WHEN (ISNULL(a.gastl_shrk_what_8, '''') <> '''' and a.gastl_shrk_what_8 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_8 + a.gastl_shrk_pct_8 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_9, '''') <> '''' and a.gastl_shrk_what_9 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_9)
		  WHEN (ISNULL(a.gastl_shrk_what_9, '''') <> '''' and a.gastl_shrk_what_9 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_9 + a.gastl_shrk_pct_9 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_10, '''') <> '''' and a.gastl_shrk_what_10 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_10)
		  WHEN (ISNULL(a.gastl_shrk_what_10, '''') <> '''' and a.gastl_shrk_what_10 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_10 + a.gastl_shrk_pct_10 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_11, '''') <> '''' and a.gastl_shrk_what_11 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_11)
		  WHEN (ISNULL(a.gastl_shrk_what_11, '''') <> '''' and a.gastl_shrk_what_11 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_11 + a.gastl_shrk_pct_11 / 100 * a.gastl_un_prc)
		  WHEN (ISNULL(a.gastl_shrk_what_12, '''') <> '''' and a.gastl_shrk_what_12 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_12)
		  WHEN (ISNULL(a.gastl_shrk_what_12, '''') <> '''' and a.gastl_shrk_what_12 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_12 + a.gastl_shrk_pct_12 / 100 * a.gastl_un_prc)
	END AS drying, a.A4GLIdentity
	FROM gastlmst a
),
GAS2
as
(
	SELECT 
	 CASE WHEN (ISNULL(a.gastl_ckoff_amt, 0) <> 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) <> 0) THEN (isnumeric(a.gastl_ckoff_amt) + isnumeric(a.gastl_ins_amt) + isnumeric(a.gastl_fees_pd))
		  WHEN (ISNULL(a.gastl_ckoff_amt, 0) <> 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) = 0) THEN (isnumeric(a.gastl_ckoff_amt) + isnumeric(a.gastl_ins_amt))
		  WHEN (ISNULL(a.gastl_ckoff_amt, 0) <> 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) <> 0) THEN (isnumeric(a.gastl_ckoff_amt) + isnumeric(a.gastl_fees_pd))
		  WHEN (ISNULL(a.gastl_ckoff_amt, 0) <> 0 and ISNULL(a.gastl_ins_amt, 0) = 0 and ISNULL(a.gastl_fees_pd, 0) = 0) THEN (isnumeric(a.gastl_ckoff_amt))
		  
		  WHEN (ISNULL(a.gastl_ckoff_amt, 0) = 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) <> 0) THEN (isnumeric(a.gastl_ins_amt) + isnumeric(a.gastl_fees_pd))
		  WHEN (ISNULL(a.gastl_ckoff_amt, 0) = 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) = 0) THEN (isnumeric(a.gastl_ins_amt))
		  WHEN (ISNULL(a.gastl_ckoff_amt, 0) = 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) <> 0) THEN (isnumeric(a.gastl_fees_pd))
	END AS chkIns, a.A4GLIdentity
	FROM gastlmst a
),
GAS3
as
(
	SELECT 
	 CASE WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ckoff_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') <> '''') THEN b.gacom_ckoff_desc+''=''+convert(varchar,a.gastl_adj_ckoff_amt)
		  WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ckoff_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') = '''') THEN ''CKOFF=''+convert(varchar,a.gastl_adj_ckoff_amt)
	else ''''
	END AS recType, a.A4GLIdentity
	FROM gastlmst a, gacommst b where b.gacom_com_cd = a.gastl_com_cd and a.gastl_pur_sls_ind = ''P''
),
GAS4
as
(
	SELECT 
	 CASE WHEN ISNULL(a.gastl_rec_type, '''') = '''' THEN ''''
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''M'' THEN ''SPOT SALE''
		  WHEN (ISNULL(a.gastl_rec_type, '''') = ''C'' and isnull(a.gastl_cnt_no,'''') = '''') THEN ''CONT''
		  WHEN (ISNULL(a.gastl_rec_type, '''') = ''C'' and isnull(a.gastl_cnt_no,'''') <> '''') THEN ''CONT ''+Convert(varchar,a.gastl_cnt_no)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''F'' THEN ''FREIGHT @''+Convert(varchar,a.gastl_frt_rt)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''I'' THEN ''INTEREST''
		  --WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ckoff_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') <> '''') THEN b.gacom_ckoff_desc+''=''+convert(varchar,a.gastl_adj_ckoff_amt)
		  --WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ckoff_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') = '''') THEN ''CKOFF=''+convert(varchar,a.gastl_adj_ckoff_amt)
		  WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ins_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') <> '''') THEN b.gacom_ckoff_desc+''=''+convert(varchar,a.gastl_adj_ins_amt)
		  WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ins_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') = '''') THEN ''INS=''+convert(varchar,a.gastl_adj_ins_amt)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''D'' THEN ''BILLED ADV''
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''1'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_1, '''') from ecctlmst e)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''2'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_2, '''') from ecctlmst e)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''3'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_3, '''') from ecctlmst e)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''4'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_4, '''') from ecctlmst e)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''5'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_5, '''') from ecctlmst e)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''6'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_6, '''') from ecctlmst e)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''7'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_7, '''') from ecctlmst e)
		  WHEN ISNULL(a.gastl_rec_type, '''') = ''8'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_8, '''') from ecctlmst e)
	END AS recType, a.A4GLIdentity
	FROM gastlmst a, gacommst b where b.gacom_com_cd = a.gastl_com_cd and a.gastl_pur_sls_ind = ''P''
)
select
	a.A4GLIdentity
	,a.gastl_com_cd
	,gastl_pd_yn = (case a.gastl_pd_yn when ''Y'' then ''P'' else ''U'' end)
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
    ,Storage = (a.gastl_no_un * a.gastl_un_stor_pd)
    ,Drying = (SELECT TOP 1 drying FROM GAS where A4GLIdentity = a.A4GLIdentity)
    ,Discount = (SELECT TOP 1 (case when drying <= ((a.gastl_no_un * a.gastl_un_disc_pd) + (a.gastl_no_un * a.gastl_un_disc_adj)) then ((a.gastl_no_un * a.gastl_un_disc_pd) + (a.gastl_no_un * a.gastl_un_disc_adj) + (a.gastl_no_un * a.gastl_frt_rt)) - drying else (a.gastl_no_un * a.gastl_un_disc_pd) + (a.gastl_no_un * a.gastl_un_disc_adj) + (a.gastl_no_un * a.gastl_frt_rt) end) FROM GAS where A4GLIdentity = a.A4GLIdentity)
    ,Gross = a.gastl_stl_amt + (a.gastl_no_un * a.gastl_un_disc_pd) + (a.gastl_no_un * a.gastl_un_disc_adj) + (a.gastl_no_un * a.gastl_un_stor_pd) + a.gastl_ckoff_amt + a.gastl_ins_amt + a.gastl_fees_pd + (a.gastl_no_un * a.gastl_un_frt_rt)
    ,Type = (SELECT TOP 1 recType FROM GAS3 where A4GLIdentity = a.A4GLIdentity)+'' ''+(SELECT TOP 1 recType FROM GAS4 where A4GLIdentity = a.A4GLIdentity)
    ,Units = a.gastl_no_un
    ,a.gastl_adj_ckoff_amt
    ,a.gastl_frt_rt
    ,a.gastl_adj_ins_amt
    ,a.gastl_frt_un
    ,b.gacom_ckoff_desc
    ,b.gacom_ins_desc
    ,'''' as TypeDetails
    ,Chk_Ins = (SELECT TOP 1 chkIns FROM GAS2 where A4GLIdentity = a.A4GLIdentity)
from
	gastlmst a
	,gacommst b
where
	(a.gastl_pur_sls_ind = ''P'')
	and (a.gastl_com_cd = b.gacom_com_cd)
	--and (a.gastl_cus_no = @gastl_cus_no)
	--and (a.gastl_stl_rev_dt >= @gastl_stl_rev_dt)
	--and (a.gastl_stl_rev_dt <= @gastl_stl_rev_dt1)
	--and (a.gastl_pmt_rev_dt >= @gastl_pmt_rev_dt)
	--and (a.gastl_pmt_rev_dt <= @gastl_pmt_rev_dt1)
	--and (a.gastl_com_cd = @gastl_com_cd)

'
GO
/****** Object:  View [dbo].[vwCPCurrentCashBids]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPCurrentCashBids]'))
EXEC dbo.sp_executesql @statement = N'









CREATE VIEW [dbo].[vwCPCurrentCashBids]
AS
select
	a.A4GLIdentity
	,a.gaprc_com_cd
	,a.gaprc_un_cash_prc
	,b.gacom_desc
	,a.gaprc_loc_no
	,c.galoc_desc
	
from
	gacommst b
right outer join
	gaprcmst a
	on b.gacom_com_cd = a.gaprc_com_cd
left join
	galocmst c
	on c.galoc_loc_no = a.gaprc_loc_no
where
	(a.gaprc_un_cash_prc > 0)
	--and (a.gaprc_com_cd = @gaprc_com_cd)




'
GO
/****** Object:  View [dbo].[vwCPContracts]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPContracts]'))
EXEC dbo.sp_executesql @statement = N'














CREATE VIEW [dbo].[vwCPContracts]
AS
select distinct
	a.A4GLIdentity
	,a.agcnt_cnt_no
	,a.agcnt_loc_no
	,a.agcnt_amt_bal
	,agcnt_due_rev_dt = (case len(convert(varchar, a.agcnt_due_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agcnt_due_rev_dt) AS CHAR(12)), 112) else null end)
	,a.agcnt_hdr_comments
	,a.agcnt_ppd_yndm
	,a.agcnt_itm_or_cls
	,b.agitm_no
	,b.agitm_un_desc
	,a.agcnt_line_no
	,a.agcnt_un_bal
	,a.agcnt_cus_no
	, strStatus = (case when a.agcnt_un_bal > 0 then ''Open'' else ''Closed'' end)
from
	agcntmst a
left outer join
	agitmmst b 
	on 
		a.agcnt_itm_or_cls = b.agitm_no
		and a.agcnt_loc_no = b.agitm_loc_no
where
	(a.agcnt_itm_or_cls <> ''*'')
	--and (a.agcnt_cus_no = @agcnt_cus_no)
	--and (a.agcnt_cnt_no = @agcnt_cnt_no)
	and (a.agcnt_line_no <> 0)
--order by a.agcnt_cnt_no, a.agcnt_line_no


'
GO
/****** Object:  View [dbo].[vwCPBusinessSummary]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPBusinessSummary]'))
EXEC dbo.sp_executesql @statement = N'















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
	(a.agstm_rec_type = ''5'')
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



'
GO
/****** Object:  View [dbo].[vwCPStorage]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPStorage]'))
EXEC dbo.sp_executesql @statement = N'















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
'
GO
/****** Object:  View [dbo].[vwCPSettlements]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPSettlements]'))
EXEC dbo.sp_executesql @statement = N'








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
	,gastl_pd_yn = (case gastl_pd_yn when ''Y'' then ''P'' else ''U'' end)
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
	(gastl_rec_type <> ''F'')
	--and (gastl_pd_yn <> ''Y'')
	--and (gastl_cus_no = @gastl_cus_no)
	--and (gastl_stl_rev_dt >= @gastl_stl_rev_dt)
	--and (gastl_stl_rev_dt <= @gastl_stl_rev_dt1)
	--and (gastl_com_cd = @gastl_com_cd)
	--and (gastl_pur_sls_ind = @gastl_pur_sls_ind)



'
GO
/****** Object:  View [dbo].[vwCPPurchasesDetail]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPurchasesDetail]'))
EXEC dbo.sp_executesql @statement = N'











CREATE VIEW [dbo].[vwCPPurchasesDetail]
AS
select
	a.A4GLIdentity
	,a.agstm_bill_to_cus
	,a.agstm_itm_no
	,a.agstm_sls
	,a.agstm_un
	,a.agstm_un_desc
	,a.agstm_loc_no
	,agstm_ship_rev_dt = (case len(convert(varchar, a.agstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
	,a.agstm_un_prc * (a.agstm_un_per_pak * a.agstm_pkg_ship) as agstm_un_prc
	,a.agstm_ivc_no
	,b.agitm_desc
from
	agstmmst a
left outer join
	agitmmst b
	on
		a.agstm_loc_no = b.agitm_loc_no
		and a.agstm_itm_no = b.agitm_no 
where
	(a.agstm_rec_type = 5)




'
GO
/****** Object:  View [dbo].[vwCPPurchases]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPurchases]'))
EXEC dbo.sp_executesql @statement = N'











CREATE VIEW [dbo].[vwCPPurchases]
AS
select
	a.A4GLIdentity
	,a.agstm_bill_to_cus
	,a.agstm_itm_no
	,a.agstm_sls
	,a.agstm_un
	,a.agstm_un_desc
	,a.agstm_loc_no
	,agstm_ship_rev_dt = (case len(convert(varchar, a.agstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
	,a.agstm_un_prc * (a.agstm_un_per_pak * a.agstm_pkg_ship) as agstm_un_prc
	,a.agstm_ivc_no
	,b.agitm_desc
from
	agstmmst a
left outer join
	agitmmst b
	on
		a.agstm_loc_no = b.agitm_loc_no
		and a.agstm_itm_no = b.agitm_no 
where
	(a.agstm_rec_type = 5)




'
GO
/****** Object:  View [dbo].[vwCPPurchaseMain]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPPurchaseMain]'))
EXEC dbo.sp_executesql @statement = N'














CREATE VIEW [dbo].[vwCPPurchaseMain]
AS

select distinct
	 id = row_number() over (order by agstm_bill_to_cus)
	,strCustomerNo = agstm_bill_to_cus
	,strItemNo = agstm_itm_no
	,strLocationNo = agstm_loc_no
	,strDescription = agitm_desc
	,intUnit = agstm_un
	,strUnitDescription = agstm_un_desc
	,dblAmount = sum(agstm_amount)
from
	vwCPPurchaseDetail
--where
--	agstm_ship_rev_dt between @datefrom and @dateto
--	and agstm_bill_to_cus = ''''
--	and agstm_itm_no = ''''
group by
	agstm_bill_to_cus
	,agstm_itm_no
	,agstm_loc_no
	,agitm_desc
	,agstm_un
	,agstm_un_desc

'
GO
/****** Object:  View [dbo].[vwCPBillingAccountPayments]    Script Date: 01/02/2014 16:47:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCPBillingAccountPayments]'))
EXEC dbo.sp_executesql @statement = N'

















CREATE VIEW [dbo].[vwCPBillingAccountPayments]
AS
SELECT
	   id = row_number() over (order by dblAmount)
      ,strCustomerNo
	  ,dtmDate
      ,strCheckNo
      ,dblAmount = sum(dblAmount)
  FROM vwCPPaymentsDetails
  GROUP BY dblAmount, dtmDate, strCheckNo,strCustomerNo
  --order by dtmDate







'
GO
