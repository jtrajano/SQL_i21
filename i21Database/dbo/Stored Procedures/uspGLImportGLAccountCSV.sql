CREATE PROCEDURE uspGLImportGLAccountCSV (@filePath    NVARCHAR(MAX),
                                          @intEntityId INT,
                                          @strVersion  NVARCHAR(100),
                                          @importLogId INT OUT)
AS
    IF Object_id('tblStagingTable') IS NOT NULL
      DROP TABLE dbo.tblStagingTable

    CREATE TABLE tblStagingTable
      (
         [strPrimarySegment]  [NVARCHAR](40) COLLATE Latin1_General_CI_AS NOT
         NULL,
         [strLocationSegment] [NVARCHAR](40) COLLATE Latin1_General_CI_AS NOT
         NULL,
         [strLOBSegment]      [NVARCHAR](40) COLLATE Latin1_General_CI_AS NULL,
         [strDescription]     [NVARCHAR](500) COLLATE Latin1_General_CI_AS NULL,
         [strUOM]             [NVARCHAR](20) COLLATE Latin1_General_CI_AS NULL
      )

  BEGIN TRY
      DECLARE @s NVARCHAR(MAX) = 'BULK    INSERT tblStagingTable    FROM ''' + @filePath + ''' WITH    (    FIELDTERMINATOR = '','',    ROWTERMINATOR = ''\n''    )'

      --select @s  
      EXEC(@s)
  END TRY

  BEGIN CATCH
      RAISERROR('Bulk Load operation failed',16,1);

      RETURN;
  END CATCH

    IF Object_id('tblGLAccountImportDataStaging2') IS NOT NULL
      DROP TABLE dbo.tblGLAccountImportDataStaging2

    --Check the content of the table.  
    CREATE TABLE tblGLAccountImportDataStaging2
      (
         [intImportStagingId]   INT IDENTITY(1, 1),
         [strPrimarySegment]    [NVARCHAR](40) COLLATE Latin1_General_CI_AS NOT
         NULL
         ,
         [strLocationSegment]   [NVARCHAR](40) COLLATE Latin1_General_CI_AS
         NOT NULL,
         [strLOBSegment]        [NVARCHAR](40) COLLATE Latin1_General_CI_AS NULL
         ,
         [strDescription]       [NVARCHAR](500) COLLATE
         Latin1_General_CI_AS NULL,
         [strUOM]               [NVARCHAR](20) COLLATE Latin1_General_CI_AS NULL
         ,
         [intAccountId]         [INT] NULL,
         [strAccountId]         [NVARCHAR](40) COLLATE Latin1_General_CI_AS NULL
         ,
         [ysnMissingSegment]    [BIT] NULL,
         [ysnGLAccountExist]    [BIT] NULL,
         [ysnMissingLOBSegment] [BIT] NULL,
         [ysnAccountBuilt]      [BIT] NULL,
         ysnNoDescription       BIT NULL,
         [intPrimarySegmentId]  INT NULL,
         [intLocationSegmentId] INT NULL,
         [intLOBSegmentId]      INT NULL,
         intAccountUnitId       INT,
         [ysnInvalid]           BIT NULL,
         strError               NVARCHAR(MAX)
      )

    INSERT INTO tblGLAccountImportDataStaging2
                ([strPrimarySegment],
                 [strLocationSegment],
                 [strLOBSegment],
                 [strDescription],
                 [strUOM])
    SELECT Replace(Ltrim(Rtrim([strPrimarySegment])), '"', ''),
           Replace(Ltrim(Rtrim([strLocationSegment])), '"', ''),
           Replace(Ltrim(Rtrim([strLOBSegment])), '"', ''),
           Replace(Ltrim(Rtrim([strDescription])), '"', ''),
           Replace(Ltrim(Rtrim([strUOM])), '"', '')
    FROM   tblStagingTable

    CREATE UNIQUE INDEX indunique
      ON [tblGLAccountImportDataStaging2]([strAccountId])
      WHERE [strAccountId] IS NOT NULL

    -- REPLACE WITH ENTITY/USER ID  
    DECLARE @withLOB   BIT = 0,
            @separator NCHAR(1) = ''

    SELECT @separator = strMask
    FROM   tblGLAccountStructure
    WHERE  strType = 'Divider'

    SELECT @withLOB = 1
    FROM   tblGLAccountStructure
    WHERE  strStructureName = 'LOB'

    UPDATE [tblGLAccountImportDataStaging2]
    SET    ysnNoDescription = 1
    WHERE  Rtrim(Ltrim(ISNULL([strDescription], ''))) = ''

    UPDATE [tblGLAccountImportDataStaging2]
    SET    [ysnMissingLOBSegment] = Cast(0 AS BIT)

    -- UPDATE EXISTING GL ACCOUNT  
    UPDATE T
    SET    [ysnGLAccountExist] = Cast(1 AS BIT),
           ysnInvalid = Cast(1 AS BIT)
    FROM   [tblGLAccountImportDataStaging2] T
           JOIN tblGLAccount A
             ON A.strAccountId COLLATE Latin1_General_CI_AS =
                T.strAccountId COLLATE Latin1_General_CI_AS

    UPDATE T
    SET    intAccountUnitId = A.intAccountUnitId
    FROM   [tblGLAccountImportDataStaging2] T
           LEFT JOIN tblGLAccountUnit A
                  ON Lower(A.strUOMCode) COLLATE Latin1_General_CI_AS =
                     Lower(Rtrim(
                     Ltrim(ISNULL(T.strUOM, '')))) COLLATE Latin1_General_CI_AS

    UPDATE T
    SET    intPrimarySegmentId = A.intAccountSegmentId
    FROM   [tblGLAccountImportDataStaging2] T
           LEFT JOIN tblGLAccountSegment A
                  ON A.strCode COLLATE Latin1_General_CI_AS =
                     Rtrim(Ltrim(T.strPrimarySegment)) COLLATE
                     Latin1_General_CI_AS
           JOIN tblGLAccountStructure S
             ON S.intAccountStructureId = A.intAccountStructureId
    WHERE  S.strType = 'Primary'

    UPDATE T
    SET    [intLocationSegmentId] = A.intAccountSegmentId
    FROM   [tblGLAccountImportDataStaging2] T
           LEFT JOIN tblGLAccountSegment A
                  ON A.strCode COLLATE Latin1_General_CI_AS =
                     Rtrim(Ltrim(T.strLocationSegment)) COLLATE
                     Latin1_General_CI_AS
           JOIN tblGLAccountStructure S
             ON S.intAccountStructureId = A.intAccountStructureId
    WHERE  strStructureName = 'Location'

    IF ISNULL(@withLOB, 0) = 1
      BEGIN
          UPDATE T
          SET    [intLOBSegmentId] = A.intAccountSegmentId
          FROM   [tblGLAccountImportDataStaging2] T
                 LEFT JOIN tblGLAccountSegment A
                        ON A.strCode COLLATE Latin1_General_CI_AS =
                           Rtrim(Ltrim(T.strLOBSegment)) COLLATE
                           Latin1_General_CI_AS
                 LEFT JOIN tblGLAccountStructure S
                        ON S.intAccountStructureId = A.intAccountStructureId
          WHERE  strStructureName = 'LOB'

          UPDATE [tblGLAccountImportDataStaging2]
          SET    ysnInvalid = 1
          WHERE  intLOBSegmentId IS NULL
      END

    UPDATE [tblGLAccountImportDataStaging2]
    SET    ysnInvalid = Cast(1 AS BIT)
    WHERE  ( intPrimarySegmentId IS NULL
              OR intLocationSegmentId IS NULL )

    UPDATE T
    SET    strDescription = ISNULL(S.strChartDesc, '')
    FROM   [tblGLAccountImportDataStaging2] T
           JOIN tblGLAccountSegment S
             ON S.strCode = Rtrim(Ltrim(T.strPrimarySegment))
           JOIN tblGLAccountStructure ST
             ON ST.intAccountStructureId = S.intAccountStructureId
    WHERE  ST.strType = 'Primary'
           AND ISNULL(ysnInvalid, 0) = 0
           AND ISNULL(T.[ysnNoDescription], 0) = 1

    UPDATE T
    SET    strDescription = T.strDescription + '-'
                            + ISNULL(S.strChartDesc, '')
    FROM   [tblGLAccountImportDataStaging2] T
           JOIN tblGLAccountSegment S
             ON S.strCode = Rtrim(Ltrim(T.strLocationSegment))
           JOIN tblGLAccountStructure ST
             ON ST.intAccountStructureId = S.intAccountStructureId
    WHERE  ST.strStructureName = 'Location'
           AND ISNULL(ysnInvalid, 0) = 0
           AND ISNULL(T.[ysnNoDescription], 0) = 1

    UPDATE T
    SET    strDescription = T.strDescription + '-'
                            + ISNULL(S.strChartDesc, '')
    FROM   [tblGLAccountImportDataStaging2] T
           JOIN tblGLAccountSegment S
             ON S.strCode = Rtrim(Ltrim(T.strLOBSegment))
           JOIN tblGLAccountStructure ST
             ON ST.intAccountStructureId = S.intAccountStructureId
    WHERE  ST.strStructureName = 'LOB'
           AND ISNULL(ysnInvalid, 0) = 0
           AND ISNULL(T.[ysnNoDescription], 0) = 1

    UPDATE [tblGLAccountImportDataStaging2]
    SET    strError = CASE WHEN ISNULL([ysnGLAccountExist], 0) = 1 THEN
                             'Error : GL Account exists |'
                             ELSE '' END + CASE WHEN intPrimarySegmentId IS NULL
                      THEN
                             ' Error : Missing or invalid Primary Segment |'
                      ELSE ''
                      END +
                             CASE WHEN intLocationSegmentId IS NULL THEN
                             'Error : Missing or invalid Location Segment |'
                      ELSE ''
                      END +
                             CASE WHEN intLOBSegmentId IS NULL AND ISNULL(
                      @withLOB,
                      0) = 1
                             THEN ' Error : Missing or invalid LOB Segment |'
                      ELSE
                      '' END +
                             CASE WHEN intAccountUnitId IS NULL THEN
                             'Warning : Missing or invalid UOM Code |' ELSE ''
                      END

    UPDATE [tblGLAccountImportDataStaging2]
    SET    strAccountId = Rtrim(Ltrim(strPrimarySegment))
                          + @separator
                          + Rtrim(Ltrim(strLocationSegment)) + CASE WHEN Rtrim(
                          Ltrim
                          (ISNULL
                                 (strLOBSegment, ''))) = '' THEN '' ELSE
                          @separator
                          +
                                 strLOBSegment END
    WHERE  isnull(ysnInvalid, 0) = 0

    INSERT INTO tblGLAccount
                ([strAccountId],
                 [strDescription],
                 [intAccountGroupId],
                 [ysnSystem],
                 [ysnActive],
                 intCurrencyID,
                 intAccountUnitId,
                 intConcurrencyId,
                 intEntityIdLastModified)
    SELECT S.strAccountId,
           S.strDescription,
           SG.intAccountGroupId,
           0,
           1,
           3,
           intAccountUnitId,
           1,
           @intEntityId
    FROM   [tblGLAccountImportDataStaging2] S
           JOIN tblGLAccountSegment SG
             ON SG.intAccountSegmentId = S.[intPrimarySegmentId]
    WHERE  isnull(ysnInvalid, 0) = 0

    UPDATE ST
    SET    intAccountId = GL.intAccountId
    FROM   [tblGLAccountImportDataStaging2] ST
           JOIN tblGLAccount GL
             ON GL.strAccountId = ST.strAccountId;

    WITH Segments
         AS (SELECT intAccountId,
                    intPrimarySegmentId SegmentId
             FROM   [tblGLAccountImportDataStaging2]
             WHERE  isnull(ysnInvalid, 0) = 0
             UNION ALL
             SELECT intAccountId,
                    [intLocationSegmentId]
             FROM   [tblGLAccountImportDataStaging2]
             WHERE  isnull(ysnInvalid, 0) = 0
             UNION ALL
             SELECT intAccountId,
                    [intLOBSegmentId]
             FROM   [tblGLAccountImportDataStaging2]
             WHERE  isnull(ysnInvalid, 0) = 0)
    INSERT INTO tblGLAccountSegmentMapping
                (intAccountSegmentId,
                 intAccountId,
                 intConcurrencyId)
    SELECT SegmentId,
           intAccountId,
           1
    FROM   Segments

    IF ISNULL(@withLOB, 0) = 1
      INSERT INTO tblGLAccountSegmentMapping
                  (intAccountSegmentId,
                   intAccountId,
                   intConcurrencyId)
      SELECT intAccountId,
             [intLOBSegmentId],
             1
      FROM   Segments

    EXEC dbo.uspGLUpdateAccountLocationId

    INSERT INTO tblGLCOACrossReference
                ([inti21Id],
                 [stri21Id],
                 [strExternalId],
                 [strCurrentExternalId],
                 [strCompanyId],
                 [intConcurrencyId])
    SELECT B.intAccountId                           AS inti21Id,
           B.strAccountId                           AS stri21Id,
           Cast(Cast(B.strPrimarySegment AS INT) AS NVARCHAR(50))
           + '.' + Replicate('0', (SELECT 8 - Sum(intLength) FROM
           tblGLAccountStructure
           WHERE strType = 'Segment'))
           + B.strLocationSegment + B.strLOBSegment AS strExternalId,
           B.strPrimarySegment
           + Replicate('0', (SELECT 8 - Sum(intLength) FROM
           tblGLAccountStructure
           WHERE
           strType = 'Segment')) + '-'
           + Replicate('0', (SELECT 8 - Sum(intLength) FROM
           tblGLAccountStructure
           WHERE
           strType = 'Segment'))
           + B.strLocationSegment + B.strLOBSegment AS strCurrentExternalId,
           'Legacy'                                 AS strCompanyId,
           1
    FROM   [tblGLAccountImportDataStaging2] B
           JOIN tblGLAccount A
             ON A.intAccountId = B.intAccountId
    WHERE  A.strAccountId NOT IN (SELECT stri21Id
                                  FROM   tblGLCOACrossReference
                                  WHERE  strCompanyId = 'Legacy')

    IF EXISTS (SELECT TOP 1 1
               FROM   sys.objects
               WHERE  object_id = object_id(N'[dbo].[glactmst]')
                      AND type IN ( N'U' ))
      BEGIN
          SET ANSI_WARNINGS OFF EXEC uspGLAccountOriginSync @intEntityId 
          EXEC('  UPDATE G set glact_desc = LEFT( D.strDescription, 30)    
          FROM tblGLCOACrossReference C Join tblGLAccount A ON A.intAccountId = C.inti21Id     
          JOIN [tblGLAccountImportDataStaging2] D  ON D.intAccountId = A.intAccountId    
          JOIN glactmst G ON G.A4GLIdentity = C.intLegacyReferenceId    
          WHERE isnull(ysnNoDescription,0) = 0  AND isnull(ysnInvalid,0) = 0')
        SET ANSI_WARNINGS ON
    END

    --checking  
    DECLARE @intInvalidCount INT = 0,
            @intValidCount   INT = 0,
            @intStagedCount  INT=0

    SELECT @intStagedCount = Count(*)
    FROM   tblGLAccountImportDataStaging

    SELECT @intInvalidCount = Count(*)
    FROM   tblGLAccountImportDataStaging2
    WHERE  ISNULL(ysnInvalid, 0) = 1

    SELECT @intValidCount = Count(*)
    FROM   tblGLAccount A
           JOIN tblGLAccountImportDataStaging2 B
             ON B.intAccountId = A.intAccountId
    WHERE  ISNULL(ysnInvalid, 0) = 0

    DECLARE @m NVARCHAR(MAX)

    IF @intValidCount > 0
       AND @intInvalidCount > 0
      SET @m = 'Importing GL Accounts with Errors.'

    IF @intValidCount > 0
       AND @intInvalidCount = 0
      SET @m = 'Successfully imported GL Accounts.'

    IF @intValidCount = 0
       AND @intInvalidCount > 0
      SET @m = 'Importing GL Accounts Failed.'

    IF @intValidCount = 0
       AND @intInvalidCount = 0
      SET @m = 'No GL Accounts was imported.'

    INSERT INTO tblGLCOAImportLog
                (strEvent,
                 intEntityId,
                 intConcurrencyId,
                 intUserId,
                 dtmDate,
                 intErrorCount,
                 intSuccessCount,
                 strIrelySuiteVersion,
                 strJournalType)
    SELECT @m,
           @intEntityId,
           1,
           @intEntityId,
           Getdate(),
           @intInvalidCount,
           @intValidCount,
           @strVersion,
           'glaccount'

    SELECT @importLogId = Scope_identity()

    INSERT INTO tblGLCOAImportLogDetail
                (intImportLogId,
                 strEventDescription,
                 strExternalId,
                 strLineNumber)
    SELECT @importLogId,
           CASE
             WHEN isnull(ysnInvalid, 0) = 1 THEN strError
             ELSE 'GL Account created. '
                  + ISNULL( strError, '')
           END,
           strAccountId,
           Cast([intImportStagingId] AS NVARCHAR(4))
    FROM   tblGLAccountImportDataStaging2 