-- USED IN REVALUE CURRENCY OVERRIDING
CREATE PROCEDURE uspGLBuildMissingAccountsRevalueOverride @intEntityId INT
AS
    DECLARE @tblS TABLE
      (
         id                    INT IDENTITY (1, 1),
         intAccountStructureId INT
      )
    DECLARE @dtmNow DATETIME = Getdate()

    INSERT INTO @tblS
                (intAccountStructureId)
    SELECT intAccountStructureId
    FROM   tblGLAccountStructure
    WHERE  strType <> 'Divider'
    ORDER  BY intSort ASC

    DECLARE @tbl TABLE
      (
         id           INT IDENTITY(1, 1),
         strAccountId NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
         strSegment   NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL
      );

    WITH d
         AS (SELECT strNewAccountIdOverride
             FROM   tblGLPostRecap
             WHERE  strOverrideAccountError IS NOT NULL
             GROUP  BY strNewAccountIdOverride),
         Segments
         AS (SELECT u.Item,
                    strNewAccountIdOverride
             FROM   d
                    OUTER apply(SELECT Item
                                FROM
                    dbo.fnSplitString(d.strNewAccountIdOverride, '-'))
                               u)
    INSERT INTO @tbl
                (strSegment,
                 strAccountId)
    SELECT Item,
           strNewAccountIdOverride
    FROM   Segments;

    WITH _partition
         AS (SELECT *,
                    ROW_NUMBER()
                      OVER(
                        partition BY strAccountId
                        ORDER BY id) intSort
             FROM   @tbl),
         _segments
         AS (SELECT strSegment,
                    intAccountStructureId
             FROM   _partition a
                    JOIN @tblS b
                      ON a.intSort = b.id
             GROUP  BY strSegment,
                       intAccountStructureId),
         _segmentIds
         AS (SELECT intAccountSegmentId
             FROM   tblGLAccountSegment a
                    JOIN _segments b
                      ON a.strCode = b.strSegment
                         AND a.intAccountStructureId = b.intAccountStructureId)
    INSERT INTO tblGLTempAccountToBuild
                (intUserId,
                 intAccountSegmentId,
                 dtmCreated)
    SELECT @intEntityId,
           intAccountSegmentId,
           @dtmNow
    FROM   _segmentIds
    GROUP  BY intAccountSegmentId

    EXEC uspGLBuildAccountTemporary
      1

