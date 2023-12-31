﻿GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPInvoicesCreditsReports')
	DROP VIEW vwCPInvoicesCreditsReports
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPInvoicesCreditsReports')
	DROP VIEW vyuCPInvoicesCreditsReports
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPInvoicesCreditsReports]
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
		')
GO

-- PETRO VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPInvoicesCreditsReports]
		AS
		select
			strCompanyName = rtrim(ltrim(c.coctl_co_name))
			,strCompanyAddress = rtrim(ltrim(c.coctl_co_addr))
			,strCompanyAddress2 = rtrim(ltrim(c.coctl_co_addr2))
			,strCompanyCityStateZip = rtrim(ltrim(c.coctl_co_city)) + '', '' + rtrim(ltrim(c.coctl_co_state)) + '' '' + rtrim(ltrim(c.coctl_co_zip))
			,strCustomerName = rtrim(ltrim(t.ptcus_first_name)) + '' '' + rtrim(ltrim(t.ptcus_last_name))
			,strCustomerAddress = rtrim(ltrim(t.ptcus_addr))
			,strCustomerCityStateZip = rtrim(ltrim(t.ptcus_city)) + '', '' + rtrim(ltrim(t.ptcus_state)) + '' '' + rtrim(ltrim(t.ptcus_zip))
			,strInvoiceNo = rtrim(ltrim(v.ptivc_invc_no))
			,dtmOrderDate = (case len(convert(varchar, d.ptstm_rev_dt)) when 8 then convert(date, cast(convert(varchar, d.ptstm_rev_dt) AS CHAR(12)), 112) else null end)
			,strAccountNo = rtrim(ltrim(t.ptcus_cus_no))
			,strOrderNo = rtrim(ltrim(v.ptivc_invc_no))
			,strPONo = rtrim(ltrim(v.ptivc_po_no))
			,dtmShipDate = (case len(convert(varchar, d.ptstm_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, d.ptstm_ship_rev_dt) AS CHAR(12)), 112) else null end)
			,strTerms = rtrim(ltrim(d.ptstm_terms_code))
			,strSalesMan = rtrim(ltrim(v.ptivc_sold_by))
			,strLocationNo = rtrim(ltrim(v.ptivc_loc_no))
			,strComment = rtrim(ltrim(v.ptivc_comment))
			,strItemNo = rtrim(ltrim(dd.ptstm_itm_no))
			,strDescription = ''''
			,strUnitsSold = convert(nvarchar, round(dd.ptstm_un, 4)) + '' '' + rtrim(ltrim(dd.ptstm_un_desc))
			,dblUnitrice = round(dd.ptstm_un_prc, 4)
			,dblExtended = convert(decimal(10,2),(dd.ptstm_un * dd.ptstm_un_prc))
			,strTax = ''GROUND WATER TAX''
			,strTaxUnitsSold = convert(nvarchar, round(dd.ptstm_un, 4)) + '' '' + dd.ptstm_un_desc
			,dblTaxUnitPrice = round(cast(dd.ptstm_lc1_rt as float), 4)
			--,dblTaxExtended = convert(decimal(10,2), (((dd.agstm_un * dd.agstm_un_prc) * dd.agstm_lc1_rt)/100))
			,dblTaxExtended = convert(decimal(10,2), (dd.ptstm_pak_qty * dd.ptstm_un_prc))
		from coctlmst c, ptcusmst t, ptivcmst v, ptstmmst d, ptstmmst dd
		where v.ptivc_cus_no = t.ptcus_cus_no
			and d.ptstm_bill_to_cus = t.ptcus_cus_no
			and d.ptstm_ivc_no = v.ptivc_invc_no
			and d.ptstm_rec_type = 1
			and dd.ptstm_bill_to_cus = t.ptcus_cus_no
			and dd.ptstm_ivc_no = v.ptivc_invc_no
			and dd.ptstm_rec_type = 5
		')
GO
