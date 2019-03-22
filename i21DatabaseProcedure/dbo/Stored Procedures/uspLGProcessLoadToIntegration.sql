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
	DECLARE @intLoadStgId INT

	EXEC uspCTCompareRecords @strTblName = @strTblName
		,@intCompareWith = @intCompareWith
		,@intCompareTo = @intCompareTo
		,@strColumnsToIgnore = @strColumnsToIgnore
		,@strModifiedColumns = @strModifiedColumns OUTPUT

	IF (@strTblName = 'tblLGLoadLog' )
	BEGIN
		IF LTRIM(RTRIM(ISNULL(@strModifiedColumns,''))) = ''
			SET @strModifiedColumns = NULL

		SELECT @strSQL = 'INSERT INTO  tblLGLoadStg (' + ISNULL(@strModifiedColumns + ',','') + 'strLoadNumber,strShippingInstructionNumber, intLoadId,strRowState,strTransactionType,dtmFeedCreated)
										SELECT	' + ISNULL(@strModifiedColumns + ',','') + 'strLoadNumber,strShippingInstructionNumber ,intLoadId,''Modified'',strTransactionType,GETDATE()
										FROM	tblLGLoadLog
										WHERE	intLoadLogId = @intLoadLogId '

		EXEC sp_executesql @strSQL
			,N'@intLoadLogId INT'
			,@intLoadLogId = @intLoadLogId
		END
	ELSE IF (@strTblName = 'tblLGLoadDetailLog' AND LTRIM(RTRIM(ISNULL(@strModifiedColumns,''))) <> '')
	BEGIN
		SELECT @intLoadStgId = MAX(intLoadStgId) FROM tblLGLoadStg
		IF LTRIM(RTRIM(ISNULL(@strModifiedColumns,''))) = ''
			SET @strModifiedColumns = NULL

		SELECT @strSQL = 'INSERT INTO  tblLGLoadDetailStg (' + ISNULL(@strModifiedColumns + ',','') + 'intLoadStgId,intSIDetailId,intLoadDetailId,strExternalPONumber,strExternalPOItemNumber,strExternalPOBatchNumber,strExternalShipmentItemNumber,strExternalBatchNo,strCommodityCode,strRowState,dtmFeedCreated)
										SELECT	' + ISNULL(@strModifiedColumns + ',','') + CONVERT(NVARCHAR,@intLoadStgId)  + ',intSIDetailId,intLoadDetailId,strExternalPONumber,strExternalPOItemNumber,strExternalPOBatchNumber,strExternalShipmentItemNumber,strExternalBatchNo,strCommodityCode,''Modified'',GETDATE()
										FROM	tblLGLoadDetailLog
										WHERE	intLGLoadDetailLogId = @intLoadDetailLogId '

		EXEC sp_executesql @strSQL
			,N'@intLoadDetailLogId INT'
			,@intLoadDetailLogId = @intLoadDetailLogId
	END
	ELSE IF (@strTblName = 'tblLGLoadContainerLog' AND LTRIM(RTRIM(ISNULL(@strModifiedColumns,''))) <> '')
	BEGIN
		SELECT @intLoadStgId = MAX(intLoadStgId) FROM tblLGLoadStg
		SELECT @strSQL = 'INSERT INTO  tblLGLoadContainerStg (' + ISNULL(@strModifiedColumns + ',','') + 'intLoadStgId,intLoadId,intLoadContainerId,strRowState,dtmFeedCreated)
										SELECT	' + ISNULL(@strModifiedColumns + ',','') + CONVERT(NVARCHAR,@intLoadStgId) + ',intLoadId,intLoadContainerId,''Modified'',GETDATE()
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