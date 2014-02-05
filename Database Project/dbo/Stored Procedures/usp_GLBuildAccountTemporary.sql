CREATE PROCEDURE  [dbo].[usp_GLBuildAccountTemporary]
@intUserID INT
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
    ,intAccountGroupID			INT
    ,intAccountSegmentID		INT
    ,intAccountStructureID		INT
    ,strAccountSegmentID		NVARCHAR(100)
)

CREATE TABLE #PrimaryAccounts
(
	 strCode					NVARCHAR(50)
	,strPrimary					NVARCHAR(50)
	,strSegment					NVARCHAR(50)
	,strDescription				NVARCHAR(300)
	,strAccountGroup			NVARCHAR(50)	
    ,intAccountGroupID			INT
    ,intAccountSegmentID		INT
    ,intAccountStructureID		INT
    ,strAccountSegmentID		NVARCHAR(100)
)

INSERT INTO #PrimaryAccounts
SELECT a.strCode,'', '', a.strDescription, b.strAccountGroup, a.intAccountGroupID, x.intAccountSegmentID, a.intAccountStructureID, x.intAccountSegmentID AS strAccountSegmentID
FROM tblGLTempAccountToBuild x
LEFT JOIN tblGLAccountSegment a 
ON x.intAccountSegmentID = a.intAccountSegmentID
LEFT JOIN tblGLAccountGroup b
ON a.intAccountGroupID = b.intAccountGroupID
LEFT JOIN tblGLAccountStructure c
ON a.intAccountStructureID = c.intAccountStructureID
WHERE x.intUserID = @intUserID and c.strType = 'Primary'

CREATE TABLE #ConstructAccount
(
	 strCode					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strPrimary					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strSegment					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strDescription				NVARCHAR(300)
	,strAccountGroup			NVARCHAR(50)
	,intAccountGroupID			INT
	,intAccountSegmentID		INT
	,intAccountStructureID		INT
	,strAccountSegmentID		NVARCHAR(100)
)

CREATE TABLE #Structure
(
	 strMask				NVARCHAR(100)
	,strType				NVARCHAR(17)
	,intAccountStructureID	INT
)

INSERT INTO #Structure 
SELECT strMask, strType, intAccountStructureID
FROM tblGLAccountStructure WHERE strType <> 'Divider'
ORDER BY intSort DESC

CREATE TABLE #Segments
(
	 strCode 					NVARCHAR(150)
	,strDescription 	        NVARCHAR(300)
    ,intAccountStructureID		INT
	,intAccountSegmentID		INT
	,strAccountSegmentID		NVARCHAR(100)
)


INSERT INTO #Segments
SELECT a.strCode, a.strDescription, a.intAccountStructureID, a.intAccountSegmentID, a.intAccountSegmentID AS strAccountSegmentID
FROM tblGLTempAccountToBuild x
LEFT JOIN tblGLAccountSegment a 
ON x.intAccountSegmentID = a.intAccountSegmentID
LEFT JOIN tblGLAccountStructure c
ON a.intAccountStructureID = c.intAccountStructureID
WHERE x.intUserID = @intUserID and c.strType = 'Segment'
ORDER BY a.strCode

DECLARE @iStructureType INT
DECLARE @strType		NVARCHAR(20)
DECLARE @strMask		NVARCHAR(50)
DECLARE @strDivider		NVARCHAR(10)

SET @strDivider = (Select Top 1 strMask from tblGLAccountStructure where strType = 'Divider')

