GO
	PRINT N'BEGIN REPLICATION CONFIGURATION'

	-- Parent

	/* System Manager */
	DECLARE @systemManager INT
	SELECT @systemManager = intModuleId FROM tblSMModule WHERE strModule = 'System Manager'

	DECLARE @usersId INT
	SELECT TOP 1 @usersId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.EntityUser'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @usersId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @usersId, N'parent')
	END

	DECLARE @roleId INT
	SELECT TOP 1 @roleId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.UserRole'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @roleId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @roleId, N'parent')
	END

	DECLARE @countryId INT
	SELECT TOP 1 @countryId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.Country'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @countryId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @countryId, N'parent')
	END
	
	DECLARE @currencyId INT
	SELECT TOP 1 @currencyId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.Currency'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @currencyId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @currencyId, N'parent')
	END
		
	DECLARE @shipviaId INT
	SELECT TOP 1 @shipviaId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.EntityShipVia'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @shipviaId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @shipviaId, N'parent')
	END
	
	DECLARE @paymentMethodId INT
	SELECT TOP 1 @paymentMethodId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.PaymentMethod'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @paymentMethodId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @paymentMethodId, N'parent')
	END

	DECLARE @termId INT
	SELECT TOP 1 @termId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.Term'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @termId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @termId, N'parent')
	END

	DECLARE @companyLocationId INT
	SELECT TOP 1 @companyLocationId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.CompanyLocation'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @companyLocationId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @companyLocationId, N'parent')
	END

	DECLARE @freightTermId INT
	SELECT TOP 1 @freightTermId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.FreightTerm'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @freightTermId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @freightTermId, N'parent')
	END

	DECLARE @cityId INT
	SELECT TOP 1 @cityId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.City'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @cityId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @cityId, N'parent')
	END

	DECLARE @currencyExchangeRateId INT
	SELECT TOP 1 @currencyExchangeRateId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.CurrencyExchangeRate'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @currencyExchangeRateId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @currencyExchangeRateId, N'parent')
	END

	DECLARE @currencyExchangeRateTypeId INT
	SELECT TOP 1 @currencyExchangeRateTypeId = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.CurrencyExchangeRateType'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @currencyExchangeRateTypeId) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @currencyExchangeRateTypeId, N'parent')
	END
	
	DECLARE @lineOfBusiness INT
	SELECT TOP 1 @lineOfBusiness = intScreenId FROM tblSMScreen WHERE strNamespace = 'i21.view.LineOfBusiness'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @lineOfBusiness) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @lineOfBusiness, N'parent')
	END

	DECLARE @screenLabel INT
	SELECT TOP 1 @screenLabel = intScreenId FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.ScreenLabel'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @screenLabel) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @screenLabel, N'parent')
	END
	
	DECLARE @reportLabel INT
	SELECT TOP 1 @reportLabel = intScreenId FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.ReportLabel'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @reportLabel) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@systemManager, @reportLabel, N'parent')
	END
	
	/* Risk Management */
	DECLARE @riskManagement INT
	SELECT @riskManagement = intModuleId FROM tblSMModule WHERE strModule = 'Risk Management'

	DECLARE @brokerageAccount INT
	SELECT TOP 1 @brokerageAccount = intScreenId FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.BrokerageAccount'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @brokerageAccount) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@riskManagement, @brokerageAccount, N'parent')
	END

	DECLARE @entityFuturesBroker INT
	SELECT TOP 1 @entityFuturesBroker = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor?searchCommand=EntityFuturesBroker'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @entityFuturesBroker) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@riskManagement, @entityFuturesBroker, N'parent')
	END

	DECLARE @futuresOptionsSettlementPrices INT
	SELECT TOP 1 @futuresOptionsSettlementPrices = intScreenId FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.FuturesOptionsSettlementPrices'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @futuresOptionsSettlementPrices) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@riskManagement, @futuresOptionsSettlementPrices, N'parent')
	END

	DECLARE @basisEntry INT
	SELECT TOP 1 @basisEntry = intScreenId FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.BasisEntry'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @basisEntry) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@riskManagement, @basisEntry, N'parent')
	END

	/* Quality */
	DECLARE @quality INT
	SELECT @quality = intModuleId FROM tblSMModule WHERE strModule = 'Quality'

	DECLARE @qualityParameters INT
	SELECT TOP 1 @qualityParameters = intScreenId FROM tblSMScreen WHERE strNamespace = 'Quality.view.QualityParameters'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @qualityParameters) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@quality, @qualityParameters, N'parent')
	END

	/* Payroll */
	DECLARE @payroll INT
	SELECT @payroll = intModuleId FROM tblSMModule WHERE strModule = 'Payroll'

	DECLARE @employee INT
	SELECT TOP 1 @employee = intScreenId FROM tblSMScreen WHERE strNamespace = 'Payroll.view.EntityEmployee'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @employee) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@payroll, @employee, N'parent')
	END

	/* Logistics */
	DECLARE @logistics INT
	SELECT @logistics = intModuleId FROM tblSMModule WHERE strModule = 'Logistics'

	DECLARE @shippingLine INT
	SELECT TOP 1 @shippingLine = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor?searchCommand=EntityShippingLine'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @shippingLine) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @shippingLine, N'parent')
	END

	DECLARE @forwardingAgent INT
	SELECT TOP 1 @forwardingAgent = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor?searchCommand=EntityForwardingAgent'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @forwardingAgent) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @forwardingAgent, N'parent')
	END

	DECLARE @entityTerminal INT
	SELECT TOP 1 @entityTerminal = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor?searchCommand=EntityTerminal'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @entityTerminal) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @entityTerminal, N'parent')
	END
	
	DECLARE @shippingMode INT
	SELECT TOP 1 @shippingMode = intScreenId FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ShippingMode'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @shippingMode) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @shippingMode, N'parent')
	END
			
	DECLARE @reasonCode INT
	SELECT TOP 1 @reasonCode = intScreenId FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ReasonCode'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @reasonCode) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @reasonCode, N'parent')
	END
	
	DECLARE @containerType INT
	SELECT TOP 1 @containerType = intScreenId FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ContainerType'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @containerType) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @containerType, N'parent')
	END

	DECLARE @warehouseRateMatrix INT
	SELECT TOP 1 @warehouseRateMatrix = intScreenId FROM tblSMScreen WHERE strNamespace = 'Logistics.view.WarehouseRateMatrix'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @warehouseRateMatrix) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @warehouseRateMatrix, N'parent')
	END

	/* Inventory */
	DECLARE @inventoryId INT
	SELECT @inventoryId = intModuleId FROM tblSMModule WHERE strModule = 'Inventory'

	DECLARE @item INT
	SELECT TOP 1 @item = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Item'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @item) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @item, N'parent')
	END

	DECLARE @commodity INT
	SELECT TOP 1 @commodity = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Commodity'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @commodity) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @commodity, N'parent')
	END

	DECLARE @category INT
	SELECT TOP 1 @category = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.Category'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @category) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @category, N'parent')
	END

	DECLARE @inventoryUOM INT
	SELECT TOP 1 @inventoryUOM = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryUOM'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @inventoryUOM) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @inventoryUOM, N'parent')
	END
	
	DECLARE @storageUnit INT
	SELECT TOP 1 @storageUnit = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.StorageUnit'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @storageUnit) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @storageUnit, N'parent')
	END
	
	/* General Ledger */
	DECLARE @generalLedger INT
	SELECT @generalLedger = intModuleId FROM tblSMModule WHERE strModule = 'General Ledger'

	DECLARE @fiscalYear INT
	SELECT TOP 1 @fiscalYear = intScreenId FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.FiscalYear'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @fiscalYear) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@generalLedger, @fiscalYear, N'parent')
	END
	
	DECLARE @chartOfAccounts INT
	SELECT TOP 1 @chartOfAccounts = intScreenId FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.ChartOfAccounts'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @chartOfAccounts) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@generalLedger, @chartOfAccounts, N'parent')
	END
	
	DECLARE @accountStructure INT
	SELECT TOP 1 @accountStructure = intScreenId FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.AccountStructure'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @accountStructure) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@generalLedger, @accountStructure, N'parent')
	END

	DECLARE @accountGroups INT
	SELECT TOP 1 @accountGroups = intScreenId FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.AccountGroups'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @accountGroups) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@generalLedger, @accountGroups, N'parent')
	END
	
	/* Contract Management */
	DECLARE @contractManagement INT
	SELECT @contractManagement = intModuleId FROM tblSMModule WHERE strModule = 'Contract Management'

	DECLARE @condition INT
	SELECT TOP 1 @condition = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Condition'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @condition) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @condition, N'parent')
	END
	
	DECLARE @contractDocument INT
	SELECT TOP 1 @contractDocument = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.ContractDocument'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @contractDocument) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @contractDocument, N'parent')
	END
	
	DECLARE @associations INT
	SELECT TOP 1 @associations = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Associations'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @associations) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @associations, N'parent')
	END

	DECLARE @INCOShipTerm INT
	SELECT TOP 1 @INCOShipTerm= intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.INCOShipTerm'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @associations) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @INCOShipTerm, N'parent')
	END

	DECLARE @AOPVsActual INT
	SELECT TOP 1 @AOPVsActual= intScreenId FROM tblSMScreen WHERE strNamespace = 'Reporting.view.ReportManager?group=Contract Management&report=AOPVsActual&direct=true&showCriteria=true'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @associations) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @AOPVsActual, N'parent')
	END
		
	DECLARE @weightGrades INT
	SELECT TOP 1 @weightGrades= intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.WeightGrades'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @associations) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @weightGrades, N'parent')
	END
	
	DECLARE @banks INT
	SELECT TOP 1 @banks = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Banks'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @associations) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @banks, N'parent')
	END
	
	DECLARE @bankAccounts INT
	SELECT TOP 1 @bankAccounts = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.BankAccounts'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @associations) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @bankAccounts, N'parent')
	END

	/* Accounts Receivable */
	DECLARE @accountsReceivableId INT
	SELECT @accountsReceivableId = intModuleId FROM tblSMModule WHERE strModule = 'Sales'

	DECLARE @customer INT
	SELECT TOP 1 @customer = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntityCustomer'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @customer) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@accountsReceivableId, @customer, N'parent')
	END

	DECLARE @salesperson INT
	SELECT TOP 1 @salesperson = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntitySalesperson'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @salesperson) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@accountsReceivableId, @salesperson, N'parent')
	END
	
	/* Accounts Payable */
	DECLARE @accountsPayableId INT
	SELECT @accountsPayableId = intModuleId FROM tblSMModule WHERE strModule = 'Purchasing'

	DECLARE @vendor INT
	SELECT TOP 1 @vendor = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @vendor) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@accountsPayableId, @vendor, N'parent')
	END
	
	-- Subsidiary

	/* Risk Management */
	DECLARE @optionsLifecycle INT
	SELECT TOP 1 @optionsLifecycle = intScreenId FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.OptionsLifecycle'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @optionsLifecycle) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@riskManagement, @optionsLifecycle, N'subsidiary')
	END
	
	DECLARE @derivativeEntry INT
	SELECT TOP 1 @derivativeEntry = intScreenId FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.DerivativeEntry'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @derivativeEntry) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@riskManagement, @derivativeEntry, N'subsidiary')
	END
	
	DECLARE @assignFuturesToContracts INT
	SELECT TOP 1 @assignFuturesToContracts = intScreenId FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.AssignFuturesToContracts'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @assignFuturesToContracts) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@riskManagement, @assignFuturesToContracts, N'subsidiary')
	END
	
	DECLARE @matchDerivatives INT
	SELECT TOP 1 @matchDerivatives = intScreenId FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.MatchDerivatives'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @matchDerivatives) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@riskManagement, @matchDerivatives, N'subsidiary')
	END

	/* Quality */
	DECLARE @qualitySample INT
	SELECT TOP 1 @qualitySample = intScreenId FROM tblSMScreen WHERE strNamespace = 'Quality.view.QualitySample'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @qualitySample) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@quality, @qualitySample, N'subsidiary')
	END

	/* Logistics */
	DECLARE @weightClaims INT
	SELECT TOP 1 @weightClaims = intScreenId FROM tblSMScreen WHERE strNamespace = 'Logistics.view.WeightClaims'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @weightClaims) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @weightClaims, N'subsidiary')
	END

	DECLARE @shipmentSchedule INT
	SELECT TOP 1 @shipmentSchedule = intScreenId FROM tblSMScreen WHERE strNamespace = 'Logistics.view.ShipmentSchedule'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @shipmentSchedule) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@logistics, @shipmentSchedule, N'subsidiary')
	END

	/* Inventory */
	DECLARE @inventoryAdjustment INT
	SELECT TOP 1 @inventoryAdjustment = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryAdjustment'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @inventoryAdjustment) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @inventoryAdjustment, N'parent')
	END

	DECLARE @inventoryReceipt INT
	SELECT TOP 1 @inventoryReceipt = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryReceipt'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @inventoryReceipt) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @inventoryReceipt, N'parent')
	END
	
	DECLARE @inventoryShipment INT
	SELECT TOP 1 @inventoryShipment = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryShipment'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @inventoryShipment) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @inventoryShipment, N'parent')
	END

	DECLARE @inventoryTransfer INT
	SELECT TOP 1 @inventoryTransfer = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryTransfer'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @inventoryTransfer) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @inventoryTransfer, N'parent')
	END
	
	DECLARE @InventoryCount INT
	SELECT TOP 1 @InventoryCount = intScreenId FROM tblSMScreen WHERE strNamespace = 'Inventory.view.InventoryCount'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @InventoryCount) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@inventoryId, @InventoryCount, N'parent')
	END
	
	DECLARE @contract INT
	SELECT TOP 1 @contract = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @contract) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@contractManagement, @contract, N'subsidiary')
	END
		
	/* Accounts Receivable */
	DECLARE @invoice INT
	SELECT TOP 1 @invoice = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.Invoice'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @invoice) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@accountsReceivableId, @invoice, N'subsidiary')
	END

	/* Accounts Payable */
	DECLARE @voucher INT
	SELECT TOP 1 @voucher = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Voucher'
	IF NOT EXISTS (SELECT TOP 1 1 FROM [tblSMReplicationConfiguration] WHERE intScreenId = @voucher) 
	BEGIN
		INSERT [dbo].[tblSMReplicationConfiguration] ([intModuleId], [intScreenId], [strType]) 
		VALUES (@accountsPayableId, @voucher, N'subsidiary')
	END

	PRINT N'END REPLICATION CONFIGURATION'
GO