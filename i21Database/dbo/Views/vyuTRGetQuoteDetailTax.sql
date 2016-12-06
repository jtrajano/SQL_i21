CREATE VIEW [dbo].[vyuTRGetQuoteDetailTax]
	AS
	
SELECT intQuoteDetailId
	, strTaxCode = ISNULL(QD.strTaxCode, TaxCode.strTaxCode)
	, dblAdjustedTax
FROM tblTRQuoteDetailTax QD
LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = QD.intTaxCodeId