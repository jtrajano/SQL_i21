CREATE FUNCTION [dbo].[fnCTGetPrepaidIds]
(
	@intContractHeaderId INT
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	@strIds AS NVARCHAR(MAX)

	SELECT	@strIds	=	CASE WHEN intContractTypeId = 1 THEN
							STUFF(															
								   (
										SELECT	DISTINCT												
												', ' +	LTRIM(BL.intBillId)
										FROM	tblAPBillDetail BD
										JOIN	tblAPBill		BL	ON BL.intBillId	=	BD.intBillId
										WHERE BD.intContractHeaderId=CH.intContractHeaderId AND BL.intTransactionType = 2
										FOR XML PATH('')
								   ),1,2, ''
								)
						ELSE
							STUFF(															
								   (
										SELECT	DISTINCT												
												', ' +	LTRIM(IV.intInvoiceId)
										FROM	tblARInvoiceDetail	ID
										JOIN	tblARInvoice		IV ON IV.intInvoiceId = ID.intInvoiceId
										WHERE	IV.strTransactionType = 'Customer Prepayment' AND ID.intContractHeaderId = @intContractHeaderId
										FOR XML PATH('')
								   ),1,2, ''
								)
						END
	FROM	tblCTContractHeader CH
	WHERE	intContractHeaderId = @intContractHeaderId

	RETURN REPLACE(@strIds,' ','');	
END