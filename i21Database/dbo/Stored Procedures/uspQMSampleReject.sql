CREATE PROCEDURE [dbo].[uspQMSampleReject]
	@strXml NVARCHAR(Max)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(Max)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @intSampleId INT
	DECLARE @intProductTypeId INT
	DECLARE @intProductValueId INT
	DECLARE @intLotStatusId INT
	DECLARE @intLastModifiedUserId INT
	DECLARE @dtmLastModified DATETIME
	DECLARE @strLotNumber NVARCHAR(30)
	DECLARE @intItemId INT
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intCurrentLotStatusId INT

	SELECT @intSampleId = intSampleId
		,@intProductTypeId = intProductTypeId
		,@intProductValueId = intProductValueId
		,@intLotStatusId = intLotStatusId
		,@intLastModifiedUserId = intLastModifiedUserId
		,@dtmLastModified = dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleId INT
			,intProductTypeId INT
			,intProductValueId INT
			,intLotStatusId INT
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	BEGIN TRAN

	UPDATE dbo.tblQMSample
	SET intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
		,intSampleStatusId = 4 -- Rejected
		,intTestedById = x.intLastModifiedUserId
		,dtmTestedOn = x.dtmLastModified
		,intLastModifiedUserId = x.intLastModifiedUserId
		,dtmLastModified = x.dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLastModifiedUserId INT
			,dtmLastModified DATETIME
			) x
	WHERE dbo.tblQMSample.intSampleId = @intSampleId

	IF @intProductTypeId = 6 -- Lot
	BEGIN
		SELECT @strLotNumber = strLotNumber
			,@intItemId = intItemId
			,@intLocationId = intLocationId
			,@intSubLocationId = intSubLocationId
			,@intStorageLocationId = intStorageLocationId
			,@intCurrentLotStatusId = intLotStatusId
		FROM dbo.tblICLot
		WHERE intLotId = @intProductValueId

		IF @intCurrentLotStatusId <> @intLotStatusId
		BEGIN
			EXEC uspICInventoryAdjustment_CreatePostLotStatusChange @intItemId = @intItemId
				,@dtmDate = @dtmLastModified
				,@intLocationId = @intLocationId
				,@intSubLocationId = @intSubLocationId
				,@intStorageLocationId = @intStorageLocationId
				,@strLotNumber = @strLotNumber
				,@intNewLotStatusId = @intLotStatusId
				,@intSourceId = 1
				,@intSourceTransactionTypeId = 8
				,@intUserId = @intLastModifiedUserId
				,@intInventoryAdjustmentId = NULL
		END
	END

	IF @intProductTypeId = 11 -- Parent Lot
	BEGIN
		DECLARE @intSeqNo INT
		DECLARE @ParentLotData TABLE (
			intSeqNo INT IDENTITY(1, 1)
			,intLotId INT
			,strLotNumber NVARCHAR(30)
			,intItemId INT
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,intLotStatusId INT
			)

		INSERT INTO @ParentLotData (
			intLotId
			,strLotNumber
			,intItemId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,intLotStatusId
			)
		SELECT intLotId
			,strLotNumber
			,intItemId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,intLotStatusId
		FROM dbo.tblICLot
		WHERE intParentLotId = @intProductValueId

		SELECT @intSeqNo = MIN(intSeqNo)
		FROM @ParentLotData

		WHILE (@intSeqNo > 0)
		BEGIN
			SELECT @strLotNumber = strLotNumber
				,@intItemId = intItemId
				,@intLocationId = intLocationId
				,@intSubLocationId = intSubLocationId
				,@intStorageLocationId = intStorageLocationId
				,@intCurrentLotStatusId = intLotStatusId
			FROM @ParentLotData
			WHERE intSeqNo = @intSeqNo

			IF @intCurrentLotStatusId <> @intLotStatusId
			BEGIN
				EXEC uspICInventoryAdjustment_CreatePostLotStatusChange @intItemId = @intItemId
					,@dtmDate = @dtmLastModified
					,@intLocationId = @intLocationId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId
					,@strLotNumber = @strLotNumber
					,@intNewLotStatusId = @intLotStatusId
					,@intSourceId = 1
					,@intSourceTransactionTypeId = 8
					,@intUserId = @intLastModifiedUserId
					,@intInventoryAdjustmentId = NULL
			END

			SELECT @intSeqNo = MIN(intSeqNo)
			FROM @ParentLotData
			WHERE intSeqNo > @intSeqNo
		END
	END

	EXEC sp_xml_removedocument @idoc

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
