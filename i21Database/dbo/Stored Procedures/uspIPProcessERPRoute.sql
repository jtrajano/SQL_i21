CREATE PROCEDURE uspIPProcessERPRoute @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	--SET ANSI_WARNINGS OFF
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@strError NVARCHAR(MAX)
	DECLARE @intTrxSequenceNo INT
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intItemRouteStageId INT
		,@strItemNo NVARCHAR(100)
	DECLARE @intCompanyLocationId INT
		,@intItemId INT
		,@intItemFactoryId INT
		,@intNewItemRouteStageId INT
	DECLARE @intItemRouteDetailStageId INT
		,@strManufacturingCell NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strManufacturingGroup NVARCHAR(50)
	DECLARE @intManufacturingCellId INT
		,@intSubLocationId INT
		,@intItemFactoryManufacturingCellId INT

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @intItemRouteStageId = MIN(intItemRouteStageId)
	FROM tblIPItemRouteStage

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(strItemNo, '') + ', '
	FROM tblIPItemRouteStage

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	--SELECT @strInfo2 = @strInfo2 + ISNULL(strRateType, '') + ', '
	--FROM (
	--	SELECT DISTINCT strRateType
	--	FROM tblIPItemRouteStage
	--	) AS DT
	--IF Len(@strInfo2) > 0
	--BEGIN
	--	SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	--END
	WHILE (@intItemRouteStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strItemNo = NULL

			SELECT @intCompanyLocationId = NULL
				,@intItemId = NULL
				,@intItemFactoryId = NULL
				,@intNewItemRouteStageId = NULL
				,@intItemRouteDetailStageId = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strItemNo = strItemNo
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			IF EXISTS (
					SELECT 1
					FROM tblIPItemRouteArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo is exists in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			SELECT @intItemId = intItemId
			FROM dbo.tblICItem WITH (NOLOCK)
			WHERE strItemNo = @strItemNo

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intItemId IS NULL
			BEGIN
				SELECT @strError = 'Item No not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			SELECT @intItemFactoryId = intItemFactoryId
			FROM dbo.tblICItemFactory
			WHERE intItemId = @intItemId
				AND intFactoryId = @intCompanyLocationId

			IF @intActionId = 4
			BEGIN
				IF @intItemFactoryId > 0
				BEGIN
					DELETE
					FROM tblICItemFactory
					WHERE intItemFactoryId = @intItemFactoryId
				END
			END
			ELSE IF @intActionId = 1
				OR @intActionId = 2
			BEGIN
				IF @intItemFactoryId IS NULL
				BEGIN
					INSERT INTO tblICItemFactory (
						intItemId
						,intFactoryId
						,ysnDefault
						,intSort
						,intConcurrencyId
						)
					SELECT @intItemId
						,@intCompanyLocationId
						,0
						,0
						,1

					SELECT @intItemFactoryId = intItemFactoryId
					FROM dbo.tblICItemFactory
					WHERE intItemId = @intItemId
						AND intFactoryId = @intCompanyLocationId
				END

				SELECT @intItemRouteDetailStageId = MIN(intItemRouteDetailStageId)
				FROM tblIPItemRouteDetailStage
				WHERE intItemRouteStageId = @intItemRouteStageId

				WHILE (@intItemRouteDetailStageId IS NOT NULL)
				BEGIN
					SELECT @strManufacturingCell = NULL
						,@strSubLocationName = NULL
						,@strManufacturingGroup = NULL

					SELECT @intManufacturingCellId = NULL
						,@intSubLocationId = NULL
						,@intItemFactoryManufacturingCellId = NULL

					SELECT @strManufacturingCell = strManufacturingCell
						,@strSubLocationName = strStorageLocation
						,@strManufacturingGroup = strManufacturingGroup
					FROM tblIPItemRouteDetailStage
					WHERE intItemRouteDetailStageId = @intItemRouteDetailStageId

					IF ISNULL(@strManufacturingCell, '') = ''
					BEGIN
						SELECT @strError = 'Manufacturing Cell cannot be blank.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END

					SELECT @intSubLocationId = intCompanyLocationSubLocationId
					FROM dbo.tblSMCompanyLocationSubLocation WITH (NOLOCK)
					WHERE strSubLocationName = @strSubLocationName

					IF @intSubLocationId IS NULL
					BEGIN
						SELECT @strError = 'Storage Location not found.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END

					SELECT @intManufacturingCellId = intManufacturingCellId
					FROM tblMFManufacturingCell
					WHERE strCellName = @strManufacturingCell
						AND intSubLocationId = @intSubLocationId
						AND intLocationId = @intCompanyLocationId

					IF @intManufacturingCellId IS NULL
					BEGIN
						SELECT @strError = 'Manufacturing Cell not found.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END

					SELECT @intItemFactoryManufacturingCellId = intItemFactoryManufacturingCellId
					FROM tblICItemFactoryManufacturingCell
					WHERE intItemFactoryId = @intItemFactoryId
						AND intManufacturingCellId = @intManufacturingCellId

					IF @intItemFactoryManufacturingCellId IS NULL
					BEGIN
						INSERT INTO tblICItemFactoryManufacturingCell (
							intItemFactoryId
							,intManufacturingCellId
							,ysnDefault
							,intPreference
							,intSort
							,intConcurrencyId
							)
						SELECT @intItemFactoryId
							,@intManufacturingCellId
							,0
							,(
								SELECT ISNULL(MAX(intPreference), 0) + 1
								FROM tblICItemFactoryManufacturingCell
								WHERE intItemFactoryId = @intItemFactoryId
								)
							,0
							,1

						SELECT @intItemFactoryManufacturingCellId = SCOPE_IDENTITY()
					END

					SELECT @intItemRouteDetailStageId = MIN(intItemRouteDetailStageId)
					FROM tblIPItemRouteDetailStage
					WHERE intItemRouteDetailStageId > @intItemRouteDetailStageId
						AND intItemRouteStageId = @intItemRouteStageId
				END
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPItemRouteArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			SELECT @intNewItemRouteStageId = SCOPE_IDENTITY()

			INSERT INTO tblIPItemRouteDetailArchive (
				intItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				)
			SELECT @intNewItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
			FROM tblIPItemRouteDetailStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			DELETE
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPItemRouteError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				,@ErrMsg
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			SELECT @intNewItemRouteStageId = SCOPE_IDENTITY()

			INSERT INTO tblIPItemRouteDetailError (
				intItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				)
			SELECT @intNewItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
			FROM tblIPItemRouteDetailStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			DELETE
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId
		END CATCH

		SELECT @intItemRouteStageId = MIN(intStageItemId)
		FROM tblIPItemStage
		WHERE intStageItemId > @intItemRouteStageId
	END

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
