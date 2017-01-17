CREATE PROCEDURE uspLGProcessIntegrationLogData
AS 
BEGIN TRY
	DECLARE @intLoadId INT
	DECLARE @intMinLoadId INT
	DECLARE @intMinLoadLogId INT
	DECLARE @intMaxLoadLogId INT
	DECLARE @intMinLoadRecordId INT
	
	DECLARE @intLoadDetailId INT
	DECLARE @intMinLoadDetailId INT
	DECLARE @intMinLoadDetailLogId INT
	DECLARE @intMaxLoadDetailLogId INT
	DECLARE @intMinLoadDetailRecordId INT

	DECLARE @intLoadContainerId INT
	DECLARE @intMinLoadContainerId INT
	DECLARE @intMinLoadContainerLogId INT
	DECLARE @intMaxLoadContainerLogId INT
	DECLARE @intMinLoadContainerRecordId INT

	DECLARE @strErrMsg NVARCHAR(MAX)

	DECLARE @tblLoadContainerRecord TABLE 
			(intLoadContainerRecordId INT Identity(1, 1)
			,intLoadContainerLogId INT
			,intLoadContainerId INT)

	DECLARE @tblLoadDetailRecord TABLE 
			(intLoadDetailRecordId INT Identity(1, 1)
			,intLoadDetailLogId INT
			,intLoadDetailId INT)

	DECLARE @tblLoadRecord TABLE 
			(intLoadRecordId INT Identity(1, 1)
			,intLoadLogId INT
			,intLoadId INT)

	INSERT INTO @tblLoadContainerRecord
	SELECT intLoadContainerLogId,
		   intLoadContainerId
	FROM tblLGLoadContainerLog
	ORDER BY intLoadContainerId DESC
		,intLoadContainerLogId

	INSERT INTO @tblLoadDetailRecord
	SELECT intLGLoadDetailLogId,
		   intLoadDetailId
	FROM tblLGLoadDetailLog
	ORDER BY intLoadDetailId DESC
		,intLGLoadDetailLogId

	INSERT INTO @tblLoadRecord
	SELECT intLoadLogId,
		   intLoadId
	FROM tblLGLoadLog

	SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
	FROM @tblLoadRecord

	WHILE ISNULL(@intMinLoadRecordId, 0) <> 0
	BEGIN
		SELECT @intLoadId = intLoadId
		FROM @tblLoadRecord
		WHERE intLoadRecordId = @intMinLoadRecordId

		SELECT @intMinLoadLogId = MIN(intLoadLogId)
		FROM @tblLoadRecord
		WHERE intLoadId = @intLoadId

		SELECT @intMaxLoadLogId = MAX(intLoadLogId)
		FROM @tblLoadRecord
		WHERE intLoadId = @intLoadId

		EXEC uspLGProcessLoadToIntegration 'tblLGLoadLog'
			,@intMinLoadLogId
			,@intMaxLoadLogId
			,NULL
			,@intMaxLoadLogId
			,0
			,0

		DELETE FROM @tblLoadRecord WHERE intLoadId = @intLoadId

		SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
		FROM @tblLoadRecord
		WHERE intLoadRecordId > @intMinLoadRecordId
	END

	SELECT @intMinLoadDetailRecordId = MIN(intLoadDetailRecordId)
	FROM @tblLoadDetailRecord

	WHILE ISNULL(@intMinLoadDetailRecordId, 0) <> 0
	BEGIN
		SELECT @intLoadDetailId = intLoadDetailId
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailRecordId = @intMinLoadDetailRecordId

		SELECT @intMinLoadDetailLogId = MIN(intLoadDetailLogId)
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailId = @intLoadDetailId

		SELECT @intMaxLoadDetailLogId = MAX(intLoadDetailLogId)
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailId = @intLoadDetailId

		EXEC uspLGProcessLoadToIntegration 'tblLGLoadDetailLog'
			,@intMinLoadDetailLogId
			,@intMaxLoadDetailLogId
			,'intLoadLogId,strRowState,intRowNumber'
			,0
			,@intMaxLoadDetailLogId
			,0

		DELETE FROM @tblLoadDetailRecord WHERE intLoadDetailId = @intLoadDetailId

		SELECT @intMinLoadDetailRecordId = MIN(intLoadDetailRecordId)
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailRecordId > @intMinLoadDetailRecordId
	END

	SELECT @intMinLoadContainerRecordId = MIN(intLoadContainerRecordId)
	FROM @tblLoadContainerRecord

	WHILE ISNULL(@intMinLoadContainerRecordId, 0) <> 0
	BEGIN
		SELECT @intLoadContainerId = intLoadContainerId
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerRecordId = @intMinLoadContainerRecordId

		SELECT @intMinLoadContainerLogId = MIN(intLoadContainerLogId)
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerId = @intLoadContainerId

		SELECT @intMaxLoadContainerLogId = MAX(intLoadContainerLogId)
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerId = @intLoadContainerId

		EXEC uspLGProcessLoadToIntegration 'tblLGLoadContainerLog'
			,@intMinLoadContainerLogId
			,@intMaxLoadContainerLogId
			,'intLoadLogId,strRowState'
			,0
			,0
			,@intMaxLoadContainerLogId

		DELETE FROM @tblLoadContainerRecord WHERE intLoadContainerId = @intLoadContainerId

		SELECT @intMinLoadContainerRecordId = MIN(intLoadContainerRecordId)
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerRecordId > @intMinLoadContainerRecordId
	END

		DELETE FROM tblLGLoadContainerLog
		DELETE FROM tblLGLoadDetailLog
		DELETE FROM tblLGLoadLog
END TRY
BEGIN CATCH

	SET @strErrMsg = ERROR_MESSAGE()
	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg
		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END

END CATCH