WHILE EXISTS(SELECT 1 FROM #Structure)
BEGIN
	SELECT @strMask = strMask, @strType = strType, @iStructureType = intAccountStructureID FROM #Structure
	IF @strType = 'Primary' 
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM #ConstructAccount)
			 BEGIN
				TRUNCATE TABLE #TempResults
								
				INSERT INTO #TempResults
				SELECT PA.strCode, REPLICATE('0',(select 8 - intLength from tblGLAccountStructure where strType = 'Primary')) + PA.strCode AS strPrimary, '' as strSegment, PA.strDescription,
					PA.strAccountGroup, PA.intAccountGroupID, PA.intAccountStructureID, PA.intAccountSegmentID, PA.intAccountSegmentID AS strAccountSegmentID
				FROM #PrimaryAccounts PA
			 END
			ELSE
			 BEGIN
				IF EXISTS (SELECT 1 FROM #PrimaryAccounts)
				BEGIN
					TRUNCATE TABLE #TempResults
				
					INSERT INTO #TempResults
					SELECT CA.strCode + @strDivider + PA.strCode AS strCode, CA.strPrimary + @strDivider + PA.strCode AS strPrimary, '' as strSegment, CA.strDescription + @strDivider + PA.strDescription AS strDescription,
						PA.strAccountGroup, PA.intAccountGroupID, PA.intAccountStructureID, PA.intAccountSegmentID, PA.intAccountSegmentID AS strAccountSegmentID
					FROM #ConstructAccount CA, #PrimaryAccounts PA
					WHERE PA.intAccountStructureID = @iStructureType
				END
			 END
			DELETE FROM #PrimaryAccounts WHERE intAccountStructureID = @iStructureType
		END

	ELSE IF @strType = 'Segment'
		BEGIN
			IF EXISTS(SELECT 1 FROM #Segments WHERE intAccountStructureID = @iStructureType) AND EXISTS (SELECT 1 FROM #Segments)
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM #ConstructAccount)
					 BEGIN
  						INSERT INTO #TempResults ([strCode], [strPrimary], [strSegment], [strDescription], [intAccountStructureID], [intAccountSegmentID], [strAccountSegmentID])
						SELECT S.strCode, S.strCode, S.strCode, S.strDescription, S.intAccountStructureID, S.intAccountSegmentID, S.intAccountSegmentID AS strAccountSegmentID FROM #Segments S  
						WHERE S.intAccountStructureID = @iStructureType										
					 END
					ELSE
					 BEGIN
						IF EXISTS (SELECT 1 FROM #Segments) 
						BEGIN
							TRUNCATE TABLE #TempResults

							INSERT INTO #TempResults ([strCode], [strPrimary], [strSegment], [strDescription], [strAccountGroup], [intAccountGroupID], [intAccountStructureID], [intAccountSegmentID], [strAccountSegmentID])
							SELECT CA.strCode + @strDivider + S.strCode AS strCode, strPrimary, CA.strSegment + '' + S.strCode AS strSegment, CA.strDescription + @strDivider + S.strDescription AS strDescription
								 ,CA.strAccountGroup, CA.intAccountGroupID, CA.intAccountStructureID, S.intAccountSegmentID, CA.strAccountSegmentID + ';' + CAST(S.intAccountSegmentID as NVARCHAR(50)) AS strAccountSegmentID
							FROM #ConstructAccount CA, #Segments S
							WHERE S.intAccountStructureID = @iStructureType  							
					    END
					 END
					DELETE FROM #Segments WHERE intAccountStructureID = @iStructureType
				END
			ELSE
				BEGIN
					DELETE FROM #Structure
				END
		END

	TRUNCATE TABLE #ConstructAccount

	INSERT INTO #ConstructAccount
	SELECT strCode,strPrimary,strSegment,strDescription,strAccountGroup,intAccountGroupID,intAccountSegmentID,intAccountStructureID,strAccountSegmentID FROM #TempResults

	DELETE FROM #Structure WHERE intAccountStructureID = @iStructureType	
END

IF EXISTS (SELECT * FROM tblGLTempAccount WHERE intUserID = @intUserID)
BEGIN
	DELETE tblGLTempAccount WHERE intUserID = @intUserID
END

INSERT INTO tblGLTempAccount
SELECT strCode AS strAccountID, 
	   strPrimary, 
	   strSegment,
	   strDescription,
	   strAccountGroup,
	   intAccountGroupID,
	   strAccountSegmentID,	   
	   intAccountUnitID = NULL,
	   ysnSystem = 1,
	   ysnActive = 1,
	   @intUserID AS intUserID,	   
	   getDate() AS dtmCreated	   	   
FROM #ConstructAccount
WHERE strCode NOT IN (SELECT strAccountID FROM tblGLAccount)	   
ORDER BY strCode		


DROP TABLE #TempResults
DROP TABLE #PrimaryAccounts
DROP TABLE #Structure	
DROP TABLE #Segments
DROP TABLE #ConstructAccount

DELETE tblGLTempAccountToBuild WHERE intUserID = @intUserID

GO
