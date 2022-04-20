CREATE PROCEDURE uspIPProcessERPCommitmentPricingBalQty @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@strError NVARCHAR(MAX)
	DECLARE @intTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(6)
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intCommitmentPricingBalQtyStageId INT
		,@strPricingNo NVARCHAR(50)
		,@strERPRefNo NVARCHAR(100)
		,@dblBalanceQty NUMERIC(18, 6)
		,@intLineTrxSequenceNo BIGINT
	DECLARE @intCommitmentPricingId INT
		,@intNewCommitmentPricingBalQtyStageId INT
	DECLARE @tblMFCommitmentPricing TABLE (
		dblOldBalanceQty NUMERIC(18, 6)
		,dblNewBalanceQty NUMERIC(18, 6)
		)
	DECLARE @tblIPCommitmentPricingBalQtyStage TABLE (intCommitmentPricingBalQtyStageId INT)

	INSERT INTO @tblIPCommitmentPricingBalQtyStage (intCommitmentPricingBalQtyStageId)
	SELECT intCommitmentPricingBalQtyStageId
	FROM tblIPCommitmentPricingBalQtyStage
	WHERE intStatusId IS NULL

	SELECT @intCommitmentPricingBalQtyStageId = MIN(intCommitmentPricingBalQtyStageId)
	FROM @tblIPCommitmentPricingBalQtyStage

	IF @intCommitmentPricingBalQtyStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPCommitmentPricingBalQtyStage S
	JOIN @tblIPCommitmentPricingBalQtyStage TS ON TS.intCommitmentPricingBalQtyStageId = S.intCommitmentPricingBalQtyStageId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strPricingNo, '') + ', '
	FROM @tblIPCommitmentPricingBalQtyStage a
	JOIN tblIPCommitmentPricingBalQtyStage b ON a.intCommitmentPricingBalQtyStageId = b.intCommitmentPricingBalQtyStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(b.strERPRefNo, '') + ', '
	FROM @tblIPCommitmentPricingBalQtyStage a
	JOIN tblIPCommitmentPricingBalQtyStage b ON a.intCommitmentPricingBalQtyStageId = b.intCommitmentPricingBalQtyStageId

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intCommitmentPricingBalQtyStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strPricingNo = NULL
				,@strERPRefNo = NULL
				,@dblBalanceQty = NULL
				,@intLineTrxSequenceNo = NULL

			SELECT @intCommitmentPricingId = NULL
				,@intNewCommitmentPricingBalQtyStageId = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strPricingNo = strPricingNo
				,@strERPRefNo = strERPRefNo
				,@dblBalanceQty = dblBalanceQty
				,@intLineTrxSequenceNo = intLineTrxSequenceNo
			FROM tblIPCommitmentPricingBalQtyStage
			WHERE intCommitmentPricingBalQtyStageId = @intCommitmentPricingBalQtyStageId

			IF EXISTS (
					SELECT 1
					FROM tblIPCommitmentPricingBalQtyArchive
					WHERE intLineTrxSequenceNo = @intLineTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'Line TrxSequenceNo ' + LTRIM(@intLineTrxSequenceNo) + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCommitmentPricingId = intCommitmentPricingId
			FROM dbo.tblMFCommitmentPricing WITH (NOLOCK)
			WHERE strPricingNumber = @strPricingNo
				AND strERPNo = @strERPRefNo

			IF @intCommitmentPricingId IS NULL
			BEGIN
				SELECT @strError = 'Pricing No. not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @dblBalanceQty IS NULL
			BEGIN
				SELECT @strError = 'Balance Qty not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			DELETE
			FROM @tblMFCommitmentPricing

			UPDATE CP
			SET intConcurrencyId = CP.intConcurrencyId + 1
				,dblBalanceQty = @dblBalanceQty
			OUTPUT deleted.dblBalanceQty
				,inserted.dblBalanceQty
			INTO @tblMFCommitmentPricing
			FROM tblMFCommitmentPricing CP
			WHERE CP.intCommitmentPricingId = @intCommitmentPricingId

			DECLARE @strDetails NVARCHAR(MAX) = ''

			IF EXISTS (
					SELECT 1
					FROM @tblMFCommitmentPricing
					WHERE ISNULL(dblOldBalanceQty, 0) <> ISNULL(dblNewBalanceQty, 0)
					)
				SELECT @strDetails += '{"change":"dblBalanceQty","from":"' + LTRIM(ISNULL(dblOldBalanceQty, 0)) + '","to":"' + LTRIM(ISNULL(dblNewBalanceQty, 0)) + '","leaf":true,"iconCls":"small-gear","changeDescription":"Balance Qty"},'
				FROM @tblMFCommitmentPricing

			IF (LEN(@strDetails) > 1)
			BEGIN
				SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

				EXEC uspSMAuditLog @keyValue = @intCommitmentPricingId
					,@screenName = 'Manufacturing.view.CommitmentPricing'
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
				,18 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

			INSERT INTO tblIPCommitmentPricingBalQtyArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intLineTrxSequenceNo
				,strPricingNo
				,strERPRefNo
				,dblBalanceQty
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intLineTrxSequenceNo
				,strPricingNo
				,strERPRefNo
				,dblBalanceQty
			FROM tblIPCommitmentPricingBalQtyStage
			WHERE intCommitmentPricingBalQtyStageId = @intCommitmentPricingBalQtyStageId

			SELECT @intNewCommitmentPricingBalQtyStageId = SCOPE_IDENTITY()

			DELETE
			FROM tblIPCommitmentPricingBalQtyStage
			WHERE intCommitmentPricingBalQtyStageId = @intCommitmentPricingBalQtyStageId

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
				,18 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

			INSERT INTO tblIPCommitmentPricingBalQtyError (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intLineTrxSequenceNo
				,strPricingNo
				,strERPRefNo
				,dblBalanceQty
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intLineTrxSequenceNo
				,strPricingNo
				,strERPRefNo
				,dblBalanceQty
				,@ErrMsg
			FROM tblIPCommitmentPricingBalQtyStage
			WHERE intCommitmentPricingBalQtyStageId = @intCommitmentPricingBalQtyStageId

			SELECT @intNewCommitmentPricingBalQtyStageId = SCOPE_IDENTITY()

			DELETE
			FROM tblIPCommitmentPricingBalQtyStage
			WHERE intCommitmentPricingBalQtyStageId = @intCommitmentPricingBalQtyStageId
		END CATCH

		SELECT @intCommitmentPricingBalQtyStageId = MIN(intCommitmentPricingBalQtyStageId)
		FROM @tblIPCommitmentPricingBalQtyStage
		WHERE intCommitmentPricingBalQtyStageId > @intCommitmentPricingBalQtyStageId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPCommitmentPricingBalQtyStage S
	JOIN @tblIPCommitmentPricingBalQtyStage TS ON TS.intCommitmentPricingBalQtyStageId = S.intCommitmentPricingBalQtyStageId
	WHERE S.intStatusId = - 1

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
