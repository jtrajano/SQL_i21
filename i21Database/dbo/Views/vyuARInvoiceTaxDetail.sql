CREATE VIEW [dbo].[vyuARInvoiceTaxDetail]
	AS 
SELECT
	 CAST(DENSE_RANK() OVER(PARTITION BY I.intInvoiceId ORDER BY D.intInvoiceDetailId ASC) AS INT) AS [Item]
	,I.intInvoiceId
	,I.strInvoiceNumber 
	,E.strName 
	,D.intInvoiceDetailId 
	,D.intItemId 
	,IC.strItemNo
	,D.strItemDescription 
	,ITX.intInvoiceDetailTaxId 
	,ITX.intTaxCodeId 
	,TC.strTaxCode
	,ITX.strCalculationMethod 
	,ITX.dblRate
	,D.dblQtyShipped 
	,D.dblPrice 
	,D.dblTotal
	,ITX.ysnCheckoffTax 
	,ITX.ysnTaxExempt 
	,ITX.ysnTaxOnly 
	,ITX.dblTax 
	,ITX.dblAdjustedTax 
	,ITX.ysnTaxAdjusted
	,TG.strTaxGroup
	,ITX.strNotes
FROM
	tblARInvoiceDetailTax ITX
INNER JOIN
	tblARInvoiceDetail D
		ON ITX.intInvoiceDetailId = D.intInvoiceDetailId
INNER JOIN
	tblARInvoice I
		ON D.intInvoiceId = I.intInvoiceId
LEFT OUTER JOIN
	tblEMEntity E
		ON I.intEntityCustomerId = E.intEntityId 
LEFT OUTER JOIN
	tblICItem IC
		ON D.intItemId = IC.intItemId 
LEFT OUTER JOIN
	tblSMTaxCode TC
		ON ITX.intTaxCodeId = TC.intTaxCodeId
LEFT OUTER JOIN
	tblSMTaxGroup TG
		ON ITX.intTaxGroupId = TG.intTaxGroupId 
