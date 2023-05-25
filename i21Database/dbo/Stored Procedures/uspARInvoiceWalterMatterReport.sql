CREATE PROCEDURE [dbo].[uspARInvoiceWalterMatterReport]
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

-- Sanitize the @xmlParam
IF LTRIM(RTRIM(@xmlParam)) = ''
BEGIN 
	SET @xmlParam = NULL
END
			
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

DECLARE @temp_AdditionalItemDetail TABLE (
	 [id]					INT
	,[intInvoiceDetailId]	INT
	,[intOriginId]			INT
	,[strCommodityOrigin]	NVARCHAR(50)
	,[strLotCertificate]	NVARCHAR(100)
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

INSERT INTO @temp_AdditionalItemDetail
(
	 [intInvoiceDetailId]
	,[intOriginId]
	,[strCommodityOrigin]
	,[strLotCertificate]
)
SELECT
	 [intInvoiceDetailId]	= ARID.[intInvoiceDetailId]
	,[intOriginId]			= ICI.[intOriginId]
	,[strCommodityOrigin]	= ICCA.[strDescription]
	,[strLotCertificate]	= ItemLotId.strCertificate
FROM tblARInvoice ARI WITH (NOLOCK) 
LEFT JOIN tblARInvoiceDetail ARID WITH (NOLOCK) ON ARI.intInvoiceId = ARID.intInvoiceId
LEFT JOIN tblICItem ICI WITH (NOLOCK) ON ICI.intItemId = ARID.intItemId
LEFT JOIN tblICCommodityAttribute ICCA WITH (NOLOCK) ON ICI.intOriginId = ICCA.intCommodityAttributeId
OUTER APPLY (SELECT TOP 1 ICIRIL.strCertificate FROM tblARInvoiceDetailLot ARIDL WITH (NOLOCK) 
			LEFT JOIN tblICInventoryReceiptItemLot ICIRIL WITH (NOLOCK) ON ARIDL.intLotId = ICIRIL.intLotId
			WHERE ARID.intInvoiceDetailId = ARIDL.intInvoiceDetailId) ItemLotId
WHERE ARI.intInvoiceId BETWEEN @intInvoiceIdFrom AND @intInvoiceIdTo 
OR ARI.intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@strInvoiceIds))
OR ARI.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo

IF EXISTS(SELECT * FROM tblSRReportLog WHERE strReportLogId = @strReportLogId) RETURN

EXEC dbo.uspARLogPerformanceRuntime 'Invoice Report', 'uspARInvoiceWalterMatterReport', @strReportLogId, 1, @intEntityUserId, NULL, @intPerformanceLogId OUT

SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header')

SELECT TOP 1 @strCompanyFullAddress	= strAddress + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(', ' + NULLIF(strZip, ''), '') + ISNULL(', ' + NULLIF(strCountry, ''), '')
		   , @strCompanyName		= strCompanyName
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

