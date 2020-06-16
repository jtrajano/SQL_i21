
CREATE PROCEDURE [uspCMFindMatchingRecordsForBankRecon]
	@strBankStatementImportId NVARCHAR(40) = NULL,
	@intBankAccountId INT,
	@dtmStatementDate DATETIME,
	@intEntityId INT NULL = NULL,
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
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20
		,@PAYCHECK AS INT = 21
		,@NSF INT = 124
		,@BANK_INTEREST INT = 51
		,@BANK_LOAN INT = 52
        ,@IMPORT_STATUS_UNPROCESSED AS INT = 0
        ,@IMPORT_STATUS_MATCHFOUND AS INT = 1
        ,@IMPORT_STATUS_NOMATCHFOUND AS INT = 2
		,@IMPORT_STATUS_MULTIPLEENTRY AS INT = 3
        
        -- This is the buffer period to search for the transactions. 
		,@BETWEEN_DAYS AS INT = 19 -- +/- 19 DAYS
		
		-- Declare the local variables 
		,@intTransactionId AS INT
		,@intBankStatementImportId AS INT
		,@dblAmount AS NUMERIC(18,6)
		,@strPayee AS NVARCHAR(300)
		,@dtmDate AS DATETIME
		,@strReferenceNumber AS NVARCHAR(20)
		,@ysnMatchFound AS BIT

-- Temporary table of qualified transactions
-- Criteria for qualification:
-- 1. The record is posted, not voided, and not yet cleared. 
-- 2. The record is with +/- 19 days from the imported record date. 
-- 3. The record is not a deposit entry transaction. 
-- 4. The check transaction is printed. Non-printed check transactions are not included. 
--SELECT	A.intTransactionId
--		,A.intBankTransactionTypeId
--		,A.dtmDate
--		,A.dblAmount
--		,strPayee = CASE WHEN A.intBankTransactionTypeId IN (@BANK_TRANSACTION) THEN A.strMemo ELSE A.strPayee END
--		,ysnTagged = CAST(0 AS BIT)
--INTO	#tmp_list_of_transactions
--FROM	dbo.tblCMBankTransaction A INNER JOIN dbo.tblCMBankStatementImport B
--			ON A.intBankAccountId = B.intBankAccountId
--WHERE	A.dtmDateReconciled IS NULL
--		AND A.ysnPosted = 1
--		AND A.ysnCheckVoid = 0
--		AND A.ysnClr = 0
--		AND CAST(FLOOR(CAST(A.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(B.dtmDate AS FLOAT) + @BETWEEN_DAYS) AS DATETIME)
--		AND CAST(FLOOR(CAST(A.dtmDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(B.dtmDate AS FLOAT) - @BETWEEN_DAYS) AS DATETIME)
--		AND dbo.fnIsDepositEntry(strLink) = 0
--		AND 1 = (
--					-- If check transaction is not yet printed, do not include record in the update.
--			CASE	WHEN intBankTransactionTypeId IN (@MISC_CHECKS, @ORIGIN_CHECKS, @AP_PAYMENT) AND dtmCheckPrinted IS NULL THEN 0
--					-- If record is a non-check, no need to check the date check printed. 
--					ELSE 1
--			END 		
--		)

SELECT	A.intTransactionId
		,A.intBankTransactionTypeId
		,A.dtmDate
		,A.dblAmount
		,strPayee = CASE WHEN A.intBankTransactionTypeId IN (5) THEN A.strMemo ELSE A.strPayee END
		,A.strReferenceNo
		,ysnTagged = CAST(0 AS BIT)
INTO	#tmp_list_of_transactions
FROM	dbo.tblCMBankTransaction A
WHERE	 A.intBankAccountId = @intBankAccountId
		AND A.dtmDateReconciled IS NULL
		AND A.ysnPosted = 1
		AND A.ysnCheckVoid = 0
		AND A.ysnClr = 0
		AND CAST(FLOOR(CAST(A.dtmDate AS FLOAT)) AS DATETIME) <= @dtmStatementDate
		AND strLink NOT IN ( --This is to improved the query by not using fnIsDespositEntry
					SELECT strLink FROM [dbo].[fnGetDepositEntry]()
			)
		AND 1 = (
					-- If check transaction is not yet printed, do not include record in the update.
			CASE	WHEN intBankTransactionTypeId IN (@MISC_CHECKS, @ORIGIN_CHECKS, @AP_PAYMENT) AND dtmCheckPrinted IS NULL THEN 0
					-- If record is a non-check, no need to check the date check printed. 
					ELSE 1
			END 		
		)
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
			,@strPayee = strPayee
			,@strReferenceNumber = strReferenceNo
	FROM	#tmp_list_of_imported_record
	IF @@ERROR <> 0	GOTO _ROLLBACK
	
	UPDATE #tmp_list_of_transactions
	SET ysnTagged = 0
	IF @@ERROR <> 0	GOTO _ROLLBACK
	
	DECLARE @Count AS INT = 0

	IF @dblAmount < 1
	BEGIN
		SELECT @Count = Count(intTransactionId) FROM #tmp_list_of_transactions WHERE ABS(dblAmount) = ABS(@dblAmount) AND intBankTransactionTypeId IN (@BANK_WITHDRAWAL,@NSF,@BANK_INTEREST,@BANK_LOAN,@BANK_TRANSACTION,@ORIGIN_WITHDRAWAL, @BANK_TRANSFER_WD,  @MISC_CHECKS, @ORIGIN_CHECKS, @ORIGIN_EFT,  @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK, @PAYCHECK)
	END
	ELSE
	BEGIN
		SELECT @Count = Count(intTransactionId) FROM #tmp_list_of_transactions WHERE dblAmount = @dblAmount AND intBankTransactionTypeId IN (@BANK_TRANSACTION,@BANK_DEPOSIT, @BANK_TRANSFER_DEP)
	END

	IF (@strPayee IS NULL OR @strPayee = '') AND (@strReferenceNumber IS NULL OR @strReferenceNumber = '') AND @Count > 1
	BEGIN
		--DELETE FROM #tmp_list_of_imported_recor
		--WHERE intBankStatementImportId = @intBankStatementImportId
		--IF @@ERROR <> 0	GOTO _ROLLBACK

		-- Update the status of the Bank Statement Import
			UPDATE	dbo.tblCMBankStatementImport
			SET		intImportStatus = @IMPORT_STATUS_MULTIPLEENTRY
			WHERE	intBankStatementImportId = @intBankStatementImportId
			IF @@ERROR <> 0	GOTO _ROLLBACK		

	END
	ELSE
	BEGIN	
		SET @ysnMatchFound = 0
		IF @@ERROR <> 0	GOTO _ROLLBACK
	
		SELECT  @ysnMatchFound = 1, @intTransactionId = A.intTransactionId
		FROM	#tmp_list_of_transactions A
		WHERE	--A.intTransactionId = @intTransactionId
				1 = CASE	WHEN (@strPayee <> '') THEN 
									CASE WHEN (LTRIM(RTRIM(ISNULL(A.strPayee, ''))) = LTRIM(RTRIM(ISNULL(@strPayee, '')))) THEN 1 ELSE 0 END
								ELSE 1 END
				AND 1 = CASE WHEN(@strReferenceNumber <> '') THEN
									CASE WHEN (LTRIM(RTRIM(ISNULL(SUBSTRING(A.strReferenceNo, PATINDEX('%[^0 ]%', A.strReferenceNo + ' '), LEN(A.strReferenceNo)), ''))) = LTRIM(RTRIM(ISNULL(SUBSTRING(@strReferenceNumber, PATINDEX('%[^0 ]%', @strReferenceNumber + ' '), LEN(@strReferenceNumber)), '')))) THEN 1 ELSE 0 END
								ELSE 1 END
				--AND 1 =	CASE	WHEN A.intBankTransactionTypeId IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT, @AR_PAYMENT) THEN
				--					CASE WHEN ABS(A.dblAmount) = ABS(@dblAmount) THEN 1 ELSE 0 END 							
				--				WHEN A.intBankTransactionTypeId IN (@BANK_WITHDRAWAL, @MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK, @PAYCHECK) THEN
				--					CASE WHEN ABS(A.dblAmount) = ABS(@dblAmount) THEN 1 ELSE 0 END 
				--				WHEN A.intBankTransactionTypeId IN (@BANK_TRANSACTION) THEN 
				--					CASE WHEN ABS(A.dblAmount) = ABS(@dblAmount) THEN 1 ELSE 0 END 
				--					--CASE WHEN EXISTS (	SELECT	1 
				--					--					FROM	tblCMBankTransactionDetail C 
				--					--					WHERE	C.intTransactionId = A.intTransactionId
				--					--					HAVING	(
				--					--								(ISNULL(SUM(ISNULL(C.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(C.dblDebit, 0)), 0) = @dblAmount AND @dblAmount > 0)
				--					--								OR (ISNULL(SUM(ISNULL(C.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(C.dblDebit, 0)), 0) = @dblAmount AND @dblAmount < 0)
				--					--							)
																
				--					--				) THEN 1 
				--					--	ELSE 0
				--					--END								
				--				ELSE 0
				--		END 
							 --WITHDRAWAL ENTRY
				AND 1 = CASE WHEN @dblAmount < 0 AND A.intBankTransactionTypeId IN (@BANK_WITHDRAWAL,@NSF,@BANK_INTEREST,@BANK_LOAN,@BANK_TRANSACTION,@ORIGIN_WITHDRAWAL, @BANK_TRANSFER_WD,  @MISC_CHECKS, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK, @PAYCHECK)THEN
							CASE WHEN A.intBankTransactionTypeId IN (@BANK_WITHDRAWAL,@NSF,@BANK_TRANSACTION, @BANK_TRANSFER_WD, @MISC_CHECKS, @ORIGIN_CHECKS, @ORIGIN_EFT,  @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK, @PAYCHECK) AND ABS(A.dblAmount) = ABS(@dblAmount) THEN 1 --Bank Transfer WD has a (+) value so need to make it absolute
								 WHEN A.dblAmount = @dblAmount THEN 1 
								 ELSE 0 END
							--DEPOSIT ENTRY
							WHEN  @dblAmount > 0 AND  A.intBankTransactionTypeId IN (@BANK_TRANSACTION,@BANK_DEPOSIT, @BANK_TRANSFER_DEP) THEN
									CASE WHEN A.dblAmount = @dblAmount THEN 1 ELSE 0 END 	
						ELSE 0
						END

		IF @@ERROR <> 0	GOTO _ROLLBACK
					
		IF (@ysnMatchFound = 1 AND @intTransactionId IS NOT NULL)
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

			--DELETE FROM #tmp_list_of_imported_record
			--WHERE intBankStatementImportId = @intBankStatementImportId
			--IF @@ERROR <> 0	GOTO _ROLLBACK
			
			--SET @intBankStatementImportId = NULL
			--IF @@ERROR <> 0	GOTO _ROLLBACK
		END
		ELSE 
		BEGIN 
			-- Update the status of the Bank Statement Import
			UPDATE	dbo.tblCMBankStatementImport
			SET		intImportStatus = @IMPORT_STATUS_NOMATCHFOUND
			WHERE	intBankStatementImportId = @intBankStatementImportId
			IF @@ERROR <> 0	GOTO _ROLLBACK		
		END
		
	--	UPDATE	#tmp_list_of_transactions
	--	SET		ysnTagged = 1
	--	WHERE	intTransactionId = @intTransactionId
	--	IF @@ERROR <> 0	GOTO _ROLLBACK
	--END
		
	

	END

	DELETE FROM #tmp_list_of_imported_record
	WHERE intBankStatementImportId = @intBankStatementImportId



	IF @@ERROR <> 0	GOTO _ROLLBACK
END



IF @@ERROR <> 0	GOTO _ROLLBACK
_COMMIT:
	COMMIT TRANSACTION 
	
	SET @ysnSuccess = 1
	GOTO _EXIT

_ROLLBACK:
	ROLLBACK TRANSACTION 
	SET @ysnSuccess = 0	
	
_EXIT:

DECLARE @rCount INT 
EXEC uspCMImportBTransferFromBStmnt 
	@strBankStatementImportId = @strBankStatementImportId, 
	@intEntityId = @intEntityId,
	@rCount = @rCount OUT

EXEC uspCMImportBTransactionFromBStmnt
	@strBankStatementImportId = @strBankStatementImportId, 
	@intEntityId = @intEntityId,
	@rCount = @rCount OUT


