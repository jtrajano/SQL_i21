CREATE PROCEDURE [dbo].[uspRestApiImportReceipt] (@guiUniqueId UNIQUEIDENTIFIER)
AS

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
	, dblUnitRetail)
SELECT 
	  'Direct'
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
END

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, intLinePosition INT NULL, strLogLevel NVARCHAR(50))
DELETE FROM tblRestApiReceiptStaging WHERE guiUniqueId = @guiUniqueId
SELECT * FROM @Logs
