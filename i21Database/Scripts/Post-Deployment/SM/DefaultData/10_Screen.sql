GO
	PRINT N'BEGIN INSERT DEFAULT SCREEN'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.Activity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'Activity', N'Activity', N'GlobalComponentEngine.view.Activity', N'System Manager', N'tblSMActivity', 0)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.GeneralJournal') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'GeneralJournal', N'General Journal', N'GeneralLedger.view.GeneralJournal', N'General Ledger', N'tblGLJournal', 1, 1, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblGLJournal',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'GeneralLedger.view.GeneralJournal'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.EditAccount') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'EditAccount', N'Edit Account', N'GeneralLedger.view.EditAccount', N'General Ledger', N'tblGLAccount', 1, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblGLAccount',
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'GeneralLedger.view.EditAccount'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.Entity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'Entity', N'Entity', N'EntityManagement.view.Entity', N'Entity Management', N'tblEMEntity', 1, 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblEntity', 
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'EntityManagement.view.Entity'
		END
		
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.LoadSchedule')
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnActivity], [intConcurrencyId])
			VALUES (N'LoadSchedule', N'Load Schedule', N'Logistics.view.LoadSchedule', N'Logistics', N'tblLGLoad', 1, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblLGLoad', 
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'Logistics.view.LoadSchedule'
		END

	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.EntityContact') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'Entity Contact', N'Entity Contact', N'EntityManagement.view.EntityContact', N'Entity Management', N'tblEMEntity', 1, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblEMEntity', 
				strScreenId = N'Entity Contact', 
				strScreenName = 'Entity Contact',
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'EntityManagement.view.EntityContact'
		END

	-- Purchasing
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Voucher') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId]) 
		VALUES (N'Voucher', N'Voucher', N'AccountsPayable.view.Voucher', N'Accounts Payable', N'tblAPBill',  1, 1,  0)
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblAPBill', ysnApproval = 1, ysnActivity = 1 WHERE strNamespace = 'AccountsPayable.view.Voucher'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId]) 
		VALUES (N'Purchase Order', N'Purchase Order', N'AccountsPayable.view.PurchaseOrder', N'Accounts Payable', N'tblPOPurchase',  1, 1,  0)
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblPOPurchase', ysnApproval = 1, ysnActivity = 1 WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.ImportAPInvoice') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [intConcurrencyId]) 
		VALUES (N'', N'Import Vouchers from Origin', N'AccountsPayable.view.ImportAPInvoice', N'Accounts Payable',  0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = 'Import Vouchers from Origin' WHERE strNamespace = 'AccountsPayable.view.ImportAPInvoice'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.RecapTransaction') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [intConcurrencyId]) 
		VALUES (N'', N'Post Preview', N'AccountsPayable.view.RecapTransaction', N'Accounts Payable', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = 'Post Preview' WHERE strNamespace = 'AccountsPayable.view.RecapTransaction'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.ReceivedItems') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [intConcurrencyId]) 
		VALUES (N'', N'Add Payables', N'AccountsPayable.view.ReceivedItems', N'Accounts Payable', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = 'Add Payables' WHERE strNamespace = 'AccountsPayable.view.ReceivedItems'
			
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.ReceivedItems') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [intConcurrencyId]) 
		VALUES (N'', N'Tax Details', N'AccountsPayable.view.Taxes', N'Accounts Payable', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = 'Tax Details' WHERE strNamespace = 'AccountsPayable.view.Taxes'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.Quote') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId]) 
		VALUES (N'Quote', N'Quote', N'AccountsReceivable.view.Quote', N'Accounts Receivable', N'tblSOSalesOrder',  1,  1,  0)
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblSOSalesOrder', ysnApproval = 1, ysnActivity = 1 WHERE strNamespace = 'AccountsReceivable.view.Quote'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.SalesOrder') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId]) 
		VALUES (N'Sales Order', N'Sales Order', N'AccountsReceivable.view.SalesOrder', N'Accounts Receivable', N'tblSOSalesOrder', 1,  1,  0)
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblSOSalesOrder', ysnApproval = 1, ysnActivity = 1 WHERE strNamespace = 'AccountsReceivable.view.SalesOrder'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],[ysnApproval], [ysnActivity], [ysnDocumentSource], [intConcurrencyId]) 
			VALUES (N'Contract', N'Contract', N'ContractManagement.view.Contract', N'Contract Management', N'tblCTContractHeader',  1,  1, 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblCTContractHeader',
				ysnApproval = 1,
				ysnActivity = 1,
				ysnDocumentSource = 1
			WHERE strNamespace = 'ContractManagement.view.Contract'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.FuturesOptionsTransactions') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'Futures Options Transactions', N'Futures Options Transactions', N'RiskManagement.view.FuturesOptionsTransactions', N'Risk Management', N'tblRKFutOptTransaction', 1,  1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblRKFutOptTransaction',
				ysnApproval = 1,
				ysnActivity = 1
			WHERE strNamespace = 'RiskManagement.view.FuturesOptionsTransactions'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Payroll.view.TimeOffRequest') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],  [ysnApproval], [ysnActivity], [strApprovalMessage], [intConcurrencyId]) 
			VALUES (N'Time Off Requests', N'Time Off Requests', N'Payroll.view.TimeOffRequest', N'Payroll', N'tblPRTimeOffRequest',  1,  1, '{transactionNo} for {currencySymbol}{amount} hours',  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblPRTimeOffRequest',
				ysnApproval = 1,
				ysnActivity = 1,
				strApprovalMessage = '{transactionNo} for {currencySymbol}{amount} hours'
			WHERE strNamespace = 'Payroll.view.TimeOffRequest'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.ActivityEmail') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'Activity Email', N'Activity Email', N'GlobalComponentEngine.view.ActivityEmail', N'System Manager', N'tblSMActivity', 0)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'CRM.view.Opportunity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],  [ysnApproval], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'Opportunity', N'Opportunity', N'CRM.view.Opportunity', N'CRM', N'tblCRMOpportunity',  null,  1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblCRMOpportunity',
				ysnActivity = 1
			WHERE strNamespace = 'CRM.view.Opportunity'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'CRM.view.Campaign')
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId])
			VALUES (N'Campaign', N'Campaign', N'CRM.view.Campaign', N'CRM', N'tblCRMCampaign', 1, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET  ysnApproval = 1, ysnCustomTab = 1
			WHERE strNamespace = 'CRM.view.Campaign'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Manufacturing.view.WorkOrder') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'WorkOrder', N'Work Order', N'Manufacturing.view.WorkOrder', N'Manufacturing', N'tblMFWorkOrder', 1, 1, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblMFWorkOrder',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'Manufacturing.view.WorkOrder'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Manufacturing.view.ProcessProductionConsume') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'ProcessProductionConsume', N'Process Production Consume', N'Manufacturing.view.ProcessProductionConsume', N'Manufacturing', N'tblMFWorkOrderInputLot', 1, 1, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblMFWorkOrderInputLot',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'Manufacturing.view.ProcessProductionConsume'
		END

	UPDATE tblSMScreen SET strNamespace = 'ContractManagement.view.Amendments' WHERE strNamespace IN ('ContractManagement.view.ContractAmendments', 'ContractManagement.view.ContractAmendment')

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Amendments') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],[ysnApproval], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'Contract', N'Contract Amendment ', N'ContractManagement.view.Amendments', N'Contract Management', N'tblCTContractHeader',  1,  1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblCTContractHeader',
				ysnApproval = 1,
				ysnActivity = 1
			WHERE strNamespace = 'ContractManagement.view.Amendments'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryReceipt')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId])
            VALUES (N'InventoryReceipt', N'Inventory Receipt', N'Inventory.view.InventoryReceipt', N'Inventory', N'tblICInventoryReceipt', 1, 1, 1, 0)
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICInventoryReceipt',
				strScreenId = N'InventoryReceipt',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'Inventory.view.InventoryReceipt'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryShipment')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId])
            VALUES (N'InventoryShipment', N'Inventory Shipment', N'Inventory.view.InventoryShipment', N'Inventory', N'tblICInventoryShipment', 1, 1, 1, 0)
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICInventoryShipment',
				strScreenId = N'InventoryShipment',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'Inventory.view.InventoryShipment'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Item')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId])
            VALUES (N'Item', N'Item', N'Inventory.view.Item', N'Inventory', N'tblICItem', 1, 1, 1, 0)
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICItem',
				strScreenId = N'Item',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1
			WHERE strNamespace = 'Inventory.view.Item'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Item')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId])
        VALUES (N'', N'Contract', N'ContractManagement.view.Contract', N'Contract Management', N'tblCTContractHeader', 1, 1, 1, 0)
	END	

	--- Tank Management
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'TankManagement.view.Order')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId])
        VALUES (N'', N'TM Order', N'TankManagement.view.Order', N'Tank Management', N'', 1,  0)
    END

	--- Grain
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.DiscountTable')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
        VALUES (N'', N'Discounts', N'Grain.view.DiscountTable', N'Grain', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Discounts', strModule = N'Grain' WHERE strNamespace = 'Grain.view.DiscountTable'
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.GrainStorageType')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
        VALUES (N'', N'Storage Type', N'Grain.view.GrainStorageType', N'Grain', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Storage Type', strModule = N'Grain' WHERE strNamespace = 'Grain.view.GrainStorageType'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
        VALUES (N'', N'Bill Storage', N'Grain.view.BillStorageAndDiscounts', N'Grain', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Bill Storage', strModule = N'Grain' WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts'

	DELETE tblSMScreen WHERE strModule = 'Grain' AND strNamespace IN('Grain.view.StorageType', 'Grain.view.QualityDiscounts', 'Grain.view.StorageStatement')

	   --- Store
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.GrainStorageType')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
        VALUES (N'', N'Storage Type', N'Grain.view.GrainStorageType', N'Grain', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Storage Type', strModule = N'Grain' WHERE strNamespace = 'Grain.view.GrainStorageType'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
        VALUES (N'', N'Bill Storage', N'Grain.view.BillStorageAndDiscounts', N'Grain', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Bill Storage', strModule = N'Grain' WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts'

	DELETE tblSMScreen WHERE strModule = 'Grain' AND strNamespace IN('Grain.view.StorageType', 'Grain.view.QualityDiscounts', 'Grain.view.StorageStatement')

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.ScaleLoadSelection')
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
		VALUES (N'', N'Load Schedule Selection', N'Grain.view.ScaleLoadSelection', N'Grain', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Load Schedule Selection', strModule = N'Grain' WHERE strNamespace = 'Grain.view.ScaleLoadSelection'
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.ScaleContractSelection')
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
		VALUES (N'', N'Contract Selection', N'Grain.view.ScaleContractSelection', N'Grain', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Contract Selection', strModule = N'Grain' WHERE strNamespace = 'Grain.view.ScaleContractSelection'

       --- Store
       --- Checkouts
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.CheckoutHeader')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
                     VALUES (N'', N'Checkouts', N'Store.view.CheckoutHeader', N'Store', N'', 0)
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Checkouts', strModule = N'Store' WHERE strNamespace = 'Store.view.CheckoutHeader'
              END
       --- Promotion Item List
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.PromotionItemList')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
                     VALUES (N'', N'Promotion Item List', N'Store.view.PromotionItemList', N'Store', N'', 0)
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Promotion Item List', strModule = N'Store' WHERE strNamespace = 'Store.view.PromotionItemList'
              END
       --- Item Movement
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.ItemMovementReport')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
                     VALUES (N'', N'Item Movement', N'Store.view.ItemMovementReport', N'Store', N'', 0)
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Item Movement', strModule = N'Store' WHERE strNamespace = 'Store.view.ItemMovementReport'
              END
       --- Mark Up/Down
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.MarkUpDown')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
                     VALUES (N'', N'Mark Up/Down', N'Store.view.MarkUpDown', N'Store', N'', 0)
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Mark Up/Down', strModule = N'Store' WHERE strNamespace = 'Store.view.MarkUpDown'
              END
       --- Purge Promotions
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.PurgePromotion')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
                     VALUES (N'', N'Purge Promotions', N'Store.view.PurgePromotion', N'Store', N'', 0)
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Purge Promotions', strModule = N'Store' WHERE strNamespace = 'Store.view.PurgePromotion'
              END
       --- Update Rebate/Discount
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.UpdateRebateDiscount')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
                     VALUES (N'', N'Update Rebate/Discount', N'Store.view.UpdateRebateDiscount', N'Store', N'', 0)
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Update Rebate/Discount', strModule = N'Store' WHERE strNamespace = 'Store.view.UpdateRebateDiscount'
              END

	IF EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Quality.view.QualityException')
	BEGIN
		UPDATE tblSMScreen SET strScreenName = N'Quality View' WHERE strNamespace = 'Quality.view.QualityException'
	END
GO
	PRINT N'END INSERT DEFAULT SCREEN'
GO