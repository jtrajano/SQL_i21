
/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
	A stub is created in case AP module is not enabled in origin. 

	Sequence of scripts to run the import: 
	   1. uspCMImportBankAccountsFromOrigin 
	   2. uspCMImportBankTransactionsFromOrigin (*This file)
	   3. uspCMImportBankReconciliationFromOrigin
*/

CREATE PROCEDURE [dbo].[uspCMImportBankTransactionsFromOrigin]
AS
