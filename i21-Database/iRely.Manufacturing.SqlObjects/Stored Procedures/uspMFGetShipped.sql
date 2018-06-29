CREATE PROCEDURE [dbo].[uspMFGetShipped]
AS
SELECT InvS.intInventoryShipmentId 
	,InvS.strReferenceNumber
	,InvS.strShipmentNumber
	,InvS.dtmShipDate
	,EL1.strAddress AS strShipFromAddress
	,EL1.strCity AS strShipFromCity
	,EL1.strStateProvince AS strShipFromState
	,EL1.strZipPostalCode AS strShipFromZipCode
	,EL1.strCountry AS strShipFromCountry
	,E.strName
	,EL.strAddress AS strShipToAddress
	,EL.strCity AS strShipToCity
	,EL.strState AS strShipToState
	,EL.strZipCode AS strShipToZipCode
	,EL.strCountry AS strShipToCountry
	,InvS.strBOLNumber
	,InvS.strProNumber
	,I.strItemNo
	,I.strDescription
	,PL.strParentLotNumber
	,L.strLotNumber
	,InvSL.dblQuantityShipped dblQuantityShipped
	,UM.strUnitMeasure
	,Case When IU.intUnitMeasureId=I.intWeightUOMId Then InvSL.dblQuantityShipped Else  InvSL.dblQuantityShipped*I.dblWeight End As Weight 
	,(
			SELECT MIN(dtmCreated)
			FROM tblICInventoryTransaction IT
			WHERE IT.intLotId = L.intLotId
				AND IT.intTransactionTypeId = 5
				AND IT.ysnIsUnposted = 0
				AND IT.strTransactionId =InvS.strShipmentNumber 
			) AS dtmPostedDate
	,C.strCategoryCode
	,C.strDescription AS strCategoryDescription
	,CAST(CASE 
			WHEN (
					(I.intUnitPerLayer * I.intLayerPerPallet > 0)
					AND (InvSL.dblQuantityShipped % (I.intUnitPerLayer * I.intLayerPerPallet) > 0)
					)
				THEN 1
			ELSE 0
			END AS BIT) AS ysnPartialPallet
	,IsNULL((
			SELECT TOP 1 I.strItemNo
			FROM tblMFRecipeItem RI
			JOIN tblMFRecipe R ON R.intRecipeId = RI.intRecipeId
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND I.strItemNo NOT LIKE '%CAP%'
				AND I.strItemNo LIKE '%Pallet%'
			WHERE R.intItemId = InvSI.intItemId
				AND ysnActive = 1
			), 'PALLETW') AS strPallet
	,InvS.ysnPosted
	,CONVERT(DECIMAL(24, 10), CASE 
			WHEN (I.intUnitPerLayer * I.intLayerPerPallet) > 0
				THEN InvSL.dblQuantityShipped / CONVERT(DECIMAL(24, 10), (I.intUnitPerLayer * I.intLayerPerPallet))
			ELSE 0
			END) AS dblNoOfPallet
	,(I.intUnitPerLayer * I.intLayerPerPallet) AS intCasesPerPallet
	,IsNULL(I.intInnerUnits,0) AS intUnitsPerCase
	,InvS.dtmRequestedArrivalDate 
	,FT.strFreightTerm 
	,InvS.strComment 
	,InvS.strDeliveryInstruction
	,InvS.strDriverId
	,InvS.strVessel 
	,InvS.strSealNumber 
	,InvS.dtmAppointmentTime
	,InvS.dtmDepartureTime 
	,InvS.dtmArrivalTime
	,InvS.dtmDeliveredDate 
	,InvS.strFreeTime
	,InvS.strReceivedBy 
	,SV.strName AS strShipVia
		,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'total pallets loaded'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strTotalPalletsLoaded
		,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'airbags'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strAirbags
			,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'case labels'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strCaseLabels
		,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'number of pallet labels'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strNumberofPalletLabels
		,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'number of pallet placards'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strNumberofPalletPlacards
		,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'pallet cap'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strPalletCap
		,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'wood pallet'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strWoodPallet
		,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'heat treated pallet'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strHeatTreatedPallet
		,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'heat treated pallet'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strBlockAndBrace
FROM dbo.tblICInventoryShipment InvS
JOIN dbo.tblICInventoryShipmentItem InvSI ON InvSI.intInventoryShipmentId = InvS.intInventoryShipmentId
JOIN dbo.tblICInventoryShipmentItemLot InvSL ON InvSL.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
JOIN dbo.tblICLot L ON L.intLotId = InvSL.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = InvSI.intItemId
JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblEMEntity E ON E.intEntityId = InvS.intEntityCustomerId
JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = InvS.intShipToLocationId
JOIN dbo.tblSMCompanyLocation EL1 ON EL1.intCompanyLocationId = InvS.intShipFromLocationId
JOIN tblSMFreightTerms FT on FT.intFreightTermId =InvS.intFreightTermId
Left JOIN tblSMShipVia SV on SV.intEntityId =InvS.intShipViaId
ORDER BY InvS.strShipmentNumber DESC
