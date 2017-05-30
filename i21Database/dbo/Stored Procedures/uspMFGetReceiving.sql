CREATE PROCEDURE [dbo].[uspMFGetReceiving]
AS
	SELECT IR.strReceiptNumber
		,IR.dtmReceiptDate
		,CL.strLocationName
		,E.strName as strVendor
		,IR.strVendorRefNo
		,IR.strWarehouseRefNo as strOrderEntryNumber
		,IR.strBillOfLading
		,E1.strName as strReceiver
		,IR.strVessel AS strBatch
		,I.strItemNo
		,I.strDescription
		,IRL.strVendorLotId
		,IRL.strParentLotNumber
		,IRL.strLotNumber
		,IRL.dblQuantity
		,UM.strUnitMeasure
		,IRL.dblGrossWeight
		,IRL.strContainerNo
		,IRL.strGarden strSealNo
		,IRL.intUnitPallet as intExpectedQuantity
		,IRL.dtmManufacturedDate
		,IRL.dtmExpiryDate
		,IRL.strRemarks
		,IRL.strCondition
		,SL.strName as strStorageLocation
		,C.strCountry
		
	FROM dbo.tblICInventoryReceipt IR
	JOIN dbo.tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
	JOIN dbo.tblICInventoryReceiptItemLot IRL ON IRL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	JOIN dbo.tblEMEntity E on E.intEntityId=IR.intEntityVendorId
	JOIN dbo.tblEMEntity E1 on E1.intEntityId=IR.intReceiverId
	JOIN dbo.tblICItem I ON I.intItemId = IRI.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = IRL.intItemUnitMeasureId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFLotInventory LI ON LI.intLotId = IRL.intLotId
	LEFT JOIN dbo.tblICItemOwner IO1 ON IO1.intItemOwnerId = LI.intItemOwnerId
	JOIN dbo.tblICStorageLocation SL on SL.intStorageLocationId=IRL.intStorageLocationId
	Left JOIN tblSMCountry C on C.intCountryID=IRL.intOriginId
	JOIN dbo.tblSMCompanyLocation CL on CL.intCompanyLocationId =IR.intLocationId