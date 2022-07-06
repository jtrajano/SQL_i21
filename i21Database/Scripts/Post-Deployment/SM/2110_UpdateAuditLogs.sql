GO
print('/*******************  BEGIN UPDATING AUDIT LOG FOR 21.1 *******************/')

-- Update Source Screen (User, Customers, Vendor and etc..) from Entity Audit Logs

UPDATE tblSMLog  
SET intOriginalScreenId = D.intOriginalScreenId
FROM tblSMLog A
	INNER JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId
	INNER JOIN tblSMScreen C ON B.intScreenId = C.intScreenId
CROSS APPLY (
	SELECT 
		intScreenId intOriginalScreenId,
		strNamespace
	FROM tblSMScreen 
	WHERE 
		strRoute LIKE ('[#][/]%[/]' + REVERSE(SUBSTRING(REVERSE(strNamespace), 1, CHARINDEX('.', REVERSE(strNamespace)) - 1)) COLLATE Latin1_General_CI_AS + '[/|?]%')
		AND ysnSearch = 0
) D
WHERE ISNULL(A.intOriginalScreenId, 0) = 0 AND C.strNamespace = 'EntityManagement.view.Entity' AND ISNULL(A.strRoute, '') <> '' AND A.strRoute NOT LIKE '?activeTab%'

-- Update Entity Transaction No
UPDATE tblSMTransaction
SET strTransactionNo = ISNULL(C.strEntityNo, strTransactionNo)
FROM tblSMTransaction A 
	INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
	LEFT JOIN tblEMEntity C ON A.intRecordId = C.intEntityId
WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'EntityManagement.view.Entity'

-- Update Contract Transaction No
UPDATE tblSMTransaction
SET strTransactionNo = ISNULL(C.strContractNumber, strTransactionNo)
FROM tblSMTransaction A 
	INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
	LEFT JOIN tblCTContractHeader C ON A.intRecordId = C.intContractHeaderId
WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'ContractManagement.view.Contract'


--Update TimeOff Request Transaction
UPDATE tblSMTransaction
SET strTransactionNo = ISNULL(C.strRequestId, strTransactionNo),
    dtmDate = C.dtmDateFrom,
    intEntityId = C.intEntityEmployeeId
FROM tblSMTransaction A
INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
LEFT JOIN tblPRTimeOffRequest C ON A.intRecordId = C.intPaycheckId
WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'Payroll.view.TimeOffRequest'

--Update Employee Transaction 
UPDATE tblSMTransaction
SET strTransactionNo = ISNULL(C.strEmployeeId, strTransactionNo),
    intEntityId = C.intEntityId
FROM tblSMTransaction A
INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
LEFT JOIN tblPREmployee C ON A.intRecordId = C.intEntityId
WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'Payroll.view.EntityEmployee' 


print('/*******************  END UPDATING AUDIT LOG FOR 21.1  *******************/')

GO

print('/*******************  BEGIN UPDATING INVENTORY AUDIT LOG FOR 21.2 *******************/')
GO
IF EXISTS (SELECT * FROM [tblICCompanyPreference] WHERE ISNULL(ysnUpdateSMTransaction, 0) = 0)
BEGIN 
	--1. Update the item 
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = NULL 
		,strName = i.strItemNo
		,strDescription = i.strDescription
		,dtmDate = NULL 
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICItem i 
			ON i.intItemId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.Item' 

	--2. Update the item location
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = NULL 
		,strName = i.intItemLocationId 
		,strDescription = i.strDescription
		,dtmDate = NULL 
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICItemLocation i 
			ON i.intItemLocationId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.ItemLocation' 

	--3. Update bundle
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = NULL 
		,strName = i.strItemNo 
		,strDescription = i.strDescription
		,dtmDate = NULL 
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICItem i 
			ON i.intItemId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.Bundle' 

	--4. Update category
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = NULL 
		,strName = i.strCategoryCode 
		,strDescription = i.strDescription
		,dtmDate = NULL 
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICCategory i 
			ON i.intCategoryId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.Category' 

	--5. Update commodity
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = NULL 
		,strName = i.strCommodityCode 
		,strDescription = i.strDescription
		,dtmDate = NULL 
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICCommodity i 
			ON i.intCommodityId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.Commodity' 

	--6. Update fuel type
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = NULL 
		,strName = i.intFuelTypeId 
		,strDescription = i.strEquivalenceValue
		,dtmDate = NULL 
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICFuelType i 
			ON i.intFuelTypeId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.FuelType' 

	--7. Update Inventory Adjustment 
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = i.strAdjustmentNo
		,strName = NULL
		,strDescription = i.strDescription
		,dtmDate = i.dtmAdjustmentDate
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICInventoryAdjustment i 
			ON i.intInventoryAdjustmentId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.InventoryAdjustment' 

	--8. Update Inventory Count By Category
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = i.strCountNo
		,strName = NULL
		,strDescription = NULL 
		,dtmDate = i.dtmCountDate
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICInventoryCountByCategory i 
			ON i.intInventoryCountByCategoryId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.InventoryCountByCategory' 

	--9. Update Inventory Count
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = i.strCountNo
		,strName = NULL
		,strDescription = i.strDescription
		,dtmDate = i.dtmCountDate
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICInventoryCount i 
			ON i.intInventoryCountId = A.intRecordId
	WHERE 
		B.strNamespace = 'Inventory.view.InventoryCount' 

	--10. Update Inventory Receipt
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = i.strReceiptNumber
		,strName = NULL
		,strDescription = NULL 
		,dtmDate = i.dtmReceiptDate
		,intEntityId = i.intEntityVendorId
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICInventoryReceipt i 
			ON i.intInventoryReceiptId = A.intRecordId
	WHERE
		B.strNamespace = 'Inventory.view.InventoryReceipt' 

	--11. Update Inventory Shipment
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = i.strShipmentNumber
		,strName = NULL
		,strDescription = NULL 
		,dtmDate = i.dtmShipDate
		,intEntityId = i.intEntityCustomerId
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICInventoryShipment i 
			ON i.intInventoryShipmentId = A.intRecordId
	WHERE
		B.strNamespace = 'Inventory.view.InventoryShipment' 

	--12. Update Transfer
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = i.strTransferNo
		,strName = NULL
		,strDescription = i.strDescription 
		,dtmDate = i.dtmTransferDate
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICInventoryTransfer i 
			ON i.intInventoryTransferId = A.intRecordId
	WHERE
		B.strNamespace = 'Inventory.view.InventoryTransfer' 

	--13. Update Storage Measurement Reading
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = i.strReadingNo
		,strName = NULL
		,strDescription = i.strDescription 
		,dtmDate = i.dtmDate
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICStorageMeasurementReading i 
			ON i.intStorageMeasurementReadingId = A.intRecordId
	WHERE
		B.strNamespace = 'Inventory.view.StorageMeasurementReading' 

	--14. Update Storage Unit
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = NULL 
		,strName = i.strName
		,strDescription = i.strDescription 
		,dtmDate = NULL 
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICStorageLocation i 
			ON i.intStorageLocationId = A.intRecordId
	WHERE
		B.strNamespace = 'Inventory.view.StorageUnit' 

	--15. Update Unit of Measure
	UPDATE tblSMTransaction
	SET 
		strTransactionNo = NULL 
		,strName = i.strUnitMeasure
		,strDescription = i.strUnitType
		,dtmDate = NULL 
		,intEntityId = NULL 
	FROM 
		tblSMTransaction A INNER JOIN tblSMScreen B 
			ON A.intScreenId = B.intScreenId
		LEFT JOIN tblICUnitMeasure i 
			ON i.intUnitMeasureId = A.intRecordId
	WHERE
		B.strNamespace = 'Inventory.view.InventoryUOM' 


	UPDATE [tblICCompanyPreference] SET ysnUpdateSMTransaction = 1 
END 
GO

print('/*******************  END UPDATING INVENTORY AUDIT LOG FOR 21.2 *******************/')
GO


print('/*******************  BEGIN UPDATING RISK MANAGEMENT AUDIT LOG FOR 21.2 *******************/')
GO

BEGIN

	--1. Update Derivative Entry 
	UPDATE tblSMTransaction
	SET strTransactionNo = ISNULL(C.intFutOptTransactionHeaderId, strTransactionNo),
		strName = NULL,                         
		strDescription = NULL,                             
		dtmDate = C.dtmTransactionDate,                          
		intEntityId = NULL                               
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN tblRKFutOptTransaction C ON A.intRecordId = C.intFutOptTransactionId            
	WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'RiskManagement.view.DerivativeEntry'


	--2. Update Basis Entry 
	UPDATE tblSMTransaction
	SET strTransactionNo = NULL,
		strName = C.strPricingType, 
		strDescription = NULL,
		dtmDate = C.dtmM2MBasisDate,
		intEntityId = NULL
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN tblRKM2MBasis C ON A.intRecordId = C.intM2MBasisId          
	WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'RiskManagement.view.BasisEntry'

	--3. Update Match Derivative 
	UPDATE tblSMTransaction
	SET strTransactionNo = ISNULL(C.intMatchNo, strTransactionNo), 
		strName = C.strName,
		strDescription = NULL,
		dtmDate = C.dtmMatchDate,             
		intEntityId = C.intEntityId                
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN vyuRKFuturesPSHeaderNotMapping C ON A.intRecordId = C.intMatchFuturesPSHeaderId    
	WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'RiskManagement.view.MatchDerivatives' 

	--4. Update Settlement Price
	UPDATE tblSMTransaction
	SET strTransactionNo = ISNULL(C.intFutureSettlementPriceId, strTransactionNo),  
		strName = D.strFutMarketName,        
		strDescription = NULL,        
		dtmDate = C.dtmPriceDate,         
		intEntityId = NULL     
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN tblRKFuturesSettlementPrice C ON A.intRecordId = C.intFutureSettlementPriceId 
		LEFT JOIN vyuRKGetFutureSettlementPriceHeader D on A.intRecordId = D.intFutureSettlementPriceId
	WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'RiskManagement.view.FuturesOptionsSettlementPrices' 

	--5. Update Brokerage Account
	UPDATE tblSMTransaction
	SET strTransactionNo = ISNULL(C.strAccountNumber, strTransactionNo),
		strName = D.strName,                  
		strDescription = C.strDescription,  
		dtmDate = NULL,    
		intEntityId = C.intEntityId         
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN tblRKBrokerageAccount C ON A.intRecordId = C.intBrokerageAccountId 
		LEFT JOIN vyuRKBrokerageAccount D ON A.intRecordId = C.intBrokerageAccountId 
	WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'RiskManagement.view.BrokerageAccount' 

	--6. Update Mark to Market
	UPDATE tblSMTransaction
	SET strTransactionNo = ISNULL(C.strRecordName, strTransactionNo),    
		strName = NULL,   
		strDescription = NULL,   
		dtmDate = C.dtmEndDate,
		intEntityId = NULL   
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN tblRKM2MHeader C ON A.intRecordId = C.intM2MHeaderId 
	WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'RiskManagement.view.NewMarkToMarket' 

	--7. Update Futures Trading Months
	UPDATE tblSMTransaction
	SET strTransactionNo = ISNULL(C.intFutureMonthId, strTransactionNo), 
		strName = C.strFutMarketName,      
		strDescription = NULL,
		dtmDate = C.dtmLastTradingDate,   
		intEntityId = NULL 
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN vyuRKGetFutureMonth C ON A.intRecordId = C.intFutureMonthId 
	WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'RiskManagement.view.FuturesTradingMonths' 

	--8. Update Collateral
	UPDATE tblSMTransaction
	SET strTransactionNo = ISNULL(C.strReceiptNo, strTransactionNo),  
		strName = C.strType,     
		strDescription = C.strComments,         
		dtmDate = C.dtmOpenDate,      
		dblAmount = C.dblOriginalQuantity,
		intEntityId = NULL 
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN tblRKCollateral C ON A.intRecordId = C.intCollateralId 
	WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'RiskManagement.view.Collateral' 


	--9. Update Futures Market
	UPDATE tblSMTransaction
	SET strTransactionNo = ISNULL(C.intFutureMarketId, strTransactionNo), 
		strName = C.strFutMarketName,
		strDescription = NULL,
		dtmDate = NULL, 
		intEntityId = NULL 
	FROM tblSMTransaction A
		INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
		LEFT JOIN tblRKFutureMarket C ON A.intRecordId = C.intFutureMarketId 
	WHERE ISNULL(strTransactionNo, '') = '' AND  B.strNamespace = 'RiskManagement.view.FuturesMarket' 

END
GO

print('/*******************  END UPDATING RISK MANAGEMENT AUDIT LOG FOR 21.2 *******************/')
GO





