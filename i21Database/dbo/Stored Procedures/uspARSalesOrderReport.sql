CREATE PROCEDURE [dbo].[uspARSalesOrderReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

IF(OBJECT_ID('tempdb..#XMLTABLE') IS NOT NULL)
BEGIN
    DROP TABLE #XMLTABLE
END
IF(OBJECT_ID('tempdb..#SELECTEDSO') IS NOT NULL)
BEGIN
    DROP TABLE #SELECTEDSO
END
IF(OBJECT_ID('tempdb..#DELIMITEDROWS') IS NOT NULL)
BEGIN
    DROP TABLE #DELIMITEDROWS
END
IF(OBJECT_ID('tempdb..#SALESORDERS') IS NOT NULL)
BEGIN
    DROP TABLE #SALESORDERS
END
IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END
IF(OBJECT_ID('tempdb..#LOCATIONS') IS NOT NULL)
BEGIN
    DROP TABLE #LOCATIONS
END

CREATE TABLE #SELECTEDSO (intSalesOrderId INT);

IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL

		SELECT * FROM tblARSalesOrderReportStagingTable
	END

DECLARE @strCompanyFullAddress	NVARCHAR(500) = NULL
	  , @strCompanyName			NVARCHAR(100) = NULL
	  , @strSalesOrderIds		NVARCHAR(MAX) = NULL
	  , @strRequestId			NVARCHAR(200) = NULL
	  , @blbLogo				VARBINARY(MAX) = NULL
	  , @dtmDateFrom			DATETIME = NULL
	  , @dtmDateTo				DATETIME = NULL
	  , @intSalesOrderIdFrom	INT = NULL
	  , @intSalesOrderIdTo		INT = NULL
	  , @xmlDocumentId			INT = NULL
	  , @strEmail				NVARCHAR(100) = NULL
	  , @strPhone				NVARCHAR(100) = NULL
	  , @intPerformanceLogId	INT = NULL
	  , @intEntityUserId		INT = NULL	  

--PREPARE XML 
EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

--PROCESS XML TABLE
SELECT *
INTO #XMLTABLE
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	  [fieldname]  NVARCHAR(50)
	, [condition]  NVARCHAR(20)
	, [from]	   NVARCHAR(MAX)
	, [to]		   NVARCHAR(MAX)
	, [join]	   NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup]   NVARCHAR(50)
	, [datatype]   NVARCHAR(50)
)

--GATHER PARAMS FROM XML TABLE
SELECT @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	 , @dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM #XMLTABLE 
WHERE [fieldname] = 'dtmDate'

SELECT @intSalesOrderIdFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE 0 END AS INT)
 	 , @intSalesOrderIdTo   = CASE WHEN UPPER([condition]) = 'BETWEEN' THEN CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE 0 END AS INT)
							     WHEN UPPER([condition]) = 'EQUAL TO' THEN CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE 0 END AS INT)
						    END
FROM #XMLTABLE 
WHERE [fieldname] = 'intSalesOrderId'

SELECT @strSalesOrderIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM #XMLTABLE
WHERE [fieldname] = 'strSalesOrderIds'

SELECT	@intEntityUserId = [from]
FROM #XMLTABLE
WHERE [fieldname] = 'intSrCurrentUserId'

