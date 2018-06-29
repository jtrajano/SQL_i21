CREATE VIEW [dbo].[vyuARSalesOrderReport]
AS
SELECT intSalesOrderId			= SO.intSalesOrderId
	 , intCompanyLocationId		= SO.intCompanyLocationId
	 , strCompanyName			= CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' ELSE COMPANY.strCompanyName END
	 , strCompanyAddress		= CASE WHEN L.strUseLocationAddress IS NULL OR L.strUseLocationAddress = 'No' OR L.strUseLocationAddress = '' OR L.strUseLocationAddress = 'Always'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, COMPANY.strAddress, COMPANY.strCity, COMPANY.strState, COMPANY.strZip, COMPANY.strCountry, NULL, COMPANY.ysnIncludeEntityName)
									   WHEN L.strUseLocationAddress = 'Yes'
											THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, L.strAddress, L.strCity, L.strStateProvince, L.strZipPostalCode, L.strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
									   WHEN L.strUseLocationAddress = 'Letterhead'
											THEN ''
								  END
	 , strOrderType				= ISNULL(SO.strType, 'Standard')
     , strCustomerName			= CUSTOMER.strName
	 , strCustomerNumber		= CUSTOMER.strCustomerNumber
	 , strLocationName			= L.strLocationName
	 , dtmDate					= SO.dtmDate
	 , strCurrency				= CUR.strCurrency
	 , strBOLNumber				= SO.strBOLNumber
	 , strOrderStatus			= SO.strOrderStatus
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strPONumber				= SO.strPONumber
	 , strShipVia				= SHIPVIA.strName
	 , strTerm					= T.strTerm
	 , dtmDueDate				= SO.dtmDueDate
	 , strFreightTerm			= FT.strFreightTerm
	 , strItemNo				= SALESORDERDETAIL.strItemNo
	 , strType					= SALESORDERDETAIL.strItemType
	 , intCategoryId			= CASE WHEN QT.strOrganization IN ('Product Type', 'Item Category') THEN SALESORDERDETAIL.intCategoryId ELSE NULL END
	 , strCategoryCode			= SALESORDERDETAIL.strCategoryCode
	 , strCategoryDescription   = SALESORDERDETAIL.strCategoryDescription
	 , intSalesOrderDetailId	= SALESORDERDETAIL.intSalesOrderDetailId
	 , dblContractBalance		= SALESORDERDETAIL.dblContractBalance
	 , strContractNumber		= SALESORDERDETAIL.strContractNumber
	 , strItem					= SALESORDERDETAIL.strItem
	 , strItemDescription		= SALESORDERDETAIL.strItemDescription
	 , strUnitMeasure			= SALESORDERDETAIL.strUnitMeasure
	 , intTaxCodeId				= SALESORDERDETAIL.intTaxCodeId
	 , strTransactionType		= SO.strTransactionType
	 , intQuoteTemplateId		= CASE WHEN SO.strTransactionType = 'Quote' THEN QT.intQuoteTemplateId ELSE NULL END
	 , strTemplateName			= CASE WHEN SO.strTransactionType = 'Quote' THEN QT.strTemplateName ELSE NULL END	 
	 , strOrganization			= CASE WHEN SO.strTransactionType = 'Quote' THEN QT.strOrganization ELSE NULL END
	 , ysnDisplayTitle			= CASE WHEN SO.strTransactionType = 'Quote' THEN QT.ysnDisplayTitle ELSE NULL END
	 , intProductTypeId			= CASE WHEN SO.strTransactionType = 'Quote' AND QT.strOrganization = 'Product Type' THEN SALESORDERDETAIL.intProductTypeId ELSE NULL END
	 , strProductTypeDescription = CASE WHEN SO.strTransactionType = 'Quote' THEN CASE WHEN SALESORDERDETAIL.intProductTypeId IS NULL THEN 'No Product Type' ELSE SALESORDERDETAIL.strProductTypeName + ' - ' + SALESORDERDETAIL.strProductTypeDescription END ELSE NULL END
	 , strProductTypeName		= CASE WHEN SO.strTransactionType = 'Quote' THEN SALESORDERDETAIL.strProductTypeName ELSE NULL END
	 , dtmExpirationDate		= CASE WHEN SO.strTransactionType = 'Quote' THEN SO.dtmExpirationDate ELSE NULL END
	 , strBillTo				= [dbo].fnARFormatCustomerAddress(NULL, NULL, SO.strBillToLocationName, SO.strBillToAddress, SO.strBillToCity, SO.strBillToState, SO.strBillToZipCode, SO.strBillToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
	 , strShipTo				= [dbo].fnARFormatCustomerAddress(NULL, NULL, SO.strShipToLocationName, SO.strShipToAddress, SO.strShipToCity, SO.strShipToState, SO.strShipToZipCode, SO.strShipToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
	 , strSalespersonName		= SALESPERSON.strName
	 , strOrderedByName			= EOB.strName
	 , strSplitName				= CASE WHEN ISNULL(ES.strDescription, '') <> '' THEN ES.strDescription ELSE ES.strSplitNumber END
	 , strSOHeaderComment		= SO.strComments
	 , strSOFooterComment		= SO.strFooterComments
	 , dblSalesOrderSubtotal	= ISNULL(SO.dblSalesOrderSubtotal, 0)
	 , dblShipping				= ISNULL(SO.dblShipping, 0)
	 , dblTax					= SALESORDERDETAIL.dblTotalTax
	 , dblSalesOrderTotal		= ISNULL(SO.dblSalesOrderTotal, 0)
	 , dblQtyShipped			= SALESORDERDETAIL.dblQtyShipped
	 , dblQtyOrdered			= SALESORDERDETAIL.dblQtyOrdered
	 , dblDiscount				= SALESORDERDETAIL.dblDiscount
	 , dblTotalTax				= ISNULL(SO.dblTax, 0)
	 , dblPrice					= SALESORDERDETAIL.dblPrice
	 , dblItemPrice				= SALESORDERDETAIL.dblItemPrice
	 , dblCategoryTotal			= CATEGORYTOTAL.dblCategoryTotal
	 , dblProductTotal			= PRODUCTTYPETOTAL.dblProductTotal
	 , strTaxCode				= SALESORDERDETAIL.strTaxCode
	 , dblTaxDetail				= SALESORDERDETAIL.dblAdjustedTax
	 , intDetailCount			= ISNULL(SALESORDERITEMS.intSalesOrderDetailCount, 0)
	 , ysnHasEmailSetup			= CASE WHEN (ISNULL(EMAILSETUP.intEmailSetupCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END 
	 , ysnHasRecipeItem			= CASE WHEN (ISNULL(RECIPEITEM.intRecipeItemCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , strQuoteType
	 , blbLogo					= dbo.fnSMGetCompanyLogo('Header')
	 , intRecipeId				= SALESORDERDETAIL.intRecipeId	 
	 , intOneLinePrintId		= SALESORDERDETAIL.intOneLinePrintId
	 , dblTotalWeight			= ISNULL(SO.dblTotalWeight, 0)
	 , strCustomerComments		= dbo.fnEMEntityMessage(CUSTOMER.intEntityId, 'Pick Ticket')
	 , ysnListBundleSeparately	= ISNULL(SALESORDERDETAIL.ysnListBundleSeparately, CONVERT(BIT, 0))
	 , dblTotalDiscount			= ISNULL(dblTotalDiscount,0) * -1
FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
LEFT JOIN (
	SELECT intSalesOrderId
		 , intCategoryId			= I.intCategoryId
		 , intSalesOrderDetailId	= SD.intSalesOrderDetailId
		 , intCommentTypeId			= SD.intCommentTypeId
		 , intRecipeId				= SD.intRecipeId
		 , intProductTypeId			= PDD.intProductTypeId
		 , intOneLinePrintId		= ISNULL(MFR.intOneLinePrintId, 1)
		 , intTaxCodeId				= SDT.intTaxCodeId
		 , strProductTypeName		= PDD.strProductTypeName
		 , strProductTypeDescription = PDD.strProductTypeDescription
		 , strItemDescription		= SD.strItemDescription
		 , strItemType				= I.strType
		 , strCategoryCode			= ICC.strCategoryCode
		 , strTaxCode				= SMT.strTaxCode
		 , strUnitMeasure			= UOM.strUnitMeasure
		 , strItem					= CASE WHEN ISNULL(I.strItemNo, '') = '' THEN SD.strItemDescription ELSE LTRIM(RTRIM(I.strItemNo)) + ' - ' + ISNULL(SD.strItemDescription, '') END
		 , strItemNo				= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN I.strItemNo ELSE NULL END
		 , dblTotalTax				= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblTotalTax, 0) ELSE NULL END
		 , dblQtyShipped			= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblQtyShipped, 0) ELSE NULL END
		 , dblQtyOrdered			= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblQtyOrdered, 0) ELSE NULL END
		 , dblDiscount				= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblDiscount, 0) / 100 ELSE NULL END
		 , dblPrice					= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblPrice, 0) ELSE NULL END
		 , dblItemPrice				= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblTotal, 0) ELSE NULL END
		 , dblAdjustedTax			= SDT.dblAdjustedTax
		 , dblContractBalance		= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN CASE WHEN SD.dblContractBalance = 0 THEN CD.dblBalance ELSE SD.dblContractBalance END ELSE NULL END
		 , strContractNumber		= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN CH.strContractNumber ELSE NULL END
		 , strCategoryDescription   = CASE WHEN I.intCategoryId IS NULL THEN 'No Item Category' ELSE ICC.strCategoryCode + ' - ' + ICC.strDescription END
		 , ysnListBundleSeparately	= I.ysnListBundleSeparately
	FROM dbo.tblSOSalesOrderDetail SD WITH (NOLOCK)
	LEFT JOIN (
		SELECT intItemId
		     , intCategoryId
			 , strItemNo
			 , strType
			 , ysnListBundleSeparately
		FROM dbo.tblICItem WITH (NOLOCK) 
	) I ON SD.intItemId = I.intItemId
	LEFT JOIN (
		SELECT intCategoryId
			 , strCategoryCode
			 , strDescription
		FROM dbo.tblICCategory WITH (NOLOCK)
	) ICC ON I.intCategoryId = ICC.intCategoryId
	LEFT JOIN (
		SELECT intCategoryId
			 , PD.*
		FROM dbo.tblARProductTypeDetail PDD WITH (NOLOCK)
		INNER JOIN (SELECT intProductTypeId
			             , strProductTypeName
					     , strProductTypeDescription
					FROM dbo.tblARProductType WITH (NOLOCK)
		) PD ON PDD.intProductTypeId = PD.intProductTypeId
	) PDD ON PDD.intCategoryId = ICC.intCategoryId
	LEFT JOIN (
		SELECT intSalesOrderDetailId
			 , intTaxCodeId
			 , dblAdjustedTax
		FROM dbo.tblSOSalesOrderDetailTax WITH (NOLOCK)
		WHERE dblAdjustedTax <> 0
	) SDT ON SD.intSalesOrderDetailId = SDT.intSalesOrderDetailId
	LEFT JOIN (
		SELECT intTaxCodeId
			 , strTaxCode
		FROM dbo.tblSMTaxCode WITH (NOLOCK)
	) SMT ON SDT.intTaxCodeId = SMT.intTaxCodeId
	LEFT JOIN (
		SELECT intItemId
			 , intItemUOMId
			 , strUnitMeasure
		FROM dbo.vyuARItemUOM WITH (NOLOCK)
	) UOM ON SD.intItemUOMId = UOM.intItemUOMId 
		 AND SD.intItemId = UOM.intItemId
	LEFT JOIN (
		SELECT intContractHeaderId
			 , strContractNumber
		FROM dbo.tblCTContractHeader  WITH (NOLOCK)
	) CH ON SD.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN (
		SELECT intContractDetailId
			 , dblBalance
		FROM dbo.tblCTContractDetail WITH (NOLOCK)
	) CD ON SD.intContractDetailId = CD.intContractDetailId
	LEFT JOIN (
		SELECT intRecipeId
		     , intOneLinePrintId
		FROM dbo.tblMFRecipe WITH (NOLOCK)
	) MFR ON SD.intRecipeId = MFR.intRecipeId
) SALESORDERDETAIL ON SO.intSalesOrderId = SALESORDERDETAIL.intSalesOrderId
LEFT JOIN (
	SELECT C.intEntityId
		 , C.strCustomerNumber
		 , C.ysnIncludeEntityName
		 , E.strName
	FROM dbo.tblARCustomer C WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId
					 , strName 
			    FROM dbo.tblEMEntity WITH (NOLOCK)
	) E ON C.intEntityId = E.intEntityId
) CUSTOMER ON CUSTOMER.intEntityId = SO.intEntityCustomerId
LEFT JOIN (
	SELECT SP.intEntityId
		 , strName
	FROM dbo.tblARSalesperson SP WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) ESP ON SP.intEntityId = ESP.intEntityId
) SALESPERSON ON SO.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT JOIN (
	SELECT SV.intEntityId
		 , ESV.strName
	FROM dbo.tblSMShipVia SV
	INNER JOIN (
		SELECT intEntityId
			 , strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) ESV ON SV.intEntityId = ESV.intEntityId
) SHIPVIA ON SO.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
		 , strUseLocationAddress
		 , strAddress
		 , strCity
		 , strStateProvince
		 , strZipPostalCode
		 , strCountry		 
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) L ON SO.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN (
	SELECT intCurrencyID
		 , strCurrency
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CUR ON SO.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (
	SELECT intTermID
		 , strTerm
	FROM dbo.tblSMTerm WITH (NOLOCK)
) T ON SO.intTermId = T.intTermID
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) EOB ON SO.intOrderedById = EOB.intEntityId
LEFT JOIN (
	SELECT intFreightTermId
		 , strFreightTerm
	FROM dbo.tblSMFreightTerms WITH (NOLOCK)
) FT ON SO.intFreightTermId = FT.intFreightTermId
LEFT JOIN (
	SELECT intSplitId
		 , strDescription
		 , strSplitNumber
	FROM dbo.tblEMEntitySplit WITH (NOLOCK)
) ES ON SO.intSplitId = ES.intSplitId
LEFT JOIN (
	SELECT intQuoteTemplateId
		 , strOrganization
		 , strTemplateName
		 , ysnDisplayTitle
	FROM dbo.tblARQuoteTemplate WITH (NOLOCK)
) QT ON SO.intQuoteTemplateId = QT.intQuoteTemplateId
LEFT JOIN (
	SELECT dblCategoryTotal	 = SUM(SD.dblTotal)
		 , I.intCategoryId
		 , SD.intSalesOrderId 
	FROM dbo.tblSOSalesOrderDetail SD WITH (NOLOCK)
	LEFT JOIN tblICItem I ON SD.intItemId = I.intItemId
	LEFT JOIN tblICCategory ICC ON I.intCategoryId = ICC.intCategoryId
	GROUP BY I.intCategoryId
		   , SD.intSalesOrderId
) CATEGORYTOTAL ON ISNULL(SALESORDERDETAIL.intCategoryId, 0) = ISNULL(CATEGORYTOTAL.intCategoryId, 0) 
	           AND SALESORDERDETAIL.intSalesOrderId = CATEGORYTOTAL.intSalesOrderId
LEFT JOIN (
	SELECT dblProductTotal	= SUM(SD.dblTotal)
	     , PD.intProductTypeId
		 , SD.intSalesOrderId 
	FROM dbo.tblSOSalesOrderDetail SD WITH (NOLOCK)
	LEFT JOIN tblICItem I ON SD.intItemId = I.intItemId
	LEFT JOIN tblICCategory ICC ON I.intCategoryId = ICC.intCategoryId
	LEFT JOIN (tblARProductTypeDetail PDD INNER JOIN tblARProductType PD ON PDD.intProductTypeId = PD.intProductTypeId) ON PDD.intCategoryId = ICC.intCategoryId
	GROUP BY PD.intProductTypeId, SD.intSalesOrderId
) PRODUCTTYPETOTAL ON ISNULL(SALESORDERDETAIL.intProductTypeId, 0) = ISNULL(PRODUCTTYPETOTAL.intProductTypeId, 0) 
                  AND SALESORDERDETAIL.intSalesOrderId = PRODUCTTYPETOTAL.intSalesOrderId
LEFT JOIN (
	SELECT strCode
		 , strMessage
	FROM dbo.vyuARDocumentMaintenanceMessage WITH (NOLOCK)
) COMMENTS ON SO.strComments = COMMENTS.strCode
OUTER APPLY (
	SELECT COUNT(*) AS intSalesOrderDetailCount
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	WHERE SOD.intSalesOrderId = SO.intSalesOrderId
) SALESORDERITEMS
OUTER APPLY (
	SELECT COUNT(*) AS intEmailSetupCount
	FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
	WHERE intCustomerEntityId = SO.intEntityCustomerId 
	  AND ISNULL(strEmail, '') <> '' 
	  AND strEmailDistributionOption LIKE '%' + CASE WHEN SO.ysnQuote = 1 THEN 'Quote Order' ELSE 'Sales Order' END + '%'
) EMAILSETUP
OUTER APPLY (
	SELECT COUNT(*) AS intRecipeItemCount
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	WHERE SOD.intSalesOrderId = SALESORDERDETAIL.intSalesOrderId
	  AND intRecipeId IS NOT NULL
) RECIPEITEM
OUTER APPLY (
	SELECT TOP 1 strCompanyName 
			   , strAddress
			   , strCity
			   , strState
			   , strZip
			   , strCountry
			   , ysnIncludeEntityName
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY