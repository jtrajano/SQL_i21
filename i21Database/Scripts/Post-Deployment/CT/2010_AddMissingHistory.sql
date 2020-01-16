GO
	PRINT('CT - 2010_AddMissingHistory Started')


	IF OBJECT_ID('tempdb..#TempContractHeaders') IS NOT NULL DROP TABLE #TempContractHeaders

	SELECT DISTINCT a.intContractHeaderId, c.strContractNumber
	INTO #TempContractHeaders
	FROM tblCTContractDetail a
	LEFT JOIN tblCTSequenceHistory b ON a.intContractHeaderId = b.intContractHeaderId
	INNER JOIN tblCTContractHeader c ON a.intContractHeaderId = c.intContractHeaderId
	WHERE b.intContractHeaderId IS NULL
	ORDER BY a.intContractHeaderId ASC

	DECLARE @currentId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM #TempContractHeaders)
	BEGIN
		SELECT TOP 1 @currentId = intContractHeaderId FROM #TempContractHeaders
	
		EXEC uspCTCreateDetailHistory @intContractHeaderId =  @currentId, @ysnUseContractDate = 1

		DELETE FROM #TempContractHeaders WHERE intContractHeaderId = @currentId
	END

	PRINT('CT - 2010_AddMissingHistory End')
GO

