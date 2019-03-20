print('/*******************  BEGIN Update Tax Detail Isvalid Setup  *******************/')
GO

UPDATE
	tblARInvoiceDetailTax
SET
	ysnInvalidSetup = 1
WHERE
	ISNULL(strNotes,'') <> ''
	AND ISNULL(ysnTaxExempt,0) = 1
	AND ISNULL(ysnInvalidSetup,0) = 0
	AND (
		CHARINDEX('Invalid ', ISNULL(strNotes,'')) > 0
		OR
		CHARINDEX('is not included in Item Category', ISNULL(strNotes,'')) > 0
		OR
		CHARINDEX('Tax Class - ', ISNULL(strNotes,'')) > 0
		OR
		CHARINDEX('No Valid Tax Code Detail!', ISNULL(strNotes,'')) > 0
		)


UPDATE
	tblSOSalesOrderDetailTax
SET
	ysnInvalidSetup = 1
WHERE
	ISNULL(strNotes,'') <> ''
	AND ISNULL(ysnTaxExempt,0) = 1
	AND ISNULL(ysnInvalidSetup,0) = 0
	AND (
		CHARINDEX('Invalid ', ISNULL(strNotes,'')) > 0
		OR
		CHARINDEX('is not included in Item Category', ISNULL(strNotes,'')) > 0
		OR
		CHARINDEX('Tax Class - ', ISNULL(strNotes,'')) > 0
		OR
		CHARINDEX('No Valid Tax Code Detail!', ISNULL(strNotes,'')) > 0
		)
			
GO
print('/*******************  END Update Tax Detail Isvalid Setup  *******************/')

print('/******************* BEGIN Update Tax Detail TaxExempt for CF Tran *******************/')
GO

UPDATE IDT
SET ysnTaxExempt = 1
FROM tblARInvoiceDetailTax IDT
INNER JOIN tblARInvoiceDetail ID ON ID.intInvoiceDetailId=IDT.intInvoiceDetailId
INNER JOIN tblARInvoice I ON I.intInvoiceId=ID.intInvoiceId
WHERE ISNULL(IDT.dblTax, 0) = 0 
  AND ISNULL(IDT.dblRate, 0) <> 0 
  AND ISNULL(IDT.ysnTaxExempt, 0) = 0 
  AND I.strType='CF Tran'

GO
print('/******************* END Update Tax Detail TaxExempt for CF Tran *******************/')