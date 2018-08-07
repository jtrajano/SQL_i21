CREATE PROCEDURE [dbo].[uspSTStoreAppValidateStoreAndRegister]
	@intStoreNo INT,
	@ysnSuccess BIT OUTPUT,
	@strResult AS NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @ysnSuccess = CAST(1 AS BIT)


		DECLARE @strRegisterClass AS NVARCHAR(50) = ''
		--DECLARE @strFilePrefixMain AS NVARCHAR(20) = ''

		-- Create table for error
		DECLARE @tempTableError TABLE (
				[intErrorId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
				[strErrorMessage] NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		)

		-- Get Register Class if exists
		SELECT @strRegisterClass = strRegisterClass
		FROM tblSTRegister Reg
		JOIN tblSTStore ST
			ON Reg.intRegisterId = ST.intRegisterId
		WHERE ST.intStoreNo = @intStoreNo

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
		ELSE IF (@strRegisterClass NOT IN ('RADIANT', 'PASSPORT'))
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
			AND RegConfig.strFilePrefix = 'ISM'
		)
			BEGIN
				INSERT INTO @tempTableError
				(
					[strErrorMessage]
				)
				SELECT 'Register ' + @strRegisterClass + ' XML Configuration has no ISM setup'
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

