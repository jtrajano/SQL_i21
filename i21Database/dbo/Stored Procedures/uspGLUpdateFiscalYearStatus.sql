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

BEGIN TRANSACTION;

BEGIN TRY
	IF @ysnPost = 1
	BEGIN
		UPDATE tblGLFiscalYear SET ysnStatus = 0 WHERE intFiscalYearId = @intFiscalYearId	
		UPDATE tblGLFiscalYearPeriod SET ysnOpen = 0,ysnAROpen = 0, ysnAPOpen = 0, ysnINVOpen = 0, ysnCMOpen = 0, ysnPROpen = 0, ysnCTOpen = 0 where intFiscalYearId = @intFiscalYearId
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
		UPDATE tblGLFiscalYearPeriod SET ysnOpen = 1,ysnAROpen = 1, ysnAPOpen = 1, ysnINVOpen = 1, ysnCMOpen = 1, ysnPROpen = 1, ysnCTOpen = 1 where intFiscalYearId = @intFiscalYearId
	END
	
	
	
END TRY
BEGIN CATCH

	SELECT  0
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	
END CATCH;

IF @@TRANCOUNT > 0
	BEGIN
		SELECT 1
		COMMIT TRANSACTION;
	END
GO
