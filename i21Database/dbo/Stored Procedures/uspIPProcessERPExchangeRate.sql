CREATE PROCEDURE uspIPProcessERPExchangeRate @strInfo1 NVARCHAR(MAX) = '' OUT
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
	DECLARE @intCurrencyRateStageId INT
		,@strFromCurrency NVARCHAR(50)
		,@strToCurrency NVARCHAR(50)
		,@dblRate NUMERIC(18, 6)
		,@strRateType NVARCHAR(50)
		,@dtmEffectiveDate DATETIME
	DECLARE @intCompanyLocationId INT
		,@intFromCurrencyID INT
		,@intToCurrencyID INT
		,@intRateTypeId INT
		,@intCurrencyExchangeRateId INT
		,@intCurrencyExchangeRateDetailId INT
		,@intNewCurrencyRateStageId INT
	DECLARE @tblSMCurrencyExchangeRateDetail TABLE (
		intCurrencyExchangeRateDetailId INT
		,intRateTypeId INT
		,dblOldRate NUMERIC(18, 6)
		,dblNewRate NUMERIC(18, 6)
		)
	DECLARE @dblOldRate NUMERIC(18, 6)
		,@dblNewRate NUMERIC(18, 6)
	DECLARE @tblIPCurrencyRateStage TABLE (intCurrencyRateStageId INT)

	INSERT INTO @tblIPCurrencyRateStage (intCurrencyRateStageId)
	SELECT intCurrencyRateStageId
	FROM tblIPCurrencyRateStage
	WHERE intStatusId IS NULL

	SELECT @intCurrencyRateStageId = MIN(intCurrencyRateStageId)
	FROM @tblIPCurrencyRateStage

	IF @intCurrencyRateStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPCurrencyRateStage S
	JOIN @tblIPCurrencyRateStage TS ON TS.intCurrencyRateStageId = S.intCurrencyRateStageId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strFromCurrency, '') + ', '
	FROM @tblIPCurrencyRateStage a
	JOIN tblIPCurrencyRateStage b ON a.intCurrencyRateStageId = b.intCurrencyRateStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strRateType, '') + ', '
	FROM (
		SELECT DISTINCT b.strRateType
		FROM @tblIPCurrencyRateStage a
		JOIN tblIPCurrencyRateStage b ON a.intCurrencyRateStageId = b.intCurrencyRateStageId
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intCurrencyRateStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strFromCurrency = NULL
				,@strToCurrency = NULL
				,@dblRate = NULL
				,@strRateType = NULL
				,@dtmEffectiveDate = NULL

			SELECT @intCompanyLocationId = NULL
				,@intFromCurrencyID = NULL
				,@intToCurrencyID = NULL
				,@intRateTypeId = NULL
				,@intCurrencyExchangeRateId = NULL
				,@intCurrencyExchangeRateDetailId = NULL
				,@intNewCurrencyRateStageId = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strFromCurrency = strFromCurrency
				,@strToCurrency = strToCurrency
				,@dblRate = dblRate
				,@strRateType = strRateType
				,@dtmEffectiveDate = dtmEffectiveDate
			FROM tblIPCurrencyRateStage
			WHERE intCurrencyRateStageId = @intCurrencyRateStageId

			IF EXISTS (
					SELECT 1
					FROM tblIPCurrencyRateArchive
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

			SELECT @intFromCurrencyID = intCurrencyID
			FROM dbo.tblSMCurrency WITH (NOLOCK)
			WHERE strCurrency = @strFromCurrency

			SELECT @intToCurrencyID = intCurrencyID
			FROM dbo.tblSMCurrency WITH (NOLOCK)
			WHERE strCurrency = @strToCurrency

			SELECT @intRateTypeId = intCurrencyExchangeRateTypeId
			FROM dbo.tblSMCurrencyExchangeRateType WITH (NOLOCK)
			WHERE strCurrencyExchangeRateType = @strRateType

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intFromCurrencyID IS NULL
			BEGIN
				SELECT @strError = 'From Currency not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intToCurrencyID IS NULL
			BEGIN
				SELECT @strError = 'To Currency not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@dblRate, 0) <= 0
			BEGIN
				SELECT @strError = 'Rate should be greater than 0.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strRateType, '') = ''
			BEGIN
				SELECT @strError = 'Rate Type cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @dtmEffectiveDate IS NULL
			BEGIN
				SELECT @strError = 'Effective date cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			IF @intRateTypeId IS NULL
			BEGIN
				INSERT INTO tblSMCurrencyExchangeRateType (
					strCurrencyExchangeRateType
					,strDescription
					,intConcurrencyId
					)
				SELECT @strRateType
					,@strRateType
					,1

				SELECT @intRateTypeId = intCurrencyExchangeRateTypeId
				FROM dbo.tblSMCurrencyExchangeRateType
				WHERE strCurrencyExchangeRateType = @strRateType
			END

			SELECT @intCurrencyExchangeRateId = intCurrencyExchangeRateId
			FROM tblSMCurrencyExchangeRate ER
			WHERE ER.intFromCurrencyId = @intFromCurrencyID
				AND ER.intToCurrencyId = @intToCurrencyID

			IF @intActionId = 4
			BEGIN
				IF @intCurrencyExchangeRateId > 0
				BEGIN
					DELETE
					FROM tblSMCurrencyExchangeRate
					WHERE intCurrencyExchangeRateId = @intCurrencyExchangeRateId

					EXEC uspSMAuditLog @keyValue = @intCurrencyExchangeRateId
						,@screenName = 'i21.view.CurrencyExchangeRate'
						,@entityId = @intUserId
						,@actionType = 'Deleted'
				END

				GOTO MOVE_TO_ARCHIVE
			END
			ELSE IF @intActionId = 1
				OR @intActionId = 2
			BEGIN
				IF @intCurrencyExchangeRateId IS NULL
				BEGIN
					INSERT INTO tblSMCurrencyExchangeRate (
						intFromCurrencyId
						,intToCurrencyId
						,intSort
						,intConcurrencyId
						)
					SELECT @intFromCurrencyID
						,@intToCurrencyID
						,0
						,1

					SELECT @intCurrencyExchangeRateId = SCOPE_IDENTITY()

					INSERT INTO tblSMCurrencyExchangeRateDetail (
						intCurrencyExchangeRateId
						,dblRate
						,intRateTypeId
						,dtmValidFromDate
						,strSource
						,dtmCreatedDate
						,intConcurrencyId
						)
					SELECT @intCurrencyExchangeRateId
						,@dblRate
						,@intRateTypeId
						,@dtmEffectiveDate
						,'User Input'
						,GETDATE()
						,1

					SELECT @intCurrencyExchangeRateDetailId = SCOPE_IDENTITY()

					EXEC uspSMAuditLog @keyValue = @intCurrencyExchangeRateId
						,@screenName = 'i21.view.CurrencyExchangeRate'
						,@entityId = @intUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@details = ''
				END
				ELSE
				BEGIN
					UPDATE tblSMCurrencyExchangeRate
					SET intConcurrencyId = intConcurrencyId + 1
					WHERE intCurrencyExchangeRateId = @intCurrencyExchangeRateId

					SELECT @intCurrencyExchangeRateDetailId = intCurrencyExchangeRateDetailId
					FROM tblSMCurrencyExchangeRateDetail
					WHERE intCurrencyExchangeRateId = @intCurrencyExchangeRateId
						AND intRateTypeId = @intRateTypeId
						AND dtmValidFromDate = @dtmEffectiveDate

					DELETE
					FROM @tblSMCurrencyExchangeRateDetail

					DECLARE @strDetails NVARCHAR(MAX) = ''

					IF @intCurrencyExchangeRateDetailId IS NULL
					BEGIN
						INSERT INTO tblSMCurrencyExchangeRateDetail (
							intCurrencyExchangeRateId
							,dblRate
							,intRateTypeId
							,dtmValidFromDate
							,strSource
							,dtmCreatedDate
							,intConcurrencyId
							)
						OUTPUT inserted.intCurrencyExchangeRateDetailId
							,inserted.intRateTypeId
							,NULL
							,inserted.dblRate
						INTO @tblSMCurrencyExchangeRateDetail
						SELECT @intCurrencyExchangeRateId
							,@dblRate
							,@intRateTypeId
							,@dtmEffectiveDate
							,'User Input'
							,GETDATE()
							,1

						SELECT @intCurrencyExchangeRateDetailId = SCOPE_IDENTITY()

						IF EXISTS (
								SELECT 1
								FROM @tblSMCurrencyExchangeRateDetail
								)
						BEGIN
							SELECT @strDetails += '{"change":"tblSMCurrencyExchangeRateDetails","children":['

							SELECT @strDetails += '{"action":"Created","change":"Created - Record: ' + LTRIM(intCurrencyExchangeRateDetailId) + '","keyValue":' + LTRIM(intCurrencyExchangeRateDetailId) + ',"iconCls":"small-new-plus","leaf":true},'
							FROM @tblSMCurrencyExchangeRateDetail ERD

							SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

							SELECT @strDetails += '],"iconCls":"small-tree-grid","changeDescription":"Exchange Rate Details"}'
						END
					END
					ELSE
					BEGIN
						UPDATE ERD
						SET intConcurrencyId = ERD.intConcurrencyId + 1
							,dblRate = @dblRate
						OUTPUT inserted.intCurrencyExchangeRateDetailId
							,inserted.intRateTypeId
							,deleted.dblRate
							,inserted.dblRate
						INTO @tblSMCurrencyExchangeRateDetail
						FROM tblSMCurrencyExchangeRateDetail ERD
						WHERE intCurrencyExchangeRateDetailId = @intCurrencyExchangeRateDetailId

						IF EXISTS (
								SELECT 1
								FROM @tblSMCurrencyExchangeRateDetail
								WHERE dblOldRate <> dblNewRate
								)
						BEGIN
							SELECT @dblOldRate = NULL
								,@dblNewRate = NULL

							SELECT @dblOldRate = dblOldRate
								,@dblNewRate = dblNewRate
							FROM @tblSMCurrencyExchangeRateDetail

							SET @strDetails = '{  
										"change":"tblSMCurrencyExchangeRateDetails",
										"children":[  
											{  
											"action":"Updated",
											"change":"Updated - Record: ' + LTRIM(@intCurrencyExchangeRateDetailId) + '",
											"keyValue":' + LTRIM(@intCurrencyExchangeRateDetailId) + ',
											"iconCls":"small-tree-modified",
											"children":
												[   
													'
							SET @strDetails = @strDetails + '
													{  
													"change":"dblRate",
													"from":"' + LTRIM(@dblOldRate) + '",
													"to":"' + LTRIM(@dblNewRate) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intCurrencyExchangeRateDetailId) + ',
													"associationKey":"tblSMCurrencyExchangeRateDetails",
													"changeDescription":"Rate",
													"hidden":false
													},'

							IF RIGHT(@strDetails, 1) = ','
								SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))
							SET @strDetails = @strDetails + '
											]
										}
									],
									"iconCls":"small-tree-grid",
									"changeDescription":"Exchange Rate Details"
									}'
						END
					END

					IF (LEN(@strDetails) > 1)
					BEGIN
						EXEC uspSMAuditLog @keyValue = @intCurrencyExchangeRateId
							,@screenName = 'i21.view.CurrencyExchangeRate'
							,@entityId = @intUserId
							,@actionType = 'Updated'
							,@actionIcon = 'small-tree-modified'
							,@details = @strDetails
					END
				END
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
				,8 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

			INSERT INTO tblIPCurrencyRateArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strFromCurrency
				,strToCurrency
				,dblRate
				,strRateType
				,dtmEffectiveDate
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strFromCurrency
				,strToCurrency
				,dblRate
				,strRateType
				,dtmEffectiveDate
			FROM tblIPCurrencyRateStage
			WHERE intCurrencyRateStageId = @intCurrencyRateStageId

			SELECT @intNewCurrencyRateStageId = SCOPE_IDENTITY()

			DELETE
			FROM tblIPCurrencyRateStage
			WHERE intCurrencyRateStageId = @intCurrencyRateStageId

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
				,8 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

			INSERT INTO tblIPCurrencyRateError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strFromCurrency
				,strToCurrency
				,dblRate
				,strRateType
				,dtmEffectiveDate
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strFromCurrency
				,strToCurrency
				,dblRate
				,strRateType
				,dtmEffectiveDate
				,@ErrMsg
			FROM tblIPCurrencyRateStage
			WHERE intCurrencyRateStageId = @intCurrencyRateStageId

			SELECT @intNewCurrencyRateStageId = SCOPE_IDENTITY()

			DELETE
			FROM tblIPCurrencyRateStage
			WHERE intCurrencyRateStageId = @intCurrencyRateStageId
		END CATCH

		SELECT @intCurrencyRateStageId = MIN(intCurrencyRateStageId)
		FROM @tblIPCurrencyRateStage
		WHERE intCurrencyRateStageId > @intCurrencyRateStageId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPCurrencyRateStage S
	JOIN @tblIPCurrencyRateStage TS ON TS.intCurrencyRateStageId = S.intCurrencyRateStageId
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
