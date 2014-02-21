IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPGASettlementsReports')
	DROP VIEW vwCPGASettlementsReports
GO
-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1
	EXEC ('
CREATE VIEW [dbo].[vwCPGASettlementsReports]
AS
select
	A4GLIdentity = row_number() over (order by a.gastl_tic_no)
	,strTicketNo = a.gastl_tic_no
	,strTieBreaker = ''-'' + convert(varchar,a.gastl_tie_breaker)
	--,strType = ''Type (supply from Main)''
	,strTicketComment = (case a.gastl_tic_comment when null then '''' else '''' end)
	,strCommodity = b.gacom_desc
	
	--COlumn 1
	,strLocationNo = a.gastl_loc_no
	,strSplitNo = a.gastl_spl_no
	,dtmDeliveryDate = (case len(convert(varchar, a.gastl_dlvry_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gastl_dlvry_rev_dt) AS CHAR(12)), 112) else null end)
	,strDiscSched = a.gastl_disc_schd_no
	,strEODAudit = a.gastl_audit_no
	
	--COlumn 2
	,dtmSettlementDate = (case len(convert(varchar, a.gastl_stl_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gastl_stl_rev_dt) AS CHAR(12)), 112) else null end)
	,dtmDeferPaymentDate = (case len(convert(varchar, a.gastl_defer_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gastl_defer_pmt_rev_dt) AS CHAR(12)), 112) else null end)
	,strDeferePaymentContract = a.gastl_defer_pmt_cnt_no
	,strReferenceNo = a.gastl_ivc_no
	,strCheckNo = a.gastl_chk_no
	,dtmCheckDate = (case len(convert(varchar, a.gastl_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gastl_pmt_rev_dt) AS CHAR(12)), 112) else null end)
	,strCurrencyRate = a.gastl_currency + '' '' + convert(varchar,a.gastl_currency_rt)
	
	--COlumn 3
	,intNumberOfUnits = a.gastl_no_un
	,dblSettlementAmount = a.gastl_stl_amt
	,dblFees = a.gastl_fees_pd
	,strCheckOff = b.gacom_ckoff_desc + '' : ''
	,strCheckOffValue = convert(varchar, a.gastl_ckoff_amt)
	,dblFreight = (a.gastl_no_un * a.gastl_un_frt_rt)
	
	--Column 4 
	,dblPrice = a.gastl_un_prc
	,dblDiscount = a.gastl_un_disc_pd
	,dblStorage = a.gastl_un_stor_pd
	
	--Details
	,colDiscount = c.gacdc_desc
	,c.gacdc_cd,
       a.gastl_disc_cd_1, a.gastl_reading_1, a.gastl_un_disc_amt_1, a.gastl_shrk_pct_1, a.gastl_shrk_what_1, 
       a.gastl_disc_cd_2, a.gastl_reading_2, a.gastl_un_disc_amt_2, a.gastl_shrk_pct_2, a.gastl_shrk_what_2, 
       a.gastl_disc_cd_3, a.gastl_reading_3, a.gastl_un_disc_amt_3, a.gastl_shrk_pct_3, a.gastl_shrk_what_3, 
       a.gastl_disc_cd_4, a.gastl_reading_4, a.gastl_un_disc_amt_4, a.gastl_shrk_pct_4, a.gastl_shrk_what_4, 
       a.gastl_disc_cd_5, a.gastl_reading_5, a.gastl_un_disc_amt_5, a.gastl_shrk_pct_5, a.gastl_shrk_what_5, 
       a.gastl_disc_cd_6, a.gastl_reading_6, a.gastl_un_disc_amt_6, a.gastl_shrk_pct_6, a.gastl_shrk_what_6, 
       a.gastl_disc_cd_7, a.gastl_reading_7, a.gastl_un_disc_amt_7, a.gastl_shrk_pct_7, a.gastl_shrk_what_7, 
       a.gastl_disc_cd_8, a.gastl_reading_8, a.gastl_un_disc_amt_8, a.gastl_shrk_pct_8, a.gastl_shrk_what_8,
       a.gastl_disc_cd_9, a.gastl_reading_9, a.gastl_un_disc_amt_9, a.gastl_shrk_pct_9, a.gastl_shrk_what_9, 
       a.gastl_disc_cd_10, a.gastl_reading_10, a.gastl_un_disc_amt_10, a.gastl_shrk_pct_10, a.gastl_shrk_what_10, 
       a.gastl_disc_cd_11, a.gastl_reading_11, a.gastl_un_disc_amt_11, a.gastl_shrk_pct_11, a.gastl_shrk_what_11, 
       a.gastl_disc_cd_12, a.gastl_reading_12, a.gastl_un_disc_amt_12, a.gastl_shrk_pct_12, a.gastl_shrk_what_12
       
       ,a.gastl_cus_no
		,a.gastl_com_cd
		,a.gastl_tic_no
		,a.gastl_pur_sls_ind
		,a.gastl_rec_type
		,a.gastl_tie_breaker
from
	gastlmst a
	,gacommst b
	,gacdcmst c
where
	a.gastl_com_cd = b.gacom_com_cd
	and c.gacdc_com_cd = a.gastl_com_cd
	--and (a.gastl_cus_no = ''0000000505'') 
	--and (a.gastl_com_cd = ''C'') 
	--and (a.gastl_tic_no = ''1224'') 
	--and (a.gastl_pur_sls_ind = ''P'')
	--and (a.gastl_rec_type = '''') 
    --and (a.gastl_tie_breaker = '''')
		')
GO