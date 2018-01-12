﻿CREATE PROCEDURE uspMFProcessEDI945
AS
BEGIN
	DECLARE @tblMFOrderNo TABLE (
		intInventoryShipmentId INT
		,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strShipmentNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblMFOrderNo (
		intInventoryShipmentId
		,strOrderNo
		,strShipmentNo
		)
	SELECT InvS.intInventoryShipmentId
		,InvS.strReferenceNumber
		,InvS.strShipmentNumber
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
		,IsNULL(EDI.strShipToCode, '') AS strShipToCode
		,dtmShipDate dtmShippedDate
		,IsNULL(EDI.strTransportationMethod, '') AS strTransportationMethod
		,IsNULL(EDI.strSCAC, '') AS strSCAC
		,IsNULL(EDI.strRouting, '') AS strRouting
		,IsNULL(EDI.strShipmentMethodOfPayment, '') AS strShipmentMethodOfPayment
		,strTotalPalletsLoaded
		,SUm(dblQuantityShipped) OVER (PARTITION BY InvS.intInventoryShipmentId) dblTotalUnitsShipped
		,0 AS dblTotalWeight
		,'' AS strWeightUOM
		,InvSI.intLineNo AS intLineNo
		,'CC' AS strOrderStatus
		,IsNULL(EDI.strUPCCaseCode, '') AS strUPCCaseCode
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,IsNULL(EDI.dblQtyOrdered, 0) AS dblQtyOrdered
		,(
			CASE 
				WHEN EXISTS (
						SELECT *
						FROM tblMFItemOwner ItemOwner
						WHERE ItemOwner.intCustomerLabelTypeId = 2
							AND ItemOwner.intOwnerId = InvS.intEntityCustomerId
						)
					THEN 1
				ELSE InvSL.dblQuantityShipped
				END
			) AS dblQtyShipped
		,I.strExternalGroup strUOM
		,PL.strParentLotNumber strParentLotNumber
		,L.strLotNumber
		,Ltrim(1 + (year(L.dtmExpiryDate) - 1) / 100) + (CONVERT(VARCHAR(6), L.dtmExpiryDate, 12)) strBestby
	INTO #tblMFEDI945
	FROM dbo.tblICInventoryShipment InvS
	JOIN @tblMFOrderNo O ON O.intInventoryShipmentId = InvS.intInventoryShipmentId
	JOIN dbo.tblICInventoryShipmentItem InvSI ON InvSI.intInventoryShipmentId = InvS.intInventoryShipmentId
	JOIN dbo.tblICInventoryShipmentItemLot InvSL ON InvSL.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId
	JOIN dbo.tblICLot L ON L.intLotId = InvSL.intLotId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN vyuMFGetInventoryShipmentCustomField CF ON CF.intRecordId = InvS.intInventoryShipmentId
	JOIN dbo.tblEMEntity E ON E.intEntityId = InvS.intEntityCustomerId
	JOIN dbo.tblEMEntityLocation EL ON EL.intEntityLocationId = InvS.intShipToLocationId
	JOIN tblICItem I ON I.intItemId = InvSI.intItemId
	LEFT JOIN tblMFEDI940Archive EDI ON EDI.intInventoryShipmentItemId = InvSI.intInventoryShipmentItemId

	SELECT *
	INTO #tblMFSSCCNo
	FROM dbo.vyuMFGetPalletSSCCNo
	WHERE strReferenceNo IN (
			SELECT strShipmentNo
			FROM @tblMFOrderNo
			)

	SELECT DISTINCT DT.strTransactionId
		,DT.strCustomerId
		,DT.strType
		,DT.strDepositorOrderNumber
		,DT.strPurchaseOrderNumber
		,DT.dtmShipmentDate
		,DT.strShipmentId
		,DT.strName
		,DT.strShipToAddress
		,DT.strShipToCity
		,DT.strShipToState
		,DT.strShipToZipCode
		,DT.strShipToCode
		,DT.strShipmentId
		,DT.dtmShippedDate
		,DT.strTransportationMethod
		,DT.strSCAC
		,DT.strRouting
		,DT.strShipmentMethodOfPayment
		,DT.strTotalPalletsLoaded
		,DT.dblTotalUnitsShipped
		,DT.dblTotalWeight
		,DT.strWeightUOM
		,DT.intLineNo
		,DT.strSSCCNo
		,DT.strOrderStatus
		,DT.strUPCCaseCode
		,DT.strItemNo
		,DT.strDescription
		,DT.dblQtyOrdered
		,DT.dblQtyShipped
		,DT.dblQtyDifference
		,DT.strUOM
		,DT.strParentLotNumber AS strLotNumber
		,DT.strBestBy
	FROM (
		SELECT EDI.strTransactionId
			,EDI.strCustomerId
			,EDI.strType
			,EDI.strDepositorOrderNumber
			,EDI.strPurchaseOrderNumber
			,EDI.dtmShipmentDate
			--,EDI.strShipmentId
			,EDI.strName
			,EDI.strShipToAddress
			,EDI.strShipToCity
			,EDI.strShipToState
			,EDI.strShipToZipCode
			,EDI.strShipToCode
			,EDI.strShipmentId
			,EDI.dtmShippedDate
			,EDI.strTransportationMethod
			,EDI.strSCAC
			,EDI.strRouting
			,EDI.strShipmentMethodOfPayment
			,EDI.strTotalPalletsLoaded
			,EDI.dblTotalUnitsShipped
			,EDI.dblTotalWeight
			,EDI.strWeightUOM
			,EDI.intLineNo
			,SSCCNo.strSSCCNo
			,EDI.strOrderStatus
			,EDI.strUPCCaseCode
			,EDI.strItemNo
			,EDI.strDescription
			,EDI.dblQtyOrdered
			,SUM(EDI.dblQtyShipped) OVER (
				PARTITION BY EDI.strShipmentId
				,EDI.strParentLotNumber
				,EDI.strItemNo
				) dblQtyShipped
			,EDI.dblQtyOrdered - SUM(EDI.dblQtyShipped) OVER (
				PARTITION BY EDI.strShipmentId
				,EDI.strItemNo
				) AS dblQtyDifference
			,EDI.strUOM
			,EDI.strParentLotNumber
			,EDI.strBestBy
		FROM #tblMFEDI945 EDI
		LEFT JOIN #tblMFSSCCNo SSCCNo ON SSCCNo.strLotNumber = EDI.strLotNumber
		) AS DT
	ORDER BY DT.strDepositorOrderNumber
		,DT.intLineNo

	INSERT INTO tblMFEDI945 (
		intInventoryShipmentId
		,strDepositorOrderNumber
		)
	SELECT intInventoryShipmentId
		,strOrderNo
	FROM @tblMFOrderNo
END
