CREATE FUNCTION fnGLGetCommonSettings( @intEntityId int)			
RETURNS @tbl TABLE (
    intId INT,
    intFiscalYearId INT,
    dtmBeginDate DATETIME,
    dtmEndDate DATETIME,
    dtmPostRemindEndDate DATETIME,
    dtmPostRemindStartDate DATETIME,
    ysnFiscalYearSetup BIT,
    strDefaultPostDate NVARCHAR(10),
    intCompanyId INT,
    strMask NVARCHAR(40),
    strDivider NVARCHAR(5),
    intPrimaryLength INT,
    ysnAccountBuilt BIT

)
AS
BEGIN
    DECLARE @dtmEndDateClosed DATETIME , @dtmDateResult DATETIME, @strDefaultPostDate NVARCHAR(10)
    SELECT TOP 1 @dtmEndDateClosed = dtmEndDate  FROM tblGLFiscalYearPeriod where ysnOpen = 0 ORDER BY dtmEndDate DESC
    SELECT TOP 1 @dtmDateResult = dtmEndDate FROM tblGLFiscalYearPeriod WHERE dtmStartDate > @dtmEndDateClosed and  ysnOpen = 1 ORDER BY dtmStartDate

    IF @dtmDateResult IS NULL 
            SELECT TOP 1 @strDefaultPostDate=  ISNULL(CONVERT(NVARCHAR(10), dtmEndDate, 101),'') FROM tblGLFiscalYearPeriod  WHERE ysnOpen = 1 ORDER BY dtmStartDate
    ELSE
            SELECT @strDefaultPostDate = CONVERT(NVARCHAR(10), @dtmDateResult, 101) 

    INSERT INTO @tbl (intId) VALUES(1)
    UPDATE A SET intFiscalYearId = CurrentFiscal.intFiscalYearId,dtmBeginDate= CurrentFiscal.dtmBeginDate,dtmEndDate= CurrentFiscal.dtmEndDate,
    ysnFiscalYearSetup = cast( Fiscal.ysnHasFiscalYear AS BIT),
    dtmPostRemindStartDate = PostRemind.DateLimit1,dtmPostRemindEndDate = PostRemind.DateLimit2,
    strDefaultPostDate =@strDefaultPostDate,
    intCompanyId = Company.intMultiCompanyId,
    intPrimaryLength = Struc.intLength,
    ysnAccountBuilt = GL.ysnAccountBuild,
    strMask = GL.strAccountId,
    strDivider = Divider.strMask
    FROM @tbl A
    OUTER APPLY(
        SELECT TOP 1 1 ysnHasFiscalYear FROM tblGLFiscalYear
    )Fiscal
    OUTER APPLY(
    SELECT TOP 1 intFiscalYearId,dtmBeginDate,dtmEndDate FROM dbo.tblGLCurrentFiscalYear 
    ) CurrentFiscal
    OUTER APPLY(
        SELECT TOP 1 DateLimit1, DateLimit2 FROM dbo.vyuGLPostRemind vgr WHERE vgr.intEntityId=@intEntityId
    )PostRemind
    OUTER APPLY(
        SELECT TOP 1 C.intMultiCompanyId FROM tblSMMultiCompany MC join tblSMCompanySetup C ON C.intMultiCompanyId = MC.intMultiCompanyId
    )Company
    OUTER APPLY(
                SELECT TOP 1 intLength FROM tblGLAccountStructure WHERE strType = 'Primary'
    )Struc
    OUTER APPLY(
                SELECT TOP 1 strMask FROM tblGLAccountStructure WHERE strType = 'Divider'
    )Divider
    OUTER APPLY(
            SELECT  TOP 1 1 ysnAccountBuild, strAccountId FROM tblGLAccount
    )GL
    

    IF EXISTS(SELECT 1 FROM @tbl WHERE ysnAccountBuilt = 1)
    BEGIN
    DECLARE @string NVARCHAR(30)

    SELECT @string= strMask from @tbl
    
    WHILE PATINDEX('%[0-8]%', @string) > 0
    BEGIN
        SET @string = REPLACE(@string,SUBSTRING(@string,PATINDEX('%[0-8]%',@string),1),'9')
    END
    UPDATE @tbl set strMask =  @string

    END
    ELSE
        UPDATE @tbl set strMask =  '?'





RETURN
END