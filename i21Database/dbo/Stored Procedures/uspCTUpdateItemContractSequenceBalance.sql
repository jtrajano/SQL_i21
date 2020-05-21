CREATE PROCEDURE [dbo].[uspCTUpdateItemContractSequenceBalance]
	@intItemContractDetailId			INT,
	@dblQuantityToUpdate			NUMERIC(18,6),
	@intUserId						INT,
	@intExternalId					INT,
	@strScreenName					NVARCHAR(50),
	@ysnFromInvoice					bit = 0
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(18,6),
			@dblOldBalance			NUMERIC(18,6),
			@dblNewBalance			NUMERIC(18,6),
			@strAdjustmentNo		NVARCHAR(50),
			@dblTransactionQuantity	NUMERIC(18,6),
			@dblQuantityToIncrease	NUMERIC(18,6),
			@ysnCompleted			BIT	= 0,
			@dblTolerance			NUMERIC(18,6) = 0.0001,
			@intSequenceUsageHistoryId	INT,  
   			@intAllocatedPurchaseContractDetailId int
	
	BEGINING:

	SELECT	@dblQuantity			=	ISNULL(CD.dblContracted,0),
			@dblOldBalance			=	ISNULL(CD.dblBalance,0)

	FROM	tblCTItemContractDetail		CD
	JOIN	tblCTItemContractHeader		CH	ON	CH.intItemContractHeaderId	=	CD.intItemContractHeaderId 
	WHERE	intItemContractDetailId		=	@intItemContractDetailId 
		
	SELECT	@dblTransactionQuantity	=	- @dblQuantityToUpdate
	SELECT	@dblNewBalance			=	@dblOldBalance - @dblQuantityToUpdate

	IF @dblNewBalance < 0
	BEGIN
		IF ABS(@dblNewBalance) > @dblTolerance
		BEGIN
			RAISERROR('Balance cannot be less than zero.',16,1)
		END
		ELSE
		BEGIN
			SET @dblQuantityToUpdate =  @dblQuantityToUpdate + @dblNewBalance
			SET	@dblNewBalance		 =	@dblOldBalance - @dblQuantityToUpdate
		END
	END
	
	IF @dblNewBalance > @dblQuantity
	BEGIN
		IF @dblNewBalance > @dblQuantity +@dblTolerance
		BEGIN
			RAISERROR('Balance cannot be more than quantity.',16,1)
		END
		ELSE
		BEGIN
			SET @dblNewBalance = @dblQuantity
		END
	END
	
	IF @dblNewBalance = 0 
	BEGIN
		SET @ysnCompleted = 1
	END

	UPDATE	tblCTItemContractDetail
	SET		intConcurrencyId	=	intConcurrencyId + 1,
			dblBalance			=	@dblNewBalance, 
			intContractStatusId	=	CASE	WHEN @ysnCompleted = 0  
											THEN	CASE	WHEN intContractStatusId = 5 
															THEN 1 
															ELSE intContractStatusId 
													END 
											ELSE 5 
									END
	WHERE	intItemContractDetailId =	@intItemContractDetailId

	 /*
	 CT-4516
	 Check if the Sales Contract is allocated and get the Purchase Contract allocated on it and update the Status
	 considering the quantity is the same.
	 */ 
	set @intAllocatedPurchaseContractDetailId = (select intPContractDetailId from tblLGAllocationDetail where intSContractDetailId = @intItemContractDetailId);
	if (@intAllocatedPurchaseContractDetailId is not null and @intAllocatedPurchaseContractDetailId > 0)
	begin

	 UPDATE tblCTItemContractDetail  
	 SET  intConcurrencyId = intConcurrencyId + 1,   
	   intContractStatusId = CASE WHEN @ysnCompleted = 0    
	           THEN CASE WHEN intContractStatusId = 5   
	               THEN 1   
	               ELSE intContractStatusId   
	             END   
	           ELSE 5   
	         END  
	 WHERE intItemContractDetailId = @intAllocatedPurchaseContractDetailId

	end

/*
	EXEC	uspCTCreateSequenceUsageHistory 
			@intContractDetailId	=	@intItemContractDetailId,
			@strScreenName			=	@strScreenName,
			@intExternalId			=	@intExternalId,
			@strFieldName			=	'Balance',
			@dblOldValue			=	@dblOldBalance,
			@dblTransactionQuantity =	@dblTransactionQuantity,
			@dblNewValue			=	@dblNewBalance,	
			@intUserId				=	@intUserId,
			@dblBalance				=   @dblNewBalance,
			@intSequenceUsageHistoryId	=	@intSequenceUsageHistoryId	OUTPUT
	
	EXEC	uspCTCreateCollateralAdjustment
			@intContractDetailId	=	@intItemContractDetailId,
			@dblQuantityToUpdate	=	@dblQuantityToUpdate,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	@strScreenName

	EXEC	uspCTCreateDetailHistory	
			@intContractHeaderId		=	NULL,
			@intContractDetailId		=	@intItemContractDetailId,
			@strComment				    =	NULL,
			@intSequenceUsageHistoryId  =	@intSequenceUsageHistoryId,
			@strSource	 				= 	'Inventory',
			@strProcess 				= 	'Balance'
*/

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH