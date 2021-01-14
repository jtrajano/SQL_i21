
CREATE PROCEDURE uspGLImportGLAccountCSV(
@filePath NVARCHAR(MAX),
@intEntityId INT,
@strVersion NVARCHAR(100),
@importLogId INT OUT
)
AS


IF object_id('tblGLAccountImportDataStaging') IS NOT NULL 
	DROP TABLE dbo.tblGLAccountImportDataStaging
IF object_id('tblGLAccountImportDataStaging2') IS NOT NULL 
	DROP TABLE dbo.tblGLAccountImportDataStaging2


CREATE TABLE tblGLAccountImportDataStaging (
	[strPrimarySegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocationSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLOBSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strUOM] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL
)
 

--FROM 'C:\Users\Jeff\Documents\SQL Server Management Studio\testImportGL.csv' --REPLACE WITH VALID FULL FILE PATH
DECLARE @s NVARCHAR(MAX) =
'BULK
INSERT tblGLAccountImportDataStaging
FROM ''' +   @filePath +

''' WITH
(
FIELDTERMINATOR = '','',
ROWTERMINATOR = ''\n''
)'
select @s
Exec(@s)


--Check the content of the table.
CREATE TABLE tblGLAccountImportDataStaging2
(
	[intImportStagingId] INT IDENTITY(1,1) ,
	[strPrimarySegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocationSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLOBSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strUOM] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
 	[intAccountId] [int] NULL,
	[strAccountId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[ysnMissingSegment] [bit] NULL,
	[ysnGLAccountExist] [bit] NULL,
	[ysnMissingLOBSegment] [bit] NULL,
	[ysnAccountBuilt] [bit] NULL,
	ysnNoDescription BIT NULL,
	[intPrimarySegmentId] INT NULL,
	[intLocationSegmentId] INT NULL,
	[intLOBSegmentId] INT NULL,
	intAccountUnitId INT,
	[ysnValid] BIT NULL,
	strError NVARCHAR(MAX)
)



INSERT INTO tblGLAccountImportDataStaging2([strPrimarySegment],[strLocationSegment],[strLOBSegment],[strDescription],[strUOM])
SELECT [strPrimarySegment],[strLocationSegment],[strLOBSegment],[strDescription],[strUOM] FROM tblGLAccountImportDataStaging


CREATE UNIQUE INDEX indunique
  ON [tblGLAccountImportDataStaging2]([strAccountId])
  WHERE [strAccountId] IS NOT NULL


-- REPLACE WITH ENTITY/USER ID
DECLARE @withLOB BIT = 0, @separator nchar(1) = ''
SELECT @separator = strMask FROM tblGLAccountStructure WHERE strType = 'Divider'
SELECT @withLOB = 1 FROM tblGLAccountStructure WHERE strStructureName = 'LOB'

UPDATE [tblGLAccountImportDataStaging2] SET strAccountId = TRIM(strPrimarySegment) + @separator + TRIM(strLocationSegment) +  case when trim(ISNULL(strLOBSegment,'')) = '' THEN ''  ELSE @separator + strLOBSegment  END
UPDATE [tblGLAccountImportDataStaging2] SET ysnNoDescription = 1 WHERE TRIM(ISNULL([strDescription],'')) = ''
UPDATE [tblGLAccountImportDataStaging2] SET [ysnMissingLOBSegment] = 0
	

-- UPDATE EXISTING GL ACCOUNT
UPDATE T SET [ysnGLAccountExist] = 1 
FROM  [tblGLAccountImportDataStaging2] T 
JOIN tblGLAccount A ON A.strAccountId COLLATE Latin1_General_CI_AS = T.strAccountId COLLATE Latin1_General_CI_AS

UPDATE T SET intAccountUnitId = A.intAccountUnitId
FROM  [tblGLAccountImportDataStaging2] T 
LEFT JOIN tblGLAccountUnit A ON LOWER(A.strUOMCode) COLLATE Latin1_General_CI_AS = LOWER(TRIM(ISNULL(T.strUOM,''))) COLLATE Latin1_General_CI_AS

UPDATE T SET 
intPrimarySegmentId = A.intAccountSegmentId
FROM  [tblGLAccountImportDataStaging2] T 
LEFT JOIN tblGLAccountSegment A ON A.strCode COLLATE Latin1_General_CI_AS =TRIM(T.strPrimarySegment) COLLATE Latin1_General_CI_AS 
JOIN tblGLAccountStructure S on S.intAccountStructureId = A.intAccountStructureId
WHERE S.strType = 'Primary'

UPDATE T SET [intLocationSegmentId] = A.intAccountSegmentId
FROM  [tblGLAccountImportDataStaging2] T 
LEFT JOIN tblGLAccountSegment A ON A.strCode COLLATE Latin1_General_CI_AS =TRIM(T.strLocationSegment) COLLATE Latin1_General_CI_AS
JOIN tblGLAccountStructure S on S.intAccountStructureId = A.intAccountStructureId
WHERE strStructureName = 'Location'


IF @withLOB =1 
	UPDATE T SET [ysnMissingLOBSegment] = CASE WHEN A.strCode IS NULL THEN 1 ELSE 0 END	,[intLOBSegmentId] = A.intAccountSegmentId
	FROM  [tblGLAccountImportDataStaging2] T 
	LEFT JOIN tblGLAccountSegment A ON A.strCode COLLATE Latin1_General_CI_AS =TRIM(T.strLOBSegment) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblGLAccountStructure S on S.intAccountStructureId = A.intAccountStructureId
	WHERE strStructureName = 'LOB'

UPDATE [tblGLAccountImportDataStaging2] SET ysnValid = 1 
WHERE intPrimarySegmentId IS NOT NULL 
AND intLocationSegmentId IS NOT NULL 
AND [ysnMissingLOBSegment] =0 
-- AND intAccountUnitId IS NOT NULL warning only
AND ISNULL([ysnGLAccountExist],0) = 0


UPDATE T set strDescription = S.strChartDesc FROM [tblGLAccountImportDataStaging2] T 
JOIN tblGLAccountSegment S ON S.strCode = TRIM(T.strPrimarySegment) 
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId = S.intAccountStructureId 
WHERE  ST.strType = 'Primary'AND ISNULL(ysnValid,0) = 1 AND  ISNULL(T.[ysnNoDescription],0)  = 1

UPDATE T set strDescription = T.strDescription + '-' + S.strChartDesc FROM [tblGLAccountImportDataStaging2] T 
JOIN tblGLAccountSegment S ON S.strCode = TRIM(T.strPrimarySegment) 
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId = S.intAccountStructureId 
WHERE  ST.strStructureName = 'Location'AND ISNULL(ysnValid,0) = 1  AND  ISNULL(T.[ysnNoDescription],0)  = 1

UPDATE T set strDescription = T.strDescription + '-' + S.strChartDesc FROM [tblGLAccountImportDataStaging2] T 
JOIN tblGLAccountSegment S ON S.strCode = TRIM(T.strPrimarySegment) 
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId = S.intAccountStructureId 
WHERE  ST.strStructureName = 'LOB'AND ISNULL(ysnValid,0) = 1 AND  ISNULL(T.[ysnNoDescription],0)  = 1

UPDATE [tblGLAccountImportDataStaging2] SET 
strError =
CASE WHEN ISNULL([ysnGLAccountExist],0) = 1 THEN  'Error : GL Account exists |' ELSE '' END +
CASE WHEN intPrimarySegmentId IS NULL THEN  ' Error : Missing or invalid Primary Segment |' ELSE '' END +
CASE WHEN intLocationSegmentId IS NULL THEN  'Error : Missing or invalid Location Segment |' ELSE '' END +
CASE WHEN intLOBSegmentId IS NULL AND @withLOB = 1 THEN  ' Error : Missing or invalid LOB Segment |' ELSE '' END +
CASE WHEN intAccountUnitId IS NULL THEN  'Warning : Missing or invalid UOM Code |' ELSE '' END

INSERT intO tblGLAccount 
([strAccountId],[strDescription], [intAccountGroupId],[ysnSystem],[ysnActive],intCurrencyID,intAccountUnitId,  intConcurrencyId, intEntityIdLastModified)
SELECT S.strAccountId,S.strDescription,SG.intAccountGroupId,0,1,3,intAccountUnitId ,1,@intEntityId FROM  [tblGLAccountImportDataStaging2] S
JOIN tblGLAccountSegment SG ON SG.intAccountSegmentId = S.[intPrimarySegmentId]
WHERE isnull(ysnValid,0) = 1

UPDATE ST SET intAccountId = GL.intAccountId FROM [tblGLAccountImportDataStaging2] ST join tblGLAccount GL ON GL.strAccountId = ST.strAccountId 

;WITH Segments AS(
	SELECT intAccountId, intPrimarySegmentId SegmentId FROM [tblGLAccountImportDataStaging2]  WHERE isnull(ysnValid,0) = 1 UNION ALL
	SELECT intAccountId, [intLocationSegmentId] FROM [tblGLAccountImportDataStaging2]  WHERE isnull(ysnValid,0) = 1 UNION ALL
	SELECT intAccountId, [intLOBSegmentId] FROM [tblGLAccountImportDataStaging2]  WHERE isnull(ysnValid,0) = 1
)
INSERT intO tblGLAccountSegmentMapping(intAccountSegmentId, intAccountId, intConcurrencyId)
SELECT SegmentId, intAccountId, 1  FROM Segments 




INSERT INTO tblGLCOACrossReference ([inti21Id],[stri21Id],[strExternalId], [strCurrentExternalId], [strCompanyId], [intConcurrencyId])  
SELECT B.intAccountId as inti21Id,  
B.strAccountId as stri21Id,  
CAST(CAST(B.strPrimarySegment AS INT) AS NVARCHAR(50))  + '.' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strLocationSegment + B.strLOBSegment as strExternalId ,       
B.strPrimarySegment + '-' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strLocationSegment + B.strLOBSegment as strCurrentExternalId,  
'Legacy' as strCompanyId,  
1  
FROM [tblGLAccountImportDataStaging2] B  
JOIN tblGLAccount A on A.intAccountId = B.intAccountId
WHERE A.strAccountId NOT IN (SELECT stri21Id FROM tblGLCOACrossReference WHERE strCompanyId='Legacy')   


 IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))  
  EXEC uspGLAccountOriginSync @intEntityId  

