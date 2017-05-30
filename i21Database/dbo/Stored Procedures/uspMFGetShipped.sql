﻿CREATE PROCEDURE [dbo].[uspMFGetShipped] As
SELECT InvS.strReferenceNumber
		,InvS.strShipmentNumber
		,InvS.dtmShipDate
		,EL1.strAddress As strShipFromAddress
		,EL1.strCity As strShipFromCity
		,EL1.strState As strShipFromState
		,EL1.strZipCode As strShipFromZipCode
		,EL1.strCountry As strShipFromCountry
		,E.strName
		,EL.strAddress As strShipToAddress
		,EL.strCity As strShipToCity
		,EL.strState As strShipToState
		,EL.strZipCode As strShipToZipCode
		,EL.strCountry As strShipToCountry
		,InvS.strBOLNumber
		,InvS.strProNumber
		,I.strItemNo
		,I.strDescription
		,PL.strParentLotNumber
		,InvSL.dblQuantityShipped dblQuantityShipped
		,UM.strUnitMeasure
	FROM dbo.tblICInventoryShipment InvS
	JOIN dbo.tblICInventoryShipmentItem InvSI ON InvSI.intInventoryShipmentId = InvS.intInventoryShipmentId
	JOIN dbo.tblICInventoryShipmentItemLot InvSL ON InvSL.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
	JOIN dbo.tblICLot L ON L.intLotId = InvSL.intLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	JOIN dbo.tblICItem I ON I.intItemId = InvSI.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblEMEntity E ON E.intEntityId = InvS.intEntityCustomerId
	JOIN dbo.tblEMEntityLocation EL on EL.intEntityLocationId=InvS.intShipToLocationId
	JOIN dbo.tblEMEntityLocation EL1 on EL1.intEntityLocationId=InvS.intShipFromLocationId