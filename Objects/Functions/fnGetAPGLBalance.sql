CREATE FUNCTION [dbo].[fnGetAPGLBalance](@intAccountId INT, @To DATETIME = NULL, @From DATETIME = NULL)
RETURNS NUMERIC(18, 6)
AS
BEGIN

	--If has payment get only the posted
	DECLARE @Balance NUMERIC(18,6) = 0

	IF(@To IS NULL)
	BEGIN
	
		SELECT 
			@Balance = SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit, 0)) 
		FROM tblGLDetail A
	
	END
	ELSE
	BEGIN
	
		IF(@From IS NULL)
		BEGIN
			SET @From = GETDATE()
		END

		SELECT 
			@Balance = SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit, 0)) 
		FROM tblGLDetail A
		WHERE A.dtmDate BETWEEN DATEADD(dd, DATEDIFF(dd, 0, @From), 0) AND DATEADD(dd, DATEDIFF(dd, 0, @To), 0)

	END

	RETURN @Balance

END