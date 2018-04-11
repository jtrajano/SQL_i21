CREATE PROCEDURE uspMFReprocessEDI943 (@strOrderNo NVARCHAR(50))
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	INSERT INTO tblMFEDI943 (
		intTransactionId
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
		,intWarehouseCodeType
		,ysnNotify
		)
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
		,intWarehouseCodeType
		,0
	FROM tblMFEDI943Error
	WHERE strDepositorOrderNumber = @strOrderNo

	DELETE
	FROM tblMFEDI943Error
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
