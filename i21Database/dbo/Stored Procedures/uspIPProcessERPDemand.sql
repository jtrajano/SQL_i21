CREATE PROCEDURE [dbo].[uspIPProcessERPDemand] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @intDemandStageId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @intUserId INT
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@strError NVARCHAR(MAX)
		,@intTrxSequenceNo BIGINT
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@strDemandName NVARCHAR(50)
		,@intLineTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strQuantityUOM NVARCHAR(50)
		,@dtmDemandDate DATETIME
		,@intLocationId INT
		,@intItemId INT
		,@intUnitMeasureId INT
		,@strDemandNo NVARCHAR(50)
		,@intItemUOMId INT
		,@intDemandHeaderId INT
		,@intCounter INT = 1
	DECLARE @tblIPDemandStage TABLE (intDemandStageId INT)

	INSERT INTO @tblIPDemandStage (intDemandStageId)
	SELECT intDemandStageId
	FROM tblIPDemandStage
	WHERE intStatusId IS NULL

	SELECT @intDemandStageId = MIN(intDemandStageId)
	FROM @tblIPDemandStage

	IF @intDemandStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblIPDemandStage
	SET intStatusId = - 1
	WHERE intDemandStageId IN (
			SELECT DS.intDemandStageId
			FROM @tblIPDemandStage DS
			)

	SELECT @strInfo1 = ''

	SELECT @strInfo2 = ''

	WHILE @intDemandStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL
				,@strDemandName = NULL
				,@intLineTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@strItemNo = NULL
				,@dblQuantity = NULL
				,@strQuantityUOM = NULL
				,@dtmDemandDate = NULL
				,@intLocationId = NULL
				,@intUnitMeasureId = NULL
				,@strDemandNo = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strDemandName = strDemandName
				,@intLineTrxSequenceNo = intLineTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@strItemNo = strItemNo
				,@dblQuantity = dblQuantity
				,@strQuantityUOM = strQuantityUOM
				,@dtmDemandDate = dtmDemandDate
			FROM dbo.tblIPDemandStage
			WHERE intDemandStageId = @intDemandStageId

			IF EXISTS (
					SELECT 1
					FROM dbo.tblIPDemandArchive
					WHERE intLineTrxSequenceNo = @intLineTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'Line TrxSequenceNo ' + ltrim(@intLineTrxSequenceNo) + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intUserId = NULL

			SELECT @intUserId = intEntityId
			FROM dbo.tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = @strCreatedBy

			IF @intUserId IS NULL
				SELECT @intUserId = intEntityId
				FROM dbo.tblSMUserSecurity WITH (NOLOCK)
				WHERE strUserName = 'IRELYADMIN'

			SELECT @intLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			IF @intLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strItemNo = ''
			BEGIN
				SELECT @strError = 'Item cannot be empty.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intItemId = NULL

			SELECT @intItemId = intItemId
			FROM dbo.tblICItem
			WHERE strItemNo = @strItemNo

			IF @intItemId IS NULL
			BEGIN
				SELECT @strError = 'Item ' + @strItemNo + ' is not availble in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strQuantityUOM = ''
			BEGIN
				SELECT @strError = 'Quantity UOM ' + @strQuantityUOM + ' cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intUnitMeasureId = NULL

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM dbo.tblICUnitMeasure
			WHERE strUnitMeasure = @strQuantityUOM

			IF @intUnitMeasureId IS NULL
			BEGIN
				SELECT @strError = 'Quantity UOM ' + @strQuantityUOM + ' is not availble in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intItemUOMId = NULL

			SELECT @intItemUOMId = intItemUOMId
			FROM tblICItemUOM IU
			WHERE intItemId = @intItemId
				AND intUnitMeasureId = @intUnitMeasureId

			IF @intItemUOMId IS NULL
			BEGIN
				SELECT @strError = 'UOM ' + @strQuantityUOM + ' is not configured in the item level in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			IF NOT EXISTS (
					SELECT *
					FROM tblMFDemandHeader
					WHERE strDemandName = @strDemandName
					)
			BEGIN
				EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
					,@intItemId = NULL
					,@intManufacturingId = NULL
					,@intSubLocationId = NULL
					,@intLocationId = @intLocationId
					,@intOrderTypeId = 8
					,@intBlendRequirementId = NULL
					,@intPatternCode = 145
					,@ysnProposed = 0
					,@strPatternString = @strDemandNo OUTPUT

				INSERT INTO dbo.tblMFDemandHeader (
					intConcurrencyId
					,strDemandNo
					,strDemandName
					,dtmDate
					,intBookId
					,intSubBookId
					,ysnImported
					)
				SELECT 1 AS intConcurrencyId
					,@strDemandNo
					,@strDemandName
					,@dtmCreatedDate AS dtmDate
					,NULL AS intBookId
					,NULL AS intSubBookId
					,1 AS ysnImported

				SELECT @intDemandHeaderId = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				SELECT @intDemandHeaderId = intDemandHeaderId
				FROM dbo.tblMFDemandHeader
				WHERE strDemandName = @strDemandName
			END

			IF @intCounter = 1
			BEGIN
				DELETE
				FROM dbo.tblMFDemandDetail
				WHERE intDemandHeaderId = @intDemandHeaderId
					AND intCompanyLocationId = @intLocationId

				SELECT @intCounter = @intCounter + 1
			END

			INSERT INTO dbo.tblMFDemandDetail (
				intConcurrencyId
				,intDemandHeaderId
				,intItemId
				,intSubstituteItemId
				,dtmDemandDate
				,dblQuantity
				,intItemUOMId
				,intCompanyLocationId
				,dtmCreated
				,ysnPopulatedBySystem
				)
			SELECT 1 AS intConcurrencyId
				,@intDemandHeaderId
				,@intItemId
				,NULL AS intSubstituteItemId
				,@dtmDemandDate
				,@dblQuantity
				,@intItemUOMId
				,@intLocationId
				,@dtmCreatedDate
				,0 AS ysnPopulatedBySystem

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
				,9 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

			--Move to Archive
			INSERT INTO dbo.tblIPDemandArchive (
				intTrxSequenceNo
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strDemandName
				,intLineTrxSequenceNo
				,strCompanyLocation
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dtmDemandDate
				)
			SELECT intTrxSequenceNo
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strDemandName
				,intLineTrxSequenceNo
				,strCompanyLocation
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dtmDemandDate
			FROM dbo.tblIPDemandStage
			WHERE intDemandStageId = @intDemandStageId

			DELETE
			FROM dbo.tblIPDemandStage
			WHERE intDemandStageId = @intDemandStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
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
				,9 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

			INSERT INTO dbo.tblIPDemandError (
				intTrxSequenceNo
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strDemandName
				,intLineTrxSequenceNo
				,strCompanyLocation
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dtmDemandDate
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strDemandName
				,intLineTrxSequenceNo
				,strCompanyLocation
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dtmDemandDate
				,@ErrMsg
			FROM dbo.tblIPDemandStage
			WHERE intDemandStageId = @intDemandStageId

			DELETE
			FROM dbo.tblIPDemandStage
			WHERE intDemandStageId = @intDemandStageId
		END CATCH

		SELECT @intDemandStageId = MIN(intDemandStageId)
		FROM @tblIPDemandStage
		WHERE intDemandStageId > @intDemandStageId
	END

	UPDATE tblIPDemandStage
	SET intStatusId = NULL
	WHERE intDemandStageId IN (
			SELECT PS.intDemandStageId
			FROM @tblIPDemandStage PS
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
