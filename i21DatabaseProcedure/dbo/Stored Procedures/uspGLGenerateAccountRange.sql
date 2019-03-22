CREATE PROCEDURE [dbo].[uspGLGenerateAccountRange] 
	@result NVARCHAR (20 ) OUTPUT
AS
	SET NOCOUNT ON;
	--DECLARE @ysnRangeBuilt BIT = 0
	--IF EXISTS(SELECT TOP 1   1 FROM tblGLAccountRange)
		--SET @ysnRangeBuilt = 1
		
	BEGIN TRY
	MERGE 
	INTO	dbo.tblGLAccountRange
	WITH	(HOLDLOCK) 
	AS		RangeTable
	USING	(
		SELECT strAccountType = 'All'		, intAccountGroupId = 0 union all
		SELECT strAccountType = 'Asset'		, intAccountGroupId = 1 union all
		SELECT strAccountType = 'Liability' , intAccountGroupId = 2 union all
		SELECT strAccountType = 'Equity'	, intAccountGroupId = 3 union all
		SELECT strAccountType = 'Revenue'	, intAccountGroupId = 4 union all
		SELECT strAccountType = 'Revenue 2' , intAccountGroupId = 4 union all
		SELECT strAccountType = 'Revenue 3' , intAccountGroupId = 4 union all
		SELECT strAccountType = 'Revenue 4' , intAccountGroupId = 4 union all
		SELECT strAccountType = 'Expense'	, intAccountGroupId = 5 union all
		SELECT strAccountType = 'Expense 2' , intAccountGroupId = 5 union all
		SELECT strAccountType = 'Expense 3' , intAccountGroupId = 5 union all
		SELECT strAccountType = 'Expense 4' , intAccountGroupId = 5 
			
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
		SET @result = 'SUCCESS'
	END TRY
	BEGIN CATCH
		SELECT @result = ERROR_MESSAGE()
	END CATCH
	
GO

