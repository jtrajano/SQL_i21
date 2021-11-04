CREATE PROCEDURE [dbo].[uspSCUpdateContractSchedule]
	@intContractDetailId INT
	,@dblQuantity NUMERIC(38,20)
	,@intUserId INT
	,@intExternalId INT
	,@strScreenName NVARCHAR(100)
AS
BEGIN 
	DECLARE @dblContractScheduleQuantity NUMERIC(38,20)
	DECLARE @ysnContractLoadBase BIT
	DECLARE @dblUpdateQty NUMERIC(38,20)
	DECLARE @dblContractAvailableQuantity NUMERIC(38,20)

	--get contract details
	SELECT TOP 1 
		@dblContractScheduleQuantity = A.dblScheduleQty
		,@ysnContractLoadBase = ISNULL(B.ysnLoad,0)
		,@dblContractAvailableQuantity = ISNULL(A.dblBalance,0)- ISNULL(A.dblScheduleQty,0)
	FROM tblCTContractDetail A
	INNER JOIN tblCTContractHeader  B
		ON A.intContractHeaderId = B.intContractHeaderId
	WHERE A.intContractDetailId = @intContractDetailId

	IF(@dblQuantity < 0)
	BEGIN
		IF @dblContractScheduleQuantity >= ABS(@dblQuantity)
		BEGIN
			SET @dblUpdateQty = @dblQuantity
		END
		ELSE
		BEGIN
			SET @dblUpdateQty = @dblContractScheduleQuantity * -1
		END	

		IF @ysnContractLoadBase = 1
		BEGIN
			SET @dblQuantity = -1
		END
	END
	ELSE
	BEGIN
		IF(@dblContractAvailableQuantity >= @dblQuantity)
		BEGIN
			SET	@dblUpdateQty = @dblQuantity
		END
		ELSE
		BEGIN
			SET @dblUpdateQty = @dblContractAvailableQuantity
		END
	END

	IF(@dblUpdateQty <> 0)
	BEGIN
		EXEC uspCTUpdateScheduleQuantity
			@intContractDetailId	=	@intContractDetailId,
			@dblQuantityToUpdate	=	@dblUpdateQty,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	@strScreenName
	END
END
