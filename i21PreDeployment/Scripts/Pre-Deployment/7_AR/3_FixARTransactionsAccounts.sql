IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblGLAccount') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intAccountId' AND [object_id] = OBJECT_ID(N'tblGLAccount')))
BEGIN
	IF (EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice'))
	BEGIN	
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intAccountId' AND [object_id] = OBJECT_ID(N'tblARInvoice')))
			EXEC('UPDATE tblARInvoice SET tblARInvoice.intAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblARInvoice.intAccountId)');			
	END
	
	IF (EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoiceDetail'))
	BEGIN	
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intAccountId' AND [object_id] = OBJECT_ID(N'tblARInvoiceDetail')))
			EXEC('UPDATE tblARInvoiceDetail SET tblARInvoiceDetail.intAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblARInvoiceDetail.intAccountId)');			
			
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intCOGSAccountId' AND [object_id] = OBJECT_ID(N'tblARInvoiceDetail')))
			EXEC('UPDATE tblARInvoiceDetail SET tblARInvoiceDetail.intCOGSAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblARInvoiceDetail.intCOGSAccountId)');						
			
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intSalesAccountId' AND [object_id] = OBJECT_ID(N'tblARInvoiceDetail')))
			EXEC('UPDATE tblARInvoiceDetail SET tblARInvoiceDetail.intSalesAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblARInvoiceDetail.intSalesAccountId)');									
			
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intInventoryAccountId' AND [object_id] = OBJECT_ID(N'tblARInvoiceDetail')))
			EXEC('UPDATE tblARInvoiceDetail SET tblARInvoiceDetail.intInventoryAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblARInvoiceDetail.intInventoryAccountId)');												
	END
	
	IF (EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARPayment'))
	BEGIN	
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intAccountId' AND [object_id] = OBJECT_ID(N'tblARPayment')))
			EXEC('UPDATE tblARPayment SET tblARPayment.intAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblARPayment.intAccountId)');			
	END	
	
	IF (EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARPaymentDetail'))
	BEGIN	
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intAccountId' AND [object_id] = OBJECT_ID(N'tblARPaymentDetail')))
			EXEC('UPDATE tblARPaymentDetail SET tblARPaymentDetail.intAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblARPaymentDetail.intAccountId)');			
	END
	
	IF (EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblSOSalesOrder'))
	BEGIN	
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intAccountId' AND [object_id] = OBJECT_ID(N'tblSOSalesOrder')))
			EXEC('UPDATE tblSOSalesOrder SET tblSOSalesOrder.intAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblSOSalesOrder.intAccountId)');			
	END
	
	IF (EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblSOSalesOrderDetail'))
	BEGIN	
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intAccountId' AND [object_id] = OBJECT_ID(N'tblSOSalesOrderDetail')))
			EXEC('UPDATE tblSOSalesOrderDetail SET tblSOSalesOrderDetail.intAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblSOSalesOrderDetail.intAccountId)');			
			
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intCOGSAccountId' AND [object_id] = OBJECT_ID(N'tblSOSalesOrderDetail')))
			EXEC('UPDATE tblSOSalesOrderDetail SET tblSOSalesOrderDetail.intCOGSAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblSOSalesOrderDetail.intCOGSAccountId)');						
			
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intSalesAccountId' AND [object_id] = OBJECT_ID(N'tblSOSalesOrderDetail')))
			EXEC('UPDATE tblSOSalesOrderDetail SET tblSOSalesOrderDetail.intSalesAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblSOSalesOrderDetail.intSalesAccountId)');									
			
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intInventoryAccountId' AND [object_id] = OBJECT_ID(N'tblSOSalesOrderDetail')))
			EXEC('UPDATE tblSOSalesOrderDetail SET tblSOSalesOrderDetail.intInventoryAccountId = NULL WHERE NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = tblSOSalesOrderDetail.intInventoryAccountId)');												
	END	
END