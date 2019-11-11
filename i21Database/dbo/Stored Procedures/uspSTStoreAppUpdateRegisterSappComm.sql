CREATE PROCEDURE [dbo].[uspSTStoreAppUpdateRegisterSappComm]
	@intStoreNo INT
	, @strPassword NVARCHAR(100)
	, @dtmLastPasswordChange DATETIME
	, @intPasswordIncrementNo INT
	, @ysnResultSuccess BIT OUTPUT
	, @strResultMessage NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @ysnResultSuccess = CAST(0 AS BIT)
		SET @strResultMessage = NULL


		IF EXISTS(SELECT TOP 1 1 FROM tblSTStore WHERE intStoreNo = @intStoreNo)
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM tblSTStore WHERE intStoreNo = @intStoreNo AND intRegisterId IS NOT NULL)
					BEGIN
						
						DECLARE @intRegisterId INT = (SELECT intRegisterId FROM tblSTStore WHERE intStoreNo = @intStoreNo)
						IF EXISTS(SELECT TOP 1 1 FROM tblSTRegister WHERE intRegisterId = @intRegisterId)
							BEGIN
								
									UPDATE reg
									SET dtmSAPPHIRELastPasswordChangeDate	= ISNULL(@dtmLastPasswordChange, reg.dtmSAPPHIRELastPasswordChangeDate),
										strSAPPHIREPassword					= ISNULL(dbo.fnAESEncryptASym(@strPassword), reg.strSAPPHIREPassword),
										intSAPPHIREPasswordIncrementNo		= ISNULL(@intPasswordIncrementNo, reg.intSAPPHIREPasswordIncrementNo)
									FROM tblSTRegister reg
									WHERE reg.intRegisterId = @intRegisterId

								--DECLARE @strSQLCommand AS NVARCHAR(1000)
								--SET @strSQLCommand = 
								--N'
								--	UPDATE reg
								--	SET dtmSAPPHIRELastPasswordChangeDate	= ISNULL(@dtmLastPasswordChange, reg.dtmSAPPHIRELastPasswordChangeDate),
								--		strSAPPHIREPassword					= ISNULL(@strPassword, reg.strSAPPHIREPassword),
								--		intSAPPHIREPasswordIncrementNo		= ISNULL(@intPasswordIncrementNo, reg.intSAPPHIREPasswordIncrementNo)
								--	FROM tblSTRegister reg
								--	WHERE reg.intRegisterId = @intRegisterId
								--'

								--DECLARE @ParmDef NVARCHAR(MAX);

								--SET @ParmDef = N'@dtmLastPasswordChange DATETIME'
								--			 + ', @strPassword NVARCHAR(100)'
								--			 + ', @intPasswordIncrementNo INT'
								--			 + ', @intRegisterId INT';

								--EXEC sp_executesql @strSQLCommand, @ParmDef, @dtmLastPasswordChange, @strPassword, @intPasswordIncrementNo, @intRegisterId

							END
						ELSE
							BEGIN
								SET @ysnResultSuccess = CAST(0 AS BIT)
								SET @strResultMessage = 'Store record does not exists.'
							END
					END
				ELSE
					BEGIN
						SET @ysnResultSuccess = CAST(0 AS BIT)
						SET @strResultMessage = 'Store does not have Register setup.'
					END
				
			END
		ELSE
			BEGIN
				SET @ysnResultSuccess = CAST(0 AS BIT)
				SET @strResultMessage = 'Store record does not exists.'
			END


	END TRY
	BEGIN CATCH
		SET @ysnResultSuccess = CAST(0 AS BIT)
		SET @strResultMessage = ERROR_MESSAGE()
	END CATCH
END




---- TO TEST
--BEGIN TRAN
--DECLARE @ysnResultSuccess BIT
--		, @strResultMessage NVARCHAR(1000)
--		, @dtmLastPasswordChange AS DATETIME = GETDATE()

--SELECT 'BEFORE', ysnSAPPHIREAutoUpdatePassword, dtmSAPPHIRELastPasswordChangeDate, strSAPPHIREPassword, intSAPPHIREPasswordIncrementNo, * FROM tblSTRegister WHERE intRegisterId = 5

--EXEC [dbo].[uspSTStoreAppUpdateRegisterSappComm]
--	@intStoreNo					= 1001
--	, @strPassword				= NULL
--	, @dtmLastPasswordChange	= @dtmLastPasswordChange
--	, @intPasswordIncrementNo	= NULL
--	, @ysnResultSuccess			= @ysnResultSuccess OUT
--	, @strResultMessage			= @strResultMessage OUT

--SELECT 'AFTER', ysnSAPPHIREAutoUpdatePassword, dtmSAPPHIRELastPasswordChangeDate, strSAPPHIREPassword, intSAPPHIREPasswordIncrementNo, * FROM tblSTRegister WHERE intRegisterId = 5

--ROLLBACK TRAN