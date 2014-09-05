/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
	A stub is created in case AP module is not enabled in origin. 

	Sequence of scripts to run the import: 
	   1. uspCMImportBankAccountsFromOrigin 
	   2. uspCMImportBankTransactionsFromOrigin 
	   3. uspCMImportBankReconciliationFromOrigin (*This file)
*/

CREATE PROCEDURE [dbo].[uspCMImportBankReconciliationFromOrigin]
AS
