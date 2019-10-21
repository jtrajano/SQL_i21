﻿CREATE VIEW [dbo].[vyuARTaxDetailMeterBillingReport]
AS
SELECT intInvoiceId			= I.intInvoiceId
	 , intInvoiceDetailId	= ID.intInvoiceDetailId
	 , strTaxCode			= NULL
	 , dblQtyShipped		= ID.dblQtyShipped * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
	 , strUnitMeasure		= UM.strUnitMeasure
	 , strSymbol			= UM.strSymbol
	 , dblTaxUnitPrice		= CASE WHEN ISNULL(ID.dblQtyShipped, 0) > 0 THEN dbo.fnRoundBanker((ISNULL(ID.dblTotal, 0) / ID.dblQtyShipped), 6) ELSE 0.000000 END
	 , dblExtended			= ID.dblTotal * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
FROM tblARInvoice I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
LEFT JOIN tblICItemUOM IUOM ON ID.intItemUOMId = IUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON IUOM.intUnitMeasureId = UM.intUnitMeasureId

UNION ALL

SELECT intInvoiceId			= I.intInvoiceId
	 , intInvoiceDetailId	= ID.intInvoiceDetailId
	 , strTaxCode			= TC.strTaxCode
	 , dblQtyShipped		= ID.dblQtyShipped * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
	 , strUnitMeasure		= UM.strUnitMeasure
	 , strSymbol			= UM.strSymbol
	 , dblTaxUnitPrice		= CASE WHEN ISNULL(ID.dblQtyShipped, 0) > 0 THEN dbo.fnRoundBanker((ISNULL(IDT.dblAdjustedTax, 0) / ID.dblQtyShipped), 6) ELSE 0.000000 END
	 , dblExtended			= IDT.dblAdjustedTax * dbo.fnARGetInvoiceAmountMultiplier(I.strTransactionType)
FROM tblARInvoice I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN tblARInvoiceDetailTax IDT ON ID.intInvoiceDetailId = IDT.intInvoiceDetailId
INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
LEFT JOIN tblICItemUOM IUOM ON ID.intItemUOMId = IUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON IUOM.intUnitMeasureId = UM.intUnitMeasureId
WHERE ISNULL(IDT.dblAdjustedTax, 0) <> 0