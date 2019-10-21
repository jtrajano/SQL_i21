CREATE PROCEDURE [dbo].[uspCTCreateSequenceUsageHistory]
	@intContractDetailId		INT,
	@strScreenName				NVARCHAR(50),
	@intExternalId				INT,
	@strFieldName				NVARCHAR(50),
	@dblOldValue				NUMERIC(18, 6),
	@dblTransactionQuantity		NUMERIC(18, 6),
	@dblNewValue				NUMERIC(18, 6),	
	@intUserId					INT,
	@strReason					NVARCHAR(MAX) = '',
	@dblBalance					NUMERIC(18, 6),
	@intSequenceUsageHistoryId	INT OUTPUT
AS
BEGIN TRY
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intExternalHeaderId	INT,
			@intContractHeaderId	INT,
			@intContractSeq			INT,
			@strNumber				NVARCHAR(MAX),
			@strUserName			NVARCHAR(MAX)
	

	SELECT	@intExternalHeaderId	=	intExternalHeaderId, 
			@intContractHeaderId	=	intContractHeaderId, 
			@intContractSeq			=	intContractSeq,
			@strNumber				=	strNumber,
			@strUserName			=	strUserName
	FROM	dbo.fnCTGetSequenceUsageHistoryAdditionalParam(@intContractDetailId,@strScreenName,@intExternalId,@intUserId)

	INSERT INTO tblCTSequenceUsageHistory
	(
			intContractDetailId,	strScreenName,				intExternalId,		strFieldName,	strReason,
			dblOldValue,			dblTransactionQuantity,		dblNewValue,		intUserId,		dtmTransactionDate,
			intExternalHeaderId,	intContractHeaderId,		intContractSeq,		strNumber,		strUserName
		   ,dblBalance
			
	)
	SELECT	@intContractDetailId,	@strScreenName,				@intExternalId,		@strFieldName,	@strReason,
			ISNULL(@dblOldValue, 0),			@dblTransactionQuantity,	ISNULL(@dblNewValue, 0),		@intUserId,		GETDATE(),
			@intExternalHeaderId,	@intContractHeaderId,		@intContractSeq,	@strNumber,		@strUserName
		   ,@dblBalance
			
	SELECT @intSequenceUsageHistoryId = SCOPE_IDENTITY()

END TRY      
BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()           
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH