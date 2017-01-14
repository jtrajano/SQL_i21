CREATE PROCEDURE uspLGProcessLoadToIntegration 
	 @strTblName NVARCHAR(50)
	,@intCompareWith INT
	,@intCompareTo INT
	,@strColumnsToIgnore NVARCHAR(MAX)
	,@intLoadLogId INT = 0
	,@intLoadDetailLogId INT = 0
	,@intLoadContainerLogId INT = 0
AS
BEGIN TRY
	DECLARE @strModifiedColumns NVARCHAR(MAX)
	DECLARE @strSQL NVARCHAR(MAX)
	DECLARE @strErrMsg NVARCHAR(MAX)

	EXEC uspCTCompareRecords @strTblName = @strTblName
		,@intCompareWith = @intCompareWith
		,@intCompareTo = @intCompareTo
		,@strColumnsToIgnore = @strColumnsToIgnore
		,@strModifiedColumns = @strModifiedColumns OUTPUT

	IF (@strTblName = 'tblLGLoadLog' AND LTRIM(RTRIM(ISNULL(@strModifiedColumns,''))) <> '')
	BEGIN
		SELECT @strSQL = 'INSERT INTO  tblLGLoadStg (' + @strModifiedColumns + ' ,intLoadId,strRowState,dtmFeedCreated)
										SELECT	' + @strModifiedColumns + ',intLoadId,''Modified'',GETDATE()
										FROM	tblLGLoadLog
										WHERE	intLoadLogId = @intLoadLogId '

		EXEC sp_executesql @strSQL
			,N'@intLoadLogId INT'
			,@intLoadLogId = @intLoadLogId
		END
	ELSE IF (@strTblName = 'tblLGLoadDetailLog' AND LTRIM(RTRIM(ISNULL(@strModifiedColumns,''))) <> '')
	BEGIN
		SELECT @strSQL = 'INSERT INTO  tblLGLoadDetailStg (' + @strModifiedColumns + ',strRowState)
										SELECT	' + @strModifiedColumns + ',''Modified''
										FROM	tblLGLoadDetailLog
										WHERE	intLGLoadDetailLogId = @intLoadDetailLogId '

		EXEC sp_executesql @strSQL
			,N'@intLoadDetailLogId INT'
			,@intLoadDetailLogId = @intLoadDetailLogId
	END
	ELSE IF (@strTblName = 'tblLGLoadContainerLog' AND LTRIM(RTRIM(ISNULL(@strModifiedColumns,''))) <> '')
	BEGIN
		SELECT @strSQL = 'INSERT INTO  tblLGLoadContainerStg (' + @strModifiedColumns + ',strRowState)
										SELECT	' + @strModifiedColumns + ',''Modified''
										FROM	tblLGLoadContainerLog
										WHERE	intLoadContainerLogId = @intLoadContainerLogId '

		EXEC sp_executesql @strSQL
			,N'@intLoadContainerLogId INT'
			,@intLoadContainerLogId = @intLoadContainerLogId
	END
END TRY
BEGIN CATCH

	SET @strErrMsg = ERROR_MESSAGE()
	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg
		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END

END CATCH