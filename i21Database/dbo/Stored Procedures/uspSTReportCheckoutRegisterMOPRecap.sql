CREATE PROCEDURE [dbo].[uspSTReportCheckoutRegisterMOPRecap]
	@intCheckoutId INT  
	
AS

BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)
  
   select D.strPaymentOptionId as MOPID, D.strDescription, A.dblAmount, SUM(A.dblAmount) over() as TotalMOP ,
   E.strAccountId AS AccountID, E.strDescription AS Description from tblSTCheckoutPaymentOptions A  JOIN tblSTCheckoutHeader
   B ON A.intCheckoutId = B.intCheckoutId JOIN tblSTStore C ON B.intStoreId = C.intStoreId
   JOIN tblSTPaymentOption D ON A.intPaymentOptionId = D.intPaymentOptionId
   LEFT OUTER JOIN tblGLAccount E ON E.intAccountId = A.intAccountId 
   where A.intCheckoutId =  @intCheckoutId
  
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH