CREATE PROCEDURE uspMFProcessEDI945
AS
BEGIN
	DECLARE @tblMFOrderNo TABLE (
		intInventoryShipmentId INT
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblMFOrderNo (
		intInventoryShipmentId
		,strOrderNo
		)
	SELECT InvS.intInventoryShipmentId
		,InvS.strReferenceNumber
	FROM tblICInventoryShipment InvS
	WHERE ysnPosted = 1
		AND EXISTS (
			SELECT *
			FROM tblMFEDI940Archive EDI940
			WHERE EDI940.strDepositorOrderNumber = InvS.strReferenceNumber
			)
		AND NOT EXISTS (
			SELECT *
			FROM tblMFEDI945 EDI945
			WHERE EDI945.intInventoryShipmentId = InvS.intInventoryShipmentId
			)
		UNION
		SELECT InvS.intInventoryShipmentId
		,InvS.strReferenceNumber
		FROM tblICInventoryShipment InvS
		JOIN vyuMFGetInventoryShipmentCustomField CF on CF.intRecordId =InvS.intInventoryShipmentId
		WHERE ysnPosted = 1 and CF.ysnEDI=1
		AND NOT EXISTS (
			SELECT *
			FROM tblMFEDI945 EDI945
			WHERE EDI945.intInventoryShipmentId = InvS.intInventoryShipmentId
			)

	SELECT 945 AS strTransactionId
		,'Wholesome Sweetners' AS strCustomerId
		,'F' AS strType
		,strReferenceNumber strDepositorOrderNumber
		,strCustomerPONo strPurchaseOrderNumber
		,dtmShipDate dtmShipmentDate
		,strShipmentNumber strShipmentId
		,E.strName
		,EL.strAddress AS strShipToAddress
		,EL.strCity AS strShipToCity
		,EL.strState AS strShipToState
		,EL.strZipCode AS strShipToZipCode
		,0 AS strShipToCode
		,strShipmentNumber strShipmentId
		,dtmShipDate dtmShippedDate
		,(
			SELECT TOP 1 strTransportationMethod
			FROM tblMFEDI940Archive EDI940
			WHERE EDI940.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
			) AS strTransportationMethod
		,(
			SELECT TOP 1 strSCAC
			FROM tblMFEDI940Archive EDI940
			WHERE EDI940.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
			) AS strSCAC
		,(
			SELECT TOP 1 strRouting
			FROM tblMFEDI940Archive EDI940
			WHERE EDI940.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
			) AS strRouting
		,(
			SELECT TOP 1 strShipmentMethodOfPayment
			FROM tblMFEDI940Archive EDI940
			WHERE EDI940.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
			) AS strShipmentMethodOfPayment
		,strTotalPalletsLoaded
		,SUm(dblQuantityShipped) OVER (PARTITION BY InvS.intInventoryShipmentId) dblTotalUnitsShipped
		,0 AS dblTotalWeight
		,'' AS strWeightUOM
		,InvSI.intLineNo AS strLineNumber
		,OML.strSSCCNo AS strUCC128
		,'CC' AS strOrderStatus
		,'' AS strUPCCaseCode
		,strItemNo
		,strDescription
		,(
			SELECT TOP 1 dblQtyOrdered
			FROM tblMFEDI940Archive EDI940
			WHERE EDI940.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
			) AS dblQtyOrdered
		,InvSI.dblQuantity AS dblQtyShipped
		,(
			SELECT TOP 1 dblQtyOrdered
			FROM tblMFEDI940Archive EDI940
			WHERE EDI940.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
			) - InvSI.dblQuantity AS dblQtyDifference
		,I.strExternalGroup strUOM
		,PL.strParentLotNumber strLotNumber
	FROM dbo.tblICInventoryShipment InvS
	JOIN dbo.tblICInventoryShipmentItem InvSI ON InvSI.intInventoryShipmentId = InvS.intInventoryShipmentId
	JOIN dbo.tblICInventoryShipmentItemLot InvSL ON InvSL.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
	JOIN dbo.tblICLot L ON L.intLotId = InvSL.intLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN vyuMFGetInventoryShipmentCustomField CF ON CF.intRecordId = InvS.intInventoryShipmentId
	JOIN dbo.tblEMEntity E ON E.intEntityId = InvS.intEntityCustomerId
	JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = InvS.intShipToLocationId
	JOIN tblICItem I ON I.intItemId = InvSI.intItemId
		AND EXISTS (
			SELECT *
			FROM @tblMFOrderNo O
			WHERE O.strOrderNo = InvS.strReferenceNumber
			)
	LEFT JOIN tblMFOrderHeader OH ON OH.strReferenceNo = InvS.strShipmentNumber
		AND EXISTS (
			SELECT *
			FROM @tblMFOrderNo O1
			WHERE O1.strOrderNo = OH.strReferenceNo
			)
	LEFT JOIN tblMFOrderDetail OD ON OD.intOrderHeaderId = OH.intOrderHeaderId
		AND OD.intItemId = InvSI.intItemId
	LEFT JOIN tblMFOrderManifest OM ON OM.intOrderDetailId = OD.intOrderDetailId
	LEFT JOIN tblMFOrderManifestLabel OML ON OML.intOrderManifestId = OM.intOrderManifestId

	INSERT INTO tblMFEDI945 (
		intInventoryShipmentId
		,strDepositorOrderNumber
		)
	SELECT intInventoryShipmentId
		,strOrderNo
	FROM @tblMFOrderNo
END
