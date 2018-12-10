CREATE PROCEDURE [dbo].[uspCTUpdateExistingSequenceHistory]

AS

DECLARE		@intContractDetailId	INT,
			@intSequenceHistoryId	iNT,
			@intPrevHistoryId		iNT,
			@dblPrevQty				NUMERIC(18,6),
			@dblPrevBal				NUMERIC(18,6),
			@intPrevStatusId		INT,
			@dblQuantity			NUMERIC(18,6),
			@dblBalance				NUMERIC(18,6),
			@intContractStatusId	INT

DECLARE  @tblToProcess TABLE
(
	intContractDetailId INT PRIMARY KEY
)

INSERT INTO @tblToProcess
SELECT DISTINCT CD.intContractDetailId FROM tblCTContractDetail CD
JOIN tblCTSequenceHistory CH ON CH.intContractDetailId = CD.intContractDetailId 
--WHERE CD.intContractDetailId >= 248
ORDER BY 1
--SElECT * FROM @tblToProcess
SELECT @intContractDetailId = MIN(intContractDetailId) FROM @tblToProcess 

WHILE ISNULL(@intContractDetailId,0) > 0
BEGIN
	SELECT	@intPrevHistoryId = NULL 
	SELECT	@intSequenceHistoryId = MIN(intSequenceHistoryId) FROM tblCTSequenceHistory WHERE intContractDetailId = @intContractDetailId

	WHILE ISNULL(@intSequenceHistoryId,0) > 0
	BEGIN
		IF @intPrevHistoryId IS NULL
		BEGIN
			SELECT	@dblPrevQty = dblQuantity,@dblPrevBal = dblBalance,@intPrevStatusId = intContractStatusId FROM tblCTSequenceHistory WHERE intSequenceHistoryId = @intSequenceHistoryId
			SELECT @intPrevHistoryId = @intSequenceHistoryId
			SELECT @intSequenceHistoryId = MIN(intSequenceHistoryId) FROM tblCTSequenceHistory WHERE intContractDetailId = @intContractDetailId AND intSequenceHistoryId > @intSequenceHistoryId
			CONTINUE
		END
		ELSE
		BEGIN
			SELECT	@dblPrevQty = dblQuantity,@dblPrevBal = dblBalance,@intPrevStatusId = intContractStatusId FROM tblCTSequenceHistory WHERE intSequenceHistoryId = @intPrevHistoryId
			SELECT	@dblQuantity = dblQuantity,@dblBalance = dblBalance,@intContractStatusId = intContractStatusId FROM tblCTSequenceHistory WHERE intSequenceHistoryId = @intSequenceHistoryId

			IF ISNULL(@dblPrevQty,0) <> ISNULL(@dblQuantity,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET dblOldQuantity = @dblPrevQty,ysnQtyChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END
			IF ISNULL(@dblPrevBal,0) <> ISNULL(@dblBalance,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET dblOldBalance = @dblPrevBal,ysnBalanceChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END
			IF ISNULL(@intPrevStatusId,0) <> ISNULL(@intContractStatusId,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET intOldStatusId = @intPrevStatusId,ysnStatusChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END
		END
		SELECT @intPrevHistoryId = @intSequenceHistoryId
		SELECT @intSequenceHistoryId = MIN(intSequenceHistoryId) FROM tblCTSequenceHistory WHERE intContractDetailId = @intContractDetailId AND intSequenceHistoryId > @intSequenceHistoryId
	END
	SELECT @intContractDetailId = MIN(intContractDetailId) FROM @tblToProcess WHERE intContractDetailId > @intContractDetailId
END
