PRINT '********************** BEGIN Fix Invoice and Sales Order Number Unique Constraint **********************'
GO
IF (EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblARInvoice')
	AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'strInvoiceNumber' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
)
	BEGIN
		IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
		BEGIN
			DROP TABLE #INVOICES
		END

		SELECT strInvoiceNumber
			 , intRowId = ROW_NUMBER() OVER(PARTITION BY strInvoiceNumber ORDER BY intInvoiceId ASC)
			 , intInvoiceId
		INTO #INVOICES
		FROM tblARInvoice
		WHERE strInvoiceNumber IN (
			SELECT strInvoiceNumber
			FROM tblARInvoice
			GROUP BY strInvoiceNumber
			HAVING COUNT(*) > 1
		)

		IF EXISTS(SELECT TOP 1 NULL FROM #INVOICES)	
			BEGIN
				UPDATE I
				SET strInvoiceNumber = I.strInvoiceNumber + ' - DUP: ' + CONVERT(NVARCHAR(20), DUPLICATE.intRowId)
				FROM tblARInvoice I
				INNER JOIN #INVOICES DUPLICATE ON I.intInvoiceId = DUPLICATE.intInvoiceId
				AND I.strInvoiceNumber = DUPLICATE.strInvoiceNumber
				WHERE DUPLICATE.intRowId > 1
			END
	END

IF (EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblSOSalesOrder')
	AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'strSalesOrderNumber' AND [object_id] = OBJECT_ID(N'tblSOSalesOrder'))
)
	BEGIN
		IF(OBJECT_ID('tempdb..#SALESORDERS') IS NOT NULL)
		BEGIN
			DROP TABLE #SALESORDERS
		END

		SELECT strSalesOrderNumber
			 , intRowId = ROW_NUMBER() OVER(PARTITION BY strSalesOrderNumber ORDER BY intSalesOrderId ASC)
			 , intSalesOrderId
		INTO #SALESORDERS
		FROM tblSOSalesOrder
		WHERE strSalesOrderNumber IN (
			SELECT strSalesOrderNumber
			FROM tblSOSalesOrder
			GROUP BY strSalesOrderNumber
			HAVING COUNT(*) > 1
		)

		IF EXISTS(SELECT TOP 1 NULL FROM #SALESORDERS)	
			BEGIN
				UPDATE SO
				SET strSalesOrderNumber = SO.strSalesOrderNumber + ' - DUP: ' + CONVERT(NVARCHAR(20), DUPLICATE.intRowId)
				FROM tblSOSalesOrder SO
				INNER JOIN #SALESORDERS DUPLICATE ON SO.intSalesOrderId = DUPLICATE.intSalesOrderId
				AND SO.strSalesOrderNumber = DUPLICATE.strSalesOrderNumber
				WHERE DUPLICATE.intRowId > 1
			END
	END
GO
PRINT ' ********************** END Fix Invoice and Sales Order Number Unique Constraint **********************'