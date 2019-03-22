CREATE PROCEDURE [dbo].[uspICEdiGenerateReceipt] @VendorId INT, @LocationId INT, @StoreLocations UdtCompanyLocations READONLY, @UniqueId NVARCHAR(100), @UserId INT, @ErrorCount INT OUTPUT, @TotalRows INT OUTPUT
AS
-------------------------- BUSINESS -----------------------------------------------------------
DECLARE @Start DATETIME
SET @Start = GETDATE()

DECLARE @Stores TABLE(FileIndex INT, RecordIndex INT, RecordType NVARCHAR(50), StoreNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS)
DECLARE @Items TABLE(FileIndex INT, RecordIndex INT, ItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS, ItemUpc NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	ParentItemCode NVARCHAR(100), [PriceMulti-pack] NUMERIC(38, 20), Quantity NUMERIC(38, 20), 
	RecordType NVARCHAR(50), RetailPrice NUMERIC(38, 20), UnitCost NUMERIC(38, 20),
	UnitMultiplier NUMERIC(38, 20), UnitOfMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS, VendorItemCode NVARCHAR(50) COLLATE Latin1_General_CI_AS)
DECLARE @Invoices TABLE(FileIndex INT, RecordIndex INT, InvoiceDate DATETIME, InvoiceNumber NVARCHAR(50), InvoiceTotal NUMERIC(38, 20), RecordType NVARCHAR(50), VendorCode NVARCHAR(50))
DECLARE @Charges TABLE(FileIndex INT, RecordIndex INT, Amount NUMERIC(38,20), ChargeType NVARCHAR(50), ItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS, RecordType NVARCHAR(50))

INSERT INTO @Stores EXEC [dbo].[uspICEdiGenerateMappingObjects] '0', @UniqueId
INSERT INTO @Items EXEC [dbo].[uspICEdiGenerateMappingObjects] 'B', @UniqueId
INSERT INTO @Invoices EXEC [dbo].[uspICEdiGenerateMappingObjects] 'A', @UniqueId
INSERT INTO @Charges EXEC [dbo].[uspICEdiGenerateMappingObjects] 'C', @UniqueId

-- Implied decimal conversions
UPDATE @Invoices SET InvoiceTotal = CASE WHEN ISNULL(InvoiceTotal, 0) = 0 THEN 0 ELSE InvoiceTotal / 100.00 END
UPDATE @Items
	SET UnitCost = CASE WHEN ISNULL(UnitCost, 0) = 0 THEN 0 ELSE UnitCost / 100.00 END,
	RetailPrice = CASE WHEN ISNULL(RetailPrice, 0) = 0 THEN 0 ELSE RetailPrice / 100.00 END
UPDATE @Charges SET Amount = CASE WHEN ISNULL(Amount, 0) = 0 THEN 0 ELSE Amount / 100.00 END

DECLARE @LogId INT
SELECT @LogId = intImportLogId FROM tblICImportLog WHERE strUniqueId = (SELECT TOP 1 strUniqueId FROM tblICEdiPricebook)

IF(@LogId IS NULL)
BEGIN
	INSERT INTO tblICImportLog(strDescription, strType, strFileType, strFileName, dtmDateImported, intUserEntityId, intConcurrencyId)
	SELECT 'Import Receipts successful', 'EDI', 'Plain Text', '', GETDATE(), @UserId, 1
	SET @LogId = @@IDENTITY
END

DELETE FROM tblICEdiMap WHERE UniqueId = @UniqueId

-- It's needed to increment each store indices by 1 since the reset file index is now based on the invoice record.
-- Need to equalize file indices of all groupings
UPDATE @Stores SET FileIndex = FileIndex + 1
-- Regenerate missing stores using a default store. The number of invoices should be equal to the number of stores.
INSERT INTO @Stores(FileIndex, RecordIndex, RecordType, StoreNumber)
SELECT missing.FileIndex, -1, '0', CAST(st.intStoreNo AS NVARCHAR(500))
FROM tblSTStore st
	INNER JOIN @StoreLocations sl ON sl.intCompanyLocationId = st.intCompanyLocationId
	CROSS JOIN (
		SELECT FileIndex FROM @Invoices
		EXCEPT
		SELECT FileIndex FROM @Stores
	) missing

DEClARE @ReceiptStagingTable ReceiptStagingTable
DECLARE @ReceiptOtherChargesTable ReceiptOtherChargesTableType
DECLARE @ReceiptItemLotStagingTable ReceiptItemLotStagingTable

