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
												', ' +	LTRIM(BL.intBillId)
										FROM	tblAPBillDetail BD
										JOIN	tblAPBill		BL	ON BL.intBillId	=	BD.intBillId
										WHERE BD.intContractHeaderId=CH.intContractHeaderId AND BL.intTransactionType = 2
										FOR XML PATH('')
								   )											
									,1,2, ''
								)
	FROM tblCTContractHeader CH
	WHERE intContractHeaderId = @intContractHeaderId

	RETURN REPLACE(@strStatus,' ','');	
END