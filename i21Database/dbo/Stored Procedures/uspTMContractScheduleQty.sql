CREATE PROCEDURE [dbo].[uspTMContractScheduleQty]
	@intSiteId INT,
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
					, @intExternalId = @intSiteId
					, @strScreenName = @strScreenName
			END
			ELSE
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
					, @dblQuantityToUpdate = @dblQuantity
					, @intUserId = @intUserId
					, @intExternalId = @intSiteId
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
		SELECT @intContractDetailId = O.intContractDetailId  
			, @dblQuantity = O.dblQuantity * -1
			, @intUserId = D.intUserID
		FROM tblTMOrder O 
		INNER JOIN tblTMDispatch D ON D.intDispatchID = O.intDispatchId AND D.intContractId = O.intContractDetailId
		WHERE D.intSiteID = @intSiteId

		IF(@intContractDetailId IS NOT NULL)
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM tblCTSequenceUsageHistory WHERE intContractDetailId = @intContractDetailId
			AND strScreenName = @strScreenName
			AND strFieldName = 'Scheduled Quantity'
			AND intExternalId = @intSiteId 
			--AND dblTransactionQuantity = @dblQuantity
			)
			BEGIN
				EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intContractDetailId
					, @dblQuantityToUpdate = @dblQuantity 
					, @intUserId = @intUserId
					, @intExternalId = @intSiteId
					, @strScreenName = @strScreenName
			END
		END

	END
END