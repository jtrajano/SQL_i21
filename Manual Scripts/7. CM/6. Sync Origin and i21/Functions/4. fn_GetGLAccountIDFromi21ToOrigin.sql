/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 19, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  fn_GetGLAccountIDFromi21ToOrigin

   Description		   :  From an i21 G/L account id, return the PK key equivalent of it in legacy.  
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_GetGLAccountIDFromi21ToOrigin') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_GetGLAccountIDFromi21ToOrigin
GO

CREATE FUNCTION fn_GetGLAccountIDFromi21ToOrigin(@inti21AccountID AS INT)	
RETURNS CHAR(16) 
AS
BEGIN 

	DECLARE @charAccountID CHAR(16)

	SELECT	@charAccountID = CAST(strExternalID AS CHAR(16)) 
	FROM	dbo.tblGLCOACrossReference 
	WHERE	inti21ID = @inti21AccountID

	RETURN @charAccountID COLLATE SQL_Latin1_General_CP1_CS_AS
END

GO
