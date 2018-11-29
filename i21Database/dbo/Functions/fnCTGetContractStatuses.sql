CREATE FUNCTION [dbo].[fnCTGetContractStatuses]
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
										', ' + CS.strContractStatus											
										FROM tblCTContractDetail CD																								
										JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
										WHERE CD.intContractHeaderId=CH.intContractHeaderId																			
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)														
	FROM tblCTContractHeader CH																
	WHERE intContractHeaderId = @intContractHeaderId	

	RETURN @strStatus COLLATE Latin1_General_CI_AS ;	
END