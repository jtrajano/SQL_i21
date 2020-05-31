IF EXISTS (SELECT 1 FROM dbo.tblRKFutOptTransactionHeader WHERE dtmTransactionDate is null)
BEGIN
	UPDATE tblRKFutOptTransactionHeader
	SET dtmTransactionDate = B.dtmTransactionDate,intSelectedInstrumentTypeId = B.intSelectedInstrumentTypeId,
		strSelectedInstrumentType = case when isnull(B.intSelectedInstrumentTypeId,1) = 1 then 'Exchange Traded' 
		WHEN B.intSelectedInstrumentTypeId = 2 THEN 'OTC'
										ELSE 'OTC - Others' END
	FROM tblRKFutOptTransactionHeader A
	JOIN tblRKFutOptTransaction B
		ON A.intFutOptTransactionHeaderId = B.intFutOptTransactionHeaderId
	where A.dtmTransactionDate is null
END

GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKDateFilterFor360')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tblRKDateFilterFor360)
BEGIN
	INSERT INTO tblRKDateFilterFor360 (intConcurrencyId) VALUES(1)
END
END
GO
IF EXISTS ( SELECT 1 FROM tblRKCompanyPreference WHERE ISNULL(strM2MView, '') = '')
BEGIN
	UPDATE tblRKCompanyPreference SET strM2MView = 'View 1 - Standard' WHERE ISNULL(strM2MView, '') = ''
END
GO

GO
IF EXISTS ( SELECT 1 FROM tblRKCompanyPreference WHERE ISNULL(dblRefreshRate, 0) = 0)
BEGIN
	UPDATE tblRKCompanyPreference SET dblRefreshRate = 5 WHERE ISNULL(dblRefreshRate, 0) = 0
END
GO

IF EXISTS ( SELECT 1 FROM tblRKCompanyPreference WHERE ISNULL(strDateTimeFormat, '') = '')
BEGIN
	UPDATE tblRKCompanyPreference SET strDateTimeFormat = 'MM DD YYYY HH:MI' WHERE ISNULL(strDateTimeFormat, '') = ''
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'vyuRKDPRHedgeDailyPositionDetail')
BEGIN
	EXEC ('DROP VIEW vyuRKDPRHedgeDailyPositionDetail')
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'vyuRKDPRInvDailyPositionDetail')
BEGIN
	EXEC ('DROP VIEW vyuRKDPRInvDailyPositionDetail')
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'vyuRKGetSequenceMonth')
BEGIN
	EXEC ('DROP VIEW vyuRKGetSequenceMonth')
END
GO

PRINT ('/*******************  START Syncing Commodity Attributes to RM *******************/')
GO
EXEC uspRKSyncCommodityMarketAttribute -- saving to an RM table with constraint to disallow deletion of commodity attributes in IC
GO
PRINT('/*******************  END Syncing Commodity Attributes to RM *******************/')
GO
IF NOT EXISTS (SELECT 1 FROM tblSMStartingNumber WHERE ISNULL(strTransactionType, '') = 'Currency Exposure' and strModule='Risk Management')
BEGIN
	INSERT INTO tblSMStartingNumber (strTransactionType,intNumber,strPrefix,strModule,ysnUseLocation,ysnResetNumber,dtmResetDate,ysnEnable,intConcurrencyId) 
	VALUES('Currency Exposure',1,'','Risk Management',0,0,getdate(),1,1)
END
GO

