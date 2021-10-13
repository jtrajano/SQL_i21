PRINT '********************** START - DROP AR OLD INDEXES **********************'
GO

IF EXISTS (SELECT NULL FROM sys.tables WHERE [name] = N'tblARInvoice')
	BEGIN
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoice_strType' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [IX_tblARInvoice_strType] ON tblARInvoice
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoice_strTransactionType' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [IX_tblARInvoice_strTransactionType] ON tblARInvoice
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoice_ysnPosted' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [IX_tblARInvoice_ysnPosted] ON tblARInvoice
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoice_intOriginalInvoiceId' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [IX_tblARInvoice_intOriginalInvoiceId] ON tblARInvoice
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='PIndex' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [PIndex] ON tblARInvoice
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='PIndex2' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [PIndex2] ON tblARInvoice
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='PIndex_tblARInvoice_intEntityCustomerId_ysnForgiven' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [PIndex_tblARInvoice_intEntityCustomerId_ysnForgiven] ON tblARInvoice
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='PIndex_tblARInvoice_intEntityCustomerId_ysnPosted' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [PIndex_tblARInvoice_intEntityCustomerId_ysnPosted] ON tblARInvoice
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetail_[intInvoiceId' AND object_id = OBJECT_ID('tblARInvoice'))
			DROP INDEX [IX_tblARInvoiceDetail_[intInvoiceId] ON tblARInvoice
	END

IF EXISTS (SELECT NULL FROM sys.tables WHERE [name] = N'tblARInvoiceDetail')
	BEGIN
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='PIndex' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [PIndex] ON tblARInvoiceDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetail_strDocumentNumber' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [IX_tblARInvoiceDetail_strDocumentNumber] ON tblARInvoiceDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetail_intInventoryShipmentItemId' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [IX_tblARInvoiceDetail_intInventoryShipmentItemId] ON tblARInvoiceDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetail_intCustomerStorageId' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [IX_tblARInvoiceDetail_intCustomerStorageId] ON tblARInvoiceDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoice_intOriginalInvoiceId' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [IX_tblARInvoice_intOriginalInvoiceId] ON tblARInvoiceDetail		
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetail_forStockRebuild' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [IX_tblARInvoiceDetail_forStockRebuild] ON tblARInvoiceDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetail_intInventoryShipmentChargeId' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [IX_tblARInvoiceDetail_intInventoryShipmentChargeId] ON tblARInvoiceDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetail_intOriginalInvoiceDetailId' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [IX_tblARInvoiceDetail_intOriginalInvoiceDetailId] ON tblARInvoiceDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetail_[intInvoiceId' AND object_id = OBJECT_ID('tblARInvoiceDetail'))
			DROP INDEX [IX_tblARInvoiceDetail_[intInvoiceId] ON tblARInvoiceDetail
	END
    
IF EXISTS (SELECT NULL FROM sys.tables WHERE [name] = N'tblARInvoiceDetailTax')
	BEGIN
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetailTax_dblTax' AND object_id = OBJECT_ID('tblARInvoiceDetailTax'))
			DROP INDEX [IX_tblARInvoiceDetailTax_dblTax] ON tblARInvoiceDetailTax
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetailTax_intInvoiceDetailId' AND object_id = OBJECT_ID('tblARInvoiceDetailTax'))
			DROP INDEX [IX_tblARInvoiceDetailTax_intInvoiceDetailId] ON tblARInvoiceDetailTax
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARInvoiceDetailTax_intTaxCodeId' AND object_id = OBJECT_ID('tblARInvoiceDetailTax'))
			DROP INDEX [IX_tblARInvoiceDetailTax_intTaxCodeId] ON tblARInvoiceDetailTax
	END

IF EXISTS (SELECT NULL FROM sys.tables WHERE [name] = N'tblARPayment')
	BEGIN
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='NC_Index_tblARPayment' AND object_id = OBJECT_ID('tblARPayment'))
			DROP INDEX [NC_Index_tblARPayment] ON tblARPayment
	END

IF EXISTS (SELECT NULL FROM sys.tables WHERE [name] = N'tblARPaymentDetail')
	BEGIN
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblARPaymentDetail_intBillId' AND object_id = OBJECT_ID('tblARPaymentDetail'))
			DROP INDEX [IX_tblARPaymentDetail_intBillId] ON tblARPaymentDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='NC_Index_tblARPaymentDetail' AND object_id = OBJECT_ID('tblARPaymentDetail'))
			DROP INDEX [NC_Index_tblARPaymentDetail] ON tblARPaymentDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='PIndex_tblARPaymentDetail_intInvoiceId' AND object_id = OBJECT_ID('tblARPaymentDetail'))
			DROP INDEX [PIndex_tblARPaymentDetail_intInvoiceId] ON tblARPaymentDetail
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='PIndex_tblARPaymentDetail_intPaymentId' AND object_id = OBJECT_ID('tblARPaymentDetail'))
			DROP INDEX [PIndex_tblARPaymentDetail_intPaymentId] ON tblARPaymentDetail
	END

IF EXISTS (SELECT NULL FROM sys.tables WHERE [name] = N'tblSOSalesOrder')
	BEGIN
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblSOSalesOrder_strTransactionType_ysnQuote' AND object_id = OBJECT_ID('tblSOSalesOrder'))
			DROP INDEX [IX_tblSOSalesOrder_strTransactionType_ysnQuote] ON tblSOSalesOrder
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblSOSalesOrder_ysnProcessed' AND object_id = OBJECT_ID('tblSOSalesOrder'))
			DROP INDEX [IX_tblSOSalesOrder_ysnProcessed] ON tblSOSalesOrder
	END

IF EXISTS (SELECT NULL FROM sys.tables WHERE [name] = N'tblSOSalesOrderDetail')
	BEGIN
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblSOSalesOrderDetail_intSalesOrderId' AND object_id = OBJECT_ID('tblSOSalesOrderDetail'))
			DROP INDEX [IX_tblSOSalesOrderDetail_intSalesOrderId] ON tblSOSalesOrderDetail
	END

IF EXISTS (SELECT NULL FROM sys.tables WHERE [name] = N'tblSOSalesOrderDetailTax')
	BEGIN
		IF EXISTS (SELECT NULL FROM sys.indexes WHERE name='IX_tblSOSalesOrderDetailTax_dblAdjustedTax' AND object_id = OBJECT_ID('tblSOSalesOrderDetailTax'))
			DROP INDEX [IX_tblSOSalesOrderDetailTax_dblAdjustedTax] ON tblSOSalesOrderDetailTax
	END

PRINT '********************** END - DROP AR OLD INDEXES **********************'
GO