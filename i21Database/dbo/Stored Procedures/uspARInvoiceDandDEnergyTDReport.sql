CREATE PROCEDURE [dbo].[uspARInvoiceDandDEnergyTDReport]
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
		,@blbLogo				VARBINARY(MAX)	= NULL
		,@blbStretchedLogo		VARBINARY(MAX)	= NULL
		,@strCompanyName		NVARCHAR(200)	= NULL
		,@strCompanyFullAddress	NVARCHAR(500)	= NULL
		,@strPhone				NVARCHAR(200)	= NULL
		,@strEmail				NVARCHAR(200)	= NULL
		,@intPerformanceLogId	INT				= NULL
		,@intEntityUserId		INT
		,@strInvoiceIds			AS NVARCHAR(MAX)
		,@ysnPrintInvoicePaymentDetail	BIT		= 0
		,@dtmDateNow			DATETIME		= NULL
		,@ysnStretchLogo		BIT				= 0
		,@strRequestId			AS NVARCHAR(MAX)
		,@intFreightItemId		INT				= 0
		,@intSurchargeItemId	INT				= 0

-- Sanitize the @xmlParam
IF LTRIM(RTRIM(@xmlParam)) = ''
BEGIN 
	SET @xmlParam = NULL
END

DECLARE @temp_INVOICES TABLE (
	      strCompanyName				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, strCompanyAddress             NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
		, intInvoiceId                  INT				NOT NULL
		, intEntityCustomerId           INT				NOT NULL
		, strInvoiceNumber              NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
		, strTransactionType            NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
		, dtmDate                       DATETIME		NOT NULL
		, dtmDueDate                    DATETIME		NOT NULL
		, strBOLNumber                  NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
		, strPONumber                   NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
		, intTruckDriverId              INT				NOT NULL
		, strTruckDriver                NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, intBillToLocationId           INT				NOT NULL
		, intShipToLocationId           INT				NOT NULL
		, strBillToLocationName         NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, strShipToLocationName         NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, strBillToAddress              NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
		, strShipToAddress              NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
		, strSource                     NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, intTermId                     INT				NOT NULL
		, strTerm                       NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, intShipViaId                  INT				NOT NULL
		, strShipVia                    NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, intCompanyLocationId          INT				NOT NULL
		, strCompanyLocation            NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, intInvoiceDetailId            INT				NULL
		, intSiteId                     INT				NULL
		, dblQtyShipped                 NUMERIC(18, 6)	NULL DEFAULT 0
		, intItemId                     INT				NULL
		, strItemNo                     NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, strItemDescription            NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
		, strContractNo                 NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
		, strUnitMeasure                NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, dblPrice                      NUMERIC(18, 6)	NULL DEFAULT 0
		, dblItemPrice                  NUMERIC(18, 6)	NULL DEFAULT 0
		, dblPriceWithTax               NUMERIC(18, 6)	NULL DEFAULT 0
		, dblTotalPriceWithTax          NUMERIC(18, 6)	NULL DEFAULT 0
		, dblInvoiceTotal               NUMERIC(18, 6)	NULL DEFAULT 0
		, dblAmountDue                  NUMERIC(18, 6)	NULL DEFAULT 0
		, dblInvoiceTax                 NUMERIC(18, 6)	NULL DEFAULT 0
		, dblTotalTax                   NUMERIC(18, 6)	NULL DEFAULT 0
		, strComments                   NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
		, strItemComments               NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
		, strOrigin                     NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
		, blbLogo                       VARBINARY(MAX)	NULL
		, intEntityUserId               INT				NULL
		, strRequestId					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
		, strInvoiceFormat				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
		, intTicketId                   INT				NULL
		, strTicketNumbers              NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
		, dtmLoadedDate                 DATETIME		NULL
		, dtmScaleDate                  DATETIME		NULL
		, strCommodity                  NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
		, ysnStretchLogo                BIT				NULL
		, blbSignature                  VARBINARY(MAX)	NULL
		, strTicketType                 NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, strLocationNumber             NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, strSalesOrderNumber           NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, strPaymentInfo                NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
		, dtmCreated                    DATETIME		NULL
		, strType                       NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard'
		, ysnPrintInvoicePaymentDetail  BIT				NULL
		, strLogoType                   NVARCHAR(10)
		, dblLaidInCost                 NUMERIC(18, 6)	NULL DEFAULT 0
		, dblInvoiceSubtotal            NUMERIC(18, 6)	NULL DEFAULT 0
)

