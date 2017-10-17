﻿GO
	PRINT N'BEGIN INSERT DEFAULT SCREEN'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.Activity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
			VALUES (N'Activity', N'Activity', N'GlobalComponentEngine.view.Activity', N'System Manager', N'tblSMActivity', 0, N'Account')
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
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnActivity], [intConcurrencyId], strGroupName)
			VALUES (N'LoadSchedule', N'Load Schedule', N'Logistics.view.LoadSchedule', N'Logistics', N'tblLGLoad', 1, 1, 0, N'Logistics')
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
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Voucher', N'Voucher', N'AccountsPayable.view.Voucher', N'Accounts Payable', N'tblAPBill',  1, 1,  0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblAPBill', ysnApproval = 1, ysnActivity = 1, strGroupName = 'Transaction' WHERE strNamespace = 'AccountsPayable.view.Voucher'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Purchase Order', N'Purchase Order', N'AccountsPayable.view.PurchaseOrder', N'Accounts Payable', N'tblPOPurchase',  1, 1,  0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblPOPurchase', ysnApproval = 1, ysnActivity = 1, strGroupName = 'Transaction'  WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.ImportAPInvoice') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [intConcurrencyId], [strGroupName]) 
		VALUES (N'', N'Import Vouchers from Origin', N'AccountsPayable.view.ImportAPInvoice', N'Accounts Payable',  0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strScreenName = 'Import Vouchers from Origin', strGroupName = 'Transaction' WHERE strNamespace = 'AccountsPayable.view.ImportAPInvoice'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.RecapTransaction') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [intConcurrencyId], [strGroupName]) 
		VALUES (N'', N'Post Preview', N'AccountsPayable.view.RecapTransaction', N'Accounts Payable', 0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strScreenName = 'Post Preview', strGroupName = 'Transaction'  WHERE strNamespace = 'AccountsPayable.view.RecapTransaction'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.ReceivedItems') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [intConcurrencyId], [strGroupName]) 
		VALUES (N'', N'Add Payables', N'AccountsPayable.view.ReceivedItems', N'Accounts Payable', 0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strScreenName = 'Add Payables', strGroupName = 'Transaction'  WHERE strNamespace = 'AccountsPayable.view.ReceivedItems'
			
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.ReceivedItems') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [intConcurrencyId], [strGroupName]) 
		VALUES (N'', N'Tax Details', N'AccountsPayable.view.Taxes', N'Accounts Payable', 0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strScreenName = 'Tax Details', strGroupName = 'Transaction' WHERE strNamespace = 'AccountsPayable.view.Taxes'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.Quote') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Quote', N'Quote', N'AccountsReceivable.view.Quote', N'Accounts Receivable', N'tblSOSalesOrder',  1,  1,  0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblSOSalesOrder', ysnApproval = 1, ysnActivity = 1, strGroupName = 'Transaction' WHERE strNamespace = 'AccountsReceivable.view.Quote'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.SalesOrder') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Sales Order', N'Sales Order', N'AccountsReceivable.view.SalesOrder', N'Accounts Receivable', N'tblSOSalesOrder', 1,  1,  0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblSOSalesOrder', ysnApproval = 1, ysnActivity = 1, strGroupName = 'Transaction' WHERE strNamespace = 'AccountsReceivable.view.SalesOrder'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],[ysnApproval], [ysnActivity], [ysnDocumentSource], [intConcurrencyId], [strGroupName]) 
			VALUES (N'Contract', N'Contract', N'ContractManagement.view.Contract', N'Contract Management', N'tblCTContractHeader',  1,  1, 1,  0, N'Contract Management')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblCTContractHeader',
				ysnApproval = 1,
				ysnActivity = 1,
				ysnDocumentSource = 1,
				strGroupName = 'Contract Management'
			WHERE strNamespace = 'ContractManagement.view.Contract'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.FuturesOptionsTransactions') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
			VALUES (N'Futures Options Transactions', N'Futures Options Transactions', N'RiskManagement.view.FuturesOptionsTransactions', N'Risk Management', N'tblRKFutOptTransaction', 1,  1,  0, N'Risk Management')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblRKFutOptTransaction',
				ysnApproval = 1,
				ysnActivity = 1,
				strGroupName = 'Risk Management'
			WHERE strNamespace = 'RiskManagement.view.FuturesOptionsTransactions'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Payroll.view.TimeOffRequest') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],  [ysnApproval], [ysnActivity], [strApprovalMessage], [intConcurrencyId], [strGroupName]) 
			VALUES (N'Time Off Requests', N'Time Off Requests', N'Payroll.view.TimeOffRequest', N'Payroll', N'tblPRTimeOffRequest',  1,  1, '{transactionNo} for {currencySymbol}{amount} hours',  0, N'Payroll')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblPRTimeOffRequest',
				ysnApproval = 1,
				ysnActivity = 1,
				strGroupName = 'Payroll',
				strApprovalMessage = '{transactionNo} for {currencySymbol}{amount} hours'
			WHERE strNamespace = 'Payroll.view.TimeOffRequest'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.ActivityEmail') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
			VALUES (N'Activity Email', N'Activity Email', N'GlobalComponentEngine.view.ActivityEmail', N'System Manager', N'tblSMActivity', 0, N'System Manager')
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'CRM.view.Opportunity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],  [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
			VALUES (N'Opportunity', N'Opportunity', N'CRM.view.Opportunity', N'CRM', N'tblCRMOpportunity',  null,  1,  0, N'Opportunity')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblCRMOpportunity',
				ysnActivity = 1,
				strGroupName = 'Opportunity'
			WHERE strNamespace = 'CRM.view.Opportunity'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'CRM.view.Campaign')
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId], [strGroupName])
			VALUES (N'Campaign', N'Campaign', N'CRM.view.Campaign', N'CRM', N'tblCRMCampaign', 1, 1, 0, N'Opportunity')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET  ysnApproval = 1, ysnCustomTab = 1, strGroupName = N'Opportunity'
			WHERE strNamespace = 'CRM.view.Campaign'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Manufacturing.view.WorkOrder') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [ysnActivity], [intConcurrencyId], [strGroupName]) 
			VALUES (N'WorkOrder', N'Work Order', N'Manufacturing.view.WorkOrder', N'Manufacturing', N'tblMFWorkOrder', 1, 1, 1, 0, N'Manufacturing')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblMFWorkOrder',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Manufacturing'
			WHERE strNamespace = 'Manufacturing.view.WorkOrder'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Manufacturing.view.ProcessProductionConsume') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [ysnActivity], [intConcurrencyId], [strGroupName]) 
			VALUES (N'ProcessProductionConsume', N'Process Production Consume', N'Manufacturing.view.ProcessProductionConsume', N'Manufacturing', N'tblMFWorkOrderInputLot', 1, 1, 1, 0, N'Manufacturing')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblMFWorkOrderInputLot',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Manufacturing'
			WHERE strNamespace = 'Manufacturing.view.ProcessProductionConsume'
		END

	UPDATE tblSMScreen SET strNamespace = 'ContractManagement.view.Amendments' WHERE strNamespace IN ('ContractManagement.view.ContractAmendments', 'ContractManagement.view.ContractAmendment')

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Amendments') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],[ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
			VALUES (N'Contract', N'Contract Amendment ', N'ContractManagement.view.Amendments', N'Contract Management', N'tblCTContractHeader',  1,  1,  0, 'Contract Management')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblCTContractHeader',
				ysnApproval = 1,
				ysnActivity = 1,
				strGroupName = N'Contract Management'
			WHERE strNamespace = 'ContractManagement.view.Amendments'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryReceipt')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName])
            VALUES (N'InventoryReceipt', N'Inventory Receipt', N'Inventory.view.InventoryReceipt', N'Inventory', N'tblICInventoryReceipt', 1, 1, 1, 0, N'Inventory')
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICInventoryReceipt',
				strScreenId = N'InventoryReceipt',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Inventory'
			WHERE strNamespace = 'Inventory.view.InventoryReceipt'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryShipment')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName])
            VALUES (N'InventoryShipment', N'Inventory Shipment', N'Inventory.view.InventoryShipment', N'Inventory', N'tblICInventoryShipment', 1, 1, 1, 0, N'Inventory')
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICInventoryShipment',
				strScreenId = N'InventoryShipment',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Inventory'
			WHERE strNamespace = 'Inventory.view.InventoryShipment'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Item')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName])
            VALUES (N'Item', N'Item', N'Inventory.view.Item', N'Inventory', N'tblICItem', 1, 1, 1, 0, N'Inventory')
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICItem',
				strScreenId = N'Item',
				ysnApproval = 1, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Inventory'
			WHERE strNamespace = 'Inventory.view.Item'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Item')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName])
        VALUES (N'', N'Contract', N'ContractManagement.view.Contract', N'Contract Management', N'tblCTContractHeader', 1, 1, 1, 0, N'Contract Management')
	END	

	--- Tank Management
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'TankManagement.view.Order')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId], [strGroupName])
        VALUES (N'', N'TM Order', N'TankManagement.view.Order', N'Tank Management', N'', 1,  0, N'Tank Management')
    END

	--- Grain
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.DiscountTable')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
        VALUES (N'', N'Discounts', N'Grain.view.DiscountTable', N'Ticket Management', N'', 0, 'Ticket Management')
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Discounts', strModule = N'Ticket Management', strGroupName = N'Ticket Management' WHERE strNamespace = 'Grain.view.DiscountTable'
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.GrainStorageType')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
        VALUES (N'', N'Storage Type', N'Grain.view.GrainStorageType', N'Ticket Management', N'', 0, N'Ticket Management')
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Storage Type', strModule = N'Ticket Management', strGroupName = N'Ticket Management' WHERE strNamespace = 'Grain.view.GrainStorageType'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
        VALUES (N'', N'Bill Storage', N'Grain.view.BillStorageAndDiscounts', N'Ticket Management', N'', 0, N'Ticket Management')
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Bill Storage', strModule = N'Ticket Management', strGroupName = N'Ticket Management' WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts'

	DELETE tblSMScreen WHERE strModule = 'Grain' AND strNamespace IN('Grain.view.StorageType', 'Grain.view.QualityDiscounts', 'Grain.view.StorageStatement')

	   --- Store
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.GrainStorageType')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
		VALUES (N'', N'Storage Type', N'Grain.view.GrainStorageType', N'Ticket Management', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Storage Type', strModule = N'Ticket Management' WHERE strNamespace = 'Grain.view.GrainStorageType'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
        VALUES (N'', N'Bill Storage', N'Grain.view.BillStorageAndDiscounts', N'Ticket Management', N'', 0)
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Bill Storage', strModule = N'Ticket Management' WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts'

	DELETE tblSMScreen WHERE strModule = 'Grain' AND strNamespace IN('Grain.view.StorageType', 'Grain.view.QualityDiscounts', 'Grain.view.StorageStatement')

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.ScaleLoadSelection')
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'', N'Load Schedule Selection', N'Grain.view.ScaleLoadSelection', N'Ticket Management', N'', 0, N'Ticket Management')
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Load Schedule Selection', strModule = N'Ticket Management', strGroupName = N'Ticket Management' WHERE strNamespace = 'Grain.view.ScaleLoadSelection'
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.ScaleContractSelection')
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'', N'Contract Selection', N'Grain.view.ScaleContractSelection', N'Ticket Management', N'', 0, N'Ticket Management')
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Contract Selection', strModule = N'Ticket Management', strGroupName = N'Ticket Management'  WHERE strNamespace = 'Grain.view.ScaleContractSelection'

       --- Store
       --- Checkouts
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.CheckoutHeader')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
                     VALUES (N'', N'Checkouts', N'Store.view.CheckoutHeader', N'Store', N'', 0, N'Store')
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Checkouts', strModule = N'Store', strGroupName = N'Store'  WHERE strNamespace = 'Store.view.CheckoutHeader'
              END
       --- Promotion Item List
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.PromotionItemList')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
                     VALUES (N'', N'Promotion Item List', N'Store.view.PromotionItemList', N'Store', N'', 0, N'Store')
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Promotion Item List', strModule = N'Store', strGroupName = N'Store' WHERE strNamespace = 'Store.view.PromotionItemList'
              END
       --- Item Movement
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.ItemMovementReport')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
                     VALUES (N'', N'Item Movement', N'Store.view.ItemMovementReport', N'Store', N'', 0, N'Store')
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Item Movement', strModule = N'Store', strGroupName = N'Store' WHERE strNamespace = 'Store.view.ItemMovementReport'
              END
       --- Mark Up/Down
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.MarkUpDown')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
                     VALUES (N'', N'Mark Up/Down', N'Store.view.MarkUpDown', N'Store', N'', 0, N'Store')
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Mark Up/Down', strModule = N'Store', strGroupName = N'Store' WHERE strNamespace = 'Store.view.MarkUpDown'
              END
       --- Purge Promotions
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.PurgePromotion')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
                     VALUES (N'', N'Purge Promotions', N'Store.view.PurgePromotion', N'Store', N'', 0, N'Store')
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Purge Promotions', strModule = N'Store', strGroupName = N'Store' WHERE strNamespace = 'Store.view.PurgePromotion'
              END
       --- Update Rebate/Discount
       IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Store.view.UpdateRebateDiscount')
              BEGIN
                     INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
                     VALUES (N'', N'Update Rebate/Discount', N'Store.view.UpdateRebateDiscount', N'Store', N'', 0, N'Store')
              END    
       ELSE
              BEGIN
                     UPDATE tblSMScreen SET strScreenName = N'Update Rebate/Discount', strModule = N'Store', strGroupName = N'Store' WHERE strNamespace = 'Store.view.UpdateRebateDiscount'
              END

	IF EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Quality.view.QualityException')
	BEGIN
		UPDATE tblSMScreen SET strScreenName = N'Quality View', strGroupName = N'Quality' WHERE strNamespace = 'Quality.view.QualityException'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EnergyTrac.view.Report')
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'', N'Delivery Metrics', N'EnergyTrac.view.Report', N'Energy Trac', N'', 0, N'Energy Trac')
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Delivery Metrics', strModule = N'Energy Trac', strGroupName = N'Energy Trac' WHERE strNamespace = 'EnergyTrac.view.Report'

