CREATE PROCEDURE [dbo].[uspGLRegenerateAccountRange] 
	@result NVARCHAR (20) OUTPUT
AS
SET NOCOUNT ON;
BEGIN TRY
	DECLARE @intLength INT
	SELECT TOP 1 @intLength = intLength - 1  FROM tblGLAccountStructure WHERE strType = 'Primary'
	;WITH R AS(
		SELECT strAccountType, CAST(LEFT(intMinRange, 1) AS NVARCHAR) strPrefix FROM tblGLAccountRange
	),
	R1 AS (
		SELECT * FROM R A CROSS APPLY(
			SELECT CAST( A.strPrefix + REPLICATE('0', @intLength) AS int) intMinRange,CAST( A.strPrefix + REPLICATE('9', @intLength) AS INT) intMaxRange
		)U
	)
	UPDATE A 
	SET intMinRange = B.intMinRange , intMaxRange =B.intMaxRange
	FROM tblGLAccountRange A 
	JOIN R1 B ON A.strAccountType = B.strAccountType
	WHERE A.intMinRange IS NOT NULL AND A.intMaxRange IS NOT NULL

	SET @result = 'SUCCESS'
END TRY
BEGIN CATCH
	SELECT @result = ERROR_MESSAGE()
END CATCH