﻿/*
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
	,@Missing_Default_Currency AS BIT OUTPUT
	,@Missing_Cash_Account_Group AS BIT OUTPUT
	,@Future_Clear_Date_Found AS BIT OUTPUT
	,@Unbalance_Found AS BIT OUTPUT
	,@Duplicate_Bank_Name_Found AS BIT OUTPUT
AS

SELECT	@Invalid_UserId_Found = ISNULL(@Invalid_UserId_Found, 0)
		,@Invalid_GL_Account_Id_Found = ISNULL(@Invalid_GL_Account_Id_Found, 0)
		,@Missing_GL_Account_Id = ISNULL(@Missing_GL_Account_Id,0)
		,@Invalid_Currency_Id_Found = ISNULL(@Invalid_Currency_Id_Found,0)
		,@Missing_Default_Currency = ISNULL(@Missing_Default_Currency, 1)
		,@Missing_Cash_Account_Group = ISNULL(@Missing_Cash_Account_Group, 0)
		,@Future_Clear_Date_Found = ISNULL(@Future_Clear_Date_Found, 0)
		,@Unbalance_Found = ISNULL(@Unbalance_Found, 0)
		,@Duplicate_Bank_Name_Found = ISNULL(@Duplicate_Bank_Name_Found, 0)

GO