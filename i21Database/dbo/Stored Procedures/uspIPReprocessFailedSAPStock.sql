CREATE PROCEDURE uspIPReprocessFailedSAPStock
AS
BEGIN TRY
	DECLARE @FailedSAPStock TABLE (
		intRecordId INT identity(1, 1)
		,strXML NVARCHAR(MAX)
		)
	DECLARE @dtmDate DATETIME
		,@intRecordId INT
		,@strXML NVARCHAR(MAX)

	SELECT @dtmDate = Convert(DATETIME, Convert(CHAR, Getdate(), 101))

	INSERT INTO @FailedSAPStock (strXML)
	SELECT strData
	FROM tblIPLog
	WHERE intProcessId = 5
		AND strMessage = 'The underlying provider failed on Open.'
		AND dtmDate > @dtmDate

	SELECT @intRecordId = MIN(intRecordId)
	FROM @FailedSAPStock

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @strXML = NULL

		SELECT @strXML = strXML
		FROM @FailedSAPStock
		WHERE intRecordId = @intRecordId

		BEGIN TRY
			EXEC [dbo].[uspIPStageSAPStock] @strXml = @strXML
				,@strSessionId = ''
				,@strInfo1 = ''
				,@strInfo2 = ''
		END TRY

		BEGIN CATCH
		END CATCH

		SELECT @intRecordId = MIN(intRecordId)
		FROM @FailedSAPStock
		WHERE intRecordId > @intRecordId
	END
END TRY

BEGIN CATCH
END CATCH
