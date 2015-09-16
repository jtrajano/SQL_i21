CREATE VIEW [dbo].[vyuIUPatchHistory]
WITH SCHEMABINDING
AS 
SELECT	A.intPatchHistoryId, 
	A.intVersionId, 
	B.strVersionNo,
	B.strUpdateType,
	B.dtmLastUpdate, 
	B.strStashCommitId, 
    A.strCommitId, 
	A.strVersion, 
	A.strChangeType, 
	A.strFilePath, 
	A.strFileName
FROM dbo.tblIUPatchHistory A INNER JOIN dbo.tblSMBuildNumber B 
	ON A.intVersionId = B.intVersionID
