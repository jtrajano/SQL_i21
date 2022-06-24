CREATE FUNCTION  dbo.fnCMGetVendorAcctNoByLocation
(
	@intBankAccountId INT,
	@intEntityVendorId INT
)
RETURNS  NVARCHAR(50)
AS
BEGIN

DECLARE @intLocationSegmentId int , @intCompanySegmentId INT, @intCompanyLocationId INT, @strVendorAccountNum NVARCHAR(50) = ''
SELECT  @intLocationSegmentId = L.intAccountSegmentId, @intCompanySegmentId = C.intAccountSegmentId from tblCMBankAccount A  
OUTER apply(
	select  intAccountSegmentId from vyuGLLocationAccountId where intGLAccountId = intAccountId
)L
OUTER apply(
	select  intAccountSegmentId from vyuGLCompanyAccountId where intGLAccountId = intAccountId
)C
WHERE @intBankAccountId = intBankAccountId

IF @intLocationSegmentId IS NOT NULL AND @intCompanySegmentId IS NULL
SELECT TOP 1 @strVendorAccountNum = strVendorAccountNum from tblSMCompanyLocation A JOIN
tblAPVendorAccountNumLocation B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intProfitCenter = @intLocationSegmentId
and @intEntityVendorId = intEntityVendorId


IF @intLocationSegmentId IS NULL AND @intCompanySegmentId IS NOT NULL
SELECT TOP 1 @strVendorAccountNum = strVendorAccountNum from tblSMCompanyLocation A JOIN
tblAPVendorAccountNumLocation B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intCompanySegment = @intCompanySegmentId
and @intEntityVendorId = intEntityVendorId


IF @intLocationSegmentId IS NOT NULL AND @intCompanySegmentId IS NOT NULL
SELECT TOP 1 @strVendorAccountNum = strVendorAccountNum from tblSMCompanyLocation A JOIN
tblAPVendorAccountNumLocation B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intCompanySegment = @intCompanySegmentId AND intProfitCenter = @intLocationSegmentId
and @intEntityVendorId = intEntityVendorId

IF ISNULL(@strVendorAccountNum,'') = ''
	SELECT TOP 1 @strVendorAccountNum = strVendorAccountNum FROM tblAPVendor  WHERE  intEntityId = @intEntityVendorId


RETURN  @strVendorAccountNum

END