CREATE PROCEDURE uspIPProcessPBBSDetail_EK @strInfo1 NVARCHAR(MAX) = '' OUT
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
		,@intActionId INT
		,@dtmCreatedDate DATETIME
	DECLARE @intPBBSStageId INT
		,@strStatus NVARCHAR(50)
		,@strAccountNo NVARCHAR(50)
		,@strName NVARCHAR(100)
		,@strTerm NVARCHAR(50)
		,@strEntityType NVARCHAR(50)
		,@strCurrency NVARCHAR(50)
		,@strDefaultLocation NVARCHAR(100)
		,@strDefaultContactName NVARCHAR(100)
	DECLARE @intEntityId INT
		,@ysnActive BIT
		,@intTermsId INT
		,@intCurrencyId INT
		,@intDefaultLocationId INT
		,@intDefaultContactId INT
		,@intNewPBBSStageId INT
		,@strEntityNo NVARCHAR(50)
	DECLARE @intPBBSDetailStageId INT
		,@strDetailLineType NVARCHAR(50)
		,@strDetailLocation NVARCHAR(200)
		,@strDetailAddress NVARCHAR(MAX)
		,@strDetailCity NVARCHAR(100)
		,@strDetailState NVARCHAR(100)
		,@strDetailZip NVARCHAR(100)
		,@strDetailCountry NVARCHAR(100)
		,@strDetailTerm NVARCHAR(100)
		,@strDetailContactName NVARCHAR(100)
	DECLARE @intDetailCountryId INT
		,@intDetailTermId INT
	DECLARE @tblIPPBBSStage TABLE (intPBBSStageId INT)

	INSERT INTO @tblIPPBBSStage (intPBBSStageId)
	SELECT intPBBSStageId
	FROM tblIPPBBSStage
	--WHERE intStatusId IS NULL
	WHERE intStatusId = 11

	SELECT @intPBBSStageId = MIN(intPBBSStageId)
	FROM @tblIPPBBSStage

	IF @intPBBSStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPPBBSStage S
	JOIN @tblIPPBBSStage TS ON TS.intPBBSStageId = S.intPBBSStageId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strBlendCode, '') + ', '
	FROM @tblIPPBBSStage a
	JOIN tblIPPBBSStage b ON a.intPBBSStageId = b.intPBBSStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(LTRIM(b.intPBBSID), '') + ', '
	FROM @tblIPPBBSStage a
	JOIN tblIPPBBSStage b ON a.intPBBSStageId = b.intPBBSStageId

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intPBBSStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL

			SELECT @strStatus = NULL
				,@strAccountNo = NULL
				,@strName = NULL
				,@strTerm = NULL
				,@strEntityType = NULL
				,@strCurrency = NULL
				,@strDefaultLocation = NULL
				,@strDefaultContactName = NULL

			SELECT @intEntityId = NULL
				,@ysnActive = NULL
				,@intTermsId = NULL
				,@intCurrencyId = NULL
				,@intDefaultLocationId = NULL
				,@intDefaultContactId = NULL
				,@intNewPBBSStageId = NULL
				,@strEntityNo = NULL
				,@intPBBSDetailStageId = NULL

			SELECT @intTrxSequenceNo = intDocNo
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId

			SELECT @intEntityId = intEntityId
			FROM dbo.tblAPVendor WITH (NOLOCK)
			WHERE strVendorAccountNum = @strAccountNo

			SELECT @intTermsId = intTermID
			FROM dbo.tblSMTerm WITH (NOLOCK)
			WHERE strTermCode = @strTerm

			IF ISNULL(@strStatus, '') NOT IN (
					'Active'
					,'In-active'
					)
			BEGIN
				SELECT @strError = 'Status not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @strStatus = 'Active'
				SELECT @ysnActive = 1
			ELSE
				SELECT @ysnActive = 0

			IF ISNULL(@strAccountNo, '') = ''
			BEGIN
				SELECT @strError = 'Vendor Account No cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intTermsId IS NULL
			BEGIN
				SELECT @strError = 'Terms Code not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF EXISTS (
					SELECT 1
					FROM tblAPVendor V
					WHERE V.strVendorAccountNum = @strAccountNo
					)
				SELECT @intActionId = 2 --Update
			ELSE
				SELECT @intActionId = 1 --Create

			IF @intActionId = 1
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblAPVendor V
						WHERE V.strVendorAccountNum = @strAccountNo
						)
				BEGIN
					SELECT @strError = 'Vendor Account No ''' + @strAccountNo + ''' already exists.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END
			END
			ELSE
			BEGIN
				IF @intEntityId IS NULL
				BEGIN
					SELECT @strError = 'Vendor not found.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblIPPBBSDetailStage
					WHERE intPBBSStageId = @intPBBSStageId
					)
			BEGIN
				SELECT @strError = 'Line - Location is required.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			-- Entity Location and Term validation
			SELECT @intPBBSDetailStageId = MIN(intPBBSDetailStageId)
			FROM tblIPPBBSDetailStage
			WHERE intPBBSStageId = @intPBBSStageId

			WHILE (@intPBBSDetailStageId IS NOT NULL)
			BEGIN
				SELECT @strDetailLineType = NULL
					,@strDetailLocation = NULL
					,@strDetailAddress = NULL
					,@strDetailCity = NULL
					,@strDetailState = NULL
					,@strDetailZip = NULL
					,@strDetailCountry = NULL
					,@strDetailTerm = NULL
					,@strDetailContactName = NULL

				SELECT @intDetailCountryId = NULL
					,@intDetailTermId = NULL

				SELECT @strDetailLineType = strBlendCode
				FROM tblIPPBBSDetailStage
				WHERE intPBBSDetailStageId = @intPBBSDetailStageId

				IF @strDetailLineType = 'L'
				BEGIN
					IF ISNULL(@strDetailLocation, '') = ''
					BEGIN
						SELECT @strError = 'Detail - Location Name cannot be blank.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END

					SELECT @intDetailCountryId = intCountryID
					FROM dbo.tblSMCountry WITH (NOLOCK)
					WHERE strCountry = @strDetailCountry

					IF @intDetailCountryId IS NULL
					BEGIN
						SELECT @strError = 'Detail - Country is invalid.'

						RAISERROR (
								@strError
								,16
								,1
								)
					END
				END

				SELECT @intPBBSDetailStageId = MIN(intPBBSDetailStageId)
				FROM tblIPPBBSDetailStage
				WHERE intPBBSDetailStageId > @intPBBSDetailStageId
					AND intPBBSStageId = @intPBBSStageId
			END

			BEGIN TRAN

			IF @intActionId = 1
			BEGIN
				SELECT 'Insert'
			END
			ELSE IF @intActionId = 2
			BEGIN
				SELECT 'Update'
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPPBBSArchive (
				intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				,dtmTransactionDate
				,strErrorMessage
				)
			SELECT intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				,dtmTransactionDate
				,''
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId

			SELECT @intNewPBBSStageId = SCOPE_IDENTITY()

			INSERT INTO tblIPPBBSDetailArchive (
				intPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
				)
			SELECT @intNewPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
			FROM tblIPPBBSDetailStage
			WHERE intPBBSStageId = @intPBBSStageId

			DELETE
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPPBBSError (
				intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				,dtmTransactionDate
				,strErrorMessage
				)
			SELECT intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				,dtmTransactionDate
				,@ErrMsg
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId

			SELECT @intNewPBBSStageId = SCOPE_IDENTITY()

			INSERT INTO tblIPPBBSDetailError (
				intPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
				)
			SELECT @intNewPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
			FROM tblIPPBBSDetailStage
			WHERE intPBBSStageId = @intPBBSStageId

			DELETE
			FROM tblIPPBBSStage
			WHERE intPBBSStageId = @intPBBSStageId
		END CATCH

		SELECT @intPBBSStageId = MIN(intPBBSStageId)
		FROM @tblIPPBBSStage
		WHERE intPBBSStageId > @intPBBSStageId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPPBBSStage S
	JOIN @tblIPPBBSStage TS ON TS.intPBBSStageId = S.intPBBSStageId
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
