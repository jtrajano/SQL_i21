CREATE VIEW [dbo].[vyuARTaxReport]
AS
SELECT TAXES.*
	 , strCustomerNumber		= C.strCustomerNumber
	 , strCustomerName			= C.strName
	 , strDisplayName			= ISNULL(C.strCustomerNumber, '') + ' - ' + ISNULL(C.strName, '')
	 , strCompanyName			= COMPANY.strCompanyName
	 , strCompanyAddress		= COMPANY.strCompanyAddress
	 , strCurrency				= SMC.strCurrency
	 , strCurrencyDescription	= SMC.strDescription
	 , strTaxGroup				= TAXGROUP.strTaxGroup
	 , strTaxAgency				= TAXCODE.strTaxAgency
	 , strTaxCode				= TAXCODE.strTaxCode
	 , strTaxCodeDescription	= TAXCODE.strTaxCodeDescription
	 , strCountry				= TAXCODE.strCountry
	 , strState					= TAXCODE.strState
	 , strCounty				= TAXCODE.strCounty
	 , strCity					= TAXCODE.strCity
	 , strTaxClass				= TAXCLASS.strTaxClass
	 , strSalesTaxAccount		= SALESACCOUNT.strAccountId
	 , strPurchaseTaxAccount	= PURCHASEACCOUNT.strAccountId
	 , strLocationName			= LOC.strLocationName
	 , strShipToLocationAddress = SHIPTO.strLocationName
	 , strItemNo				= ITEMDETAIL.strItemNo
	 , strCategoryCode			= ITEMDETAIL.strCategoryCode
	 , strItemCategory			= ITEMDETAIL.strItemCategory
	 , intTaxClassId			= TAXCLASS.intTaxClassId
	 , intSalesTaxAccountId		= SALESACCOUNT.intAccountId
	 , intPurchaseTaxAccountId	= PURCHASEACCOUNT.intAccountId
	 , intCategoryId			= ITEMDETAIL.intCategoryId
	 , intTonnageTaxUOMId		= ITEMDETAIL.intTonnageTaxUOMId
	 , dblQtyTonShipped			= CASE WHEN ITEMDETAIL.intTonnageTaxUOMId IS NOT NULL THEN CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(TAXES.intItemUOMId, ISNULL(ITEMDETAIL.intTonnageUOMSetupId, TAXES.intItemUOMId), TAXES.dblQtyShipped)) ELSE TAXES.dblQtyShipped END
