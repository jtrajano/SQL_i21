CREATE PROCEDURE uspGLBuildRetainedEarningsAccount
AS
    DECLARE @dtmNow DATETIME = Getdate()
    DECLARE @intUserId INT =1
    DECLARE @intRetainedEarningsAccount INT
    DECLARE @intIncomeSummaryAccount INT

    SELECT @intRetainedEarningsAccount = intRetainAccount,
           @intIncomeSummaryAccount = intIncomeSummaryAccount
    FROM   tblGLFiscalYear

    IF @intIncomeSummaryAccount IS NULL
       AND @intRetainedEarningsAccount IS NULL
      BEGIN
          RAISERROR('Missing Income Summary and Retained Earnings Account',16,1)
          RETURN -1
      END

    IF @intIncomeSummaryAccount IS NULL
      BEGIN
          RAISERROR('Missing Retained Earnings Account',16,1)
          RETURN -1
      END

    IF @intIncomeSummaryAccount IS NULL
      BEGIN
          RAISERROR('Missing Income Summary Account',16,1)
          RETURN -1
      END

    DECLARE @ysnREOverrideLocation BIT,
            @ysnREOverrideLOB      BIT,
            @ysnREOverrideCompany  BIT

    SELECT @ysnREOverrideLocation = ysnREOverrideLocation,
           @ysnREOverrideLOB = ysnREOverrideLOB,
           @ysnREOverrideCompany = ysnREOverrideCompany
    FROM   tblGLCompanyPreferenceOption

    TRUNCATE TABLE tblGLTempAccountToBuild

    DECLARE @tbl TABLE
      (
         intAccountStructureId INT,
         intAccountSegmentId   INT
      )

    SELECT @ysnREOverrideLocation = 1,
           @ysnREOverrideLOB = 1,
           @ysnREOverrideCompany = 0

    INSERT INTO @tbl
    SELECT B.intAccountStructureId,
           B.intAccountSegmentId
    FROM   tblGLAccountSegmentMapping A
           JOIN tblGLAccountSegment B
             ON A.intAccountSegmentId = B.intAccountSegmentId
    WHERE  intAccountId IN ( @intRetainedEarningsAccount,
                             @intIncomeSummaryAccount )

    IF isnull(@ysnREOverrideCompany, 0) = 1
      DELETE FROM @tbl
      WHERE  intAccountStructureId = 6

    IF isnull(@ysnREOverrideLocation, 0) = 1
      DELETE FROM @tbl
      WHERE  intAccountStructureId = 3

    IF isnull(@ysnREOverrideLOB, 0) = 1
      DELETE FROM @tbl
      WHERE  intAccountStructureId = 5

    INSERT INTO tblGLTempAccountToBuild
                (intUserId,
                 intAccountSegmentId,
                 dtmCreated)
    SELECT @intUserId,
           intAccountSegmentId,
           @dtmNow
    FROM   @tbl

    DECLARE @tbl1 TABLE
      (
         intAccountId          INT,
         intAccountStructureId INT,
         intAccountSegmentId   INT,
         strDescription        NVARCHAR(200)
      )

    INSERT INTO @tbl1
    SELECT A.intAccountId,
           B.intAccountStructureId,
           B.intAccountSegmentId,
           B.strDescription
    FROM   tblGLAccountSegmentMapping A
           JOIN tblGLAccountSegment B
             ON A.intAccountSegmentId = B.intAccountSegmentId
           LEFT JOIN @tbl T
                  ON T.intAccountStructureId = B.intAccountStructureId
    WHERE  A.intAccountId IN (SELECT intAccountId
                              FROM   vyuGLAccountDetail
                              WHERE  strAccountType IN ( 'Expense', 'Revenue' ))
           AND T.intAccountStructureId IS NULL

    INSERT INTO tblGLTempAccountToBuild
                (intUserId,
                 intAccountSegmentId,
                 dtmCreated)
    SELECT @intUserId,
           intAccountSegmentId,
           @dtmNow
    FROM   @tbl1
    GROUP  BY intAccountSegmentId

    EXEC uspGLBuildAccountTemporary
      1 