GO
	
	--Manufacturing
	DELETE from tblSMScreen where strModule='Manufacturing' and strNamespace in ('Manufacturing.view.DataSource','Manufacturing.view.ItemMachine','Manufacturing.view.BlendSheetItemGridRowExpander')

GO

	--Integration
	Delete from tblSMScreen where strModule='Integration' and strNamespace in ('Integration.view.TextLayout','Integration.view.DatabaseTableToExcel','Integration.view.ValidateXML','Integration.view.GenerateXML')

GO

	IF EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strModule='Integration' and strNamespace = 'Integration.view.CopyMoveDeleteFile')
	BEGIN
		UPDATE tblSMScreen SET strScreenName = N'File Operation', strGroupName = N'Integration' WHERE strModule='Integration' and strNamespace = 'Integration.view.CopyMoveDeleteFile'
	END

GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.Consolidate')
    INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
    VALUES (N'', N'Consolidate GL Entries', N'GeneralLedger.view.Consolidate', N'GeneralLedger', N'', 0, N'General Ledger')
ELSE
    UPDATE tblSMScreen SET strScreenName = N'Consolidate GL Entries', strModule = N'General Ledger', strGroupName = N'General Ledger' WHERE strNamespace = 'GeneralLedger.view.Consolidate'
GO


