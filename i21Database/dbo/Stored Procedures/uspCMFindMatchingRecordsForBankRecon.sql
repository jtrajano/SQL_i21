
CREATE PROCEDURE uspCMFindMatchingRecordsForBankRecon
	@strBankStatementImportId NVARCHAR(40) = NULL,
	@ysnSuccess AS BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION
		
		-- Declare the constant variables
DECLARE @BANK_DEPOSIT INT = 1
		,@BANK_WITHDRAWAL INT = 2
		,@MISC_CHECKS INT = 3
		,@BANK_TRANSFER INT = 4
		,@BANK_TRANSACTION INT = 5
		,@CREDIT_CARD_CHARGE INT = 6
		,@CREDIT_CARD_RETURNS INT = 7
		,@CREDIT_CARD_PAYMENTS INT = 8
		,@BANK_TRANSFER_WD INT = 9
		,@BANK_TRANSFER_DEP INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11
		,@ORIGIN_CHECKS AS INT = 12
		,@ORIGIN_EFT AS INT = 13
		,@ORIGIN_WITHDRAWAL AS INT = 14
		,@ORIGIN_WIRE AS INT = 15
		,@AP_PAYMENT AS INT = 16
        ,@BANK_STMT_IMPORT AS INT = 17
        
        ,@IMPORT_STATUS_UNPROCESSED AS INT = 0
        ,@IMPORT_STATUS_MATCHFOUND AS INT = 1
        ,@IMPORT_STATUS_NOMATCHFOUND AS INT = 2
        
        -- This is the buffer period to search for the transactions. 
		,@BETWEEN_DAYS AS INT = 19 -- +/- 19 DAYS
		
		-- Declare the local variables 
		,@intTransactionId AS INT
		,@intBankStatementImportId AS INT
		,@dblAmount AS NUMERIC(18,6)
		,@dtmDate AS DATETIME
		,@ysnMatchFound AS BIT

-- Temporary table of qualified transactions
-- Criteria for qualification:
-- 1. The record is posted, not voided, and not yet cleared. 
-- 2. The record is with +/- 19 days from the imported record date. 
SELECT	A.intTransactionId
		,A.intBankTransactionTypeId
		,A.dtmDate
		,A.dblAmount
		,ysnTagged = CAST(0 AS BIT)
INTO	#tmp_list_of_transactions
FROM	dbo.tblCMBankTransaction A INNER JOIN dbo.tblCMBankStatementImport B
			ON A.intBankAccountId = B.intBankAccountId
