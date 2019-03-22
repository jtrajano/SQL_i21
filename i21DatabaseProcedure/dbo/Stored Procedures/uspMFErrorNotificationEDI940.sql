CREATE PROCEDURE uspMFErrorNotificationEDI940
AS
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM tblMFEDI940Error
			WHERE IsNULL(ysnSentEMail, 0) = 0
			)
	BEGIN
		RAISERROR (
				'Execution completed. Please check log for messages.'
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
		,strErrorMessage
	FROM tblMFEDI940Error
	WHERE IsNULL(ysnSentEMail, 0) = 0

	UPDATE tblMFEDI940Error
	SET ysnSentEMail = 1
	WHERE IsNULL(ysnSentEMail, 0) = 0
END

