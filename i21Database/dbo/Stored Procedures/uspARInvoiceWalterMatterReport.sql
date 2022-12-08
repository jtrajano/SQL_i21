CREATE PROCEDURE [dbo].[uspARInvoiceWalterMatterReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS 

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE  @blbLogo				VARBINARY (MAX)  = NULL
		,@strCompanyName		NVARCHAR(200) = NULL
		,@strCompanyFullAddress	NVARCHAR(500) = NULL

--LOGO
SELECT TOP 1 @blbLogo = imgLogo 
FROM tblSMLogoPreference
WHERE ysnARInvoice = 1
OR ysnDefault = 1
ORDER BY ysnARInvoice DESC

SELECT TOP 1 @strCompanyFullAddress	= strAddress + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(', ' + NULLIF(strZip, ''), '') + ISNULL(', ' + NULLIF(strCountry, ''), '')
		   , @strCompanyName		= strCompanyName
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

DELETE FROM tblARInvoiceReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat = 'Format 7 - Walter Matter'
INSERT INTO tblARInvoiceReportStagingTable (
	 intInvoiceId
	,intInvoiceDetailId
	,intEntityUserId
	,strInvoiceFormat
	,strRequestId
	,strCompanyName
	,strCompanyAddress
	,strInvoiceNumber
	,strCustomerName
	,strLocationName
	,strContractNumber
	,strOrigin
	,strFreightTerm
	,strWeight
	,strCustomerReference
	,strFLOId
	,strGrade
	,dtmDueDate
	,strTerm
	,strItemDescription
	,strQtyShipped
	,strShipmentGrossWt
	,strShipmentTareWt
	,strShipmentNetWt
	,strPrice
	,dblInvoiceTotal
	,strEDICode
	,ysnCustomsReleased
	,strBOLNumber
	,strDestinationCity
	,strMVessel
	,strPaymentComments
	,blbLogo
)
SELECT
	 intInvoiceId			= ARI.intInvoiceId
	,intInvoiceDetailId		= ISNULL(ARGID.intInvoiceDetailId, 0)
	,strCompanyName			= @strCompanyName
	,strCompanyAddress		= @strCompanyFullAddress
	,strInvoiceNumber		= ARI.strInvoiceNumber
	,strCustomerName		= ARCS.strName
	,strLocationName		= SMCL.strLocationName + ',' +  + [dbo].[fnConvertDateToReportDateFormat](ARI.dtmDate, 0)
	,strContractNumber		= CTCDV.strContractNumber + '-' + CAST(CTCDV.intContractSeq AS NVARCHAR(100)) + ' dated ' + [dbo].[fnConvertDateToReportDateFormat](CTCDV.dtmContractDate, 0)
	,strOrigin				= CTCDV.strItemOrigin
	,strFreightTerm			= CTCDV.strFreightTerm
	,strWeight				= CTCDV.strWeight
	,strCustomerReference	= CTCDV.strCustomerContract
	,strFLOId				= ARCS.strFLOId
	,strGrade				= CTCDV.strGrade
	,dtmDueDate				= CAST(ARI.dtmDueDate AS DATE)
	,strTerm				= SMT.strTerm
	,strItemDescription		= ARGID.strItemDescription
	,strQtyShipped			= CONVERT(VARCHAR,CAST(ARGID.dblQtyShipped AS MONEY),1) + ' ' + ARGID.strUnitMeasure
	,strShipmentGrossWt		= CONVERT(VARCHAR,CAST(ARGID.dblShipmentGrossWt AS MONEY),1) + ' ' + ARGID.strWeightUnitMeasure
	,strShipmentTareWt		= CONVERT(VARCHAR,CAST(ARGID.dblShipmentTareWt AS MONEY),1) + ' ' + ARGID.strWeightUnitMeasure
	,strShipmentNetWt		= CONVERT(VARCHAR,CAST(ARGID.dblShipmentNetWt AS MONEY),1) + ' ' + ARGID.strWeightUnitMeasure
	,strCurrenyPriceUOM		= ARGID.strCurrency + ' ' + REPLACE(CONVERT(VARCHAR,CAST(ARGID.dblPrice AS MONEY),1), '.00','') + ' ' + ARGID.strPriceUnitMeasure
	,dblTotal				= ARGID.dblTotal
	,strEDICode				= ICC.strEDICode
	,ysnCustomsReleased		= ISNULL(LGL.ysnCustomsReleased, 0)
	,strBOLNumber			= LGL.strBLNumber + ' dd ' + [dbo].[fnConvertDateToReportDateFormat](LGL.dtmBLDate, 0)
	,strDestinationCity		= LGL.strDestinationCity
	,strMVessel				= LGL.strMVessel
	,strPaymentComments		= ARI.strTradeFinanceComments
	,blbLogo                = @blbLogo
FROM dbo.tblARInvoice ARI WITH (NOLOCK)
INNER JOIN vyuARCustomerSearch ARCS WITH (NOLOCK) ON ARI.intEntityCustomerId = ARCS.intEntityId 
INNER JOIN tblSMCompanyLocation SMCL WITH (NOLOCK) ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId
LEFT JOIN vyuARGetInvoiceDetail ARGID WITH (NOLOCK) ON ARI.intInvoiceId = ARGID.intInvoiceId
LEFT JOIN vyuCTContractDetailView CTCDV WITH (NOLOCK) ON ARGID.intContractDetailId = CTCDV.intContractDetailId
LEFT JOIN tblICCommodity ICC WITH (NOLOCK) ON CTCDV.intCommodityId = ICC.intCommodityId
LEFT JOIN tblLGLoad LGL WITH (NOLOCK) ON ARGID.strDocumentNumber = LGL.strLoadNumber AND ISNULL(ARGID.intLoadDetailId, 0) <> 0 AND ISNULL(LGL.strBLNumber,'') <> ''
LEFT JOIN tblSMTerm SMT WITH (NOLOCK) ON ARI.intTermId = SMT.intTermID
