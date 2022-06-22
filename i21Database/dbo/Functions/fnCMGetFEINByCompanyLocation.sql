CREATE FUNCTION  dbo.fnCMGetFEINByCompanyLocation
(
	@intBankAccountId INT,
	@intEntityVendorId INT
)
RETURNS  NVARCHAR(10)
AS
BEGIN

DECLARE @intLocationSegmentId int , @intCompanySegmentId INT, @intCompanyLocationId INT, @strFEIN NVARCHAR(10) = ''
SELECT  @intLocationSegmentId = L.intAccountSegmentId, @intCompanySegmentId = C.intAccountSegmentId from tblCMBankAccount A  
OUTER apply(
	select  intAccountSegmentId from vyuGLLocationAccountId where intGLAccountId = intAccountId
)L
OUTER apply(
	select  intAccountSegmentId from vyuGLCompanyAccountId where intGLAccountId = intAccountId
)C
WHERE @intBankAccountId = intBankAccountId

IF @intLocationSegmentId IS NOT NULL AND @intCompanySegmentId IS NULL
SELECT TOP 1 @strFEIN = '' from tblSMCompanyLocation A
WHERE intProfitCenter = @intLocationSegmentId


IF @intLocationSegmentId IS NULL AND @intCompanySegmentId IS NOT NULL
SELECT TOP 1 @strFEIN = '' from tblSMCompanyLocation A
WHERE intCompanySegment = @intCompanySegmentId


IF @intLocationSegmentId IS NOT NULL AND @intCompanySegmentId IS NOT NULL
SELECT TOP 1 @strFEIN = '' from tblSMCompanyLocation A
WHERE intCompanySegment = @intCompanySegmentId AND intProfitCenter = @intLocationSegmentId

RETURN  @strFEIN

END