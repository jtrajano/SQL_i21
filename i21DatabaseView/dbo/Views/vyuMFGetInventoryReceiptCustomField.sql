CREATE VIEW vyuMFGetInventoryReceiptCustomField
AS
SELECT intRecordId
	,[created by edi] AS ysnEDI
FROM (
	SELECT T.intRecordId
		,TD.strControlName
		,FV.strValue
	FROM tblSMTabRow TR
	JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
	JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
		AND LOWER(TD.strControlName) IN ('created by edi')
	JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
	JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
		AND S.strNamespace = 'Inventory.view.InventoryReceipt'
	) AS SourceTable
PIVOT(MAX(strValue) FOR strControlName IN ([created by edi])) AS PivotTable
