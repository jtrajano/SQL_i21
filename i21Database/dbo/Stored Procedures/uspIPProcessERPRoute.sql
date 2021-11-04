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
	DECLARE @intTrxSequenceNo BIGINT
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
	DECLARE @tblICItemFactory TABLE (
		intItemFactoryId INT
		,strRowState NVARCHAR(50)
		)
	DECLARE @tblICItemFactoryManufacturingCell TABLE (
		intItemFactoryManufacturingCellId INT
		,intItemFactoryId INT
		,intManufacturingCellId INT
		,strRowState NVARCHAR(50)
		)
	DECLARE @strLocationName NVARCHAR(50)
	DECLARE @tblDeleteManufacturingCell TABLE (intManufacturingCellId INT)

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
				,@strLocationName = NULL

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
				SELECT @strError = 'TrxSequenceNo ' + LTRIM(@intTrxSequenceNo) + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
				,@strLocationName = strLocationName
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
				SELECT @strError = 'Item No "' + @strItemNo + '" not found.'

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

			DELETE
			FROM @tblICItemFactory

			DELETE
			FROM @tblICItemFactoryManufacturingCell

			IF @intActionId = 4
			BEGIN
				IF @intItemFactoryId > 0
				BEGIN
					DELETE F
					OUTPUT deleted.intItemFactoryId
						,'Deleted'
					INTO @tblICItemFactory
					FROM tblICItemFactory F
					WHERE F.intItemFactoryId = @intItemFactoryId
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
					OUTPUT inserted.intItemFactoryId
						,'Added'
					INTO @tblICItemFactory
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
						SELECT @strError = 'Storage Location "' + @strSubLocationName + '" not found.'

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
						OUTPUT inserted.intItemFactoryManufacturingCellId
							,inserted.intItemFactoryId
							,inserted.intManufacturingCellId
							,'Added'
						INTO @tblICItemFactoryManufacturingCell
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

				DELETE
				FROM @tblDeleteManufacturingCell

				INSERT INTO @tblDeleteManufacturingCell (intManufacturingCellId)
				SELECT IFMC.intManufacturingCellId
				FROM tblICItemFactoryManufacturingCell IFMC
				JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = IFMC.intManufacturingCellId
				WHERE IFMC.intItemFactoryId = @intItemFactoryId
					AND NOT EXISTS (
						SELECT 1
						FROM tblIPItemRouteDetailStage IRDS
						WHERE IRDS.intItemRouteStageId = @intItemRouteStageId
							AND IRDS.strManufacturingCell = MC.strCellName
						)

				INSERT INTO @tblICItemFactoryManufacturingCell (
					intItemFactoryManufacturingCellId
					,intItemFactoryId
					,intManufacturingCellId
					,strRowState
					)
				SELECT IFMC.intItemFactoryManufacturingCellId
					,IFMC.intItemFactoryId
					,IFMC.intManufacturingCellId
					,'Deleted'
				FROM tblICItemFactoryManufacturingCell IFMC
				JOIN @tblDeleteManufacturingCell DEL ON DEL.intManufacturingCellId = IFMC.intManufacturingCellId
					AND IFMC.intItemFactoryId = @intItemFactoryId

				DELETE IFMC
				FROM tblICItemFactoryManufacturingCell IFMC
				JOIN @tblDeleteManufacturingCell DEL ON DEL.intManufacturingCellId = IFMC.intManufacturingCellId
					AND IFMC.intItemFactoryId = @intItemFactoryId

				IF NOT EXISTS (
						SELECT 1
						FROM tblICItemFactoryManufacturingCell IFMC
						WHERE IFMC.intItemFactoryId = @intItemFactoryId
							AND IFMC.ysnDefault = 1
						)
				BEGIN
					UPDATE IFMC
					SET ysnDefault = 1
					FROM tblICItemFactoryManufacturingCell IFMC
					WHERE IFMC.intItemFactoryId = @intItemFactoryId
						AND IFMC.intManufacturingCellId IN (
							SELECT TOP 1 intManufacturingCellId
							FROM tblICItemFactoryManufacturingCell
							WHERE intItemFactoryId = @intItemFactoryId
							ORDER BY intItemFactoryManufacturingCellId
							)
				END
			END

			DECLARE @strDetails NVARCHAR(MAX) = ''

			IF EXISTS (
					SELECT 1
					FROM @tblICItemFactory
					WHERE strRowState = 'Added'
						OR strRowState = 'Deleted'
					)
			BEGIN
				SELECT @strDetails += '{"change":"tblICItemFactories","children":['

				SELECT @strDetails += '{"action":"Created","change":"Created - Record: ' + @strLocationName + '","keyValue":' + ltrim(intItemFactoryId) + ',"iconCls":"small-new-plus","leaf":true},'
				FROM @tblICItemFactory
				WHERE strRowState = 'Added'

				SELECT @strDetails += '{"action":"Deleted","change":"Deleted - Record: ' + @strLocationName + '","keyValue":' + ltrim(intItemFactoryId) + ',"iconCls":"small-new-minus","leaf":true},'
				FROM @tblICItemFactory
				WHERE strRowState = 'Deleted'

				SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

				SELECT @strDetails += '],"iconCls":"small-tree-grid","changeDescription":"Factory Association"},'
			END

			IF (LEN(@strDetails) > 1)
			BEGIN
				SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

				EXEC uspSMAuditLog @keyValue = @intItemId
					,@screenName = 'Inventory.view.Item'
					,@entityId = @intUserId
					,@actionType = 'Updated'
					,@actionIcon = 'small-tree-modified'
					,@details = @strDetails
			END

			SELECT @strDetails = ''

			IF EXISTS (
					SELECT 1
					FROM @tblICItemFactoryManufacturingCell
					WHERE strRowState = 'Added'
						OR strRowState = 'Deleted'
					)
			BEGIN
				SET @strDetails = '{
							"change":"tblICItemFactories",
										"children":[  
											{  
											"action":"Updated",
											"change":"Updated - Record: ' + LTRIM(@strLocationName) + '",
											"keyValue":' + LTRIM(@intItemFactoryId) + ',
											"iconCls":"small-tree-modified",
											"children":
												['

				SELECT @strDetails += '{"change":"tblICItemFactoryManufacturingCells","children":['

				SELECT @strDetails += '{"action":"Created","change":"Created - Record: ' + MC.strCellName + '","keyValue":' + LTRIM(intItemFactoryManufacturingCellId) + ',"iconCls":"small-new-plus","leaf":true},'
				FROM @tblICItemFactoryManufacturingCell FMC
				JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = FMC.intManufacturingCellId
				WHERE strRowState = 'Added'

				SELECT @strDetails += '{"action":"Deleted","change":"Deleted - Record: ' + MC.strCellName + '","keyValue":' + LTRIM(intItemFactoryManufacturingCellId) + ',"iconCls":"small-new-minus","leaf":true},'
				FROM @tblICItemFactoryManufacturingCell FMC
				JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = FMC.intManufacturingCellId
				WHERE strRowState = 'Deleted'

				SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

				SELECT @strDetails += '],"iconCls":"small-tree-grid","changeDescription":"Manufacturing Cell Association"}'

				SET @strDetails += '
											]
										}
									],
									"iconCls":"small-tree-grid",
									"changeDescription":"Factory Association"
									}
								]
							}'

				EXEC uspSMAuditLog @keyValue = @intItemId
					,@screenName = 'Inventory.view.Item'
					,@entityId = @intUserId
					,@actionType = 'Updated'
					,@actionIcon = 'small-tree-modified'
					,@details = @strDetails
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPInitialAck (
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
				,3 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

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

			INSERT INTO tblIPInitialAck (
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
				,3 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

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

		SELECT @intItemRouteStageId = MIN(intItemRouteStageId)
		FROM tblIPItemRouteStage
		WHERE intItemRouteStageId > @intItemRouteStageId
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
