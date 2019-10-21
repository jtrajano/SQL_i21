CREATE FUNCTION [dbo].[fnSCGetPrepaidIds]
(
	@Ids as [Id] READONLY
)
RETURNS @returntable TABLE
(
	intTransactionId INT
)
AS
BEGIN
	DECLARE @intContractTypeId as INT

	SELECT @intContractTypeId = intContractTypeId 
	FROM tblCTContractHeader CH
	INNER JOIN @Ids Id
		ON Id.intId = CH.intContractHeaderId

	IF @intContractTypeId = 1
		BEGIN
			INSERT INTO @returntable(intTransactionId)
			SELECT DISTINCT B.intBillId
			FROM tblAPBillDetail BD
			INNER JOIN tblAPBill B
				ON B.intBillId = BD.intBillId
			INNER JOIN @Ids ID
				ON ID.intId = BD.intContractHeaderId
			WHERE B.intTransactionType = 2 AND dblAmountDue != 0
		END
	ELSE
		BEGIN
			INSERT INTO @returntable(intTransactionId)
			SELECT DISTINCT SI.intInvoiceId
			FROM tblARInvoiceDetail ID
			INNER JOIN tblARInvoice SI
				ON SI.intInvoiceId = ID.intInvoiceId
			INNER JOIN @Ids Id
				ON Id.intId = ID.intContractHeaderId
			WHERE SI.strTransactionType = 'Customer Prepayment' 
		END

	RETURN
END