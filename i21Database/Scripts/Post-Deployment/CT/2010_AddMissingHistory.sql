GO
	PRINT('CT - 2010_AddMissingHistory Started')


	IF OBJECT_ID('tempdb..#TempContractHeaders') IS NOT NULL DROP TABLE #TempContractHeaders

	SELECT DISTINCT a.intContractHeaderId, c.strContractNumber, intUserId = ISNULL(a.intCreatedById, a.intLastModifiedById)
	INTO #TempContractHeaders
	FROM tblCTContractDetail a
	INNER JOIN tblCTContractHeader c ON a.intContractHeaderId = c.intContractHeaderId
	WHERE intContractDetailId NOT IN (SELECT intContractDetailId FROM tblCTSequenceHistory)
	ORDER BY a.intContractHeaderId ASC

	DECLARE @currentId INT,
			@userId INT,
			@irelyAdmin INT
	WHILE EXISTS(SELECT TOP 1 1 FROM #TempContractHeaders)
	BEGIN
		SELECT TOP 1 @currentId = intContractHeaderId, @userId = intUserId FROM #TempContractHeaders

		SELECT @irelyAdmin = intEntityId FROM tblEMEntityCredential WHERE UPPER(strUserName) = 'IRELYADMIN'
		SELECT @userId = ISNULL(@userId, @irelyAdmin)
	
		EXEC uspCTCreateDetailHistory	@intContractHeaderId 	= @currentId,
										@ysnUseContractDate 	= 1,
										@strSource 				= 'Contract',
										@strProcess 			= 'Missing History',
										@intUserId				= @userId	

		DELETE FROM #TempContractHeaders WHERE intContractHeaderId = @currentId
	END

	PRINT('CT - 2010_AddMissingHistory End')
GO

