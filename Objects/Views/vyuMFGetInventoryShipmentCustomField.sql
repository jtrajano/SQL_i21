CREATE VIEW vyuMFGetInventoryShipmentCustomField
AS
SELECT intRecordId
	,[customer po no] AS strCustomerPONo
	,[total pallets loaded] AS strTotalPalletsLoaded
	,[airbags] AS strAirbags
	,[case labels] AS strCaseLabels
	,[number of pallet labels] AS strNumberofPalletLabels
	,[number of pallet placards] AS strNumberofPalletPlacards
	,[pallet cap] AS strPalletCap
	,[wood pallet] AS strWoodPallet
	,[heat treated pallet] AS strHeatTreatedPallet
	,[block and brace] AS strBlockAndBrace
	,[created by edi] AS ysnEDI
	,[customer pick up] As ysnCustomerPickUp
FROM (
	SELECT T.intRecordId
		,TD.strControlName
		,FV.strValue
	FROM tblSMTabRow TR
	JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
	JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
		AND LOWER(TD.strControlName) IN (
			'customer po no'
			,'total pallets loaded'
			,'airbags'
			,'case labels'
			,'number of pallet labels'
			,'number of pallet placards'
			,'pallet cap'
			,'wood pallet'
			,'heat treated pallet'
			,'block and brace'
			,'created by edi'
			,'customer pick up'
			)
	JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
	JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
		AND S.strNamespace = 'Inventory.view.InventoryShipment'
	) AS SourceTable
PIVOT(MAX(strValue) FOR strControlName IN (
			[customer po no]
			,[total pallets loaded]
			,[airbags]
			,[case labels]
			,[number of pallet labels]
			,[number of pallet placards]
			,[pallet cap]
			,[wood pallet]
			,[heat treated pallet]
			,[block and brace]
			,[created by edi]
			,[customer pick up]
			)) AS PivotTable
