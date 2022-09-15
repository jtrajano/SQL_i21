CREATE PROCEDURE [dbo].[uspGLGenerateAccountRange] 
	@result NVARCHAR (20) OUTPUT
AS
	SET NOCOUNT ON;
	
	DECLARE @tbl Table (
		strAccountType NVARCHAR(30) COLLATE Latin1_General_CI_AS,  intAccountGroupId INT
	)

	;WITH accountTypes as
	(
		SELECT 'Asset' strAccountType, 'Asset' strAccountGroup	union 
		SELECT 'Liability'	,'Liability'union 
		SELECT 'Equity'		,'Equity'	union 
		SELECT 'Revenue'	,'Revenue'	union 
		SELECT 'Revenue 2'	,'Revenue'	union 
		SELECT 'Revenue 3'	,'Revenue'	union 
		SELECT 'Revenue 4'	,'Revenue'	union 
		SELECT 'Expense'	,'Expense'	union 
		SELECT 'Expense 2'	,'Expense'	union 
		SELECT 'Expense 3'	,'Expense'	union 
		SELECT 'Expense 4'	,'Expense'	
	)
	INSERT INTO @tbl 
	SELECT A.strAccountType, B.intAccountGroupId from accountTypes A
	INNER JOIN tblGLAccountGroup B ON B.strAccountGroup = A.strAccountGroup
	
	INSERT INTO @tbl SELECT 'All'	,0

		
	BEGIN TRY
	MERGE 
	INTO	dbo.tblGLAccountRange
	WITH	(HOLDLOCK) 
	AS		RangeTable
	USING	(
		select * from @tbl
	) AS RangeHardCodedValues
		ON  RangeTable.strAccountType = RangeHardCodedValues.strAccountType
	WHEN MATCHED THEN 
		UPDATE 
		SET RangeTable.intAccountGroupId = RangeHardCodedValues.intAccountGroupId

	WHEN NOT MATCHED THEN
		INSERT (
			strAccountType
			,intAccountGroupId
			,intConcurrencyId
		)
		VALUES (
			RangeHardCodedValues.strAccountType
			,RangeHardCodedValues.intAccountGroupId
			,1
		);
	--IF (@ysnRangeBuilt = 1)RETURN
	
	DECLARE @intLength INT
	SELECT TOP 1 @intLength = intLength - 1  FROM tblGLAccountStructure WHERE strType = 'Primary'
	;WITH R AS(
		SELECT 'Asset'strAccountType, '1' strPrefix union all
		SELECT 'Liability'strAccountType, '2' strPrefix union all
		SELECT 'Equity'strAccountType, '3' strPrefix union all
		SELECT 'Revenue'strAccountType, '4' strPrefix union all
		SELECT 'Expense'strAccountType, '5' strPrefix 
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
	WHERE A.intMinRange IS NULL AND A.intMaxRange IS NULL

		SET @result = 'SUCCESS'
	END TRY
	BEGIN CATCH
		SELECT @result = ERROR_MESSAGE()
	END CATCH