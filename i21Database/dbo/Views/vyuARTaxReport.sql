CREATE VIEW [dbo].[vyuARTaxReport]
AS
SELECT I.intEntityCustomerId
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , C.strCustomerNumber
	 , C.strName	 
	 , strCompanyName			= COMPANY.strCompanyName
	 , strCompanyAddress		= COMPANY.strCompanyAddress
	 , intCurrencyId			= I.intCurrencyId
	 , strCurrency				= SMC.strCurrency
	 , strCurrencyDescription	= SMC.strDescription
	 , TAXDETAIL.*
	 , dblTaxDifference = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN (TAXDETAIL.dblTotalAdjustedTax - TAXDETAIL.dblTotalTax) * -1 
								ELSE (TAXDETAIL.dblTotalAdjustedTax - TAXDETAIL.dblTotalTax) 
						  END
	 , dblTaxAmount     = CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash')
								THEN TAXDETAIL.dblTotalAdjustedTax * -1 
								ELSE TAXDETAIL.dblTotalAdjustedTax
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
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (SELECT TC.intTaxCodeId
				 , TC.strTaxAgency
				 , TC.strTaxCode
				 , TC.intTaxClassId
				 , CL.strTaxClass
				 , TC.strCountry
				 , TC.strState
				 , TC.strCounty
				 , TC.strCity
				 , TC.intSalesTaxAccountId
				 , SalesTaxAccount		= SA.strAccountId
				 , TC.intPurchaseTaxAccountId
				 , PurchaseTaxAccount	= ISNULL(PA.strAccountId, '')
				 , IDT.strCalculationMethod
				 , IDT.dblRate
				 , ID.intInvoiceId				 
				 , intItemId			= ITEMDETAIL.intItemId
				 , strItemNo			= ITEMDETAIL.strItemNo
				 , dblUnitPrice			= ID.dblPrice
				 , dblQtyShipped		= ID.dblQtyShipped
				 , intCategoryId		= ITEMDETAIL.intCategoryId
				 , strItemCategory		= ITEMDETAIL.strCategoryCode
				 , IDT.dblAdjustedTax	 				 				 
				 , IDT.dblTax
				 , dblTotalAdjustedTax  = SUM(IDT.dblAdjustedTax)
				 , dblTotalTax			= SUM(IDT.dblTax)
			FROM dbo.tblSMTaxCode TC WITH (NOLOCK)
			LEFT OUTER JOIN (SELECT intTaxClassId
									, strTaxClass 
								FROM dbo.tblSMTaxClass WITH (NOLOCK)
			) CL ON TC.intTaxClassId = CL.intTaxClassId
			LEFT OUTER JOIN (SELECT intAccountId
									, strAccountId 
								FROM dbo.tblGLAccount WITH (NOLOCK)
			) SA ON TC.intSalesTaxAccountId = SA.intAccountId 
			LEFT OUTER JOIN (SELECT intAccountId
									, strAccountId 
								FROM dbo.tblGLAccount WITH (NOLOCK)
			) PA ON TC.intPurchaseTaxAccountId = PA.intAccountId
			LEFT OUTER JOIN (SELECT intInvoiceDetailId
									, intTaxCodeId
									, strCalculationMethod
									, dblRate
									, dblAdjustedTax
									, dblTax 
								FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)
			) IDT ON TC.intTaxCodeId = IDT.intTaxCodeId 
			INNER JOIN (SELECT intInvoiceId
								, intItemId
								, intInvoiceDetailId
								, dblPrice
								, dblQtyShipped
						FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
			) ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId	
			OUTER APPLY (SELECT TOP 1 intItemId
									, ICI.intCategoryId
									, strItemNo
									, strCategoryCode
							FROM dbo.tblICItem ICI WITH (NOLOCK)
							LEFT JOIN (SELECT intCategoryId
											, strCategoryCode 
									FROM dbo.tblICCategory WITH (NOLOCK)
							) ICC ON ICI.intCategoryId = ICC.intCategoryId
							WHERE ID.intItemId = ICI.intItemId) ITEMDETAIL	
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
				,IDT.strCalculationMethod
				,IDT.dblRate
				,IDT.dblAdjustedTax
				,IDT.dblTax
				,ITEMDETAIL.intItemId
				,ID.dblPrice
				,ID.dblQtyShipped
				,ID.intInvoiceId
				,ITEMDETAIL.strItemNo
				,ITEMDETAIL.intCategoryId
				,ITEMDETAIL.strCategoryCode
) TAXDETAIL ON I.intInvoiceId = TAXDETAIL.intInvoiceId
LEFT OUTER JOIN (SELECT intEntityId
				      , strCustomerNumber
				      , strName
				 FROM dbo.vyuARCustomer WITH (NOLOCK)
) C ON I.intEntityCustomerId = C.intEntityId	
LEFT OUTER JOIN (SELECT intCurrencyID
						, strCurrency
						, strDescription 
				 FROM dbo.tblSMCurrency WITH (NOLOCK)
) SMC ON I.intCurrencyId = SMC.intCurrencyID
OUTER APPLY (SELECT TOP 1 strCompanyName
						, strCompanyAddress = dbo.[fnARFormatCustomerAddress] (NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
			 FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (SELECT dblNonTaxable = ISNULL(SUM(dblTotal), 0) 
				 FROM dbo.tblARInvoiceDetail WITH (NOLOCK) 
				 WHERE dblTotalTax = 0 AND intInvoiceId = I.intInvoiceId
) NONTAXABLE
OUTER APPLY (SELECT dblTaxable = ISNULL(SUM(dblTotal), 0) 
			 FROM dbo.tblARInvoiceDetail WITH (NOLOCK) 
			 WHERE dblTotalTax <> 0 AND intInvoiceId = I.intInvoiceId
) TAXABLE
WHERE I.ysnPosted = 1	