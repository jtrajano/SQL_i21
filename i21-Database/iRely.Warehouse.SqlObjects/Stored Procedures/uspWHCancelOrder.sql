CREATE PROCEDURE [dbo].[uspWHCancelOrder] @intOrderHeaderId INT
	,@strUserName NVARCHAR(32)
AS
BEGIN TRY
	SET NOCOUNT ON

	BEGIN TRANSACTION

	DECLARE @intShipToAddressId INT
	DECLARE @intShipFromAddressId INT
	DECLARE @intOrderDirectionId INT
	DECLARE @intTruckId INT
	DECLARE @TaskCount INT
	DECLARE @intOrderTypeId INT
	DECLARE @intSanitizationOrderId INT
	DECLARE @intOrderCount INT
	DECLARE @ysnLifetimeUnitMonthEndofMonth BIT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strBOLNo NVARCHAR(64)

	--SELECT @ysnLifetimeUnitMonthEndofMonth = SettingValue
	--FROM dbo.iMake_AppSetting S
	--JOIN dbo.iMake_AppSettingValue SV ON S.SettingKey = SV.SettingKey
	--WHERE SettingName = 'Lifetime-UnitMonth-EndofMonth'
	SET @strErrMsg = ''
	SET @intTruckId = 0

	SELECT @intTruckId = intTruckId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Get the BOL Number          
	SELECT @strBOLNo = strBOLNo
		,@intShipToAddressId = intShipToAddressId
		,@intShipFromAddressId = intShipFromAddressId
		,@intOrderDirectionId = intOrderDirectionId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Get the number of tasks          
	SELECT @TaskCount = ISNULL(COUNT(*), 0)
	FROM tblWHTask
	WHERE strTaskNo = @strBOLNo

	IF @TaskCount > 0
	BEGIN
		RAISERROR (
				'There are tasks associated with this order and cannot be cancelled. Please delete the tasks before cancelling the order.'
				,16
				,1
				)
	END

	--Update the ship date and status in the order header          
	UPDATE tblWHOrderHeader
	SET dtmShipDate = '1/1/1900'
		,intOrderStatusId = 4
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intOrderTypeId = intOrderTypeId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	IF EXISTS (
			SELECT *
			FROM dbo.tblWHOrderType
			WHERE strInternalCode = 'SP'
				AND intOrderTypeId = @intOrderTypeId
			)
	BEGIN
		RAISERROR (
				'The lot(s) are already created for this order. You cannot cancel it.'
				,16
				,1
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblWHOrderType
			WHERE strInternalCode = 'PS'
				AND intOrderTypeId = @intOrderTypeId
			)
	BEGIN
		UPDATE dbo.tblMFWorkOrder
		SET intOrderHeaderId = NULL
			,strBOLNo = NULL
		WHERE intOrderHeaderId = @intOrderHeaderId
	END
	ELSE IF EXISTS (
			SELECT *
			FROM dbo.tblWHOrderType
			WHERE strInternalCode = 'SS'
				AND intOrderTypeId = @intOrderTypeId
			)
	BEGIN
		UPDATE dbo.tblMFWorkOrder
		SET intOrderHeaderId = NULL
			,strBOLNo = NULL
			,intStatusId = 14
		WHERE intOrderHeaderId = @intOrderHeaderId

		SELECT @intSanitizationOrderId = intWorkOrderId
		FROM tblMFWorkOrder
		WHERE intOrderHeaderId = @intOrderHeaderId
	END

	--Check already the strBOLNo available in the archive table or not. If yes then suffix appropriate text (eg. C1 / C2 ...) to the strBOLNo.      
	SET @intOrderCount = 0
	SET @intOrderCount = @intOrderCount + 1

	--Archive The order header containier Mapping data  
	--Delete the order line items          
	DELETE
	FROM tblWHOrderLineItem
	WHERE intOrderHeaderId = @intOrderHeaderId

	-- Delete the order header contaienr manpping  
	--DELETE
	--FROM tblWHOrderHeaderContainers
	--WHERE intOrderHeaderId = @intOrderHeaderId
	--Delete the order          
	DELETE
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	IF NOT EXISTS (
			SELECT intTruckId
			FROM tblWHOrderHeader
			WHERE intTruckId = @intTruckId
			)
		DELETE
		FROM tblWHTruck
		WHERE intTruckId = @intTruckId

	-- EXEC Lot_ReserveRelease @strBOLNo,4  
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspWHCancelOrder: ' + @strErrMsg

		RAISERROR (
				@strErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH
