CREATE PROCEDURE [dbo].[uspApiImportReceipt] (@guiUniqueId UNIQUEIDENTIFIER)
AS

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, dblTotalAmount NUMERIC(18, 6), intLinePosition INT NULL, strLogLevel NVARCHAR(50))

-- Set Default Values
UPDATE rs
SET
	rs.intCurrencyId = COALESCE(rs.intCurrencyId, v.intCurrencyId),
	rs.intShipFromEntityId = COALESCE(rs.intShipFromEntityId, v.intEntityId),
	rs.intShipFromLocationId = COALESCE(rs.intShipFromLocationId, x.intEntityLocationId),
	rs.intFreightTermId = COALESCE(rs.intFreightTermId, x.intFreightTermId)
FROM tblRestApiReceiptStaging rs
JOIN tblAPVendor v ON v.intEntityId = rs.intEntityId
JOIN tblEMEntity e ON e.intEntityId = v.intEntityId
OUTER APPLY (
	SELECT TOP 1 l.strLocationName, l.intEntityLocationId, l.intFreightTermId
	FROM tblEMEntityLocation l
	WHERE l.intEntityId = v.intEntityId
	AND l.ysnDefaultLocation = 1
) x
WHERE rs.guiUniqueId = @guiUniqueId
AND v.ysnPymtCtrlActive = 1
AND e.ysnActive = 1

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the entityId ''' + CAST(s.intEntityId AS NVARCHAR(50)) + '''', 'entityId', 'Error',  CAST(s.intEntityId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging s
LEFT JOIN tblEMEntity e ON s.intEntityId = e.intEntityId
WHERE e.intEntityId IS NULL
	AND s.guiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the locationId ''' + CAST(s.intLocationId AS NVARCHAR(50)) + '''', 'locationId', 'Error',  CAST(s.intLocationId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging s
LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = s.intLocationId
WHERE l.intCompanyLocationId IS NULL
	AND s.guiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT CASE WHEN s.intCurrencyId IS NULL THEN 'currencyId is required.' ELSE 'Cannot find the currencyId ''' + CAST(s.intCurrencyId AS NVARCHAR(50)) + '''' END
	, 'currencyId', 'Error',  CAST(s.intCurrencyId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging s
LEFT JOIN tblSMCurrency c ON c.intCurrencyID = s.intCurrencyId
WHERE c.intCurrencyID IS NULL
	AND s.guiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT CASE WHEN s.intShipFromEntityId IS NULL THEN 'shipFromEntityId is required.' ELSE 'Cannot find the shipFromEntityId ''' + CAST(s.intShipFromEntityId AS NVARCHAR(50)) + '''' END
	, 'shipFromEntityId', 'Error',  CAST(s.intShipFromEntityId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging s
WHERE s.intShipFromEntityId IS NULL
	AND s.guiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the freightTermId ''' + CAST(s.intFreightTermId AS NVARCHAR(50)) + '''', 'freightTermId', 'Error',  CAST(s.intFreightTermId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging s
LEFT JOIN tblSMFreightTerms f ON f.intFreightTermId = s.intFreightTermId
WHERE f.intFreightTermId IS NULL
	AND s.guiUniqueId = @guiUniqueId
	AND s.intFreightTermId IS NOT NULL

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the itemId ''' + CAST(ri.intItemId AS NVARCHAR(50)) + '''', 'itemId', 'Error',  CAST(ri.intItemId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging r
INNER JOIN tblRestApiReceiptItemStaging ri ON ri.intRestApiReceiptStagingId = r.intRestApiReceiptStagingId
LEFT JOIN tblICItem i ON i.intItemId = ri.intItemId
WHERE i.intItemId IS NULL
	AND r.guiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'The itemId ''' + CAST(ri.intItemId AS NVARCHAR(50)) + ''' is not valid for the locationId ''' + CAST(r.intLocationId AS NVARCHAR(50)) + '''', 'itemId', 'Error',  CAST(ri.intItemId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging r
INNER JOIN tblRestApiReceiptItemStaging ri ON ri.intRestApiReceiptStagingId = r.intRestApiReceiptStagingId
LEFT JOIN tblICItem i ON i.intItemId = ri.intItemId
LEFT JOIN tblICItemLocation il ON il.intLocationId = r.intLocationId
	AND il.intItemId = i.intItemId
WHERE i.intItemId IS NULL
	AND r.guiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'Cannot find the chargeId ''' + CAST(ri.intChargeId AS NVARCHAR(50)) + '''', 'chargeId', 'Error',  CAST(ri.intChargeId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging r
INNER JOIN tblRestApiReceiptChargeStaging ri ON ri.intRestApiReceiptStagingId = r.intRestApiReceiptStagingId
LEFT JOIN tblICItem i ON i.intItemId = ri.intChargeId
WHERE i.intItemId IS NULL
	AND r.guiUniqueId = @guiUniqueId
	
INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'The chargeId ''' + CAST(ri.intChargeId AS NVARCHAR(50)) + ''' is not valid for the locationId ''' + CAST(r.intLocationId AS NVARCHAR(50)) + '''', 'chargeId', 'Error',  CAST(ri.intChargeId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging r
INNER JOIN tblRestApiReceiptChargeStaging ri ON ri.intRestApiReceiptStagingId = r.intRestApiReceiptStagingId
LEFT JOIN tblICItem i ON i.intItemId = ri.intChargeId
LEFT JOIN tblICItemLocation il ON il.intLocationId = r.intLocationId
	AND il.intItemId = i.intItemId
WHERE i.intItemId IS NULL
	AND r.guiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT 'The costUOMId ''' + CAST(ri.intCostUOMId AS NVARCHAR(50)) + ''' is not valid for the chargeId ''' + CAST(ri.intChargeId AS NVARCHAR(50)) + '''', 'costUOMId', 'Error',  CAST(ri.intChargeId AS NVARCHAR(50))
FROM tblRestApiReceiptStaging r
INNER JOIN tblRestApiReceiptChargeStaging ri ON ri.intRestApiReceiptStagingId = r.intRestApiReceiptStagingId
LEFT JOIN tblICItem i ON i.intItemId = ri.intChargeId
LEFT JOIN tblICItemUOM uom ON uom.intItemUOMId = ri.intCostUOMId
WHERE uom.intItemUOMId IS NULL
	AND r.guiUniqueId = @guiUniqueId

INSERT INTO @Logs (strError, strField, strLogLevel, strValue)
SELECT CASE WHEN s.strOrderType IS NULL THEN 'orderType is required.' ELSE 'Cannot find the orderType ''' + s.strOrderType + '''. Valid values are: Direct, Purchase Order, Purchase Contract, Transfer Order.' END
	, 'orderType', 'Error',  strOrderType
FROM tblRestApiReceiptStaging s
WHERE s.guiUniqueId = @guiUniqueId
	AND NULLIF(s.strOrderType, '') IS NOT NULL
	AND s.strOrderType NOT IN ('Direct', 'Purchase Order', 'Purchase Contract', 'Transfer Order')

IF EXISTS(SELECT * FROM @Logs)
	GOTO Logging

DECLARE @ReceiptEntries ReceiptStagingTable
DECLARE @OtherCharges ReceiptOtherChargesTableType
DECLARE @LotEntries ReceiptItemLotStagingTable

INSERT INTO @ReceiptEntries(
	  strReceiptType
	, intSourceType
	, dtmDate
	, intEntityVendorId
	, intLocationId
	, intShipFromEntityId
	, intShipFromId

	, intItemLocationId
	, intItemId
	, intItemUOMId
	, intCurrencyId
	, intFreightTermId
	, strVendorRefNo
	, intTaxGroupId
	, dblQty
	, dblCost
	, dblGross
	, intGrossNetUOMId
	, intForexRateTypeId
	, intCostUOMId
	, dblUnitRetail
	, strWarehouseRefNo
	, intPurchaseId
	, intPurchaseDetailId
	, intTicketId
	, intInventoryTransferId
	, intInventoryTransferDetailId
	, intLoadShipmentId
	, intLoadShipmentDetailId)
SELECT 
	  ISNULL(r.strOrderType, 'Direct')
	, 0
	, r.dtmReceiptDate
	, r.intEntityId
	, r.intLocationId
	, r.intShipFromEntityId
	, r.intShipFromLocationId

	, il.intItemLocationId
	, ri.intItemId
	, ri.intReceiveUOMId
	, r.intCurrencyId
	, r.intFreightTermId
	, r.strVendorRefNo
	, ri.intTaxGroupId
	, ri.dblReceiptQty
	, ri.dblCost
	, ri.dblGrossQty
	, ri.intGrossUOMId
	, ri.intForexRateType
	, ri.intCostUOMId
	, ri.dblUnitRetail
	, r.strWarehouseRefNo
	, ri.intPurchaseId
	, ri.intPurchaseDetailId
	, ri.intTicketId
	, ri.intInventoryTransferId
	, ri.intInventoryTransferDetailId
	, ri.intLoadShipmentId
	, ri.intLoadShipmentDetailId
FROM tblRestApiReceiptStaging r
	INNER JOIN tblRestApiReceiptItemStaging ri ON ri.intRestApiReceiptStagingId = r.intRestApiReceiptStagingId
	INNER JOIN tblICItemLocation il ON il.intItemId = ri.intItemId
		AND il.intLocationId = r.intLocationId
WHERE r.guiUniqueId = @guiUniqueId

INSERT INTO @OtherCharges(
	  intEntityVendorId
	, strReceiptType
	, intLocationId
	, intShipFromId
	, intCurrencyId
    , intChargeId
	, strCostMethod
	, dblRate
	, dblAmount
	, intCostUOMId
	, intOtherChargeEntityVendorId
    , ysnInventoryCost
	, ysnPrice)
SELECT
	  r.intEntityId
	, 'Direct'
	, r.intLocationId
	, r.intShipFromLocationId
	, r.intCurrencyId
	, c.intChargeId
	, c.strCostMethod
	, c.dblRate
	, c.dblAmount
	, c.intCostUOMId
	, c.intEntityId
    , c.ysnInventoryCost
	, c.ysnChargeEntity
FROM tblRestApiReceiptStaging r
INNER JOIN tblRestApiReceiptChargeStaging c ON c.intRestApiReceiptStagingId = r.intRestApiReceiptStagingId
INNER JOIN tblICItem i ON i.intItemId = c.intChargeId
WHERE r.guiUniqueId = @guiUniqueId
	AND i.strType = 'Other Charge'

INSERT INTO @LotEntries(
	  intEntityVendorId
	, strReceiptType
	, intLocationId
	, intShipFromId
	, intCurrencyId
	, intSourceType
	, intItemId
	, intSubLocationId
	, intStorageLocationId
	, strLotNumber
	, dblQuantity
	, intItemUnitMeasureId)
SELECT	
	  r.intEntityId
	, 'Direct'
	, r.intLocationId
	, r.intShipFromLocationId
	, r.intCurrencyId
	, 0
    , ri.intItemId
	, l.intSubLocationId
	, l.intStorageLocationId
	, l.strLotNumber
	, lot.dblQuantity
	, l.intItemUOMId
FROM tblRestApiReceiptStaging r
INNER JOIN tblRestApiReceiptItemStaging ri ON ri.intRestApiReceiptStagingId = r.intRestApiReceiptStagingId
INNER JOIN tblRestApiReceiptItemLotStaging lot ON lot.intRestApiReceiptItemStagingId = ri.intRestApiReceiptItemStagingId
INNER JOIN tblICLot l ON l.intLotId = lot.intLotId
INNER JOIN tblICItem i ON i.intItemId = ri.intItemId
WHERE r.guiUniqueId = @guiUniqueId
	AND i.strLotTracking <> 'No'

IF EXISTS(SELECT TOP 1 1 FROM @ReceiptEntries)
BEGIN
   	EXEC dbo.[uspICImportReceipt] @ReceiptEntries, @OtherCharges, 1, @LotEntries, @guiUniqueId

	 DECLARE @intInventoryReceiptId INT
	 DECLARE cur CURSOR LOCAL FAST_FORWARD
     FOR
	 SELECT r.intInventoryReceiptId
	 FROM tblICInventoryReceipt r
	 WHERE r.guiApiUniqueId = @guiUniqueId

	 OPEN cur

     FETCH NEXT FROM cur INTO @intInventoryReceiptId

	 WHILE @@FETCH_STATUS = 0
     BEGIN
   	 	EXEC dbo.uspICInventoryReceiptCalculateTotals @intInventoryReceiptId, 1
	 	FETCH NEXT FROM cur INTO @intInventoryReceiptId
	 END

	 CLOSE cur
	 DEALLOCATE cur
END

Logging:

INSERT INTO @Logs (intLineNumber, dblTotalAmount, strLogLevel, strField)
SELECT r.intInventoryReceiptId, SUM(ISNULL(i.dblLineTotal, 0)) + r.dblTotalCharges + SUM(ISNULL(i.dblTax, 0)), 'Ids', r.strReceiptNumber
FROM tblICInventoryReceipt r
INNER JOIN tblICInventoryReceiptItem i ON i.intInventoryReceiptId = r.intInventoryReceiptId
WHERE r.guiApiUniqueId = @guiUniqueId
GROUP BY r.intInventoryReceiptId, r.strReceiptNumber, r.dblTotalCharges

DELETE FROM tblRestApiReceiptStaging WHERE guiUniqueId = @guiUniqueId

SELECT * FROM @Logs
