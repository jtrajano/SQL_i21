﻿
CREATE PROCEDURE uspCMUnreconcileBankRecords
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL,
	@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

-- Declare the transaction types (constant)
DECLARE @dtmLog AS DATETIME 
		
SET @dtmLog = GETDATE()

-- Update the status of the transactions to clear prior to the unreconciliation. 
UPDATE [dbo].[tblCMBankReconciliationAudit] SET
	 ysnReconciled = 0
	,intUserId = @intUserId
	,dtmLog = @dtmLog
WHERE intBankAccountId = @intBankAccountId
	AND dtmDateReconciled = @dtmDate
	AND ysnReconciled = 1

IF @@ERROR <> 0	GOTO uspCMUnreconcileBankRecords_Rollback		

DECLARE @Id Id

INSERT INTO @Id
SELECT intTransactionId FROM tblCMBankTransaction
WHERE	intBankAccountId = @intBankAccountId
		AND ysnPosted = 1
		AND ysnClr = 1
		AND dtmDateReconciled =@dtmDate
		AND dbo.fnIsDepositEntry(strLink) = 0
IF @@ERROR <> 0	GOTO uspCMUnreconcileBankRecords_Rollback

UPDATE t
SET dtmDateReconciled = NULL
FROM  tblCMBankTransaction t 
JOIN @Id i on i.intId = t.intTransactionId

UPDATE t
SET dtmDateReconciled = NULL
FROM  tblCMABRActivityMatched t
JOIN @Id i on i.intId = t.intTransactionId
		
--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
uspCMUnreconcileBankRecords_Commit:
	COMMIT TRANSACTION
	GOTO uspCMUnreconcileBankRecords_Exit
	
uspCMUnreconcileBankRecords_Rollback:
	ROLLBACK TRANSACTION 
	
uspCMUnreconcileBankRecords_Exit:

