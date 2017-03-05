CREATE PROCEDURE dbo.uspMFSaveYieldConfig (
	@strXML NVARCHAR(MAX)
	,@intYieldId INT OUTPUT
	,@intConcurrencyId INT OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@intManufacturingProcessId INT
		,@strInputFormula NVARCHAR(MAX)
		,@strOutputFormula NVARCHAR(MAX)
		,@strYieldFormula NVARCHAR(MAX)
		,@intUserId INT
		,@dtmCurrentDate DATETIME

	SELECT @dtmCurrentDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intYieldId = intYieldId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@strInputFormula = strInputFormula
		,@strOutputFormula = strOutputFormula
		,@strYieldFormula = strYieldFormula
		,@intConcurrencyId = intConcurrencyId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intYieldId INT
			,intManufacturingProcessId INT
			,strInputFormula NVARCHAR(MAX)
			,strOutputFormula NVARCHAR(MAX)
			,strYieldFormula NVARCHAR(MAX)
			,intConcurrencyId INT
			,intUserId INT
			)

	IF NOT EXISTS (
			SELECT *
			FROM tblMFManufacturingProcess
			WHERE intManufacturingProcessId = @intManufacturingProcessId
			)
	BEGIN
		RAISERROR (
				90029
				,11
				,1
				)
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @intYieldId IS NULL
	BEGIN
		INSERT INTO dbo.tblMFYield (
			intManufacturingProcessId
			,strInputFormula
			,strOutputFormula
			,strYieldFormula
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			,intConcurrencyId
			)
		VALUES (
			@intManufacturingProcessId
			,@strInputFormula
			,@strOutputFormula
			,@strYieldFormula
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,1
			)

		SELECT @intYieldId = SCOPE_IDENTITY()

		SELECT @intConcurrencyId = 1
	END
	ELSE
	BEGIN
		IF (
				SELECT intConcurrencyId
				FROM dbo.tblMFYield
				WHERE intYieldId = @intYieldId
				) <> @intConcurrencyId
		BEGIN
			RAISERROR (
					51194
					,11
					,1
					)

			RETURN
		END

		UPDATE dbo.tblMFYield
		SET strInputFormula = @strInputFormula
			,strOutputFormula = @strOutputFormula
			,strYieldFormula = @strYieldFormula
			,intConcurrencyId = intConcurrencyId + 1
			,dtmLastModified = @dtmCurrentDate
			,intLastModifiedUserId = @intUserId
		WHERE intYieldId = @intYieldId
	END

	SELECT @intConcurrencyId = intConcurrencyId
	FROM dbo.tblMFYield
	WHERE intYieldId = @intYieldId

	DELETE
	FROM dbo.tblMFYieldDetail
	WHERE intYieldId = @intYieldId

	INSERT INTO dbo.tblMFYieldDetail (
		intYieldId
		,intYieldTransactionId
		,ysnSelect
		)
	SELECT @intYieldId
		,x.intYieldTransactionId
		,x.ysnSelect
	FROM OPENXML(@idoc, 'root/YieldDetails/YieldDetail', 2) WITH (
			intYieldTransactionId INT
			,ysnSelect BIT
			) x

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


