﻿CREATE FUNCTION [dbo].[fnPATCountStockStatus]
(
	@strStockStatus AS NVARCHAR(50),
	@intRefundId AS INT = 0
)
RETURNS INT
AS
BEGIN
	
	DECLARE @stockStatusCount AS INT
	IF(@intRefundId = 0)
		SELECT @stockStatusCount = ISNULL(Count(*),0) FROM tblPATCustomerVolume CVV
		INNER JOIN tblARCustomer ARR
			ON ARR.intEntityCustomerId = CVV.intCustomerPatronId
		WHERE ARR.strStockStatus = @strStockStatus AND CVV.ysnRefundProcessed <> 1
	ELSE
		SELECT @stockStatusCount = ISNULL(Count(*),0) FROM tblPATRefundCustomer RC
		WHERE strStockStatus = @strStockStatus AND intRefundId = @intRefundId
	RETURN @stockStatusCount
END