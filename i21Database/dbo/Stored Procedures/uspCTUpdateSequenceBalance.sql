CREATE PROCEDURE [dbo].[uspCTUpdateSequenceBalance]
	@intContractDetailId			INT,
	@dblQuantityToUpdate			NUMERIC(12,4),
	@intUserId						INT,
	@intExternalId					INT,
	@strScreenName					NVARCHAR(50)
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(12,4),
			@dblOldBalance			NUMERIC(12,4),
			@dblNewBalance			NUMERIC(12,4),
			@strAdjustmentNo		NVARCHAR(50),
			@dblTransactionQuantity	NUMERIC(12,4)

	SELECT	@dblQuantity			=	dblQuantity,
			@dblOldBalance			=	dblBalance
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId 
	
	SELECT	@dblTransactionQuantity	=	- @dblQuantityToUpdate
	SELECT	@dblNewBalance = @dblOldBalance - @dblQuantityToUpdate

	IF @dblNewBalance < 0
	BEGIN
		RAISERROR('Balance cannot be less than zero.',16,1)
	END
	
	IF @dblNewBalance > @dblQuantity
	BEGIN
		RAISERROR('Balance cannot be more than quantity.',16,1)
	END
	
	UPDATE	tblCTContractDetail
	SET		intConcurrencyId	=	intConcurrencyId + 1,
			dblBalance			=	@dblNewBalance,
			intContractStatusId	=	CASE WHEN @dblNewBalance = 0 THEN 5 ELSE CASE WHEN intContractStatusId = 5 THEN 1 ELSE intContractStatusId END END
	WHERE	intContractDetailId =	@intContractDetailId
	
	SELECT	@strAdjustmentNo = strPrefix+LTRIM(intNumber) 
	FROM	tblSMStartingNumber 
	WHERE	strModule = 'Contract Management' AND strTransactionType = 'ContractAdjNo'

	UPDATE	tblSMStartingNumber
	SET		intNumber = intNumber+1
	WHERE	strModule = 'Contract Management' AND strTransactionType = 'ContractAdjNo'

	EXEC	uspCTCreateSequenceUsageHistory 
			@intContractDetailId	=	@intContractDetailId,
			@strScreenName			=	@strScreenName,
			@intExternalId			=	@intExternalId,
			@strFieldName			=	'Balance',
			@dblOldValue			=	@dblOldBalance,
			@dblTransactionQuantity =	@dblTransactionQuantity,
			@dblNewValue			=	@dblNewBalance,	
			@intUserId				=	@intUserId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTUpdateSequenceBalance - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH