CREATE PROCEDURE [dbo].[uspICEdiGenerateReceipt] @VendorId INT, @LocationId INT, @UniqueId NVARCHAR(100), @UserId INT
AS
-------------------------- BUSINESS -----------------------------------------------------------
DECLARE @Stores TABLE(FileIndex INT, RecordIndex INT, RecordType NVARCHAR(50), StoreNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS)
DECLARE @Items TABLE(FileIndex INT, RecordIndex INT, ItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS, ItemUpc NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	ParentItemCode NVARCHAR(100), [PriceMulti-pack] NUMERIC(38, 20), Quantity NUMERIC(38, 20), 
	RecordType NVARCHAR(50), RetailPrice NUMERIC(38, 20), UnitCost NUMERIC(38, 20),
	UnitMultiplier NUMERIC(38, 20), UnitOfMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS, VendorItemCode NVARCHAR(50) COLLATE Latin1_General_CI_AS)
DECLARE @Invoices TABLE(FileIndex INT, RecordIndex INT, InvoiceDate DATETIME, InvoiceNumber NVARCHAR(50), InvoiceTotal INT, RecordType NVARCHAR(50), VendorCode NVARCHAR(50))
DECLARE @Charges TABLE(FileIndex INT, RecordIndex INT, Amount NUMERIC(38,20), ChargeType NVARCHAR(50), ItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS, RecordType NVARCHAR(50))

INSERT INTO @Stores EXEC [dbo].[uspICEdiGenerateMappingObjects] '0', @UniqueId
INSERT INTO @Items EXEC [dbo].[uspICEdiGenerateMappingObjects] 'B', @UniqueId
INSERT INTO @Invoices EXEC [dbo].[uspICEdiGenerateMappingObjects] 'A', @UniqueId
INSERT INTO @Charges EXEC [dbo].[uspICEdiGenerateMappingObjects] 'C', @UniqueId

DELETE FROM tblICEdiMap WHERE UniqueId = @UniqueId

DEClARE @ReceiptStagingTable ReceiptStagingTable
DECLARE @ReceiptOtherChargesTableType ReceiptOtherChargesTableType
DECLARE @ReceiptItemLotStagingTable ReceiptItemLotStagingTable

DECLARE @StoreId INT
SELECT TOP 1 @StoreId = intStoreStoreId
FROM vyuAPVendor
WHERE intEntityId = @VendorId

DECLARE @ReceiptStore TABLE(FileIndex INT, RecordIndex INT, RecordType NVARCHAR(50), StoreNumber NVARCHAR(50), intStoreId INT)
INSERT INTO @ReceiptStore(FileIndex, RecordIndex, RecordType, StoreNumber, intStoreId)
SELECT s.FileIndex, s.RecordIndex, s.RecordType, s.StoreNumber, st.intStoreId
FROM @Stores s
	INNER JOIN tblSTStore st ON st.intStoreNo = CAST(s.StoreNumber AS INT)
WHERE CAST(s.StoreNumber AS INT) = st.intStoreNo


INSERT INTO @ReceiptStagingTable(strReceiptType, intEntityVendorId, intShipFromId, intLocationId, dtmDate, intSourceId, intItemId, 
	intItemLocationId, intItemUOMId, dblQty, dblCost, intCostUOMId, intSourceType, strVendorRefNo, intCurrencyId, intShipViaId)
SELECT 
	strReceiptType = 'Direct', 
	intEntityVendorId = @VendorId, 
	intShipFromId = el.intEntityLocationId, 
	intLocationId = @LocationId, 
	dtmDate = CASE WHEN ISDATE(inv.InvoiceDate) = 1 THEN CAST(inv.InvoiceDate AS DATETIME) ELSE NULL END,
	intSourceId = 0, 
	intItemId = it.intItemId, 
	intItemLocationId = il.intItemLocationId,
	intItemUOMId = ISNULL(iu.intItemUOMId, im.intItemUOMId), 
	dblQuantity = i.Quantity, 
	dblCost = i.UnitCost, 
	intCostUOMId = ISNULL(iu.intItemUOMId, im.intItemUOMId), 
	intSourceType = 0,
	strVendorRefNo = inv.InvoiceNumber,
	intCurrencyId = v.intCurrencyId, 
	intShipVia = el.intShipViaId
FROM @Invoices inv
	INNER JOIN @ReceiptStore st ON inv.FileIndex = st.FileIndex
	INNER JOIN @Items i ON i.FileIndex = inv.FileIndex
	INNER JOIN tblICItemUOM lookupUom ON ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode) = i.ItemUpc 
	INNER JOIN tblICItem it ON it.intItemId = lookupUom.intItemId
	INNER JOIN vyuAPVendor v ON v.intEntityId = @VendorId
	LEFT OUTER JOIN tblEMEntityLocation el ON el.intEntityId = @VendorId
		AND el.ysnActive = 1
		AND el.intEntityLocationId = v.intDefaultLocationId
	INNER JOIN tblICItemLocation il ON il.intItemId = it.intItemId
		AND il.intLocationId = @LocationId
	LEFT OUTER JOIN tblICItemUOM im ON im.intItemId = it.intItemId
		AND im.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = i.UnitOfMeasure
	LEFT JOIN tblICItemUOM iu ON iu.intItemId = it.intItemId
		AND iu.intUnitMeasureId = u.intUnitMeasureId
WHERE st.intStoreId = @StoreId

INSERT INTO @ReceiptOtherChargesTableType(intEntityVendorId, strReceiptType, intLocationId, intShipViaId, intShipFromId, intCurrencyId, intChargeId, strCostMethod, dblAmount)
SELECT 
	intEntityVendorId = @VendorId, 
	strReceiptType = 'Direct',
	intLocationId = @LocationId, 
	intShipViaId = v.intShipViaId, 
	intShipFromId = el.intEntityLocationId,
	intCurrencyId = v.intCurrencyId,
	intChargeId = i.intItemId,
	strCostMethod = 'Amount',
	dblAmount = c.Amount
FROM @Charges c
	INNER JOIN @ReceiptStore st ON c.FileIndex = st.FileIndex
	INNER JOIN tblICItem i ON i.strItemNo = c.ItemDescription
	INNER JOIN vyuAPVendor v ON v.intEntityId = @VendorId
	LEFT OUTER JOIN tblEMEntityLocation el ON el.intEntityId = @VendorId
		AND el.ysnActive = 1
		AND el.intEntityLocationId = v.intDefaultLocationId
WHERE st.intStoreId = @StoreId
	AND c.Amount != 0

IF EXISTS(SELECT * FROM @ReceiptStagingTable)
	EXEC dbo.uspICAddItemReceipt @ReceiptStagingTable, @ReceiptOtherChargesTableType, @UserId, @ReceiptItemLotStagingTable