DECLARE @ReceiptStore TABLE(FileIndex INT, RecordIndex INT, RecordType NVARCHAR(50), StoreNumber NVARCHAR(50), intStoreId INT, intLocationId INT)
INSERT INTO @ReceiptStore(FileIndex, RecordIndex, RecordType, StoreNumber, intStoreId, intLocationId)
SELECT s.FileIndex, s.RecordIndex, s.RecordType, s.StoreNumber, st.intStoreId, st.intCompanyLocationId
FROM @Stores s
	INNER JOIN tblSTStore st ON st.intStoreNo = CAST(s.StoreNumber AS INT)
WHERE CAST(s.StoreNumber AS INT) = st.intStoreNo

-- Populate receipt staging table
INSERT INTO @ReceiptStagingTable(strReceiptType, intEntityVendorId, intShipFromId, intLocationId, dtmDate, intSourceId, intItemId, 
	intItemLocationId, intItemUOMId, dblQty, dblCost, intCostUOMId, intSourceType, strVendorRefNo, intCurrencyId, intShipViaId, dblUnitRetail, intSort)
SELECT 
	strReceiptType = 'Direct', 
	intEntityVendorId = @VendorId, 
	intShipFromId = el.intEntityLocationId, 
	intLocationId = st.intLocationId, 
	dtmDate = CASE WHEN ISDATE(inv.InvoiceDate) = 1 THEN CAST(inv.InvoiceDate AS DATETIME) ELSE NULL END,
	intSourceId = 0, 
	intItemId = it.intItemId, 
	intItemLocationId = il.intItemLocationId,
	intItemUOMId = ISNULL(iu.intItemUOMId, im.intItemUOMId), 
	dblQuantity = CASE WHEN i.UnitMultiplier > 1 THEN i.Quantity * i.UnitMultiplier ELSE i.Quantity END, 
	dblCost = CASE WHEN i.UnitMultiplier > 1 THEN i.UnitCost / i.UnitMultiplier ELSE i.UnitCost END, 
	intCostUOMId = ISNULL(iu.intItemUOMId, im.intItemUOMId), 
	intSourceType = 0,
	strVendorRefNo = inv.InvoiceNumber,
	intCurrencyId = v.intCurrencyId, 
	intShipVia = el.intShipViaId,
	dblUnitRetail = i.RetailPrice,
	intSort = i.RecordIndex
FROM @Invoices inv
	INNER JOIN @ReceiptStore st ON inv.FileIndex = st.FileIndex
	INNER JOIN @Items i ON i.FileIndex = inv.FileIndex
	INNER JOIN tblICItemUOM lookupUom ON 
		SUBSTRING(ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode), PATINDEX('%[^0]%', ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode)+'.'), LEN(ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode)))
		= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))
	INNER JOIN tblICItem it ON it.intItemId = lookupUom.intItemId
	INNER JOIN vyuAPVendor v ON v.intEntityId = @VendorId
	LEFT OUTER JOIN tblEMEntityLocation el ON el.intEntityId = @VendorId
		AND el.ysnActive = 1
		AND el.intEntityLocationId = v.intDefaultLocationId
	INNER JOIN tblICItemLocation il ON il.intItemId = it.intItemId
		AND il.intLocationId = st.intLocationId
	LEFT OUTER JOIN tblICItemUOM im ON im.intItemId = it.intItemId
		AND im.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure u ON u.strUnitMeasure = i.UnitOfMeasure
	LEFT JOIN tblICItemUOM iu ON iu.intItemId = it.intItemId
		AND iu.intUnitMeasureId = u.intUnitMeasureId
ORDER BY i.RecordIndex ASC

INSERT INTO @ReceiptOtherChargesTable(intEntityVendorId, strReceiptType, intLocationId, intShipViaId, intShipFromId, intCurrencyId, intChargeId, strCostMethod, dblAmount)
SELECT 
	intEntityVendorId = @VendorId, 
	strReceiptType = 'Direct',
	intLocationId = st.intLocationId, 
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
	AND ISNULL(c.Amount, 0) != 0

IF EXISTS(SELECT * FROM @ReceiptStagingTable)
	EXEC dbo.uspICAddItemReceipt @ReceiptStagingTable, @ReceiptOtherChargesTable, @UserId, @ReceiptItemLotStagingTable
