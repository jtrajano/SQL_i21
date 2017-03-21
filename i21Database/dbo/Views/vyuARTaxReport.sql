CREATE VIEW [dbo].[vyuARTaxReport]
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
	 , IDT.strCalculationMethod
	 , IDT.dblRate
	 , I.intInvoiceId
	 , I.intEntityCustomerId
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , C.strCustomerNumber
	 , E.strName
	 , dblUnitPrice     = (SELECT TOP 1 dblPrice FROM tblARInvoiceDetail IID 
									 INNER JOIN tblARInvoiceDetailTax IIDT ON IID.intInvoiceDetailId = IIDT.intInvoiceDetailId AND IIDT.intTaxCodeId = TC.intTaxCodeId
							WHERE intInvoiceId = I.intInvoiceId AND IID.dblTotalTax > 0)
	 , strCompanyName	= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	 , strCompanyAddress = (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) FROM tblSMCompanySetup)
	 , intItemId        = (SELECT TOP 1 IID.intItemId FROM tblARInvoiceDetail IID 
									INNER JOIN tblARInvoiceDetailTax IIDT ON IID.intInvoiceDetailId = IIDT.intInvoiceDetailId AND IIDT.intTaxCodeId = TC.intTaxCodeId									
							WHERE intInvoiceId = I.intInvoiceId AND IID.dblTotalTax > 0)
	 , strItemNo        = (SELECT TOP 1 ICI.strItemNo FROM tblARInvoiceDetail IID 
									INNER JOIN tblARInvoiceDetailTax IIDT ON IID.intInvoiceDetailId = IIDT.intInvoiceDetailId AND IIDT.intTaxCodeId = TC.intTaxCodeId
									LEFT JOIN tblICItem ICI ON IID.intItemId = ICI.intItemId
							WHERE intInvoiceId = I.intInvoiceId AND IID.dblTotalTax > 0)
	 , dblQtyShipped	= (SELECT TOP 1 dblQtyShipped FROM tblARInvoiceDetail IID 
									INNER JOIN tblARInvoiceDetailTax IIDT ON IID.intInvoiceDetailId = IIDT.intInvoiceDetailId AND IIDT.intTaxCodeId = TC.intTaxCodeId
							WHERE intInvoiceId = I.intInvoiceId AND IID.dblTotalTax > 0)
	 , intCategoryId    = (SELECT TOP 1 ICI.intCategoryId FROM tblARInvoiceDetail IID 
									INNER JOIN tblARInvoiceDetailTax IIDT ON IID.intInvoiceDetailId = IIDT.intInvoiceDetailId AND IIDT.intTaxCodeId = TC.intTaxCodeId
									LEFT JOIN tblICItem ICI ON IID.intItemId = ICI.intItemId
							WHERE intInvoiceId = I.intInvoiceId AND IID.dblTotalTax > 0)
	 , strItemCategory  = (SELECT TOP 1 ICC.strCategoryCode FROM tblARInvoiceDetail IID 
									INNER JOIN tblARInvoiceDetailTax IIDT ON IID.intInvoiceDetailId = IIDT.intInvoiceDetailId AND IIDT.intTaxCodeId = TC.intTaxCodeId
									LEFT JOIN tblICItem ICI ON IID.intItemId = ICI.intItemId
									LEFT JOIN tblICCategory ICC ON ICI.intCategoryId = ICC.intCategoryId
							WHERE intInvoiceId = I.intInvoiceId AND IID.dblTotalTax > 0)
	 , dblTaxDifference = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN SUM(IDT.dblAdjustedTax - IDT.dblTax) * -1 
								ELSE SUM(IDT.dblAdjustedTax - IDT.dblTax) 
						  END
	 , dblTaxAmount     = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN SUM(IDT.dblAdjustedTax) * -1 
								ELSE SUM(IDT.dblAdjustedTax)
						  END
	 , dblNonTaxable    = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN (SELECT ISNULL(SUM(dblTotal), 0) FROM tblARInvoiceDetail WHERE dblTotalTax = 0 AND intInvoiceId = I.intInvoiceId) * -1 
								ELSE (SELECT ISNULL(SUM(dblTotal), 0) FROM tblARInvoiceDetail WHERE dblTotalTax = 0 AND intInvoiceId = I.intInvoiceId) 
						  END
	 , dblTaxable       = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') 
								THEN (SELECT SUM(Taxable)
										FROM 
										(
										SELECT SUM(dblTotal) Taxable FROM tblARInvoiceDetail WHERE intInvoiceId IN (Select intInvoiceId FROM tblARInvoice WHERE dblTotalTax > 0 AND intInvoiceId = I.intInvoiceId)
										UNION ALL
										SELECT SUM(dblTotal) Taxable FROM tblARInvoiceDetail WHERE intInvoiceId IN (Select intInvoiceId FROM tblARInvoice WHERE dblTotalTax < 0 AND intInvoiceId = I.intInvoiceId)
										) ABC) * -1 
								ELSE (SELECT SUM(Taxable)
										FROM 
										(
										SELECT SUM(dblTotal) Taxable FROM tblARInvoiceDetail WHERE intInvoiceId IN (Select intInvoiceId FROM tblARInvoice WHERE dblTotalTax > 0 AND intInvoiceId = I.intInvoiceId)
										UNION ALL
										SELECT SUM(dblTotal) Taxable FROM tblARInvoiceDetail WHERE intInvoiceId IN (Select intInvoiceId FROM tblARInvoice WHERE dblTotalTax < 0 AND intInvoiceId = I.intInvoiceId)
										) ABC) 
						  END
	 , dblTotalSales    = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN I.dblInvoiceTotal * -1 
								ELSE I.dblInvoiceTotal
						  END
	 , dblTaxCollected  = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN ISNULL(I.dblTax, 0) * -1 
								ELSE ISNULL(I.dblTax, 0)
						  END
FROM tblSMTaxCode TC
	LEFT OUTER JOIN tblSMTaxClass CL ON TC.intTaxClassId = CL.intTaxClassId
	LEFT OUTER JOIN tblGLAccount SA ON TC.intSalesTaxAccountId = SA.intAccountId 
	LEFT OUTER JOIN tblGLAccount PA ON TC.intPurchaseTaxAccountId = PA.intAccountId
	LEFT OUTER JOIN tblARInvoiceDetailTax IDT ON TC.intTaxCodeId = IDT.intTaxCodeId 
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId AND I.ysnPosted = 1
	INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN tblEMEntity E ON C.intEntityCustomerId = E.intEntityId
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
	,I.intEntityCustomerId
	,I.strInvoiceNumber
	,I.dtmDate
	,C.strCustomerNumber
	,E.strName	
	,I.dblInvoiceTotal
	,I.ysnPaid
	,I.dblTax
	,I.strTransactionType
	,IDT.strCalculationMethod
	,IDT.dblRate