SELECT
	 intInvoiceId				= ARI.intInvoiceId
	,intInvoiceDetailId			= ISNULL(ARGID.intInvoiceDetailId, 0)
	,strCompanyName				= @strCompanyName
	,strCompanyAddress			= @strCompanyFullAddress
	,strInvoiceNumber			= ARI.strInvoiceNumber
	,strCustomerName			= ARCS.strName
	,strLocationName			= ISNULL(NULLIF(SMCL.strCity, ''), '') + ',' + FORMAT(ARI.dtmDate, 'dd.MM.yyyy')
	,strContractNumber			= CTCDV.strContractNumber + '-' + CAST(CTCDV.intContractSeq AS NVARCHAR(100)) + ' dated ' + FORMAT(CTCDV.dtmContractDate, 'dd.MM.yyyy')
	,strOrigin					= CTCDV.strItemOrigin
	,strFreightTerm				= CTCDV.strFreightTerm
	,strWeight					= CTCDV.strWeight
	,strCustomerReference		= CTCDV.strCustomerContract
	,strFLOId					= ARCS.strFLOId
	,strGrade					= CTCDV.strGrade
	,dtmDueDate					= CAST(ARI.dtmDueDate AS DATE)
	,strTerm					= SMT.strTerm
	,strItemDescription			= ISNULL(NULLIF(TAID.strCommodityOrigin COLLATE SQL_Latin1_General_CP1_CS_AS, '') + ', ', '') + ARGID.strItemDescription + ISNULL(', ' + NULLIF(TAID.strLotCertificate, ''), '')
	,strQtyShipped				= CONVERT(VARCHAR,CAST(ARGID.dblQtyShipped AS MONEY),1) + ' ' + ARGID.strUnitMeasure
	,strShipmentGrossWt			= CONVERT(VARCHAR,CAST(ARGID.dblShipmentGrossWt AS MONEY),1) + ' ' + ARGID.strWeightUnitMeasure
	,strShipmentTareWt			= CONVERT(VARCHAR,CAST(ARGID.dblShipmentTareWt AS MONEY),1) + ' ' + ARGID.strWeightUnitMeasure
	,strShipmentNetWt			= CONVERT(VARCHAR,CAST(ARGID.dblShipmentNetWt AS MONEY),1) + ' ' + ARGID.strWeightUnitMeasure
	,strCurrenyPriceUOM			= REPLACE(CONVERT(VARCHAR,CAST(ARGID.dblPrice AS MONEY),1), '.00','') + ' ' + ARGID.strCurrency + '/' + ARGID.strUnitMeasure
	,strEDICode					= ICC.strEDICode
	,ysnCustomsReleased			= ISNULL(LGL.ysnCustomsReleased, 0)
	,strBOLNumber				= LGL.strBLNumber + ' dd ' + FORMAT(LGL.dtmBLDate, 'dd.MM.yyyy')
	,strDestinationCity			= LGL.strDestinationCity
	,strMVessel					= LGL.strMVessel
	,strPaymentComments			= dbo.fnEliminateHTMLTags(ISNULL(ARI.strPaymentInstructions, ''), 0)
	,blbLogo					= ISNULL(SMLP.imgLogo, @blbLogo)
	,strLogoType				= CASE WHEN SMLP.imgLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
	,strBankName				= CMB.strBankName
	,strIBAN					= CMBA.strIBAN
	,strSWIFT					= CMBA.strSWIFT
	,strBICCode					= CMBA.strBICCode
	,strBankAddress				= ISNULL(NULLIF(CMB.strAddress, ''), '')
	,blbFooterLogo				= SMLPF.imgLogo
	,dblInvoiceSubtotal			= ARI.dblInvoiceSubtotal
	,strInvoiceSubtotal			= ARGID.strCurrency + ' ' + REPLACE(CONVERT(VARCHAR,CAST(ARI.dblInvoiceSubtotal AS MONEY),1), '.00','')
	,dblTax						= ARI.dblTax
	,strTax						= ARGID.strCurrency + ' ' + REPLACE(CONVERT(VARCHAR,CAST(ARI.dblTax AS MONEY),1), '.00','')
	,dblInvoiceTotal			= CASE WHEN ARI.strTransactionType = 'Customer Prepayment' AND ARI.ysnPosted = 0 THEN 0 ELSE ARI.dblInvoiceTotal END
	,strInvoiceTotal			= CASE WHEN ARI.strTransactionType = 'Customer Prepayment' AND ARI.ysnPosted = 0 THEN ARGID.strCurrency + ' ' + '0.00' ELSE ARGID.strCurrency + ' ' + REPLACE(CONVERT(VARCHAR,CAST(ARI.dblInvoiceTotal AS MONEY),1), '.00','') END
	,strVATNo					= ISNULL(EMELS.strVATNo, '')
	,strOurFiscalRepName		= EMELS.strOurFiscalRepName
	,strOurFiscalRepAddress		= EMELS.strOurFiscalRepAddress
	,strEntityLocationRemarks	= EMELS.strRemarks
	,strFooterComments			= dbo.fnEliminateHTMLTags(ISNULL(ARI.strFooterComments, ''), 0)
	,dblTotal					= ARGID.dblTotal
	,strTotal					= ARGID.strCurrency + ' ' + REPLACE(CONVERT(VARCHAR,CAST(ARGID.dblTotal AS MONEY),1), '.00','')
	,strReportIdentifier		= CASE 
									WHEN ARI.strType = 'Provisional' THEN 'Provisional ' 
									WHEN ARIR.strType = 'Provisional' THEN 'Commercial ' 
									WHEN ISNULL(ARI.strPrintFormat, '') <> '' THEN ARI.strPrintFormat + ' '
									ELSE ''
								  END + 'Invoice No: ' + ARI.strInvoiceNumber COLLATE Latin1_General_CI_AS
	,strRelatedInvoiceRemarks	= CASE 
									WHEN ARIR.strType = 'Provisional' THEN 'Replaces Provisional Invoice: ' + + ARIR.strInvoiceNumber
									WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.intOriginalInvoiceId, 0) <> 0 THEN 'Cancels Invoice: ' + ARIR.strInvoiceNumber
									ELSE ''
								  END
	,dblAmountDue				= ARI.dblAmountDue
	,dblShipmentNetWt			= ARGID.dblShipmentNetWt
	,dblQtyShipped				= ARGID.dblQtyShipped
	,strUnitMeasure				= ARGID.strUnitMeasure
	,dblUnitPrice				= ARGID.dblUnitPrice
	,strProvisionalInvoiceNumber= ISNULL(ARIR.strInvoiceNumber, '')
	,dtmRelatedDate				= ARIR.dtmDate
	,dblRelatedPayment			= ARIR.dblPayment
	,dblRelatedShipmentNetWt	= ARGIDP.dblShipmentNetWt
	,dblRelatedQtyShipped		= ARGIDP.dblQtyShipped
	,strRelatedUnitMeasure		= ARGIDP.strUnitMeasure
	,dblRelatedUnitPrice		= ARGIDP.dblUnitPrice
	,strRelatedType				= ARIR.strType
	,strType					= ARI.strType
	,strTransactionType			= ARI.strTransactionType
	,strBuyer					= ISNULL(RTRIM(EMELB.strCheckPayeeName) + CHAR(13) + char(10), '') + ISNULL(RTRIM(ARI.strBillToAddress) + CHAR(13) + CHAR(10), '')	+ ISNULL(NULLIF(ARI.strBillToCity, ''), '') + ISNULL(', ' + NULLIF(ARI.strBillToState, ''), '') + ISNULL(', ' + NULLIF(ARI.strBillToZipCode, ''), '') + ISNULL(', ' + NULLIF(ARI.strBillToCountry, ''), '')
	,dblPercentage				= CASE 
									WHEN ARI.ysnFromProvisional = 1 THEN ARGIDP.dblPercentage
									WHEN ARI.strType = 'Provisional' THEN ARGID.dblPercentage
									ELSE 0
								  END
	,dblProvisionalTotal		= CASE 
									WHEN ARI.ysnFromProvisional = 1 THEN ARGIDP.dblProvisionalTotal
									WHEN ARI.strType = 'Provisional' THEN ARGID.dblProvisionalTotal 
									ELSE 0
								  END
	,strFLOIDNo					= 'FLO ID No ' + ISNULL(NULLIF(CAST(SMCL.strFLOID AS VARCHAR(20)), ''), '')
	,strBioINSPECTANo			= 'BIO INSPECTA No ' + ISNULL(NULLIF(SMCL.strBioINSPECTANo, ''), '')
	,strStorageLocation			= LGLDLV.strStorageLocation
	,strCommodityDescription	= ICC.strDescription
FROM tblARInvoice ARI WITH (NOLOCK)
INNER JOIN vyuARCustomerSearch ARCS WITH (NOLOCK) ON ARI.intEntityCustomerId = ARCS.intEntityId 
INNER JOIN tblSMCompanyLocation SMCL WITH (NOLOCK) ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId
INNER JOIN tblEMEntityLocation EMELS WITH (NOLOCK) ON ARI.intShipToLocationId = EMELS.intEntityLocationId
INNER JOIN tblEMEntityLocation EMELB ON ARI.intBillToLocationId = EMELB.intEntityLocationId
LEFT JOIN vyuARGetInvoiceDetail ARGID WITH (NOLOCK) ON ARI.intInvoiceId = ARGID.intInvoiceId
LEFT JOIN tblARInvoice ARIR WITH (NOLOCK) ON ARI.intOriginalInvoiceId = ARIR.intInvoiceId
LEFT JOIN vyuARGetInvoiceDetail ARGIDP WITH (NOLOCK) ON ARGID.intOriginalInvoiceDetailId = ARGIDP.intInvoiceDetailId
LEFT JOIN vyuCTContractDetailView CTCDV WITH (NOLOCK) ON ARGID.intContractDetailId = CTCDV.intContractDetailId
LEFT JOIN tblICCommodity ICC WITH (NOLOCK) ON CTCDV.intCommodityId = ICC.intCommodityId
LEFT JOIN tblLGLoad LGL WITH (NOLOCK) ON ARGID.strDocumentNumber = LGL.strLoadNumber AND ISNULL(ARGID.intLoadDetailId, 0) <> 0 AND ISNULL(LGL.strBLNumber,'') <> ''
LEFT JOIN tblSMTerm SMT WITH (NOLOCK) ON ARI.intTermId = SMT.intTermID
LEFT JOIN tblCMBankAccount CMBA WITH (NOLOCK) ON ISNULL(ISNULL(ARI.intPayToCashBankAccountId, ARI.intDefaultPayToBankAccountId), 0) = CMBA.intBankAccountId
LEFT JOIN tblCMBank CMB WITH (NOLOCK) ON CMBA.intBankId = CMB.intBankId
LEFT JOIN tblSMLogoPreference SMLP ON SMLP.intCompanyLocationId = ARI.intCompanyLocationId AND (ysnARInvoice = 1 OR ysnDefault = 1)
LEFT JOIN tblSMLogoPreferenceFooter SMLPF ON SMLPF.intCompanyLocationId = ARI.intCompanyLocationId AND (SMLPF.ysnARInvoice = 1 OR SMLPF.ysnDefault = 1)
LEFT JOIN vyuLGLoadDetailLotsView LGLDLV WITH (NOLOCK) ON ARGID.intLoadDetailId = LGLDLV.intLoadDetailId
LEFT JOIN @temp_AdditionalItemDetail TAID ON ARGID.intInvoiceDetailId = TAID.intInvoiceDetailId 
WHERE ARI.intInvoiceId BETWEEN @intInvoiceIdFrom AND @intInvoiceIdTo 
OR ARI.intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@strInvoiceIds))
OR ARI.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo

EXEC dbo.uspARLogPerformanceRuntime 'Invoice Report', 'uspARInvoiceWalterMatterReport', @strReportLogId, 0, @intEntityUserId, @intPerformanceLogId, NULL