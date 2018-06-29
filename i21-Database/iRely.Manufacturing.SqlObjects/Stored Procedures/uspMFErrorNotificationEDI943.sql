Create PROCEDURE uspMFErrorNotificationEDI943
AS
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM tblMFEDI943Error
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
		,strType
		,strDepositorOrderNumber
		,dtmDate
		,strShipmentId
		,strActionCode
		,strShipFromName
		,strShipFromAddress1
		,strShipFromAddress2
		,strShipFromCity
		,strShipFromState
		,strShipFromZip
		,strShipFromCode
		,strTransportationMethod
		,strSCAC
		,dblTotalNumberofUnitsShipped
		,dblTotalWeight
		,strWeightUOM
		,strVendorItemNumber
		,strDescription
		,dblQtyShipped
		,strUOM
		,dtmCreated
		,strFileName
		,strParentLotNumber
		,intLineNumber
		,strWarehouseCode
		,strErrorMessage
	FROM tblMFEDI943Error
	WHERE IsNULL(ysnSentEMail, 0) = 0

	UPDATE tblMFEDI943Error
	SET ysnSentEMail = 1
	WHERE IsNULL(ysnSentEMail, 0) = 0
END