ELSE
BEGIN
	INSERT INTO tblICImportLogDetail(intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
	SELECT @LogId, 'Error', -1, NULL, NULL, 'Unable to generate receipts. Possible reasons: (1) No store headers found in file and no selected location. (2) Store headers found but the locations do not exists in the system. (3) Items are not in the store location(s).', 'Failed', 'No record(s) imported.', 1 
	GOTO LogErrors;
	RETURN
END

-- Log valid items
INSERT INTO tblICImportLogDetail(intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
SELECT @LogId, 'Info', rs.intSort, 'Receipt Item', i.strItemNo, 'Import successful.', 'Success', 'Record inserted.', 1
FROM @ReceiptStagingTable rs
	INNER JOIN tblICItem i ON rs.intItemId = i.intItemId

-- Log UPCs that don't have corresponding items
INSERT INTO tblICImportLogDetail(intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
SELECT @LogId, 'Error', i.RecordIndex, 'Item UPC', i.ItemUpc, 'Cannot find the item that matches the UPC: ' + i.ItemUpc, 'Skipped', 'Record not imported.', 1
FROM @Items i
	LEFT OUTER JOIN tblICItemUOM u ON SUBSTRING(ISNULL(u.strLongUPCCode, u.strUpcCode), PATINDEX('%[^0]%', ISNULL(u.strLongUPCCode, u.strUpcCode)+'.'), LEN(ISNULL(u.strLongUPCCode, u.strUpcCode)))
		= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))
	LEFT JOIN tblICItem it ON it.intItemId = u.intItemId
WHERE it.intItemId IS NULL

-- Log items with invalid locations
INSERT INTO tblICImportLogDetail(intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
SELECT @LogId, 'Error', i.RecordIndex, 'Item Location', i.ItemUpc, 'Item: ' + i.ItemUpc + ' does not belong to store location: ' + st.StoreNumber, 'Skipped', 'Record not imported.', 1
FROM @Invoices inv
	INNER JOIN @ReceiptStore st ON inv.FileIndex = st.FileIndex
	INNER JOIN @Items i ON i.FileIndex = inv.FileIndex
	INNER JOIN tblICItemUOM lookupUom ON 
		SUBSTRING(ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode), PATINDEX('%[^0]%', ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode)+'.'), LEN(ISNULL(lookupUom.strLongUPCCode, lookupUom.strUpcCode)))
		= SUBSTRING(i.ItemUpc, PATINDEX('%[^0]%', i.ItemUpc+'.'), LEN(i.ItemUpc))
	INNER JOIN tblICItem it ON it.intItemId = lookupUom.intItemId
	LEFT OUTER JOIN tblICItemLocation il ON il.intItemId = it.intItemId
		AND il.intLocationId = st.intLocationId
WHERE il.intLocationId IS NULL

GOTO LogErrors

LogErrors:

SELECT @ErrorCount = COUNT(*) FROM tblICImportLogDetail WHERE intImportLogId = @LogId AND strType = 'Error'
SELECT @TotalRows = COUNT(*) FROM @Items
DECLARE @TotalRowsImported INT
SELECT @TotalRowsImported = COUNT(*) FROM @ReceiptStagingTable
DECLARE @ElapsedInMs INT = DATEDIFF(MILLISECOND, @Start, DATEADD(SECOND, 3, GETDATE())) -- Add 3 seconds for importing to staging table
DECLARE @ElapsedInSec FLOAT = CAST(@ElapsedInMs / 1000.00 AS FLOAT)

IF @ErrorCount > 0
BEGIN
	UPDATE tblICImportLog SET 
		strDescription = 'Import finished with ' + CAST(@ErrorCount AS NVARCHAR(50))+ ' error(s).',
		intTotalErrors = @ErrorCount,
		intTotalRows = @TotalRows,
		intTotalWarnings = 0,
		intRowsImported = @TotalRowsImported,
		dblTimeSpentInSeconds = @ElapsedInSec,
		intRowsUpdated = 0 --CASE WHEN (@TotalRows - @ErrorCount) < 0 THEN 0 ELSE @TotalRows - @ErrorCount END
	WHERE intImportLogId = @LogId
END

IF(@TotalRows <= 0 AND @ErrorCount <= 0)
BEGIN
	UPDATE tblICImportLog SET strDescription = 'There''s no record to import.' WHERE intImportLogId = @LogId	
END
ELSE
BEGIN
	IF @ErrorCount <= 0
	BEGIN
		UPDATE tblICImportLog SET 
			strDescription = 'Import Receipts successful.',
			intTotalErrors = @ErrorCount,
			intTotalRows = @TotalRows,
			intTotalWarnings = 0,
			intRowsImported = @TotalRowsImported,
			dblTimeSpentInSeconds = @ElapsedInSec,
			intRowsUpdated = 0 --CASE WHEN (@TotalRows - @ErrorCount) < 0 THEN 0 ELSE @TotalRows - @ErrorCount END
		WHERE intImportLogId = @LogId	

		--INSERT INTO tblICImportLogDetail(intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
		--SELECT @LogId, 'Info', 0, NULL, NULL, 'Import successful.', 'Success', 'Record inserted', 1
	END
END