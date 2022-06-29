CREATE PROCEDURE [dbo].[uspHDBuildHierarchyFilterString]
	@intCoworkerHierarchyId			AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

DECLARE @intCoworkerHierarchyDetailId INT
DECLARE @strFilterString NVARCHAR(MAX)
DECLARE @strLevel NVARCHAR(MAX)
DECLARE @intParentGroupId INT
DECLARE @intSort INT

DECLARE @strFilterString_NEW NVARCHAR(MAX) = ''

CREATE TABLE #TempHDHierarchy (	
	[intCoworkerHierarchyDetailId]	INT,
	[intCoworkerHierarchyId]		INT,
	[strLevel]						NVARCHAR(MAX),
	[strFilterString]				NVARCHAR(MAX),
	[intParentGroupId]				INT,
	[intSort]						INT,
	[intConcurrencyId]				INT,
	[strDescription]				NVARCHAR(MAX)
);

-- +++++++++++++++++++++++++++++
--		NODE TO BRANCH
-- +++++++++++++++++++++++++++++

INSERT INTO #TempHDHierarchy EXEC ('SELECT * FROM tblHDCoworkerHierarchyDetail WHERE intCoworkerHierarchyId = ' + @intCoworkerHierarchyId + ' ORDER BY intSort DESC')

WHILE EXISTS(SELECT 1 FROM #TempHDHierarchy)
BEGIN
	SELECT TOP 1 @intCoworkerHierarchyDetailId = intCoworkerHierarchyDetailId, @intParentGroupId = intParentGroupId, @strLevel = strLevel, @strFilterString = strFilterString FROM #TempHDHierarchy ORDER BY intSort DESC

	IF(@strFilterString IS NULL)
	BEGIN
		SET @strFilterString_NEW = @strFilterString_NEW + '[Agent] = ''' + @strLevel + ''' or '
	END
	ELSE IF (@strFilterString_NEW != '')
	BEGIN
		UPDATE tblHDCoworkerHierarchyDetail SET strFilterString = SUBSTRING(@strFilterString_NEW, 0,LEN(@strFilterString_NEW) - CHARINDEX('or',REVERSE(@strFilterString_NEW))-1)  WHERE intCoworkerHierarchyDetailId = @intCoworkerHierarchyDetailId		
		SET @strFilterString_NEW = ''
	END
	ELSE IF (@strFilterString_NEW = '')
	BEGIN
		UPDATE tblHDCoworkerHierarchyDetail SET strFilterString = '' WHERE intCoworkerHierarchyDetailId = @intCoworkerHierarchyDetailId		
	END

	DELETE #TemphDHierarchy WHERE intCoworkerHierarchyDetailId = @intCoworkerHierarchyDetailId
END

-- ++++++++++++++++++++++++++++++
--		BRANCH TO MAIN BRANCH
-- ++++++++++++++++++++++++++++++

DECLARE @intParentId_previous INT
SET @strFilterString_NEW = ''

INSERT INTO #TempHDHierarchy EXEC ('SELECT * FROM tblHDCoworkerHierarchyDetail WHERE intCoworkerHierarchyId = ' + @intCoworkerHierarchyId + ' and strFilterString IS NOT NULL ORDER BY intSort DESC')

SELECT TOP 1 @intCoworkerHierarchyDetailId = intCoworkerHierarchyDetailId, @intParentId_previous = intParentGroupId, @strLevel = strLevel, @strFilterString = strFilterString FROM #TempHDHierarchy

WHILE EXISTS(SELECT 1 FROM #TempHDHierarchy)
BEGIN
	SELECT TOP 1 @intCoworkerHierarchyDetailId = intCoworkerHierarchyDetailId, @intParentGroupId = intParentGroupId, @strLevel = strLevel, @strFilterString = strFilterString FROM #TempHDHierarchy

	DECLARE @AllFilterString NVARCHAR(MAX) 

	SET @AllFilterString = (SELECT strFilterString + ' or ' AS 'data()' 
								FROM tblHDCoworkerHierarchyDetail 
								WHERE intCoworkerHierarchyId = @intCoworkerHierarchyId and strFilterString IS NOT NULL and strFilterString <> '' and intParentGroupId = @intCoworkerHierarchyDetailId  FOR XML PATH(''))
			
	IF(LEN(@AllFilterString) > 5)
	BEGIN
		UPDATE tblHDCoworkerHierarchyDetail SET strFilterString = SUBSTRING(@AllFilterString, 0,LEN(@AllFilterString) - CHARINDEX('or',REVERSE(@AllFilterString))-1)  WHERE intCoworkerHierarchyDetailId = @intCoworkerHierarchyDetailId		
		SET @strFilterString_NEW = ''			
	END	

	SET @intParentId_previous = @intParentGroupId

	DELETE #TempHDHierarchy WHERE intCoworkerHierarchyDetailId = @intCoworkerHierarchyDetailId
END

DROP TABLE #TempHDHierarchy



END

GO