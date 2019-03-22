IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoiceDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intSubCurrencyId' AND [object_id] = OBJECT_ID(N'tblARInvoiceDetail'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoiceDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'dblSubCurrencyRate' AND [object_id] = OBJECT_ID(N'tblARInvoiceDetail')))
BEGIN
	UPDATE 
		ARI
	SET 
		ARI.intCurrencyId = C.intCurrencyId
	FROM 
		tblARInvoice ARI
	INNER JOIN 
		vyuARCustomerSearch C 
			ON ARI.intEntityCustomerId = C.intEntityCustomerId
	WHERE 
		ISNULL(ARI.intCurrencyId, 0) = 0
			
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


IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblSOSalesOrderDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intSubCurrencyId' AND [object_id] = OBJECT_ID(N'tblSOSalesOrderDetail'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblSOSalesOrderDetail') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'dblSubCurrencyRate' AND [object_id] = OBJECT_ID(N'tblSOSalesOrderDetail')))
BEGIN
	UPDATE 
		SO
	SET 
		SO.intCurrencyId = C.intCurrencyId
	FROM 
		tblSOSalesOrder SO
	INNER JOIN 
		vyuARCustomerSearch C 
			ON SO.intEntityCustomerId = C.intEntityCustomerId
	WHERE 
		ISNULL(SO.intCurrencyId, 0) = 0
	
	UPDATE
		SOSOD
	SET
		 SOSOD.[intSubCurrencyId]	= SO.[intCurrencyId]
		,SOSOD.[dblSubCurrencyRate]	= 1.000000
	FROM
		tblSOSalesOrderDetail SOSOD
	INNER JOIN
		tblSOSalesOrder SO
			ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]
	WHERE
		ISNULL(SOSOD.[intSubCurrencyId], 0) = 0
		OR ISNULL(SOSOD.[dblSubCurrencyRate], 0) = 0
END