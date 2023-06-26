CREATE VIEW [dbo].[vyuSCGrainBankInvoiceTransaction]
	AS

	WITH cte AS (

		SELECT 
			DISTINCT 
			STORAGE.intEntityId 			
			, STORAGE.intStorageTypeId 
			, STORAGE.intStorageScheduleId
			, STORAGE.intItemId
			, HISTORY.intInvoiceId
			, HISTORY.intTransactionTypeId
		FROM tblGRCustomerStorage STORAGE
			JOIN tblGRStorageType STORAGE_TYPE 
				ON STORAGE.intStorageTypeId = STORAGE_TYPE.intStorageScheduleTypeId
					AND STORAGE_TYPE.ysnGrainBankType = 1
			JOIN tblGRStorageHistory HISTORY
				ON STORAGE.intCustomerStorageId = HISTORY.intCustomerStorageId
		WHERE HISTORY.intTransactionTypeId = 6

	)

	SELECT 
	'INVOICE' AS strMode
	, STORAGE.intTransactionTypeId
	, INVOICE.strInvoiceNumber AS strTransactionId
	, 'INVOICE' AS strTransactionType
	, INVOICE.dtmDate AS dtmTransactionDate



	, STORAGE.intEntityId 
	, NULL AS intCustomerStorageId 
	, STORAGE.intStorageTypeId 
	, NULL AS intStorageHistoryId  
	, INVOICE_DETAIL.dblTotal
	, STORAGE.intStorageScheduleId
	, STORAGE.intItemId
	, INVOICE_DETAIL.strItemDescription 
	FROM cte  STORAGE				
		JOIN tblARInvoice INVOICE
			ON STORAGE.intInvoiceId = INVOICE.intInvoiceId
		JOIN tblARInvoiceDetail INVOICE_DETAIL
			ON INVOICE.intInvoiceId = INVOICE_DETAIL.intInvoiceId
				AND STORAGE.intItemId <> INVOICE_DETAIL.intItemId
	
		/*
		STORAGE.intEntityId = @ENTITY_ID
		AND STORAGE.intStorageTypeId = @STORAGE_SCHEDULE_TYPE_ID		
		AND STORAGE.intCustomerStorageId = @CUSTOMER_STORAGE
		*/

GO