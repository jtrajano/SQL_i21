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
	
	
	INSERT INTO @returntable(intTransactionId)
	SELECT DISTINCT B.intBillId
	FROM tblAPBillDetail BD
	INNER JOIN tblAPBill B
		ON B.intBillId = BD.intBillId
	INNER JOIN @Ids ID
		ON ID.intId = BD.intContractDetailId
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = ID.intId
	WHERE B.intTransactionType = 2 
		AND dblAmountDue != 0
		AND BD.ysnRestricted = 1
		AND BD.intItemId = CD.intItemId

	RETURN
END