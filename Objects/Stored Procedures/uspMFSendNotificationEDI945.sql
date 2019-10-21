CREATE PROCEDURE uspMFSendNotificationEDI945
AS
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM tblMFEDI945Error
			WHERE ysnNotify = 1
				AND IsNULL(ysnSentEMail, 0) = 0
			)
	BEGIN
		RAISERROR (
				'No data.'
				,16
				,1
				)

		RETURN
	END

	SELECT strTransactionId
		,strCustomerId
		,strType
		,strDepositorOrderNumber
		,strPurchaseOrderNumber
		,dtmShipmentDate
		,strShipmentId
		,strName
		,strShipToAddress1
		,strShipToAddress2
		,strShipToCity
		,strShipToState
		,strShipToZipCode
		,strShipToCode
		,strBOL
		,dtmShippedDate
		,strTransportationMethod
		,strSCAC
		,strRouting
		,strShipmentMethodOfPayment
		,strTotalPalletsLoaded
		,dblTotalUnitsShipped
		,dblTotalWeight
		,strWeightUOM
		,intLineNo
		,strSSCCNo
		,strOrderStatus
		,strUPCCaseCode
		,strItemNo
		,strDescription
		,dblQtyOrdered
		,dblQtyShipped
		,dblQtyDifference
		,strUOM
		,strParentLotNumber
		,strBestBy
		,intRowNumber
	FROM tblMFEDI945Error
	WHERE ysnNotify = 1
		AND IsNULL(ysnSentEMail, 0) = 0

	UPDATE tblMFEDI945Error
	SET ysnSentEMail = 1
	WHERE ysnNotify = 1
		AND IsNULL(ysnSentEMail, 0) = 0
END