SELECT @strRequestId = REPLACE(ISNULL([from], ''), '''''', '''')
FROM #XMLTABLE
WHERE [fieldname] = 'strRequestId'

EXEC dbo.uspARLogPerformanceRuntime 'Sales Order Report', 'uspARSalesOrderReport', @strRequestId, 1, @intEntityUserId, NULL, @intPerformanceLogId OUT

IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateTo = CAST('12/31/2999' AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST('01/01/1900' AS DATETIME)

IF ISNULL(@intSalesOrderIdTo, 0) = 0
	SET @intSalesOrderIdTo = (SELECT MAX(intInvoiceId) FROM dbo.tblARInvoice)

IF ISNULL(@intSalesOrderIdFrom, 0) = 0
	SET @intSalesOrderIdFrom = (SELECT MIN(intInvoiceId) FROM dbo.tblARInvoice)

--FILTER SELECTED SALES ORDER
IF ISNULL(@strSalesOrderIds, '') <> ''
	BEGIN		
		SELECT DISTINCT intSalesOrderId = intID
		INTO #DELIMITEDROWS
		FROM fnGetRowsFromDelimitedValues(@strSalesOrderIds)

		INSERT INTO #SELECTEDSO
		SELECT SO.intSalesOrderId
		FROM tblSOSalesOrder SO
		INNER JOIN #DELIMITEDROWS DR ON SO.intSalesOrderId = DR.intSalesOrderId
	END
ELSE
	BEGIN
		INSERT INTO #SELECTEDSO
		SELECT SO.intSalesOrderId
		FROM tblSOSalesOrder SO
		WHERE SO.intSalesOrderId BETWEEN @intSalesOrderIdFrom AND @intSalesOrderIdTo
		  AND SO.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
	END

--COMPANY INFO
SELECT TOP 1 @strCompanyFullAddress	= strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry
		   , @strCompanyName		= strCompanyName
		   , @strPhone				= strPhone
		   , @strEmail				= strEmail
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

--LOGO
SELECT TOP 1 @blbLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen = 'SystemManager.CompanyPreference' 
  AND A.strComment = 'Header'
ORDER BY U.intAttachmentId DESC

--LOCATIONS
SELECT intCompanyLocationId		= L.intCompanyLocationId
	 , strLocationName			= L.strLocationName
	 , strUseLocationAddress	= ISNULL(L.strUseLocationAddress, 'No')
	 , strFullAddress			= L.strAddress + CHAR(13) + char(10) + L.strCity + ', ' + L.strStateProvince + ', ' + L.strZipPostalCode + ', ' + L.strCountry 
INTO #LOCATIONS
FROM tblSMCompanyLocation L

--MAIN QUERY
SELECT intSalesOrderId			= SO.intSalesOrderId
	 , intCompanyLocationId		= SO.intCompanyLocationId
	 , intEntityCustomerId		= SO.intEntityCustomerId
	 , strCompanyName			= CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' ELSE @strCompanyName END
	 , strCompanyAddress		= CASE WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
									   WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
									   WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
								  END
	 , strCompanyInfo			= CASE WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
									   WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
									   WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
								  END  + CHAR(10) + ISNULL(@strEmail,'')   + CHAR(10) + ISNULL(@strPhone,'')
	 , strOrderType				= ISNULL(SO.strType, 'Standard')
	 , strLocationName			= L.strLocationName
	 , dtmDate					= SO.dtmDate
	 , strCurrency				= CUR.strCurrency
	 , strBOLNumber				= SO.strBOLNumber
	 , strOrderStatus			= SO.strOrderStatus
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strPONumber				= SO.strPONumber
	 , strShipVia				= SVE.strName
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
	 , strBillTo				= ISNULL(RTRIM(ENTITYLOCATION.strCheckPayeeName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(SO.strBillToAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(SO.strBillToCity), '') + ISNULL(RTRIM(', ' + SO.strBillToState), '') + ISNULL(RTRIM(', ' + SO.strBillToZipCode), '') + ISNULL(RTRIM(', ' + SO.strBillToCountry), '')
	 , strShipTo				= ISNULL(RTRIM(SO.strShipToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(SO.strShipToAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(SO.strShipToCity), '') + ISNULL(RTRIM(', ' + SO.strShipToState), '') + ISNULL(RTRIM(', ' + SO.strShipToZipCode), '') + ISNULL(RTRIM(', ' + SO.strShipToCountry), '')
	 , strSalespersonName		= SPE.strName
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
	 , dblCategoryTotal			= 0
	 , dblProductTotal			= 0
	 , strTaxCode				= SALESORDERDETAIL.strTaxCode
	 , dblTaxDetail				= SALESORDERDETAIL.dblAdjustedTax
	 , intDetailCount			= 0
	 , ysnHasRecipeItem			= 0
	 , strQuoteType				= SO.strQuoteType
	 , blbLogo					= @blbLogo
	 , intRecipeId				= SALESORDERDETAIL.intRecipeId	 
	 , intOneLinePrintId		= SALESORDERDETAIL.intOneLinePrintId
	 , dblTotalWeight			= ISNULL(SO.dblTotalWeight, 0)	 
	 , ysnListBundleSeparately	= ISNULL(SALESORDERDETAIL.ysnListBundleSeparately, CONVERT(BIT, 0))
	 , dblTotalDiscount			= ISNULL(dblTotalDiscount,0) * -1
	 , strCustomerName			= CAST('' AS NVARCHAR(100))
	 , strCustomerNumber		= CAST('' AS NVARCHAR(50))
	 , strCustomerComments		= CAST('' AS NVARCHAR(500))
	 , ysnHasEmailSetup			= CAST(0 AS BIT)
INTO #SALESORDERS
FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
INNER JOIN #SELECTEDSO SOS ON SO.intSalesOrderId = SOS.intSalesOrderId
LEFT JOIN (
	SELECT intSalesOrderId
		 , intCategoryId			= I.intCategoryId
		 , intSalesOrderDetailId	= SD.intSalesOrderDetailId
		 , intCommentTypeId			= SD.intCommentTypeId
		 , intRecipeId				= SD.intRecipeId
		 , intProductTypeId			= PDD.intProductTypeId
		 , intOneLinePrintId		= ISNULL(MFR.intOneLinePrintId, 1)
		 , intTaxCodeId				= SDT.intTaxCodeId
		 , strProductTypeName		= PD.strProductTypeName
		 , strProductTypeDescription = PD.strProductTypeDescription
		 , strItemDescription		= SD.strItemDescription
		 , strItemType				= I.strType
		 , strCategoryCode			= ICC.strCategoryCode
		 , strTaxCode				= SMT.strTaxCode
		 , strUnitMeasure			= UM.strUnitMeasure
		 , strItem					= CASE WHEN ISNULL(I.strItemNo, '') = '' THEN SD.strItemDescription ELSE LTRIM(RTRIM(I.strItemNo)) + ' - ' + ISNULL(SD.strItemDescription, '') END
		 , strItemNo				= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN I.strItemNo ELSE NULL END
		 , dblTotalTax				= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblTotalTax, 0) ELSE NULL END
		 , dblQtyShipped			= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblQtyShipped, 0) ELSE NULL END
		 , dblQtyOrdered			= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblQtyOrdered, 0) ELSE NULL END
		 , dblDiscount				= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblDiscount, 0) / 100 ELSE NULL END
		 , dblPrice					= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblPrice, 0) ELSE NULL END
		 , dblItemPrice				= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN ISNULL(SD.dblTotal, 0) ELSE NULL END
		 , dblAdjustedTax			= SDT.dblAdjustedTax
		 , dblContractBalance		= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN CD.dblBalance ELSE NULL END
		 , strContractNumber		= CASE WHEN ISNULL(SD.intCommentTypeId, 0) = 0 THEN CH.strContractNumber ELSE NULL END
		 , strCategoryDescription   = CASE WHEN I.intCategoryId IS NULL THEN 'No Item Category' ELSE ICC.strCategoryCode + ' - ' + ICC.strDescription END
		 , ysnListBundleSeparately	= I.ysnListBundleSeparately
	FROM dbo.tblSOSalesOrderDetail SD WITH (NOLOCK)
	LEFT JOIN tblICItem I WITH (NOLOCK) ON SD.intItemId = I.intItemId
	LEFT JOIN tblICCategory ICC  WITH (NOLOCK) ON I.intCategoryId = ICC.intCategoryId
	LEFT JOIN tblARProductTypeDetail PDD WITH (NOLOCK) ON ICC.intCategoryId = PDD.intCategoryId
	LEFT JOIN tblARProductType PD WITH (NOLOCK) ON PDD.intProductTypeId = PD.intProductTypeId
	LEFT JOIN (
		SELECT intSalesOrderDetailId
			 , intTaxCodeId
			 , dblAdjustedTax
		FROM dbo.tblSOSalesOrderDetailTax WITH (NOLOCK)
		WHERE dblAdjustedTax <> 0
	) SDT ON SD.intSalesOrderDetailId = SDT.intSalesOrderDetailId
	LEFT JOIN tblSMTaxCode SMT WITH (NOLOCK) ON SDT.intTaxCodeId = SMT.intTaxCodeId
	LEFT JOIN tblICItemUOM IUOM ON SD.intItemUOMId = IUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUOM.intUnitMeasureId	
	LEFT JOIN tblCTContractHeader CH WITH (NOLOCK) ON SD.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractDetail CD WITH (NOLOCK) ON SD.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblMFRecipe MFR WITH (NOLOCK) ON SD.intRecipeId = MFR.intRecipeId
) SALESORDERDETAIL ON SO.intSalesOrderId = SALESORDERDETAIL.intSalesOrderId
LEFT JOIN #LOCATIONS L ON SO.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN tblARSalesperson SALESPERSON WITH (NOLOCK) ON SO.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT JOIN tblEMEntity SPE WITH (NOLOCK) ON SALESPERSON.intEntityId = SPE.intEntityId
LEFT JOIN tblSMShipVia SHIPVIA ON SO.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN tblEMEntity SVE WITH (NOLOCK) ON SHIPVIA.intEntityId = SVE.intEntityId
LEFT JOIN tblEMEntityLocation ENTITYLOCATION ON ENTITYLOCATION.intEntityLocationId = SO.intBillToLocationId
LEFT JOIN tblSMCurrency CUR WITH (NOLOCK) ON SO.intCurrencyId = CUR.intCurrencyID
LEFT JOIN tblSMTerm T WITH (NOLOCK) ON SO.intTermId = T.intTermID
LEFT JOIN tblEMEntity EOB WITH (NOLOCK) ON SO.intOrderedById = EOB.intEntityId
LEFT JOIN tblSMFreightTerms FT WITH (NOLOCK) ON SO.intFreightTermId = FT.intFreightTermId
LEFT JOIN tblEMEntitySplit ES WITH (NOLOCK) ON SO.intSplitId = ES.intSplitId
LEFT JOIN tblARQuoteTemplate QT WITH (NOLOCK) ON SO.intQuoteTemplateId = QT.intQuoteTemplateId

--CUSTOMERS
SELECT intEntityCustomerId	= C.intEntityId
	 , strCustomerNumber	= C.strCustomerNumber
	 , strCustomerName		= E.strName
	 , ysnIncludeEntityName	= C.ysnIncludeEntityName
	 , strCustomerComments	= EM.strMessage
	 , ysnHasEmailSetup		= CASE WHEN (ISNULL(EMAILSETUP.intEmailSetupCount, 0)) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END 	 
INTO #CUSTOMERS
FROM tblARCustomer C
INNER JOIN (
	SELECT DISTINCT intEntityCustomerId
	FROM #SALESORDERS
) SO ON C.intEntityId = SO.intEntityCustomerId
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strMessage
	FROM tblEMEntityMessage
	WHERE strMessageType = 'Pick Ticket'
) EM ON C.intEntityId = EM.intEntityId
OUTER APPLY (
	SELECT intEmailSetupCount	= COUNT(*)
	FROM dbo.tblARCustomer CC WITH (NOLOCK)
	INNER JOIN tblEMEntity AS B ON CC.intEntityId = B.intEntityId 
	INNER JOIN tblEMEntityToContact AS C ON CC.intEntityId = C.intEntityId 
	INNER JOIN dbo.tblEMEntity AS D ON C.intEntityContactId = D.intEntityId
	WHERE D.strEmail <> '' 
	  AND D.strEmail IS NOT NULL
	  AND (D.strEmailDistributionOption LIKE '%Quote Order%' OR D.strEmailDistributionOption LIKE '%Sales Order%')
	  AND CC.intEntityId = C.intEntityId
) EMAILSETUP

UPDATE SO
SET strCustomerName			= C.strCustomerName
  , strCustomerNumber		= C.strCustomerNumber
  , strCustomerComments		= C.strCustomerComments  
  , ysnHasEmailSetup		= C.ysnHasEmailSetup
  , strBillTo				= CASE WHEN C.ysnIncludeEntityName = 1 THEN ISNULL(RTRIM(C.strCustomerName) + CHAR(13) + char(10), '') + SO.strBillTo ELSE SO.strBillTo END
  , strShipTo				= CASE WHEN C.ysnIncludeEntityName = 1 THEN ISNULL(RTRIM(C.strCustomerName) + CHAR(13) + char(10), '') + SO.strShipTo ELSE SO.strShipTo END
FROM #SALESORDERS SO
INNER JOIN #CUSTOMERS C ON SO.intEntityCustomerId = C.intEntityCustomerId

--CATEGORY ITEM TOTAL
UPDATE SO
SET dblCategoryTotal	= CATEGORYTOTAL.dblCategoryTotal
FROM tblARSalesOrderReportStagingTable SO
INNER JOIN (
	SELECT dblCategoryTotal	= SUM(SD.dblTotal)
		 , intCategoryId	= I.intCategoryId
		 , intSalesOrderId	= SD.intSalesOrderId 
	FROM dbo.tblSOSalesOrderDetail SD WITH (NOLOCK)
	INNER JOIN tblICItem I ON SD.intItemId = I.intItemId
	INNER JOIN tblICCategory ICC ON I.intCategoryId = ICC.intCategoryId
	GROUP BY I.intCategoryId, SD.intSalesOrderId
) CATEGORYTOTAL ON SO.intCategoryId = CATEGORYTOTAL.intCategoryId
	           AND SO.intSalesOrderId = CATEGORYTOTAL.intSalesOrderId
WHERE SO.strTransactionType = 'Quote' 

--PRODUCT ITEM TOTAL
UPDATE SO
SET dblProductTotal	= PRODUCTTYPETOTAL.dblProductTotal
FROM tblARSalesOrderReportStagingTable SO
INNER JOIN (
	SELECT dblProductTotal	= SUM(SD.dblTotal)
	     , intProductTypeId	= PD.intProductTypeId
		 , intSalesOrderId	= SD.intSalesOrderId 
	FROM dbo.tblSOSalesOrderDetail SD WITH (NOLOCK)
	INNER JOIN tblICItem I ON SD.intItemId = I.intItemId
	INNER JOIN tblICCategory ICC ON I.intCategoryId = ICC.intCategoryId
	INNER JOIN tblARProductTypeDetail PDD ON PDD.intCategoryId = ICC.intCategoryId
	INNER JOIN tblARProductType PD ON PDD.intProductTypeId = PD.intProductTypeId
	GROUP BY PD.intProductTypeId, SD.intSalesOrderId
) PRODUCTTYPETOTAL ON SO.intProductTypeId = PRODUCTTYPETOTAL.intProductTypeId
                  AND SO.intSalesOrderId = PRODUCTTYPETOTAL.intSalesOrderId
WHERE SO.strTransactionType = 'Quote' 

--DETAIL COUNT
UPDATE SO
SET intDetailCount	= SALESORDERITEMS.intSalesOrderDetailCount
FROM #SALESORDERS SO
INNER JOIN (
	SELECT intSalesOrderId			= SOD.intSalesOrderId
		 , intSalesOrderDetailCount	= COUNT(*)
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	GROUP BY SOD.intSalesOrderId 
) SALESORDERITEMS ON SALESORDERITEMS.intSalesOrderId = SO.intSalesOrderId

--RECIPE ITEM COUNT
UPDATE SO
SET ysnHasRecipeItem	= CASE WHEN intRecipeItemCount > 0 THEN 1 ELSE 0 END
FROM #SALESORDERS SO
INNER JOIN (
	SELECT intSalesOrderId		= SOD.intSalesOrderId
		 , intRecipeItemCount	= COUNT(*)
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	WHERE SOD.intRecipeId IS NOT NULL
	GROUP BY SOD.intSalesOrderId
) RECIPEITEM ON RECIPEITEM.intSalesOrderId = SO.intSalesOrderId

TRUNCATE TABLE tblARSalesOrderReportStagingTable
INSERT INTO tblARSalesOrderReportStagingTable WITH (TABLOCK) (
	  intSalesOrderId
	 , intCompanyLocationId
	 , intEntityCustomerId
	 , strCompanyName
	 , strCompanyAddress
	 , strCompanyInfo
	 , strOrderType
	 , strLocationName
	 , dtmDate
	 , strCurrency
	 , strBOLNumber
	 , strOrderStatus
	 , strSalesOrderNumber
	 , strPONumber
	 , strShipVia
	 , strTerm
	 , dtmDueDate
	 , strFreightTerm
	 , strItemNo
	 , strType
	 , intCategoryId
	 , strCategoryCode
	 , strCategoryDescription
	 , intSalesOrderDetailId
	 , dblContractBalance
	 , strContractNumber
	 , strItem
	 , strItemDescription
	 , strUnitMeasure
	 , intTaxCodeId
	 , strTransactionType
	 , intQuoteTemplateId
	 , strTemplateName
	 , strOrganization
	 , ysnDisplayTitle
	 , intProductTypeId
	 , strProductTypeDescription
	 , strProductTypeName
	 , dtmExpirationDate
	 , strBillTo
	 , strShipTo
	 , strSalespersonName
	 , strOrderedByName
	 , strSplitName
	 , strSOHeaderComment
	 , strSOFooterComment
	 , dblSalesOrderSubtotal
	 , dblShipping
	 , dblTax
	 , dblSalesOrderTotal
	 , dblQtyShipped
	 , dblQtyOrdered
	 , dblDiscount
	 , dblTotalTax
	 , dblPrice
	 , dblItemPrice
	 , dblCategoryTotal
	 , dblProductTotal
	 , strTaxCode
	 , dblTaxDetail
	 , intDetailCount
	 , ysnHasRecipeItem
	 , strQuoteType
	 , blbLogo
	 , intRecipeId
	 , intOneLinePrintId
	 , dblTotalWeight
	 , ysnListBundleSeparately
	 , dblTotalDiscount
	 , strCustomerName
	 , strCustomerNumber
	 , strCustomerComments
	 , ysnHasEmailSetup
)
SELECT intSalesOrderId
	 , intCompanyLocationId
	 , intEntityCustomerId
	 , strCompanyName
	 , strCompanyAddress
	 , strCompanyInfo
	 , strOrderType
	 , strLocationName
	 , dtmDate
	 , strCurrency
	 , strBOLNumber
	 , strOrderStatus
	 , strSalesOrderNumber
	 , strPONumber
	 , strShipVia
	 , strTerm
	 , dtmDueDate
	 , strFreightTerm
	 , strItemNo
	 , strType
	 , intCategoryId
	 , strCategoryCode
	 , strCategoryDescription
	 , intSalesOrderDetailId
	 , dblContractBalance
	 , strContractNumber
	 , strItem
	 , strItemDescription
	 , strUnitMeasure
	 , intTaxCodeId
	 , strTransactionType
	 , intQuoteTemplateId
	 , strTemplateName
	 , strOrganization
	 , ysnDisplayTitle
	 , intProductTypeId
	 , strProductTypeDescription
	 , strProductTypeName
	 , dtmExpirationDate
	 , strBillTo
	 , strShipTo
	 , strSalespersonName
	 , strOrderedByName
	 , strSplitName
	 , strSOHeaderComment
	 , strSOFooterComment
	 , dblSalesOrderSubtotal
	 , dblShipping
	 , dblTax
	 , dblSalesOrderTotal
	 , dblQtyShipped
	 , dblQtyOrdered
	 , dblDiscount
	 , dblTotalTax
	 , dblPrice
	 , dblItemPrice
	 , dblCategoryTotal
	 , dblProductTotal
	 , strTaxCode
	 , dblTaxDetail
	 , intDetailCount
	 , ysnHasRecipeItem
	 , strQuoteType
	 , blbLogo
	 , intRecipeId
	 , intOneLinePrintId
	 , dblTotalWeight
	 , ysnListBundleSeparately
	 , dblTotalDiscount
	 , strCustomerName
	 , strCustomerNumber
	 , strCustomerComments
	 , ysnHasEmailSetup 
FROM #SALESORDERS

SELECT * FROM tblARSalesOrderReportStagingTable

EXEC dbo.uspARLogPerformanceRuntime 'Sales Order Report', 'uspARSalesOrderReport', @strRequestId, 0, @intEntityUserId, @intPerformanceLogId, NULL