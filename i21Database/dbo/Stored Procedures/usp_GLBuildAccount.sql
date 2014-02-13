CREATE PROCEDURE  [dbo].[usp_GLBuildAccount]
@intUserID nvarchar(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

-- +++++ INSERT ACCOUNT ID +++++ --
INSERT INTO tblGLAccount ([strAccountID],[strDescription],[intAccountGroupID],[intAccountUnitID],[ysnSystem],[ysnActive])
SELECT strAccountID, 
	   strDescription,
	   intAccountGroupID,
	   intAccountUnitID,
	   ysnSystem,
	   ysnActive
FROM tblGLTempAccount
WHERE intUserID = @intUserID and strAccountID NOT IN (SELECT strAccountID FROM tblGLAccount)	
ORDER BY strAccountID

-- +++++ DELETE LEGACY COA TABLE AT 1st BUILD +++++ --
IF NOT EXISTS(SELECT 1 FROM tblGLCOACrossReference)
BEGIN
	DELETE glactmst	
END

-- +++++ INSERT CROSS REFERENCE +++++ --
IF (select SUM(intLength) from tblGLAccountStructure where strType = 'Segment') <= 8
BEGIN
	INSERT INTO tblGLCOACrossReference ([inti21ID],[stri21ID],[strExternalID], [strCurrentExternalID], [strCompanyID], [intConcurrencyId])
	SELECT (SELECT intAccountID FROM tblGLAccount A WHERE A.strAccountID = B.strAccountID) as inti21ID,
		   B.strAccountID as stri21ID,
		   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50))  + '.' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strSegment as strExternalID , 	   
		   B.strPrimary + '-' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strSegment as strCurrentExternalID,
		   'Legacy' as strCompanyID,
		   1
	FROM tblGLTempAccount B
	WHERE intUserID = @intUserID and strAccountID NOT IN (SELECT stri21ID FROM tblGLCOACrossReference)	
	ORDER BY strAccountID
END
ELSE
BEGIN
	-- HANDLE OUT OF STANDARD ACCOUNT STRUCTURE (e.i REPowell)
	INSERT INTO tblGLCOACrossReference ([inti21ID],[stri21ID],[strExternalID], [strCurrentExternalID], [strCompanyID], [intConcurrencyId])
	SELECT (SELECT intAccountID FROM tblGLAccount A WHERE A.strAccountID = B.strAccountID) as inti21ID,
		   B.strAccountID as stri21ID,
		   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50)) + SUBSTRING(B.strSegment,0,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = 'Segment'  order by intSort)) + '.' + 
				REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment' and intAccountStructureID <> (select TOP 1 intAccountStructureID from tblGLAccountStructure where strType = 'Segment' order by intSort))) +  
				SUBSTRING(B.strSegment,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = 'Segment'  order by intSort),(select SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) as strExternalID , 	   								
		   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50)) + SUBSTRING(B.strSegment,0,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = 'Segment'  order by intSort)) + '-' + 
				REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment' and intAccountStructureID <> (select TOP 1 intAccountStructureID from tblGLAccountStructure where strType = 'Segment' order by intSort))) +  
				SUBSTRING(B.strSegment,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = 'Segment'  order by intSort),(select SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) as strCurrentExternalID,
		   'Origin' as strCompanyID,
		   1
	FROM tblGLTempAccount B
	WHERE intUserID = @intUserID and strAccountID NOT IN (SELECT stri21ID FROM tblGLCOACrossReference)	
	ORDER BY strAccountID
END

-- +++++ INSERT SEGMENT MAPPING +++++ --
WHILE EXISTS(SELECT 1 FROM tblGLTempAccount WHERE intUserID = @intUserID)
BEGIN
	Declare @ID INT = (SELECT TOP 1 cntID FROM tblGLTempAccount WHERE intUserID = @intUserID)
	Declare @segmentcodes varchar(200) = (SELECT TOP 1 strAccountSegmentID FROM tblGLTempAccount WHERE intUserID = @intUserID)
	Declare @segmentID varchar(200) = null
	Declare @accountID INT = (SELECT TOP 1 intAccountID FROM tblGLAccount WHERE strAccountID = (SELECT TOP 1 strAccountID FROM tblGLTempAccount WHERE intUserID = @intUserID))

	WHILE LEN(@segmentcodes) > 0
	BEGIN
		IF PATINDEX('%;%',@segmentcodes) > 0
		BEGIN
			SET @segmentID = SUBSTRING(@segmentcodes, 0, PATINDEX('%;%',@segmentcodes))
			
			INSERT INTO tblGLAccountSegmentMapping ([intAccountID], [intAccountSegmentID]) values (@accountID, @segmentID)
			UPDATE tblGLAccountSegment SET ysnBuild = 1 WHERE intAccountSegmentID = @segmentID
			UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureID = (SELECT intAccountStructureID FROM tblGLAccountSegment WHERE intAccountSegmentID = @segmentID)

			SET @segmentcodes = SUBSTRING(@segmentcodes, LEN(@segmentID + ';') + 1, LEN(@segmentcodes))
		END
		ELSE
		BEGIN
			SET @segmentID = @segmentcodes
			SET @segmentcodes = NULL
			
			INSERT INTO tblGLAccountSegmentMapping ([intAccountID], [intAccountSegmentID]) values (@accountID, @segmentID)
			UPDATE tblGLAccountSegment SET ysnBuild = 1 WHERE intAccountSegmentID = @segmentID
			UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureID = (SELECT intAccountStructureID FROM tblGLAccountSegment WHERE intAccountSegmentID = @segmentID)
					
		END
		
		DELETE FROM tblGLTempAccount WHERE cntID = @ID
	END
END


DELETE FROM tblGLTempAccount WHERE intUserID = @intUserID

EXEC usp_GLAccountOriginSync @intUserID
EXEC usp_GLBuildTempCOASegment