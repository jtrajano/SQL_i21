CREATE FUNCTION [dbo].[fnGRCheckBillIfFromAdjustSettlements]
(
	@intBillId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnFromAdjustSettlements BIT = 0

	IF EXISTS(SELECT 1 FROM tblGRAdjustSettlements WHERE intTypeId = 1 /*PURCHASE*/ AND intBillId = @intBillId)
	BEGIN
		SET @ysnFromAdjustSettlements = 1
	END

	IF EXISTS(
		SELECT 1
		FROM tblGRAdjustSettlements A
		INNER JOIN tblGRAdjustSettlementsSplit B
			ON B.intAdjustSettlementId = A.intAdjustSettlementId
		WHERE A.intTypeId = 1
			AND B.intBillId = @intBillId
	)
	BEGIN
		SET @ysnFromAdjustSettlements = 1
	END
	

	RETURN ISNULL(@ysnFromAdjustSettlements,0)

END