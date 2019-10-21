CREATE FUNCTION [dbo].[fnGLCheckScale]
(
	@dblAmount DECIMAL (18,6)
)
RETURNS DECIMAL (18,6)
AS
BEGIN
	DECLARE @dblRoundedAmount DECIMAL (18,6)

	SELECT @dblRoundedAmount = ROUND(@dblAmount,2)
	IF @dblRoundedAmount <> @dblAmount
		RETURN -1

	RETURN 1
END
GO

