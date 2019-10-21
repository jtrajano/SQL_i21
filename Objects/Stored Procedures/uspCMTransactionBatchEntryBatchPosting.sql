CREATE PROCEDURE uspCMTransactionBatchEntryBatchPosting
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@TransactionId			NVARCHAR(MAX)
	,@strTransactionType	NVARCHAR(50)
	,@intUserId				INT		= NULL
	,@intEntityId			INT		= NULL
	,@BatchId				NVARCHAR(MAX)
	,@successfulCount		AS INT	= 0 OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @transactionCount AS INT = 0

SELECT intTransactionId = Item INTO #tmpTransactionId FROM fnSplitString(@TransactionId,',')

SELECT @transactionCount = COUNT(intTransactionId) from #tmpTransactionId

EXEC uspCMBatchPosting @ysnPost,@ysnRecap,@TransactionId,@strTransactionType,@intUserId,@intEntityId,@BatchId,@successfulCount out

If @successfulCount = @transactionCount
BEGIN
	UPDATE tblCMBankTransactionBatch SET ysnPosted = @ysnPost WHERE strBankTransactionBatchId = @BatchId
END