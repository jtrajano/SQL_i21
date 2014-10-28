CREATE PROCEDURE  [dbo].[uspGLBuildAccountTemporary]
@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

CREATE TABLE #TempResults
(
	 strCode					NVARCHAR(50)
	,strPrimary					NVARCHAR(50)
	,strSegment					NVARCHAR(50)
	,strDescription				NVARCHAR(300)
	,strAccountGroup			NVARCHAR(50)
    ,intAccountGroupId			INT
    ,intAccountSegmentId		INT
    ,intAccountStructureId		INT
    ,strAccountSegmentId		NVARCHAR(100)
)

CREATE TABLE #PrimaryAccounts
(
	 strCode					NVARCHAR(50)
	,strPrimary					NVARCHAR(50)
	,strSegment					NVARCHAR(50)
	,strDescription				NVARCHAR(300)
	,strAccountGroup			NVARCHAR(50)	
    ,intAccountGroupId			INT
    ,intAccountSegmentId		INT
    ,intAccountStructureId		INT
    ,strAccountSegmentId		NVARCHAR(100)
)

INSERT INTO #PrimaryAccounts
SELECT a.strCode,'', '', a.strDescription, b.strAccountGroup, a.intAccountGroupId, x.intAccountSegmentId, a.intAccountStructureId, x.intAccountSegmentId AS strAccountSegmentId
FROM tblGLTempAccountToBuild x
LEFT JOIN tblGLAccountSegment a 
ON x.intAccountSegmentId = a.intAccountSegmentId
LEFT JOIN tblGLAccountGroup b
ON a.intAccountGroupId = b.intAccountGroupId
LEFT JOIN tblGLAccountStructure c
ON a.intAccountStructureId = c.intAccountStructureId
WHERE x.intUserId = @intUserId and c.strType = 'Primary'

CREATE TABLE #ConstructAccount
(
	 strCode					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strPrimary					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strSegment					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strDescription				NVARCHAR(300)
	,strAccountGroup			NVARCHAR(50)
	,intAccountGroupId			INT
	,intAccountSegmentId		INT
	,intAccountStructureId		INT
	,strAccountSegmentId		NVARCHAR(100)
)

CREATE TABLE #Structure
(
	 strMask				NVARCHAR(100)
	,strType				NVARCHAR(17)
	,intAccountStructureId	INT
	,intSort				INT
)

INSERT INTO #Structure 
SELECT strMask, strType, intAccountStructureId, intSort
FROM tblGLAccountStructure WHERE strType <> 'Divider'
ORDER BY intSort DESC

CREATE TABLE #Segments
(
	 strCode 					NVARCHAR(150)
	,strDescription 	        NVARCHAR(300)
    ,intAccountStructureId		INT
	,intAccountSegmentId		INT
	,strAccountSegmentId		NVARCHAR(100)
)


INSERT INTO #Segments
SELECT a.strCode, [strDescription] = CASE WHEN a.[strDescription] <> '' THEN  a.[strDescription] ELSE 'REMOVE_DIVIDER' END
	  ,a.intAccountStructureId, a.intAccountSegmentId, a.intAccountSegmentId AS strAccountSegmentId
FROM tblGLTempAccountToBuild x
LEFT JOIN tblGLAccountSegment a 
ON x.intAccountSegmentId = a.intAccountSegmentId
LEFT JOIN tblGLAccountStructure c
ON a.intAccountStructureId = c.intAccountStructureId
WHERE x.intUserId = @intUserId and c.strType = 'Segment'
ORDER BY a.strCode

DECLARE @iStructureType INT
DECLARE @strType		NVARCHAR(20)
DECLARE @strMask		NVARCHAR(50)
DECLARE @strDivider		NVARCHAR(10)

SET @strDivider = (Select Top 1 strMask from tblGLAccountStructure where strType = 'Divider')

