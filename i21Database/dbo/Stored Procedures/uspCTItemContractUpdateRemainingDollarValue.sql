CREATE PROCEDURE [dbo].[uspCTItemContractUpdateRemainingDollarValue]

	@intItemContractHeaderId	INT, 
	@dblValueToUpdate			NUMERIC(18,6),
	@intUserId					INT,
	@intTransactionDetailId		INT,
	@strScreenName				NVARCHAR(50)

AS

BEGIN TRY
	
	DECLARE 
			@strItemContractNumber		NVARCHAR(50),
			@dblDollarValue				numeric(18,6),
			@dblRemainingDollarValue	numeric(18,6),
			@dblNewRemainingDollarValue	numeric(18,6),
			@ErrMsg						NVARCHAR(MAX)

	IF NOT EXISTS(select * from tblCTItemContractHeader where intItemContractHeaderId = @intItemContractHeaderId)
	BEGIN
		set @ErrMsg = 'Item contract is deleted by other user.';
		RAISERROR(@ErrMsg,16,1)
	END 	

	BEGINING:

	SELECT
		@strItemContractNumber = H.strContractNumber
		,@dblDollarValue = isnull(H.dblDollarValue,0)
		,@dblRemainingDollarValue = isnull(H.dblRemainingDollarValue,0)
	FROM
		tblCTItemContractHeader H
	WHERE
		H.intItemContractHeaderId = @intItemContractHeaderId

	SET @dblNewRemainingDollarValue = @dblRemainingDollarValue + @dblValueToUpdate;

	-- VALIDATION #1
	IF (@dblNewRemainingDollarValue < 0)
	BEGIN
		set @ErrMsg = 'Available amount for the item contract ' + @strItemContractNumber + ' is ' + convert(nvarchar(50),@dblRemainingDollarValue) + ', which is insufficient for this transaction.';
		RAISERROR(@ErrMsg,16,1)
	END

	-- VALIDATION #2
	IF	(@dblNewRemainingDollarValue > @dblDollarValue)
	BEGIN
		SET @ErrMsg = 'Unable to return ' + convert(nvarchar(50),@dblValueToUpdate) + ' amount to item contract '+ @strItemContractNumber + ' because this will exceed to its total value of ' + convert(nvarchar(50),@dblDollarValue) + '.' 
		RAISERROR(@ErrMsg,16,1)
	END

	-- INSERT HISTORY
	--EXEC uspCTItemContractCreateHistory 
	--		@intItemContractDetailId	=	@intItemContractDetailId, 
	--		@intTransactionId			=	@intTransactionId, 
	--		@intTransactionDetailId		=	@intTransactionDetailId,
	--		@strTransactionId			=	@strTransactionId,
	--		@intUserId					=	@intUserId,
	--		@strTransactionType			=	@strScreenName,
	--		@dblNewContracted			=	@dblOrigContracted,
	--		@dblNewScheduled			=	@dblNewScheduled,
	--		@dblNewAvailable			=	@dblOrigAvailable,
	--		@dblNewApplied				=	@dblOrigApplied,
	--		@dblNewBalance				=	@dblOrigBalance,
	--		@intNewContractStatusId		=	@intContractStatusId,
	--		@dtmNewLastDeliveryDate		=	@dtmOrigLastDeliveryDate


	-- UPDATE ITEM CONTRACT
	UPDATE 	tblCTItemContractHeader
	SET		dblRemainingDollarValue			=	ISNULL(@dblNewRemainingDollarValue,0),
			intConcurrencyId				=	intConcurrencyId + 1
	WHERE	intItemContractHeaderId			=	@intItemContractHeaderId


END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO