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


DECLARE @ysnHasLocation BIT = 0
DECLARE @ysnHasComopany BIT = 0

SELECT @ysnHasLocation = 1 FROM tblSMCompanyLocation WHERE intProfitCenter = @intLocationSegmentId

IF (@ysnHasLocation = 1)
BEGIN
	SELECT TOP 1 @ysnHasComopany = 1 FROM tblSMCompanyLocation WHERE intProfitCenter = @intLocationSegmentId AND intCompanySegment = @intCompanySegmentId
END


IF @ysnHasLocation = 0 OR @ysnHasComopany = 0
BEGIN
		SET @strError = 'FEIN was not found. Please fill up the FEIN and make sure that Location and Company Segment of the Bank GL Account is setup in a Company Location.'
END
ELSE
BEGIN
	SELECT TOP 1 @strFEIN = strFEIN from tblSMCompanyLocation A
	WHERE intCompanySegment = @intCompanySegmentId AND intProfitCenter = @intLocationSegmentId

END

INSERT INTO @tbl ( FEIN, Error ) SELECT @strFEIN, @strError

RETURN

END