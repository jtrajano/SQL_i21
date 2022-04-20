CREATE PROCEDURE [dbo].[uspTMContractScheduleQty]
	@intDispatchId INT,
	@dblQuantity NUMERIC(18,6),
	@strScreenName NVARCHAR(100),
	@intContractDetailId INT = NULL,
	@intUserId INT = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	IF(@dblQuantity > 0)
	BEGIN
		-- IF POSITIVE QTY THEN ADD FROM SCHEDULED QTY
		DECLARE @dblBalance DECIMAL(18,6) = NULL

		SELECT @dblBalance = B.dblBalance
			FROM tblCTContractHeader A
			INNER JOIN vyuCTContractHeaderNotMapped H
				ON A.intContractHeaderId = H.intContractHeaderId
			INNER JOIN tblCTContractDetail B
				ON A.intContractHeaderId = B.intContractHeaderId
			WHERE B.intContractDetailId = @intContractDetailId

		IF(@dblBalance > 0)
		BEGIN
			IF(@dblQuantity > @dblBalance)
			BEGIN
				DECLARE @dblRemainingQty DECIMAL(18,6) = NULL
				SET @dblRemainingQty = @dblQuantity - (@dblQuantity - @dblBalance)
				
				EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
					, @dblQuantityToUpdate = @dblRemainingQty
					, @intUserId = @intUserId
					, @intExternalId = @intDispatchId
					, @strScreenName = @strScreenName
			END

		END
		ELSE
		BEGIN
			RAISERROR('Contract has 0 balance',16, 1)
		END
	END
	ELSE
	BEGIN
	 	-- IF NEGATIVE QTY THEN REMOVE FROM SCHEDULED QTY
		SELECT @intContractDetailId = intContractId
			, @dblQuantity = (dblQuantity - dblOverageQty) * -1
			, @intUserId = intUserID
		FROM tblTMDispatch WHERE intDispatchID = @intDispatchId

		EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
			, @dblQuantityToUpdate = @dblQuantity 
			, @intUserId = @intUserId
			, @intExternalId = @intDispatchId
			, @strScreenName = @strScreenName
	END
END