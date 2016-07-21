CREATE PROCEDURE [dbo].[uspQMSampleApprove]
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
	DECLARE @intLotId INT
	DECLARE @intApproveLotStatusId INT
	DECLARE @ysnChangeLotStatusOnApproveforPreSanitizeLot BIT
	DECLARE @intContractDetailId INT
	DECLARE @intLoadDetailContainerLinkId INT
	DECLARE @intSampleStatusId INT

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

	SELECT @ysnChangeLotStatusOnApproveforPreSanitizeLot = ysnChangeLotStatusOnApproveforPreSanitizeLot
	FROM dbo.tblQMCompanyPreference

	SELECT @intApproveLotStatusId = ISNULL(intApproveLotStatus, @intLotStatusId)
	FROM dbo.tblQMCompanyPreference

	BEGIN TRAN

	SELECT @intContractDetailId = intContractDetailId
		,@intLoadDetailContainerLinkId = intLoadDetailContainerLinkId
		,@intSampleStatusId = intSampleStatusId
	FROM tblQMSample

	IF @intContractDetailId IS NOT NULL
		AND @intLoadDetailContainerLinkId IS NOT NULL
		AND @intSampleStatusId = 4 -- Only for Rejected to Approved
	BEGIN
		EXEC uspLGRejectContainerFromQuality @intLoadDetailContainerLinkId
			,@intContractDetailId
			,0
			,@intLastModifiedUserId
	END

	UPDATE dbo.tblQMSample
	SET intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
		,intSampleStatusId = 3 -- Approved
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

		IF @intCurrentLotStatusId = 4 -- Pre-Sanitized
		BEGIN
			IF @ysnChangeLotStatusOnApproveforPreSanitizeLot = 0
				SET @intApproveLotStatusId = @intCurrentLotStatusId
		END

		IF @intCurrentLotStatusId <> @intApproveLotStatusId
		BEGIN
			EXEC uspMFSetLotStatus @intLotId = @intProductValueId
				,@intNewLotStatusId = @intApproveLotStatusId
				,@intUserId = @intLastModifiedUserId
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
			SELECT @intLotId = intLotId
				,@strLotNumber = strLotNumber
				,@intItemId = intItemId
				,@intLocationId = intLocationId
				,@intSubLocationId = intSubLocationId
				,@intStorageLocationId = intStorageLocationId
				,@intCurrentLotStatusId = intLotStatusId
			FROM @ParentLotData
			WHERE intSeqNo = @intSeqNo

			IF @intCurrentLotStatusId = 4 -- Pre-Sanitized
			BEGIN
				IF @ysnChangeLotStatusOnApproveforPreSanitizeLot = 0
					SET @intApproveLotStatusId = @intCurrentLotStatusId
			END

			IF @intCurrentLotStatusId <> @intApproveLotStatusId
			BEGIN
				EXEC uspMFSetLotStatus @intLotId = @intLotId
					,@intNewLotStatusId = @intApproveLotStatusId
					,@intUserId = @intLastModifiedUserId
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
