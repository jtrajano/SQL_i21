CREATE PROCEDURE [dbo].[uspARInvoiceWalterMatterReport]
	  @intEntityUserId		AS INT	= NULL
	, @strRequestId			AS NVARCHAR(MAX) = NULL
AS 

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
	,strBankName
	,strIBAN
	,strSWIFT
	,strBICCode
)
SELECT
	 intInvoiceId			= ARI.intInvoiceId
	,intInvoiceDetailId		= ARGID.intInvoiceDetailId
	,intEntityUserId		= @intEntityUserId
	,strInvoiceFormat		= SELECTEDINV.strInvoiceFormat
	,strRequestId			= @strRequestId
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
	,strQtyShipped			= FORMAT(ARGID.dblQtyShipped, '#,###.00') + ' ' + ARGID.strUnitMeasure
	,strShipmentGrossWt		= FORMAT(ARGID.dblShipmentGrossWt, '#,###.00') + ' ' + ARGID.strWeightUnitMeasure
	,strShipmentTareWt		= FORMAT(ARGID.dblShipmentTareWt, '#,###.00') + ' ' + ARGID.strWeightUnitMeasure
	,strShipmentNetWt		= FORMAT(ARGID.dblShipmentNetWt, '#,###.00') + ' ' + ARGID.strWeightUnitMeasure
	,strPrice				= ARGID.strCurrency + ' ' + FORMAT(ARGID.dblPrice, '#,###.00') + ' ' + ARGID.strPriceUnitMeasure
	,dblInvoiceTotal		= ARGID.dblTotal
	,strEDICode				= ICC.strEDICode
	,ysnCustomsReleased		= ISNULL(LGL.ysnCustomsReleased, 0)
	,strBOLNumber			= LGL.strBLNumber + ' dd ' + [dbo].[fnConvertDateToReportDateFormat](LGL.dtmBLDate, 0)
	,strDestinationCity		= LGL.strDestinationCity
	,strMVessel				= LGL.strMVessel
	,strPaymentComments		= ARI.strTradeFinanceComments
	,blbLogo                = @blbLogo
	,strBankName			= CMB.strBankName
	,strIBAN				= CMBA.strIBAN
	,strSWIFT				= CMBA.strSWIFT
	,strBICCode				= CMBA.strBICCode
FROM dbo.tblARInvoice ARI WITH (NOLOCK)
INNER JOIN #WALTERMATTERINVOICES SELECTEDINV ON ARI.intInvoiceId = SELECTEDINV.intInvoiceId
INNER JOIN vyuARCustomerSearch ARCS WITH (NOLOCK) ON ARI.intEntityCustomerId = ARCS.intEntityId
INNER JOIN tblSMCompanyLocation SMCL WITH (NOLOCK) ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId
LEFT JOIN vyuARGetInvoiceDetail ARGID WITH (NOLOCK) ON ARI.intInvoiceId = ARGID.intInvoiceId
LEFT JOIN vyuCTContractDetailView CTCDV WITH (NOLOCK) ON ARGID.intContractDetailId = CTCDV.intContractDetailId
LEFT JOIN tblICCommodity ICC WITH (NOLOCK) ON CTCDV.intCommodityId = ICC.intCommodityId
LEFT JOIN tblLGLoad LGL WITH (NOLOCK) ON ARGID.strDocumentNumber = LGL.strLoadNumber AND ISNULL(ARGID.intLoadDetailId, 0) <> 0 AND ISNULL(LGL.strBLNumber,'') <> ''
LEFT JOIN tblSMTerm SMT WITH (NOLOCK) ON ARI.intTermId = SMT.intTermID
LEFT JOIN tblCMBankAccount CMBA WITH (NOLOCK) ON ISNULL(ISNULL(ARI.intPayToCashBankAccountId, ARI.intDefaultPayToBankAccountId), 0) = CMBA.intBankAccountId
LEFT JOIN tblCMBank CMB WITH (NOLOCK) ON CMBA.intBankId = CMB.intBankId