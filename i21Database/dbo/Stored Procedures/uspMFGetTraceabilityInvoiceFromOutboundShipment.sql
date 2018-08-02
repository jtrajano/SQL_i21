CREATE PROCEDURE uspMFGetTraceabilityInvoiceFromOutboundShipment @intLoadId INT
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
	,ivd.dblQtyOrdered AS dblQuantity
	,um.strUnitMeasure AS strUOM
	,iv.dtmDate AS dtmTransactionDate
	,c.strName AS strVendor
	,'IN' AS strType
FROM tblARInvoice iv
JOIN tblARInvoiceDetail ivd ON iv.intInvoiceId = ivd.intInvoiceId
JOIN tblLGLoadDetail lg ON lg.intLoadDetailId = ivd.intLoadDetailId
JOIN tblLGLoad l ON l.intLoadId = lg.intLoadId
JOIN tblICItem i ON lg.intItemId = i.intItemId
JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
LEFT JOIN tblICItemUOM iu ON ivd.intItemUOMId = iu.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
LEFT JOIN vyuARCustomer c ON iv.intEntityCustomerId = c.[intEntityId]
WHERE l.intLoadId = @intLoadId