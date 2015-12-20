﻿CREATE VIEW [dbo].[vyuARTaxReport]
AS
SELECT TC.intTaxCodeId
	 , TC.strTaxAgency
	 , TC.strTaxCode
	 , TC.intTaxClassId
	 , CL.strTaxClass
	 , TC.strCountry
	 , TC.strState
	 , TC.strCounty
	 , TC.strCity
	 , TC.intSalesTaxAccountId
	 , SalesTaxAccount = SA.strAccountId
	 , TC.intPurchaseTaxAccountId
	 , PurchaseTaxAccount = ISNULL(PA.strAccountId, '')
	 , I.intInvoiceId
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , C.strCustomerNumber
	 , E.strName
	 , strItemNo        = (SELECT TOP 1 ICI.strItemNo FROM tblARInvoiceDetail IID 
									INNER JOIN tblARInvoiceDetailTax IIDT ON IID.intInvoiceDetailId = IIDT.intInvoiceDetailId AND IIDT.intTaxCodeId = TC.intTaxCodeId
									LEFT JOIN tblICItem ICI ON IID.intItemId = ICI.intItemId
							WHERE intInvoiceId = I.intInvoiceId)
	 , strItemCategory  = (SELECT TOP 1 ICC.strDescription FROM tblARInvoiceDetail IID 
									INNER JOIN tblARInvoiceDetailTax IIDT ON IID.intInvoiceDetailId = IIDT.intInvoiceDetailId AND IIDT.intTaxCodeId = TC.intTaxCodeId
									LEFT JOIN tblICItem ICI ON IID.intItemId = ICI.intItemId
									LEFT JOIN tblICCategory ICC ON ICI.intCategoryId = ICC.intCategoryId
							WHERE intInvoiceId = I.intInvoiceId)
	 , dblTaxDifference = SUM(IDT.dblAdjustedTax - IDT.dblTax)
	 , dblTaxAmount     = SUM(IDT.dblAdjustedTax)
	 , dblNonTaxable    = (SELECT ISNULL(SUM(dblTotal), 0) FROM tblARInvoiceDetail WHERE dblTotalTax = 0 AND intInvoiceId = I.intInvoiceId)
	 , dblTaxable       = (SELECT ISNULL(SUM(dblTotal), 0) FROM tblARInvoiceDetail WHERE dblTotalTax > 0 AND intInvoiceId = I.intInvoiceId)
	 , dblTotalSales    = I.dblInvoiceTotal
	 , dblTaxCollected  = ISNULL(I.dblTax, 0)
FROM tblSMTaxCode TC
	LEFT OUTER JOIN tblSMTaxClass CL ON TC.intTaxClassId = CL.intTaxClassId
	LEFT OUTER JOIN tblGLAccount SA ON TC.intSalesTaxAccountId = SA.intAccountId 
	LEFT OUTER JOIN tblGLAccount PA ON TC.intPurchaseTaxAccountId = PA.intAccountId
	LEFT OUTER JOIN tblARInvoiceDetailTax IDT ON TC.intTaxCodeId = IDT.intTaxCodeId 
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId AND I.ysnPosted = 1
	INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId
GROUP BY
	 TC.intTaxCodeId
	,TC.strTaxAgency
	,TC.strTaxCode
	,TC.intTaxClassId
	,CL.strTaxClass
	,TC.strCountry
	,TC.strState
	,TC.strCounty
	,TC.strCity
	,TC.intSalesTaxAccountId
	,SA.strAccountId
	,TC.intPurchaseTaxAccountId
	,ISNULL(PA.strAccountId, '')
	,I.intInvoiceId
	,I.strInvoiceNumber
	,I.dtmDate
	,C.strCustomerNumber
	,E.strName	
	,I.dblInvoiceTotal
	,I.ysnPaid
	,I.dblTax