CREATE PROCEDURE uspMFSendNotificationEDI940
AS
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM tblMFEDI940Archive
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

	SELECT intTransactionId
		,strCustomerId
		,strPurpose
		,strDepositorOrderNumber
		,strPONumber
		,strShipToName
		,strShipToAddress1
		,strShipToAddress2
		,strShipToCity
		,strShipToState
		,strShipToZip
		,strShipToCode
		,strBuyerIdentification
		,strPODate
		,strDeliveryRequestedDate
		,intLineNumber
		,strCustomerItemNumber
		,strUPCCaseCode
		,strDescription
		,dblQtyOrdered
		,strUOM
		,dblInnerPacksPerOuterPack
		,dblTotalQtyOrdered
		,dtmCreated
		,strFileName
		,strShipmentDate
		,strTransportationMethod
		,strSCAC
		,strRouting
		,strShipmentMethodOfPayment
		,strCustomerCode
	FROM tblMFEDI940Archive
	WHERE ysnNotify = 1
		AND IsNULL(ysnSentEMail, 0) = 0

	UPDATE tblMFEDI940Archive
	SET ysnSentEMail = 1
	WHERE ysnNotify = 1
		AND IsNULL(ysnSentEMail, 0) = 0
END
