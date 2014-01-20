
CREATE PROCEDURE ApplyCheckChangeForPrintFail
	@intBankAccountID INT = NULL,
	@strTransactionID NVARCHAR(40) = NULL,
	@strBatchID NVARCHAR(20) = NULL,
	@ysnFail BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Clean the parameters
SELECT	@strTransactionID = CASE WHEN LTRIM(RTRIM(@strTransactionID)) = '' THEN NULL ELSE @strTransactionID END
		,@strBatchID = CASE WHEN LTRIM(RTRIM(@strBatchID)) = '' THEN NULL ELSE @strBatchID END

-- Mass update the ysnFail
UPDATE	dbo.tblCMCheckPrintJobSpool 
SET		ysnFail = @ysnFail
WHERE	intBankAccountID = @intBankAccountID
		AND strTransactionID = ISNULL(@strTransactionID, strTransactionID)
		AND strBatchID = ISNULL(@strBatchID, strBatchID)