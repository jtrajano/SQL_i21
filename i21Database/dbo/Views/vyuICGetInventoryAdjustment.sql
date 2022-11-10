CREATE VIEW [dbo].[vyuICGetInventoryAdjustment]
	AS 

SELECT 
	Adj.intInventoryAdjustmentId
	, Adj.intLocationId
	, Location.strLocationName
	, Adj.dtmAdjustmentDate
	, Adj.intAdjustmentType
	, strAdjustmentType = (
		CASE WHEN Adj.intAdjustmentType = 1 THEN 'Quantity'
			WHEN Adj.intAdjustmentType = 2 THEN 'UOM'
			WHEN Adj.intAdjustmentType = 3 THEN 'Item'
			WHEN Adj.intAdjustmentType = 4 THEN 'Lot Status' 
			WHEN Adj.intAdjustmentType = 5 THEN 'Split Lot'
			WHEN Adj.intAdjustmentType = 6 THEN 'Expiry Date'
			WHEN Adj.intAdjustmentType = 7 THEN 'Lot Merge'
			WHEN Adj.intAdjustmentType = 8 THEN 'Lot Move'
			WHEN Adj.intAdjustmentType = 9 THEN 'Lot Owner'
			WHEN Adj.intAdjustmentType = 10 THEN 'Opening Inventory'
			WHEN Adj.intAdjustmentType = 11 THEN 'Lot Weight'
			WHEN Adj.intAdjustmentType = 12 THEN 'Closing Balance'
		END) COLLATE Latin1_General_CI_AS
	, Adj.strAdjustmentNo
	, Adj.strDescription
	, Adj.intSort
	, Adj.ysnPosted
	, Adj.intEntityId
	, strUser = UserEntity.strName
	, Adj.dtmPostedDate
	, Adj.dtmUnpostedDate
	, Adj.intSourceId
	, Adj.intSourceTransactionTypeId
	, Adj.intConcurrencyId
	, Link.strTransactionFrom
	, Link.strSource
	, Link.strTicketNumber
	, Link.strInvoiceNumber
	, Link.strShipmentNumber
	, Link.strReceiptNumber
	, fiscal.strPeriod strAccountingPeriod
FROM tblICInventoryAdjustment Adj
LEFT JOIN vyuICInventoryAdjustmentSourceLink Link
	on Link.intInventoryAdjustmentId = Adj.intInventoryAdjustmentId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Adj.intLocationId
LEFT JOIN tblEMEntity UserEntity ON UserEntity.intEntityId = Adj.intEntityId
OUTER APPLY (
	SELECT TOP 1 fp.strPeriod
	FROM tblGLFiscalYearPeriod fp
	WHERE Adj.dtmAdjustmentDate BETWEEN fp.dtmStartDate AND fp.dtmEndDate
) fiscal