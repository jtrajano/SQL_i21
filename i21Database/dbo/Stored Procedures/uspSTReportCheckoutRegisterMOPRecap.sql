CREATE PROCEDURE [dbo].[uspSTReportCheckoutRegisterMOPRecap]
	@intCheckoutId INT  
AS
BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
  
	SELECT 
		STPO.strPaymentOptionId as MOPID, 
		STPO.strDescription, 
		CHPO.dblRegisterAmount,
		CHPO.dblAmount, 
		SUM(CHPO.dblAmount) over() as TotalMOP,
		GLAccount.strAccountId AS AccountID, 
		GLAccount.strDescription AS Description 
	FROM tblSTCheckoutPaymentOptions CHPO  
	JOIN tblSTCheckoutHeader CH 
		ON CHPO.intCheckoutId = CH.intCheckoutId 
	JOIN tblSTStore ST 
		ON CH.intStoreId = ST.intStoreId
	JOIN tblSTPaymentOption STPO 
		ON CHPO.intPaymentOptionId = STPO.intPaymentOptionId
	LEFT OUTER JOIN tblGLAccount GLAccount 
		ON GLAccount.intAccountId = CHPO.intAccountId 
	WHERE CHPO.intCheckoutId =  @intCheckoutId
  
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH