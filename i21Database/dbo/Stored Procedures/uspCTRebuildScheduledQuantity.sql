CREATE PROCEDURE [dbo].[uspCTRebuildScheduledQuantity]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @Contract TABLE 
	(  
		intUniqueId	INT IDENTITY(1,1),
		dblHistorySchedQuantity NUMERIC(18,6),
		strContractNumber NVARCHAR(20)
	)

	INSERT INTO @Contract
	SELECT *
	FROM
	(
		-- With not equal to 0 Scheduled Quantity
		SELECT SUM (dblTransactionQuantity) AS HistorySchedQuantity, C.strContractNumber
		FROM vyuCTSequenceUsageHistory    A
		INNER JOIN tblCTContractDetail  B ON A.intContractDetailId = B.intContractDetailId
		INNER JOIN tblCTContractHeader  C ON C.intContractHeaderId = B.intContractHeaderId
		INNER JOIN tblCTContractStatus    D ON D.intContractStatusId = B.intContractStatusId
		OUTER APPLY (SELECT TOP 1 CASE WHEN (dblOldValue - dblTransactionQuantity) < 0 AND dblNewValue = 0 THEN 'Unfix' ELSE 'Fixed' END AS strStatus FROM vyuCTSequenceUsageHistory WHERE intContractDetailId = B.intContractDetailId ORDER BY intSequenceUsageHistoryId DESC) E
		WHERE strFieldName ='Scheduled Quantity'
		AND B.dblScheduleQty <> 0
		AND D.strContractStatus = 'Open'
		GROUP BY C.strContractNumber,  B.intContractSeq , B.dblScheduleQty, D.strContractStatus,E.strStatus
		HAVING SUM (A.dblTransactionQuantity)  <>  B.dblScheduleQty

		UNION ALL
 
		 -- With 0 Scheduled Quantity
		SELECT SUM (dblTransactionQuantity) AS HistorySchedQuantity,C.strContractNumber
		FROM vyuCTSequenceUsageHistory A
		INNER JOIN tblCTContractDetail  B ON A.intContractDetailId = B.intContractDetailId
		INNER JOIN tblCTContractHeader  C ON C.intContractHeaderId = B.intContractHeaderId
		INNER JOIN tblCTContractStatus    D ON D.intContractStatusId = B.intContractStatusId
		OUTER APPLY (SELECT TOP 1 CASE WHEN (dblOldValue - dblTransactionQuantity) < 0 AND dblNewValue = 0 THEN 'Unfix' ELSE 'Fixed' END AS strStatus FROM vyuCTSequenceUsageHistory WHERE intContractDetailId = B.intContractDetailId ORDER BY intSequenceUsageHistoryId DESC) E
		WHERE strFieldName ='Scheduled Quantity'
		AND B.dblScheduleQty = 0
		AND D.strContractStatus = 'Open'
		GROUP BY C.strContractNumber,  B.intContractSeq , B.dblScheduleQty, D.strContractStatus, C.intContractHeaderId, E.strStatus 
		HAVING SUM (A.dblTransactionQuantity)  <>  B.dblScheduleQty
	) tbl

	DECLARE @strContractNumber NVARCHAR(20)
	DECLARE @dblHistorySchedQuantity NUMERIC(18,6)

	DECLARE @history TABLE 
	(  
		intSequenceUsageHistoryId INT,
		dblOldValue NUMERIC(18,6),
		dblTransactionQuantity NUMERIC(18,6),
		dblNewValue NUMERIC(18,6),
		intContractDetailId INT
	)

	DECLARE @intUniqueId INT
	SELECT	@intUniqueId = MIN(intUniqueId) FROM @Contract 
			 
	WHILE	ISNULL(@intUniqueId,0) > 0 
	BEGIN
	
		SELECT	@strContractNumber = strContractNumber, @dblHistorySchedQuantity = dblHistorySchedQuantity FROM @Contract WHERE intUniqueId = @intUniqueId

		INSERT INTO @history(intSequenceUsageHistoryId, dblOldValue, dblTransactionQuantity, dblNewValue, intContractDetailId)
		SELECT intSequenceUsageHistoryId,
		dblOldValue = (dblTransactionQuantity - SUM(dblTransactionQuantity) OVER (PARTITION BY a.intContractHeaderId, a.intContractDetailId ORDER BY a.intContractDetailId, a.intSequenceUsageHistoryId ASC)) *-1,
		dblTransactionQuantity, 
		dblNewValue = SUM(dblTransactionQuantity) OVER (PARTITION BY a.intContractHeaderId, a.intContractDetailId ORDER BY a.intContractDetailId, a.intSequenceUsageHistoryId ASC),
		a.intContractDetailId
		FROM tblCTSequenceUsageHistory a
		INNER JOIN tblCTContractHeader b ON a.intContractHeaderId = b.intContractHeaderId
		INNER JOIN tblCTContractDetail c ON a.intContractDetailId = c.intContractDetailId
		WHERE strFieldName = 'Scheduled Quantity'
		AND c.intContractStatusId = 1
		AND b.strContractNumber = @strContractNumber

		IF @dblHistorySchedQuantity < 0
		BEGIN
			UPDATE @history SET dblNewValue = 0 WHERE intSequenceUsageHistoryId = (SELECT TOP 1 intSequenceUsageHistoryId FROM @history ORDER BY intSequenceUsageHistoryId DESC)
		END

		UPDATE a SET dblOldValue = b.dblOldValue, dblNewValue = b.dblNewValue
		FROM tblCTSequenceUsageHistory a
		INNER JOIN @history b ON a.intSequenceUsageHistoryId = b.intSequenceUsageHistoryId
		INNER JOIN tblCTContractHeader c ON a.intContractHeaderId = c.intContractHeaderId

		UPDATE a SET dblScheduleQty = dblNewValue
		FROM tblCTSequenceHistory a
		INNER JOIN @history b ON a.intSequenceUsageHistoryId = b.intSequenceUsageHistoryId
		INNER JOIN tblCTContractHeader c ON a.intContractHeaderId = c.intContractHeaderId

		UPDATE a SET dblScheduleQty = b.dblNewValue
		FROM tblCTContractDetail a
		INNER JOIN (SELECT TOP 1 * FROM @history ORDER BY intSequenceUsageHistoryId DESC) b ON a.intContractDetailId = b.intContractDetailId

		DELETE FROM @history
	
		SELECT @intUniqueId = MIN(intUniqueId) FROM @Contract WHERE intUniqueId > @intUniqueId
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH