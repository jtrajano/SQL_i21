CREATE PROCEDURE [dbo].[uspARInvoiceDetailTaxReport]
	  @intEntityUserId		AS INT	= NULL
	, @strRequestId			AS NVARCHAR(MAX) = NULL
AS

DECLARE @intItemForFreightId	INT = (SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference)

DELETE FROM tblARInvoiceTaxReportStagingTable WHERE intEntityUserId = @intEntityUserId AND strRequestId = @strRequestId AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein')
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
	, [strException]				= CASE WHEN CHARINDEX('Tax Exemption > ', IDT.strNotes) > 0 
										  THEN SUBSTRING(IDT.strNotes, CHARINDEX('-', IDT.strNotes) + 2, CHARINDEX('; Start Date:', IDT.strNotes) - CHARINDEX('-', IDT.strNotes) - 2)
										  ELSE strNotes
									  END
FROM tblARInvoiceDetailTax IDT 	
INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN (
	SELECT DISTINCT intInvoiceId
				  , strInvoiceFormat
				  , strType
				  , intEntityCustomerId
	FROM tblARInvoiceReportStagingTable
	WHERE intEntityUserId = @intEntityUserId 
	AND strRequestId = @strRequestId 
	AND strInvoiceFormat NOT IN ('Format 1 - MCP', 'Format 5 - Honstein')
) I ON ID.intInvoiceId = I.intInvoiceId --AND IDT.intTaxCodeId = I.intTaxCodeId
INNER JOIN tblSMTaxCode SMT ON IDT.intTaxCodeId = SMT.intTaxCodeId
INNER JOIN tblSMTaxClass TC ON SMT.intTaxClassId = TC.intTaxClassId	
WHERE ((IDT.ysnTaxExempt = 1) OR (IDT.ysnTaxExempt = 0 AND IDT.dblAdjustedTax <> 0))
	AND ID.intItemId <> ISNULL(@intItemForFreightId, 0)