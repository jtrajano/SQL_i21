CREATE PROCEDURE uspMFSetLotDetail @intLotId INT
	,@intNewItemOwnerId INT
	,@intUserId INT
	,@strParentLotNumber NVARCHAR(50)
	,@strVendorRefNo NVARCHAR(50)
	,@strWarehouseRefNo NVARCHAR(50)
	,@strContainerNo NVARCHAR(50)
	,@strNotes NVARCHAR(MAX)
	,@ysnUpdateOwnerOnly BIT = 0
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@dtmDate DATETIME = NULL
	,@ysnBulkChange BIT = 0
	,@strNewLotAlias NVARCHAR(50) = NULL
	,@strNewVendorLotNumber NVARCHAR(50) = NULL
	,@dtmNewDueDate DATETIME=NULL
AS
BEGIN TRY
	DECLARE @intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strLotNumber NVARCHAR(50)
		,@intItemId INT

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @strLotNumber = strLotNumber
		,@intItemId = intItemId
	FROM tblICLot
	WHERE intLotId = @intLotId

	DECLARE @tblMFLot TABLE (intLotId INT)

	INSERT INTO @tblMFLot
	SELECT intLotId
	FROM tblICLot
	WHERE strLotNumber = @strLotNumber
		AND intItemId = @intItemId

	SELECT @intLotId = NULL

	SELECT @intLotId = Min(intLotId)
	FROM @tblMFLot

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	WHILE @intLotId IS NOT NULL
	BEGIN
		EXEC dbo.uspMFLotOwnerUpdate @intLotId = @intLotId
			,@intNewItemOwnerId = @intNewItemOwnerId
			,@intUserId = @intUserId
			,@strParentLotNumber = @strParentLotNumber
			,@strVendorRefNo = @strVendorRefNo
			,@strWarehouseRefNo = @strWarehouseRefNo
			,@strContainerNo = @strContainerNo
			,@strNotes = @strNotes
			,@ysnUpdateOwnerOnly = @ysnUpdateOwnerOnly
			,@strReasonCode = @strReasonCode
			,@dtmDate = @dtmDate
			,@ysnBulkChange = @ysnBulkChange
			,@strNewLotAlias = @strNewLotAlias
			,@strNewVendorLotNumber = @strNewVendorLotNumber
			,@dtmNewDueDate=@dtmNewDueDate

		SELECT @intLotId = Min(intLotId)
		FROM @tblMFLot
		WHERE intLotId > @intLotId
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
