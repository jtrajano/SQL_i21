CREATE PROCEDURE uspMFReprocessEDI940 (@strOrderNo NVARCHAR(50))
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	INSERT INTO tblMFEDI940 (
		intTransactionId
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
		,intCustomerCodeType
		,ysnNotify
		)
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
		,intCustomerCodeType
		,0
	FROM tblMFEDI940Error
	WHERE strDepositorOrderNumber = @strOrderNo

	DELETE
	FROM tblMFEDI940Error
	WHERE strDepositorOrderNumber = @strOrderNo

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
