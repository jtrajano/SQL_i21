CREATE PROCEDURE [dbo].[uspIPProcessERPBlendDemand] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @intBendDemandStageId INT
	DECLARE @strQuantityUOM NVARCHAR(50)
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @intUserId INT
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@intCompanyLocationSubLocationId INT
		,@strError NVARCHAR(MAX)
		,@intTrxSequenceNo BIGINT
		,@strItemNo NVARCHAR(50)
		,@intItemId INT
		,@intUnitMeasureId INT
		,@strOrderNo NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strWorkCenter NVARCHAR(50)
		,@dtmDueDate DATETIME
		,@strMachine NVARCHAR(50)
		,@intManufacturingCellId INT
		,@intLocationId INT
		,@intMachineId INT
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
		,@strStorageLocation NVARCHAR(50)
		,@strDemandType NVARCHAR(50)
		,@intCounter INT = 1

	SELECT @intBendDemandStageId = MIN(intBendDemandStageId)
	FROM tblIPBendDemandStage

	SELECT @strInfo1 = ''

	SELECT @strInfo2 = ''

	WHILE @intBendDemandStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @strCompanyLocation = NULL
				,@strStorageLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL
				,@strOrderNo = NULL
				,@strItemNo = NULL
				,@dblQuantity = NULL
				,@strQuantityUOM = NULL
				,@strWorkCenter = NULL
				,@dtmDueDate = NULL
				,@strMachine = NULL
				,@strDemandType = NULL

			SELECT @strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strStorageLocation = strStorageLocation
				,@strOrderNo = strOrderNo
				,@strItemNo = strItem
				,@dblQuantity = dblQuantity
				,@strQuantityUOM = strQuantityUOM
				,@strWorkCenter = strWorkCenter
				,@dtmDueDate = dtmDueDate
				,@strMachine = strMachine
				,@strDemandType = strDemandType
				,@intTrxSequenceNo = intTrxSequenceNo
			FROM dbo.tblIPBendDemandStage
			WHERE intBendDemandStageId = @intBendDemandStageId

			IF EXISTS (
					SELECT 1
					FROM dbo.tblIPBendDemandArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + ltrim(@intTrxSequenceNo) + ' is already processed in i21.'

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

			SELECT @intLocationId = NULL

			SELECT @intLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			SELECT @intCompanyLocationSubLocationId = NULL

			SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
			FROM dbo.tblSMCompanyLocationSubLocation
			WHERE strSubLocationName = @strStorageLocation
				AND intCompanyLocationId = @intLocationId

			IF @intCompanyLocationSubLocationId IS NULL
			BEGIN
				SELECT @strError = 'Storage Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

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

			IF @strWorkCenter = ''
			BEGIN
				SELECT @strError = 'Manufacturing Cell ' + @strWorkCenter + ' cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intManufacturingCellId = NULL

			SELECT @intManufacturingCellId = intManufacturingCellId
			FROM dbo.tblMFManufacturingCell
			WHERE strCellName = @strWorkCenter
				AND intSubLocationId = @intCompanyLocationSubLocationId
				AND intLocationId = @intLocationId

			IF @intManufacturingCellId IS NULL
			BEGIN
				--SELECT @strError = 'Manufacturing Cell ' + @strWorkCenter + ' is not availble in i21.'
				--RAISERROR (
				--		@strError
				--		,16
				--		,1
				--		)
				INSERT INTO tblMFManufacturingCell (
					strCellName
					,strDescription
					,intSubLocationId
					,intLocationId
					)
				SELECT @strWorkCenter
					,@strWorkCenter
					,@intCompanyLocationSubLocationId
					,@intLocationId

				SELECT @intManufacturingCellId = SCOPE_IDENTITY()
			END

			IF @strMachine = ''
			BEGIN
				SELECT @strError = 'Machine ' + @strMachine + ' cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intMachineId = NULL

			SELECT @intMachineId = intMachineId
			FROM dbo.tblMFMachine M
			WHERE strName = @strMachine
				AND intSubLocationId = @intCompanyLocationSubLocationId
				AND intLocationId = @intLocationId

			IF @intMachineId IS NULL
			BEGIN
				--SELECT @strError = 'Machine ' + @strMachine + ' is not availble in i21.'
				--RAISERROR (
				--		@strError
				--		,16
				--		,1
				--		)
				INSERT INTO tblMFMachine (
					strName
					,strDescription
					,intSubLocationId
					,intLocationId
					)
				SELECT @strMachine
					,@strMachine
					,@intCompanyLocationSubLocationId
					,@intLocationId

				SELECT @intMachineId = SCOPE_IDENTITY()
			END

			BEGIN TRAN

			IF @intCounter = 1
			BEGIN
				DELETE
				FROM dbo.tblMFBlendDemand
				WHERE intLocationId = @intLocationId

				SELECT @intCounter = @intCounter + 1
			END

			INSERT INTO dbo.tblMFBlendDemand (
				strDemandNo
				,intLocationId
				,intItemId
				,dblQuantity
				,intManufacturingCellId
				,intMachineId
				,dtmDueDate
				,intStatusId
				,intOrderId
				,strOrderNo
				,strOrderType
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				,intConcurrencyId
				,intCompanyId
				)
			SELECT @strOrderNo AS strDemandNo
				,@intLocationId
				,@intItemId
				,@dblQuantity
				,@intManufacturingCellId
				,@intMachineId
				,@dtmDueDate
				,1 intStatusId
				,NULL intOrderId
				,@strOrderNo
				,@strDemandType
				,@intUserId
				,@dtmCreatedDate
				,@intUserId
				,@dtmCreatedDate
				,1 AS intConcurrencyId
				,NULL AS intCompanyId

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
				,10 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

			--Move to Archive
			INSERT INTO dbo.tblIPBendDemandArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strStorageLocation
				,strDemandType
				,strOrderNo
				,strItem
				,dblQuantity
				,strQuantityUOM
				,strWorkCenter
				,dtmDueDate
				,strMachine
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strStorageLocation
				,strDemandType
				,strOrderNo
				,strItem
				,dblQuantity
				,strQuantityUOM
				,strWorkCenter
				,dtmDueDate
				,strMachine
			FROM dbo.tblIPBendDemandStage
			WHERE intBendDemandStageId = @intBendDemandStageId

			DELETE
			FROM dbo.tblIPBendDemandStage
			WHERE intBendDemandStageId = @intBendDemandStageId

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
				,10 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

			--Move to Error
			INSERT INTO dbo.tblIPBendDemandError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strStorageLocation
				,strDemandType
				,strOrderNo
				,strItem
				,dblQuantity
				,strQuantityUOM
				,strWorkCenter
				,dtmDueDate
				,strMachine
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strStorageLocation
				,strDemandType
				,strOrderNo
				,strItem
				,dblQuantity
				,strQuantityUOM
				,strWorkCenter
				,dtmDueDate
				,strMachine
				,@ErrMsg
			FROM dbo.tblIPBendDemandStage
			WHERE intBendDemandStageId = @intBendDemandStageId

			DELETE
			FROM dbo.tblIPBendDemandStage
			WHERE intBendDemandStageId = @intBendDemandStageId
		END CATCH

		SELECT @intBendDemandStageId = MIN(intBendDemandStageId)
		FROM dbo.tblIPBendDemandStage
		WHERE intBendDemandStageId > @intBendDemandStageId
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
