CREATE PROCEDURE [dbo].[uspICImportReceiptsFromStaging]
AS

DECLARE @ReceiptEntries ReceiptStagingTable
DECLARE @OtherCharges ReceiptOtherChargesTableType
DECLARE @LotEntries ReceiptItemLotStagingTable


INSERT INTO @ReceiptEntries(strReceiptType, intSourceType, intEntityVendorId, intShipFromId, intLocationId,  intItemId, intItemLocationId, intItemUOMId
	, dtmDate, intCurrencyId, intFreightTermId, strVendorRefNo, intTaxGroupId, intBookId, intSubBookId, intSubLocationId, intStorageLocationId, /* Hack: Use strSourceScreenName to store the receipt number */ strSourceScreenName)
SELECT 'Direct', 0, vs.intEntityId, el.intEntityLocationId, c.intCompanyLocationId, item.intItemId, il.intItemLocationId, uom.intItemUOMId, r.dtmReceiptDate, cr.intCurrencyID,
	ft.intFreightTermId, r.strVendorRefNo, tg.intTaxGroupId, bk.intBookId, sb.intSubBookId, sbl.intCompanyLocationSubLocationId, sl.intStorageLocationId, r.strReceiptNo
FROM tblICStagingReceipt r
	LEFT OUTER JOIN tblICStagingReceiptItem ri ON ri.strReceiptNo = r.strReceiptNo
	LEFT OUTER JOIN tblICItem item ON item.strItemNo = ri.strItemNo
	LEFT OUTER JOIN tblSMFreightTerms ft ON ft.strFreightTerm = r.strFreightTerms
	INNER JOIN tblSMCompanyLocation c ON c.strLocationName = r.strShipToLocation
	LEFT OUTER JOIN vyuEMEntityVendorSearch vs ON vs.strCustomerNumber = r.strVendorNo
	LEFT OUTER JOIN vyuEMEntityLocationWithType vl ON vl.intEntityId = vs.intEntityId
		AND vl.strLocationName = r.strShipFromLocation
	LEFT OUTER JOIN tblEMEntityLocation el ON el.strLocationName = r.strShipFromLocation
		AND el.intEntityId = vl.intEntityId
	INNER JOIN tblICItemLocation il ON il.intLocationId = c.intCompanyLocationId
		AND item.intItemId = il.intItemId
	LEFT OUTER JOIN vyuICItemUOM uom ON uom.intItemId = item.intItemId
		AND uom.strUnitMeasure = ri.strReceiveUom
	LEFT OUTER JOIN tblSMCurrency cr ON cr.strCurrency = r.strCurrency
	LEFT OUTER JOIN tblSMTaxGroup tg ON tg.strTaxGroup = ri.strTaxGroup
	LEFT OUTER JOIN tblCTBook bk ON bk.strBook = r.strBook
	LEFT OUTER JOIN tblCTSubBook sb ON sb.strSubBook = r.strSubBook
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sbl ON sbl.strSubLocationName = ri.strStorageLocation
		AND sbl.intCompanyLocationId = c.intCompanyLocationId
	LEFT OUTER JOIN tblICStorageLocation sl ON sl.strName = ri.strStorageUnit
		AND sl.intLocationId = c.intCompanyLocationId

IF EXISTS(SELECT TOP 1 1 FROM @ReceiptEntries)
BEGIN

    INSERT INTO @OtherCharges(intEntityVendorId, strReceiptType, intLocationId, intShipFromId, intCurrencyId
        , intChargeId, strCostMethod, dblRate, dblAmount, intCostUOMId, intOtherChargeEntityVendorId
        , ysnInventoryCost, ysnPrice, strAllocateCostBy)
    SELECT e.intEntityVendorId, e.strReceiptType, e.intLocationId, e.intShipFromId, e.intCurrencyId,
        i.intItemId, rc.strCostMethod, rc.dblRate, rc.dblAmount, um.intItemUOMId, vs.intEntityId
        , rc.ysnInventoryCost, rc.ysnChargeEntity, rc.strAllocateCostBy
    FROM @ReceiptEntries e
        INNER JOIN tblICStagingReceiptCharge rc ON rc.strReceiptNo COLLATE Latin1_General_CI_AS = e.strSourceScreenName COLLATE Latin1_General_CI_AS
        INNER JOIN tblICItem i ON i.strItemNo = rc.strChargeNo
        LEFT OUTER JOIN vyuEMEntityVendorSearch vs ON vs.strCustomerNumber = rc.strVendorNo
        LEFT OUTER JOIN vyuICItemUOM um ON um.strUnitMeasure = rc.strCostUom
            AND um.intItemId = i.intItemId
    WHERE i.strType = 'Other Charge'

    INSERT INTO @LotEntries(intEntityVendorId, strReceiptType, intLocationId, intShipFromId, intCurrencyId, intSourceType, 
        intItemId, intSubLocationId, intStorageLocationId, strLotNumber, dblQuantity, intItemUnitMeasureId)
    SELECT e.intEntityVendorId, e.strReceiptType, e.intLocationId, e.intShipFromId, e.intCurrencyId, e.intSourceType
        , e.intItemId, e.intSubLocationId, e.intStorageLocationId, s.strLotNo, s.dblQuantity, e.intItemUOMId
    FROM @ReceiptEntries e
        INNER JOIN tblICStagingReceiptItemLot s ON s.strReceiptNo COLLATE Latin1_General_CI_AS = e.strSourceScreenName COLLATE Latin1_General_CI_AS
        INNER JOIN tblICItem i ON i.intItemId = e.intItemId
    WHERE i.strLotTracking <> 'No'

    -- Remove hack value from screen name
    UPDATE @ReceiptEntries SET strSourceScreenName = NULL

    EXEC dbo.uspICAddItemReceipt @ReceiptEntries, @OtherCharges, 1, @LotEntries

END