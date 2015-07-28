CREATE PROCEDURE [dbo].[uspCTCreateSequenceUsageHistory]
	@intContractDetailId	INT,
	@strScreenName			NVARCHAR(50),
	@intExternalId			INT,
	@strFieldName			NVARCHAR(50),
	@dblOldValue			NUMERIC(12,4),
	@dblTransactionQuantity NUMERIC(12,4),
	@dblNewValue			NUMERIC(12,4),	
	@intUserId				INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	INSERT INTO tblCTSequenceUsageHistory
	(
			intContractDetailId,	strScreenName,			intExternalId,	strFieldName,
			dblOldValue,			dblTransactionQuantity,	dblNewValue,	intUserId,		dtmTransactionDate
	)
	SELECT	@intContractDetailId,	@strScreenName,			@intExternalId,	@strFieldName,
			@dblOldValue,			@dblTransactionQuantity,@dblNewValue,	@intUserId,		GETDATE()
	
END TRY      
BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()           
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH