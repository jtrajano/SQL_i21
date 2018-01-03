CREATE PROCEDURE [dbo].[uspGLUpdateFiscalYearStatus]
	 @intFiscalYearId	AS INT
	,@ysnPost			AS BIT				= 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

DECLARE  @strRetainedAcctGroup	 NVARCHAR(50)  
		,@intAccountId			 INT		
		,@intYear				INT
		,@strRetainedAccount	NVARCHAR(50)	= ''

IF @ysnPost = 1
BEGIN
	UPDATE tblGLFiscalYear SET ysnStatus = 0 WHERE intFiscalYearId = @intFiscalYearId	
	UPDATE tblGLFiscalYearPeriod SET ysnOpen = 0,ysnAROpen = 0, ysnAPOpen = 0, ysnINVOpen = 0, ysnCMOpen = 0, ysnPROpen = 0, ysnCTOpen = 0, ysnFAOpen = 0 where intFiscalYearId = @intFiscalYearId

	IF EXISTS(SELECT TOP 1 1 FROM tblGLCurrentFiscalYear WHERE intFiscalYearId = @intFiscalYearId)
	BEGIN
		--update the current fiscal year to next open fiscal year
		DECLARE @currentYear  NVARCHAR(4)
		SELECT TOP 1 @currentYear =  strFiscalYear  FROM tblGLCurrentFiscalYear CF JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = CF.intFiscalYearId
		UPDATE CF  SET intFiscalYearId = FY.intFiscalYearId , dtmBeginDate = FY.dtmDateFrom, dtmEndDate = FY.dtmDateTo FROM tblGLCurrentFiscalYear CF 
		CROSS APPLY(
			SELECT TOP 1 intFiscalYearId, dtmDateFrom,dtmDateTo  FROM tblGLFiscalYear WHERE strFiscalYear > @currentYear AND ysnStatus = 1 ORDER BY strFiscalYear 
		)FY
	END
END	
ELSE IF @ysnPost = 0 
BEGIN
	SET @intYear			= (SELECT TOP 1 CAST(strFiscalYear as INT) FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId) 		
	SET @strRetainedAccount = (SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId))
	SET @intAccountId			= (SELECT intAccountId FROM tblGLAccount WHERE strAccountId = @strRetainedAccount)
	SET @strRetainedAcctGroup	= ISNULL((SELECT TOP 1 strAccountGroup FROM tblGLAccount A
												LEFT JOIN tblGLAccountGroup B
												ON A.intAccountGroupId = B.intAccountGroupId WHERE A.strAccountId = @strRetainedAccount), '')
	UPDATE tblGLDetail SET ysnIsUnposted = 1 WHERE strTransactionId = CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount and ysnIsUnposted = 0
	UPDATE tblGLFiscalYear SET ysnStatus = 1 WHERE intFiscalYearId = @intFiscalYearId
	UPDATE tblGLFiscalYearPeriod SET ysnOpen = 1,ysnAROpen = 1, ysnAPOpen = 1, ysnINVOpen = 1, ysnCMOpen = 1, ysnPROpen = 1, ysnCTOpen = 1, ysnFAOpen = 1 where intFiscalYearId = @intFiscalYearId
END
