CREATE PROCEDURE uspQMTransferERPTestResult
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	SELECT @strServerName = strServerName
		,@strDatabaseName = strDatabaseName
	FROM tblIPERPDetail WITH (NOLOCK)

	IF ISNULL(@strServerName, '') = ''
		OR ISNULL(@strDatabaseName, '') = ''
	BEGIN
		RETURN
	END

	SELECT @strSQL = N'INSERT INTO dbo.tblIPTestResultStage (
		strSampleNumber
		,strSampleStatus
		,dblCuppingScore
		,dblGradingScore
		,strComments
		,dtmCuppingDate
		,strCuppedBy
		,dtmUpdated
		,strUpdatedBy
		,intRecordStatus
		)
	SELECT SampleNumber
		,DispositionStatus
		,CuppingScore
		,GradingScore
		,Comments
		,CuppingDate
		,CuppedBy
		,Updated
		,UpdatedBy
		,RecordStatus
	FROM ' + @strServerName + '.' + @strDatabaseName + '.dbo.SQExport WHERE RecordStatus = 0'

	EXEC sp_executesql @strSQL

	SELECT @strSQL = ''

	SELECT @strSQL = N'UPDATE ' + @strServerName + '.' + @strDatabaseName + '.dbo.SQExport SET RecordStatus = 1 WHERE RecordStatus = 0'

	EXEC sp_executesql @strSQL
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
