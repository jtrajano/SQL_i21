CREATE PROCEDURE [dbo].[uspIPProcessERPProductionOrder] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @intProductionOrderStageId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @intUserId INT
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@strError NVARCHAR(MAX)
		,@dtmCreatedDate DATETIME
		,@intLocationId INT
		,@intItemId INT
		,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@strOrderNo NVARCHAR(50)
		,@strBatchId NVARCHAR(50)
		,@dblNoOfPack NUMERIC(18, 6)
		,@strNoOfPackUOM NVARCHAR(50)
		,@dblWeight NUMERIC(18, 6)
		,@strWeightUOM NVARCHAR(50)
		,@intDocNo BIGINT
		,@intWorkOrderId INT
		,@strLocationNumber NVARCHAR(50)
		,@intPackItemUOMId INT
		,@intPackUnitMeasureId INT
		,@strCreatedBy NVARCHAR(50)
	DECLARE @tblMFProductionOrderStage TABLE (intProductionOrderStageId INT)

	INSERT INTO @tblMFProductionOrderStage (intProductionOrderStageId)
	SELECT intProductionOrderStageId
	FROM tblMFProductionOrderStage
	WHERE intStatusId IS NULL

	SELECT @intProductionOrderStageId = MIN(intProductionOrderStageId)
	FROM @tblMFProductionOrderStage

	IF @intProductionOrderStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblMFProductionOrderStage
	SET intStatusId = - 1
	WHERE intProductionOrderStageId IN (
			SELECT DS.intProductionOrderStageId
			FROM @tblMFProductionOrderStage DS
			)

	SELECT @strInfo1 = ''

	SELECT @strInfo2 = ''

	WHILE @intProductionOrderStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @strOrderNo = NULL
				,@strBatchId = NULL
				,@dblNoOfPack = NULL
				,@strNoOfPackUOM = NULL
				,@dblWeight = NULL
				,@strWeightUOM = NULL
				,@intDocNo = NULL
				,@strLocationNumber = NULL

			SELECT @strOrderNo = strOrderNo
				,@strLocationNumber = strLocationCode
				,@strBatchId = strBatchId
				,@dblNoOfPack = dblNoOfPack
				,@strNoOfPackUOM = strNoOfPackUOM
				,@dblWeight = dblWeight
				,@strWeightUOM = strWeightUOM
				,@intDocNo = intDocNo
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId

			IF EXISTS (
					SELECT 1
					FROM dbo.tblMFProductionOrderArchive
					WHERE intDocNo = @intDocNo
					)
			BEGIN
				SELECT @strError = 'Document number ' + ltrim(@intDocNo) + ' is already processed in i21.'

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
			WHERE strLocationNumber = @strLocationNumber

			IF @intLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblMFWorkOrder
					WHERE strERPOrderNo = @strOrderNo
					)
			BEGIN
				SELECT @strError = 'Production Order ' + @strOrderNo + ' is not available in i21'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intWorkOrderId = NULL

			SELECT @intWorkOrderId = intWorkOrderId
			FROM dbo.tblMFWorkOrder
			WHERE strWorkOrderNo = @strOrderNo

			IF NOT EXISTS (
					SELECT *
					FROM tblICLot
					WHERE strLotNumber = @strBatchId
					)
			BEGIN
				SELECT @strError = 'Batch No ' + @strBatchId + ' is not availble in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END
				 SELECT @intItemId = NULL
				
			SELECT @intItemId = intItemId
			FROM tblICLot
			WHERE strLotNumber = @strBatchId
				AND intLocationId = @intLocationId

			IF @strWeightUOM  = ''
			BEGIN
				SELECT @strError = 'Weight UOM ' + @strWeightUOM + ' cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intUnitMeasureId = NULL

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM dbo.tblICUnitMeasure
			WHERE strUnitMeasure = @strWeightUOM

			IF @intUnitMeasureId IS NULL
			BEGIN
				SELECT @strError = 'Weight UOM ' + @strWeightUOM + ' is not availble in i21.'

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
				SELECT @strError = 'UOM ' + @strWeightUOM + ' is not configured in the item level in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strNoOfPackUOM = ''
			BEGIN
				SELECT @strError = 'Pack UOM ' + @strNoOfPackUOM + ' cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intPackUnitMeasureId = NULL

			SELECT @intPackUnitMeasureId = intUnitMeasureId
			FROM dbo.tblICUnitMeasure
			WHERE strUnitMeasure = @strNoOfPackUOM

			IF @intPackUnitMeasureId IS NULL
			BEGIN
				SELECT @strError = 'Pack UOM ' + @strNoOfPackUOM + ' is not availble in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intPackItemUOMId = NULL

			SELECT @intPackItemUOMId = intItemUOMId
			FROM tblICItemUOM IU
			WHERE intItemId = @intItemId
				AND intUnitMeasureId = @intPackUnitMeasureId

			IF @intPackItemUOMId IS NULL
			BEGIN
				SELECT @strError = 'UOM ' + @strNoOfPackUOM + ' is not configured in the item level in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			INSERT INTO tblMFWorkOrderInputLot (
				intWorkOrderId
				,intItemId
				,dblQuantity
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,intConcurrencyId
				)
			SELECT @intWorkOrderId
				,@intItemId
				,@dblWeight
				,@intItemUOMId
				,@dblNoOfPack
				,@intPackItemUOMId
				,1

			MOVE_TO_ARCHIVE:

			--Move to Archive
			INSERT INTO dbo.tblMFProductionOrderArchive (
				intDocNo
				,strOrderNo
				,strLocationCode
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,dtmFeedDate
				)
			SELECT intDocNo
				,strOrderNo
				,strLocationCode
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,dtmFeedDate
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId

			DELETE
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO dbo.tblMFProductionOrderError (
				intDocNo
				,strOrderNo
				,strLocationCode
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,dtmFeedDate
				)
			SELECT intDocNo
				,strOrderNo
				,strLocationCode
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,dtmFeedDate
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId

			DELETE
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId
		END CATCH

		SELECT @intProductionOrderStageId = MIN(intProductionOrderStageId)
		FROM @tblMFProductionOrderStage
		WHERE intProductionOrderStageId > @intProductionOrderStageId
	END

	UPDATE tblMFProductionOrderStage
	SET intStatusId = NULL
	WHERE intProductionOrderStageId IN (
			SELECT PS.intProductionOrderStageId
			FROM @tblMFProductionOrderStage PS
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