WHILE EXISTS(SELECT 1 FROM #Structure)
BEGIN
	SELECT TOP 1 @strMask = strMask, @strType = strType, @iStructureType = intAccountStructureId FROM #Structure ORDER BY intSort
	IF @strType = 'Primary' 
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM #ConstructAccount)
			 BEGIN
				TRUNCATE TABLE #TempResults
								
				INSERT INTO #TempResults
				SELECT PA.strCode, REPLICATE('0',(select 8 - intLength from tblGLAccountStructure where strType = 'Primary')) + PA.strCode AS strPrimary, '' as strSegment, PA.strDescription,
					PA.strAccountGroup, PA.intAccountGroupId, PA.intAccountStructureId, PA.intAccountSegmentId, PA.intAccountSegmentId AS strAccountSegmentId
				FROM #PrimaryAccounts PA
			 END
			ELSE
			 BEGIN
				IF EXISTS (SELECT 1 FROM #PrimaryAccounts)
				BEGIN
					TRUNCATE TABLE #TempResults
				
					INSERT INTO #TempResults
					SELECT CA.strCode + @strDivider + PA.strCode AS strCode, CA.strPrimary + @strDivider + PA.strCode AS strPrimary, '' as strSegment, CA.strDescription + @strDivider + PA.strDescription AS strDescription,
						PA.strAccountGroup, PA.intAccountGroupId, PA.intAccountStructureId, PA.intAccountSegmentId, PA.intAccountSegmentId AS strAccountSegmentId
					FROM #ConstructAccount CA, #PrimaryAccounts PA
					WHERE PA.intAccountStructureId = @iStructureType
				END
			 END
			DELETE FROM #PrimaryAccounts WHERE intAccountStructureId = @iStructureType
		END

	ELSE IF @strType = 'Segment'
		BEGIN
			IF EXISTS(SELECT 1 FROM #Segments WHERE intAccountStructureId = @iStructureType) AND EXISTS (SELECT 1 FROM #Segments)
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM #ConstructAccount)
					 BEGIN
  						INSERT INTO #TempResults ([strCode], [strPrimary], [strSegment], [strDescription], [intAccountStructureId], [intAccountSegmentId], [strAccountSegmentId])
						SELECT S.strCode, S.strCode, S.strCode, S.strDescription, S.intAccountStructureId, S.intAccountSegmentId, S.intAccountSegmentId AS strAccountSegmentId FROM #Segments S  
						WHERE S.intAccountStructureId = @iStructureType										
					 END
					ELSE
					 BEGIN
						IF EXISTS (SELECT 1 FROM #Segments) 
						BEGIN
							TRUNCATE TABLE #TempResults

							INSERT INTO #TempResults ([strCode], [strPrimary], [strSegment], [strDescription], [strAccountGroup], [intAccountGroupId], [intAccountStructureId], [intAccountSegmentId], [strAccountSegmentId])
							SELECT CA.strCode + @strDivider + S.strCode AS strCode, strPrimary, CA.strSegment + '' + S.strCode AS strSegment, CA.strDescription + @strDivider + S.strDescription AS strDescription
								 ,CA.strAccountGroup, CA.intAccountGroupId, CA.intAccountStructureId, S.intAccountSegmentId, CA.strAccountSegmentId + ';' + CAST(S.intAccountSegmentId as NVARCHAR(50)) AS strAccountSegmentId
							FROM #ConstructAccount CA, #Segments S
							WHERE S.intAccountStructureId = @iStructureType  							
					    END
					 END
					DELETE FROM #Segments WHERE intAccountStructureId = @iStructureType
				END
			ELSE
				BEGIN
					DELETE FROM #Structure
				END
		END

	TRUNCATE TABLE #ConstructAccount

	INSERT INTO #ConstructAccount
	SELECT strCode,strPrimary,strSegment,strDescription,strAccountGroup,intAccountGroupId,intAccountSegmentId,intAccountStructureId,strAccountSegmentId FROM #TempResults

	DELETE FROM #Structure WHERE intAccountStructureId = @iStructureType	
END

IF EXISTS (SELECT * FROM tblGLTempAccount WHERE intUserId = @intUserId)
BEGIN
	DELETE tblGLTempAccount WHERE intUserId = @intUserId
END

INSERT INTO tblGLTempAccount
SELECT strCode AS strAccountId, 
	   strPrimary, 
	   strSegment,
	   REPLACE(strDescription, @strDivider + 'REMOVE_DIVIDER',''),
	   strAccountGroup,
	   intAccountGroupId,
	   strAccountSegmentId,	   
	   intAccountUnitId = NULL,
	   ysnSystem = 0,
	   ysnActive = 1,
	   @intUserId AS intUserId,	   
	   getDate() AS dtmCreated	   	   
FROM #ConstructAccount
WHERE strCode NOT IN (SELECT strAccountId FROM tblGLAccount)	   
ORDER BY strCode		


DROP TABLE #TempResults
DROP TABLE #PrimaryAccounts
DROP TABLE #Structure	
DROP TABLE #Segments
DROP TABLE #ConstructAccount

DELETE tblGLTempAccountToBuild WHERE intUserId = @intUserId