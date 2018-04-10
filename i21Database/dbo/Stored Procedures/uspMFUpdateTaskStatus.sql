CREATE PROCEDURE uspMFUpdateTaskStatus (
	@strPickNo NVARCHAR(50)
	,@strLotNumber NVARCHAR(50)
	,@strDockDoorLocation NVARCHAR(50)
	,@intUserId INT
	,@intLocationId INT
	)
AS
BEGIN TRY
	Declare @strErrMsg nvarchar(MAX)
	DECLARE @tblMFTask TABLE (
		intTaskId INT
		,intOrderHeaderId INT
		)

	INSERT INTO @tblMFTask (
		intTaskId
		,intOrderHeaderId
		)
	SELECT T.intTaskId
		,T.intOrderHeaderId
	FROM tblMFTask T
	JOIN tblICLot L ON L.intLotId = T.intLotId
	WHERE T.strTaskNo = @strPickNo
	and L.strLotNumber=@strLotNumber

	DECLARE @intTaskId INT
		,@intOrderHeaderId INT
		,@intStorageLocationId int
		,@intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT

	Select @intStorageLocationId =intStorageLocationId 
	from tblICStorageLocation
	Where strName=@strDockDoorLocation and intLocationId =@intLocationId 

	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	Update tblMFTask
	Set intToStorageLocationId=@intStorageLocationId
	Where strTaskNo =@strPickNo and intToStorageLocationId is null

	SELECT @intTaskId = MIN(intTaskId)
	FROM @tblMFTask

	WHILE @intTaskId IS NOT NULL
	BEGIN
		SELECT @intOrderHeaderId = NULL

		SELECT @intOrderHeaderId = intOrderHeaderId
		FROM @tblMFTask
		WHERE intTaskId = @intTaskId

		EXEC uspMFCompleteTask @intOrderHeaderId = @intOrderHeaderId
			,@intUserId = @intUserId
			,@strTaskId = @intTaskId
			,@ysnLoad=1

		SELECT @intTaskId = MIN(intTaskId)
		FROM @tblMFTask
		WHERE intTaskId > @intTaskId
	END
	IF @intTransactionCount = 0
	COMMIT TRANSACTION
END TRY

BEGIN CATCH
IF XACT_STATE() != 0
		AND @intTransactionCount = 0
	ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg

		RAISERROR (
				@strErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH

