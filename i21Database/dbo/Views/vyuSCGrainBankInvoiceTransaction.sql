CREATE VIEW [dbo].[vyuSCGrainBankInvoiceTransaction]
	AS



	SELECT 
	'INVOICE' AS strMode
	, HISTORY.intTransactionTypeId
	, INVOICE.strInvoiceNumber AS strTransactionId
	, 'INVOICE' AS strTransactionType
	, INVOICE.dtmDate AS dtmTransactionDate



	, STORAGE.intEntityId 
	, STORAGE.intCustomerStorageId 
	, STORAGE.intStorageTypeId 
	, HISTORY.intStorageHistoryId
	, INVOICE_DETAIL.dblTotal
	, STORAGE.intStorageScheduleId
	, STORAGE.intItemId
	, INVOICE_DETAIL.strItemDescription 
	FROM tblGRCustomerStorage  STORAGE
		JOIN tblGRStorageHistory HISTORY
			ON STORAGE.intCustomerStorageId = HISTORY.intCustomerStorageId
		JOIN tblARInvoice INVOICE
			ON HISTORY.intInvoiceId = INVOICE.intInvoiceId
		JOIN tblARInvoiceDetail INVOICE_DETAIL
			ON INVOICE.intInvoiceId = INVOICE_DETAIL.intInvoiceId
				AND STORAGE.intItemId <> INVOICE_DETAIL.intItemId

	WHERE HISTORY.intTransactionTypeId = 6
		AND HISTORY.ysnPost = 1
		
		/*
		STORAGE.intEntityId = @ENTITY_ID
		AND STORAGE.intStorageTypeId = @STORAGE_SCHEDULE_TYPE_ID		
		AND STORAGE.intCustomerStorageId = @CUSTOMER_STORAGE
		*/

GO