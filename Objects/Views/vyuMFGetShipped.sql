CREATE VIEW [dbo].[vyuMFGetShipped]
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
	,CASE 
		WHEN IU.intUnitMeasureId = I.intWeightUOMId
			THEN InvSL.dblQuantityShipped
		ELSE InvSL.dblQuantityShipped * I.dblWeight
		END AS Weight
	--,(
	--	SELECT MIN(dtmCreated)
	--	FROM tblICInventoryTransaction IT
	--	WHERE IT.intLotId = L.intLotId
	--		AND IT.intTransactionTypeId = 5
	--		AND IT.ysnIsUnposted = 0
	--		AND IT.intTransactionId = InvS.intInventoryShipmentId
	--	) AS dtmPostedDate
	,PD.dtmPostedDate
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
	,IsNULL(I.intInnerUnits, 0) AS intUnitsPerCase
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
	,CF.strTotalPalletsLoaded
	,CF.strAirbags
	,CF.strCaseLabels
	,CF.strNumberofPalletLabels
	,CF.strNumberofPalletPlacards
	,CF.strPalletCap
	,CF.strWoodPallet
	,CF.strHeatTreatedPallet
	,CF.strBlockAndBrace
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
JOIN tblSMFreightTerms FT ON FT.intFreightTermId = InvS.intFreightTermId
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = InvS.intShipViaId
Left JOIN vyuMFGetPostedDate PD on PD.intLotId= L.intLotId and PD.intTransactionId = InvS.intInventoryShipmentId
Left JOIN vyuMFGetInventoryShipmentCustomField CF on CF.intRecordId=InvS.intInventoryShipmentId
