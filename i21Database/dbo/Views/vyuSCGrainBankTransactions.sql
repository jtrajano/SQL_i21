CREATE VIEW [dbo].[vyuSCGrainBankTransactions]
	AS 

	SELECT 
	'TICKET' AS strMode
	, HISTORY.intTransactionTypeId
	, TICKET.strTicketNumber AS strTransactionId
	, TICKET.strDistributionOption AS strTransactionType
	, TICKET.dtmTicketDateTime AS dtmTransactionDate


	, STORAGE.intEntityId
	, STORAGE.intCustomerStorageId 
	, STORAGE.intStorageTypeId 
	, HISTORY.intStorageHistoryId

	, case when GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId is not null and 
			GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId != UOM.intUnitMeasureId then
			round(dbo.fnGRConvertQuantityToTargetItemUOM(
									TICKET.intItemId
									, UOM.intUnitMeasureId
									, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
									, HISTORY.dblUnits) , 4)
		else
			HISTORY.dblUnits
		end as dblUnits
		

	, STORAGE.intStorageScheduleId
	, STORAGE.intItemId
	, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
	FROM tblGRCustomerStorage  STORAGE
		JOIN tblGRStorageHistory HISTORY
			ON STORAGE.intCustomerStorageId = HISTORY.intCustomerStorageId
		JOIN tblSCTicket TICKET
			ON HISTORY.intTicketId = TICKET.intTicketId
		JOIN tblICItemUOM ITEM_UOM
					on TICKET.intItemUOMIdTo = ITEM_UOM.intItemUOMId
						and TICKET.intItemId = ITEM_UOM.intItemId
		
		JOIN tblICUnitMeasure UOM
				on ITEM_UOM.intUnitMeasureId = UOM.intUnitMeasureId
		OUTER APPLY(
			SELECT intGrainBankUnitMeasureId FROM tblGRCompanyPreference
		) GR_COMPANY_PREFERENCE

	WHERE 
		HISTORY.intTransactionTypeId = 1
		-- AND HISTORY.ysnPost = 1
		/*
		AND STORAGE.intCustomerStorageId = @CUSTOMER_STORAGE
		AND STORAGE.intEntityId = @ENTITY_ID
		AND STORAGE.intStorageTypeId = @STORAGE_SCHEDULE_TYPE_ID
		
		*/
	UNION ALL

	SELECT 
	'TRANSFER' AS strMode
	, HISTORY.intTransactionTypeId
	, TRANSFERS.strTransferStorageTicket AS strTransactionId
	, 'TRANSFER' AS strTransactionType 
	, TRANSFERS.dtmTransferStorageDate AS dtmTransactionDate



	, STORAGE.intEntityId
	, STORAGE.intCustomerStorageId 
	, STORAGE.intStorageTypeId 
	, HISTORY.intStorageHistoryId
	, case when GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId is not null and 
			GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId != UOM.intUnitMeasureId then
			round(dbo.fnGRConvertQuantityToTargetItemUOM(
									STORAGE.intItemId
									, UOM.intUnitMeasureId
									, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
									, HISTORY.dblUnits) , 4)
		else
			HISTORY.dblUnits
		end as dblUnits
	, STORAGE.intStorageScheduleId
	, STORAGE.intItemId	
	, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId

	FROM tblGRCustomerStorage  STORAGE
		JOIN tblGRStorageHistory HISTORY
			ON STORAGE.intCustomerStorageId = HISTORY.intCustomerStorageId
		JOIN tblGRTransferStorage TRANSFERS
			ON HISTORY.intTransferStorageId = TRANSFERS.intTransferStorageId
		JOIN tblICItemUOM ITEM_UOM
					on STORAGE.intItemUOMId = ITEM_UOM.intItemUOMId
						and STORAGE.intItemId = ITEM_UOM.intItemId
		
		JOIN tblICUnitMeasure UOM
				on ITEM_UOM.intUnitMeasureId = UOM.intUnitMeasureId
		OUTER APPLY(
			SELECT intGrainBankUnitMeasureId FROM tblGRCompanyPreference
		) GR_COMPANY_PREFERENCE
	WHERE HISTORY.intTransactionTypeId = 3
		-- AND HISTORY.ysnPost = 1
		/*STORAGE.intEntityId = @ENTITY_ID
		AND STORAGE.intStorageTypeId = @STORAGE_SCHEDULE_TYPE_ID
		AND 
		AND STORAGE.intCustomerStorageId = @CUSTOMER_STORAGE
		*/
	UNION ALL

	SELECT 
	'SETTLEMENT' AS strMode
	, HISTORY.intTransactionTypeId
	, SETTLEMENT.strStorageTicket AS strTransactionId
	, 'SETTLEMENT' AS strTransactionType 
	, SETTLEMENT.dtmCreated AS dtmTransactionDate



	, STORAGE.intEntityId
	, STORAGE.intCustomerStorageId 
	, STORAGE.intStorageTypeId 
	, HISTORY.intStorageHistoryId
	, -1 * case when GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId is not null and 
			GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId != UOM.intUnitMeasureId then
			round(dbo.fnGRConvertQuantityToTargetItemUOM(
									STORAGE.intItemId
									, UOM.intUnitMeasureId
									, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
									, HISTORY.dblUnits) , 4)
		else
			HISTORY.dblUnits
		end as dblUnits
	, STORAGE.intStorageScheduleId
	, STORAGE.intItemId
	
	, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
	FROM tblGRCustomerStorage  STORAGE
		JOIN tblGRStorageHistory HISTORY
			ON STORAGE.intCustomerStorageId = HISTORY.intCustomerStorageId
		JOIN tblGRSettleStorage SETTLEMENT
			ON HISTORY.intSettleStorageId = SETTLEMENT.intSettleStorageId
		JOIN tblICItemUOM ITEM_UOM
					on STORAGE.intItemUOMId = ITEM_UOM.intItemUOMId
						and STORAGE.intItemId = ITEM_UOM.intItemId
		
		JOIN tblICUnitMeasure UOM
				on ITEM_UOM.intUnitMeasureId = UOM.intUnitMeasureId
		OUTER APPLY(
			SELECT intGrainBankUnitMeasureId FROM tblGRCompanyPreference
		) GR_COMPANY_PREFERENCE
	WHERE HISTORY.intTransactionTypeId = 4
		-- AND HISTORY.ysnPost = 1
		 /*
		 STORAGE.intEntityId = @ENTITY_ID
		AND STORAGE.intStorageTypeId = @STORAGE_SCHEDULE_TYPE_ID
		AND AND STORAGE.intCustomerStorageId = @CUSTOMER_STORAGE
		*/

	UNION ALL

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
	, -1 * case when GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId is not null and 
			GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId != UOM.intUnitMeasureId then
			round(dbo.fnGRConvertQuantityToTargetItemUOM(
									STORAGE.intItemId
									, UOM.intUnitMeasureId
									, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
									, HISTORY.dblUnits) , 4)
		else
			HISTORY.dblUnits
		end as dblUnits
	, STORAGE.intStorageScheduleId
	, STORAGE.intItemId
	
	, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
	FROM tblGRCustomerStorage  STORAGE
		JOIN tblGRStorageHistory HISTORY
			ON STORAGE.intCustomerStorageId = HISTORY.intCustomerStorageId
		JOIN tblARInvoice INVOICE
			ON HISTORY.intInvoiceId = INVOICE.intInvoiceId
		JOIN tblARInvoiceDetail INVOICE_DETAIL
			ON INVOICE.intInvoiceId = INVOICE_DETAIL.intInvoiceId
				AND STORAGE.intItemId = INVOICE_DETAIL.intItemId
	
		
		JOIN tblICItemUOM ITEM_UOM
					on STORAGE.intItemUOMId = ITEM_UOM.intItemUOMId
						and STORAGE.intItemId = ITEM_UOM.intItemId
		
		JOIN tblICUnitMeasure UOM
				on ITEM_UOM.intUnitMeasureId = UOM.intUnitMeasureId
		OUTER APPLY(
			SELECT intGrainBankUnitMeasureId FROM tblGRCompanyPreference
		) GR_COMPANY_PREFERENCE
	WHERE HISTORY.intTransactionTypeId = 6
		-- AND HISTORY.ysnPost = 1
		/*
		STORAGE.intEntityId = @ENTITY_ID
		AND STORAGE.intStorageTypeId = @STORAGE_SCHEDULE_TYPE_ID		
		AND STORAGE.intCustomerStorageId = @CUSTOMER_STORAGE
		*/
