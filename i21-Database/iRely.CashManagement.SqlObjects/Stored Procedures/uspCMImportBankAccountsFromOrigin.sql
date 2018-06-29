/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
   A stub is created in case AP module is not enabled in origin. 
   	The real stored procedure is in the integration project. 

   Sequence of scripts to run the import: 
	   1. uspCMImportBankAccountsFromOrigin (*This file)
	   2. uspCMImportBankTransactionsFromOrigin
	   3. uspCMImportBankReconciliationFromOrigin   
*/

CREATE PROCEDURE [dbo].[uspCMImportBankAccountsFromOrigin]
AS
