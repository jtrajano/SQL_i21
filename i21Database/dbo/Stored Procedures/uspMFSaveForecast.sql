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
		,@dblOldJan INT
		,@dblNewJan INT
		,@dblOldFeb INT
		,@dblNewFeb INT
		,@dblOldMar INT
		,@dblNewMar INT
		,@dblOldApr INT
		,@dblNewApr INT
		,@dblOldMay INT
		,@dblNewMay INT
		,@dblOldJun INT
		,@dblNewJun INT
		,@dblOldJul INT
		,@dblNewJul INT
		,@dblOldAug INT
		,@dblNewAug INT
		,@dblOldSep INT
		,@dblNewSep INT
		,@dblOldOct INT
		,@dblNewOct INT
		,@dblOldNov INT
		,@dblNewNov INT
		,@dblOldDec INT
		,@dblNewDec INT
	DECLARE @ForecastItemValue TABLE (
		intForecastItemValueId INT NOT NULL
		,dblOldJan INT
		,dblNewJan INT
		,dblOldFeb INT
		,dblNewFeb INT
		,dblOldMar INT
		,dblNewMar INT
		,dblOldApr INT
		,dblNewApr INT
		,dblOldMay INT
		,dblNewMay INT
		,dblOldJun INT
		,dblNewJun INT
		,dblOldJul INT
		,dblNewJul INT
		,dblOldAug INT
		,dblNewAug INT
		,dblOldSep INT
		,dblNewSep INT
		,dblOldOct INT
		,dblNewOct INT
		,dblOldNov INT
		,dblNewNov INT
		,dblOldDec INT
		,dblNewDec INT
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

	IF Exists(
			SELECT *
			FROM dbo.tblMFForecastItemValue FV
			JOIN OPENXML(@idoc, 'root/ForecastItemValues/ForecastItemValue', 2) WITH (intForecastItemValueId INT,intConcurrencyId int) x ON x.intForecastItemValueId = FV.intForecastItemValueId
			Where FV.intConcurrencyId<>x.intConcurrencyId
			) 
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
	SET dblJan = x.dblJan
		,dblFeb = x.dblFeb
		,dblMar = x.dblMar
		,dblApr = x.dblApr
		,dblMay = x.dblMay
		,dblJun = x.dblJun
		,dblJul = x.dblJul
		,dblAug = x.dblAug
		,dblSep = x.dblSep
		,dblOct = x.dblOct
		,dblNov = x.dblNov
		,dblDec = x.dblDec
		,intConcurrencyId = intConcurrencyId + 1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	OUTPUT inserted.intForecastItemValueId
		,deleted.dblJan
		,inserted.dblJan
		,deleted.dblFeb
		,inserted.dblFeb
		,deleted.dblMar
		,inserted.dblMar
		,deleted.dblApr
		,inserted.dblApr
		,deleted.dblMay
		,inserted.dblMay
		,deleted.dblJun
		,inserted.dblJun
		,deleted.dblJul
		,inserted.dblJul
		,deleted.dblAug
		,inserted.dblAug
		,deleted.dblSep
		,inserted.dblSep
		,deleted.dblOct
		,inserted.dblOct
		,deleted.dblNov
		,inserted.dblNov
		,deleted.dblDec
		,inserted.dblDec
	INTO @ForecastItemValue
	FROM OPENXML(@idoc, 'root/ForecastItemValues/ForecastItemValue', 2) WITH (
			intForecastItemValueId INT
			,dblJan INT
			,dblFeb INT
			,dblMar INT
			,dblApr INT
			,dblMay INT
			,dblJun INT
			,dblJul INT
			,dblAug INT
			,dblSep INT
			,dblOct INT
			,dblNov INT
			,dblDec INT
			) x
	WHERE x.intForecastItemValueId = tblMFForecastItemValue.intForecastItemValueId

	SELECT @intConcurrencyId = MAX(FV.intConcurrencyId)
	FROM dbo.tblMFForecastItemValue FV
	JOIN OPENXML(@idoc, 'root/ForecastItemValues/ForecastItemValue', 2) WITH (intForecastItemValueId INT) x ON x.intForecastItemValueId = FV.intForecastItemValueId

	SELECT @intForecastItemValueId = Min(intForecastItemValueId)
	FROM @ForecastItemValue

	WHILE @intForecastItemValueId IS NOT NULL
	BEGIN
		SELECT @dblOldJan = NULL
			,@dblNewJan = NULL
			,@dblOldFeb = NULL
			,@dblNewFeb = NULL
			,@dblOldMar = NULL
			,@dblNewMar = NULL
			,@dblOldApr = NULL
			,@dblNewApr = NULL
			,@dblOldMay = NULL
			,@dblNewMay = NULL
			,@dblOldJun = NULL
			,@dblNewJun = NULL
			,@dblOldJul = NULL
			,@dblNewJul = NULL
			,@dblOldAug = NULL
			,@dblNewAug = NULL
			,@dblOldSep = NULL
			,@dblNewSep = NULL
			,@dblOldOct = NULL
			,@dblNewOct = NULL
			,@dblOldNov = NULL
			,@dblNewNov = NULL
			,@dblOldDec = NULL
			,@dblNewDec = NULL

		SELECT @dblOldJan =dblOldJan
			,@dblNewJan = dblNewJan
			,@dblOldFeb = dblOldFeb
			,@dblNewFeb = dblNewFeb
			,@dblOldMar = dblOldMar
			,@dblNewMar = dblNewMar
			,@dblOldApr = dblOldApr
			,@dblNewApr = dblNewApr
			,@dblOldMay = dblOldMay
			,@dblNewMay = dblNewMay
			,@dblOldJun = dblOldJun
			,@dblNewJun = dblNewJun
			,@dblOldJul = dblOldJul
			,@dblNewJul = dblNewJul
			,@dblOldAug = dblOldAug
			,@dblNewAug = dblNewAug
			,@dblOldSep = dblOldSep
			,@dblNewSep = dblNewSep
			,@dblOldOct = dblOldOct
			,@dblNewOct = dblNewOct
			,@dblOldNov = dblOldNov
			,@dblNewNov = dblNewNov
			,@dblOldDec = dblOldDec
			,@dblNewDec = dblNewDec
		FROM @ForecastItemValue
		WHERE intForecastItemValueId = @intForecastItemValueId

		IF @dblOldJan <> @dblNewJan
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldJan
				,@toValue = @dblNewJan
		END

		IF @dblOldFeb <> @dblNewFeb
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldFeb
				,@toValue = @dblNewFeb
		END

		IF @dblOldMar <> @dblNewMar
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldMar
				,@toValue = @dblNewMar
		END

		IF @dblOldApr <> @dblNewApr
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldApr
				,@toValue = @dblNewApr
		END

		IF @dblOldMay <> @dblNewMay
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldMay
				,@toValue = @dblNewMay
		END

		IF @dblOldJun <> @dblNewJun
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldJun
				,@toValue = @dblNewJun
		END

		IF @dblOldJul <> @dblNewJul
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldJul
				,@toValue = @dblNewJul
		END

		IF @dblOldAug <> @dblNewAug
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldAug
				,@toValue = @dblNewAug
		END

		IF @dblOldSep <> @dblNewSep
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldSep
				,@toValue = @dblNewSep
		END

		IF @dblOldOct <> @dblNewOct
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldOct
				,@toValue = @dblNewOct
		END

		IF @dblOldNov <> @dblNewNov
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldNov
				,@toValue = @dblNewNov
		END

		IF @dblOldDec <> @dblNewDec
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intForecastItemValueId
				,@screenName = 'Manufacuturing.view.Forecast'
				,@entityId = @intUserId
				,@actionType = 'Processed'
				,@changeDescription = @strReasonCode
				,@fromValue = @dblOldDec
				,@toValue = @dblNewDec
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



