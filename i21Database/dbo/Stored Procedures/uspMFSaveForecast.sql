CREATE PROCEDURE dbo.uspMFSaveForecast (
	@strXML NVARCHAR(MAX)
	,@intConcurrencyId INT OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@intUserId INT
		,@dtmCurrentDate DATETIME
		,@intForecastItemValueId INT
		,@strReasonCode NVARCHAR(MAX)
		,@intOldJAN INT
		,@intNewJAN INT
		,@intOldFEB INT
		,@intNewFEB INT
		,@intOldMAR INT
		,@intNewMAR INT
		,@intOldAPR INT
		,@intNewAPR INT
		,@intOldMAY INT
		,@intNewMAY INT
		,@intOldJUN INT
		,@intNewJUN INT
		,@intOldJUL INT
		,@intNewJUL INT
		,@intOldAUG INT
		,@intNewAUG INT
		,@intOldSEP INT
		,@intNewSEP INT
		,@intOldOCT INT
		,@intNewOCT INT
		,@intOldNOV INT
		,@intNewNOV INT
		,@intOldDEC INT
		,@intNewDEC INT
	DECLARE @ForecastItemValue TABLE (
		intForecastItemValueId INT NOT NULL
		,intOldJAN INT
		,intNewJAN INT
		,intOldFEB INT
		,intNewFEB INT
		,intOldMAR INT
		,intNewMAR INT
		,intOldAPR INT
		,intNewAPR INT
		,intOldMAY INT
		,intNewMAY INT
		,intOldJUN INT
		,intNewJUN INT
		,intOldJUL INT
		,intNewJUL INT
		,intOldAUG INT
		,intNewAUG INT
		,intOldSEP INT
		,intNewSEP INT
		,intOldOCT INT
		,intNewOCT INT
		,intOldNOV INT
		,intNewNOV INT
		,intOldDEC INT
		,intNewDEC INT
		)

	SELECT @dtmCurrentDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @strReasonCode = strReasonCode
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strReasonCode NVARCHAR(MAX)
			,intConcurrencyId INT
			,intUserId INT
			)

	IF (
			SELECT MAX(FV.intConcurrencyId)
			FROM dbo.tblMFForecastItemValue FV
			JOIN OPENXML(@idoc, 'root/ForecastItemValues/ForecastItemValue', 2) WITH (intForecastItemValueId INT) x ON x.intForecastItemValueId = FV.intForecastItemValueId
			) <> @intConcurrencyId
	BEGIN
		RAISERROR (
				51194
				,11
				,1
				)

		RETURN
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	UPDATE dbo.tblMFForecastItemValue
	SET intJAN = x.intJAN
		,intFEB = x.intFEB
		,intMAR = x.intMAR
		,intAPR = x.intAPR
		,intMAY = x.intMAY
		,intJUN = x.intJUN
		,intJUL = x.intJUL
		,intAUG = x.intAUG
		,intSEP = x.intSEP
		,intOCT = x.intOCT
		,intNOV = x.intNOV
		,intDEC = x.intDEC
		,intConcurrencyId = intConcurrencyId + 1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	OUTPUT inserted.intForecastItemValueId
		,deleted.intJAN
		,inserted.intJAN
		,deleted.intFEB
		,inserted.intFEB
		,deleted.intMAR
		,inserted.intMAR
		,deleted.intAPR
		,inserted.intAPR
		,deleted.intMAY
		,inserted.intMAY
		,deleted.intJUN
		,inserted.intJUN
		,deleted.intJUL
		,inserted.intJUL
		,deleted.intAUG
		,inserted.intAUG
		,deleted.intSEP
		,inserted.intSEP
		,deleted.intOCT
		,inserted.intOCT
		,deleted.intNOV
		,inserted.intNOV
		,deleted.intDEC
		,inserted.intDEC
	INTO @ForecastItemValue
	FROM OPENXML(@idoc, 'root/ForecastItemValues/ForecastItemValue', 2) WITH (
			intForecastItemValueId INT
			,intJAN INT
			,intFEB INT
			,intMAR INT
			,intAPR INT
			,intMAY INT
			,intJUN INT
			,intJUL INT
			,intAUG INT
			,intSEP INT
			,intOCT INT
			,intNOV INT
			,intDEC INT
			) x
	WHERE x.intForecastItemValueId = tblMFForecastItemValue.intForecastItemValueId

	SELECT @intConcurrencyId = MAX(FV.intConcurrencyId)
	FROM dbo.tblMFForecastItemValue FV
	JOIN OPENXML(@idoc, 'root/ForecastItemValues/ForecastItemValue', 2) WITH (intForecastItemValueId INT) x ON x.intForecastItemValueId = FV.intForecastItemValueId

	SELECT @intForecastItemValueId = Min(intForecastItemValueId)
	FROM @ForecastItemValue

	WHILE @intForecastItemValueId IS NOT NULL
	BEGIN
		SELECT @intOldJAN = NULL
			,@intNewJAN = NULL
			,@intOldFEB = NULL
			,@intNewFEB = NULL
			,@intOldMAR = NULL
			,@intNewMAR = NULL
			,@intOldAPR = NULL
			,@intNewAPR = NULL
			,@intOldMAY = NULL
			,@intNewMAY = NULL
			,@intOldJUN = NULL
			,@intNewJUN = NULL
			,@intOldJUL = NULL
			,@intNewJUL = NULL
			,@intOldAUG = NULL
			,@intNewAUG = NULL
			,@intOldSEP = NULL
			,@intNewSEP = NULL
			,@intOldOCT = NULL
			,@intNewOCT = NULL
			,@intOldNOV = NULL
			,@intNewNOV = NULL
			,@intOldDEC = NULL
			,@intNewDEC = NULL

		SELECT @intOldJAN = intOldJAN
			,@intNewJAN = intNewJAN
			,@intOldFEB = intOldFEB
			,@intNewFEB = intNewFEB
			,@intOldMAR = intOldMAR
			,@intNewMAR = intNewMAR
			,@intOldAPR = intOldAPR
			,@intNewAPR = intNewAPR
			,@intOldMAY = intOldMAY
			,@intNewMAY = intNewMAY
			,@intOldJUN = intOldJUN
			,@intNewJUN = intNewJUN
			,@intOldJUL = intOldJUL
			,@intNewJUL = intNewJUL
			,@intOldAUG = intOldAUG
			,@intNewAUG = intNewAUG
			,@intOldSEP = intOldSEP
			,@intNewSEP = intNewSEP
			,@intOldOCT = intOldOCT
			,@intNewOCT = intNewOCT
			,@intOldNOV = intOldNOV
			,@intNewNOV = intNewNOV
			,@intOldDEC = intOldDEC
			,@intNewDEC = intNewDEC
		FROM @ForecastItemValue
		WHERE intForecastItemValueId = @intForecastItemValueId

		IF @intOldJAN <> @intNewJAN
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldJAN
				,@toValue = @intNewJAN
		END

		IF @intOldFEB <> @intNewFEB
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldFEB
				,@toValue = @intNewFEB
		END

		IF @intOldMAR <> @intNewMAR
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldMAR
				,@toValue = @intNewMAR
		END

		IF @intOldAPR <> @intNewAPR
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldAPR
				,@toValue = @intNewAPR
		END

		IF @intOldMAY <> @intNewMAY
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldMAY
				,@toValue = @intNewMAY
		END

		IF @intOldJUN <> @intNewJUN
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldJUN
				,@toValue = @intNewJUN
		END

		IF @intOldJUL <> @intNewJUL
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldJUL
				,@toValue = @intNewJUL
		END

		IF @intOldAUG <> @intNewAUG
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldAUG
				,@toValue = @intNewAUG
		END

		IF @intOldSEP <> @intNewSEP
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldSEP
				,@toValue = @intNewSEP
		END

		IF @intOldOCT <> @intNewOCT
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldOCT
				,@toValue = @intNewOCT
		END

		IF @intOldNOV <> @intNewNOV
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldNOV
				,@toValue = @intNewNOV
		END

		IF @intOldDEC <> @intNewDEC
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @intOldDEC
				,@toValue = @intNewDEC
		END

		SELECT @intForecastItemValueId = Min(intForecastItemValueId)
		FROM @ForecastItemValue
		WHERE intForecastItemValueId > @intForecastItemValueId
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO



