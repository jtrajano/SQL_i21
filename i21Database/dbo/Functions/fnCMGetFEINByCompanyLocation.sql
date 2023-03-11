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
  
DECLARE @ysnHasLocation BIT = 0  
DECLARE @ysnHasCompany BIT = 0  
DECLARE @intAccountId INT  
  
SELECT TOP 1 @ysnHasLocation  = 1 FROM tblGLAccountStructure WHERE intStructureType = 3  
SELECT TOP 1 @ysnHasCompany  = 1 FROM tblGLAccountStructure WHERE intStructureType = 6  
  
SELECT TOP 1 @intAccountId =intGLAccountId FROM tblCMBankAccount A   WHERE intBankAccountId = @intBankAccountId  
  
DECLARE @intAccountSegmentIdLocation INT  
DECLARE @intAccountSegmentIdCompany INT  
DECLARE @strLocationCode NVARCHAR(10)
DECLARE @strCompanyCode NVARCHAR(10)
IF @ysnHasLocation =1  
 SELECT  @intAccountSegmentIdLocation = intAccountSegmentId, @strLocationCode = strCode from vyuGLLocationAccountId where @intAccountId = intAccountId  
  
IF @ysnHasCompany = 1  
 SELECT  @intAccountSegmentIdCompany = intAccountSegmentId, @strCompanyCode = strCode from vyuGLCompanyAccountId where @intAccountId = intAccountId  
  
IF @ysnHasLocation = 1 AND @ysnHasCompany = 1  
 INSERT INTO @tbl(FEIN, Error)  
 SELECT TOP 1 strFEIN, '' FROM tblSMCompanyLocation   
 WHERE intProfitCenter = @intAccountSegmentIdLocation AND intCompanySegment = @intAccountSegmentIdCompany  
  
IF @ysnHasLocation = 1 AND @ysnHasCompany = 0  
 INSERT INTO @tbl(FEIN, Error)  
 SELECT TOP 1 strFEIN, '' FROM tblSMCompanyLocation   
 WHERE intProfitCenter = @intAccountSegmentIdLocation  
  
  
IF NOT EXISTS(SELECT 1 FROM  @tbl)  
BEGIN  
  
 INSERT INTO @tbl (  
   Error  
 )  
  SELECT  
 CASE WHEN @ysnHasLocation = 1 AND @ysnHasCompany = 0    THEN 
  'Company Location screen has no setting for Location Code ' + @strLocationCode
  WHEN @ysnHasLocation = 1 AND @ysnHasCompany = 1 THEN
   'Company Location screen has no setting for Company Code ' + @strCompanyCode + ' and Location Code ' + @strLocationCode
  ELSE '' END
END  
ELSE

IF EXISTS( SELECT 1 FROM @tbl WHERE ISNULL(FEIN,'') = '' )
BEGIN
	IF @ysnHasLocation = 1 AND @ysnHasCompany = 0   
		UPDATE @tbl SET Error = 'Missing FEIN value in Company Location screen for Location Code ' + @strLocationCode
	IF @ysnHasLocation = 1 AND @ysnHasCompany = 1
		UPDATE @tbl SET Error = 'Missing FEIN value in Company Location screen for Company Code ' + @strCompanyCode + ' and Location Code ' + @strLocationCode
END

RETURN  
  
END