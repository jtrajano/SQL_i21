CREATE FUNCTION [dbo].[fnCTGetEventRecipientEmail]
(
	@intEventId INT
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	@strStatus AS NVARCHAR(MAX)

	SELECT	@strStatus	=	STUFF(															
								   (
										SELECT	DISTINCT												
										'; ' + EY.strEmail											
										FROM tblCTEventRecipient ER																								
										JOIN [tblEMEntityToContact] EC ON EC.intEntityId = ER.intEntityId AND EC.ysnDefaultContact = 1  
										JOIN tblEMEntity EY ON EY.intEntityId = EC.intEntityContactId
										WHERE ER.intEventId=EV.intEventId AND LTRIM(RTRIM(ISNULL(EY.strEmail,''))) <> ''
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)														
	FROM	tblCTEvent EV																
	WHERE	intEventId = @intEventId	

	RETURN @strStatus;	
END