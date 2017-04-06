CREATE FUNCTION [dbo].[fnCTGetEventRecipientId]
(
	@intEventId INT
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	@ids AS NVARCHAR(MAX)

	SELECT	@ids	=	STUFF(															
							   (
									SELECT	DISTINCT												
									', ' + LTRIM(EC.intEntityContactId)											
									FROM tblCTEventRecipient ER		
									JOIN tblEMEntityToContact EC ON EC.intEntityId = ER.intEntityId AND EC.ysnDefaultContact = 1
									WHERE ER.intEventId=EV.intEventId AND ER.strEntityType = 'User'
									FOR XML PATH('')
							   )											
								,1,2, ''													
							)														
	FROM	tblCTEvent EV																
	WHERE	intEventId = @intEventId	

	RETURN @ids;	
END
