CREATE FUNCTION [dbo].[fnPATCountStockStatus]
(
	@strStockStatus AS NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
	
	DECLARE @stockStatusCount AS INT
		SELECT @stockStatusCount = ISNULL(Count(*),0) FROM tblPATCustomerVolume CVV
		INNER JOIN tblARCustomer ARR
			ON ARR.intEntityCustomerId = CVV.intCustomerPatronId
		WHERE ARR.strStockStatus = @strStockStatus
	RETURN @stockStatusCount
END