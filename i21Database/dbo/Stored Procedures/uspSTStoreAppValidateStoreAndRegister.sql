CREATE PROCEDURE [dbo].[uspSTStoreAppValidateStoreAndRegister]
	@intStoreNo INT
	, @ysnSuccess BIT OUTPUT
	, @strResult AS NVARCHAR(1000) OUTPUT
	, @strRegisterClass AS NVARCHAR(30) OUTPUT
	, @strRegisterIPAddress AS NVARCHAR(150) OUTPUT
	, @strRegisterUsername AS NVARCHAR(150) OUTPUT
	, @strRegisterPassword AS NVARCHAR(150) OUTPUT
	, @intPeriodNum AS INT OUTPUT
	, @intSetNum AS INT OUTPUT
	, @strPullTime AS NVARCHAR(30) OUTPUT
	
	-- , @ysnAutoUpdatePassword AS BIT OUTPUT
	--, @dtmLastPasswordChangeDate AS DATETIME OUTPUT
	--, @strBasePassword AS NVARCHAR(100) OUTPUT
	--, @intPasswordIntervalDays AS INT OUTPUT
	--, @intPasswordIncrementNo AS INT OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @ysnSuccess = CAST(1 AS BIT)
		SET @strRegisterClass = ''
		SET @strRegisterIPAddress = ''
		SET @strRegisterUsername = ''
		SET @strRegisterPassword = ''
		SET @intPeriodNum = 0
		SET @intSetNum = 0
		SET @strPullTime = ''

		--DECLARE @strRegisterClass AS NVARCHAR(50) = ''
		----DECLARE @strFilePrefixMain AS NVARCHAR(20) = ''

		-- Create table for error
		DECLARE @tempTableError TABLE (
				[intErrorId]		INT				NOT NULL PRIMARY KEY IDENTITY(1,1),
				[strErrorMessage]	NVARCHAR(1000)	COLLATE Latin1_General_CI_AS NULL
		)

		-- Get Register Class if exists
		SELECT 
			@strRegisterClass = ISNULL(Reg.strRegisterClass, '')
			, @strRegisterIPAddress = ISNULL(Reg.strSapphireIpAddress, '')
			, @strRegisterUsername = ISNULL(Reg.strSAPPHIREUserName, '')
			, @strRegisterPassword = ISNULL(dbo.fnAESDecryptASym(Reg.strSAPPHIREPassword), '')
			, @intPeriodNum = ISNULL(Reg.intSAPPHIRECheckoutPullTimePeriodId, 0)
			, @intSetNum = ISNULL(Reg.intSAPPHIRECheckoutPullTimeSetId, 0)
			, @strPullTime = ISNULL(Reg.strSAPPHIRECheckoutPullTime, '')

			--, @ysnAutoUpdatePassword = ISNULL(Reg.ysnSAPPHIREAutoUpdatePassword, 0)
			--, @dtmLastPasswordChangeDate = ISNULL(Reg.dtmSAPPHIRELastPasswordChangeDate, GETDATE())
			--, @strBasePassword = ISNULL(dbo.fnAESDecryptASym(Reg.strSAPPHIREBasePassword), '')
			--, @intPasswordIntervalDays = Reg.intSAPPHIREPasswordIntervalDays
			--, @intPasswordIncrementNo = Reg.intSAPPHIREPasswordIncrementNo
		FROM tblSTRegister Reg
		JOIN tblSTStore ST
			ON Reg.intRegisterId = ST.intRegisterId
		WHERE ST.intStoreNo = @intStoreNo

		-- Convert to TIME, example: '4:00:00 AM'
		IF (@strPullTime != '')
			BEGIN
				SET @strPullTime = LTRIM(RIGHT(CONVERT(CHAR(20), CAST((@strPullTime) AS DATETIME), 22), 11))
			END
		

		--IF(@strRegisterClass IN ('PASSPORT', 'RADIANT'))
		--	BEGIN
		--		SET @strFilePrefixMain = 'ISM'
		--	END

		-- Check Store exists
		IF NOT EXISTS
		(
			SELECT intStoreNo 
			FROM tblSTStore 
			WHERE intStoreNo = @intStoreNo
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Store ' + CAST(@intStoreNo AS NVARCHAR(20)) + ' does not exists'
			END

		-- Check Store has register
		ELSE IF NOT EXISTS
		(
			SELECT intStoreNo 
			FROM tblSTStore 
			WHERE intStoreNo = @intStoreNo 
			AND intRegisterId IS NOT NULL
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Store ' + CAST(@intStoreNo AS NVARCHAR(20)) + ' does not have register'
			END

		-- Check Register if (RADIANT or PASSPORT)
		ELSE IF (@strRegisterClass NOT IN ('RADIANT', 'PASSPORT', 'SAPPHIRE/COMMANDER'))
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Register ' + @strRegisterClass + ' is not configured for Shared Drive transaction'
			END





		-- Check Register has Shared Drive folder path (Inbound)
		ELSE IF NOT EXISTS
		(
			SELECT Reg.intRegisterId
			FROM tblSTRegister Reg
			JOIN tblSTStore ST
				ON Reg.intRegisterId = ST.intRegisterId
			WHERE ST.intStoreNo = @intStoreNo
			AND (Reg.strRegisterInboxPath != '' AND Reg.strRegisterInboxPath IS NOT NULL)
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Register ' + ISNULL(@strRegisterClass, '') + ' does not have setup for Shared Drive Inbound'
			END
		
		-- Check Register has Shared Drive folder path (Outbound)
		ELSE IF NOT EXISTS
		(
			SELECT Reg.intRegisterId
			FROM tblSTRegister Reg
			JOIN tblSTStore ST
				ON Reg.intRegisterId = ST.intRegisterId
			WHERE ST.intStoreNo = @intStoreNo
			AND (Reg.strRegisterOutboxPath != '' AND Reg.strRegisterOutboxPath IS NOT NULL)
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Register ' + ISNULL(@strRegisterClass, '') + ' does not have setup for Shared Drive Outbound'
			END





		-- Check Register has xml configuration
		ELSE IF NOT EXISTS
		(
			SELECT RegConfig.intRegisterFileConfigId
			FROM tblSTRegisterFileConfiguration RegConfig
			JOIN tblSTRegister Reg
				ON RegConfig.intRegisterId = Reg.intRegisterId
			JOIN tblSTStore ST
				ON Reg.intRegisterId = ST.intRegisterId
			WHERE ST.intStoreNo = @intStoreNo
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Register ' + @strRegisterClass + ' has no Register XML Configuration'
			END

		-- Check Register configuration has file type Inbound
		ELSE IF NOT EXISTS
		(
			SELECT RegConfig.intRegisterFileConfigId
			FROM tblSTRegisterFileConfiguration RegConfig
			JOIN tblSTRegister Reg
				ON RegConfig.intRegisterId = Reg.intRegisterId
			JOIN tblSTStore ST
				ON Reg.intRegisterId = ST.intRegisterId
			WHERE ST.intStoreNo = @intStoreNo
			AND RegConfig.strFileType = 'Inbound'
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Register ' + @strRegisterClass + ' XML Configuration has no Inbound setup'
			END

		-- Check Register configuration has file type Outbound
		ELSE IF NOT EXISTS
		(
			SELECT RegConfig.intRegisterFileConfigId
			FROM tblSTRegisterFileConfiguration RegConfig
			JOIN tblSTRegister Reg
				ON RegConfig.intRegisterId = Reg.intRegisterId
			JOIN tblSTStore ST
				ON Reg.intRegisterId = ST.intRegisterId
			WHERE ST.intStoreNo = @intStoreNo
				AND RegConfig.strFileType = 'Outbound'
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Register ' + @strRegisterClass + ' XML Configuration has no Outbound setup'
			END

		-- Check Register configuration has main prefix file setup (ISM)
		ELSE IF NOT EXISTS
		(
			SELECT RegConfig.intRegisterFileConfigId
			FROM tblSTRegisterFileConfiguration RegConfig
			JOIN tblSTRegister Reg
				ON RegConfig.intRegisterId = Reg.intRegisterId
			JOIN tblSTStore ST
				ON Reg.intRegisterId = ST.intRegisterId
			WHERE ST.intStoreNo = @intStoreNo
				AND RegConfig.strFileType = 'Inbound'
				AND RegConfig.strFilePrefix = CASE
												WHEN @strRegisterClass IN ('RADIANT', 'PASSPORT')
													THEN 'ISM'
												WHEN (@strRegisterClass IN ('SAPPHIRE/COMMANDER'))
													THEN 'vrubyrept-department'

												-- Transactionlog should be included in checkout
												--WHEN (@strRegisterClass IN ('SAPPHIRE') AND Reg.ysnTransctionLog = CAST(1 AS BIT))
												--	THEN 'vtransset-tlog'
												--WHEN (@strRegisterClass IN ('SAPPHIRE') AND Reg.ysnDepartmentTotals = CAST(1 AS BIT))
												--	THEN 'vrubyrept-department'
												ELSE NULL
											END
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Register ' + @strRegisterClass + ' XML Configuration has no main xml setup'
			END

		IF EXISTS(SELECT intErrorId FROM @tempTableError)
			BEGIN
				SET @ysnSuccess = CAST(0 AS BIT)
			END

		SELECT * FROM @tempTableError
	END TRY

	BEGIN CATCH
		SET @ysnSuccess = CAST(0 AS BIT)
		SET @strResult = ERROR_MESSAGE()
	END CATCH
END