CREATE VIEW [dbo].[vyuARTaxReport]
AS
SELECT intEntityCustomerId		= INVOICE.intEntityCustomerId
	 , strInvoiceNumber			= INVOICE.strInvoiceNumber
	 , strTransactionType       = INVOICE.strTransactionType
	 , strSourceType			= INVOICE.strType
	 , strCFTransactionType     = CF.strTransactionType
	 , dtmDate					= INVOICE.dtmDate
	 , intCurrencyId			= INVOICE.intCurrencyId
	 , intCompanyLocationId		= INVOICE.intCompanyLocationId
	 , intShipToLocationId		= INVOICE.intShipToLocationId
	 , intTaxCodeId				= DETAIL.intTaxCodeId
	 , intInvoiceId				= DETAIL.intInvoiceId
	 , intInvoiceDetailId		= DETAIL.intInvoiceDetailId
	 , intItemId				= DETAIL.intItemId
	 , intItemUOMId				= DETAIL.intItemUOMId
	 , intTaxGroupId			= DETAIL.intTaxGroupId
	 , strCalculationMethod		= DETAIL.strCalculationMethod
	 , dblRate					= DETAIL.dblRate
	 , dblUnitPrice				= DETAIL.dblPrice * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblQtyShipped			= DETAIL.dblQtyShipped * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblAdjustedTax			= DETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblTax					= DETAIL.dblTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblTotalAdjustedTax		= DETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblTotalTax				= DETAIL.dblTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , ysnTaxExempt				= DETAIL.ysnTaxExempt
	 , ysnInvalidSetup			= DETAIL.ysnInvalidSetup
	 , dblTaxDifference			= (DETAIL.dblAdjustedTax - DETAIL.dblTax) * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblTaxAmount				= DETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblNonTaxable    		= (CASE WHEN INVOICE.dblTax = 0 
		 							THEN DETAIL.dblLineTotal / ISNULL(NULLIF(DETAIL.intTaxCodeCount, 0), 1.000000)
									ELSE (CASE WHEN DETAIL.dblAdjustedTax = 0.000000 --AND (DETAIL.ysnTaxExempt = 1 OR (DETAIL.ysnTaxExempt = 0 AND ISNULL(DETAIL.dblTotalAdjustedTax, 0.000000) = 0.000000)) 
												THEN DETAIL.dblLineTotal / ISNULL(NULLIF(DETAIL.intTaxCodeCount, 0), 1.000000)
												ELSE 0.000000 
											END) 
									END) * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblTaxable       		= (CASE WHEN INVOICE.dblTax = 0 
		 							THEN 0 
									ELSE (CASE WHEN DETAIL.dblAdjustedTax <> 0.000000 
												THEN DETAIL.dblLineTotal * (DETAIL.dblAdjustedTax/ISNULL(NULLIF(DETAIL.dblTotalAdjustedTax, 0), DETAIL.dblAdjustedTax))
												ELSE 0.000000 
											END) 
									END) * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblTotalSales 			= (CASE WHEN INVOICE.dblTax = 0 
		 							THEN DETAIL.dblLineTotal / ISNULL(NULLIF(DETAIL.intTaxCodeCount, 0), 1.000000)
									ELSE ((CASE WHEN DETAIL.dblAdjustedTax = 0.000000 --AND ISNULL(DETAIL.dblTotalAdjustedTax, 0.000000) = 0.000000 
												THEN DETAIL.dblLineTotal / ISNULL(NULLIF(DETAIL.intTaxCodeCount, 0), 1.000000)
												ELSE 0.000000 
											END) +
											(CASE WHEN DETAIL.dblAdjustedTax <> 0.000000 
												THEN DETAIL.dblLineTotal * (DETAIL.dblAdjustedTax/ISNULL(NULLIF(DETAIL.dblTotalAdjustedTax, 0), DETAIL.dblAdjustedTax))
												ELSE 0.000000 
											END))
									END) * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblTaxCollected			= INVOICE.dblTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , strCustomerNumber	    = CUSTOMER.strCustomerNumber
	 , strCustomerName			= CUSTOMER.strCustomerName
	 , strDisplayName			= CUSTOMER.strDisplayName
	 , strTaxNumber				= CUSTOMER.strTaxNumber
	 , intEntitySalespersonId	= INVOICE.intEntitySalespersonId
	 , strSalespersonNumber		= SALESPERSON.strSalespersonNumber
	 , strSalespersonName		= SALESPERSON.strSalespersonName
	 , strSalespersonDisplayName = SALESPERSON.strSalespersonDisplayName
	 , strCompanyName			= COMPANY.strCompanyName
	 , strCompanyAddress		= COMPANY.strCompanyAddress
	 , strCurrency				= CURRENCY.strCurrency
	 , strCurrencyDescription   = CURRENCY.strDescription
	 , strTaxGroup				= DETAIL.strTaxGroup
	 , strTaxAgency				= DETAIL.strTaxAgency
	 , strTaxCode				= DETAIL.strTaxCode
	 , strTaxCodeDescription	= DETAIL.strTaxCodeDescription
	 , strCountry				= DETAIL.strCountry
	 , strState					= DETAIL.strState
	 , strCounty				= DETAIL.strCounty
	 , strCity					= DETAIL.strCity
	 , strTaxClass				= DETAIL.strTaxClass
	 , strSalesTaxAccount		= DETAIL.strSalesTaxAccount
	 , strPurchaseTaxAccount	= DETAIL.strPurchaseTaxAccount	 
	 , strLocationName			= LOC.strLocationName
	 , strShipToLocationAddress = SHIPTO.strLocationName
	 , strItemNo				= DETAIL.strItemNo
	 , strCategoryCode			= DETAIL.strCategoryCode
	 , strItemCategory			= DETAIL.strCategoryCode
	 , intTaxClassId			= DETAIL.intTaxClassId
	 , intSalesTaxAccountId		= DETAIL.intSalesTaxAccountId
	 , intPurchaseTaxAccountId	= DETAIL.intPurchaseTaxAccountId
	 , intCategoryId			= DETAIL.intCategoryId
	 , intTonnageTaxUOMId		= DETAIL.intTonnageTaxUOMId
	 , dblQtyTonShipped			= DETAIL.dblQtyTonShipped * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , strFederalTaxId 			= CUSTOMER.strFederalTaxId
	 , strStateTaxId			= CUSTOMER.strStateTaxId
