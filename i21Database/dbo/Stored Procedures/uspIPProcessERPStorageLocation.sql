CREATE PROCEDURE [dbo].[uspIPProcessERPStorageLocation] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	--SET ANSI_WARNINGS OFF
	DECLARE @intStorageLocationStageId INT
	DECLARE @strStorageUnit NVARCHAR(50)
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @strDescription NVARCHAR(250)
	DECLARE @strJson NVARCHAR(Max)
	DECLARE @dtmDate DATETIME
	DECLARE @intUserId INT
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@strStorageLocation NVARCHAR(50)
		,@strStorageUnitType NVARCHAR(50)
		,@intCompanyLocationSubLocationId INT
		,@intCompanyLocationId INT
		,@intStorageUnitTypeId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@intStorageLocationId INT
		,@strError NVARCHAR(MAX)
		,@intTrxSequenceNo BIGINT
	DECLARE @tblICStorageLocation TABLE (
		strOldDescription NVARCHAR(100)
		,strNewDescription NVARCHAR(100)
		,intOldStorageUnitTypeId INT
		,intNewStorageUnitTypeId INT
		)

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	DECLARE @tblIPStorageLocationStage TABLE (intStorageLocationStageId INT)

	INSERT INTO @tblIPStorageLocationStage (intStorageLocationStageId)
	SELECT intStorageLocationStageId
	FROM dbo.tblIPStorageLocationStage
	WHERE intStatusId IS NULL

	SELECT @intStorageLocationStageId = MIN(intStorageLocationStageId)
	FROM @tblIPStorageLocationStage

	IF @intStorageLocationStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblIPStorageLocationStage
	SET intStatusId = - 1
	WHERE intStorageLocationStageId IN (
			SELECT SL.intStorageLocationStageId
			FROM @tblIPStorageLocationStage SL
			)

	SELECT @strInfo1 = ''

	SELECT @strInfo2 = ''

	--SELECT @strInfo1 = @strInfo1 + ISNULL(strStorageUnit, '') + ', '
	--FROM @tblIPStorageLocationStage

	--IF Len(@strInfo1) > 0
	--BEGIN
	--	SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	--END

	--SELECT @strInfo2 = @strInfo2 + ISNULL(strStorageLocation, '') + ', '
	--FROM (
	--	SELECT DISTINCT strStorageLocation
	--	FROM @tblIPStorageLocationStage
	--	) AS DT

	--IF Len(@strInfo2) > 0
	--BEGIN
	--	SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	--END

	WHILE (@intStorageLocationStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL
				,@strStorageLocation = NULL
				,@strStorageUnit = NULL
				,@strDescription = NULL
				,@strStorageUnitType = NULL
				,@intCompanyLocationSubLocationId = NULL
				,@intCompanyLocationId = NULL
				,@intStorageUnitTypeId = NULL
				,@intStorageLocationId = NULL
				,@intTrxSequenceNo = NULL

			SELECT @strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strStorageLocation = strStorageLocation
				,@strStorageUnit = strStorageUnit
				,@strDescription = strDescription
				,@strStorageUnitType = strStorageUnitType
				,@intTrxSequenceNo = intTrxSequenceNo
			FROM tblIPStorageLocationStage
			WHERE intStorageLocationStageId = @intStorageLocationStageId

			IF EXISTS (
					SELECT 1
					FROM tblIPStorageLocationArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + LTRIM(@intTrxSequenceNo) + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
			FROM dbo.tblSMCompanyLocationSubLocation
			WHERE strSubLocationName = @strStorageLocation

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			SELECT @intStorageUnitTypeId = intStorageUnitTypeId
			FROM dbo.tblICStorageUnitType
			WHERE strStorageUnitType = @strStorageUnitType

			IF @strStorageUnit IS NULL
				OR @strStorageUnit = ''
			BEGIN
				SELECT @strError = 'Storage Unit cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intCompanyLocationSubLocationId IS NULL
			BEGIN
				SELECT @strError = 'Storage Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intStorageUnitTypeId IS NULL
			BEGIN
				SELECT @strError = 'Storage Unit Type cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intActionId = 1
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblICStorageLocation
						WHERE strName = @strStorageUnit
							AND intSubLocationId = @intCompanyLocationSubLocationId
							AND intLocationId = @intCompanyLocationId
						)
				BEGIN
					SELECT @strError = 'Storage Unit ''' + @strStorageUnit + ''' is already exists.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END
			END

			BEGIN TRAN

			IF @intActionId = 1
			BEGIN
				INSERT INTO tblICStorageLocation (
					strName
					,strDescription
					,intStorageUnitTypeId
					,intLocationId
					,intSubLocationId
					,ysnAllowConsume
					,ysnAllowMultipleItem
					,ysnAllowMultipleLot
					,ysnMergeOnMove
					,ysnCycleCounted
					,intRestrictionId
					,intConcurrencyId
					,dtmDateCreated
					,dtmDateModified
					,intCreatedByUserId
					,intModifiedByUserId
					)
				SELECT @strStorageUnit
					,@strDescription
					,@intStorageUnitTypeId
					,@intCompanyLocationId
					,@intCompanyLocationSubLocationId
					,1 AS ysnAllowConsume
					,1 AS ysnAllowMultipleItem
					,1 AS ysnAllowMultipleLot
					,0 AS ysnMergeOnMove
					,1 AS ysnCycleCounted
					,1 AS intRestrictionId
					,1 AS intConcurrencyId
					,@dtmDateCreated AS dtmDateCreated
					,@dtmDateCreated AS dtmDateModified
					,@intUserId AS intCreatedByUserId
					,@intUserId AS intModifiedByUserId

				SELECT @intStorageLocationId = SCOPE_IDENTITY()

				EXEC uspSMAuditLog @keyValue = @intStorageLocationId
					,@screenName = 'Inventory.view.StorageLocation'
					,@entityId = @intUserId
					,@actionType = 'Created'
					,@actionIcon = 'small-new-plus'
					,@details = ''
			END
			ELSE IF @intActionId = 2
			BEGIN --Update
				SELECT @intStorageLocationId = intStorageLocationId
				FROM tblICStorageLocation
				WHERE strName = @strStorageUnit
					AND intSubLocationId = @intCompanyLocationSubLocationId
					AND intLocationId = @intCompanyLocationId

				UPDATE tblICStorageLocation
				SET strDescription = @strDescription
					,intStorageUnitTypeId = @intStorageUnitTypeId
				OUTPUT deleted.strDescription
					,inserted.strDescription
					,deleted.intStorageUnitTypeId
					,inserted.intStorageUnitTypeId
				INTO @tblICStorageLocation
				WHERE intStorageLocationId = @intStorageLocationId

				DECLARE @strDetails NVARCHAR(MAX) = ''

				IF EXISTS (
						SELECT *
						FROM @tblICStorageLocation
						WHERE IsNULL(strOldDescription, '') <> IsNULL(strNewDescription, '')
						)
					SELECT @strDetails += '{"change":"strDescription","iconCls":"small-gear","from":"' + IsNULL(strOldDescription, '') + '","to":"' + IsNULL(strNewDescription, '') + '","leaf":true,"changeDescription":"Description"},'
					FROM @tblICStorageLocation

				IF EXISTS (
						SELECT *
						FROM @tblICStorageLocation
						WHERE IsNULL(intOldStorageUnitTypeId, '') <> IsNULL(intNewStorageUnitTypeId, '')
						)
					SELECT @strDetails += '{"change":"strStorageUnitType","iconCls":"small-gear","from":"' + IsNULL(UT.strStorageUnitType, '') + '","to":"' + IsNULL(UT1.strStorageUnitType, '') + '","leaf":true,"changeDescription":"Storage Unit Type"},'
					FROM @tblICStorageLocation SL
					LEFT JOIN tblICStorageUnitType UT ON SL.intOldStorageUnitTypeId = UT.intStorageUnitTypeId
					LEFT JOIN tblICStorageUnitType UT1 ON SL.intOldStorageUnitTypeId = UT1.intStorageUnitTypeId

				IF (LEN(@strDetails) > 1)
				BEGIN
					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					EXEC uspSMAuditLog @keyValue = @intStorageLocationId
						,@screenName = 'Inventory.view.StorageLocation'
						,@entityId = @intUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails
				END
			END
			ELSE IF @intActionId = 4
			BEGIN
				SELECT @intStorageLocationId = intStorageLocationId
				FROM tblICStorageLocation
				WHERE strName = @strStorageUnit
					AND intSubLocationId = @intCompanyLocationSubLocationId
					AND intLocationId = @intCompanyLocationId

				DELETE
				FROM tblICStorageLocation
				WHERE intStorageLocationId = @intStorageLocationId
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO dbo.tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,7 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

			--Move to Archive
			INSERT INTO tblIPStorageLocationArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strStorageLocation
				,strStorageUnit
				,strDescription
				,strStorageUnitType
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strStorageLocation
				,strStorageUnit
				,strDescription
				,strStorageUnitType
			FROM tblIPStorageLocationStage
			WHERE intStorageLocationStageId = @intStorageLocationStageId

			DELETE
			FROM tblIPStorageLocationStage
			WHERE intStorageLocationStageId = @intStorageLocationStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO dbo.tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,7 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

			--Move to Error
			INSERT INTO tblIPStorageLocationError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strStorageLocation
				,strStorageUnit
				,strDescription
				,strStorageUnitType
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strStorageLocation
				,strStorageUnit
				,strDescription
				,strStorageUnitType
			FROM tblIPStorageLocationStage
			WHERE intStorageLocationStageId = @intStorageLocationStageId

			DELETE
			FROM tblIPStorageLocationStage
			WHERE intStorageLocationStageId = @intStorageLocationStageId
		END CATCH

		SELECT @intStorageLocationStageId = MIN(intStorageLocationStageId)
		FROM @tblIPStorageLocationStage
		WHERE intStorageLocationStageId > @intStorageLocationStageId
	END

	UPDATE tblIPStorageLocationStage
	SET intStatusId = NULL
	WHERE intStorageLocationStageId IN (
			SELECT SL.intStorageLocationStageId
			FROM @tblIPStorageLocationStage SL
			)
		AND intStatusId = - 1

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
