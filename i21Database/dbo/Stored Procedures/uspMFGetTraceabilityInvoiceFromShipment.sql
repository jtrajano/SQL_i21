CREATE PROCEDURE [dbo].[uspMFGetTraceabilityInvoiceFromShipment] @intShipmentId INT
AS
SET NOCOUNT ON;

SELECT DISTINCT 'Invoice' AS strTransactionName
	,iv.intInvoiceId
	,iv.strInvoiceNumber
	,'' AS strLotAlias
	,i.intItemId
	,i.strItemNo
	,i.strDescription
	,mt.intCategoryId
	,mt.strCategoryCode
	,SUM(ivd.dblQtyShipped) AS dblQuantity
	,um.strUnitMeasure AS strUOM
	,iv.dtmDate AS dtmTransactionDate
	,c.strName AS strVendor
	,'IN' AS strType
FROM tblARInvoice iv
JOIN tblARInvoiceDetail ivd ON iv.intInvoiceId = ivd.intInvoiceId
JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentItemId = ivd.intInventoryShipmentItemId
JOIN tblICInventoryShipment sh ON sh.intInventoryShipmentId = si.intInventoryShipmentId
JOIN tblICItem i ON si.intItemId = i.intItemId
JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
LEFT JOIN tblICItemUOM iu ON ivd.intItemUOMId = iu.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
LEFT JOIN vyuARCustomer c ON iv.intEntityCustomerId = c.[intEntityId]
WHERE sh.intInventoryShipmentId = @intShipmentId
Group by 
iv.intInvoiceId
	,iv.strInvoiceNumber
	,i.intItemId
	,i.strItemNo
	,i.strDescription
	,mt.intCategoryId
	,mt.strCategoryCode
	,um.strUnitMeasure 
	,iv.dtmDate
	,c.strName