-- Patronage - Start Screen Rename --
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Patronage.view.CustomerStock')
    INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
    VALUES (N'', N'Stock', N'Patronage.view.CustomerStock', N'Patronage', N'', 0, N'Patronage')
ELSE
    UPDATE tblSMScreen SET strScreenName = N'Stock', strModule = N'Patronage', strGroupName = N'Patronage' WHERE strNamespace = 'Patronage.view.CustomerStock'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Patronage.view.EquityDetail')
    INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
    VALUES (N'', N'Equity', N'Patronage.view.EquityDetail', N'Patronage', N'', 0, N'Patronage')
ELSE
    UPDATE tblSMScreen SET strScreenName = N'Equity', strModule = N'Patronage', strGroupName = N'Patronage' WHERE strNamespace = 'Patronage.view.EquityDetail'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Patronage.view.PrintLetter')
    INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
    VALUES (N'', N'Mailer', N'Patronage.view.PrintLetter', N'Patronage', N'', 0, N'Patronage')
ELSE
    UPDATE tblSMScreen SET strScreenName = N'Mailer', strModule = N'Patronage', strGroupName = N'Patronage' WHERE strNamespace = 'Patronage.view.PrintLetter'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Patronage.view.RefundCalculationWorksheet')
    INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
    VALUES (N'', N'Refunds', N'Patronage.view.RefundCalculationWorksheet', N'Patronage', N'', 0, N'Patronage')
