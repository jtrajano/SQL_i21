CREATE PROCEDURE uspIPProcessERPPaymentStatus @strInfo1 NVARCHAR(MAX) = '' OUT
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
		,@strError NVARCHAR(MAX)
	DECLARE @intTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intPaymentStatusStageId INT
		,@strVoucherNo NVARCHAR(50)
		,@strERPVoucherNo NVARCHAR(50)
		,@strERPJournalNo NVARCHAR(50)
		,@intPaymentStatus INT
		,@strERPPaymentReferenceNo NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
		,@intBillId INT
		,@strPaymentStatus NVARCHAR(50)
		,@strComment NVARCHAR(200)
	DECLARE @tblAPBill TABLE (
		strOldComment NVARCHAR(200)
		,strNewComment NVARCHAR(200)
		)
	DECLARE @tblIPPaymentStatusStage TABLE (intPaymentStatusStageId INT)

	INSERT INTO @tblIPPaymentStatusStage (intPaymentStatusStageId)
	SELECT intPaymentStatusStageId
	FROM tblIPPaymentStatusStage
	WHERE intStatusId IS NULL

	SELECT @intPaymentStatusStageId = MIN(intPaymentStatusStageId)
	FROM @tblIPPaymentStatusStage

	IF @intPaymentStatusStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPPaymentStatusStage S
	JOIN @tblIPPaymentStatusStage TS ON TS.intPaymentStatusStageId = S.intPaymentStatusStageId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strVoucherNo, '') + ', '
	FROM @tblIPPaymentStatusStage a
	JOIN tblIPPaymentStatusStage b ON a.intPaymentStatusStageId = b.intPaymentStatusStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strERPJournalNo, '') + ', '
	FROM (
		SELECT DISTINCT b.strERPJournalNo
		FROM @tblIPPaymentStatusStage a
		JOIN tblIPPaymentStatusStage b ON a.intPaymentStatusStageId = b.intPaymentStatusStageId
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intPaymentStatusStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strVoucherNo = NULL
				,@strERPVoucherNo = NULL
				,@strERPJournalNo = NULL
				,@intPaymentStatus = NULL
				,@strERPPaymentReferenceNo = NULL

			SELECT @intCompanyLocationId = NULL
				,@intBillId = NULL
				,@strPaymentStatus = NULL
				,@strComment = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strVoucherNo = strVoucherNo
				,@strERPVoucherNo = strERPVoucherNo
				,@strERPJournalNo = strERPJournalNo
				,@intPaymentStatus = intPaymentStatus
				,@strERPPaymentReferenceNo = strERPPaymentReferenceNo
			FROM tblIPPaymentStatusStage
			WHERE intPaymentStatusStageId = @intPaymentStatusStageId

			IF EXISTS (
					SELECT 1
					FROM tblIPPaymentStatusArchive
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
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			SELECT @intBillId = intBillId
			FROM dbo.tblAPBill WITH (NOLOCK)
			WHERE strBillId = @strVoucherNo

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intBillId IS NULL
			BEGIN
				SELECT @strError = 'Voucher No not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strERPVoucherNo, '') = ''
			BEGIN
				SELECT @strError = 'ERP Voucher No cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strERPJournalNo, '') = ''
			BEGIN
				SELECT @strError = 'ERP Journal No cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intPaymentStatus IS NULL
			BEGIN
				SELECT @strError = 'Payment Status not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intPaymentStatus <> 0
				AND @intPaymentStatus <> 1
			BEGIN
				SELECT @strError = 'Invalid Payment Status.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intPaymentStatus = 0
				SELECT @strPaymentStatus = 'Not Paid'
			ELSE IF @intPaymentStatus = 1
				SELECT @strPaymentStatus = 'Paid'

			BEGIN TRAN

			SELECT @strComment = @strERPVoucherNo + ', ' + @strERPJournalNo + ', ' + @strPaymentStatus

			IF ISNULL(@strERPPaymentReferenceNo, '') <> ''
				SELECT @strComment = @strComment + ', ' + @strERPPaymentReferenceNo

			DELETE
			FROM @tblAPBill

			UPDATE tblAPBill
			SET intConcurrencyId = intConcurrencyId + 1
				,strComment = @strComment
			OUTPUT deleted.strComment
				,inserted.strComment
			INTO @tblAPBill
			WHERE intBillId = @intBillId

			DECLARE @strDetails NVARCHAR(MAX) = ''

			IF EXISTS (
					SELECT 1
					FROM @tblAPBill
					WHERE ISNULL(strOldComment, '') <> ISNULL(strNewComment, '')
					)
				SELECT @strDetails += '{"change":"strComment","iconCls":"small-gear","from":"' + ISNULL(strOldComment, '') + '","to":"' + ISNULL(strNewComment, '') + '","leaf":true,"changeDescription":"Check Comments"},'
				FROM @tblAPBill

			IF (LEN(@strDetails) > 1)
			BEGIN
				SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

				EXEC uspSMAuditLog @keyValue = @intBillId
					,@screenName = 'AccountsPayable.view.Voucher'
					,@entityId = @intUserId
					,@actionType = 'Updated'
					,@actionIcon = 'small-tree-modified'
					,@details = @strDetails
			END

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
				,17
				,1
				,'Success'

			INSERT INTO tblIPPaymentStatusArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strVoucherNo
				,strERPVoucherNo
				,strERPJournalNo
				,intPaymentStatus
				,strERPPaymentReferenceNo
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strVoucherNo
				,strERPVoucherNo
				,strERPJournalNo
				,intPaymentStatus
				,strERPPaymentReferenceNo
			FROM tblIPPaymentStatusStage
			WHERE intPaymentStatusStageId = @intPaymentStatusStageId

			DELETE
			FROM tblIPPaymentStatusStage
			WHERE intPaymentStatusStageId = @intPaymentStatusStageId

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
				,17
				,0
				,@ErrMsg

			INSERT INTO tblIPPaymentStatusError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strVoucherNo
				,strERPVoucherNo
				,strERPJournalNo
				,intPaymentStatus
				,strERPPaymentReferenceNo
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strVoucherNo
				,strERPVoucherNo
				,strERPJournalNo
				,intPaymentStatus
				,strERPPaymentReferenceNo
				,@ErrMsg
			FROM tblIPPaymentStatusStage
			WHERE intPaymentStatusStageId = @intPaymentStatusStageId

			DELETE
			FROM tblIPPaymentStatusStage
			WHERE intPaymentStatusStageId = @intPaymentStatusStageId
		END CATCH

		SELECT @intPaymentStatusStageId = MIN(intPaymentStatusStageId)
		FROM @tblIPPaymentStatusStage
		WHERE intPaymentStatusStageId > @intPaymentStatusStageId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPPaymentStatusStage S
	JOIN @tblIPPaymentStatusStage TS ON TS.intPaymentStatusStageId = S.intPaymentStatusStageId
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
