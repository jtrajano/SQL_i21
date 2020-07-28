GO
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

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.Invoice') 
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Invoice', N'Invoice', N'AccountsReceivable.view.Invoice', N'Accounts Receivable', N'tblARInvoice', 1,  1,  0, N'Transaction')
	ELSE
		UPDATE tblSMScreen SET strTableName = 'tblARInvoice', ysnApproval = 1, ysnActivity = 1, strGroupName = 'Transaction' WHERE strNamespace = 'AccountsReceivable.view.Invoice'

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
			VALUES (N'Futures Options Transactions', N'Futures Options Transactions', N'RiskManagement.view.FuturesOptionsTransactions', N'Risk Management', N'tblRKFutOptTransaction', 0,  1,  0, N'Risk Management')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblRKFutOptTransaction',
				ysnApproval = 0,
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
			VALUES (N'WorkOrder', N'Work Order', N'Manufacturing.view.WorkOrder', N'Manufacturing', N'tblMFWorkOrder', 0, 1, 1, 0, N'Manufacturing')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblMFWorkOrder',
				ysnApproval = 0, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Manufacturing'
			WHERE strNamespace = 'Manufacturing.view.WorkOrder'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Manufacturing.view.ProcessProductionConsume') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [ysnActivity], [intConcurrencyId], [strGroupName]) 
			VALUES (N'ProcessProductionConsume', N'Process Production Consume', N'Manufacturing.view.ProcessProductionConsume', N'Manufacturing', N'tblMFWorkOrderInputLot', 0, 1, 1, 0, N'Manufacturing')
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblMFWorkOrderInputLot',
				ysnApproval = 0, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Manufacturing'
			WHERE strNamespace = 'Manufacturing.view.ProcessProductionConsume'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Manufacturing.view.ProcessProductionProduce') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [ysnActivity], [intConcurrencyId], [strGroupName]) 
		VALUES (N'ProcessProductionProduce', N'Process Production Produce', N'Manufacturing.view.ProcessProductionProduce', N'Manufacturing', N'tblMFWorkOrderProducedLot', 0, 1, 1, 0, N'Manufacturing')
	END
	ELSE
	BEGIN
		UPDATE tblSMScreen
		SET strTableName = N'tblMFWorkOrderProducedLot',
			ysnApproval = 0, 
			ysnCustomTab = 1,
			ysnActivity = 1,
			strGroupName = N'Manufacturing'
		WHERE strNamespace = 'Manufacturing.view.ProcessProductionProduce'
	END

	UPDATE tblSMScreen SET strNamespace = 'ContractManagement.view.Amendments' WHERE strNamespace IN ('ContractManagement.view.ContractAmendments', 'ContractManagement.view.ContractAmendment')

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Amendments') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],[ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Contract', N'Amendment and Approvals ', N'ContractManagement.view.Amendments', N'Contract Management', N'tblCTContractHeader',  1,  1,  0, 'Contract Management')
	END
	ELSE
	BEGIN
		UPDATE tblSMScreen
		SET strScreenName = 'Amendment and Approvals',
			strTableName = 'tblCTContractHeader',
			ysnApproval = 1,
			ysnActivity = 1,
			strGroupName = N'Contract Management'
		WHERE strNamespace = 'ContractManagement.view.Amendments'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryReceipt')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName])
            VALUES (N'InventoryReceipt', N'Inventory Receipt', N'Inventory.view.InventoryReceipt', N'Inventory', N'tblICInventoryReceipt', 1, 0, 1, 0, N'Inventory')
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICInventoryReceipt',
				strScreenId = N'InventoryReceipt',
				ysnApproval = 0, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Inventory'
			WHERE strNamespace = 'Inventory.view.InventoryReceipt'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryShipment')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName])
            VALUES (N'InventoryShipment', N'Inventory Shipment', N'Inventory.view.InventoryShipment', N'Inventory', N'tblICInventoryShipment', 1, 0, 1, 0, N'Inventory')
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICInventoryShipment',
				strScreenId = N'InventoryShipment',
				ysnApproval = 0, 
				ysnCustomTab = 1,
				ysnActivity = 1,
				strGroupName = N'Inventory'
			WHERE strNamespace = 'Inventory.view.InventoryShipment'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Item')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [ysnApproval], [ysnActivity], [intConcurrencyId], [strGroupName])
            VALUES (N'Item', N'Item', N'Inventory.view.Item', N'Inventory', N'tblICItem', 1, 0, 0, 0, N'Inventory')
        END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblICItem',
				strScreenId = N'Item',
				ysnApproval = 0, 
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
		UPDATE tblSMScreen SET strScreenName = N'Storage Type', strModule = N'Ticket Management', strGroupName = N'Ticket Management' WHERE strNamespace = 'Grain.view.GrainStorageType'

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts')
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
        VALUES (N'', N'Bill Storage', N'Grain.view.BillStorageAndDiscounts', N'Ticket Management', N'', 0, N'Ticket Management')
	ELSE
		UPDATE tblSMScreen SET strScreenName = N'Bill Storage', strModule = N'Ticket Management', strGroupName = N'Ticket Management' WHERE strNamespace = 'Grain.view.BillStorageAndDiscounts'

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

