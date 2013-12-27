/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 27, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  fn_GetNumbersFromString
   
   Description		   :  Strip off all the alpha characters from a string and return only an integer value. 
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_GetNumbersFromString') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_GetNumbersFromString
GO

CREATE FUNCTION fn_GetNumbersFromString(@strText AS NVARCHAR(20))	
RETURNS INT
AS
BEGIN 
	WHILE PATINDEX('%[^0-9]%', @strText) > 0
	BEGIN
		SET @strText = STUFF(@strText, PATINDEX('%[^0-9]%', @strText), 1, '')
	END
	
	RETURN CAST(@strText AS INT)
END

GO
