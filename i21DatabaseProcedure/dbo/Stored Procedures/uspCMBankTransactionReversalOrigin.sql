/**Standard temporary table to use: 
* 
* 	CREATE TABLE #tmpCMBankTransaction (
* 		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
* 		UNIQUE (strTransactionId)
* 	)
* 
* This is a dummy stored procedure in the i21Database project. 
* It is used to avoid errors in uspCMBankTransactionReversal. 
*/

CREATE PROCEDURE [dbo].[uspCMBankTransactionReversalOrigin]
	@intUserId INT  
	,@isSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Exit_Successfully:
	SET @isSuccessful = 1
	GOTO Exit_BankTransactionReversalOrigin
	
Exit_BankTransactionReversalOrigin_WithErrors:
	SET @isSuccessful = 0		
	GOTO Exit_BankTransactionReversalOrigin
	
Exit_BankTransactionReversalOrigin: 