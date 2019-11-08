CREATE PROCEDURE [dbo].[uspSTStoreAppUpdateRegisterSappComm]
	@intRegisterId INT
	, @strPassword NVARCHAR(100)
	, @ysnAutoUpdatePassword BIT
	, @dtmLastPasswordChange DATETIME
	, @intPasswordIncrementNo INT
	, @ysnResultSuccess BIT OUTPUT
	, @strResultMessage NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @ysnResultSuccess = CAST(0 AS BIT)
		SET @strResultMessage = NULL


		IF EXISTS(SELECT TOP 1 1 FROM tblSTRegister WHERE intRegisterId = @intRegisterId)
			BEGIN
				DECLARE @strSQLCommand AS NVARCHAR(1000)
				SET @strSQLCommand = 
				N'
					UPDATE reg
					SET ysnSAPPHIREAutoUpdatePassword		= ISNULL(@ysnAutoUpdatePassword, reg.ysnSAPPHIREAutoUpdatePassword),
						dtmSAPPHIRELastPasswordChangeDate	= ISNULL(@dtmLastPasswordChange, reg.dtmSAPPHIRELastPasswordChangeDate),
						strSAPPHIREPassword					= ISNULL(@strPassword, reg.strSAPPHIREPassword),
						intSAPPHIREPasswordIncrementNo		= ISNULL(@intPasswordIncrementNo, reg.intSAPPHIREPasswordIncrementNo)
					FROM tblSTRegister reg
					WHERE reg.intRegisterId = @intRegisterId
				'

				DECLARE @ParmDef NVARCHAR(MAX);

				SET @ParmDef = N'@ysnAutoUpdatePassword BIT'
							 + ', @dtmLastPasswordChange DATETIME'
							 + ', @strPassword NVARCHAR(100)'
							 + ', @intPasswordIncrementNo INT'
							 + ', @intRegisterId INT';

				EXEC sp_executesql @strSQLCommand, @ParmDef, @ysnAutoUpdatePassword, @dtmLastPasswordChange, @strPassword, @intPasswordIncrementNo, @intRegisterId
			END
		ELSE
			BEGIN
				SET @ysnResultSuccess = CAST(0 AS BIT)
				SET @strResultMessage = 'Register record does not exists.'
			END


	END TRY
	BEGIN CATCH
		SET @ysnResultSuccess = CAST(0 AS BIT)
		SET @strResultMessage = ERROR_MESSAGE()
	END CATCH
END




-- TO TEST
--BEGIN TRAN
--DECLARE @ysnResultSuccess BIT
--		, @strResultMessage NVARCHAR(1000)
--		, @dtmLastPasswordChange AS DATETIME = GETDATE()

--SELECT 'BEFORE', ysnSAPPHIREAutoUpdatePassword, dtmSAPPHIRELastPasswordChangeDate, strSAPPHIREPassword, intSAPPHIREPasswordIncrementNo, * FROM tblSTRegister WHERE intRegisterId = 5

--EXEC [dbo].[uspSTStoreAppUpdateRegisterSappComm]
--	@intRegisterId				= 5
--	, @strPassword				= 'QWERTY'
--	, @ysnAutoUpdatePassword	= NULL
--	, @dtmLastPasswordChange	= @dtmLastPasswordChange
--	, @intPasswordIncrementNo	= NULL
--	, @ysnResultSuccess			= @ysnResultSuccess OUT
--	, @strResultMessage			= @strResultMessage OUT

--SELECT 'AFTER', ysnSAPPHIREAutoUpdatePassword, dtmSAPPHIRELastPasswordChangeDate, strSAPPHIREPassword, intSAPPHIREPasswordIncrementNo, * FROM tblSTRegister WHERE intRegisterId = 5

--ROLLBACK TRAN