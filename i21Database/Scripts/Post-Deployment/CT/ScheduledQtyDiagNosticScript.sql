
IF EXISTS ( SELECT TOP 1 1
			FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[uspTmpGetRunningSchedule]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[uspTmpGetRunningSchedule]
END
GO

CREATE PROCEDURE [dbo].[uspTmpGetRunningSchedule]
	@intContractDetailId INT
	,@ysnGenerateTable BIT = 0
AS 

BEGIN

	DECLARE @dtmLatestTransaction DATETIME
	DECLARE @dblRunningSchedule NUMERIC(18,6)
	DECLARE @intSequenceUsageHistoryId INT
	DECLARE @strScreenName NVARCHAR(50)
	DECLARE @_dblTransactionQty NUMERIC(18,6)

	DECLARE @intExternalHeaderId INT
	DECLARE @dblLoadQuantity NUMERIC(18,6)
	DECLARE @intTicketId INT
	DECLARE @intTicketContractDetailId INT
	DECLARE @strTransaction NVARCHAR(50)
	DECLARE @intId INT
	dECLARE @intTicketLoadDetailId INT
	dECLARE @strNote NVARCHAR(500)
	DECLARE @dblRunningSchedule2 NUMERIC(18,6)
	DECLARE @dblTicketLoadUsedQty NUMERIC(18,6)

	--DECLARE @intContractDetailId INT
	--SET @intContractDetailId = 822

	IF OBJECT_ID (N'tempdb.dbo.#tmpTransaction') IS NOT NULL DROP TABLE #tmpTransaction
	CREATE TABLE #tmpTransaction (
			intRow INT IDENTITY(1,1)
			,intSequenceUsageHistoryId INT
			,strTransactionType NVARCHAR (50)
			,strTransaction NVARCHAR (50)
			,dblTransactionQty NUMERIC(18,6)
			,dblLoadUsedQuantity NUMERIC(18,6)
			,dblRunningSchedule NUMERIC(18,6)
			,dblRunningSchedule2 NUMERIC(18,6)
			,strNote NVARCHAR (500)

		)

	IF OBJECT_ID (N'tempdb.dbo.#tmpCTHistoryTran') IS NOT NULL DROP TABLE #tmpCTHistoryTran

	SELECT 
		ROW_NUMBER() OVER(ORDER BY dtmTransactionDate ASC) AS intId,
		*
	INTO #tmpCTHistoryTran
	FROM vyuCTSequenceUsageHistory
	WHERE intContractDetailId = @intContractDetailId
		--AND strScreenName IN ('Inventory Shipment','Inventory Receipt','Load Schedule','Scale')
		AND strFieldName = 'Scheduled Quantity'
	ORDER BY dtmTransactionDate ASC

	SELECT TOP 1 
		@intId = MIN(intId)
	FROM #tmpCTHistoryTran

	SET @dblRunningSchedule = 0
	SET @dblRunningSchedule2 = 0

	WHILE ISNULL(@intId,0) > 0
	BEGIN
	
		SELECT @intSequenceUsageHistoryId = intSequenceUsageHistoryId
		FROM #tmpCTHistoryTran
		WHERE intId = @intId

		SELECT TOP 1 
			 @_dblTransactionQty = ISNULL(HT.dblTransactionQuantity,0)
			,@strScreenName = HT.strScreenName
			,@intExternalHeaderId = HT.intExternalHeaderId
			,@strTransaction = HT.strNumber
		FROM #tmpCTHistoryTran HT
		INNER JOIN tblCTContractHeader CH ON HT.intContractHeaderId = CH.intContractHeaderId
		WHERE HT.intSequenceUsageHistoryId = @intSequenceUsageHistoryId

		-- Load schedule
		IF(@strScreenName = 'Load Schedule')
		BEGIN
			SET @dblRunningSchedule = @dblRunningSchedule + @_dblTransactionQty
			SET @dblRunningSchedule2 = @dblRunningSchedule2 + @_dblTransactionQty
			print @strTransaction

			INSERT INTO #tmpTransaction(
				intSequenceUsageHistoryId
				,strTransactionType
				,strTransaction
				,dblTransactionQty
				,dblLoadUsedQuantity
				,dblRunningSchedule
				,dblRunningSchedule2
				,strNote
			)
			SELECT 
				intSequenceUsageHistoryId = @intSequenceUsageHistoryId
				,strTransactionType = @strScreenName
				,strTransaction = @strTransaction
				,dblTransactionQty = @_dblTransactionQty
				,dblLoadUsedQuantity = @_dblTransactionQty
				,dblRunningSchedule = @dblRunningSchedule
				,dblRunningSchedule2 = @dblRunningSchedule2
				,strNote = ''
		END

		-- Scale ticket
		ELSE IF(@strScreenName = 'Scale')
		BEGIN
			IF EXISTS
			(
				SELECT TOP 1 1
				FROM tblSCTicket A
				INNER JOIN tblCTSequenceUsageHistory B
					ON A.intTicketId = ISNULL(B.intExternalId,0)
				INNER JOIN vyuCTSequenceUsageHistory C
					ON B.intSequenceUsageHistoryId = C.intSequenceUsageHistoryId
				WHERE C.intSequenceUsageHistoryId = @intSequenceUsageHistoryId
					AND A.strDistributionOption = 'CNT'
					AND A.strTicketStatus = 'O'
			)
			BEGIN
			
				SELECT TOP 1 
					@intTicketId = A.intTicketId
					,@intTicketContractDetailId = A.intContractId
					,@dblLoadQuantity = D.dblQuantity
				FROM tblSCTicket A
				INNER JOIN tblCTSequenceUsageHistory B
					ON A.intTicketId = ISNULL(B.intExternalId,0)
				INNER JOIN vyuCTSequenceUsageHistory C
					ON B.intSequenceUsageHistoryId = C.intSequenceUsageHistoryId
				LEFT JOIN tblLGLoadDetail D
					ON ISNULL(A.intLoadDetailId,0) = D.intLoadDetailId
				WHERE C.intSequenceUsageHistoryId = @intSequenceUsageHistoryId
			
				IF @intTicketContractDetailId = @intContractDetailId
				BEGIn
					SET @dblRunningSchedule = @dblRunningSchedule + @_dblTransactionQty
					SET @dblRunningSchedule2 = @dblRunningSchedule2 + @_dblTransactionQty
				END

				
			END

			INSERT INTO #tmpTransaction(
					intSequenceUsageHistoryId
					,strTransactionType
					,strTransaction
					,dblTransactionQty
					,dblLoadUsedQuantity
					,dblRunningSchedule
					,dblRunningSchedule2
					,strNote
				)
			SELECT 
				intSequenceUsageHistoryId = @intSequenceUsageHistoryId
				,strTransactionType = @strScreenName
				,strTransaction = @strTransaction
				,dblTransactionQty = @_dblTransactionQty
				,dblLoadUsedQuantity = @dblLoadQuantity
				,dblRunningSchedule = @dblRunningSchedule
				,dblRunningSchedule2 = @dblRunningSchedule2
				,strNote = ''

		END

		-- Inventory shipment/receipt
		ELSE IF(@strScreenName IN ('Inventory Shipment', 'Inventory Receipt'))
		BEGIN
			SET @strNote = ''
			SET @dblLoadQuantity = 0
			--Get ticket details
			BEGIN

				IF @strScreenName = 'Inventory Receipt' -- Purchase
				BEGIN
					SELECT TOP 1 
						@intTicketId = C.intTicketId
						,@intTicketContractDetailId = C.intContractId
						,@dblLoadQuantity = ISNULL(D.dblQuantity,0)
						,@intTicketContractDetailId = ISNULL(C.intContractId,0)
					FROM tblICInventoryReceipt A
					INNER JOIN tblICInventoryReceiptItem B
						ON A.intInventoryReceiptId = B.intInventoryReceiptId
					INNER JOIN tblSCTicket C
						ON ISNULL(B.intSourceId,0) = C.intTicketId
					LEFT JOIN tblLGLoadDetail D
						ON ISNULL(C.intLoadDetailId,0) = D.intLoadDetailId
					LEFT JOIN (
						SELECT TOP 1
							AA.intTicketId
							,BB.dblQuantity
						FROM tblSCTicketLoadUsed AA
						INNER JOIN tblLGLoadDetail BB
							ON AA.intLoadDetailId = BB.intLoadDetailId
						WHERE AA.intTicketId = @intTicketId		
							AND AA.dblQty = -@_dblTransactionQty 
							AND BB.intPContractDetailId = @intContractDetailId
					) E
						ON C.intTicketId = E.intTicketId
					WHERE A.intInventoryReceiptId = @intExternalHeaderId


					SET @dblTicketLoadUsedQty = ISNULL((
															SELECT TOP 1 
																ISNULL(A.dblQty,0)
															FROM tblSCTicketLoadUsed A
															INNER JOIN tblLGLoadDetail B
																ON A.intLoadDetailId = B.intLoadDetailId
															WHERE A.intTicketId = @intTicketId 
																AND A.dblQty = -@_dblTransactionQty 
																AND B.intPContractDetailId = @intContractDetailId
														),0)
				END
				ELSE
				BEGIN
					SELECT TOP 1 
						@intTicketId = C.intTicketId
						,@dblLoadQuantity = ISNULL(E.dblQuantity,ISNULL(D.dblQuantity,0))
						,@intTicketContractDetailId = ISNULL(C.intContractId,0)
					FROM tblICInventoryShipment A
					INNER JOIN tblICInventoryShipmentItem B
						ON A.intInventoryShipmentId = B.intInventoryShipmentId
					INNER JOIN tblSCTicket C
						ON ISNULL(B.intSourceId,0) = C.intTicketId
					LEFT JOIN tblLGLoadDetail D
						ON ISNULL(C.intLoadDetailId,0) = D.intLoadDetailId
					LEFT JOIN (
						SELECT TOP 1
							AA.intTicketId
							,BB.dblQuantity
						FROM tblSCTicketLoadUsed AA
						INNER JOIN tblLGLoadDetail BB
							ON AA.intLoadDetailId = BB.intLoadDetailId
						WHERE AA.intTicketId = @intTicketId		
							AND AA.dblQty = -@_dblTransactionQty 
							AND BB.intSContractDetailId = @intContractDetailId
					) E
						ON C.intTicketId = E.intTicketId
					WHERE A.intInventoryShipmentId = @intExternalHeaderId

					SET @dblTicketLoadUsedQty = ISNULL((
															SELECT TOP 1 
																ISNULL(A.dblQty,0)
															FROM tblSCTicketLoadUsed A
															INNER JOIN tblLGLoadDetail B
																ON A.intLoadDetailId = B.intLoadDetailId
															WHERE A.intTicketId = @intTicketId 
																AND A.dblQty = -@_dblTransactionQty 
																AND B.intSContractDetailId = @intContractDetailId
														),0)
				END
			END

			IF @intTicketContractDetailId = @intContractDetailId
			BEGIN
			

				-- subtract IS quantity if it is greater than the quantity of the load used
				IF(ABS(@_dblTransactionQty) > @dblLoadQuantity AND @_dblTransactionQty < 0 AND @dblLoadQuantity > 0)
				BEGIN
					SET @dblRunningSchedule = @dblRunningSchedule + @_dblTransactionQty		
				END
				ELSE -- subtract the quantity of the load used
				BEGIN
					IF(@_dblTransactionQty > 0)
					BEGIN
						SET @dblRunningSchedule = @dblRunningSchedule + @dblLoadQuantity		
					END
					ELSE IF @dblTicketLoadUsedQty > 0 -- if record exists in ticketloadused table
					BEGIN
						SET @dblRunningSchedule = @dblRunningSchedule - @dblLoadQuantity	
					END
					ELSE
					BEGIN
						IF EXISTS(SELECT TOP 1 1 
									FROM tblSCTicketContractUsed 
									WHERE intTicketId = @intTicketId
										AND intContractDetailId = @intContractDetailId
										AND dblScheduleQty = ABS(@_dblTransactionQty))
						BEGIN
							SET @strNote = @strTransaction + ' no schedule movement - contract distribution'
						END
						ELSE
						BEGIN
							IF(ISNULL(@dblLoadQuantity,0) > 0)
							BEGIN
								SET @dblRunningSchedule = @dblRunningSchedule - @dblLoadQuantity		
							END
							ELSE
							BEGIN
								SET @strNote = @strTransaction + ' no Corresponding Load'
							END
						END
						
					END
				END
			END
			ELSE
			BEGIN
				SET @strNote = @strTransaction + ' no schedule movement - overage from other transaction or Deleted IS'
				--print @strTransaction + ' no schedule movement - overage from other transaction'
			END

			--Check if running schedule is less than zero
			IF @dblRunningSchedule < 0
			BEGIN
				SET @dblRunningSchedule = 0
			END

			SET @dblRunningSchedule2 = @dblRunningSchedule2 + @_dblTransactionQty

			IF @intTicketContractDetailId = @intContractDetailId
			BEGIN
				INSERT INTO #tmpTransaction(
					intSequenceUsageHistoryId
					,strTransactionType
					,strTransaction
					,dblTransactionQty
					,dblLoadUsedQuantity
					,dblRunningSchedule
					,dblRunningSchedule2
					,strNote
				)
				SELECT 
					intSequenceUsageHistoryId = @intSequenceUsageHistoryId
					,strTransactionType = @strScreenName
					,strTransaction = @strTransaction
					,dblTransactionQty = @_dblTransactionQty
					,dblLoadUsedQuantity = @dblLoadQuantity
					,dblRunningSchedule = @dblRunningSchedule
					,dblRunningSchedule2 = @dblRunningSchedule2
					,strNote = @strNote
			END
			ELSE
			BEGIN
				INSERT INTO #tmpTransaction(
					intSequenceUsageHistoryId
					,strTransactionType
					,strTransaction
					,dblTransactionQty
					,dblLoadUsedQuantity
					,dblRunningSchedule
					,dblRunningSchedule2
					,strNote
				)
				SELECT 
					intSequenceUsageHistoryId = @intSequenceUsageHistoryId
					,strTransactionType = @strScreenName
					,strTransaction = @strTransaction
					,dblTransactionQty = @_dblTransactionQty
					,dblLoadUsedQuantity = @dblLoadQuantity
					,dblRunningSchedule = @dblRunningSchedule
					,dblRunningSchedule2 = @dblRunningSchedule2
					,strNote = @strNote
			END
		END	
		ELSE
		BEGIN
			INSERT INTO #tmpTransaction(
				intSequenceUsageHistoryId
				,strTransactionType
				,strTransaction
				,dblTransactionQty
				,dblLoadUsedQuantity
				,dblRunningSchedule
				,dblRunningSchedule2
				,strNote
			)
			SELECT 
				intSequenceUsageHistoryId = @intSequenceUsageHistoryId
				,strTransactionType = @strScreenName
				,strTransaction = @strTransaction
				,dblTransactionQty = @_dblTransactionQty
				,dblLoadUsedQuantity = @_dblTransactionQty
				,dblRunningSchedule = @dblRunningSchedule
				,dblRunningSchedule2 = @dblRunningSchedule2
				,strNote = 'No Calculation'	
		END

		print @dblRunningSchedule

		-- Loop iteration
		BEGIN
			SET @intId = ISNULL((SELECT MIN(intId)
													 FROM #tmpCTHistoryTran
													 WHERE intId > @intId)
													,0)
		END
	END

	SELECT 
		dblRunningSchedule = @dblRunningSchedule
		,dblContractDetailId = @intContractDetailId

	if(@ysnGenerateTable = 1)
	BEGIN
		SELECT * FROM #tmpTransaction
	END

