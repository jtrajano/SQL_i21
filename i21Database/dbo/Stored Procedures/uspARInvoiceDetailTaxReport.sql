CREATE PROCEDURE [dbo].[uspARInvoiceDetailTaxReport]
	  @intEntityUserId		AS INT	= NULL
	, @strRequestId			AS NVARCHAR(MAX) = NULL
AS

DECLARE @intItemForFreightId	INT = (SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference)

DELETE FROM tblARInvoiceTaxReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein', 'Format 9 - Berry Oil','Format 10 - Berry Trucking','Format 11 - Newton Oil')
INSERT INTO tblARInvoiceTaxReportStagingTable (
	 [intTransactionId]
	,[intTransactionDetailId]
	,[intTransactionDetailTaxId]
	,[intTaxCodeId]
	,[intEntityUserId]
	,[strRequestId]
	,[strTaxTransactionType]
	,[strCalculationMethod]
	,[strTaxCode]
	,[strDescription]
	,[strTaxClass]
	,[strInvoiceFormat]
	,[strInvoiceType]
	,[dblAdjustedTax]
	,[dblRate]
	,[dblTaxPerQty]
	,[dblComputedGrossPrice]
	,[ysnIncludeInvoicePrice]
	,[strException]
)
SELECT 
	 [intTransactionId]			= ID.intInvoiceId
	,[intTransactionDetailId]	= IDT.intInvoiceDetailId
	,[intTransactionDetailTaxId]= IDT.intInvoiceDetailTaxId
	,[intTaxCodeId]				= IDT.intTaxCodeId
	,[intEntityUserId]			= @intEntityUserId
	,[strRequestId]				= @strRequestId
	,[strTaxTransactionType]	= 'Invoice' COLLATE Latin1_General_CI_AS
	,[strCalculationMethod]		= IDT.strCalculationMethod
	,[strTaxCode]				= SMTCode.strTaxCode
	,[strDescription]			= SMTCode.strDescription
	,[strTaxClass]				= SMTClass.strTaxClass	
	,[strInvoiceFormat]			= I.strInvoiceFormat
	,[strInvoiceType]			= I.strType
	,[dblAdjustedTax]			= IDT.dblAdjustedTax
	,[dblRate]					= IDT.dblRate
	,[dblTaxPerQty]				= CASE WHEN ISNULL(ID.dblQtyShipped, 0) <> 0 THEN IDT.dblAdjustedTax / ID.dblQtyShipped ELSE 0 END
	,[dblComputedGrossPrice]	= ISNULL(ID.dblComputedGrossPrice, 0)	
	,[ysnIncludeInvoicePrice]	= ISNULL(SMTCode.ysnIncludeInvoicePrice, 0)
	,strException				= CASE WHEN IDT.strException IS NULL THEN ISNULL(I.strTaxNumber, '') ELSE ISNULL(IDT.strException, '') END
FROM (
	SELECT
		 intInvoiceDetailTaxId
		,intInvoiceDetailId
		,intTaxCodeId
		,ysnTaxExempt
		,dblAdjustedTax
		,strCalculationMethod
		,dblRate
		,strException		= CASE WHEN ISNULL(ysnTaxExempt, 0) = 1 AND CHARINDEX('Tax Exemption > ', strNotes) > 0 
								THEN SUBSTRING(strNotes, CHARINDEX('-', strNotes) + 2, CHARINDEX('; Start Date:', strNotes) - CHARINDEX('-', strNotes) - 2)
								ELSE NULL
							  END
	FROM tblARInvoiceDetailTax
) IDT 	
INNER JOIN (
	SELECT
		 ARID.intInvoiceDetailId
		,ARID.intInvoiceId
		,ARID.intItemId
		,ARID.intItemCategoryId
		,ARID.dblQtyShipped
		,ARID.dblComputedGrossPrice
		,TMS.intSiteNumber
	FROM tblARInvoiceDetail ARID
	LEFT JOIN tblTMSite TMS ON ARID.intSiteId = TMS.intSiteID
) ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN (
	SELECT DISTINCT 
		 intInvoiceId
		,strInvoiceFormat
		,strType
		,intEntityCustomerId
		,dtmPostDate
		,strTaxNumber
	FROM tblARInvoiceReportStagingTable
	WHERE intEntityUserId = @intEntityUserId 
	AND strRequestId = @strRequestId 
	AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein', 'Format 9 - Berry Oil','Format 10 - Berry Trucking','Format 11 - Newton Oil')
) I ON ID.intInvoiceId = I.intInvoiceId
INNER JOIN tblSMTaxCode SMTCode ON IDT.intTaxCodeId = SMTCode.intTaxCodeId
INNER JOIN tblSMTaxClass SMTClass ON SMTCode.intTaxClassId = SMTClass.intTaxClassId	
WHERE (
	(IDT.ysnTaxExempt = 1 AND (ISNULL(I.strTaxNumber, '') <> '' OR ISNULL(IDT.strException, '') <> '')) 
	OR 
	(IDT.ysnTaxExempt = 0 AND IDT.dblAdjustedTax <> 0)
)
AND ID.intItemId <> ISNULL(@intItemForFreightId, 0)

UPDATE ARIRST
SET intHasTaxException = ARITRST.intHasTaxException
FROM tblARInvoiceReportStagingTable ARIRST
OUTER APPLY (
	SELECT intHasTaxException = COUNT(1)
	FROM tblARInvoiceTaxReportStagingTable
	WHERE intTransactionDetailId = ARIRST.intInvoiceDetailId
	AND strRequestId = ARIRST.strRequestId
	AND strException <> ''
) ARITRST
WHERE strRequestId = @strRequestId 