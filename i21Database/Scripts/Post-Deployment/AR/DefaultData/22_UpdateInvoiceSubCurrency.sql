IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoiceDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intSubCurrencyId' AND [object_id] = OBJECT_ID(N'tblARInvoiceDetail'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoiceDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'dblSubCurrencyRate' AND [object_id] = OBJECT_ID(N'tblARInvoiceDetail')))
BEGIN
		
	UPDATE
		ARID
	SET
		 ARID.[intSubCurrencyId]	= ARI.[intCurrencyId]
		,ARID.[dblSubCurrencyRate]	= 1.000000
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		tblARInvoice ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	WHERE
		ISNULL(ARID.[intSubCurrencyId], 0) = 0
		OR ISNULL(ARID.[dblSubCurrencyRate], 0) = 0
END