--Include Price Contracts on approval

UPDATE TOP(1) tblSMScreen SET ysnApproval =  1 WHERE strNamespace = 'ContractManagement.view.PriceContracts'


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

PRINT N'END INSERT DEFAULT SCREEN'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Manufacturing.view.Recipe') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],[ysnCustomTab],[ysnApproval], [ysnActivity], [ysnDocumentSource], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Recipe', N'Recipe', N'Manufacturing.view.Recipe', N'Manufacturing', N'tblMFRecipe', 1, 0,  1, 0,  0, N'Manufacturing')
	END
ELSE
	BEGIN
		UPDATE tblSMScreen
		SET strTableName = 'tblMFRecipe',
			ysnCustomTab = 1,
			ysnApproval = 0,
			ysnActivity = 1,
			ysnDocumentSource = 0,
			strGroupName = 'Manufacturing'
		WHERE strNamespace = 'Manufacturing.view.Recipe'
	END
GO
	------------------------ START REPLICATION SCREEN ------------------------

	-- Parent
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.EntityUser') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Users', N'Users', N'i21.view.EntityUser', N'System Manager', N'tblSMUserSecurity', 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Users', strScreenName = 'Users', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.EntityUser'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.UserRole') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'User Roles', N'User Roles', N'i21.view.UserRole', N'System Manager', N'tblSMUserRole', 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'User Roles', strScreenName = 'User Roles', strModule = 'System Manager', ysnAvailable = 1  WHERE strNamespace = 'i21.view.UserRole'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.Country') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Countries', N'Countries', N'i21.view.Country', N'System Manager', N'tblSMCountry', 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Countries', strScreenName = 'Countries', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.Country'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.Currency') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Currencies', N'Currencies', N'i21.view.Currency', N'System Manager', N'tblSMCurrency', 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Currencies', strScreenName = 'Currencies', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.Currency'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.EntityShipVia') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Ship Via', N'Ship Via', N'i21.view.EntityShipVia', N'System Manager', N'tblSMShipVia', 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Ship Via', strScreenName = 'Ship Via', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.EntityShipVia'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.PaymentMethod') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Payment Methods', N'Payment Methods', N'i21.view.PaymentMethod', N'System Manager', N'tblSMPaymentMethod', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.Term') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Terms', N'Terms', N'i21.view.Term', N'System Manager', N'tblSMTerm', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.CompanyLocation') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Company Locations', N'Company Locations', N'i21.view.CompanyLocation', N'System Manager', N'tblSMCompanyLocation', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.FreightTerm') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Freight Terms', N'Freight Terms', N'i21.view.FreightTerm', N'System Manager', N'tblSMFreightTerm', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.City') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Cities', N'Cities', N'i21.view.City', N'System Manager', N'tblSMCity', 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Cities', strScreenName = 'Cities', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.City'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.CurrencyExchangeRate') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Currency Exchange Rates', N'Currency Exchange Rates', N'i21.view.CurrencyExchangeRate', N'System Manager', N'tblSMCurrencyExchangeRate', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.CurrencyExchangeRateType') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Currency Exchange Rate Types', N'Currency Exchange Rate Types', N'i21.view.CurrencyExchangeRateType', N'System Manager', N'tblSMCurrencyExchangeRateType', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.LineOfBusiness') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Lines of Business', N'Lines of Business', N'i21.view.LineOfBusiness', N'System Manager', N'tblSMLineOfBusiness', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.ScreenLabel') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Screen Labels', N'Screen Labels', N'GlobalComponentEngine.view.ScreenLabel', N'System Manager', N'tblSMScreenLabel', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.ReportLabel') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Report Labels', N'Report Labels', N'GlobalComponentEngine.view.ReportLabel', N'System Manager', N'tblSMReportLabel', 1, N'System Manager')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.BrokerageAccount') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Brokerage Accounts', N'Brokerage Accounts', N'RiskManagement.view.BrokerageAccount', N'Risk Management', N'tblRKBrokerageAccount', 1, N'Risk Management')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor?searchCommand=EntityFuturesBroker') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Futures Broker', N'Futures Broker', N'AccountsPayable.view.EntityVendor?searchCommand=EntityFuturesBroker', N'Risk Management', N'tblRKFuturesBroker', 1, N'Risk Management')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.FuturesOptionsSettlementPrices') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Settlement Price', N'Settlement Price', N'RiskManagement.view.FuturesOptionsSettlementPrices', N'Risk Management', N'tblRKFutSettlementPriceMarketMap', 1, N'Risk Management')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.BasisEntry') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Basis Entry', N'Basis Entry', N'RiskManagement.view.BasisEntry', N'Risk Management', N'tblRKM2MBasis', 1, N'Risk Management')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Quality.view.QualityParameters') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Quality Parameters', N'Quality Parameters', N'Quality.view.QualityParameters', N'Quality', N'tblQMAttribute', 1, N'Quality')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Payroll.view.EntityEmployee') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Employees', N'Employees', N'Payroll.view.EntityEmployee', N'Payroll', N'tblPREmployee', 1, N'Payroll')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Employees', strScreenName = 'Employees', strModule = 'Payroll' WHERE strNamespace = 'Payroll.view.EntityEmployee'
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntityLead') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Leads', N'Leads', N'AccountsReceivable.view.EntityLead', N'CRM', NULL, 1, N'CRM')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Leads', strScreenName = 'Leads', strModule = 'CRM' WHERE strNamespace = 'AccountsReceivable.view.EntityLead'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.EntityVeterinary') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Veterinary', N'Veterinary', N'EntityManagement.view.EntityVeterinary', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Veterinary', strScreenName = 'Veterinary', strModule = 'System Manager' WHERE strNamespace = 'EntityManagement.view.EntityVeterinary'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor?searchCommand=EntityShippingLine') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Shipping Lines', N'Shipping Lines', N'AccountsPayable.view.EntityVendor?searchCommand=EntityShippingLine', N'Logistics', N'tblEMEntity', 1, N'Logistics')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor?searchCommand=EntityForwardingAgent') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Forwarding Agents', N'Forwarding Agents', N'AccountsPayable.view.EntityVendor?searchCommand=EntityForwardingAgent', N'Logistics', N'tblEMEntity', 1, N'Logistics')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor?searchCommand=EntityTerminal') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Terminals', N'Terminals', N'AccountsPayable.view.EntityVendor?searchCommand=EntityTerminal', N'Logistics', N'tblEMEntity', 1, N'Logistics')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ShippingMode') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Shipping Mode', N'Shipping Mode', N'Logistics.view.ShippingMode', N'Logistics', N'tblLGShippingMode', 1, N'Logistics')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ReasonCode') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Reason Code', N'Reason Code', N'Logistics.view.ReasonCode', N'Logistics', N'tblLGReasonCode', 1, N'Logistics')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ContainerType') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Container Types', N'Container Types', N'Logistics.view.ContainerType', N'Logistics', N'tblLGContainerType', 1, N'Logistics')
	END
		
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.WarehouseRateMatrix') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Warehouse Rate Matrix', N'Warehouse Rate Matrix', N'Logistics.view.WarehouseRateMatrix', N'Logistics', N'tblLGWarehouseRateMatrixDetail', 1, N'Logistics')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Item') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Items', N'Items', N'Inventory.view.Item', N'Inventory', N'tblICItem', 1, N'Inventory')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Commodity') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Commodities', N'Commodities', N'Inventory.view.Commodity', N'Inventory', N'tblICCommodity', 1, N'Inventory')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Category') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Categories', N'Categories', N'Inventory.view.Category', N'Inventory', N'tblICCategory', 1, N'Inventory')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryUOM') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Inventory UOM', N'Inventory UOM', N'Inventory.view.InventoryUOM', N'Inventory', N'tblICUnitMeasure', 1, N'Inventory')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.StorageUnit') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Storage Units', N'Storage Units', N'Inventory.view.StorageUnit', N'Inventory', N'tblICStorageUnitType', 1, N'Inventory')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.FiscalYear') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Fiscal Year', N'Fiscal Year', N'GeneralLedger.view.FiscalYear', N'General Ledger', N'tblGLCurrentFiscalYear', 1, N'General Ledger')
	END
		
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.ChartOfAccounts') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Chart of Accounts', N'Chart of Accounts', N'GeneralLedger.view.ChartOfAccounts', N'General Ledger', N'tblGLAccount', 1, N'General Ledger')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.AccountStructure') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Account Structure', N'Account Structure', N'GeneralLedger.view.AccountStructure', N'General Ledger', N'tblGLAccountStructure', 1, N'General Ledger')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.AccountGroups') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Account Groups', N'Account Groups', N'GeneralLedger.view.AccountGroups', N'General Ledger', N'tblGLAccountGroup', 1, N'General Ledger')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Condition') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Condition', N'Condition', N'ContractManagement.view.Condition', N'Contract Management', N'tblCTCondition', 1, N'Contract Management')
	END
		
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.ContractDocument') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Documents', N'Documents', N'ContractManagement.view.ContractDocument', N'Contract Management', N'tblICDocument', 1, N'Contract Management')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Associations') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Associations', N'Associations', N'ContractManagement.view.Associations', N'Contract Management', N'tblCTAssociation', 1, N'Contract Management')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.INCOShipTerm') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'INCO/Ship Term', N'INCO/Ship Term', N'ContractManagement.view.INCOShipTerm', N'Contract Management', N'tblCTContractBasis', 1, N'Contract Management')
	END
		
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Reporting.view.ReportManager?group=Contract Management&report=AOPVsActual&direct=true&showCriteria=true') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'AOP Vs Actual', N'AOP Vs Actual', N'Reporting.view.ReportManager?group=Contract Management&report=AOPVsActual&direct=true&showCriteria=true', N'Contract Management', N'tblCTAOP', 1, N'Contract Management')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.WeightGrades') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Weight/Grades', N'Weight/Grades', N'ContractManagement.view.WeightGrades', N'Contract Management', N'tblCTWeightGrade', 1, N'Contract Management')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'CashManagement.view.Banks') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Banks', N'Banks', N'CashManagement.view.Banks', N'Cash Management', N'tblCMBank', 1, N'Cash Management')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'CashManagement.view.BankAccounts') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Bank Accounts', N'Bank Accounts', N'CashManagement.view.BankAccounts', N'Cash Management', N'tblCMBankAccount', 1, N'Cash Management')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'CashManagement.view.BankAccounts') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Bank Accounts', N'Bank Accounts', N'CashManagement.view.BankAccounts', N'Cash Management', N'tblCMBankAccount', 1, N'Cash Management')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntityCustomer') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strPortalName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Customers', N'Customers', N'My Company', N'AccountsReceivable.view.EntityCustomer', N'Accounts Receivable', N'tblARCustomer', 1, N'Accounts Receivable')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET  strScreenId = 'Customers', strScreenName = 'Customers', strPortalName = N'My Company', strModule = 'Accounts Receivable' WHERE strNamespace = 'AccountsReceivable.view.EntityCustomer'
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntitySalesperson') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Sales Reps', N'Sales Reps', N'AccountsReceivable.view.EntitySalesperson', N'Accounts Receivable', N'tblARSalesperson', 1, N'Accounts Receivable')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET  [strScreenName] = 'Sales Reps', [strModule] = 'Accounts Receivable' WHERE strNamespace = 'AccountsReceivable.view.EntitySalesperson'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Vendors', N'Vendors', N'AccountsPayable.view.EntityVendor', N'Accounts Payable', N'tblAPVendor', 1, N'Accounts Payable')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET [strScreenId] = 'Vendors', [strScreenName] = 'Vendors', [strModule] = 'Accounts Payable' WHERE strNamespace = 'AccountsPayable.view.EntityVendor'
	END

	-- Subsidiary
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.OptionsLifecycle') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Option Lifecycle', N'Option Lifecycle', N'RiskManagement.view.OptionsLifecycle', N'Risk Management', N'tblRKFutOptTransactionHeader', 1, N'Risk Management')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.DerivativeEntry') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Derivative Entry', N'Derivative Entry', N'RiskManagement.view.DerivativeEntry', N'Risk Management', NULL, 1, N'Risk Management')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.AssignFuturesToContracts') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Assign Derivatives', N'Assign Derivatives', N'RiskManagement.view.AssignFuturesToContracts', N'Risk Management', 'tblRKAssignFuturesToContractSummary', 1, N'Risk Management')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.MatchDerivatives') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Match Derivatives', N'Match Derivatives', N'RiskManagement.view.MatchDerivatives', N'Risk Management', 'tblRKOptionsMatchPnSHeader', 1, N'Risk Management')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Quality.view.QualitySample') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Sample Entry', N'Sample Entry', N'Quality.view.QualitySample', N'Quality', NULL, 1, N'Quality')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.WeightClaims') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Weight Claims', N'Weight Claims', N'Logistics.view.WeightClaims', N'Logistics', 'tblLGWeightClaim', 1, N'Logistics')
	END	

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ShipmentSchedule') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Load / Shipment Schedules', N'Load / Shipment Schedules', N'Logistics.view.ShipmentSchedule', N'Logistics', 'tblLGLoad', 1, N'Logistics')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryAdjustment') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Inventory Adjustments', N'Inventory Adjustments', N'Inventory.view.InventoryAdjustment', N'Inventory', 'tblICInventoryAdjustment', 1, N'Inventory')
	END
			
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryReceipt') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Inventory Receipts', N'Inventory Receipts', N'Inventory.view.InventoryReceipt', N'Inventory', 'tblICInventoryReceipt', 1, N'Inventory')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryShipment') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Inventory Shipments', N'Inventory Shipments', N'Inventory.view.InventoryShipment', N'Inventory', 'tblICInventoryShipment', 1, N'Inventory')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryTransfer') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Inventory Transfers', N'Inventory Transfers', N'Inventory.view.InventoryTransfer', N'Inventory', 'tblICInventoryTransfer', 1, N'Inventory')
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryCount') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Inventory Count', N'Inventory Count', N'Inventory.view.InventoryCount', N'Inventory', 'tblICInventoryCount', 1, N'Inventory')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Contracts', N'Contracts', N'ContractManagement.view.Contract', N'Contract Management', 'tblCTContractCost', 1, N'Contract Management')
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.Invoice') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Invoices', N'Invoices', N'AccountsReceivable.view.Invoice', N'Accounts Receivable', 'tblARInvoice', 1, N'Accounts Receivable')
	END
			
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Voucher') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName])
		VALUES (N'Vouchers', N'Vouchers', N'AccountsPayable.view.Voucher', N'Accounts Payable', 'tblAPBill', 1, N'Accounts Payable')
	END

	------------------------ END REPLICATION SCREEN ------------------------
	
	--IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntityCustomer' AND strScreenName = 'My Company (Portal)') 
	--BEGIN
	--	INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
	--	VALUES (N'My Company (Portal)', N'My Company (Portal)', N'AccountsReceivable.view.EntityCustomer', N'Accounts Receivable', N'tblARCustomer', 1, N'Accounts Receivable')
	--END

	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.ApprovalList') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Approval List', N'Approval List', N'i21.view.ApprovalList', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Approval List', strScreenName = 'Approval List', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.ApprovalList'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.ApproverConfiguration') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Approver Configuration', N'Approver Configuration', N'i21.view.ApproverConfiguration', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Approver Configuration', strScreenName = 'Approver Configuration', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.ApproverConfiguration'
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.ApproverGroup') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Approver Groups', N'Approver Groups', N'i21.view.ApproverGroup', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Approver Groups', strScreenName = 'Approver Groups', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.ApproverGroup'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.TaxCode') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Tax Codes', N'Tax Codes', N'i21.view.TaxCode', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Tax Codes', strScreenName = 'Tax Codes', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.TaxCode'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.TaxGroup') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Tax Groups', N'Tax Groups', N'i21.view.TaxGroup', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Tax Groups', strScreenName = 'Tax Groups', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.TaxGroup'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.Letters') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Letters', N'Letters', N'i21.view.Letters', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Letters', strScreenName = 'Letters', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.Letters'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.FileFieldMapping') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'File Field Mapping', N'File Field Mapping', N'i21.view.FileFieldMapping', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'File Field Mapping', strScreenName = 'File Field Mapping', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.FileFieldMapping'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.SecurityPolicy') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Security Policies', N'Security Policies', N'i21.view.SecurityPolicy', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Security Policies', strScreenName = 'Security Policies', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.SecurityPolicy'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.Signatures') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Signatures', N'Signatures', N'i21.view.Signatures', N'System Manager', NULL, 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Signatures', strScreenName = 'Signatures', strModule = 'System Manager', ysnAvailable = 1 WHERE strNamespace = 'i21.view.Signatures'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'i21.view.PortalRole') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Portal User Roles', N'Portal User Roles', N'i21.view.PortalRole', N'System Manager', N'tblSMUserRole', 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Portal User Roles', strScreenName = 'Portal User Roles', strModule = 'System Manager', ysnAvailable = 1  WHERE strNamespace = 'i21.view.PortalRole'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.EmailHistory') 
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId], [strGroupName]) 
		VALUES (N'Email History', N'Email History', N'GlobalComponentEngine.view.EmailHistory', N'Global Component Engine', N'tblSMScreen', 1, N'System Manager')
	END
	ELSE
	BEGIN
		UPDATE [tblSMScreen] SET strScreenId = 'Email History', strScreenName = 'Email History', strModule = 'Global Component Engine', ysnAvailable = 1  WHERE strNamespace = 'GlobalComponentEngine.view.EmailHistory'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryReceipt')
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId])
        VALUES (N'', N'Inventory Receipt', N'Inventory.view.InventoryReceipt', N'Inventory Receipt', N'', 1,  0) 
	END
	ELSE
	BEGIN
		UPDATE tblSMScreen
        SET  ysnApproval = 1
        WHERE strNamespace = 'Inventory.view.InventoryReceipt'
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryReceipt.TransferOrders')
	BEGIN
		INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId])
        VALUES (N'', N'Inventory Receipt Transfer Orders', N'Inventory.view.InventoryReceipt.TransferOrders', N'Inventory Receipt Transfer Orders', N'', 1,  0) 
	END
	ELSE
	BEGIN
		UPDATE tblSMScreen
        SET  ysnApproval = 1
        WHERE strNamespace = 'Inventory.view.InventoryReceipt.TransferOrders'
	END
GO