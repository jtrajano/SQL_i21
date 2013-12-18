/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 17, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  fn_GetCurrencyIDFromOriginToi21
   Description		   :  From a Origin currency, return the PK key equivalent of it in i21 currency table (tblSMCurrency). 
   Last Modified By    : 1. 
                         2.
                         :
                         :
                         n.

   Last Modified Date  : 1. 
                         2. 
                         :
                         :
                         n.

   Synopsis            : 1. 
                         2. 
                         :
                         :
                         n.
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_GetCurrencyIDFromOriginToi21') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_GetCurrencyIDFromOriginToi21
GO

CREATE FUNCTION fn_GetCurrencyIDFromOriginToi21(@strOriginCurrencyID AS NVARCHAR(3))	
RETURNS INT 
AS
BEGIN 

	DECLARE @intCurrencyID INT

	SELECT	@intCurrencyID = intCurrencyID
	FROM	dbo.tblSMCurrency 
	WHERE	strCurrency = @strOriginCurrencyID

	RETURN @intCurrencyID
END

GO
