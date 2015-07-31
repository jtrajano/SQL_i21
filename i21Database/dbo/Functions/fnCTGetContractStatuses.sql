CREATE FUNCTION [dbo].[fnCTGetContractStatuses]
(
	@intContractHeaderId INT
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	@strStatus AS NVARCHAR(MAX)

	--SELECT	@strStatus	=	STUFF(															
	--							   (
	--									SELECT	DISTINCT												
	--									', ' + CD.strContractStatus											
	--									FROM vyuCTContractDetailView CD																								
	--									WHERE CD.intContractHeaderId=CH.intContractHeaderId																			
	--									FOR XML PATH('')
	--							   )											
	--								,1,2, ''													
	--							)														
	--FROM tblCTContractHeader CH																
	--WHERE intContractHeaderId = @intContractHeaderId	

	RETURN @strStatus;	
END