GO
	PRINT 'Start generating Account Range for Account Types'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountRange)
	BEGIN
		DECLARE @intLength INT
		SELECT TOP 1 @intLength = intLength - 1  FROM tblGLAccountStructure WHERE strType = 'Primary'
		SET IDENTITY_INSERT tblGLAccountRange ON
		INSERT INTO tblGLAccountRange(intAccountRangeId,strAccountType,intMinRange,intMaxRange)
		SELECT 1,'Asset', CAST( '1' + REPLICATE('0', @intLength) AS int),CAST( '1' + REPLICATE('9', @intLength) AS INT)  UNION
		SELECT 2,'Liability' , CAST( '2' + REPLICATE('0', @intLength) AS int),CAST( '2' + REPLICATE('9', @intLength) AS INT) UNION
		SELECT 3,'Equity', CAST( '3' + REPLICATE('0', @intLength) AS int),CAST( '3' + REPLICATE('9', @intLength) AS INT) UNION
		SELECT 4,'Revenue' , CAST( '4' + REPLICATE('0', @intLength) AS int),CAST( '4' + REPLICATE('9', @intLength) AS INT) UNION
		SELECT 5,'Expense', CAST( '5' + REPLICATE('0', @intLength) AS int),CAST( '5' + REPLICATE('9', @intLength) AS INT)
		SET IDENTITY_INSERT tblGLAccountRange OFF
	END
GO
	UPDATE A SET intAccountRangeId = B.intAccountRangeId
	FROM  tblGLAccountGroup A INNER JOIN tblGLAccountRange B ON A.strAccountType = B.strAccountType
GO
	PRINT 'Finished generating Account Range for Account Types'
GO