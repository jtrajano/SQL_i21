CREATE FUNCTION [dbo].[fnCTGetPrepaidIdsItemContract]
(
	@intItemContractHeaderId INT
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	@strIds AS NVARCHAR(MAX)

	SELECT	@strIds	=	STUFF(															
								   (
										SELECT	DISTINCT												
												', ' +	LTRIM(IV.intInvoiceId)
										FROM	tblARInvoiceDetail	ID
										JOIN	tblARInvoice		IV ON IV.intInvoiceId = ID.intInvoiceId
										WHERE	IV.strTransactionType = 'Customer Prepayment' AND ID.intItemContractHeaderId = @intItemContractHeaderId
										FOR XML PATH('')
								   ),1,2, ''
								)
	FROM	tblCTItemContractHeader CH
	WHERE	intItemContractHeaderId = @intItemContractHeaderId

	RETURN REPLACE(@strIds,' ','');	
END 
