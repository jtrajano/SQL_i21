CREATE FUNCTION [dbo].[fnAPCreateVoucherAllocation]
(
	@allocationId INT,
	@amount DECIMAL(18,2),
	@units DECIMAL(18,2)
)
RETURNS @returntable TABLE
(
	intGLAllocationId INT,
	intAccountId INT,
	strAccountId NVARCHAR(50),
	dblTotal DECIMAL(18,6),
	dblUnits DECIMAL(18,2)
)
AS
BEGIN
	INSERT @returntable
	SELECT
		@allocationId,
		A.intAccountId,
		B.strAccountId,
		CAST(@amount * (A.dblPercentage / 100) AS DECIMAL(18,2)),
		CAST(@units * (A.dblPercentage / 100) AS DECIMAL(18,2))
	FROM tblGLAccountReallocationDetail A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
	WHERE A.intAccountReallocationId = @allocationId
	RETURN;
END
