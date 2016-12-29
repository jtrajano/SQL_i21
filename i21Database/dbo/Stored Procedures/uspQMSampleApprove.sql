﻿CREATE PROCEDURE [dbo].[uspQMSampleApprove]
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
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intItemId INT
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intCurrentLotStatusId INT
	DECLARE @intLotId INT
	DECLARE @ysnChangeLotStatusOnApproveforPreSanitizeLot BIT
	DECLARE @intContractDetailId INT
	DECLARE @intLoadDetailContainerLinkId INT
	DECLARE @intSampleStatusId INT
	DECLARE @ysnRejectLGContainer BIT
	DECLARE @intUserSampleApproval INT
	DECLARE @intApproveRejectUserId INT

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

	BEGIN TRAN

	SELECT @intContractDetailId = intContractDetailId
		,@intLoadDetailContainerLinkId = intLoadDetailContainerLinkId
		,@intSampleStatusId = intSampleStatusId
		,@intApproveRejectUserId = intTestedById
	FROM tblQMSample
	WHERE intSampleId = @intSampleId

	SELECT TOP 1 @intUserSampleApproval = ISNULL(intUserSampleApproval, 0)
	FROM tblQMCompanyPreference

	IF @intUserSampleApproval <> 0 -- No Check
	BEGIN
		IF @intSampleStatusId = 4 -- Only for Rejected to Approved
		BEGIN
			IF @intApproveRejectUserId <> @intLastModifiedUserId
			BEGIN
				IF @intUserSampleApproval = 1 -- User Check
				BEGIN
					RAISERROR (
						90025
						,11
						,1
						,'rejected'
						,'user'
						,'approve'
						)
				END
				ELSE IF @intUserSampleApproval = 2 -- User Role Check
				BEGIN
					DECLARE @intApproveRejectUserRoleID INT
					DECLARE @intUserRoleID INT

					SELECT @intApproveRejectUserRoleID = intUserRoleID
					FROM tblSMUserSecurity
					WHERE intEntityUserSecurityId = @intApproveRejectUserId

					SELECT @intUserRoleID = intUserRoleID
					FROM tblSMUserSecurity
					WHERE intEntityUserSecurityId = @intLastModifiedUserId

					IF @intApproveRejectUserRoleID <> @intUserRoleID
					BEGIN
						RAISERROR (
							90025
							,11
							,1
							,'rejected'
							,'user role'
							,'approve'
							)
					END
				END
			END
		END
	END

	SELECT TOP 1 @ysnRejectLGContainer = ISNULL(ysnRejectLGContainer, 0)
	FROM tblQMCompanyPreference

	IF @ysnRejectLGContainer = 1
	BEGIN
		IF @intContractDetailId IS NOT NULL
			AND @intLoadDetailContainerLinkId IS NOT NULL
			AND @intSampleStatusId = 4 -- Only for Rejected to Approved
		BEGIN
			EXEC uspLGRejectContainerFromQuality @intLoadDetailContainerLinkId
				,@intContractDetailId
				,0
				,@intLastModifiedUserId
		END
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
				SET @intLotStatusId = @intCurrentLotStatusId
		END

		IF @intCurrentLotStatusId <> @intLotStatusId
		BEGIN
			EXEC uspMFSetLotStatus @intLotId = @intProductValueId
				,@intNewLotStatusId = @intLotStatusId
				,@intUserId = @intLastModifiedUserId
		END
	END

	IF @intProductTypeId = 11 -- Parent Lot
	BEGIN
		DECLARE @intSeqNo INT
		DECLARE @ParentLotData TABLE (
			intSeqNo INT IDENTITY(1, 1)
			,intLotId INT
			,strLotNumber NVARCHAR(50)
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
					SET @intLotStatusId = @intCurrentLotStatusId
			END

			IF @intCurrentLotStatusId <> @intLotStatusId
			BEGIN
				EXEC uspMFSetLotStatus @intLotId = @intLotId
					,@intNewLotStatusId = @intLotStatusId
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
