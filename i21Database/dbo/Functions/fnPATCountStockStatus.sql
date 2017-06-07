CREATE FUNCTION [dbo].[fnPATCountStockStatus]
(
	@strStockStatus AS NVARCHAR(50),
	@intRefundId AS INT = 0
)
RETURNS INT
AS
BEGIN
	
	DECLARE @stockStatusCount AS INT
	IF(@intRefundId = 0)
		SELECT @stockStatusCount = ISNULL(Count(DISTINCT ARR.intEntityId),0) FROM tblPATCustomerVolume CVV
		INNER JOIN tblARCustomer ARR
			ON ARR.intEntityId = CVV.intCustomerPatronId
		WHERE ARR.strStockStatus = @strStockStatus AND CVV.ysnRefundProcessed <> 1 AND CVV.dblVolume <> 0
	ELSE
		SELECT @stockStatusCount = ISNULL(Count(*),0) FROM (SELECT DISTINCT intCustomerId,intRefundId,strStockStatus FROM tblPATRefundCustomer) RC
		WHERE strStockStatus = @strStockStatus AND intRefundId = @intRefundId
	RETURN @stockStatusCount
END