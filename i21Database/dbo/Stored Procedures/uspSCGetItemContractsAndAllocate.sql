CREATE PROCEDURE uspSCGetItemContractsAndAllocate

	@intTicketId				INT,
	@intEntityId				INT,
	@dblNetUnits				NUMERIC(18,6),
	@intItemContractDetailId	INT,
	@intUserId					INT
AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strContractStatus NVARCHAR(20)
	DECLARE @intItemContractStatus INT
	DECLARE @dblDistributedUnits NUMERIC(18,6)
	DECLARE @dblRemainingUnits NUMERIC(18,6)
	DECLARE @dblCost NUMERIC(18,6)
	DECLARE @intContractHeaderId INT
	DECLARE @dblItemContractAvailable NUMERIC(18,6)
	DECLARE @intItemContractCurrencyId INT

	SET @dblRemainingUnits = @dblNetUnits
	SET @dblDistributedUnits = @dblNetUnits
	IF	ISNULL(@intItemContractDetailId,0) > 0
	BEGIN
		SET @strContractStatus = NULL
		SELECT TOP 1 
			@strContractStatus = A.strContractStatus
			,@intItemContractStatus = A.intContractStatusId
			,@intItemContractCurrencyId = B.intCurrencyId
			,@dblCost = A.dblPrice
		FROM vyuCTItemContractDetail A
		INNER JOIN tblCTItemContractHeader B 
			ON A.intItemContractHeaderId = B.intItemContractHeaderId
		WHERE intItemContractDetailId =	@intItemContractDetailId 

		IF	(@intItemContractStatus IS NOT NULL AND @intItemContractStatus <> 1)
		BEGIN
			SET @ErrMsg = 'Using of Item contract having status '''+ @strContractStatus +''' is not allowed.'
			RAISERROR(@ErrMsg,16,1)
		END
	END

	SET @dblRemainingUnits = @dblRemainingUnits - @dblDistributedUnits

	SELECT 
		intTicketId = @intTicketId
		,intItemContractDetailId = @intItemContractDetailId
		,dblUnitsDistributed = @dblDistributedUnits
		,dblUnitsRemaining = @dblRemainingUnits
		,dblCost = @dblCost
		,intCurrencyId = @intItemContractCurrencyId
	


	--IF	((SELECT	MAX(dblUnitsRemaining) 
	--	 FROM	@Processed	PR
	--	 JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	PR.intContractDetailId
	--	 WHERE	ISNULL(ysnIgnore,0) <> 1) > 0
	--	OR NOT EXISTS(SELECT TOP 1 1 FROM @Processed WHERE ISNULL(ysnIgnore,0) <> 1)) 
	--	AND @ysnAutoDistribution = 1
	--BEGIN
	--	RAISERROR ('The entire ticket quantity cannot be applied to the item contract.',16,1,'WITH NOWAIT') 
	--END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