END

GO

DECLARE @intContractDetailId INT


IF OBJECT_ID (N'tempdb.dbo.#tmpTotalRunningSchedule') IS NOT NULL DROP TABLE #tmpTotalRunningSchedule
CREATE TABLE #tmpTotalRunningSchedule (
		intContractDetailId INT
		,dblRunningSchedule NUMERIC(18,6)
		,dblRunningSchedule2 NUMERIC(18,6)
)


SELECT TOP 1
	@intContractDetailId = MIN(intContractDetailId)
FROM vyuCTContractDetailView
WHERE ISNULL(ysnLoad,0) = 0
	AND intContractStatusId =1


WHILE (ISNULL(@intContractDetailId,0) > 0)
BEGIN
	IF OBJECT_ID (N'tempdb.dbo.#tmpTransaction1') IS NOT NULL DROP TABLE #tmpTransaction1
	CREATE TABLE #tmpTransaction1 (
			intRow INT IDENTITY(1,1)
			,intContractDetailId INT
			,intSequenceUsageHistoryId INT
			,strTransactionType NVARCHAR (50)
			,strTransaction NVARCHAR (50)
			,dblTransactionQty NUMERIC(18,6)
			,dblLoadUsedQuantity NUMERIC(18,6)
			,dblRunningSchedule NUMERIC(18,6)
			,dblRunningSchedule2 NUMERIC(18,6)
			,strNote NVARCHAR (500)

	)
	DELETE FROM #tmpTransaction1
	INSERT INTO #tmpTransaction1 (
			dblRunningSchedule 
			,intContractDetailId 
			
	)
	EXEC [uspTmpGetRunningSchedule] @intContractDetailId

	INSERT INTO #tmpTotalRunningSchedule(
		intContractDetailId
		,dblRunningSchedule
		,dblRunningSchedule2
	)
	SELECT TOP 1
		intContractDetailId 
		,ISNULL(dblRunningSchedule,0)
		,ISNULL(dblRunningSchedule2,0)
	FROM #tmpTransaction1
	ORDER BY intRow DESC
	
	--Loop iterator
	BEGIN
		
		SET @intContractDetailId = ISNULL((
											SELECT TOP 1
												ISNULL(intContractDetailId,0)
											FROM vyuCTContractDetailView
											WHERE ISNULL(ysnLoad,0) = 0
												AND intContractDetailId > @intContractDetailId
												AND intContractStatusId =1
											ORDER BY intContractDetailId ASC),0)
	END
