CREATE FUNCTION  dbo.fnCMGetFEINByCompanyLocation
(
	@intBankAccountId INT
)
RETURNS @tbl TABLE(
	FEIN NVARCHAR(10)  COLLATE Latin1_General_CI_AS NULL ,
	Error NVARCHAR(200) COLLATE  Latin1_General_CI_AS NULL
) 
AS
BEGIN

DECLARE @intLocationSegmentId int , @intCompanySegmentId INT, @intCompanyLocationId INT, @strFEIN NVARCHAR(10) = '', @strError NVARCHAR(200)
SELECT  @intLocationSegmentId = L.intAccountSegmentId, @intCompanySegmentId = C.intAccountSegmentId from tblCMBankAccount A  
OUTER apply(
	select  intAccountSegmentId from vyuGLLocationAccountId where intGLAccountId = intAccountId
)L
OUTER apply(
	select  intAccountSegmentId from vyuGLCompanyAccountId where intGLAccountId = intAccountId
)C
WHERE @intBankAccountId = intBankAccountId

IF @intLocationSegmentId IS NOT NULL AND @intCompanySegmentId IS NULL
BEGIN
	SELECT TOP 1 @strFEIN = strFEIN from tblSMCompanyLocation A
	WHERE intProfitCenter = @intLocationSegmentId
	IF @strFEIN IS NULL 
		SET @strError = 'FEIN was not found. Please fill up the FEIN and make sure that Location GL Account segments of Bank account is set up in the Company Location GL Accounts'
END

IF @intLocationSegmentId IS NULL AND @intCompanySegmentId IS NOT NULL
BEGIN
	SELECT TOP 1 @strFEIN = strFEIN from tblSMCompanyLocation A
	WHERE intCompanySegment = @intCompanySegmentId

	IF @strFEIN IS NULL 
		SET @strError = 'FEIN was not found. Please fill up the FEIN and make sure that Company GL Account segments of Bank account is set up in the Company Location GL Accounts'

END


IF @intLocationSegmentId IS NOT NULL AND @intCompanySegmentId IS NOT NULL
BEGIN
	SELECT TOP 1 @strFEIN = strFEIN from tblSMCompanyLocation A
	WHERE intCompanySegment = @intCompanySegmentId AND intProfitCenter = @intLocationSegmentId

	IF @strFEIN IS NULL 
		SET @strError = 'FEIN was not found. Please fill up the FEIN and make sure that Location and Company GL Account segments of Bank account is set up in the Company Location GL Accounts'

END

INSERT INTO @tbl ( FEIN, Error ) SELECT @strFEIN, @strError

RETURN

END