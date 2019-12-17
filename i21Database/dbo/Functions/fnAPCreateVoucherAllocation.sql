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
	dblTotal DECIMAL(18,2),
	dblUnits DECIMAL(18,2)
)
AS
BEGIN
	INSERT @returntable
	SELECT
		@allocationId,
		A.intAccountId,
		CAST(@amount * (A.dblPercentage / 100) AS DECIMAL(18,2)),
		CAST(@units * (A.dblPercentage / 100) AS DECIMAL(18,2))
	FROM tblGLAccountReallocationDetail A
	WHERE A.intAccountReallocationId = @allocationId
	RETURN;
END
