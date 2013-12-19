/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 19, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :	fn_GetCurrencyIDFromi21ToOrigin
   
   Description		   :	Both i21 and the legacy systems maintain its own currency tables. We can only use one for the sync. 
							For the data sync, this functions tries to find the closes match currency key from i21 to 
							the one from the legacy currency table.
							
							The currency tables are:
							1. sscurmst is the legacy currency table. 
							2. tblSMCurrency is the i21 currency table. 							
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_GetCurrencyIDFromi21ToOrigin') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_GetCurrencyIDFromi21ToOrigin
GO

CREATE FUNCTION fn_GetCurrencyIDFromi21ToOrigin(@inti21CurrencyID AS INT)	
RETURNS CHAR(3) 
AS
BEGIN 

	DECLARE @sscur_key CHAR(3) 
	
	SELECT	@sscur_key = sscur_key
	FROM	dbo.sscurmst curL INNER JOIN dbo.tblSMCurrency curi21
				ON LTRIM(RTRIM(UPPER(curi21.strCurrency))) = LTRIM(RTRIM(UPPER(curL.sscur_key))) COLLATE Latin1_General_CI_AS 
	WHERE	curi21.intCurrencyID = @inti21CurrencyID
				
	RETURN @sscur_key COLLATE SQL_Latin1_General_CP1_CS_AS
END

GO
