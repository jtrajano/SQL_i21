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
									', ' + LTRIM(ER.intEntityId)											
									FROM tblCTEventRecipient ER																								
									WHERE ER.intEventId=EV.intEventId AND ER.strEntityType = 'User'
									FOR XML PATH('')
							   )											
								,1,2, ''													
							)														
	FROM	tblCTEvent EV																
	WHERE	intEventId = @intEventId	

	RETURN @ids;	
END
