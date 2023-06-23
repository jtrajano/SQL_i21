CREATE PROCEDURE [dbo].[uspARInvoiceDetailTaxReport]
	  @intEntityUserId		AS INT	= NULL
	, @strRequestId			AS NVARCHAR(MAX) = NULL
AS

DECLARE @intItemForFreightId	INT = (SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference)

DELETE FROM tblARInvoiceTaxReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein', 'Format 9 - Berry Oil','Format 10 - Berry Trucking')
INSERT INTO tblARInvoiceTaxReportStagingTable (
	  [intTransactionId]
	, [intTransactionDetailId]
	, [intTransactionDetailTaxId]
	, [intTaxCodeId]
	, [intEntityUserId]
	, [strRequestId]
	, [strTaxTransactionType]
	, [strCalculationMethod]
	, [strTaxCode]
	, [strDescription]
	, [strTaxClass]
	, [strInvoiceFormat]
	, [strInvoiceType]
	, [dblAdjustedTax]
	, [dblRate]
	, [dblTaxPerQty]
	, [dblComputedGrossPrice]
	, [ysnIncludeInvoicePrice]
	, [strException]
)
SELECT [intTransactionId]			= ID.intInvoiceId
	, [intTransactionDetailId]		= IDT.intInvoiceDetailId
	, [intTransactionDetailTaxId]	= IDT.intInvoiceDetailTaxId
	, [intTaxCodeId]				= IDT.intTaxCodeId
	, [intEntityUserId]				= @intEntityUserId
	, [strRequestId]				= @strRequestId
	, [strTaxTransactionType]		= 'Invoice' COLLATE Latin1_General_CI_AS
	, [strCalculationMethod]		= IDT.strCalculationMethod
	, [strTaxCode]					= SMT.strTaxCode
	, [strDescription]				= SMT.strDescription
	, [strTaxClass]					= TC.strTaxClass	
	, [strInvoiceFormat]			= I.strInvoiceFormat
	, [strInvoiceType]				= I.strType
	, [dblAdjustedTax]				= IDT.dblAdjustedTax
	, [dblRate]						= IDT.dblRate
	, [dblTaxPerQty]				= CASE WHEN ISNULL(ID.dblQtyShipped, 0) <> 0 THEN IDT.dblAdjustedTax / ID.dblQtyShipped ELSE 0 END
	, [dblComputedGrossPrice]		= ISNULL(ID.dblComputedGrossPrice, 0)	
	, [ysnIncludeInvoicePrice]		= ISNULL(SMT.ysnIncludeInvoicePrice, 0)
	, [strException]				= CASE WHEN ISNULL(IDT.ysnTaxExempt, 0) = 1 THEN ISNULL(ARCTTE.strException, '') ELSE '' END
FROM tblARInvoiceDetailTax IDT 	
INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN (
	SELECT DISTINCT intInvoiceId
				  , strInvoiceFormat
				  , strType
				  , intEntityCustomerId
				  , dtmPostDate
	FROM tblARInvoiceReportStagingTable
	WHERE intEntityUserId = @intEntityUserId 
	AND strRequestId = @strRequestId 
	AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein', 'Format 9 - Berry Oil','Format 10 - Berry Trucking')
) I ON ID.intInvoiceId = I.intInvoiceId
INNER JOIN tblSMTaxCode SMT ON IDT.intTaxCodeId = SMT.intTaxCodeId
INNER JOIN tblSMTaxClass TC ON SMT.intTaxClassId = TC.intTaxClassId	
OUTER APPLY (
	SELECT TOP 1 strException
	FROM tblARCustomerTaxingTaxException
	WHERE intEntityCustomerId = I.intEntityCustomerId
	AND ((I.dtmPostDate >= dtmStartDate AND dtmEndDate IS NULL) OR (I.dtmPostDate BETWEEN dtmStartDate AND dtmEndDate))
	AND (
		(intTaxCodeId = SMT.intTaxCodeId AND intTaxClassId = TC.intTaxClassId) 
		OR
		(ISNULL(intTaxCodeId, 0) = 0 AND intTaxClassId = TC.intTaxClassId)
		OR
		(intTaxCodeId = SMT.intTaxCodeId AND ISNULL(intTaxClassId, 0) = 0)
		OR
		(ISNULL(intTaxCodeId, 0) = 0 AND ISNULL(intTaxClassId, 0) = 0 AND ISNULL(intItemCategoryId, 0) = ID.intItemCategoryId)
		OR
		(ISNULL(intTaxCodeId, 0) = 0 AND ISNULL(intTaxClassId, 0) = 0 AND ISNULL(intItemCategoryId, 0) = 0 AND ISNULL(intItemId, 0) = ID.intItemId)
	)
	ORDER BY intTaxCodeId DESC, intTaxClassId DESC, dtmStartDate DESC, dtmEndDate DESC, intEntityCustomerLocationId DESC, intItemId DESC, intCategoryId DESC
) ARCTTE
WHERE (
	(IDT.ysnTaxExempt = 1 AND ISNULL(ARCTTE.strException, '') <> '') 
	OR 
	(IDT.ysnTaxExempt = 0 AND IDT.dblAdjustedTax <> 0)
)
AND ID.intItemId <> ISNULL(@intItemForFreightId, 0)