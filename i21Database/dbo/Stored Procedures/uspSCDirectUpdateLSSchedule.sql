CREATE PROCEDURE [dbo].[uspSCDirectUpdateLSSchedule]
	@intLoadDetailId INT
	,@intContractDetailId INT
	,@intUserId INT
	,@intTicketId INT
	,@ysnAddSchedule BIT = 0
AS
BEGIN
	DECLARE @dblLoadQuantity NUMERIC(38,20)
	DECLARE @intLoadItemUOMId INT
	DECLARE @dblLoadContractUOMQuantity NUMERIC(38,20)
	DECLARE @intContractItemUOMId INT

	SELECT TOP 1
		@dblLoadQuantity = dblQuantity
		,@intLoadItemUOMId = intItemUOMId
	FROM tblLGLoadDetail
	WHERE intLoadDetailId = @intLoadDetailId


	--get contract details
	SELECT TOP 1 
		@intContractItemUOMId = intItemUOMId
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intContractDetailId

	SET @dblLoadContractUOMQuantity = dbo.fnCalculateQtyBetweenUOM(@intLoadItemUOMId,@intContractItemUOMId,@dblLoadQuantity)

	IF(@ysnAddSchedule = 0)
	BEGIN
		SET @dblLoadContractUOMQuantity = @dblLoadContractUOMQuantity * -1
	END
	ELSE
	BEGIN
		SET @dblLoadContractUOMQuantity = @dblLoadContractUOMQuantity
	END

	EXEC uspSCUpdateContractSchedule
			@intContractDetailId = @intContractDetailId
			,@dblQuantity = @dblLoadContractUOMQuantity
			,@intUserId = @intUserId
			,@intExternalId = @intTicketId
			,@strScreenName = 'Scale'
	
	
END
GO



