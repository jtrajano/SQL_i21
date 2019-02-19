/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
	A stub is created in case AP module is not enabled in origin. 
	The real stored procedure is in the integration project. 
*/
CREATE PROCEDURE [dbo].[uspCMImportValidations]
	@Invalid_UserId_Found AS BIT OUTPUT
	,@Invalid_GL_Account_Id_Found AS BIT OUTPUT
	,@Missing_GL_Account_Id AS BIT OUTPUT
	,@Invalid_Currency_Id_Found AS BIT OUTPUT
	,@Invalid_Bank_Account_Found AS BIT OUTPUT
	,@Missing_Default_Currency AS BIT OUTPUT
	,@Missing_Cash_Account_Group AS BIT OUTPUT
	,@Future_Clear_Date_Found AS BIT OUTPUT
	,@Unbalance_Found AS BIT OUTPUT
	,@Duplicate_Bank_Name_Found AS BIT OUTPUT
AS

RAISERROR('Importing procedure not available.', 16, 1);