
CREATE PROCEDURE uspGLBuildRetainedEarningsAccount
AS
DECLARE @dtmNow datetime = getdate()
DECLARE @intUserId INT =1
DECLARE @intRetainedEarningsAccount INT
DECLARE @intIncomeSummaryAccount INT
SELECT @intRetainedEarningsAccount = intRetainAccount FROM tblGLFiscalYear 
SELECT @intIncomeSummaryAccount = intIncomeSummaryAccountId FROM tblGLCompanyPreferenceOption 

DECLARE @ysnREOverrideLocation bit , @ysnREOverrideLOB bit , @ysnREOverrideCompany bit
select  @ysnREOverrideLocation= ysnREOverrideLocation,@ysnREOverrideLOB =ysnREOverrideLOB,@ysnREOverrideCompany = ysnREOverrideCompany  from tblGLCompanyPreferenceOption 

truncate table tblGLTempAccountToBuild

DECLARE @tbl table(
	intAccountStructureId int,
	intAccountSegmentId INT
)

select @ysnREOverrideLocation = 1,@ysnREOverrideLOB =1,@ysnREOverrideCompany = 0
INSERT INTO @tbl
SELECT B.intAccountStructureId, B.intAccountSegmentId
FROM tblGLAccountSegmentMapping 
A join tblGLAccountSegment B on A.intAccountSegmentId = B.intAccountSegmentId
WHERE intAccountId = @intRetainedEarningsAccount


IF isnull(@ysnREOverrideCompany,0) = 1  DELETE FROM @tbl where intAccountStructureId = 6
IF isnull(@ysnREOverrideLocation,0) = 1  DELETE FROM @tbl where intAccountStructureId  = 3
IF isnull(@ysnREOverrideLOB,0) = 1 DELETE FROM @tbl where intAccountStructureId  = 5

insert into 
tblGLTempAccountToBuild ( intUserId , intAccountSegmentId, dtmCreated)
SELECT @intUserId, intAccountSegmentId , @dtmNow from @tbl


DECLARE @tbl1 table(
	intAccountId int,
	intAccountStructureId int,
	intAccountSegmentId INT,
	strDescription NVARCHAR(200)
)
INSERT INTO @tbl1

SELECT A.intAccountId,B.intAccountStructureId, B.intAccountSegmentId, B.strDescription 
FROM tblGLAccountSegmentMapping 
A join tblGLAccountSegment B on A.intAccountSegmentId = B.intAccountSegmentId
LEFT JOIN @tbl T on T.intAccountStructureId = B.intAccountStructureId
WHERE A.intAccountId in (

SELECT intAccountId FROM vyuGLAccountDetail
	where strAccountType in ('Expense', 'Revenue')
)
AND T.intAccountStructureId IS NULL

insert into 
tblGLTempAccountToBuild ( intUserId , intAccountSegmentId, dtmCreated)
SELECT @intUserId, intAccountSegmentId , @dtmNow from @tbl1
group by intAccountSegmentId

exec uspGLBuildAccountTemporary 1

