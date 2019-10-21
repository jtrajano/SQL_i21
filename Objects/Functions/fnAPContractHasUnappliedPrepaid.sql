CREATE FUNCTION [dbo].[fnAPContractHasUnappliedPrepaid]
(
	@intContractDetailId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @hasUnapplied BIT = 0;

	IF EXISTS(SELECT 1 
			FROM tblAPBill A
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			WHERE A.intTransactionType = 2 AND A.dblAmountDue > 0 AND B.intContractDetailId = @intContractDetailId)
	BEGIN
		SET @hasUnapplied = 1;
	END

	RETURN @hasUnapplied;
END