FROM dbo.tblARInvoice INVOICE WITH (NOLOCK)
INNER JOIN (
	SELECT intInvoiceId				= ID.intInvoiceId
		 , intInvoiceDetailId		= ID.intInvoiceDetailId
		 , intItemId				= ID.intItemId
		 , intItemUOMId				= ID.intItemUOMId
		 , intTaxCodeId				= IDT.intTaxCodeId
		 , intTaxGroupId			= IDT.intTaxGroupId
		 , strCalculationMethod		= IDT.strCalculationMethod
		 , dblRate					= IDT.dblRate
		 , dblPrice					= ID.dblPrice
		 , dblQtyShipped			= ID.dblQtyShipped
		 , dblLineTotal				= ID.dblQtyShipped * ID.dblPrice
		 , dblAdjustedTax			= IDT.dblAdjustedTax
		 , dblTax					= IDT.dblTax		 
		 , dblTotalAdjustedTax		= ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0)		 
		 , ysnTaxExempt				= IDT.ysnTaxExempt		
		 , ysnInvalidSetup			= IDT.ysnInvalidSetup		
		 , strTaxGroup				= TAXGROUP.strTaxGroup
		 , strTaxAgency				= TAXCODE.strTaxAgency
		 , strTaxCode				= TAXCODE.strTaxCode
		 , strTaxCodeDescription	= TAXCODE.strDescription
		 , strCountry				= TAXCODE.strCountry
		 , strState					= TAXCODE.strState
		 , strCounty				= TAXCODE.strCounty
		 , strCity					= TAXCODE.strCity
		 , strTaxClass				= TAXCLASS.strTaxClass
		 , strSalesTaxAccount		= SALESACCOUNT.strAccountId
		 , strPurchaseTaxAccount	= PURCHASEACCOUNT.strAccountId
		 , strItemNo				= ITEM.strItemNo
		 , strCategoryCode			= CATEGORY.strCategoryCode
		 , intTaxClassId			= IDT.intTaxClassId
		 , intSalesTaxAccountId		= TAXCODE.intSalesTaxAccountId
		 , intPurchaseTaxAccountId	= TAXCODE.intPurchaseTaxAccountId
		 , intCategoryId			= ITEM.intCategoryId
		 , intTaxCodeCount			= ISNULL(TAXTOTAL.intTaxCodeCount, TAXCLASSTOTAL.intTaxClassCount)
		 , intTonnageTaxUOMId		= ITEM.intTonnageTaxUOMId
		 , dblQtyTonShipped			= CASE WHEN ITEM.intTonnageTaxUOMId IS NOT NULL THEN CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ISNULL(ITEMUOMSETUP.intItemUOMId, ID.intItemUOMId), ID.dblQtyShipped)) ELSE ID.dblQtyShipped END
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceDetailId
			 , intTaxCodeId
			 , intTaxGroupId
			 , intTaxClassId
			 , strCalculationMethod
			 , dblRate
			 , dblAdjustedTax		
			 , dblTax				
			 , ysnTaxExempt
			 ,ysnTaxAdjusted
			 , ysnInvalidSetup
		FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)
	) IDT ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	LEFT JOIN (
		SELECT intInvoiceDetailId
			 , dblTotalAdjustedTax	= SUM(dblAdjustedTax)			 
			 , intTaxCodeCount		= COUNT(intInvoiceDetailTaxId)
		FROM tblARInvoiceDetailTax WITH (NOLOCK)
		WHERE ysnTaxExempt = 0
		GROUP BY intInvoiceDetailId
	) TAXTOTAL ON ID.intInvoiceDetailId = TAXTOTAL.intInvoiceDetailId
	INNER JOIN (
		SELECT intItemId
			 , intCategoryId
			 , intTonnageTaxUOMId	= CASE WHEN ISNULL(ysnTonnageTax, 0) = 1 THEN intTonnageTaxUOMId ELSE NULL END
			 , strItemNo
		FROM dbo.tblICItem WITH (NOLOCK)
	) ITEM ON ID.intItemId = ITEM.intItemId
	INNER JOIN (
		SELECT intTaxClassId
			 , intCategoryId
		FROM dbo.tblICCategoryTax ICT WITH (NOLOCK)
	) ITEMTAXCATEGORY ON ITEMTAXCATEGORY.intTaxClassId = IDT.intTaxClassId
					 AND ITEMTAXCATEGORY.intCategoryId = ITEM.intCategoryId
	CROSS APPLY (
		SELECT intTaxClassCount	= COUNT(*)
		FROM dbo.tblICCategoryTax ICT WITH (NOLOCK)
		WHERE ICT.intCategoryId = ITEM.intCategoryId
		  AND ICT.intTaxClassId IN (SELECT TC.intTaxClassId FROM tblSMTaxGroupCode TGC INNER JOIN tblSMTaxCode TC ON TGC.intTaxCodeId = TC.intTaxCodeId WHERE ID.intTaxGroupId IS NOT NULL AND TGC.intTaxGroupId = ID.intTaxGroupId OR ID.intTaxGroupId IS NULL)
		GROUP BY intCategoryId
	) TAXCLASSTOTAL
	LEFT JOIN (
		SELECT intItemUOMId
			 , intItemId
			 , intUnitMeasureId
		FROM tblICItemUOM WITH (NOLOCK) 
	) ITEMUOMSETUP ON ITEMUOMSETUP.intItemId = ITEM.intItemId
				  AND ITEMUOMSETUP.intUnitMeasureId = ITEM.intTonnageTaxUOMId
	INNER JOIN (
		SELECT intCategoryId
			 , strCategoryCode
		FROM dbo.tblICCategory WITH (NOLOCK)
	) CATEGORY ON ITEM.intCategoryId = CATEGORY.intCategoryId
	LEFT JOIN (
		SELECT intTaxGroupId
			 , strTaxGroup
		FROM dbo.tblSMTaxGroup WITH (NOLOCK)
	) TAXGROUP ON ID.intTaxGroupId = TAXGROUP.intTaxGroupId
	INNER JOIN (
		SELECT intTaxCodeId
			 , intSalesTaxAccountId
			 , intPurchaseTaxAccountId
			 , strTaxAgency
			 , strTaxCode
			 , strDescription
			 , strCountry
			 , strState
			 , strCounty
			 , strCity			 
		FROM dbo.tblSMTaxCode WITH (NOLOCK)
	) TAXCODE ON IDT.intTaxCodeId = TAXCODE.intTaxCodeId
	INNER JOIN (
		SELECT intTaxClassId
			 , strTaxClass
		FROM dbo.tblSMTaxClass WITH (NOLOCK)
	) TAXCLASS ON IDT.intTaxClassId = TAXCLASS.intTaxClassId
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
) DETAIL ON INVOICE.intInvoiceId = DETAIL.intInvoiceId
INNER JOIN (
	SELECT intEntityId			= ENTITY.intEntityId 
		 , strCustomerNumber	= CASE WHEN C.strCustomerNumber = '' THEN ENTITY.strEntityNo ELSE C.strCustomerNumber END
		 , strCustomerName		= ENTITY.strName
		 , strDisplayName		= ISNULL(C.strCustomerNumber, '') + ' - ' + ISNULL(ENTITY.strName, '')
		 , strStateTaxId  		= ENTITY.strStateTaxId
		 , strFederalTaxId		= ENTITY.strFederalTaxId
		 , strTaxNumber			= C.strTaxNumber
	FROM dbo.tblEMEntity ENTITY WITH (NOLOCK) 
	INNER JOIN (
		SELECT intEntityId
			 , strCustomerNumber
			 , strTaxNumber
		FROM dbo.tblARCustomer WITH (NOLOCK)
	) C ON ENTITY.intEntityId = C.intEntityId
) CUSTOMER ON INVOICE.intEntityCustomerId = CUSTOMER.intEntityId
LEFT JOIN (
	SELECT intEntityId					= ENTITY.intEntityId 
		 , strSalespersonNumber			= ISNULL(NULLIF(SP.strSalespersonId, ''), ENTITY.strEntityNo)
		 , strSalespersonName			= ENTITY.strName
		 , strSalespersonDisplayName	= ISNULL(NULLIF(SP.strSalespersonId, ''), ENTITY.strEntityNo) + ' - ' + ISNULL(ENTITY.strName, '')
	FROM dbo.tblEMEntity ENTITY WITH (NOLOCK) 
	INNER JOIN (
		SELECT intEntityId
			 , strSalespersonId
		FROM dbo.tblARSalesperson WITH (NOLOCK)
	) SP ON ENTITY.intEntityId = SP.intEntityId
) SALESPERSON ON INVOICE.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT OUTER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOC ON INVOICE.intCompanyLocationId	 = LOC.intCompanyLocationId
LEFT OUTER JOIN (
	SELECT intEntityLocationId
	     , strLocationName
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) SHIPTO ON INVOICE.intShipToLocationId = SHIPTO.intEntityLocationId
LEFT OUTER JOIN (
	SELECT intCurrencyID
		 , strCurrency
		 , strDescription 
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CURRENCY ON INVOICE.intCurrencyId = CURRENCY.intCurrencyID
LEFT OUTER JOIN (
	SELECT intInvoiceId
		 , strTransactionType
	FROM dbo.tblCFTransaction WITH (NOLOCK)
	WHERE intInvoiceId IS NOT NULL
) CF ON INVOICE.intInvoiceId = CF.intInvoiceId 
    AND INVOICE.strType = 'CF Tran'
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress] (NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
WHERE INVOICE.ysnPosted = 1
