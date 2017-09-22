﻿CREATE VIEW vyuMFGetInventoryShipmentCustomField
AS
SELECT intRecordId
	,[total pallets loaded] AS strTotalPalletsLoaded
	,[airbags] AS strAirbags
	,[case labels] AS strCaseLabels
	,[number of pallet labels] AS strNumberofPalletLabels
	,[number of pallet placards] AS strNumberofPalletPlacards
	,[pallet cap] AS strPalletCap
	,[wood pallet] AS strWoodPallet
	,[heat treated pallet] AS strHeatTreatedPallet
	,[block and brace] AS strBlockAndBrace
FROM (
	SELECT T.intRecordId
		,TD.strControlName
		,FV.strValue
	FROM tblSMTabRow TR
	JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
	JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
		AND LOWER(TD.strControlName) IN (
			'total pallets loaded'
			,'airbags'
			,'case labels'
			,'number of pallet labels'
			,'number of pallet placards'
			,'pallet cap'
			,'wood pallet'
			,'heat treated pallet'
			,'block and brace'
			)
	JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
	JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
		AND S.strNamespace = 'Inventory.view.InventoryShipment'
	) AS SourceTable
PIVOT(MAX(strValue) FOR strControlName IN (
			[total pallets loaded]
			,[airbags]
			,[case labels]
			,[number of pallet labels]
			,[number of pallet placards]
			,[pallet cap]
			,[wood pallet]
			,[heat treated pallet]
			,[block and brace]
			)) AS PivotTable