PRINT ('/*******************  START Syncing Commodity Attributes to RM *******************/')
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKLogAction')
BEGIN
	SET IDENTITY_INSERT tblRKLogAction ON

	INSERT INTO tblRKLogAction(intLogActionId
		, strActionIn
		, strDescription)
	SELECT intActionId
		, strActionIn
		, strDescription
	FROM (
		SELECT intActionId = 1, strActionIn = 'Rebuild', strDescription = 'Logs created upon rebuild.'
		UNION ALL SELECT 2, 'Produce', 'Inventory Increasing from Posted Work Order'
		UNION ALL SELECT 3, 'Consume', 'Inventory Decreasing from posted Work Order'
		UNION ALL SELECT 4, 'Inventory Transfer', 'Positive and negative change from transferring inventory from one location to another.'
		UNION ALL SELECT 5, 'Receipt on Purchase Priced Contract', 'Inventory increasing from receipt on a purchase priced contract or priced portion of a purchase basis contract'
		UNION ALL SELECT 6, 'Receipt on Purchase Basis Contract (PBD)', 'Inventory increasing from receipt on Purchase Basis contract (unpriced Portion)'
		UNION ALL SELECT 7, 'Receipt on Company Owned Storage', 'Inventory increasing from receipt on Storage Type of "Company Owned"'
		UNION ALL SELECT 8, 'Receipt on Spot Priced', 'Inventory increasing from receipt of units Spot priced as scale ( can either have distribution type of spot or units can have split application in manual screen with some going to spot)'
		UNION ALL SELECT 9, 'Customer owned to Company owned Storage', 'Settle Storage to: Spot or Purchase Priced or Purchase Basis Contract. Transfer storage from Customer owned to Company owned '
		UNION ALL SELECT 10, 'Delivery on Sales Priced Contract', 'Inventory Decreasing from shipment on a Sales priced contract or priced portion of a Sales basis contract'
		UNION ALL SELECT 11, 'Delivery on Sales Basis Contract (SBD)', 'Inventory Decreasing from shipment on Sales Basis contract (unpriced Portion)'
		UNION ALL SELECT 12, 'Shipment on Spot Priced', 'Inventory Decreasing from shipment of units Spot priced as scale ( can either have distribution type of spot or units can have split application in manual screen with some going to spot)'
		UNION ALL SELECT 13, 'Distributed Ticket', 'Happens when distributing ticket with Hold distribution type.'
		UNION ALL SELECT 14, 'Undistributed Ticket', 'Happens when undistributing ticket with Hold distribution type.'
		UNION ALL SELECT 15, 'Created Voucher', 'Created Voucher.'
		UNION ALL SELECT 16, 'Created Invoice', 'Created Invoice.'
		UNION ALL SELECT 17, 'Created Price', 'Created Pricing Layer.'
		UNION ALL SELECT 18, 'Inventory Shipped on Basis Delivery', 'Shipment is invoiced.'
		UNION ALL SELECT 19, 'Inventory Received on Basis Delivery', 'Receipt is vouchered.'
		UNION ALL SELECT 20, 'Inventory Adjustment - Quantity', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 21, 'Inventory Adjustment - UOM', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 22, 'Inventory Adjustment - Item', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 23, 'Inventory Adjustment - Lot Status', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 24, 'Inventory Adjustment - Split Lot', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 25, 'Inventory Adjustment - Expiry Date', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 26, 'Inventory Adjustment - Lot Merge', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 27, 'Inventory Adjustment - Lot Move', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 28, 'Inventory Adjustment - Ownership', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 29, 'Inventory Adjustment - Opening Inventory', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 30, 'Inventory Adjustment - Lot Weight', 'Positive or negative change to inventory based on Change from Posted Inventory adjustment'
		UNION ALL SELECT 31, 'Inbound Shipment', 'Positive or negative change to inventory based on Load Schedule -> Inbound Shipment'
		UNION ALL SELECT 32, 'Outbound Shipment', 'Positive or negative change to inventory based on Load Schedule -> Outbound Shipment'
		UNION ALL SELECT 33, 'Company Owned to Customer Owned storage', 'Unpost Settle Storage (settled customer-owned storage). Transfer storage from Company owned to Customer owned; Unpost of customer owned to company owned storage'
		UNION ALL SELECT 34, 'Created Derivative', 'Created Derivative Entries.'
		UNION ALL SELECT 35, 'Collateral Receipts', 'Created Collateral receipts.'
		UNION ALL SELECT 36, 'Match Derivatives', 'Created Match Derivatives.'
		UNION ALL SELECT 37, 'Settle Storage - Company owned storage', 'Company owned storage is settled or reversed'
		UNION ALL SELECT 38, 'Collateral Adjustments', 'Created collateral receipt line items.'
		UNION ALL SELECT 39, 'Options', 'Created options lifecycle transactions.'
		UNION ALL SELECT 40, 'Receipt on Customer Owned Storage', 'Inventory increasing from receipt on Storage Type of "Customer Owned"'
		UNION ALL SELECT 41, 'Inventory Shipment', 'Reducing a storage (company or customer owned) thru Load Out ticket'
		UNION ALL SELECT 42, 'Created Contract', 'Created contract'
		UNION ALL SELECT 43, 'Updated Contract', 'Updated contract when there was changes in quantity, slice, and status'
		UNION ALL SELECT 44, 'Removed Sequence', 'When a sequence removed.'
		UNION ALL SELECT 45, 'Receipt on DP Contract', 'Inventory increasing from receipt on a purchase dp contract'
		UNION ALL SELECT 46, 'Inventory Shipped on Priced Delivery', 'Shipment is invoiced.'
		UNION ALL SELECT 47, 'Inventory Received on Priced Delivery', 'Receipt is vouchered.'
		UNION ALL SELECT 48, 'Posted Invoice', 'Sales In-Transit decreasing when Invoice is posted'
		UNION ALL SELECT 49, 'Distribution (receipt) to DP Contract', 'Quantities increase/decrease in ticket distribution to Purchase DP contract.'
		UNION ALL SELECT 50, 'Distribution (shipment) to DP Contract', 'Quantities increase/decrease in ticket distribution to Sale DP contract.'
		UNION ALL SELECT 51, 'Inventory Shipped on Cash Delivery', 'Inventory Shipment shipped cash quantities.'
		UNION ALL SELECT 52, 'Inventory Received on Cash Delivery', 'Inventory receipt received cash quantities.'
		UNION ALL SELECT 53, 'Settle Storage on Basis Delivery', 'Settle Storage settled basis quantities.'
		UNION ALL SELECT 54, 'Canceled Sequence', 'Canceled Sequence.'
		UNION ALL SELECT 55, 'Deleted Pricing', 'Deleted Pricing.'
		UNION ALL SELECT 56, 'Updated Derivative', 'Updated Derivative Entries.'
		UNION ALL SELECT 57, 'Deleted Derivative', 'Deleted Derivative Entries.'
		UNION ALL SELECT 58, 'Transfer Storage to DP (Price Later)', 'Transfer Storage to DP (Price Later)'
		UNION ALL SELECT 59, 'Short Closed Sequence', 'Short Closed Sequence.'	
	) tbl
	WHERE intActionId NOT IN (SELECT intLogActionId FROM tblRKLogAction)

	SET IDENTITY_INSERT tblRKLogAction OFF

END
GO