
/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
	A stub is created in case AP module is not enabled in origin. 
	The real stored procedure is in the integration project. 

	Sequence of scripts to run the import: 
	   1. uspCMImportBankAccountsFromOrigin 
	   2. uspCMImportBankTransactionsFromOrigin (*This file)
	   3. uspCMImportBankReconciliationFromOrigin
*/

CREATE PROCEDURE [dbo].[uspCMImportBankTransactionsFromOrigin]
AS
