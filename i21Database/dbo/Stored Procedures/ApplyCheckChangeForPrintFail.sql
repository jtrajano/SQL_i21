
CREATE PROCEDURE ApplyCheckChangeForPrintFail
	@intBankAccountId INT = NULL,
	@strTransactionId NVARCHAR(40) = NULL,
	@strBatchId NVARCHAR(20) = NULL,
	@ysnFail BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Clean the parameters
SELECT	@strTransactionId = CASE WHEN LTRIM(RTRIM(@strTransactionId)) = '' THEN NULL ELSE @strTransactionId END
		,@strBatchId = CASE WHEN LTRIM(RTRIM(@strBatchId)) = '' THEN NULL ELSE @strBatchId END

-- Mass update the ysnFail
UPDATE	[dbo].[tblCMCheckPrintJobSpool]
SET		ysnFail = @ysnFail
WHERE	intBankAccountId = @intBankAccountId
		AND strTransactionId = ISNULL(@strTransactionId, strTransactionId)
		AND strBatchId = ISNULL(@strBatchId, strBatchId)