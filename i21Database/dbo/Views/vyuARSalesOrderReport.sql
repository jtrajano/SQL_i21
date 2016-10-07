﻿CREATE VIEW [dbo].[vyuARSalesOrderReport]
AS
SELECT SO.intSalesOrderId	 
	 , strCompanyName = CASE WHEN L.strUseLocationAddress = 'Letterhead'
								THEN ''
							 ELSE
								(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
						END
	 , strCompanyAddress = CASE WHEN L.strUseLocationAddress IS NULL OR L.strUseLocationAddress = 'No' OR L.strUseLocationAddress = '' OR L.strUseLocationAddress = 'Always'
									THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, ysnIncludeEntityName) FROM tblSMCompanySetup)
								WHEN L.strUseLocationAddress = 'Yes'
									THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, L.strAddress, L.strCity, L.strStateProvince, L.strZipPostalCode, L.strCountry, NULL, ysnIncludeEntityName)
								WHEN L.strUseLocationAddress = 'Letterhead'
									THEN ''
						   END 
	 , strOrderType				= ISNULL(SO.strType, 'Standard')
     , strCustomerName			= E.strName
	 , strLocationName			= L.strLocationName
	 , dtmDate					= SO.dtmDate
	 , strCurrency				= CUR.strCurrency
	 , strBOLNumber				= SO.strBOLNumber
	 , strOrderStatus			= SO.strOrderStatus
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strPONumber				= SO.strPONumber
	 , strShipVia				= SV.strShipVia
	 , strTerm					= T.strTerm
	 , dtmDueDate				= SO.dtmDueDate
	 , strFreightTerm			= FT.strFreightTerm
	 , strItemNo				= I.strItemNo
	 , strItem					= CASE WHEN ISNULL(I.strItemNo, '') = '' THEN SD.strItemDescription ELSE LTRIM(RTRIM(I.strItemNo)) + ' - ' + ISNULL(SD.strItemDescription, '') END
	 , strType					= I.strType
	 , intCategoryId			= CASE WHEN QT.strOrganization IN ('Product Type', 'Item Category') THEN I.intCategoryId ELSE NULL END
	 , strCategoryCode			= ICC.strCategoryCode
	 , strCategoryDescription   = CASE WHEN I.intCategoryId IS NULL THEN 'No Item Category' ELSE ICC.strCategoryCode + ' - ' + ICC.strDescription END
	 , intSalesOrderDetailId	= SD.intSalesOrderDetailId
	 , dblContractBalance		= CASE WHEN SD.dblContractBalance = 0 THEN CD.dblBalance ELSE SD.dblContractBalance END
	 , strContractNumber		= CH.strContractNumber
	 , strItemDescription		= SD.strItemDescription
	 , strUnitMeasure			= UOM.strUnitMeasure
	 , intTaxCodeId				= SDT.intTaxCodeId
	 , strTransactionType		= SO.strTransactionType
	 , intQuoteTemplateId		= CASE WHEN SO.strTransactionType = 'Quote' THEN QT.intQuoteTemplateId ELSE NULL END
	 , strTemplateName			= CASE WHEN SO.strTransactionType = 'Quote' THEN QT.strTemplateName ELSE NULL END	 
	 , strOrganization			= CASE WHEN SO.strTransactionType = 'Quote' THEN QT.strOrganization ELSE NULL END
	 , ysnDisplayTitle			= CASE WHEN SO.strTransactionType = 'Quote' THEN QT.ysnDisplayTitle ELSE NULL END
	 , intProductTypeId			= CASE WHEN SO.strTransactionType = 'Quote' AND QT.strOrganization = 'Product Type' THEN PD.intProductTypeId ELSE NULL END
	 , strProductTypeDescription = CASE WHEN SO.strTransactionType = 'Quote' THEN CASE WHEN PD.intProductTypeId IS NULL THEN 'No Product Type' ELSE PD.strProductTypeName + ' - ' + PD.strProductTypeDescription END ELSE NULL END
	 , strProductTypeName		= CASE WHEN SO.strTransactionType = 'Quote' THEN PD.strProductTypeName ELSE NULL END
	 , dtmExpirationDate		= CASE WHEN SO.strTransactionType = 'Quote' THEN SO.dtmExpirationDate ELSE NULL END
	 , strBillTo				= [dbo].fnARFormatCustomerAddress(NULL, NULL, SO.strBillToLocationName, SO.strBillToAddress, SO.strBillToCity, SO.strBillToState, SO.strBillToZipCode, SO.strBillToCountry, E.strName, ysnIncludeEntityName)
	 , strShipTo				= [dbo].fnARFormatCustomerAddress(NULL, NULL, SO.strShipToLocationName, SO.strShipToAddress, SO.strShipToCity, SO.strShipToState, SO.strShipToZipCode, SO.strShipToCountry, E.strName, ysnIncludeEntityName)
	 , strSalespersonName		= ESP.strName
	 , strOrderedByName			= EOB.strName
	 , strSplitName				= CASE WHEN ISNULL(ES.strDescription, '') <> '' THEN ES.strDescription ELSE ES.strSplitNumber END
	 , strSOHeaderComment		= SO.strComments
	 , strSOFooterComment		= SO.strFooterComments
	 , dblSalesOrderSubtotal	= ISNULL(SO.dblSalesOrderSubtotal, 0)
	 , dblShipping				= ISNULL(SO.dblShipping, 0)
	 , dblTax					= ISNULL(SD.dblTotalTax, 0)
	 , dblSalesOrderTotal		= ISNULL(SO.dblSalesOrderTotal, 0)
	 , dblQtyShipped			= ISNULL(SD.dblQtyShipped, 0)
	 , dblQtyOrdered			= ISNULL(SD.dblQtyOrdered, 0)
	 , dblDiscount				= ISNULL(SD.dblDiscount, 0) / 100
	 , dblTotalTax				= ISNULL(SO.dblTax, 0)
	 , dblPrice					= ISNULL(SD.dblPrice, 0)
	 , dblItemPrice				= ISNULL(SD.dblTotal, 0)
	 , dblCategoryTotal			= CATEGORYTOTAL.dblCategoryTotal
	 , dblProductTotal			= PRODUCTTYPETOTAL.dblProductTotal
	 , strTaxCode				= SMT.strTaxCode
	 , dblTaxDetail				= SDT.dblAdjustedTax
	 , intDetailCount			= (SELECT COUNT(*) FROM tblSOSalesOrderDetail WHERE intSalesOrderId = SO.intSalesOrderId)
	 , ysnHasEmailSetup			= CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = SO.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + CASE WHEN SO.ysnQuote = 1 THEN 'Quote Order' ELSE 'Sales Order' END + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , strQuoteType
	 , blbLogo					= dbo.fnSMGetCompanyLogo('Header')	 
FROM tblSOSalesOrder SO
LEFT JOIN (tblSOSalesOrderDetail SD 
	LEFT JOIN tblICItem I ON SD.intItemId = I.intItemId
	LEFT JOIN tblICCategory ICC ON I.intCategoryId = ICC.intCategoryId
	LEFT JOIN (tblARProductTypeDetail PDD INNER JOIN tblARProductType PD ON PDD.intProductTypeId = PD.intProductTypeId) ON PDD.intCategoryId = ICC.intCategoryId
	LEFT JOIN tblSOSalesOrderDetailTax SDT ON SD.intSalesOrderDetailId = SDT.intSalesOrderDetailId
	LEFT JOIN tblSMTaxCode SMT ON SDT.intTaxCodeId = SMT.intTaxCodeId
	LEFT JOIN vyuARItemUOM UOM ON SD.intItemUOMId = UOM.intItemUOMId AND SD.intItemId = UOM.intItemId
	LEFT JOIN tblCTContractHeader CH ON SD.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractDetail CD ON SD.intContractDetailId = CD.intContractDetailId) ON SO.intSalesOrderId = SD.intSalesOrderId
LEFT JOIN (tblARCustomer C 
	INNER JOIN tblEMEntity E ON C.intEntityCustomerId = E.intEntityId) ON C.intEntityCustomerId = SO.intEntityCustomerId
LEFT JOIN tblSMCompanyLocation L ON SO.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN tblSMCurrency CUR ON SO.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (tblARSalesperson SP 
	INNER JOIN tblEMEntity ESP ON SP.intEntitySalespersonId = ESP.intEntityId) ON SO.intEntitySalespersonId = SP.intEntitySalespersonId
LEFT JOIN tblSMShipVia SV ON SO.intShipViaId = SV.intEntityShipViaId
LEFT JOIN tblSMTerm T ON SO.intTermId = T.intTermID
LEFT JOIN tblEMEntity EOB ON SO.intOrderedById = EOB.intEntityId
LEFT JOIN tblSMFreightTerms FT ON SO.intFreightTermId = FT.intFreightTermId
LEFT JOIN tblEMEntitySplit ES ON SO.intSplitId = ES.intSplitId
LEFT JOIN tblARQuoteTemplate QT ON SO.intQuoteTemplateId = QT.intQuoteTemplateId
LEFT JOIN (SELECT SUM(SD.dblTotal) AS dblCategoryTotal, I.intCategoryId, SD.intSalesOrderId FROM tblSOSalesOrderDetail SD
	LEFT JOIN tblICItem I ON SD.intItemId = I.intItemId
	LEFT JOIN tblICCategory ICC ON I.intCategoryId = ICC.intCategoryId
GROUP BY I.intCategoryId, SD.intSalesOrderId) AS CATEGORYTOTAL
ON ISNULL(I.intCategoryId, 0) = ISNULL(CATEGORYTOTAL.intCategoryId, 0) AND SD.intSalesOrderId = CATEGORYTOTAL.intSalesOrderId
LEFT JOIN (SELECT SUM(SD.dblTotal) AS dblProductTotal, PD.intProductTypeId, SD.intSalesOrderId FROM tblSOSalesOrderDetail SD
	LEFT JOIN tblICItem I ON SD.intItemId = I.intItemId
	LEFT JOIN tblICCategory ICC ON I.intCategoryId = ICC.intCategoryId
	LEFT JOIN (tblARProductTypeDetail PDD INNER JOIN tblARProductType PD ON PDD.intProductTypeId = PD.intProductTypeId) ON PDD.intCategoryId = ICC.intCategoryId
GROUP BY PD.intProductTypeId, SD.intSalesOrderId) AS PRODUCTTYPETOTAL
ON ISNULL(PD.intProductTypeId, 0) = ISNULL(PRODUCTTYPETOTAL.intProductTypeId, 0) AND SD.intSalesOrderId = PRODUCTTYPETOTAL.intSalesOrderId