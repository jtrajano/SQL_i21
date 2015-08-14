CREATE PROCEDURE [dbo].[uspGLGenerateAccountRange]
AS
	SET NOCOUNT ON;
	UPDATE tblGLAccountGroup set intAccountRangeId = null
	DELETE FROM tblGLAccountRange
	
	DECLARE @intLength INT
	SELECT TOP 1 @intLength = intLength - 1  FROM tblGLAccountStructure WHERE strType = 'Primary'
	SET IDENTITY_INSERT tblGLAccountRange ON
	INSERT INTO tblGLAccountRange(intAccountRangeId,strAccountType,intMinRange,intMaxRange)
	SELECT 0,'All', NULL,NULL  UNION
	SELECT 1,'Asset', CAST( '1' + REPLICATE('0', @intLength) AS int),CAST( '1' + REPLICATE('9', @intLength) AS INT)  UNION
	SELECT 2,'Liability' , CAST( '2' + REPLICATE('0', @intLength) AS int),CAST( '2' + REPLICATE('9', @intLength) AS INT) UNION
	SELECT 3,'Equity', CAST( '3' + REPLICATE('0', @intLength) AS int),CAST( '3' + REPLICATE('9', @intLength) AS INT) UNION
	SELECT 4,'Revenue' , CAST( '4' + REPLICATE('0', @intLength) AS int),CAST( '4' + REPLICATE('9', @intLength) AS INT) UNION
	SELECT 5,'Expense', CAST( '5' + REPLICATE('0', @intLength) AS int),CAST( '5' + REPLICATE('9', @intLength) AS INT) UNION
	SELECT 6,'Sales', CAST( '6' + REPLICATE('0', @intLength) AS int),CAST( '5' + REPLICATE('9', @intLength) AS INT) UNION
	SELECT 7,'Cost of Goods Sold', CAST( '7' + REPLICATE('0', @intLength) AS int),CAST( '5' + REPLICATE('9', @intLength) AS INT)
	SET IDENTITY_INSERT tblGLAccountRange OFF
	UPDATE A SET intAccountRangeId = B.intAccountRangeId
	FROM  tblGLAccountGroup A INNER JOIN tblGLAccountRange B ON A.strAccountType = B.strAccountType
	UPDATE tblGLAccountRange SET intAccountGroupId = 0 WHERE strAccountType = 'All'
	UPDATE A SET intAccountGroupId = B.intAccountGroupId FROM tblGLAccountRange A
	INNER JOIN tblGLAccountGroup B ON B.strAccountGroup = A.strAccountType AND B.intParentGroupId = 0
RETURN 0
