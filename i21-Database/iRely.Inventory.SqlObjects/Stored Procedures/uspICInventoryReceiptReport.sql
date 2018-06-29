CREATE PROCEDURE uspICInventoryReceiptReport @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @intInventoryReceiptId INT 
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

--Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
SELECT
	  '' AS 'intInventoryReceiptId'
	, '' AS 'strReceiptNumber'
	, '' AS 'strOrderType'
	, '' AS 'dtmReceiptDate'
	, '' AS 'strSourceType'
	, '' AS 'strShipTo'
	, '' AS 'strVendor'
	, '' AS 'strShipFrom'
	, '' AS 'strItemNo'
	, '' AS 'intInventoryReceiptItemId'
	, '' AS 'intItemId'
	, '' AS 'dblGross'
	, '' AS 'dblNet'
	, '' AS 'dblQtyToReceive'
	, '' AS 'strUnitMeasure'
	, '' AS 'strQtyReceived'
	, '' AS 'dblOrdered'
	, '' AS 'strOrderNumber'
	, '' AS 'strOwnershipType'
	, '' AS 'dblUnitCost'
	, '' AS 'strCostUOM'
	, '' AS 'strCost'
	, '' AS 'strTax'
	, '' AS 'dblTax'
	, '' AS 'strCurrency'
	, '' AS 'strStorageLocation'
	, '' AS 'strStorageUnit'
	, '' AS 'strItemType'
	, '' AS 'strLotTracking'
	, '' AS 'dblLineTotal'
	, '' AS 'strBillOfLading'
	, '' AS 'strFreightTerm'
	, '' AS 'strFobPoint'
	, '' AS 'strWarehouseRefNo'
	, '' AS 'strVendorRefNo'
	, '' AS 'strReceiver'
	RETURN
END

--Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[datatype] NVARCHAR(50)
)

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	[fieldname] nvarchar(50)
	, [condition] nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)

DECLARE @strReceiptNumber NVARCHAR(100)
SELECT @strReceiptNumber = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strReceiptNumber'


IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@intInventoryReceiptId = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'intInventoryReceiptId'
END

SELECT
	  r.intInventoryReceiptId
	, r.strReceiptNumber
	, strOrderType = r.strReceiptType
	, r.dtmReceiptDate
	, strSourceType = CASE r.intSourceType WHEN 1 THEN 'Scale' WHEN 2 THEN 'Inbound Shipment' WHEN 3 THEN 'Transport' WHEN 4 THEN 'Settle Storage' WHEN 5 THEN 'Delivery Sheet' ELSE 'None' END
	, strShipTo = cl.strLocationName
	, strVendor = e.strName
	, strShipFrom = el.strLocationName
	, strItemNo = i.strItemNo
	, ri.intInventoryReceiptItemId
	, i.intItemId
	, dblGross = ri.dblGrossWgt
	, dblNet = ri.dblNetWgt
	, ri.dblQtyToReceive
	, strUnitMeasure = ri.strUnitMeasure
	, strQtyReceived = dbo.fnICFormatNumber(ri.dblQtyToReceive) + ' ' + ri.strUnitMeasure
	, ri.dblOrdered
	, ri.strOrderNumber
	, strOwnershipType = dbo.fnICGetOwnershipType(rr.intOwnershipType)
	, ri.dblUnitCost
	, strCostUOM = ri.strCostUOM
	, strCost = dbo.fnICFormatNumber(ri.dblUnitCost) + ' ' + ri.strCostUOM
	, strTax = dbo.fnICFormatNumber(ri.dblTax)
	, dblTax = ri.dblTax
	, strCurrency = c.strCurrency
	, strStorageLocation = sl.strSubLocationName
	, strStorageUnit = su.strName
	, strItemType = i.strType
	, i.strLotTracking
	, ri.dblLineTotal
	, r.strBillOfLading
	, strFreightTerm = fr.strFreightTerm
	, strFobPoint = fr.strFobPoint
	, r.strWarehouseRefNo
	, r.strVendorRefNo
	, strReceiver = us.strUserName
FROM tblICInventoryReceipt r
	LEFT JOIN vyuICGetInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	LEFT JOIN tblICInventoryReceiptItem rr ON rr.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
	LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
	LEFT JOIN tblEMEntity e ON e.intEntityId = r.intEntityVendorId
	LEFT JOIN tblEMEntityLocation el ON el.intEntityLocationId = r.intShipFromId
	LEFT JOIN tblICItem i ON i.intItemId = ri.intItemId
	LEFT JOIN tblSMCurrency c ON c.intCurrencyID = r.intCurrencyId
	LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = ri.intSubLocationId
	LEFT JOIN tblICStorageLocation su ON su.intStorageLocationId = ri.intStorageLocationId
	LEFT JOIN tblSMFreightTerms fr ON fr.intFreightTermId = r.intFreightTermId
	LEFT JOIN tblSMUserSecurity us ON us.intEntityId = r.intReceiverId
WHERE r.strReceiptNumber = @strReceiptNumber
ORDER BY r.intInventoryReceiptId DESC