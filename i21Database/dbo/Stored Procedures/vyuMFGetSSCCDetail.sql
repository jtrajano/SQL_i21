CREATE VIEW vyuMFGetSSCCDetail
AS
SELECT InvS.strShipmentNumber
	,InvS.strBOLNumber
	,InvS.strReferenceNumber
	,(
		SELECT TOP 1 FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'customer po no'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = InvS.intInventoryShipmentId
		) AS strCustomerPO
	,E.strName AS strCustomer
	,SV.strName AS strCarrier
	,I.strItemNo
	,I.strDescription
	,OML.strSSCCNo
	,1 AS dblQty
FROM dbo.tblICInventoryShipment InvS
JOIN dbo.tblEMEntity E ON E.intEntityId = InvS.intEntityCustomerId
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = InvS.intShipViaId
JOIN tblMFOrderHeader OH ON OH.strReferenceNo = InvS.strShipmentNumber
JOIN tblMFOrderDetail OD ON OD.intOrderHeaderId = OH.intOrderHeaderId
JOIN dbo.tblICItem I ON I.intItemId = OD.intItemId
JOIN tblMFOrderManifest OM ON OM.intOrderDetailId = OD.intOrderDetailId
JOIN tblMFOrderManifestLabel OML ON OML.intOrderManifestId = OM.intOrderManifestId
