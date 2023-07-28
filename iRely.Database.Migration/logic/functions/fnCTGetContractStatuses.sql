--liquibase formatted sql

-- changeset Von:fnCTGetContractStatuses.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetContractStatuses]
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

	RETURN ISNULL(@strStatus,'Incomplete');	
END