FROM (
	SELECT DISTINCT I.intEntityCustomerId
		 , I.strInvoiceNumber
		 , I.dtmDate
		 , intCurrencyId			= I.intCurrencyId
		 , intCompanyLocationId		= I.intCompanyLocationId
		 , intShipToLocationId		= I.intShipToLocationId
		 , TAXDETAIL.intTaxCodeId
		 , TAXDETAIL.intInvoiceId
		 , TAXDETAIL.intInvoiceDetailId
		 , TAXDETAIL.intItemId
		 , TAXDETAIL.intItemUOMId
		 , TAXDETAIL.intTaxGroupId
		 , TAXDETAIL.strCalculationMethod
		 , TAXDETAIL.dblRate
		 , dblUnitPrice				= TAXDETAIL.dblUnitPrice * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
		 , dblQtyShipped			= TAXDETAIL.dblQtyShipped * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
		 , TAXDETAIL.dblAdjustedTax
		 , TAXDETAIL.dblTax
		 , TAXDETAIL.dblTotalAdjustedTax
		 , TAXDETAIL.dblTotalTax
		 , TAXDETAIL.ysnTaxExempt
		 , dblTaxDifference 		= (TAXDETAIL.dblAdjustedTax - TAXDETAIL.dblTax) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
		 , dblTaxAmount     		= TAXDETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
		 , dblNonTaxable    		= (CASE WHEN I.dblTax = 0 
		 								THEN (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) / ISNULL(NULLIF(TAXTOTAL.intTaxCodeCount, 0), 1.000000)
										ELSE (CASE WHEN TAXDETAIL.dblAdjustedTax = 0.000000 AND ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0.000000) = 0.000000 
												   THEN (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) / ISNULL(NULLIF(TAXTOTAL.intTaxCodeCount, 0), 1.000000) 
												   ELSE 0.000000 
											  END) 
									   END) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
		 , dblTaxable       		= (CASE WHEN I.dblTax = 0 
		 								THEN 0 
										ELSE (CASE WHEN TAXDETAIL.dblAdjustedTax <> 0.000000 
												   THEN (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) * (TAXDETAIL.dblAdjustedTax/ISNULL(TAXTOTAL.dblTotalAdjustedTax, 1.000000)) 
												   ELSE 0.000000 
											  END) 
									  END) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
		 , dblTotalSales 			= (CASE WHEN I.dblTax = 0 
		 								THEN (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) / ISNULL(NULLIF(TAXTOTAL.intTaxCodeCount, 0), 1.000000)
										ELSE ((CASE WHEN TAXDETAIL.dblAdjustedTax = 0.000000 AND ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0.000000) = 0.000000 
												    THEN (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) / ISNULL(NULLIF(TAXTOTAL.intTaxCodeCount, 0), 1.000000) 
													ELSE 0.000000 
											   END) +
											  (CASE WHEN TAXDETAIL.dblAdjustedTax <> 0.000000 
											  		THEN (TAXDETAIL.dblQtyShipped * TAXDETAIL.dblUnitPrice) * (TAXDETAIL.dblAdjustedTax/ISNULL(TAXTOTAL.dblTotalAdjustedTax, 1.000000)) 
													ELSE 0.000000 
											   END))
									  END) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
		, dblTaxCollected  = ISNULL(I.dblTax, 0) * [dbo].[fnARGetInvoiceAmountMultiplier](I.strTransactionType)
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN (
		SELECT DISTINCT TC.intTaxCodeId
					  , ID.intInvoiceId
					  , ID.intInvoiceDetailId
					  , ID.intItemId
					  , ID.intItemUOMId
					  , ID.intTaxGroupId
					  , IDT.strCalculationMethod
					  , IDT.dblRate
					  , dblUnitPrice			= ID.dblPrice
					  , dblQtyShipped			= ID.dblQtyShipped					  
					  , IDT.dblAdjustedTax	 				 				 
					  , IDT.dblTax
					  , dblTotalAdjustedTax		= SUM(IDT.dblAdjustedTax)
					  , dblTotalTax				= SUM(IDT.dblTax)
					  , IDT.ysnTaxExempt
				FROM dbo.tblSMTaxCode TC WITH (NOLOCK)
				LEFT OUTER JOIN (
					SELECT intInvoiceDetailId
						 , intTaxCodeId
						 , strCalculationMethod
						 , dblRate
						 , dblAdjustedTax = CASE WHEN ysnTaxExempt = 1 THEN 0 ELSE dblAdjustedTax end
						 , dblTax
						 , ysnTaxExempt 
					FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)
				) IDT ON TC.intTaxCodeId = IDT.intTaxCodeId 
				INNER JOIN (
					SELECT intInvoiceId
						 , intItemId
						 , intItemUOMId
						 , intInvoiceDetailId
						 , dblPrice
						 , dblQtyShipped
						 , intTaxGroupId
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
				) ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId						
				GROUP BY ID.intInvoiceDetailId
					   , TC.intTaxCodeId
					   , IDT.strCalculationMethod
					   , IDT.dblRate
					   , IDT.dblAdjustedTax
					   , IDT.dblTax
					   , ID.dblPrice
					   , ID.dblQtyShipped
					   , ID.intInvoiceId
					   , ID.intItemId
					   , ID.intItemUOMId
					   , ID.intTaxGroupId
					   , IDT.ysnTaxExempt
	) TAXDETAIL ON I.intInvoiceId = TAXDETAIL.intInvoiceId
	LEFT OUTER JOIN (
		SELECT intInvoiceDetailId
			 , dblTotalAdjustedTax	= SUM(dblAdjustedTax)
			 , intTaxCodeCount		= COUNT(intInvoiceDetailTaxId)
		FROM tblARInvoiceDetailTax WITH (NOLOCK)
		WHERE ysnTaxExempt = 0
		GROUP BY intInvoiceDetailId
	) TAXTOTAL ON TAXDETAIL.intInvoiceDetailId = TAXTOTAL.intInvoiceDetailId
	WHERE I.ysnPosted = 1 
) TAXES
LEFT OUTER JOIN (
	SELECT intTaxGroupId
		 , strTaxGroup
	FROM dbo.tblSMTaxGroup WITH (NOLOCK)
) TAXGROUP ON TAXES.intTaxGroupId = TAXGROUP.intTaxGroupId
LEFT OUTER JOIN (
	SELECT intTaxCodeId
		 , strTaxAgency
		 , strTaxCode
		 , strTaxCodeDescription	= strDescription
		 , intTaxClassId
		 , strCountry
		 , strState
		 , strCounty
		 , strCity
		 , intSalesTaxAccountId
		 , intPurchaseTaxAccountId
	FROM dbo.tblSMTaxCode WITH (NOLOCK)
) TAXCODE ON TAXES.intTaxCodeId = TAXCODE.intTaxCodeId
LEFT OUTER JOIN (
	SELECT intTaxClassId
		 , strTaxClass 
	FROM dbo.tblSMTaxClass WITH (NOLOCK)
) TAXCLASS ON TAXCODE.intTaxClassId = TAXCLASS.intTaxClassId
LEFT OUTER JOIN (
	SELECT intAccountId
		 , strAccountId 
	FROM dbo.tblGLAccount WITH (NOLOCK)
) SALESACCOUNT ON TAXCODE.intSalesTaxAccountId = SALESACCOUNT.intAccountId 
LEFT OUTER JOIN (
	SELECT intAccountId
		 , strAccountId 
	FROM dbo.tblGLAccount WITH (NOLOCK)
) PURCHASEACCOUNT ON TAXCODE.intPurchaseTaxAccountId = PURCHASEACCOUNT.intAccountId
OUTER APPLY (
	SELECT TOP 1 intItemId
			   , ICI.intCategoryId
			   , intTonnageTaxUOMId = CASE WHEN ISNULL(ICI.ysnTonnageTax, 0) = 1 THEN ICI.intTonnageTaxUOMId ELSE NULL END
			   , strItemNo
			   , strItemCategory	= ICC.strCategoryCode
			   , strCategoryCode
			   , intTonnageUOMSetupId = ITEMUOMSETUP.intItemUOMSetupId
	FROM dbo.tblICItem ICI WITH (NOLOCK)
	LEFT JOIN (
		SELECT intCategoryId
			 , strCategoryCode 
		FROM dbo.tblICCategory WITH (NOLOCK)
	) ICC ON ICI.intCategoryId = ICC.intCategoryId
	OUTER APPLY (
		Select intItemUOMSetupId = intItemUOMId from tblICItemUOM WITH (NOLOCK) where intItemId = ICI.intItemId and  intUnitMeasureId = CASE WHEN ISNULL(ICI.ysnTonnageTax, 0) = 1 THEN ICI.intTonnageTaxUOMId ELSE NULL END
	) ITEMUOMSETUP
	WHERE TAXES.intItemId = ICI.intItemId
) ITEMDETAIL
INNER JOIN (
	SELECT intTaxClassId
		 , intCategoryId
	FROM dbo.tblICCategoryTax ICT WITH (NOLOCK)
) ITEMTAXCATEGORY ON ITEMTAXCATEGORY.intTaxClassId = TAXCODE.intTaxClassId
				 AND ITEMTAXCATEGORY.intCategoryId = ITEMDETAIL.intCategoryId
LEFT OUTER JOIN (
	SELECT ENTITY.intEntityId 
		 , strCustomerNumber = CASE WHEN CUS.strCustomerNumber = '' THEN ENTITY.strEntityNo ELSE CUS.strCustomerNumber END
		 , strName  
	FROM dbo.tblEMEntity ENTITY WITH (NOLOCK) 
	INNER JOIN (
		SELECT intEntityId
			 , strCustomerNumber
		FROM dbo.tblARCustomer WITH (NOLOCK)
	) CUS ON ENTITY.intEntityId = CUS.intEntityId
) C ON TAXES.intEntityCustomerId = C.intEntityId	
LEFT OUTER JOIN (
	SELECT intCurrencyID
		 , strCurrency
		 , strDescription 
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) SMC ON TAXES.intCurrencyId = SMC.intCurrencyID
LEFT OUTER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOC ON TAXES.intCompanyLocationId	 = LOC.intCompanyLocationId
LEFT OUTER JOIN (
	SELECT intEntityLocationId
	     , strLocationName
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) SHIPTO ON TAXES.intShipToLocationId = SHIPTO.intEntityLocationId
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress] (NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY