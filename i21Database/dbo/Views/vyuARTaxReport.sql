CREATE VIEW [dbo].[vyuARTaxReport]
AS
SELECT 
	 intEntityCustomerId		= INVOICE.intEntityCustomerId
	,strInvoiceNumber			= INVOICE.strInvoiceNumber
	,strTransactionType  		= INVOICE.strTransactionType
	,strSourceType				= INVOICE.strType
	,strCFTransactionType 		= CF.strTransactionType
	,dtmDate					= CAST(INVOICE.dtmDate AS DATE)
	,dtmPostDate				= CAST(INVOICE.dtmPostDate AS DATE)
	,dtmDueDate					= CAST(INVOICE.dtmDueDate AS DATE)
	,intCurrencyId				= INVOICE.intCurrencyId
	,intCompanyLocationId		= INVOICE.intCompanyLocationId
	,intShipToLocationId		= INVOICE.intShipToLocationId
	,intTaxCodeId				= DETAIL.intTaxCodeId
	,intInvoiceId				= DETAIL.intInvoiceId
	,intInvoiceDetailId			= DETAIL.intInvoiceDetailId
	,intItemId					= DETAIL.intItemId
	,intItemUOMId				= DETAIL.intItemUOMId
	,intTaxGroupId				= DETAIL.intTaxGroupId
	,strCalculationMethod		= DETAIL.strCalculationMethod
	,dblRate					= DETAIL.dblRate
	,dblUnitPrice				= DETAIL.dblPrice * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblQtyShipped				= DETAIL.dblQtyShipped * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblAdjustedTax				= DETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblTax						= DETAIL.dblTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblTotalAdjustedTax		= DETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblTotalTax				= DETAIL.dblTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,ysnTaxExempt				= DETAIL.ysnTaxExempt
	,ysnInvalidSetup			= DETAIL.ysnInvalidSetup
	,dblTaxDifference			= (DETAIL.dblAdjustedTax - DETAIL.dblTax) * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblTaxAmount				= DETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblTaxAmountFunctional		= DETAIL.dblAdjustedTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	, dblNonTaxable    		= (CASE WHEN INVOICE.dblTax = 0 
		 							THEN DETAIL.dblLineTotal 
									ELSE (CASE WHEN DETAIL.dblAdjustedTax = 0.000000 
												THEN DETAIL.dblLineTotal 
												ELSE 0.000000 
											END) 
									END) * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblNonTaxableFunctional	= (CASE WHEN INVOICE.dblBaseTax = 0 
								THEN DETAIL.dblBaseLineTotal / ISNULL(NULLIF(DETAIL.intTaxCodeCount, 0), 1.000000)
								ELSE (CASE WHEN DETAIL.dblBaseAdjustedTax = 0.000000
											THEN DETAIL.dblBaseLineTotal / ISNULL(NULLIF(DETAIL.intTaxCodeCount, 0), 1.000000)
											ELSE 0.000000 
										END) 
								END) * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	 , dblTaxable       		= (CASE WHEN INVOICE.dblTax = 0 
		 							THEN 0 
									ELSE (CASE WHEN DETAIL.dblAdjustedTax <> 0.000000 
												THEN CASE WHEN DETAIL.ysnTaxExempt = 0 
														  THEN DETAIL.dblLineTotal 
														  ELSE 0.000000
													 END
												ELSE 0.000000 
											END) 
									END) 
	,dblTaxableFunctional		= (CASE WHEN INVOICE.dblBaseTax = 0 
								THEN 0 
								ELSE (CASE WHEN DETAIL.dblBaseAdjustedTax <> 0.000000 
											THEN CASE WHEN DETAIL.ysnTaxExempt = 0 
														THEN DETAIL.dblBaseLineTotal * (DETAIL.dblBaseAdjustedTax/ISNULL(NULLIF(DETAIL.dblBaseTotalAdjustedTax, 0), DETAIL.dblBaseAdjustedTax))
														ELSE 0.000000
													END
											ELSE 0.000000 
										END) 
								END) * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblTotalSales 				= DETAIL.dblLineTotal * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblTotalSalesFunctional	= DETAIL.dblBaseLineTotal * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,dblTaxCollected			= INVOICE.dblTax * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,strCustomerNumber	    	= CUSTOMER.strCustomerNumber
	,strCustomerName			= CUSTOMER.strCustomerName
	,strCustomerCity			= CUSTOMER.strCustomerCity
	,strCustomerState			= CUSTOMER.strCustomerState
	,strCustomerAddress			= CUSTOMER.strCustomerAddress
	,strCustomerZipCode			= CUSTOMER.strCustomerZipCode
	,strCustomerCountry			= CUSTOMER.strCustomerCountry
	,strCustomerEmail			= CUSTOMER.strCustomerEmail
	,strDisplayName				= CUSTOMER.strDisplayName
	,strTaxNumber				= CUSTOMER.strTaxNumber
	,intEntitySalespersonId		= INVOICE.intEntitySalespersonId
	,strSalespersonNumber		= SALESPERSON.strSalespersonNumber
	,strSalespersonName			= SALESPERSON.strSalespersonName
	,strSalespersonDisplayName	= SALESPERSON.strSalespersonDisplayName
	,strCompanyName				= COMPANY.strCompanyName
	,strCompanyAddress			= COMPANY.strCompanyAddress
	,strCurrency				= CURRENCY.strCurrency
	,strCurrencyDescription   	= CURRENCY.strDescription
	,strTaxGroup				= DETAIL.strTaxGroup
	,strTaxAgency				= DETAIL.strTaxAgency
	,strTaxCode					= DETAIL.strTaxCode
	,strTaxCodeDescription		= DETAIL.strTaxCodeDescription
	,strCountry					= DETAIL.strCountry
	,strState					= DETAIL.strState
	,strCounty					= DETAIL.strCounty
	,strCity					= DETAIL.strCity
	,strTaxClass				= DETAIL.strTaxClass
	,strTaxPoint				= DETAIL.strTaxPoint
	,strSalesTaxAccount			= DETAIL.strSalesTaxAccount
	,strPurchaseTaxAccount		= DETAIL.strPurchaseTaxAccount	 
	,strLocationName			= LOC.strLocationName
	,strShipToLocationAddress 	= SHIPTO.strLocationName
	,strItemNo					= DETAIL.strItemNo
	,strCategoryCode			= DETAIL.strCategoryCode
	,strItemCategory			= DETAIL.strCategoryCode
	,intTaxClassId				= DETAIL.intTaxClassId
	,intSalesTaxAccountId		= DETAIL.intSalesTaxAccountId
	,intPurchaseTaxAccountId	= DETAIL.intPurchaseTaxAccountId
	,intCategoryId				= DETAIL.intCategoryId
	,intTonnageTaxUOMId			= DETAIL.intTonnageTaxUOMId
	,dblQtyTonShipped			= DETAIL.dblQtyTonShipped * [dbo].[fnARGetInvoiceAmountMultiplier](INVOICE.strTransactionType)
	,strFederalTaxId 			= CUSTOMER.strFederalTaxId
	,strStateTaxId				= CUSTOMER.strStateTaxId
	,dblInvoiceTotal          	= INVOICE.dblInvoiceTotal
	,intFreightTermId			= INVOICE.intFreightTermId
	,strAccountStatusCode 		= STATUSCODES.strAccountStatusCode
	,strCommodityCode			= DETAIL.strCommodityCode
	,strUnitOfMeasure			= DETAIL.strUnitOfMeasure
	,ysnPaid					= INVOICE.ysnPaid
	,intARAccountId				= INVOICE.intAccountId
	,strARAccountId				= ARACCOUNT.strAccountId
	,intSalesAccountId			= DETAIL.intSalesAccountId
	,strSalesAccountId			= DETAIL.strAccountId
	,strShipToName				= SHIPTO.strCheckPayeeName
	,strShipToAddress			= SHIPTO.strAddress
	,strShipToCity				= SHIPTO.strCity
	,strShipToState				= SHIPTO.strState
	,strShipToCountry			= SHIPTO.strCountry
	,dblPayment					= INVOICE.dblPayment
	,dblPaymentFunctional		= INVOICE.dblBasePayment
	,strCheckNumbers			= PAYMENT.strCheckNumbers
	,ysnOverrideTaxGroup		= DETAIL.ysnOverrideTaxGroup
	,dtmDateCreated				= CAST(INVOICE.dtmDateCreated AS DATE)
	,dtmUpdatedDate				= CAST(AUDITLOG.dtmUpdatedDate AS DATE)
FROM dbo.tblARInvoice INVOICE WITH (NOLOCK)
INNER JOIN (
	SELECT 
		 intInvoiceId			= ID.intInvoiceId
		,intInvoiceDetailId		= ID.intInvoiceDetailId
		,intItemId				= ID.intItemId
		,intItemUOMId			= ID.intItemUOMId
		,intTaxCodeId			= IDT.intTaxCodeId
		,intTaxGroupId			= IDT.intTaxGroupId
		,strCalculationMethod	= IDT.strCalculationMethod
		,dblRate				= IDT.dblRate
		,dblPrice				= ID.dblPrice
		,dblQtyShipped			= ID.dblQtyShipped
		,dblLineTotal			= ID.dblQtyShipped * ID.dblPrice * ISNULL(ITEMUOMSETUP.dblUnitQty,1)
		,dblBaseLineTotal		= ID.dblQtyShipped * ID.dblBasePrice * ISNULL(ITEMUOMSETUP.dblUnitQty,1)
		,dblAdjustedTax			= IDT.dblAdjustedTax
		,dblBaseAdjustedTax		= IDT.dblBaseAdjustedTax
		,dblTax					= IDT.dblTax
		,dblBaseTax				= IDT.dblBaseAdjustedTax
		,dblTotalAdjustedTax	= ISNULL(TAXTOTAL.dblTotalAdjustedTax, 0)
		,dblBaseTotalAdjustedTax= ISNULL(TAXTOTAL.dblBaseTotalAdjustedTax, 0)
		,ysnTaxExempt			= IDT.ysnTaxExempt		
		,ysnInvalidSetup		= IDT.ysnInvalidSetup		
		,strTaxGroup			= TAXGROUP.strTaxGroup
		,strTaxAgency			= TAXCODE.strTaxAgency
		,strTaxCode				= TAXCODE.strTaxCode
		,strTaxCodeDescription	= TAXCODE.strDescription
		,strCountry				= TAXCODE.strCountry
		,strState				= TAXCODE.strState
		,strCounty				= TAXCODE.strCounty
		,strCity				= TAXCODE.strCity
		,strTaxClass			= TAXCLASS.strTaxClass
		,strSalesTaxAccount		= SALESTAXACCOUNT.strAccountId
		,strPurchaseTaxAccount	= PURCHASEACCOUNT.strAccountId
		,strItemNo				= ITEM.strItemNo
		,strCategoryCode		= CATEGORY.strCategoryCode
		,intTaxClassId			= IDT.intTaxClassId
		,intSalesTaxAccountId	= IDT.intSalesTaxAccountId
		,intPurchaseTaxAccountId= TAXCODE.intPurchaseTaxAccountId
		,intCategoryId			= ITEM.intCategoryId
		,intTaxCodeCount		= COALESCE(TAXTOTAL.intTaxCodeCount, TAXCLASSTOTAL.intTaxClassCount, TAXCLASSTOTALBYINVOICEDETAIL.intTaxClassCount)
		,intTonnageTaxUOMId		= ITEM.intTonnageTaxUOMId
		,dblQtyTonShipped		= CASE WHEN ITEM.intTonnageTaxUOMId IS NOT NULL THEN CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ISNULL(ITEMUOMSETUPTONNAGE.intItemUOMId, ID.intItemUOMId), ID.dblQtyShipped)) ELSE ID.dblQtyShipped END
		,strTaxPoint			= TAXCODE.strTaxPoint
		,strCommodityCode		= ICC.strCommodityCode 
		,strUnitOfMeasure		= ICUM.strUnitMeasure
		,strAccountId			= SALESACCOUNT.strAccountId
		,intSalesAccountId		= ID.intSalesAccountId
		,ysnOverrideTaxGroup    = ISNULL(ID.ysnOverrideTaxGroup, 0)
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN (
		SELECT 
			 intInvoiceDetailId
			,intTaxCodeId
			,intTaxGroupId
			,intTaxClassId
			,intSalesTaxAccountId
			,strCalculationMethod
			,dblRate
			,dblAdjustedTax
			,dblBaseAdjustedTax
			,dblTax
			,ysnTaxExempt
			,ysnTaxAdjusted
			,ysnInvalidSetup			 
		FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)
	) IDT ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	LEFT JOIN (
		SELECT 
			 intInvoiceDetailId
			,dblTotalAdjustedTax		= SUM(dblAdjustedTax)
			,dblBaseTotalAdjustedTax	= SUM(dblBaseAdjustedTax)
			,intTaxCodeCount			= COUNT(intInvoiceDetailTaxId)
		FROM tblARInvoiceDetailTax WITH (NOLOCK)
		WHERE ysnTaxExempt = 0
		GROUP BY intInvoiceDetailId
	) TAXTOTAL ON ID.intInvoiceDetailId = TAXTOTAL.intInvoiceDetailId
	INNER JOIN (
		SELECT 
			 intItemId
			,intCategoryId
			,intTonnageTaxUOMId	= CASE WHEN ISNULL(ysnTonnageTax, 0) = 1 THEN intTonnageTaxUOMId ELSE NULL END
			,strItemNo
			,intCommodityId
		FROM dbo.tblICItem WITH (NOLOCK)
	) ITEM ON ID.intItemId = ITEM.intItemId
	OUTER APPLY (
		SELECT intTaxClassCount	= COUNT(*)
		FROM dbo.tblARInvoiceDetailTax TCT_IDT WITH (NOLOCK)
		INNER JOIN tblARInvoiceDetail TCT_ID WITH (NOLOCK)
		ON TCT_IDT.intInvoiceDetailId = TCT_ID.intInvoiceDetailId
		WHERE TCT_ID.intItemId = ITEM.intItemId
		  AND IDT.intTaxClassId IN (SELECT TC.intTaxClassId FROM tblSMTaxGroupCode TGC INNER JOIN tblSMTaxCode TC ON TGC.intTaxCodeId = TC.intTaxCodeId WHERE ID.intTaxGroupId IS NOT NULL AND TGC.intTaxGroupId = ID.intTaxGroupId OR ID.intTaxGroupId IS NULL)
		  AND TCT_ID.intInvoiceDetailId IN (SELECT TARID.intInvoiceDetailId FROM tblARInvoiceDetail TARID WHERE TARID.intInvoiceDetailId = ID.intInvoiceDetailId)
		GROUP BY TCT_ID.intCategoryId
	) TAXCLASSTOTALBYINVOICEDETAIL
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
	) ITEMUOMSETUPTONNAGE ON ITEMUOMSETUPTONNAGE.intItemId = ITEM.intItemId
				  AND ITEMUOMSETUPTONNAGE.intUnitMeasureId = ITEM.intTonnageTaxUOMId
	LEFT JOIN (
		SELECT intItemUOMId
			 , intItemId
			 , intUnitMeasureId
			 , dblUnitQty
		FROM tblICItemUOM WITH (NOLOCK) 
	) ITEMUOMSETUP ON ITEMUOMSETUP.intItemId = ITEM.intItemId
				  AND ITEMUOMSETUP.intItemUOMId = ID.intItemUOMId
	LEFT JOIN tblICUnitMeasure ICUM ON ITEMUOMSETUP.intUnitMeasureId = ICUM.intUnitMeasureId
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
		SELECT 
			 intTaxCodeId
			,intSalesTaxAccountId
			,intPurchaseTaxAccountId
			,strTaxAgency
			,strTaxCode
			,strDescription
			,strCountry
			,strState
			,strCounty
			,strCity
			,strTaxPoint
		FROM dbo.tblSMTaxCode WITH (NOLOCK)
	) TAXCODE ON IDT.intTaxCodeId = TAXCODE.intTaxCodeId
	INNER JOIN (
		SELECT intTaxClassId
			 , strTaxClass
		FROM dbo.tblSMTaxClass WITH (NOLOCK)
	) TAXCLASS ON IDT.intTaxClassId = TAXCLASS.intTaxClassId
	LEFT OUTER JOIN (
		SELECT 
			 intAccountId
			,strAccountId 
		FROM dbo.tblGLAccount WITH (NOLOCK)
	) SALESTAXACCOUNT ON IDT.intSalesTaxAccountId = SALESTAXACCOUNT.intAccountId 
	LEFT OUTER JOIN (
		SELECT 
			 intAccountId
			,strAccountId 
		FROM dbo.tblGLAccount WITH (NOLOCK)
	) PURCHASEACCOUNT ON TAXCODE.intPurchaseTaxAccountId = PURCHASEACCOUNT.intAccountId
	LEFT JOIN tblICCommodity ICC ON ICC.intCommodityId = ITEM.intCommodityId
	OUTER APPLY (
		SELECT TOP 1 strAccountId
		FROM tblGLAccount
		WHERE intAccountId = ID.intSalesAccountId
	) SALESACCOUNT

	UNION ALL
 
	SELECT intInvoiceId				= DF.intInvoiceId
	     , intInvoiceDetailId		= NULL
	     , intItemId				= NULL
	     , intItemUOMId				= NULL
	     , intTaxCodeId				= DF.intTaxCodeId
	     , intTaxGroupId			= DF.intTaxGroupId
	     , strCalculationMethod		= 'Texas Loading Fee'
	     , dblRate					= DF.dblTax
	     , dblPrice					= DF.dblTax
	     , dblQtyShipped			= ID.dblQtyShipped
	     , dblLineTotal				= ID.dblLineTotal
	     , dblBaseLineTotal			= ID.dblLineTotal
	     , dblAdjustedTax			= DF.dblTax
	     , dblBaseAdjustedTax		= DF.dblTax
	     , dblTax					= DF.dblTax
	     , dblBaseTax				= DF.dblTax
	     , dblTotalAdjustedTax		= DF.dblTax
	     , dblBaseTotalAdjustedTax	= DF.dblTax
	     , ysnTaxExempt				= CAST(0 AS BIT)  
	     , ysnInvalidSetup			= CAST(0 AS BIT)  
	     , strTaxGroup				= TG.strTaxGroup
	     , strTaxAgency				= TC.strTaxAgency
	     , strTaxCode				= TC.strTaxCode
	     , strTaxCodeDescription	= TC.strDescription
	     , strCountry				= TC.strCountry
	     , strState					= TC.strState
	     , strCounty				= TC.strCounty
	     , strCity					= TC.strCity
	     , strTaxClass				= TAXCLASS.strTaxClass
	     , strSalesTaxAccount		= GLS.strAccountId
	     , strPurchaseTaxAccount	= GLP.strAccountId
	     , strItemNo				= NULL
	     , strCategoryCode			= NULL
	     , intTaxClassId			= TC.intTaxClassId
	     , intSalesTaxAccountId		= TC.intSalesTaxAccountId
	     , intPurchaseTaxAccountId	= TC.intPurchaseTaxAccountId
	     , intCategoryId			= NULL
	     , intTaxCodeCount			= 1
	     , intTonnageTaxUOMId		= NULL
	     , dblQtyTonShipped			= ID.dblQtyShipped
	     , strTaxPoint				= TC.strTaxPoint
	     , strCommodityCode			= NULL 
	     , strUnitOfMeasure			= NULL
	     , strAccountId				= GLS.strAccountId
	     , intSalesAccountId		= NULL
	     , ysnOverrideTaxGroup		= CAST(0 AS BIT)
	FROM dbo.tblARInvoiceDeliveryFee DF WITH (NOLOCK)
	INNER JOIN tblSMTaxCode TC ON DF.intTaxCodeId = TC.intTaxCodeId
	INNER JOIN tblSMTaxGroup TG ON DF.intTaxGroupId = TG.intTaxGroupId
	INNER JOIN tblSMTaxClass TAXCLASS ON TC.intTaxClassId = TAXCLASS.intTaxClassId
	INNER JOIN tblGLAccount GLS ON TC.intSalesTaxAccountId = GLS.intAccountId
	INNER JOIN tblGLAccount GLP ON TC.intPurchaseTaxAccountId = GLP.intAccountId
	INNER JOIN (
		SELECT dblQtyShipped = SUM(dblQtyShipped)
			 , dblLineTotal  = SUM(dblTotal)
			 , intInvoiceId  = ID.intInvoiceId
		FROM tblARInvoiceDetail ID
		GROUP BY ID.intInvoiceId
	) ID ON DF.intInvoiceId = ID.intInvoiceId
) DETAIL ON INVOICE.intInvoiceId = DETAIL.intInvoiceId
INNER JOIN (
	SELECT 
		 intEntityId		= ENTITY.intEntityId 
		,strCustomerNumber	= CASE WHEN C.strCustomerNumber = '' THEN ENTITY.strEntityNo ELSE C.strCustomerNumber END
		,strCustomerName	= ENTITY.strName
		,strDisplayName		= ISNULL(C.strCustomerNumber, '') + ' - ' + ISNULL(ENTITY.strName, '')
		,strStateTaxId  	= ENTITY.strStateTaxId
		,strFederalTaxId	= ENTITY.strFederalTaxId
		,strTaxNumber		= C.strTaxNumber
		,strCustomerCity	= EMEL.strCity
		,strCustomerState	= EMEL.strState
		,strCustomerAddress	= EMEL.strAddress
		,strCustomerZipCode	= EMEL.strZipCode
		,strCustomerCountry	= EMEL.strCountry
		,strCustomerEmail	= ENTITY.strEmail
	FROM dbo.tblEMEntity ENTITY WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strCustomerNumber
			 , strTaxNumber
		FROM dbo.tblARCustomer WITH (NOLOCK)
	) C ON ENTITY.intEntityId = C.intEntityId
	LEFT JOIN tblEMEntityLocation EMEL ON ENTITY.intEntityId = EMEL.intEntityId AND ysnDefaultLocation = 1
) CUSTOMER ON INVOICE.intEntityCustomerId = CUSTOMER.intEntityId
LEFT JOIN (
	SELECT 
		 intEntityId					= ENTITY.intEntityId 
		,strSalespersonNumber			= ISNULL(NULLIF(SP.strSalespersonId, ''), ENTITY.strEntityNo)
		,strSalespersonName			= ENTITY.strName
		,strSalespersonDisplayName	= ISNULL(NULLIF(SP.strSalespersonId, ''), ENTITY.strEntityNo) + ' - ' + ISNULL(ENTITY.strName, '')
	FROM dbo.tblEMEntity ENTITY WITH (NOLOCK) 
	INNER JOIN (
		SELECT 
			 intEntityId
			,strSalespersonId
		FROM dbo.tblARSalesperson WITH (NOLOCK)
	) SP ON ENTITY.intEntityId = SP.intEntityId
) SALESPERSON ON INVOICE.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT OUTER JOIN (
	SELECT 
		 intCompanyLocationId
		,strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOC ON INVOICE.intCompanyLocationId	 = LOC.intCompanyLocationId
LEFT OUTER JOIN (
	SELECT 
		 intEntityLocationId
		,strLocationName
		,strCheckPayeeName
		,strAddress
		,strCity
		,strState
		,strCountry
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) SHIPTO ON INVOICE.intShipToLocationId = SHIPTO.intEntityLocationId
LEFT OUTER JOIN (
	SELECT 
		 intCurrencyID
		,strCurrency
		,strDescription 
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CURRENCY ON INVOICE.intCurrencyId = CURRENCY.intCurrencyID
LEFT OUTER JOIN (
	SELECT 
		 intInvoiceId
		,strTransactionType
	FROM dbo.tblCFTransaction WITH (NOLOCK)
	WHERE intInvoiceId IS NOT NULL
) CF ON INVOICE.intInvoiceId = CF.intInvoiceId 
    AND INVOICE.strType = 'CF Tran'
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress] (NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (
	 SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1) COLLATE Latin1_General_CI_AS
	 FROM (
	  SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + ', '
	  FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
	  INNER JOIN (
	   SELECT intAccountStatusId
		 , strAccountStatusCode
	   FROM dbo.tblARAccountStatus WITH (NOLOCK)
	  ) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
	  WHERE CAS.intEntityCustomerId = INVOICE.intEntityCustomerId
	  FOR XML PATH ('')
	 ) SC (strAccountStatusCode)
) STATUSCODES
OUTER APPLY (
	SELECT TOP 1 strAccountId
	FROM tblGLAccount
	WHERE intAccountId = INVOICE.intAccountId
) ARACCOUNT
OUTER APPLY (
	SELECT strCheckNumbers = STUFF(
		(
			SELECT DISTINCT ',' + LTRIM(strPaymentInfo)
			FROM tblARPayment
			WHERE intPaymentId IN (
				SELECT intPaymentId
				FROM tblARPaymentDetail
				WHERE intInvoiceId = INVOICE.intInvoiceId
			)
			FOR XML PATH('')
		), 1, 2, ''
	)
) PAYMENT
OUTER APPLY (
	SELECT TOP 1
        [SMT].[intRecordId]	AS [intInvoiceId], 
        DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [VSMAD].[changeDate]) AS [dtmUpdatedDate]
    FROM [dbo].[vyuSMAuditDetail] AS [VSMAD]
    INNER JOIN [dbo].[tblSMLog] AS [SML] ON [VSMAD].[intLogId] = [SML].[intLogId]
    LEFT OUTER JOIN [dbo].[tblSMTransaction] AS [SMT] ON [SML].[intTransactionId] = [SMT].[intTransactionId]
    LEFT OUTER JOIN [dbo].[tblSMScreen] AS [SMS] ON [SMT].[intScreenId] = [SMS].[intScreenId]
    WHERE ([SML].[strType] = 'Audit') 
	AND ([VSMAD].[intParentAuditId] IS NULL) 
	AND ([VSMAD].[hidden] = 0 OR [VSMAD].[hidden] IS NULL) 
	AND (([SMS].[strNamespace] = 'AccountsReceivable.view.Invoice') OR (([SMS].[strNamespace] IS NULL) AND ('AccountsReceivable.view.Invoice' IS NULL))) 
	AND [SMT].[intRecordId] = INVOICE.[intInvoiceId]
	ORDER BY [VSMAD].[changeDate] DESC
) AUDITLOG
WHERE INVOICE.ysnPosted = 1