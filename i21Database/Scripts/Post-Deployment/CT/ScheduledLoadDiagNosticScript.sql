--EXEC [uspTmpGetRunningSchedule] 1620,1
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

	
IF OBJECT_ID (N'tempdb.dbo.#tmpTransTable') IS NOT NULL DROP TABLE #tmpTransTable
CREATE TABLE #tmpTransTable (
		intRow INT IDENTITY(1,1)
		,dblTransQty NUMERIC(18,6)
		,dtmTransDate DATETIME
		,strTransType NVARCHAR(50)
		,strTransNumber NVARCHAR(100)
)



DECLARE @dblRunningSchedule NUMERIC(18,6)

SET @dblRunningSchedule = 0



---Load Schedule
BEGIN
	INSERT INTO #tmpTransTable(
		dblTransQty 
		,dtmTransDate 
		,strTransType 
		,strTransNumber
	)
	SELECT 
		1
		,B.dtmScheduledDate
		,'Load Schedule'
		,B.strLoadNumber
	FROM tblLGLoadDetail A
	INNER JOIN tblLGLoad B
		ON A.intLoadId = B.intLoadId
	WHERE intSContractDetailId = @intContractDetailId 
		AND B.intShipmentStatus = 1 --Scheduled
		
END


--SCALE
BEGIN
	INSERT INTO #tmpTransTable(
		dblTransQty 
		,dtmTransDate 
		,strTransType 
		,strTransNumber
	)
	SELECT 
		1
		,dtmTicketDateTime
		,'Scale'
		,strTicketNumber
	FROM tblSCTicket
	WHERE intContractId = @intContractDetailId 
		AND strTicketStatus = 'O'
		AND strDistributionOption = 'CNT'

END

--Inventory Shipment
BEGIN
	--SET @dblRunningSchedule = @dblRunningSchedule - @dblICTotalQuantity
	INSERT INTO #tmpTransTable(
		dblTransQty 
		,dtmTransDate 
		,strTransType 
		,strTransNumber
	)
	SELECT 
		-1
		,A.dtmShipDate
		,'Inventory Shipment'
		,A.strShipmentNumber
	FROM tblICInventoryShipment A
	INNER JOIN tblICInventoryShipmentItem B
		ON A.intInventoryShipmentId = B.intInventoryShipmentId
	INNER JOIN tblSCTicket C
		ON B.intSourceId = C.intTicketId
	INNER JOIN tblLGLoadDetail D
		ON C.intLoadDetailId = D.intLoadDetailId
	WHERE B.intLineNo = @intContractDetailId
		AND A.intSourceType = 1
		AND D.intSContractDetailId = @intContractDetailId
END


--Inventory Receipt
BEGIN
	INSERT INTO #tmpTransTable(
		dblTransQty 
		,dtmTransDate 
		,strTransType 
		,strTransNumber
	)
	SELECT 
		-1
		,A.dtmReceiptDate
		,'Inventory Shipment'
		,A.strReceiptNumber
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblSCTicket C
		ON B.intSourceId = C.intTicketId
	INNER JOIN tblLGLoadDetail D
		ON C.intLoadDetailId = D.intLoadDetailId
	WHERE B.intLineNo = @intContractDetailId
		AND A.intSourceType = 1
		AND D.intPContractDetailId = @intContractDetailId
END


SELECT 
	dblRunningSchedule = SUM(dblTransQty)
	,intContractDetailId = @intContractDetailId
FROM #tmpTransTable
		
IF(@ysnGenerateTable = 1)
BEGIN
	SELECT * FROM #tmpTransTable
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
WHERE ISNULL(ysnLoad,0) = 1
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
	, [Sequence] = B.intContractSeq
    , ContractType = case when A.intContractTypeId = 1 then 'Purchase' else 'Sale' end 
	,SeqSchedule = ISNULL(B.dblScheduleLoad,0)
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
	(B.dblScheduleLoad <> C.dblRunningSchedule )
	 --B.dblScheduleQty <> D.dblNewValue
	--OR C.dblRunningSchedule <> D.dblNewValue)
AND ISNULL(A.ysnLoad,0) = 1
