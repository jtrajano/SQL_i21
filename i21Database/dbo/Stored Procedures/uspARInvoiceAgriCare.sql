CREATE PROCEDURE [dbo].[uspARInvoiceAgriCare]
	@xmlParam NVARCHAR(MAX) = NULL	
AS 

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE  @dtmDateTo				DATETIME
		,@dtmDateFrom			DATETIME
		,@intInvoiceIdTo		INT
		,@intInvoiceIdFrom		INT
		,@xmlDocumentId			INT
		,@strReportLogId		NVARCHAR(MAX)
		,@blbLogo				VARBINARY (MAX)	= NULL
		,@strCompanyName		NVARCHAR(200)	= NULL
		,@strCompanyFullAddress	NVARCHAR(500)	= NULL
		,@intPerformanceLogId	INT = NULL
		,@intEntityUserId		INT
		,@strInvoiceIds			AS NVARCHAR(MAX)
	    , @intItemForFreightId			INT = NULL

IF(OBJECT_ID('tempdb..#LOCATIONS') IS NOT NULL) DROP TABLE #LOCATIONS

-- Sanitize the @xmlParam
IF LTRIM(RTRIM(@xmlParam)) = ''
BEGIN 
	SET @xmlParam = NULL
END

SELECT TOP 1 @intItemForFreightId = intItemForFreightId 
FROM tblTRCompanyPreference
ORDER BY intCompanyPreferenceId DESC
			
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50)
	,[condition]	NVARCHAR(20)
	,[from]			NVARCHAR(MAX)
	,[to]			NVARCHAR(MAX)
	,[join]			NVARCHAR(10)
	,[begingroup]	NVARCHAR(50)
	,[endgroup]		NVARCHAR(50)
	,[datatype]		NVARCHAR(50)
)

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
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

-- Insert the XML Dummies to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)
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

SELECT	@intEntityUserId = [from]
FROM	@temp_xml_table
WHERE	[fieldname] = 'intSrCurrentUserId'

SELECT @strReportLogId = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strReportLogId'

SELECT  @dtmDateFrom = CASE WHEN ISNULL([from], '') <> '' THEN CONVERT(DATETIME, [from], 103) ELSE CAST(-53690 AS DATETIME) END
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN CONVERT(DATETIME, [to], 103) ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmDate'

SELECT  @intInvoiceIdFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE 0 END AS INT)
 	   ,@intInvoiceIdTo   = CASE WHEN [condition] = 'BETWEEN' THEN CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE 0 END AS INT)
							     WHEN [condition] = 'EQUAL TO' THEN CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE 0 END AS INT)
						    END
FROM	@temp_xml_table 
WHERE	[fieldname] = 'intInvoiceId'

SELECT @strInvoiceIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strInvoiceIds'

IF EXISTS(SELECT * FROM tblSRReportLog WHERE strReportLogId = @strReportLogId) RETURN

EXEC dbo.uspARLogPerformanceRuntime 'Invoice Report', 'uspARInvoiceAgriCare', @strReportLogId, 1, @intEntityUserId, NULL, @intPerformanceLogId OUT

SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header')

SELECT TOP 1 @strCompanyFullAddress	= strAddress + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(', ' + NULLIF(strZip, ''), '') + ISNULL(', ' + NULLIF(strCountry, ''), '')
		   , @strCompanyName		= strCompanyName
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

--LOCATIONS
SELECT intCompanyLocationId		= L.intCompanyLocationId
	 , strLocationName			= L.strLocationName
	 , strUseLocationAddress	= ISNULL(L.strUseLocationAddress, 'No')
	 , strInvoiceComments		= L.strInvoiceComments
	 , strFullAddress			= L.strAddress + CHAR(13) + char(10) + ISNULL(ISNULL(L.strCity, ''), '') + ISNULL(', ' + ISNULL(L.strStateProvince, ''), '') + ISNULL(', ' + ISNULL(L.strZipPostalCode, ''), '') + ISNULL(', ' + ISNULL(L.strCountry, ''), '')
INTO #LOCATIONS
FROM tblSMCompanyLocation L


SELECT
	 intInvoiceId			= ARI.intInvoiceId
	,strType				= ARI.strType
	,strTransactionType		= ARI.strTransactionType
	,intEntityCustomerId	= ARI.intEntityCustomerId
	,intCompanyLocationId	= ARI.intCompanyLocationId
	,intInvoiceDetailId		= ISNULL(ARGID.intInvoiceDetailId, 0)
	,strCompanyName			= CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' ELSE @strCompanyName END
	,strCompanyAddress		= CASE WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
									   WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
									   WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
							   END
	,strInvoiceNumber		= ARI.strInvoiceNumber
	,strCustomerNumber	     =ARCS.strCustomerNumber
	,strCustomerName		= ARCS.strName
	,strLocationName		= SMCL.strLocationName + ',' +  + [dbo].[fnConvertDateToReportDateFormat](ARI.dtmDate, 0)
	,strItemNo				= ARGID.strItemNo
	,strItemDescription		= CASE WHEN ARI.strType = 'Service Charge' THEN ARGID.strSCInvoiceNumber ELSE ARGID.strItemDescription END
	,strQtyShipped			= CONVERT(VARCHAR,CAST(ARGID.dblQtyShipped AS MONEY),1) + ' ' + ARGID.strUnitMeasure
	,strFreightTerm         = FREIGHT.strFreightTerm
	,strSalespersonName     = ISNULL(SP.strName, SOADD.strName)
	,strPONumber			= ARI.strPONumber
	,strComments			= dbo.fnEliminateHTMLTags(ISNULL(HEADER.strMessage, ARI.strComments), 0) 
	,strFooterComments		= dbo.fnEliminateHTMLTags(ISNULL(FOOTER.strMessage, ARI.strFooterComments), 0)
	,strTerm				= TERM.strTerm
	,strBillTo				= ISNULL(RTRIM(ARI.strBillToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(ARI.strBillToAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(ARI.strBillToCity), '') + ISNULL(RTRIM(', ' + ARI.strBillToState), '') + ISNULL(RTRIM(', ' + ARI.strBillToZipCode), '') + ISNULL(RTRIM(', ' + ARI.strBillToCountry), '')
	,strShipTo				= ISNULL(RTRIM(ARI.strShipToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(ARI.strShipToAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(ARI.strShipToCity), '') + ISNULL(RTRIM(', ' + ARI.strShipToState), '') + ISNULL(RTRIM(', ' + ARI.strShipToZipCode), '') + ISNULL(RTRIM(', ' + ARI.strShipToCountry), '')	 
	,strSalesOrderNumber	= ISNULL(ISNULL(SOI.strSalesOrderNumber ,SO.strSalesOrderNumber), SOADD.strSalesOrderNumber)
	,dtmOrderDate			= ISNULL(ISNULL(SOI.dtmDate ,SO.dtmDate), SOADD.dtmDate)
	,dtmDate				= ARI.dtmDate
	,dtmShipDate			= ARI.dtmShipDate
	,dtmDueDate				= ARI.dtmDueDate
	,dblInvoiceTotal		= ISNULL(ARI.dblInvoiceTotal, 0) - ISNULL(ARI.dblProvisionalAmount, 0) -  ISNULL(TOTALTAX.dblNonSSTTax, 0)  
	,dblInvoiceSubtotal		= (ISNULL(ARI.dblInvoiceSubtotal, 0) + CASE WHEN ARI.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePriceTotal, 0) ELSE 0 END)
	,dblTax					= CASE WHEN ISNULL(ARGID.intCommentTypeId, 0) = 0 THEN (ISNULL(ARGID.dblTotalTax, 0) - CASE WHEN ARI.strType = 'Transport Delivery' THEN ISNULL(TOTALTAX.dblIncludePrice, 0) * ARGID.dblQtyShipped ELSE 0 END) ELSE NULL END
	,dblQtyShipped			= ARGID.dblQtyShipped
	,strUnitMeasure			= ARGID.strUnitMeasure
	,strLotNumber			= ARGIDL.strLotNumber
	,dblQuantityShipped		= ARGIDL.dblQuantityShipped
	,strLotstrUnitMeasure	= ARGIDL.strItemUOM
	,dblPrice				= ARGID.dblPrice
	,dblTotal				= ARGID.dblTotal
	,intInventoryShipmentChargeId = ISNULL(ARGID.intInventoryShipmentChargeId,0)
	,intInvoiceDetailLotId	= ARGIDL.intInvoiceDetailLotId
	,blbLogo                = ISNULL(SMLP.imgLogo, @blbLogo)
	,strLogoType			= CASE WHEN SMLP.imgLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
	,strDisplayInvoiceType	= CASE WHEN ARI.strType = 'Service Charge' THEN 'Service Charge Invoice:' ELSE 'Invoice:' END
FROM dbo.tblARInvoice ARI WITH (NOLOCK)
INNER JOIN vyuARCustomerSearch ARCS WITH (NOLOCK) ON ARI.intEntityCustomerId = ARCS.intEntityId 
INNER JOIN tblSMCompanyLocation SMCL WITH (NOLOCK) ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId
INNER JOIN #LOCATIONS L ON ARI.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN tblEMEntity SP ON ARI.intEntitySalespersonId = SP.intEntityId
LEFT JOIN vyuARGetInvoiceDetail ARGID WITH (NOLOCK) ON ARI.intInvoiceId = ARGID.intInvoiceId
LEFT JOIN vyuARGetInvoiceDetailLot ARGIDL ON ARGID.intInvoiceDetailId=ARGIDL.intInvoiceDetailId
LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = ARI.intSalesOrderId
LEFT JOIN tblSMFreightTerms FREIGHT ON ARI.intFreightTermId = FREIGHT.intFreightTermId
INNER JOIN tblSMTerm TERM ON ARI.intTermId = TERM.intTermID
LEFT JOIN tblEMEntityLocation ENTITYLOCATION ON ENTITYLOCATION.intEntityLocationId = ARI.intBillToLocationId
LEFT JOIN tblSMLogoPreference SMLP ON SMLP.intCompanyLocationId = ARI.intCompanyLocationId AND (ysnARInvoice = 1 OR SMLP.ysnDefault = 1)
OUTER APPLY (
	select top 1 dtmDate, ARID.intInvoiceId, SO.strSalesOrderNumber from tblARInvoiceDetail ARID
	INNER JOIN tblICInventoryShipmentItem ISI on ISI.intInventoryShipmentItemId =ARID.intInventoryShipmentItemId
	INNER JOIN tblSOSalesOrder SO on SO.intSalesOrderId=ISI.intOrderId
	WHERE ARID.intInvoiceId = ARI.intInvoiceId
)SOI 
OUTER APPLY(
SELECT TOP 1 a.strSalesOrderNumber,a.dtmDate,b.strName FROM tblSOSalesOrder a
LEFT JOIN tblEMEntity b ON a.intEntitySalespersonId=b.intEntityId
WHERE strSalesOrderNumber = ARGID.strSalesOrderNumber
)SOADD
LEFT JOIN (
	SELECT intInvoiceId			= ID.intInvoiceId
		 , dblSSTTax 			= SUM(CASE WHEN UPPER(strTaxClass) = 'STATE SALES TAX (SST)' OR ID.dblComputedGrossPrice = 0 THEN dblAdjustedTax ELSE 0 END)
		 , dblNonSSTTax 		= SUM(CASE WHEN UPPER(strTaxClass) <> 'STATE SALES TAX (SST)' AND ID.dblComputedGrossPrice <> 0 THEN dblAdjustedTax ELSE 0 END)
		 , dblIncludePrice		= SUM(CASE WHEN ysnIncludeInvoicePrice = 1 THEN CASE WHEN ISNULL(ID.dblQtyShipped, 0) <> 0 THEN IDT.dblAdjustedTax / ID.dblQtyShipped ELSE 0 END ELSE 0 END)
		 , dblIncludePriceTotal	= SUM(CASE WHEN ysnIncludeInvoicePrice = 1 THEN dblAdjustedTax ELSE 0 END)
	FROM tblARInvoiceDetailTax IDT
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
	INNER JOIN tblSMTaxClass TCLASS ON IDT.intTaxClassId = TCLASS.intTaxClassId
	WHERE ((IDT.ysnTaxExempt = 1 AND ISNULL(ID.dblComputedGrossPrice, 0) <> 0) OR (IDT.ysnTaxExempt = 0 AND IDT.dblAdjustedTax <> 0))
	  AND (@intItemForFreightId IS NULL OR ID.intItemId <> @intItemForFreightId)
	GROUP BY ID.intInvoiceId
) TOTALTAX ON TOTALTAX.intInvoiceId = ARI.intInvoiceId
OUTER APPLY (
	SELECT TOP 1 strMessage	= '<html>' + CAST(blbMessage AS VARCHAR(MAX)) + '</html>'
	FROM tblSMDocumentMaintenanceMessage H
	INNER JOIN tblSMDocumentMaintenance M ON H.intDocumentMaintenanceId = M.intDocumentMaintenanceId
	WHERE H.strHeaderFooter = 'Header'
	  AND M.strType = ARI.strType
	  AND M.strSource = ARI.strTransactionType
	ORDER BY M.[intDocumentMaintenanceId] DESC
		   , ISNULL(ARI.intEntityCustomerId, -10 * M.intDocumentMaintenanceId) DESC
		   , ISNULL(ARI.intCompanyLocationId, -100 * M.intDocumentMaintenanceId) DESC
) HEADER
OUTER APPLY (
	SELECT TOP 1 strMessage	= '<html>' + CAST(blbMessage AS VARCHAR(MAX)) + '</html>'
	FROM tblSMDocumentMaintenanceMessage H
	INNER JOIN tblSMDocumentMaintenance M ON H.intDocumentMaintenanceId = M.intDocumentMaintenanceId
	WHERE H.strHeaderFooter = 'Footer'
	  AND M.strType = ARI.strType
	  AND M.strSource = ARI.strTransactionType
	ORDER BY M.[intDocumentMaintenanceId] DESC
		   , ISNULL(ARI.intEntityCustomerId, -10 * M.intDocumentMaintenanceId) DESC
		   , ISNULL(ARI.intCompanyLocationId, -100 * M.intDocumentMaintenanceId) DESC
) FOOTER

WHERE ARI.intInvoiceId BETWEEN @intInvoiceIdFrom AND @intInvoiceIdTo 
OR ARI.intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@strInvoiceIds))
OR ARI.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo


EXEC dbo.uspARLogPerformanceRuntime 'Invoice Report', 'uspARInvoiceAgriCare', @strReportLogId, 0, @intEntityUserId, @intPerformanceLogId, NULL