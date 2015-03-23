/**Standard temporary table to use: 
* 
* 	CREATE TABLE #tmpCMBankTransaction (
* 		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
* 		UNIQUE (strTransactionId)
* 	)
* 
*/

GO

IF	EXISTS(select top 1 1 from sys.procedures where name = 'uspCMBankTransactionReversalOrigin')
	AND (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN 
	DROP PROCEDURE uspCMBankTransactionReversalOrigin
END 
GO

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN 

	EXEC('
	CREATE PROCEDURE [dbo].[uspCMBankTransactionReversalOrigin]
		@intUserId INT  
		,@isSuccessful BIT = 0 OUTPUT
	AS

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @BANK_DEPOSIT AS INT = 1
			,@BANK_WITHDRAWAL AS INT = 2
			,@MISCELLANEOUS_CHECKS AS INT = 3
			,@BANK_TRANSFER AS INT = 4
			,@BANK_TRANSACTION AS INT = 5
			,@CREDIT_CARD_CHARGE AS INT = 6
			,@CREDIT_CARD_RETURNS AS INT = 7
			,@CREDIT_CARD_PAYMENTS AS INT = 8
			,@BANK_TRANSFER_WD AS INT = 9
			,@BANK_TRANSFER_DEP AS INT = 10
			,@ORIGIN_DEPOSIT AS INT = 11		-- NEGATIVE AMOUNT, INDICATOR: O, APCHK_CHK_NO PREFIX: NONE
			,@ORIGIN_CHECKS AS INT = 12			-- POSITIVE AMOUNT, INDICATOR: C, APCHK_CHK_NO PREFIX: N/A, IT MUST BE A VALId NUMBER
			,@ORIGIN_EFT AS INT = 13			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''E''		
			,@ORIGIN_WITHDRAWAL AS INT = 14		-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: NONE
			,@ORIGIN_WIRE AS INT = 15			-- POSITIVE AMOUNT, INDICATOR: N/A, APCHK_CHK_NO PREFIX: ''W''
			,@AP_PAYMENT AS INT = 16
			,@BANK_STMT_IMPORT AS INT = 17
			,@AR_PAYMENT AS INT = 18
			,@VOID_CHECK AS INT = 19
			,@AP_ECHECK AS INT = 20

	-- Try to find the origin transaction to void. 
	UPDATE	apchkmst_origin
	SET		apchk_void_ind = ''C''
	FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
				ON F.strTransactionId = TMP.strTransactionId
			INNER JOIN apchkmst_origin O
				ON F.strLink = ( 
					CAST(O.apchk_cbk_no AS NVARCHAR(2)) 
					+ CAST(O.apchk_rev_dt AS NVARCHAR(10)) 
					+ CAST(O.apchk_trx_ind AS NVARCHAR(1)) 
					+ CAST(O.apchk_chk_no AS NVARCHAR(8))
				) COLLATE Latin1_General_CI_AS 							
	WHERE	F.intBankTransactionTypeId IN (@ORIGIN_CHECKS)
	IF @@ERROR <> 0	GOTO Exit_BankTransactionReversalOrigin_WithErrors

	Exit_Successfully:
		SET @isSuccessful = 1
		GOTO Exit_BankTransactionReversalOrigin
	
	Exit_BankTransactionReversalOrigin_WithErrors:
		SET @isSuccessful = 0		
		GOTO Exit_BankTransactionReversalOrigin
	
	Exit_BankTransactionReversalOrigin: 
	')
END