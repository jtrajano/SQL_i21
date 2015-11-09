CREATE FUNCTION [dbo].[fnCTGetBillIds]
(
	@intContractHeaderId INT
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	@strStatus AS NVARCHAR(MAX)

	SELECT	@strStatus	=	STUFF(															
								   (
										SELECT	DISTINCT												
										',' + LTRIM(BD.intBillId)
										FROM tblAPBillDetail BD
										WHERE BD.intContractHeaderId=CH.intContractHeaderId
										FOR XML PATH('')
								   )											
									,1,2, ''
								)
	FROM tblCTContractHeader CH
	WHERE intContractHeaderId = @intContractHeaderId

	RETURN @strStatus;	
END