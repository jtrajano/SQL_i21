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
	, '' AS 'dblGross'
	, '' AS 'dblNet'
	, '' AS 'dblOpenReceive'
	, '' AS 'strUnitMeasure'
	, '' AS 'dblOrderQty'
	, '' AS 'strOwnershipType'
	, '' AS '.dblUnitCost'
	, '' AS 'strCostUOM'
	, '' AS 'strCurrency'
	, '' AS 'strStorageLocation'
	, '' AS 'strStorageUnit '
	, '' AS 'strItemType '
	, '' AS 'strLotTracking'
	, '' AS 'ri.dblLineTotal'
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
	, ri.dblGross
	, ri.dblNet
	, ri.dblOpenReceive
	, strUnitMeasure = qu.strUnitMeasure
	, strQtyReceived = dbo.fnICFormatNumber(ri.dblOpenReceive) + ' ' + qu.strUnitMeasure
	, ri.dblOrderQty
	, strOwnershipType = dbo.fnICGetOwnershipType(ri.intOwnershipType)
	, ri.dblUnitCost
	, strCostUOM = cu.strUnitMeasure
	, strCost = dbo.fnICFormatNumber(ri.dblUnitCost) + ' ' + cu.strUnitMeasure
	, strTax = dbo.fnICFormatNumber(ri.dblTax)
	, dblTax = ri.dblTax
	, strCurrency = c.strCurrency
	, strStorageLocation = sl.strSubLocationName
	, strStorageUnit = su.strName
	, strItemType = i.strType
	, i.strLotTracking
	, ri.dblLineTotal
	, ri.strComments
FROM tblICInventoryReceipt r
	LEFT JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
	LEFT JOIN tblEMEntity e ON e.intEntityId = r.intEntityVendorId
	LEFT JOIN tblEMEntityLocation el ON el.intEntityLocationId = r.intShipFromId
	LEFT JOIN tblICItem i ON i.intItemId = ri.intItemId
	LEFT JOIN tblICItemUOM qum ON qum.intItemUOMId = ri.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure qu ON qu.intUnitMeasureId = qum.intUnitMeasureId
	LEFT JOIN tblICItemUOM cum ON cum.intItemUOMId = ri.intCostUOMId
	LEFT JOIN tblICUnitMeasure cu ON cu.intUnitMeasureId = ri.intUnitMeasureId
	LEFT JOIN tblSMCurrency c ON c.intCurrencyID = r.intCurrencyId
	LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = ri.intSubLocationId
	LEFT JOIN tblICStorageLocation su ON su.intStorageLocationId = ri.intStorageLocationId
WHERE r.strReceiptNumber = @strReceiptNumber
ORDER BY r.intInventoryReceiptId DESC