WHERE	A.dtmDateReconciled IS NULL
		AND A.ysnPosted = 1
		AND A.ysnCheckVoid = 0
		AND A.ysnClr = 0
		AND CAST(FLOOR(CAST(A.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(B.dtmDate AS FLOAT) + @BETWEEN_DAYS) AS DATETIME)
		AND CAST(FLOOR(CAST(A.dtmDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(B.dtmDate AS FLOAT) - @BETWEEN_DAYS) AS DATETIME)
IF @@ERROR <> 0	GOTO _ROLLBACK

-- Temporary table of the imported records		
SELECT  *
INTO	#tmp_list_of_imported_record
FROM	dbo.tblCMBankStatementImport B
WHERE	B.strBankStatementImportId = @strBankStatementImportId
IF @@ERROR <> 0	GOTO _ROLLBACK
		
WHILE EXISTS (SELECT TOP 1 1 FROM #tmp_list_of_imported_record)
BEGIN
	SELECT	TOP 1 
			@intBankStatementImportId = intBankStatementImportId
			,@dblAmount = dblAmount
			,@dtmDate = dtmDate
	FROM	#tmp_list_of_imported_record
	IF @@ERROR <> 0	GOTO _ROLLBACK
	
	UPDATE #tmp_list_of_transactions
	SET ysnTagged = 0
	IF @@ERROR <> 0	GOTO _ROLLBACK

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmp_list_of_transactions WHERE ysnTagged = 0 AND @intBankStatementImportId IS NOT NULL) 
	BEGIN 
		SELECT	TOP 1 
				@intTransactionId = intTransactionId
		FROM	#tmp_list_of_transactions
		WHERE	ysnTagged = 0 
		ORDER BY dtmDate
		IF @@ERROR <> 0	GOTO _ROLLBACK
		
		SET @ysnMatchFound = 0
		IF @@ERROR <> 0	GOTO _ROLLBACK
	
		SELECT  @ysnMatchFound = 1
		FROM	#tmp_list_of_transactions A
		WHERE	A.intTransactionId = @intTransactionId
				AND 1 =	CASE	WHEN A.intBankTransactionTypeId IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT) THEN
									CASE WHEN ABS(A.dblAmount) = ABS(@dblAmount) THEN 1 ELSE 0 END 							
								WHEN A.intBankTransactionTypeId IN (@BANK_WITHDRAWAL, @MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE, @AP_PAYMENT) THEN
									CASE WHEN ABS(A.dblAmount) = ABS(@dblAmount) THEN 1 ELSE 0 END 
								WHEN A.intBankTransactionTypeId IN (@BANK_TRANSACTION) THEN 
									CASE WHEN EXISTS (	SELECT	1 
														FROM	tblCMBankTransactionDetail C 
														WHERE	C.intTransactionId = A.intTransactionId
														HAVING	(
																	(ISNULL(SUM(ISNULL(C.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(C.dblDebit, 0)), 0) = @dblAmount AND @dblAmount > 0)
																	OR (ISNULL(SUM(ISNULL(C.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(C.dblDebit, 0)), 0) = @dblAmount AND @dblAmount < 0)
																)
																
													) THEN 1 
										ELSE 0
									END								
								ELSE 0
						END 
		IF @@ERROR <> 0	GOTO _ROLLBACK
					
		IF (@ysnMatchFound = 1)
		BEGIN 	
			-- Link the transaction to the imported bank statement. 
			-- Set the ysnClr to true		
			UPDATE	dbo.tblCMBankTransaction 
			SET		ysnClr = 1
					,intBankStatementImportId = @intBankStatementImportId
					,intConcurrencyId = A.intConcurrencyId + 1					
			FROM	dbo.tblCMBankTransaction A
			WHERE	A.intTransactionId = @intTransactionId
					AND A.ysnPosted = 1
					AND A.ysnClr = 0
			IF @@ERROR <> 0	GOTO _ROLLBACK
			
			-- Update the status of the Bank Statement Import
			UPDATE	dbo.tblCMBankStatementImport
			SET		intImportStatus = @IMPORT_STATUS_MATCHFOUND
			WHERE	intBankStatementImportId = @intBankStatementImportId
			IF @@ERROR <> 0	GOTO _ROLLBACK
			
			DELETE FROM #tmp_list_of_transactions
			WHERE intTransactionId = @intTransactionId		
			IF @@ERROR <> 0	GOTO _ROLLBACK

			DELETE FROM #tmp_list_of_imported_record
			WHERE intBankStatementImportId = @intBankStatementImportId
			IF @@ERROR <> 0	GOTO _ROLLBACK
			
			SET @intBankStatementImportId = NULL
			IF @@ERROR <> 0	GOTO _ROLLBACK
		END
		ELSE 
		BEGIN 
			-- Update the status of the Bank Statement Import
			UPDATE	dbo.tblCMBankStatementImport
			SET		intImportStatus = @IMPORT_STATUS_NOMATCHFOUND
			WHERE	intBankStatementImportId = @intBankStatementImportId
			IF @@ERROR <> 0	GOTO _ROLLBACK		
		END
		
		UPDATE	#tmp_list_of_transactions
		SET		ysnTagged = 1
		WHERE	intTransactionId = @intTransactionId
		IF @@ERROR <> 0	GOTO _ROLLBACK
	END

	DELETE FROM #tmp_list_of_imported_record
	WHERE intBankStatementImportId = @intBankStatementImportId
	IF @@ERROR <> 0	GOTO _ROLLBACK
END

_COMMIT:
	COMMIT TRANSACTION 
	SET @ysnSuccess = 1
	GOTO _EXIT

_ROLLBACK:
	ROLLBACK TRANSACTION 
	SET @ysnSuccess = 0	
	
_EXIT:
