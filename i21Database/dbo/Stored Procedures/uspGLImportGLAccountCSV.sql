
CREATE PROCEDURE uspGLImportGLAccountCSV  
(  
 @filePath NVARCHAR(MAX),
 @intEntityId INT,
 @strVersion NVARCHAR(100),
 @importLogId INT OUT 
)  
AS  
  
IF object_id('tblStagingTable') IS NOT NULL   
 DROP TABLE dbo.tblStagingTable  

  
CREATE TABLE tblStagingTable (  
 [strPrimarySegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,  
 [strLocationSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,  
 [strLOBSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,  
 [strDescription] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,  
 [strUOM] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL  
)  
   
  
  
BEGIN TRY  
 DECLARE @s NVARCHAR(MAX) =  
 'BULK  
 INSERT tblStagingTable  
 FROM ''' +   @filePath +  
  
 ''' WITH  
 (  
 FIELDTERMINATOR = '','',  
 ROWTERMINATOR = ''\n''  
 )'  
 --select @s  
 Exec(@s)  
END TRY  
BEGIN CATCH  
 RAISERROR('Bulk Load operation failed', 16, 1);  
 RETURN;  
  
END CATCH    


IF object_id('tblGLAccountImportDataStaging2') IS NOT NULL   
 DROP TABLE dbo.tblGLAccountImportDataStaging2  
  
  
--Check the content of the table.  
CREATE TABLE tblGLAccountImportDataStaging2  
(  
 [intImportStagingId] INT IDENTITY(1,1) ,  
 [strPrimarySegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,  
 [strLocationSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,  
 [strLOBSegment] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,  
 [strDescription] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,  
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
 [ysnInvalid] BIT NULL,  
 strError NVARCHAR(MAX)  
)
  
INSERT INTO tblGLAccountImportDataStaging2([strPrimarySegment],[strLocationSegment],[strLOBSegment],[strDescription],[strUOM])  
SELECT   
REPLACE(LTRIM(RTRIM([strPrimarySegment])),'"','')  
,REPLACE(LTRIM(RTRIM([strLocationSegment])),'"','')  
,REPLACE(LTRIM(RTRIM([strLOBSegment])),'"','')  
,REPLACE(LTRIM(RTRIM([strDescription])),'"','')  
,REPLACE(LTRIM(RTRIM([strUOM])),'"','') FROM tblStagingTable  
  
  
CREATE UNIQUE INDEX indunique  
  ON [tblGLAccountImportDataStaging2]([strAccountId])  
  WHERE [strAccountId] IS NOT NULL  
  
     
  
-- REPLACE WITH ENTITY/USER ID  
DECLARE @withLOB BIT = 0, @separator nchar(1) = ''  
SELECT @separator = strMask FROM tblGLAccountStructure WHERE strType = 'Divider'  
SELECT @withLOB = 1 FROM tblGLAccountStructure WHERE strStructureName = 'LOB'  
  


UPDATE [tblGLAccountImportDataStaging2] SET ysnNoDescription = 1 WHERE RTRIM(LTRIM(ISNULL([strDescription],''))) = ''  
UPDATE [tblGLAccountImportDataStaging2] SET [ysnMissingLOBSegment] = CAST(0 AS BIT)
   
  
-- UPDATE EXISTING GL ACCOUNT  
UPDATE T SET [ysnGLAccountExist] = CAST(1 AS BIT), ysnInvalid = CAST(1 AS BIT )
FROM  [tblGLAccountImportDataStaging2] T   
JOIN tblGLAccount A ON A.strAccountId COLLATE Latin1_General_CI_AS = T.strAccountId COLLATE Latin1_General_CI_AS  
  
UPDATE T SET intAccountUnitId = A.intAccountUnitId  
FROM  [tblGLAccountImportDataStaging2] T   
LEFT JOIN tblGLAccountUnit A ON LOWER(A.strUOMCode) COLLATE Latin1_General_CI_AS = LOWER(RTRIM(LTRIM(ISNULL(T.strUOM,'')))) COLLATE Latin1_General_CI_AS  
  
  



UPDATE T SET   
intPrimarySegmentId = A.intAccountSegmentId  
FROM  [tblGLAccountImportDataStaging2] T   
LEFT JOIN tblGLAccountSegment A ON A.strCode COLLATE Latin1_General_CI_AS =RTRIM(LTRIM(T.strPrimarySegment)) COLLATE Latin1_General_CI_AS   
JOIN tblGLAccountStructure S on S.intAccountStructureId = A.intAccountStructureId  
WHERE S.strType = 'Primary'  
  
UPDATE T SET [intLocationSegmentId] = A.intAccountSegmentId  
FROM  [tblGLAccountImportDataStaging2] T   
LEFT JOIN tblGLAccountSegment A ON A.strCode COLLATE Latin1_General_CI_AS =RTRIM(LTRIM(T.strLocationSegment)) COLLATE Latin1_General_CI_AS  
JOIN tblGLAccountStructure S on S.intAccountStructureId = A.intAccountStructureId  
WHERE strStructureName = 'Location'  
  

IF @withLOB =1   
begin
 UPDATE T SET [intLOBSegmentId] = A.intAccountSegmentId  
 FROM  [tblGLAccountImportDataStaging2] T   
 LEFT JOIN tblGLAccountSegment A ON A.strCode COLLATE Latin1_General_CI_AS =RTRIM(LTRIM(T.strLOBSegment)) COLLATE Latin1_General_CI_AS  
 LEFT JOIN tblGLAccountStructure S on S.intAccountStructureId = A.intAccountStructureId  
 WHERE strStructureName = 'LOB'  

 update [tblGLAccountImportDataStaging2] set ysnInvalid = 1 WHERE intLOBSegmentId IS NULL 

end
  
UPDATE [tblGLAccountImportDataStaging2] SET ysnInvalid = CAST(1 AS BIT)
WHERE (intPrimarySegmentId IS NULL   
OR intLocationSegmentId IS NULL)
  
  
UPDATE T set strDescription = ISNULL(S.strChartDesc,'') FROM [tblGLAccountImportDataStaging2] T   
JOIN tblGLAccountSegment S ON S.strCode = RTRIM(LTRIM(T.strPrimarySegment))   
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId = S.intAccountStructureId   
WHERE  ST.strType = 'Primary'AND ISNULL(ysnInvalid,0) = 0 AND  ISNULL(T.[ysnNoDescription],0)  = 1  
  
UPDATE T set strDescription = T.strDescription + '-' + ISNULL(S.strChartDesc,'') FROM [tblGLAccountImportDataStaging2] T   
JOIN tblGLAccountSegment S ON S.strCode = RTRIM(LTRIM(T.strLocationSegment))   
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId = S.intAccountStructureId   
WHERE  ST.strStructureName = 'Location'AND ISNULL(ysnInvalid,0) = 0  AND  ISNULL(T.[ysnNoDescription],0)  = 1  
  
UPDATE T set strDescription = T.strDescription + '-' + ISNULL(S.strChartDesc,'') FROM [tblGLAccountImportDataStaging2] T   
JOIN tblGLAccountSegment S ON S.strCode = RTRIM(LTRIM(T.strLOBSegment))   
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId = S.intAccountStructureId   
WHERE  ST.strStructureName = 'LOB'AND ISNULL(ysnInvalid,0) = 0 AND  ISNULL(T.[ysnNoDescription],0)  = 1  
  
UPDATE [tblGLAccountImportDataStaging2] SET   
strError =  
CASE WHEN ISNULL([ysnGLAccountExist],0) = 1 THEN  'Error : GL Account exists |' ELSE '' END +  
CASE WHEN intPrimarySegmentId IS NULL THEN  ' Error : Missing or invalid Primary Segment |' ELSE '' END +  
CASE WHEN intLocationSegmentId IS NULL THEN  'Error : Missing or invalid Location Segment |' ELSE '' END +  
CASE WHEN intLOBSegmentId IS NULL AND @withLOB = 1 THEN  ' Error : Missing or invalid LOB Segment |' ELSE '' END +  
CASE WHEN intAccountUnitId IS NULL THEN  'Warning : Missing or invalid UOM Code |' ELSE '' END  
 
 UPDATE [tblGLAccountImportDataStaging2]   
SET strAccountId = RTRIM(LTRIM(strPrimarySegment)) + @separator + RTRIM(LTRIM(strLocationSegment)) +    
 CASE WHEN RTRIM(LTRIM(ISNULL(strLOBSegment,''))) = ''   
 THEN ''    
 ELSE @separator + strLOBSegment  END  
 WHERE isnull(ysnInvalid,0) = 0  

  
INSERT intO tblGLAccount   
([strAccountId],[strDescription], [intAccountGroupId],[ysnSystem],[ysnActive],intCurrencyID,intAccountUnitId,  intConcurrencyId, intEntityIdLastModified)  
SELECT S.strAccountId,S.strDescription,SG.intAccountGroupId,0,1,3,intAccountUnitId ,1,@intEntityId FROM  [tblGLAccountImportDataStaging2] S  
JOIN tblGLAccountSegment SG ON SG.intAccountSegmentId = S.[intPrimarySegmentId]  
WHERE isnull(ysnInvalid,0) = 0  
  
UPDATE ST SET intAccountId = GL.intAccountId FROM [tblGLAccountImportDataStaging2] ST join tblGLAccount GL ON GL.strAccountId = ST.strAccountId   
  
;WITH Segments AS(  
 SELECT intAccountId, intPrimarySegmentId SegmentId FROM [tblGLAccountImportDataStaging2]  WHERE isnull(ysnInvalid,0) = 0 UNION ALL  
 SELECT intAccountId, [intLocationSegmentId] FROM [tblGLAccountImportDataStaging2]  WHERE isnull(ysnInvalid,0) = 0 UNION ALL  
 SELECT intAccountId, [intLOBSegmentId] FROM [tblGLAccountImportDataStaging2]  WHERE isnull(ysnInvalid,0) = 0  
)  
INSERT intO tblGLAccountSegmentMapping(intAccountSegmentId, intAccountId, intConcurrencyId)  
SELECT SegmentId, intAccountId, 1  FROM Segments

EXEC dbo.uspGLUpdateAccountLocationId

INSERT INTO tblGLCOACrossReference ([inti21Id],[stri21Id],[strExternalId], [strCurrentExternalId], [strCompanyId], [intConcurrencyId])    
SELECT B.intAccountId as inti21Id,    
B.strAccountId as stri21Id,    
CAST(CAST(B.strPrimarySegment AS INT) AS NVARCHAR(50))  + '.' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strLocationSegment + B.strLOBSegment as strExternalId ,  
B.strPrimarySegment + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + '-' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) +B.strLocationSegment + B.strLOBSegment as strCurrentExternalId,    
'Legacy' as strCompanyId,    
1    
FROM [tblGLAccountImportDataStaging2] B    
JOIN tblGLAccount A on A.intAccountId = B.intAccountId  
WHERE A.strAccountId NOT IN (SELECT stri21Id FROM tblGLCOACrossReference WHERE strCompanyId='Legacy')


 IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))    
 BEGIN  
 SET ANSI_WARNINGS  OFF

 EXEC uspGLAccountOriginSync @intEntityId    
  
 EXEC('
 UPDATE G set glact_desc = LEFT( D.strDescription, 30)  
 FROM tblGLCOACrossReference C Join tblGLAccount A on A.intAccountId = C.inti21Id   
 JOIN [tblGLAccountImportDataStaging2] D  on D.intAccountId = A.intAccountId  
 join glactmst G on G.A4GLIdentity = C.intLegacyReferenceId  
 where isnull(ysnNoDescription,0) = 0
 and isnull(ysnInvalid,0) = 0 
 ')  
 SET ANSI_WARNINGS  ON
END  
  
  
--checking  
  
DECLARE @intInvalidCount INT = 0, @intValidCount INT = 0, @intStagedCount INT=0  
SELECT @intStagedCount = COUNT(*) FROM tblGLAccountImportDataStaging  
SELECT @intInvalidCount = count(*) FROM tblGLAccountImportDataStaging2 where ISNULL(ysnInvalid,0) = 1  
SELECT @intValidCount=COUNT(*) FROM tblGLAccount A JOIN tblGLAccountImportDataStaging2 B on B.intAccountId = A.intAccountId   
WHERE ISNULL(ysnInvalid,0) = 0  
  
  
DECLARE @m NVARCHAR(MAX)  
  
IF @intValidCount > 0 and @intInvalidCount >0  
 SET @m = 'Importing GL Accounts with Errors.'  
IF @intValidCount > 0 AND @intInvalidCount = 0  
 SET @m = 'Successfully imported GL Accounts.'  
IF @intValidCount = 0 AND @intInvalidCount > 0  
 SET @m = 'Importing GL Accounts Failed.'  
IF @intValidCount = 0 AND @intInvalidCount = 0  
 SET @m = 'No GL Accounts was imported.'  
  
INSERT INTO tblGLCOAImportLog(strEvent, intEntityId, intConcurrencyId, intUserId, dtmDate, intErrorCount, intSuccessCount, strIrelySuiteVersion, strJournalType)  
 SELECT @m, @intEntityId, 1, @intEntityId, GETDATE(), @intInvalidCount, @intValidCount, @strVersion,'glaccount'  
 SELECT @importLogId = SCOPE_IDENTITY()  
  
INSERT INTO tblGLCOAImportLogDetail(intImportLogId, strEventDescription, strExternalId,strLineNumber)  
 SELECT   
  @importLogId,  
  CASE WHEN isnull(ysnInvalid,0) = 1 THEN strError ELSE 'GL Account created. '
  + ISNULL( strError,'') 
   END,   
  strAccountId,   
  CAST([intImportStagingId] AS nvarchar(4))  
 FROM tblGLAccountImportDataStaging2