END


SELECT
	A.strContractNumber
	,A.intContractHeaderId
	,B.intContractDetailId
	,[Sequence] = B.intContractSeq
    , ContractType = case when A.intContractTypeId = 1 then 'Purchase' else 'Sale' end 
	,SeqSchedule = ISNULL(B.dblScheduleQty,0)
	,ComputedRunning = C.dblRunningSchedule
	,[NewValue History] = D.dblNewValue
	,HistoryTotal = ISNULL(E.dblQuantity,0)
FROM tblCTContractHeader A
INNER JOIN tblCTContractDetail B
	ON A.intContractHeaderId = B.intContractHeaderId
INNER JOIN #tmpTotalRunningSchedule C
	ON B.intContractDetailId = C.intContractDetailId
OUTER APPLY (
	SELECT TOP 1
		intContractDetailId 
		,dblNewValue
	FROM vyuCTSequenceUsageHistory
	WHERE intContractDetailId = B.intContractDetailId
	ORDER BY dtmTransactionDate DESC
)D
OUTER APPLY (
	SELECT  
		intContractDetailId 
		,dblQuantity = SUM(ISNULl(dblTransactionQuantity,0)) 
	FROM vyuCTSequenceUsageHistory
	WHERE intContractDetailId = B.intContractDetailId
	GROUP BY intContractDetailId
)E
WHERE 
	(B.dblScheduleQty <> C.dblRunningSchedule )
	 --B.dblScheduleQty <> D.dblNewValue
	--OR C.dblRunningSchedule <> D.dblNewValue)
AND ISNULL(A.ysnLoad,0) = 0
