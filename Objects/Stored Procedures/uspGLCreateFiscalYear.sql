CREATE PROCEDURE uspGLCreateFiscalYear
	@strFiscalYear NVARCHAR(4),
	@intFiscalYearId INT OUTPUT 
AS 
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM tblGLFiscalYear WHERE strFiscalYear = @strFiscalYear)
		RETURN -1

	DECLARE @intRetainAccount INT, @dtmDateTo DATETIME, @dtmDateFrom DATETIME

	SELECT TOP 1 @intRetainAccount = intRetainAccount FROM tblGLFiscalYear
	SELECT @dtmDateTo = DATEADD(SECOND,-1, @strFiscalYear +'-02-01')
	SELECT @dtmDateFrom = @strFiscalYear +'-01-01'

	INSERT INTO tblGLFiscalYear(strFiscalYear, intRetainAccount, dtmDateFrom, dtmDateTo, ysnStatus, intConcurrencyId)
	SELECT @strFiscalYear,@intRetainAccount,@dtmDateFrom ,@dtmDateTo , 0, 1

	SELECT @intFiscalYearId= SCOPE_IDENTITY()

	INSERT INTO tblGLFiscalYearPeriod ( intFiscalYearId, strPeriod, dtmStartDate, dtmEndDate,ysnOpen, ysnAPOpen, ysnAROpen, ysnINVOpen, ysnCMOpen, ysnCTOpen, ysnFAOpen, ysnPROpen, intConcurrencyId)
	SELECT @intFiscalYearId, 'January ' + @strFiscalYear , @dtmDateFrom ,@dtmDateTo,0,0,0,0,0,0,0,0,1

	
	IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	BEGIN
		INSERT INTO glfypmst (glfyp_yr, glfyp_beg_date_1,glfyp_end_date_1,glfyp_closed_yn,glfyp_purged_yn)
		SELECT @strFiscalYear, CAST( @strFiscalYear + '0101' AS INT), CAST(@strFiscalYear + '0131' AS INT),'Y','N'
	END

	RETURN 1

END