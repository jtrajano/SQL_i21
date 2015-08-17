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
	 , SA.strAccountId				AS SalesTaxAccount
	 , TC.intPurchaseTaxAccountId
	 , ISNULL(PA.strAccountId, '')	AS PurchaseTaxAccount
	 , I.intInvoiceId
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , C.strCustomerNumber
	 , E.strName
	 , SUM(IDT.dblAdjustedTax - IDT.dblTax) AS dblTaxDifference
	 , SUM(IDT.dblAdjustedTax)		AS dblTaxAmount
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