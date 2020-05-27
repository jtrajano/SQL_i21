CREATE PROCEDURE [dbo].[uspFRDBuildHierarchyFilterString]
	@intReportHierarchyId			AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

DECLARE @intReportHierarchyDetailId INT
DECLARE @strFilterString NVARCHAR(MAX)
DECLARE @strLevel NVARCHAR(MAX)
DECLARE @intParentGroupId INT
DECLARE @intSort INT

DECLARE @strFilterString_NEW NVARCHAR(MAX) = ''

CREATE TABLE #TempFRDHierarchy (	
	[intReportHierarchyDetailId]	INT,
	[intReportHierarchyId]			INT,
	[strLevel]						NVARCHAR(MAX),
	[strFilterString]				NVARCHAR(MAX),
	[intParentGroupId]				INT,
	[intSort]						INT,
	[intConcurrencyId]				INT
);

-- +++++++++++++++++++++++++++++
--		NODE TO BRANCH
-- +++++++++++++++++++++++++++++

INSERT INTO #TempFRDHierarchy EXEC ('SELECT * FROM tblFRReportHierarchyDetail WHERE intReportHierarchyId = ' + @intReportHierarchyId + ' ORDER BY intSort DESC')

WHILE EXISTS(SELECT 1 FROM #TempFRDHierarchy)
BEGIN
	SELECT TOP 1 @intReportHierarchyDetailId = intReportHierarchyDetailId, @intParentGroupId = intParentGroupId, @strLevel = strLevel, @strFilterString = strFilterString FROM #TempFRDHierarchy

	IF(@strFilterString IS NULL)
	BEGIN
		SET @strFilterString_NEW = @strFilterString_NEW + '[Location] = ''' + @strLevel + ''' or '
	END
	ELSE IF (@strFilterString_NEW != '')
	BEGIN
		UPDATE tblFRReportHierarchyDetail SET strFilterString = SUBSTRING(@strFilterString_NEW, 0,LEN(@strFilterString_NEW) - CHARINDEX('or',REVERSE(@strFilterString_NEW))-1)  WHERE intReportHierarchyDetailId = @intReportHierarchyDetailId		
		SET @strFilterString_NEW = ''
	END
	ELSE IF (@strFilterString_NEW = '')
	BEGIN
		UPDATE tblFRReportHierarchyDetail SET strFilterString = '' WHERE intReportHierarchyDetailId = @intReportHierarchyDetailId		
	END

	DELETE #TempFRDHierarchy WHERE intReportHierarchyDetailId = @intReportHierarchyDetailId
END

-- ++++++++++++++++++++++++++++++
--		BRANCH TO MAIN BRANCH
-- ++++++++++++++++++++++++++++++

DECLARE @intParentId_previous INT
SET @strFilterString_NEW = ''

INSERT INTO #TempFRDHierarchy EXEC ('SELECT * FROM tblFRReportHierarchyDetail WHERE intReportHierarchyId = ' + @intReportHierarchyId + ' and strFilterString IS NOT NULL ORDER BY intSort DESC')

SELECT TOP 1 @intReportHierarchyDetailId = intReportHierarchyDetailId, @intParentId_previous = intParentGroupId, @strLevel = strLevel, @strFilterString = strFilterString FROM #TempFRDHierarchy

WHILE EXISTS(SELECT 1 FROM #TempFRDHierarchy)
BEGIN
	SELECT TOP 1 @intReportHierarchyDetailId = intReportHierarchyDetailId, @intParentGroupId = intParentGroupId, @strLevel = strLevel, @strFilterString = strFilterString FROM #TempFRDHierarchy

	DECLARE @AllFilterString NVARCHAR(MAX) 

	SET @AllFilterString = (SELECT strFilterString + ' or ' AS 'data()' 
								FROM tblFRReportHierarchyDetail 
								WHERE intReportHierarchyId = @intReportHierarchyId and strFilterString IS NOT NULL and strFilterString <> '' and intParentGroupId = @intReportHierarchyDetailId  FOR XML PATH(''))
			
	IF(LEN(@AllFilterString) > 5)
	BEGIN
		UPDATE tblFRReportHierarchyDetail SET strFilterString = SUBSTRING(@AllFilterString, 0,LEN(@AllFilterString) - CHARINDEX('or',REVERSE(@AllFilterString))-1)  WHERE intReportHierarchyDetailId = @intReportHierarchyDetailId		
		SET @strFilterString_NEW = ''			
	END	

	SET @intParentId_previous = @intParentGroupId

	DELETE #TempFRDHierarchy WHERE intReportHierarchyDetailId = @intReportHierarchyDetailId
END

DROP TABLE #TempFRDHierarchy



END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDBuildHierarchyFilterString] 2011
