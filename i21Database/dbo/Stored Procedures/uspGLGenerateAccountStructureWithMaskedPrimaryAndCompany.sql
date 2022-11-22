CREATE PROCEDURE [dbo].[uspGLGenerateAccountStructureWithMaskedPrimaryAndCompany]
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
BEGIN TRANSACTION

TRUNCATE TABLE tblGLMaskedAccountStructureTemp

BEGIN TRY
	DECLARE 
		@strPrimaryMask NVARCHAR(50),
		@strCompanyMask NVARCHAR(50),
		@strDivider NVARCHAR(10)

	SELECT TOP 1 @strDivider = strMask FROM [dbo].[tblGLAccountStructure] WHERE strType = 'Divider'

	SELECT TOP 1  @strPrimaryMask = REPLICATE('X', A.intLength)
	FROM [dbo].[tblGLAccountStructure] A
	JOIN [dbo].[tblGLSegmentType] B
		ON A.intStructureType = B.intSegmentTypeId
	WHERE A.intStructureType = 1

	SELECT TOP 1  @strCompanyMask = REPLICATE('X', A.intLength)
	FROM [dbo].[tblGLAccountStructure] A
	JOIN [dbo].[tblGLSegmentType] B
		ON A.intStructureType = B.intSegmentTypeId
	WHERE A.intStructureType = 6

	CREATE TABLE #tblTempResults
	(
		strCode					NVARCHAR(50)
		,strPrimary					NVARCHAR(50)
		,strSegment					NVARCHAR(50)
		,intAccountStructureId		INT
		,intAccountSegmentId		INT
		,strAccountSegmentId		NVARCHAR(100)
	)

	CREATE TABLE #tblPrimaryAccounts
	(
		strCode					NVARCHAR(50)
		,strPrimary					NVARCHAR(50)
		,strSegment					NVARCHAR(50)
		,intAccountStructureId		INT
		,intAccountSegmentId		INT
		,strAccountSegmentId		NVARCHAR(100)
	)

	-- Insert 1 masked Primary Segment
	INSERT INTO #tblPrimaryAccounts
	SELECT TOP 1
		strCode = REPLICATE('X', B.intLength)
		,''
		,''
		,B.intAccountStructureId
		,-1
		,-1 AS strAccountSegmentId
	FROM tblGLAccountSegment A
	JOIN tblGLAccountStructure B
		ON A.intAccountStructureId = B.intAccountStructureId
	WHERE B.strType = 'Primary'

	CREATE TABLE #tblConstructAccount
	(
		strCode					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,strPrimary					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,strSegment					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,intAccountSegmentId		INT
		,intAccountStructureId		INT
		,strAccountSegmentId		NVARCHAR(100)
	)

	DECLARE @Structure TABLE
	(
		strMask				NVARCHAR(100)
		,strType				NVARCHAR(17)
		,intAccountStructureId	INT
		,intSort				INT
	)

	INSERT INTO @Structure 
	SELECT strMask, strType, intAccountStructureId, intSort
	FROM tblGLAccountStructure WHERE strType <> 'Divider'
	ORDER BY intSort DESC

	CREATE TABLE #tblSegments
	(
			strCode 					NVARCHAR(150)
		,intAccountStructureId		INT
		,intAccountSegmentId		INT
		,strAccountSegmentId		NVARCHAR(100)
	)

	INSERT INTO #tblSegments
	SELECT 
		strCode = CASE WHEN B.intStructureType = 6 THEN REPLICATE('X', B.intLength) ELSE A.strCode END
		,A.intAccountStructureId
		,intAccountSegmentId = CASE WHEN B.intStructureType = 6 THEN 0 ELSE A.intAccountSegmentId END
		,strAccountSegmentId = CASE WHEN B.intStructureType = 6 THEN 0 ELSE A.intAccountSegmentId END
	FROM tblGLAccountSegment A
	JOIN tblGLAccountStructure B
		ON A.intAccountStructureId = B.intAccountStructureId
	WHERE B.strType = 'Segment'
	ORDER BY B.intSort
	
	-- Remove duplicate masked company segment
	;WITH CTE AS (
		SELECT 
			intRowId = ROW_NUMBER() OVER (PARTITION BY strCode, intAccountStructureId, intAccountSegmentId, strAccountSegmentId 
									ORDER BY strCode, intAccountStructureId, intAccountSegmentId, strAccountSegmentId)
			,*
		FROM #tblSegments
	) 
	DELETE CTE WHERE intRowId <> 1

	DECLARE 
		@iStructureType INT,
		@strType NVARCHAR(20)

	WHILE EXISTS(SELECT 1 FROM @Structure)
	BEGIN
		SELECT TOP 1 @iStructureType = intAccountStructureId, @strType = strType FROM @Structure ORDER BY intSort

		IF @strType = 'Primary'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM #tblConstructAccount)
					BEGIN
					TRUNCATE TABLE #tblTempResults
									
					INSERT INTO #tblTempResults
					SELECT 
						PA.strCode
						,REPLICATE('0',(SELECT 8 - intLength FROM tblGLAccountStructure WHERE strType = 'Primary')) + PA.strCode AS strPrimary
						,'' AS strSegment
						,PA.intAccountStructureId
						,PA.intAccountSegmentId
						,PA.intAccountSegmentId AS strAccountSegmentId
					FROM #tblPrimaryAccounts PA
					END
				ELSE
					BEGIN
					IF EXISTS (SELECT 1 FROM #tblPrimaryAccounts)
					BEGIN
						TRUNCATE TABLE #tblTempResults
					
						INSERT INTO #tblTempResults
						SELECT CA.strCode + @strDivider + PA.strCode AS strCode, CA.strPrimary + @strDivider + PA.strCode AS strPrimary, '' as strSegment, 
						PA.intAccountStructureId, PA.intAccountSegmentId, PA.intAccountSegmentId AS strAccountSegmentId
						FROM #tblConstructAccount CA 
						INNER JOIN #tblPrimaryAccounts PA ON 1 = 1
						WHERE PA.intAccountStructureId = @iStructureType
					END
					END
				DELETE FROM #tblPrimaryAccounts WHERE intAccountStructureId = @iStructureType
		END
		ELSE IF @strType = 'Segment'
		BEGIN
			IF EXISTS(SELECT 1 FROM #tblSegments WHERE intAccountStructureId = @iStructureType) AND EXISTS (SELECT 1 FROM #tblSegments)
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM #tblConstructAccount)
				BEGIN
					INSERT INTO #tblTempResults ([strCode], [strPrimary], [strSegment], [intAccountStructureId], [intAccountSegmentId], [strAccountSegmentId])
					SELECT S.strCode, S.strCode, S.strCode, S.intAccountStructureId, S.intAccountSegmentId, S.intAccountSegmentId AS strAccountSegmentId 
					FROM #tblSegments S  
					WHERE S.intAccountStructureId = @iStructureType										
				END
				ELSE
					BEGIN
					IF EXISTS (SELECT 1 FROM #tblSegments) 
					BEGIN
						TRUNCATE TABLE #tblTempResults
						INSERT INTO #tblTempResults ([strCode], [strPrimary], [strSegment], [intAccountStructureId], [intAccountSegmentId], [strAccountSegmentId])
						SELECT CA.strCode + @strDivider + S.strCode AS strCode
								,strPrimary
								,CA.strSegment + '' + S.strCode AS strSegment
								,CA.intAccountStructureId, S.intAccountSegmentId, CA.strAccountSegmentId + ';' + CAST(S.intAccountSegmentId as NVARCHAR(50)) AS strAccountSegmentId
						FROM #tblConstructAccount CA
						INNER JOIN #tblSegments S ON 1=1
						WHERE S.intAccountStructureId = @iStructureType  							
					END
				END

				DELETE FROM #tblSegments WHERE intAccountStructureId = @iStructureType
			END
			ELSE
			BEGIN
				DELETE FROM @Structure
			END
		END

		TRUNCATE TABLE #tblConstructAccount

		INSERT INTO #tblConstructAccount
		SELECT strCode, strPrimary, strSegment, intAccountSegmentId, intAccountStructureId, strAccountSegmentId FROM #tblTempResults
		
		DELETE FROM @Structure WHERE intAccountStructureId = @iStructureType
	END

	INSERT INTO tblGLMaskedAccountStructureTemp
	SELECT strAccountSegmentId, strCode, 1 FROM #tblConstructAccount

	DROP TABLE #tblTempResults
	DROP TABLE #tblPrimaryAccounts
	DROP TABLE #tblSegments
	DROP TABLE #tblConstructAccount

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	DECLARE @ErrorMessage NVARCHAR(4000),  
			@ErrorSeverity INT,
			@ErrorState INT;  

	SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE();  

	RAISERROR (
		@ErrorMessage, -- Message text.  
		@ErrorSeverity, -- Severity.  
		@ErrorState -- State.  
	);  
END CATCH
