﻿CREATE VIEW [dbo].[vyuSCGrainBankTransactions]
	AS 

	SELECT 
	'TICKET' AS strMode
	, HISTORY.intTransactionTypeId
	, TICKET.strTicketNumber AS strTransactionId
	, '' AS strStorageTicketNo
	, CASE WHEN TICKET.strDistributionOption = 'SPL' THEN 'Split' 
		WHEN TICKET.intTicketTypeId = 3 THEN 'Transfer In'
		WHEN TICKET.intTicketTypeId = 4 THEN 'Transfer Out'

		ELSE 'Delivered' END AS strTransactionType
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
		JOIN tblGRStorageType STORAGE_TYPE 
			ON STORAGE.intStorageTypeId = STORAGE_TYPE.intStorageScheduleTypeId
				AND STORAGE_TYPE.ysnGrainBankType = 1
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
	'TICKET' AS strMode
	, HISTORY.intTransactionTypeId
	, TICKET.strTicketNumber AS strTransactionId
	, '' AS strStorageTicketNo
	, CASE WHEN TICKET.strDistributionOption = 'SPL' THEN 'Split' ELSE 'Loaded Out' END AS strTransactionType
	, TICKET.dtmTicketDateTime AS dtmTransactionDate


	, STORAGE.intEntityId
	, STORAGE.intCustomerStorageId 
	, STORAGE.intStorageTypeId 
	, HISTORY.intStorageHistoryId

	, -1 * case when GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId is not null and 
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
		JOIN tblGRStorageType STORAGE_TYPE 
			ON STORAGE.intStorageTypeId = STORAGE_TYPE.intStorageScheduleTypeId
				AND STORAGE_TYPE.ysnGrainBankType = 1
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
		HISTORY.intTransactionTypeId = 8


	UNION ALL

	SELECT 
	'TRANSFER' AS strMode
	, HISTORY.intTransactionTypeId
	, TRANSFERS.strTransferStorageTicket AS strTransactionId
	, '' AS strStorageTicketNo
	, 'Transfer' AS strTransactionType
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
		JOIN tblGRStorageType STORAGE_TYPE 
			ON STORAGE.intStorageTypeId = STORAGE_TYPE.intStorageScheduleTypeId
				AND STORAGE_TYPE.ysnGrainBankType = 1
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
	, '' AS strStorageTicketNo
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
		JOIN tblGRStorageType STORAGE_TYPE 
			ON STORAGE.intStorageTypeId = STORAGE_TYPE.intStorageScheduleTypeId
				AND STORAGE_TYPE.ysnGrainBankType = 1
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
	, STORAGE.strStorageTicketNumber AS strStorageTicketNo
	, HISTORY.strType AS strTransactionType
	, INVOICE.dtmDate AS dtmTransactionDate



	, STORAGE.intEntityId 
	, STORAGE.intCustomerStorageId 
	, STORAGE.intStorageTypeId 
	, HISTORY.intStorageHistoryId
	, CASE WHEN HISTORY.strType = 'Reduced By Invoice' THEN -1 
		WHEN HISTORY.strType = 'Reverse By Invoice' THEN 1 
		ELSE 1
		END
		* case when GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId is not null and 
			GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId != STORAGE.intUnitMeasureId then
			round(dbo.fnGRConvertQuantityToTargetItemUOM(
									STORAGE.intItemId
									, STORAGE.intUnitMeasureId
									, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
									, HISTORY.dblUnits) , 4)
		else
			HISTORY.dblUnits
		end as dblUnits
	, STORAGE.intStorageScheduleId
	, STORAGE.intItemId
	
	, GR_COMPANY_PREFERENCE.intGrainBankUnitMeasureId
	FROM tblGRCustomerStorage  STORAGE
		JOIN tblGRStorageType STORAGE_TYPE 
			ON STORAGE.intStorageTypeId = STORAGE_TYPE.intStorageScheduleTypeId
				AND STORAGE_TYPE.ysnGrainBankType = 1
		JOIN tblGRStorageHistory HISTORY
			ON STORAGE.intCustomerStorageId = HISTORY.intCustomerStorageId
		JOIN tblARInvoice INVOICE
			ON HISTORY.intInvoiceId = INVOICE.intInvoiceId		
		OUTER APPLY(
			SELECT intGrainBankUnitMeasureId FROM tblGRCompanyPreference
		) GR_COMPANY_PREFERENCE
	WHERE HISTORY.intTransactionTypeId = 6
		AND ISNULL(HISTORY.strPaidDescription,'') <> 'Generated Storage Invoice'
		-- AND HISTORY.ysnPost = 1
		/*
		STORAGE.intEntityId = @ENTITY_ID
		AND STORAGE.intStorageTypeId = @STORAGE_SCHEDULE_TYPE_ID		
		AND STORAGE.intCustomerStorageId = @CUSTOMER_STORAGE
		*/
GO


