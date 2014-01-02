/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 17, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  fn_GetGLAccountIDFromOriginToi21
   Description		   :  From an Origin G/L account id, return the PK key equivalent of it in i21 COA table (tblGLAccount).
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_GetGLAccountIDFromOriginToi21') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_GetGLAccountIDFromOriginToi21
GO

CREATE FUNCTION fn_GetGLAccountIDFromOriginToi21(@strOriginAccountID AS NVARCHAR(16))	
RETURNS INT 
AS
BEGIN 

	DECLARE @intAccountID INT

	SELECT	@intAccountID = inti21ID 
	FROM	dbo.tblGLCOACrossReference 
	WHERE	strExternalID = @strOriginAccountID

	RETURN @intAccountID
END

GO