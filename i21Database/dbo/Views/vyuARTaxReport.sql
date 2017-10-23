CREATE VIEW [dbo].[vyuARTaxReport]
AS

SELECT DISTINCT I.intEntityCustomerId
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , C.strCustomerNumber
	 , C.strName	 	 
	 , strDisplayName			= ISNULL(C.strCustomerNumber, '') + ' - ' + ISNULL(C.strName, '')	 
	 , strCompanyName			= COMPANY.strCompanyName
	 , strCompanyAddress		= COMPANY.strCompanyAddress
	 , intCurrencyId			= I.intCurrencyId
	 , strCurrency				= SMC.strCurrency
	 , strCurrencyDescription	= SMC.strDescription
	 , TAXDETAIL.*
	 , dblTaxDifference = (TAXDETAIL.dblAdjustedTax - TAXDETAIL.dblTax) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	 , dblTaxAmount     = TAXDETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	 , dblNonTaxable    = (CASE WHEN TAXDETAIL.dblAdjustedTax = 0.000000 AND ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0.000000) = 0.000000 THEN  (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) / ISNULL(TAXTOTAL.intTaxCodeCount, 1.000000) ELSE 0.000000 END) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	 , dblTaxable       = (CASE WHEN TAXDETAIL.dblAdjustedTax > 0.000000 THEN  (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) * (TAXDETAIL.dblAdjustedTax/ISNULL(TAXTOTAL.dblTotalAdjustedTax, 1.000000)) ELSE 0.000000 END) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	 , dblTotalSales = (
						(CASE WHEN TAXDETAIL.dblAdjustedTax = 0.000000 AND ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0.000000) = 0.000000 THEN  (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) / ISNULL(TAXTOTAL.intTaxCodeCount, 1.000000) ELSE 0.000000 END)
						+
						(CASE WHEN TAXDETAIL.dblAdjustedTax > 0.000000 THEN  (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) * (TAXDETAIL.dblAdjustedTax/ISNULL(TAXTOTAL.dblTotalAdjustedTax, 1.000000)) ELSE 0.000000 END)
					   )
					   * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	, dblTaxCollected  = ISNULL(I.dblTax, 0) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)	
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (SELECT DISTINCT TC.intTaxCodeId
				 , TC.strTaxAgency
				 , TC.strTaxCode				 
				 , strTaxCodeDescription = TC.strDescription
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
				 , ID.intInvoiceDetailId
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
									, dblAdjustedTax = CASE WHEN ysnTaxExempt = 1 then 0 else dblAdjustedTax end
									, dblTax 
								FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)
			) IDT ON TC.intTaxCodeId = IDT.intTaxCodeId 
			INNER JOIN (SELECT intInvoiceId
								, intItemId
								, intInvoiceDetailId
								, dblPrice
								, dblQtyShipped
								, intTaxGroupId
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
				ID.intInvoiceDetailId
				,TC.intTaxCodeId
				,TC.strTaxAgency
				,TC.strTaxCode
				,TC.strDescription
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
LEFT OUTER JOIN (SELECT intInvoiceDetailId
				      , dblTotalAdjustedTax	= SUM(CASE WHEN ysnTaxExempt = 1 then 0 else dblAdjustedTax end)
				      , dblTotalTax			= SUM(dblTax)
					  , intTaxCodeCount		= COUNT(intInvoiceDetailTaxId )
				 FROM tblARInvoiceDetailTax WITH (NOLOCK)
				 GROUP BY intInvoiceDetailId
) TAXTOTAL ON TAXDETAIL.intInvoiceDetailId = TAXTOTAL.intInvoiceDetailId
LEFT OUTER JOIN (SELECT ENTITY.intEntityId 
					  , strCustomerNumber= CASE WHEN CUS.strCustomerNumber = '' THEN ENTITY.strEntityNo ELSE CUS.strCustomerNumber END
					  , strName  
				 FROM dbo.tblEMEntity ENTITY WITH (NOLOCK) 
				 INNER JOIN (SELECT intEntityId
					              , strCustomerNumber
							 FROM dbo.tblARCustomer WITH (NOLOCK)
				 ) CUS ON ENTITY.intEntityId = CUS.intEntityId
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
WHERE 
	I.ysnPosted = 1 and I.dblTax <> 0

UNION 


SELECT DISTINCT I.intEntityCustomerId
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , C.strCustomerNumber
	 , C.strName		 	 
	 , strDisplayName			= ISNULL(C.strCustomerNumber, '') + ' - ' + ISNULL(C.strName, '') 
	 , strCompanyName			= COMPANY.strCompanyName
	 , strCompanyAddress		= COMPANY.strCompanyAddress
	 , intCurrencyId			= I.intCurrencyId
	 , strCurrency				= SMC.strCurrency
	 , strCurrencyDescription	= SMC.strDescription
	 , TAXDETAIL.*
	 , dblTaxDifference = (TAXDETAIL.dblAdjustedTax - TAXDETAIL.dblTax) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	 , dblTaxAmount     = TAXDETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	 , dblNonTaxable    = I.dblInvoiceTotal--(CASE WHEN TAXDETAIL.dblAdjustedTax = 0.000000 AND ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0.000000) = 0.000000 THEN  (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) / ISNULL(TAXTOTAL.intTaxCodeCount, 1.000000) ELSE 0.000000 END) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	 , dblTaxable       = (CASE WHEN TAXDETAIL.dblAdjustedTax > 0.000000 THEN  (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) * (TAXDETAIL.dblAdjustedTax/ISNULL(TAXTOTAL.dblTotalAdjustedTax, 1.000000)) ELSE 0.000000 END) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	 , dblTotalSales = I.dblInvoiceTotal/*(
						(CASE WHEN TAXDETAIL.dblAdjustedTax = 0.000000 AND ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0.000000) = 0.000000 THEN  (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) / ISNULL(TAXTOTAL.intTaxCodeCount, 1.000000) ELSE 0.000000 END)
						+
						(CASE WHEN TAXDETAIL.dblAdjustedTax > 0.000000 THEN  (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) * (TAXDETAIL.dblAdjustedTax/ISNULL(TAXTOTAL.dblTotalAdjustedTax, 1.000000)) ELSE 0.000000 END)
					   )
					   * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)*/

	, dblTaxCollected  = ISNULL(I.dblTax, 0) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (

			SELECT DISTINCT  TC.intTaxCodeId
				 , TC.strTaxAgency
				 , TC.strTaxCode
				 , strTaxCodeDescription = TC.strDescription
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
				 , dblUnitPrice			= 0 -- ID.dblPrice
				 , dblQtyShipped		= ID.dblQtyShipped
				 , intCategoryId		= ITEMDETAIL.intCategoryId
				 , strItemCategory		= ITEMDETAIL.strCategoryCode
				 , IDT.dblAdjustedTax	 				 				 
				 , IDT.dblTax
				 , ID.intInvoiceDetailId
				 , dblTotalAdjustedTax  = SUM(IDT.dblAdjustedTax)
				 , dblTotalTax			= SUM(IDT.dblTax)
			FROM 
				tblARInvoiceDetail ID

			JOIN (SELECT intInvoiceDetailId
									, intTaxCodeId
									, strCalculationMethod
									, dblRate = 0
									, dblAdjustedTax = 0 --case when ysnTaxExempt = 1 then 0 else dblAdjustedTax end
									, dblTax = 0 
								FROM dbo.tblARInvoiceDetailTax idx WITH (NOLOCK) 
									where idx.intTaxCodeId = (select top 1 intTaxCodeId from tblARInvoiceDetailTax btx where btx.intInvoiceDetailId = idx.intInvoiceDetailId)
			) IDT ON ID.intInvoiceDetailId= IDT.intInvoiceDetailId

			JOIN (
				select intTaxCodeId,
					strTaxAgency,
					strTaxCode,
					strDescription,
					intTaxClassId,
					strCountry,
					strState,
					strCounty,
					strCity,
					intPurchaseTaxAccountId,
					intSalesTaxAccountId		
				FROM  
				dbo.tblSMTaxCode WITH (NOLOCK)
			) TC ON TC.intTaxCodeId = IDT.intTaxCodeId			
				
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
			
			--INNER JOIN (SELECT intInvoiceId
			--					, intItemId
			--					, intInvoiceDetailId
			--					, dblPrice
			--					, dblQtyShipped
			--					, intTaxGroupId
			--			FROM dbo.tblARInvoiceDetail vfp  WITH (NOLOCK)
			--) ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId	
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
				,TC.strDescription
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
				, ID.intInvoiceDetailId

) TAXDETAIL ON I.intInvoiceId = TAXDETAIL.intInvoiceId  and TAXDETAIL.intInvoiceDetailId = (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail childDetail where childDetail.intInvoiceId = I.intInvoiceId )
LEFT OUTER JOIN (SELECT intInvoiceDetailId
				      , dblTotalAdjustedTax	= SUM(CASE WHEN ysnTaxExempt = 1 then 0 else dblAdjustedTax end)
				      , dblTotalTax			= SUM(dblTax)
					  , intTaxCodeCount		= COUNT(intInvoiceDetailTaxId )
				 FROM tblARInvoiceDetailTax WITH (NOLOCK)
				 GROUP BY intInvoiceDetailId
) TAXTOTAL ON TAXDETAIL.intInvoiceDetailId = TAXTOTAL.intInvoiceDetailId
LEFT OUTER JOIN (SELECT ENTITY.intEntityId 
					  , strCustomerNumber= CASE WHEN CUS.strCustomerNumber = '' THEN ENTITY.strEntityNo ELSE CUS.strCustomerNumber END
					  , strName  
				 FROM dbo.tblEMEntity ENTITY WITH (NOLOCK) 
				 INNER JOIN (SELECT intEntityId
					              , strCustomerNumber
							 FROM dbo.tblARCustomer WITH (NOLOCK)
				 ) CUS ON ENTITY.intEntityId = CUS.intEntityId
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
WHERE 
	I.ysnPosted = 1 AND I.dblTax = 0