-- sync description incase description is explicitly stated
UPDATE G set glact_desc = D.strDescription
FROM tblGLCOACrossReference C Join tblGLAccount A on A.intAccountId = C.inti21Id 
JOIN [tblGLAccountImportDataStaging2] D  on D.intAccountId = A.intAccountId
join glactmst G on G.A4GLIdentity = C.intLegacyReferenceId
where isnull(ysnNoDescription,0) = 0


--checking

DECLARE @intInvalidCount INT = 0, @intValidCount INT = 0, @intStagedCount INT=0
SELECT @intStagedCount = COUNT(*) FROM tblGLAccountImportDataStaging
SELECT @intInvalidCount = count(*) FROM tblGLAccountImportDataStaging2 where ISNULL(ysnValid,0) = 0
SELECT @intValidCount=COUNT(*) FROM tblGLAccount A JOIN tblGLAccountImportDataStaging2 B on B.intAccountId = A.intAccountId 
WHERE ISNULL(ysnValid,0) = 1


DECLARE @m NVARCHAR(MAX)

IF @intValidCount > 0 and @intInvalidCount >0
	SET @m = 'Importing GL Accounts with Errors.'
IF @intValidCount > 0 AND @intInvalidCount = 0
	SET @m = 'Successfully imported GL Accounts.'
IF @intValidCount = 0 AND @intInvalidCount > 0
	SET @m = 'Importing GL Accounts Failed.'
IF @intValidCount = 0 AND @intInvalidCount = 0
	SET @m = 'No GL Accounts was imported.'

INSERT INTO tblGLCOAImportLog(strEvent, intEntityId, intConcurrencyId, intUserId, dtmDate, intErrorCount, intSuccessCount, strIrelySuiteVersion)
	SELECT @m, @intEntityId, 1, @intEntityId, GETDATE(), @intInvalidCount, @intValidCount, @strVersion
	SELECT @importLogId = SCOPE_IDENTITY()

INSERT INTO tblGLCOAImportLogDetail(intImportLogId, strEventDescription, strExternalId,strLineNumber)
	SELECT 
		@importLogId,
		CASE WHEN isnull(ysnValid,0) = 0 THEN strError ELSE 'GL Account created' END, 
		strAccountId, 
		CAST([intImportStagingId] AS nvarchar(4))
	FROM tblGLAccountImportDataStaging2