ELSE
    UPDATE tblSMScreen SET strScreenName = N'Refunds', strModule = N'Patronage', strGroupName = N'Patronage' WHERE strNamespace = 'Patronage.view.RefundCalculationWorksheet'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Patronage.view.VolumeDetail')
    INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
    VALUES (N'', N'Volume', N'Patronage.view.VolumeDetail', N'Patronage', N'', 0, N'Patronage')
ELSE
    UPDATE tblSMScreen SET strScreenName = N'Volume', strModule = N'Patronage', strGroupName = N'Patronage' WHERE strNamespace = 'Patronage.view.VolumeDetail'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Patronage.view.ProcessDividend')
    INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
    VALUES (N'', N'Dividends', N'Patronage.view.ProcessDividend', N'Patronage', N'', 0, N'Patronage')
ELSE
    UPDATE tblSMScreen SET strScreenName = N'Dividends', strModule = N'Patronage', strGroupName = N'Patronage' WHERE strNamespace = 'Patronage.view.ProcessDividend'
GO

-- Patronage - End Screen Rename --

----------------------------Contract Management------------

UPDATE tblSMScreen set ysnAvailable = 0 WHERE strScreenName IN ('Allocations','Contract Ag Petro','Contract Options','Cost Type','Cost Type New','Deferred Payment Rates','Freight Rates','Freight Rate New','Market Zone','Price Contracts','Weight Grade New','Approval Basis','Packing Description','Delivery Sheet','Acre Contract','Approval','Crop Year New')
AND strModule = 'Contract Management'

UPDATE tblSMScreen SET strScreenName = N'Weight Grade',strNamespace = 'ContractManagement.view.WeightGrade' 
WHERE strNamespace = 'ContractManagement.view.WeightsGrades' AND strModule = N'Contract Management'

UPDATE tblSMScreen SET strScreenName = N'Price Contracts',strNamespace = 'ContractManagement.view.PriceContracts' 
WHERE strNamespace = 'ContractManagement.view.PriceContractsNew' AND strModule = N'Contract Management'

------------------------END Contract Management------------
GO
-------------------------LOGISTICS------------
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ShipmentSchedule')
    INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
    VALUES (N'', N'Load/Shipment Schedule', N'Logistics.view.ShipmentSchedule', N'Logistics', N'', 0)
ELSE
    UPDATE tblSMScreen SET strScreenName = N'Load/Shipment Schedule', strModule = N'Logistics' WHERE strNamespace = 'Logistics.view.ShipmentSchedule'
-------------------------END LOGISTICS------------
GO

PRINT N'END INSERT DEFAULT SCREEN'
GO
