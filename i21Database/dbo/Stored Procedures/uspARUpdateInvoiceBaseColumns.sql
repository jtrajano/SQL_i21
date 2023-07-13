CREATE PROCEDURE dbo.uspARUpdateInvoiceBaseColumns
	 @InvoiceIds	Id READONLY
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

UPDATE tblARInvoice
SET
	 dblBaseInvoiceSubtotal				= dbo.fnRoundBanker(dblInvoiceSubtotal * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseShipping					= dbo.fnRoundBanker(dblShipping * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseTax							= dbo.fnRoundBanker(dblTax * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseInvoiceTotal				= dbo.fnRoundBanker(dblInvoiceTotal * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseDiscount					= dbo.fnRoundBanker(dblDiscount * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseDiscountAvailable			= dbo.fnRoundBanker(dblDiscountAvailable * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseTotalTermDiscount			= dbo.fnRoundBanker(dblTotalTermDiscount * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseTotalTermDiscountExemption	= dbo.fnRoundBanker(dblTotalTermDiscountExemption * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseInterest					= dbo.fnRoundBanker(dblInterest * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseAmountDue					= dbo.fnRoundBanker(dblAmountDue * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBasePayment						= dbo.fnRoundBanker(dblPayment * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseProvisionalAmount			= dbo.fnRoundBanker(dblProvisionalAmount * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseRoundingTotal				= dbo.fnRoundBanker(dblRoundingTotal * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
WHERE intInvoiceId IN (
	SELECT intId
	FROM @InvoiceIds
)

UPDATE tblARInvoiceDetail
SET
	 dblBaseItemTermDiscountAmount		= dbo.fnRoundBanker(dblItemTermDiscountAmount * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseItemTermDiscountExemption	= dbo.fnRoundBanker(dblItemTermDiscountExemption * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBasePrice						= dbo.fnRoundBanker(dblPrice * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseUnitPrice					= dbo.fnRoundBanker(dblUnitPrice * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseOriginalGrossPrice			= dbo.fnRoundBanker(dblOriginalGrossPrice * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseComputedGrossPrice			= dbo.fnRoundBanker(dblComputedGrossPrice * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseTotalTax					= dbo.fnRoundBanker(dblTotalTax * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseTotal						= dbo.fnRoundBanker(dblTotal * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseMaintenanceAmount			= dbo.fnRoundBanker(dblMaintenanceAmount * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseLicenseAmount				= dbo.fnRoundBanker(dblLicenseAmount * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseRebateAmount				= dbo.fnRoundBanker(dblRebateAmount * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseBuybackAmount				= dbo.fnRoundBanker(dblBuybackAmount * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseRounding					= dbo.fnRoundBanker(dblRounding * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseProvisionalTotalTax			= dbo.fnRoundBanker(dblProvisionalTotalTax * dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
WHERE intInvoiceId IN (
	SELECT intId
	FROM @InvoiceIds
)

UPDATE ARIDT
SET
	 dblBaseRate		= dbo.fnRoundBanker(dblRate * ARID.dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
	,dblBaseAdjustedTax	= dbo.fnRoundBanker(dblAdjustedTax * ARID.dblCurrencyExchangeRate, dbo.fnARGetDefaultDecimal())
FROM tblARInvoiceDetailTax ARIDT
INNER JOIN tblARInvoiceDetail ARID
	ON ARIDT.intInvoiceDetailId = ARID.intInvoiceDetailId
WHERE ARID.intInvoiceId IN (
	SELECT intId
	FROM @InvoiceIds
)