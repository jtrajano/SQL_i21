CREATE FUNCTION  dbo.fnCMGetVendorAcctNoByLocation
(
	@intBankAccountId INT,
	@intEntityVendorId INT
)

RETURNS  NVARCHAR(30)
AS
BEGIN

declare @intLocationSegmentId int , @intCompanySegmentId INT, @intCompanyLocationId INT, @strVendorAccountNum NVARCHAR(50) = ''
select  @intLocationSegmentId = L.intAccountSegmentId, @intCompanySegmentId = C.intAccountSegmentId from tblCMBankAccount A  

outer apply(
	select  intAccountSegmentId from vyuGLLocationAccountId where intGLAccountId = intAccountId
)L
outer apply(
	select  intAccountSegmentId from vyuGLCompanyAccountId where intGLAccountId = intAccountId
)C
WHERE @intBankAccountId = intBankAccountId

if @intCompanySegmentId is not null
	select @intCompanyLocationId =intCompanyLocationId from tblSMCompanyLocation where intProfitCenter = @intLocationSegmentId
ELSE
	if @intLocationSegmentId is not null
	select TOP 1 @intCompanyLocationId =intCompanyLocationId from tblSMCompanyLocation where intProfitCenter = @intLocationSegmentId

IF @intCompanyLocationId IS NOT NULL
	SELECT TOP 1 @strVendorAccountNum = strVendorAccountNum FROM [tblAPVendorAccountNumLocation] where @intCompanyLocationId = intCompanyLocationId AND intEntityVendorId = @intEntityVendorId

IF ISNULL(@strVendorAccountNum,'') = ''
	SELECT TOP 1 @strVendorAccountNum = strVendorAccountNum FROM tblAPVendor  WHERE  intEntityId = @intEntityVendorId


RETURN  @strVendorAccountNum

END