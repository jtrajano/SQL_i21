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
	 , C.strName	 
	 , strCompanyName	= COMPANY.strCompanyName
	 , strCompanyAddress = COMPANY.strCompanyAddress
	 , intItemId        = ITEMDETAIL.intItemId
	 , strItemNo		= ITEMDETAIL.strItemNo
	 , dblUnitPrice     = ITEMDETAIL.dblPrice
	 , dblQtyShipped	= ITEMDETAIL.dblQtyShipped
	 , intCategoryId	= ITEMDETAIL.intCategoryId
	 , strItemCategory	= ITEMDETAIL.strCategoryCode	 
	 , dblTaxDifference = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN SUM(IDT.dblAdjustedTax - IDT.dblTax) * -1 
								ELSE SUM(IDT.dblAdjustedTax - IDT.dblTax) 
						  END
	 , dblTaxAmount     = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN SUM(IDT.dblAdjustedTax) * -1 
								ELSE SUM(IDT.dblAdjustedTax)
						  END
	 , dblNonTaxable    = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN NONTAXABLE.dblNonTaxable * -1 
								ELSE NONTAXABLE.dblNonTaxable 
						  END
	 , dblTaxable       = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') 
								THEN TAXABLE.dblTaxable * -1
								ELSE TAXABLE.dblTaxable
						  END
	 , dblTotalSales    = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN I.dblInvoiceTotal * -1 
								ELSE I.dblInvoiceTotal
						  END
	 , dblTaxCollected  = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN ISNULL(I.dblTax, 0) * -1 
								ELSE ISNULL(I.dblTax, 0)
						  END
	 ,intCurrencyId				= I.intCurrencyId
	 ,strCurrency				= SMC.strCurrency
	 ,strCurrencyDescription	= SMC.strDescription
FROM tblSMTaxCode TC
	LEFT OUTER JOIN (SELECT intTaxClassId
	                      , strTaxClass 
					 FROM dbo.tblSMTaxClass WITH (NOLOCK)) CL ON TC.intTaxClassId = CL.intTaxClassId
	LEFT OUTER JOIN (SELECT intAccountId
						  , strAccountId 
					 FROM dbo.tblGLAccount WITH (NOLOCK)) SA ON TC.intSalesTaxAccountId = SA.intAccountId 
	LEFT OUTER JOIN (SELECT intAccountId
						  , strAccountId 
					 FROM dbo.tblGLAccount WITH (NOLOCK)) PA ON TC.intPurchaseTaxAccountId = PA.intAccountId
	LEFT OUTER JOIN (SELECT intInvoiceDetailId
						  , intTaxCodeId
						  , strCalculationMethod
						  , dblRate
						  , dblAdjustedTax
						  , dblTax 
					 FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)) IDT ON TC.intTaxCodeId = IDT.intTaxCodeId 
	INNER JOIN (SELECT intInvoiceId
					 , intInvoiceDetailId 
				FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN (SELECT intInvoiceId
					 , strInvoiceNumber
					 , dtmDate
					 , intEntityCustomerId
					 , ysnPosted
					 , intCurrencyId
					 , dblTax
					 , strTransactionType
					 , dblInvoiceTotal
					 , ysnPaid 
				FROM dbo.tblARInvoice WITH (NOLOCK)) I ON ID.intInvoiceId = I.intInvoiceId AND I.ysnPosted = 1
	INNER JOIN (SELECT intEntityId
					 , strCustomerNumber
					 , strName
			    FROM dbo.vyuARCustomer WITH (NOLOCK)) C ON I.intEntityCustomerId = C.intEntityId	
	LEFT OUTER JOIN (SELECT intCurrencyID
						  , strCurrency
						  , strDescription 
					 FROM dbo.tblSMCurrency WITH (NOLOCK)) SMC ON I.intCurrencyId = SMC.intCurrencyID
	OUTER APPLY (SELECT TOP 1 strCompanyName
							, strCompanyAddress = dbo.[fnARFormatCustomerAddress] (NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
				 FROM dbo.tblSMCompanySetup WITH (NOLOCK)) COMPANY
	OUTER APPLY (SELECT TOP 1 IID.intItemId
							, IID.dblPrice
						    , IID.dblQtyShipped
						    , ICI.strItemNo
							, ICI.intCategoryId
							, ICC.strCategoryCode 
				 FROM dbo.tblARInvoiceDetail IID 					
					LEFT JOIN (SELECT intItemId
									, intCategoryId
									, strItemNo
							   FROM dbo.tblICItem WITH (NOLOCK)) ICI ON IID.intItemId = ICI.intItemId
					LEFT JOIN (SELECT intCategoryId
									, strCategoryCode 
							   FROM dbo.tblICCategory WITH (NOLOCK)) ICC ON ICI.intCategoryId = ICC.intCategoryId
				 WHERE intInvoiceId = I.intInvoiceId) ITEMDETAIL
	OUTER APPLY (SELECT dblNonTaxable = ISNULL(SUM(dblTotal), 0) 
				 FROM dbo.tblARInvoiceDetail WITH (NOLOCK) 
				 WHERE dblTotalTax = 0 AND intInvoiceId = I.intInvoiceId) NONTAXABLE
	OUTER APPLY (SELECT dblTaxable = ISNULL(SUM(dblTotal), 0) 
				 FROM dbo.tblARInvoiceDetail WITH (NOLOCK) 
				 WHERE dblTotalTax <> 0 AND intInvoiceId = I.intInvoiceId) TAXABLE
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
	,C.strName
	,I.dblInvoiceTotal
	,I.ysnPaid
	,I.dblTax
	,I.strTransactionType
	,IDT.strCalculationMethod
	,IDT.dblRate
	,I.intCurrencyId
	,SMC.strCurrency
	,SMC.strDescription
	,COMPANY.strCompanyName
	,COMPANY.strCompanyAddress
	,ITEMDETAIL.intItemId
	,ITEMDETAIL.dblPrice
	,ITEMDETAIL.dblQtyShipped
	,ITEMDETAIL.strItemNo
	,ITEMDETAIL.intCategoryId
	,ITEMDETAIL.strCategoryCode
	,NONTAXABLE.dblNonTaxable
	,TAXABLE.dblTaxable