DECLARE @temp_LOCATIONS TABLE
(
	 intCompanyLocationId		INT
	,strLocationName			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	,strUseLocationAddress		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	,strInvoiceComments			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	,strLocationNumber			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	,strFullAddress				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
)

DECLARE @temp_CUSTOMERS TABLE
(
	  intEntityCustomerId		INT
	 ,strCustomerNumber			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 ,strCustomerName			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 ,ysnIncludeEntityName		BIT
)
			
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

-- Gather the variables values from the xml table.
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

SELECT	@intEntityUserId = [from]
FROM	@temp_xml_table
WHERE	[fieldname] = 'intSrCurrentUserId'

SELECT @strInvoiceIds = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strInvoiceIds'

SELECT @strReportLogId = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strReportLogId'

SELECT @strRequestId = REPLACE(ISNULL([from], ''), '''''', '''')
FROM @temp_xml_table
WHERE [fieldname] = 'strRequestId'

IF EXISTS(SELECT * FROM tblSRReportLog WHERE strReportLogId = @strReportLogId) RETURN

EXEC dbo.uspARLogPerformanceRuntime 'Invoice Report', 'uspARInvoiceDandDEnergyTDReport', @strRequestId, 1, @intEntityUserId, NULL, @intPerformanceLogId OUT

--LOGO
SELECT TOP 1 @blbLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen IN ('SystemManager.CompanyPreference', 'SystemManager.view.CompanyPreference') 
  AND A.strComment = 'Header'
ORDER BY A.intAttachmentId DESC

--STRETCHED LOGO
SELECT TOP 1 @blbStretchedLogo = U.blbFile 
FROM tblSMUpload U
INNER JOIN tblSMAttachment A ON U.intAttachmentId = A.intAttachmentId
WHERE A.strScreen IN ('SystemManager.CompanyPreference', 'SystemManager.view.CompanyPreference') 
  AND A.strComment = 'Stretched Header'
ORDER BY A.intAttachmentId DESC

SET @blbStretchedLogo = ISNULL(@blbStretchedLogo, @blbLogo)
SET @dtmDateNow = GETDATE()

--AR PREFERENCE
SELECT TOP 1 @ysnPrintInvoicePaymentDetail	= ysnPrintInvoicePaymentDetail
		   , @ysnStretchLogo				= ysnStretchLogo
FROM dbo.tblARCompanyPreference WITH (NOLOCK)
ORDER BY intCompanyPreferenceId DESC

--COMPANY INFO
SELECT TOP 1 @strCompanyFullAddress	= strAddress + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(', ' + NULLIF(strZip, ''), '') + ISNULL(', ' + NULLIF(strCountry, ''), '')
		   , @strCompanyName		= strCompanyName
		   , @strPhone				= strPhone
		   , @strEmail				= strEmail
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

--LOCATIONS
INSERT INTO @temp_LOCATIONS (
	 intCompanyLocationId
	,strLocationName
	,strUseLocationAddress
	,strInvoiceComments
	,strLocationNumber
	,strFullAddress
)
SELECT intCompanyLocationId		= L.intCompanyLocationId
	 , strLocationName			= L.strLocationName
	 , strUseLocationAddress	= ISNULL(L.strUseLocationAddress, 'No')
	 , strInvoiceComments		= L.strInvoiceComments
	 , strLocationNumber		= L.strLocationNumber
	 , strFullAddress			= L.strAddress + CHAR(13) + CHAR(10) + ISNULL(NULLIF(L.strCity, ''), '') + ISNULL(', ' + NULLIF(L.strStateProvince, ''), '') + ISNULL(', ' + NULLIF(L.strZipPostalCode, ''), '') + ISNULL(', ' + NULLIF(L.strCountry, ''), '')
FROM tblSMCompanyLocation L

DELETE FROM tblARInvoiceReportStagingTable 
WHERE intEntityUserId = @intEntityUserId 
  AND strRequestId = @strReportLogId 
  AND strInvoiceFormat = 'Format 2 - With Laid in Cost'

-- Get Freight itemId
SELECT TOP 1 @intFreightItemId = intFreightItemId
	FROM tblTRLoadHeader H INNER JOIN tblICItem I ON I.intItemId = H.intFreightItemId
	INNER JOIN tblARInvoiceDetail INVD ON H.strTransaction = INVD.strDocumentNumber
	WHERE INVD.intInvoiceId BETWEEN @intInvoiceIdFrom AND @intInvoiceIdTo 
		OR INVD.intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@strInvoiceIds))

-- Get Surcharge itemId
SELECT TOP 1 @intSurchargeItemId = intItemId
	FROM vyuICGetOtherCharges WHERE intOnCostTypeId = @intFreightItemId

--MAIN QUERY
INSERT INTO @temp_INVOICES
(
	  strCompanyName
	, strCompanyAddress
	, intInvoiceId
	, intEntityCustomerId
	, strInvoiceNumber
	, strTransactionType
	, dtmDate
	, dtmDueDate
	, strBOLNumber
	, strPONumber
	, intTruckDriverId
	, strTruckDriver
	, intBillToLocationId
	, intShipToLocationId
	, strBillToLocationName
	, strShipToLocationName
	, strBillToAddress
	, strShipToAddress
	, strSource
	, intTermId
	, strTerm
	, intShipViaId
	, strShipVia
	, intCompanyLocationId
	, strCompanyLocation
	, intInvoiceDetailId
	, intSiteId
	, dblQtyShipped
	, intItemId
	, strItemNo
	, strItemDescription
	, strContractNo
	, strUnitMeasure
	, dblPrice
	, dblItemPrice
	, dblPriceWithTax
	, dblTotalPriceWithTax
	, dblInvoiceTotal
	, dblAmountDue
	, dblInvoiceTax
	, dblTotalTax
	, strComments
	, strItemComments
	, strOrigin
	, blbLogo
	, intEntityUserId
	, strRequestId
	, strInvoiceFormat
	, intTicketId
	, strTicketNumbers
	, dtmLoadedDate
	, dtmScaleDate
	, strCommodity
	, ysnStretchLogo
	, blbSignature
	, strTicketType
	, strLocationNumber
	, strSalesOrderNumber
	, strPaymentInfo
	, dtmCreated
	, strType
	, ysnPrintInvoicePaymentDetail
	, strLogoType
	, dblLaidInCost
	, dblInvoiceSubtotal
)
SELECT strCompanyName			= CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' ELSE @strCompanyName END
	 , strCompanyAddress		= CASE WHEN L.strUseLocationAddress IN ('No', 'Always') THEN @strCompanyFullAddress
										WHEN L.strUseLocationAddress = 'Yes' THEN L.strFullAddress
										WHEN L.strUseLocationAddress = 'Letterhead' THEN ''
									END
	 , intInvoiceId				= INV.intInvoiceId
	 , intEntityCustomerId		= INV.intEntityCustomerId
	 , strInvoiceNumber			= INV.strInvoiceNumber
	 , strTransactionType		= INV.strTransactionType
	 , dtmDate					= CAST(INV.dtmDate AS DATE)
	 , dtmDueDate				= INV.dtmDueDate
	 , strBOLNumber				= INV.strBOLNumber
	 , strPONumber				= INV.strPONumber
	 , intTruckDriverId			= ISNULL(INV.intTruckDriverId, INV.intEntitySalespersonId)
	 , strTruckDriver			= CASE WHEN INV.strType = 'Tank Delivery' THEN ISNULL(NULLIF(DRIVER.strName, ''), SALESPERSON.strName) ELSE NULL END
	 , intBillToLocationId		= INV.intBillToLocationId
	 , intShipToLocationId		= INV.intShipToLocationId
	 , strBillToLocationName	= EMBT.strEntityNo
	 , strShipToLocationName	= EMST.strEntityNo
	 , strBillToAddress			= ISNULL(RTRIM(INV.strBillToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strBillToAddress) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strBillToCity), '') + ISNULL(RTRIM(', ' + INV.strBillToState), '') + ISNULL(RTRIM(', ' + INV.strBillToZipCode), '') + ISNULL(RTRIM(', ' + INV.strBillToCountry), '')
	 , strShipToAddress			= CAST(ISNULL(RTRIM(INV.strShipToLocationName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strShipToAddress) + CHAR(13) + char(10), '') + ISNULL(RTRIM(INV.strShipToCity), '') + ISNULL(RTRIM(', ' + INV.strShipToState), '') + ISNULL(RTRIM(', ' + INV.strShipToZipCode), '') + ISNULL(RTRIM(', ' + INV.strShipToCountry), '') AS NVARCHAR(MAX))
	 , strSource				= INV.strType
	 , intTermId				= INV.intTermId
	 , strTerm					= TERM.strTerm
	 , intShipViaId				= INV.intShipViaId
	 , strShipVia				= SHIPVIA.strShipVia
	 , intCompanyLocationId		= INV.intCompanyLocationId
	 , strCompanyLocation		= CAST(L.strLocationName AS NVARCHAR(100))
	 , intInvoiceDetailId		= ISNULL(INVOICEDETAIL.intInvoiceDetailId,0)
	 , intSiteId				= INVOICEDETAIL.intSiteId
	 , dblQtyShipped			= INVOICEDETAIL.dblQtyShipped
	 , intItemId				= INVOICEDETAIL.intItemId
	 , strItemNo				= INVOICEDETAIL.strItemNo
	 , strItemDescription		= INVOICEDETAIL.strItemDescription
	 , strContractNo			= INVOICEDETAIL.strContractNo
	 , strUnitMeasure			= INVOICEDETAIL.strUnitMeasure
	 , dblPrice					= INVOICEDETAIL.dblPrice
	 , dblItemPrice				= INVOICEDETAIL.dblTotal
	 , dblPriceWithTax			= INVOICEDETAIL.dblPriceWithTax
	 , dblTotalPriceWithTax		= INVOICEDETAIL.dblTotalPriceWithTax
	 , dblInvoiceTotal			= ISNULL(INV.dblInvoiceTotal, 0)
	 , dblAmountDue				= ISNULL(INV.dblAmountDue, 0)
	 , dblInvoiceTax			= ISNULL(INV.dblTax, 0)
	 , dblTotalTax				= INVOICEDETAIL.dblTotalTax
	 , strComments				= CASE WHEN INV.strType = 'Tank Delivery' THEN ISNULL(INV.strComments, '') ELSE ISNULL(INV.strFooterComments, '') END
	 , strItemComments          = CAST('' AS NVARCHAR(500))
	 , strOrigin				= CAST(REPLACE(INV.strComments, 'Origin:', '') AS NVARCHAR(MAX))
	 , blbLogo					= ISNULL(SMLP.imgLogo, CASE WHEN ISNULL(@ysnStretchLogo, 0) = 1 THEN @blbStretchedLogo ELSE @blbLogo END)
	 , intEntityUserId			= @intEntityUserId
	 , strRequestId				= @strRequestId
	 , strInvoiceFormat			= 'Format 2 - With Laid in Cost'
	 , intTicketId				= CAST(0 AS INT)
	 , strTicketNumbers			= CAST('' AS NVARCHAR(MAX))
	 , dtmLoadedDate			= INV.dtmShipDate
	 , dtmScaleDate				= INV.dtmPostDate
	 , strCommodity				= CAST('' AS NVARCHAR(100))
	 , ysnStretchLogo			= ISNULL(@ysnStretchLogo, 0)
	 , blbSignature				= INV.blbSignature
	 , strTicketType			= INV.strTransactionType
	 , strLocationNumber		= L.strLocationNumber
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strPaymentInfo			= CASE WHEN INV.strTransactionType = 'Cash' THEN ISNULL(PAYMENTMETHOD.strPaymentMethod, '') + ' - ' + ISNULL(INV.strPaymentInfo, '') ELSE NULL END
	 , dtmCreated				= @dtmDateNow
	 , strType					= INV.strType
	 , ysnPrintInvoicePaymentDetail = @ysnPrintInvoicePaymentDetail
	 , strLogoType				= CASE WHEN SMLP.imgLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
	 , dblLaidInCost			= 0
	 , dblInvoiceSubtotal		= INV.dblInvoiceSubtotal
FROM dbo.tblARInvoice INV WITH (NOLOCK)
INNER JOIN @temp_LOCATIONS L ON INV.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN tblSMTerm TERM WITH (NOLOCK) ON INV.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT intInvoiceId			= ID.intInvoiceId
		 , intInvoiceDetailId   = ID.intInvoiceDetailId
		 , intSiteId			= ID.intSiteId
		 , dblQtyShipped		= ID.dblQtyShipped
		 , intItemId			= ID.intItemId
		 , strItemNo			= ITEM.strItemNo
		 , strItemDescription	= ID.strItemDescription
		 , strContractNo		= CT.strContractNumber
		 , strUnitMeasure		= UM.strUnitMeasure
		 , dblPrice				= ID.dblPrice
		 , dblTotal				= ID.dblTotal
		 , dblPriceWithTax		= ID.dblPrice + ISNULL(CASE WHEN ID.dblTotalTax <> 0 AND ID.dblQtyShipped <> 0 THEN ID.dblTotalTax/ID.dblQtyShipped ELSE 0 END, 0)
		 , dblTotalPriceWithTax = ID.dblTotal + ID.dblTotalTax
		 , dblTotalTax			= ID.dblTotalTax
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN tblICItem ITEM WITH (NOLOCK) ON ID.intItemId = ITEM.intItemId
	LEFT JOIN tblCTContractHeader CT WITH (NOLOCK) ON ID.intContractHeaderId = CT.intContractHeaderId
	LEFT JOIN tblICItemUOM IUOM ON ID.intItemUOMId = IUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUOM.intUnitMeasureId
) INVOICEDETAIL ON INV.intInvoiceId = INVOICEDETAIL.intInvoiceId
LEFT JOIN tblEMEntity DRIVER WITH (NOLOCK) ON INV.intTruckDriverId = DRIVER.intEntityId
LEFT JOIN tblEMEntity SALESPERSON WITH (NOLOCK) ON INV.intEntitySalespersonId = SALESPERSON.intEntityId
LEFT JOIN tblEMEntityLocation BILLTO WITH (NOLOCK) ON INV.intBillToLocationId = BILLTO.intEntityLocationId
LEFT JOIN tblEMEntity EMBT ON BILLTO.intEntityId = EMBT.intEntityId
LEFT JOIN tblEMEntityLocation SHIPTO WITH (NOLOCK) ON INV.intShipToLocationId = SHIPTO.intEntityLocationId
LEFT JOIN tblEMEntity EMST ON SHIPTO.intEntityId = EMST.intEntityId
LEFT JOIN tblSMShipVia SHIPVIA WITH (NOLOCK) ON INV.intShipViaId = SHIPVIA.intEntityId
LEFT JOIN tblSMPaymentMethod PAYMENTMETHOD ON INV.intPaymentMethodId = PAYMENTMETHOD.intPaymentMethodID
LEFT JOIN tblSOSalesOrder SO ON INV.intSalesOrderId = SO.intSalesOrderId
OUTER APPLY (
	SELECT TOP 1 imgLogo
	FROM tblSMLogoPreference
	WHERE intCompanyLocationId = INV.intCompanyLocationId AND (ysnARInvoice = 1 OR ysnDefault = 1)
	ORDER BY ysnARInvoice DESC
) SMLP
WHERE INV.intInvoiceId BETWEEN @intInvoiceIdFrom AND @intInvoiceIdTo 
OR INV.intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@strInvoiceIds))
OR INV.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo

--CUSTOMERS
INSERT INTO @temp_CUSTOMERS
(
	 intEntityCustomerId
	,strCustomerNumber
	,strCustomerName
	,ysnIncludeEntityName
)
SELECT intEntityCustomerId	= C.intEntityId
	 , strCustomerNumber	= C.strCustomerNumber
	 , strCustomerName		= E.strName
	 , ysnIncludeEntityName	= C.ysnIncludeEntityName
FROM tblARCustomer C
INNER JOIN (
	SELECT DISTINCT intEntityCustomerId
	FROM @temp_INVOICES
) STAGING ON C.intEntityId = STAGING.intEntityCustomerId
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId

--SHIP TO FOR TM SITE
UPDATE I
SET strShipToAddress	= CONSUMPTIONSITE.strSiteFullAddress
  , strCompanyLocation	= CONSUMPTIONSITE.strSiteNumber
  , strOrigin			= CONSUMPTIONSITE.strLocationName
FROM @temp_INVOICES I 
CROSS APPLY (
	SELECT TOP 1 intSiteId				= ID.intSiteId
			   , strSiteFullAddress		= ISNULL(RTRIM(S.strSiteAddress) + CHAR(13) + char(10), '')	+ ISNULL(RTRIM(S.strCity), '') + ISNULL(RTRIM(', ' + S.strState), '') + ISNULL(RTRIM(', ' + S.strZipCode), '') + ISNULL(RTRIM(', ' + S.strCountry), '')
			   , strSiteNumber			= RIGHT('000'+ CAST(S.intSiteNumber AS NVARCHAR(4)),4) + ' - ' + ISNULL(S.strDescription, '')
			   , strLocationName		= CLS.strLocationName
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN tblTMSite S ON ID.intSiteId = S.intSiteID
	INNER JOIN tblSMCompanyLocation CLS ON S.intLocationId = CLS.intCompanyLocationId
	WHERE ID.intInvoiceId = I.intInvoiceId 
	  AND ISNULL(ID.intSiteId, 0) <> 0
	ORDER BY ID.intInvoiceDetailId
) CONSUMPTIONSITE
WHERE I.strType = 'Tank Delivery'

--UPDATE CUSTOMER
UPDATE I
SET strBillToAddress		= CASE WHEN C.ysnIncludeEntityName = 1 THEN ISNULL(RTRIM(C.strCustomerName) + CHAR(13) + char(10), '') + I.strBillToAddress ELSE I.strBillToAddress END
  , strShipToAddress		= CASE WHEN C.ysnIncludeEntityName = 1 THEN ISNULL(RTRIM(C.strCustomerName) + CHAR(13) + char(10), '') + I.strShipToAddress ELSE I.strShipToAddress END
FROM @temp_INVOICES I
INNER JOIN @temp_CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId

--UPDATE NEGATIVE AMOUNTS
UPDATE I
SET dblPrice				= dblPrice * -1
  , dblPriceWithTax			= dblPriceWithTax * -1
  , dblTotalPriceWithTax	= dblTotalPriceWithTax * -1
  , dblInvoiceTotal			= dblInvoiceTotal * -1
  , dblQtyShipped			= dblQtyShipped * -1
FROM @temp_INVOICES I
WHERE I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')

--UPDATE TICKET DETAILS
UPDATE I
SET intTicketId			= TICKETDETAILS.intTicketId
  , strTicketNumbers	= TICKETDETAILS.strTicketNumbers
  , strCommodity		= TICKETDETAILS.strCommodity
FROM @temp_INVOICES I
CROSS APPLY (
	SELECT TOP 1 intTicketId		= TICKET.intTicketId
		       , strTicketNumbers	= TICKET.strTicketNumber
		       , strCommodity		= COM.strDescription
	FROM dbo.tblARInvoiceDetail DETAIL
	INNER JOIN dbo.tblSCTicket TICKET ON DETAIL.intTicketId = TICKET.intTicketId
	LEFT JOIN dbo.tblICCommodity COM ON TICKET.intCommodityId = COM.intCommodityId
	WHERE DETAIL.intInvoiceId = I.intInvoiceId
	  AND DETAIL.intTicketId IS NOT NULL
	ORDER BY DETAIL.intInvoiceDetailId
) TICKETDETAILS

--HAZMAT ITEMS
UPDATE I
SET strItemComments = HAZMAT.strMessage
FROM @temp_INVOICES I
CROSS APPLY (
	SELECT strMessage = LEFT(strMessage, LEN(strMessage) - 0)
	FROM (
		SELECT CAST(ISNULL(ICC.strMessage, '') AS VARCHAR(MAX)) + CHAR(10)
		FROM dbo.tblARInvoiceDetail IDD WITH (NOLOCK)
		INNER JOIN (
			SELECT intItemId
				 , ICT.strMessage 
			FROM dbo.tblICItem ICC WITH (NOLOCK)
			INNER JOIN dbo.tblICTag ICT ON ICC.intHazmatTag = ICT.intTagId AND ICT.strType = 'Hazmat Message'
			WHERE ICC.intHazmatTag > 0
			  AND ICC.intHazmatTag IS NOT NULL
		) ICC ON IDD.intItemId = ICC.intItemId
		WHERE IDD.intInvoiceId = I.intInvoiceId		
		GROUP BY IDD.intItemId, ICC.strMessage
		FOR XML PATH ('')
	) DETAILS (strMessage)
) HAZMAT

--COMMENTS
UPDATE I
SET strComments	= dbo.fnEliminateHTMLTags(I.strComments, 0)
  , strOrigin	= dbo.fnEliminateHTMLTags(I.strOrigin, 0)
FROM @temp_INVOICES I
WHERE strComments <> '' 
   OR strOrigin <> ''

INSERT INTO tblARInvoiceReportStagingTable WITH (TABLOCK) (
	   strCompanyName
	 , strCompanyAddress
	 , intInvoiceId
	 , intEntityCustomerId
	 , strInvoiceNumber
	 , strTransactionType
	 , dtmDate
	 , dtmDueDate
	 , strBOLNumber
	 , strPONumber
	 , intTruckDriverId
	 , strTruckDriver
	 , intBillToLocationId
	 , intShipToLocationId
	 , strBillToLocationName
	 , strShipToLocationName
	 , strBillTo		
	 , strShipTo
	 , strSource
	 , intTermId
	 , strTerm
	 , intShipViaId
	 , strShipVia
	 , intCompanyLocationId
	 , strCompanyLocation
	 , intInvoiceDetailId
	 , intSiteId
	 , dblQtyShipped
	 , intItemId
	 , strItemNo
	 , strItemDescription
	 , strContractNo
	 , strUnitMeasure
	 , dblPrice
	 , dblItemPrice
	 , dblPriceWithTax
	 , dblTotalPriceWithTax
	 , dblInvoiceTotal
	 , dblAmountDue
	 , dblInvoiceTax
	 , dblTotalTax
	 , strComments
	 , strItemComments
	 , strOrigin
	 , blbLogo
	 , intEntityUserId
	 , strRequestId
	 , strInvoiceFormat
	 , intTicketId
	 , strTicketNumbers
	 , dtmLoadedDate
	 , dtmScaleDate
	 , strCommodity
	 , ysnStretchLogo
	 , blbSignature
	 , strTicketType
	 , strLocationNumber
	 , strSalesOrderNumber
	 , strPaymentInfo
	 , dtmCreated
	 , ysnPrintInvoicePaymentDetail
	 , strLogoType
)
SELECT strCompanyName
	 , strCompanyAddress
	 , intInvoiceId
	 , intEntityCustomerId
	 , strInvoiceNumber
	 , strTransactionType
	 , dtmDate
	 , dtmDueDate
	 , strBOLNumber
	 , strPONumber
	 , intTruckDriverId
	 , strTruckDriver
	 , intBillToLocationId
	 , intShipToLocationId
	 , strBillToLocationName
	 , strShipToLocationName
	 , strBillToAddress
	 , strShipToAddress
	 , strSource
	 , intTermId
	 , strTerm
	 , intShipViaId
	 , strShipVia
	 , intCompanyLocationId
	 , strCompanyLocation
	 , intInvoiceDetailId
	 , intSiteId
	 , dblQtyShipped
	 , intItemId
	 , strItemNo
	 , strItemDescription
	 , strContractNo
	 , strUnitMeasure
	 , dblPrice
	 , dblItemPrice
	 , dblPriceWithTax
	 , dblTotalPriceWithTax
	 , dblInvoiceTotal
	 , dblAmountDue
	 , dblInvoiceTax
	 , dblTotalTax
	 , strComments
	 , strItemComments
	 , strOrigin
	 , blbLogo
	 , intEntityUserId
	 , strRequestId
	 , strInvoiceFormat
	 , intTicketId
	 , strTicketNumbers
	 , dtmLoadedDate
	 , dtmScaleDate
	 , strCommodity
	 , ysnStretchLogo
	 , blbSignature
	 , strTicketType
	 , strLocationNumber
	 , strSalesOrderNumber
	 , strPaymentInfo
	 , dtmCreated
	 , ysnPrintInvoicePaymentDetail
	 , strLogoType
FROM @temp_INVOICES


--UPDATE LAID IN COST
UPDATE I
SET dblLaidInCost = LIC.LaidInCost
FROM @temp_INVOICES I
LEFT JOIN (
	SELECT 
		  ID.intInvoiceDetailId
		, (ID.dblPrice
			+ (Freight.dblPrice * Freight.dblQtyShipped / ID.dblQtyShipped)
			+ ((Freight.dblPrice * Freight.dblQtyShipped / ID.dblQtyShipped) * Surgecharge.dblPrice)
			+ Taxes.taxRate
		) [LaidInCost]
	FROM tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN tblICItem I WITH (NOLOCK) ON ID.intItemId = I.intItemId
	LEFT JOIN (
		SELECT 
			intLoadDistributionDetailId
			, intInvoiceId
			, dblQtyShipped
			, dblPrice
		FROM tblARInvoiceDetail LD WITH (NOLOCK)
		WHERE intItemId = @intFreightItemId
	) Freight ON Freight.intLoadDistributionDetailId = ID.intLoadDistributionDetailId AND Freight.intInvoiceId = ID.intInvoiceId
	LEFT JOIN (
		SELECT 
			intLoadDistributionDetailId
			, intInvoiceId
			, dblQtyShipped
			, dblPrice
		FROM tblARInvoiceDetail LD WITH (NOLOCK)
		WHERE intItemId = @intSurchargeItemId
	) Surgecharge ON Surgecharge.intLoadDistributionDetailId = ID.intLoadDistributionDetailId AND Surgecharge.intInvoiceId = ID.intInvoiceId
	LEFT JOIN (
		SELECT 
			SUM(dblRate) [taxRate]
			, intInvoiceId
		FROM vyuARTaxDetailMCPReport
		GROUP BY intInvoiceId
	) Taxes ON ID.intInvoiceId = Taxes.intInvoiceId
	WHERE (ID.intItemId <> 18 AND ID.intItemId <> 17)
		AND I.strType IN ('Bundle','Inventory')
) LIC ON I.intInvoiceDetailId = LIC.intInvoiceDetailId

SELECT strCompanyName
	 , strCompanyAddress
	 , intInvoiceId
	 , intEntityCustomerId
	 , strInvoiceNumber
	 , strTransactionType
	 , dtmDate
	 , dtmDueDate
	 , strBOLNumber
	 , strPONumber
	 , intTruckDriverId
	 , strTruckDriver
	 , intBillToLocationId
	 , intShipToLocationId
	 , strBillToLocationName
	 , strShipToLocationName
	 , strBillToAddress
	 , strShipToAddress
	 , strSource
	 , intTermId
	 , strTerm
	 , intShipViaId
	 , strShipVia
	 , intCompanyLocationId
	 , strCompanyLocation
	 , intInvoiceDetailId
	 , intSiteId
	 , dblQtyShipped
	 , intItemId
	 , strItemNo
	 , strItemDescription
	 , strContractNo
	 , strUnitMeasure
	 , dblPrice
	 , dblItemPrice
	 , dblPriceWithTax
	 , dblTotalPriceWithTax
	 , dblInvoiceTotal
	 , dblAmountDue
	 , dblInvoiceTax
	 , dblTotalTax
	 , strComments
	 , strItemComments
	 , strOrigin
	 , blbLogo
	 , intEntityUserId
	 , strRequestId
	 , strInvoiceFormat
	 , intTicketId
	 , strTicketNumbers
	 , dtmLoadedDate
	 , dtmScaleDate
	 , strCommodity
	 , ysnStretchLogo
	 , blbSignature
	 , strTicketType
	 , strLocationNumber
	 , strSalesOrderNumber
	 , strPaymentInfo
	 , dtmCreated
	 , ysnPrintInvoicePaymentDetail
	 , strLogoType
	 , dblLaidInCost
	 , dblInvoiceSubtotal
FROM @temp_INVOICES


EXEC dbo.uspARLogPerformanceRuntime 'Invoice Report', 'uspARInvoiceDandDEnergyTDReport', @strRequestId, 0, @intEntityUserId, @intPerformanceLogId, NULL