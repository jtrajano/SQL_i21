﻿GO
DECLARE @intTableCount INT = 0

SELECT @intTableCount = COUNT(ORDINAL_POSITION) 
FROM  INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME IN (N'tblSTRegisterSetup', N'tblSTRegisterSetupDetail', N'tblSMImportFileHeader') AND ORDINAL_POSITION = 1

IF (@intTableCount = 3) 
	BEGIN
		PRINT N'BEGIN - Store Register setup entries'

		DECLARE @intRegisterSetupId AS INT

		-- Header
		DECLARE @strRegisterClass		AS NVARCHAR(100)
			  , @strXmlVersion	AS NVARCHAR(30)

		-- Detail
		DECLARE @intImportFileHeaderId		AS INT
			  , @intRegisterSetupDetailId	AS INT
			  , @strImportFileHeader		AS NVARCHAR(50)
			  , @strFileType				AS NVARCHAR(20)
			  , @strFilePrefix				AS NVARCHAR(50)
			  , @strFileNamePattern			AS NVARCHAR(50)
			  , @strStoredProcedure			AS NVARCHAR(50)


		-- ============================================================================================================
		-- [START] PASSPORT
		-- ============================================================================================================
		BEGIN
			-- Version 3.4
			SET @strRegisterClass		= N'PASSPORT'
			SET @strXmlVersion			= N'3.4'

			-- HEADER
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetup WHERE strRegisterClass = @strRegisterClass AND strXmlVersion = @strXmlVersion)
				BEGIN				
					-- Insert Header
					INSERT INTO tblSTRegisterSetup
					(
						strRegisterClass,
						strXmlVersion,
						intConcurrencyId
					)
					SELECT 
						strRegisterClass	= @strRegisterClass,
						strXmlVersion		= @strXmlVersion,
						intConcurrencyId	= 1


					-- Get New created Id
					SET @intRegisterSetupId = SCOPE_IDENTITY()

				END
			ELSE
				BEGIN

					SELECT TOP 1
						@intRegisterSetupId = intRegisterSetupId
					FROM tblSTRegisterSetup 
					WHERE strRegisterClass = @strRegisterClass 
						AND strXmlVersion = @strXmlVersion

				END

			-- DETAILS	
			--Insert Details
					
			-- MSM 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - MSM 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'MSM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportMSM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- MCM 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - MCM 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'MCM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportMCM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END


			-- ISM 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - ISM 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'ISM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportISM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- FGM 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - FGM 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'FGM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportFGM'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END

			-- FGMA 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - FGMA 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'FGMA'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportFGM'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			END

			-- FGMD 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - FGMD 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'FGMD'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportFGM'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND strImportFileHeaderName = @strImportFileHeader AND strStoredProcedure = @strStoredProcedure)
								BEGIN
									-- INSERT
									INSERT INTO tblSTRegisterSetupDetail 
									(
										intRegisterSetupId, 
										intImportFileHeaderId, 
										strImportFileHeaderName, 
										strFileType, strFilePrefix, 
										strFileNamePattern, 
										strURICommand, 
										strStoredProcedure, 
										intConcurrencyId
									)
									SELECT 
										intRegisterSetupId			= @intRegisterSetupId, 
										intImportFileHeaderId		= @intImportFileHeaderId, 
										strImportFileHeaderName		= @strImportFileHeader, 
										strFileType					= @strFileType, 
										strFilePrefix				= @strFilePrefix, 
										strFileNamePattern			= @strFileNamePattern, 
										strURICommand				= NULL, 
										strStoredProcedure			= @strStoredProcedure, 
										intConcurrencyId			= 1
								END
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END


			-- TLM 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - TLM 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'TLM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportTLM'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END

			
			-- TPM 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - TPM 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'TPM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportTPM'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- CPJR 3.4
			BEGIN
				SET @strImportFileHeader	= N'Passport - CPJR 3.4'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'CPJR'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutPassportTranslog'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- ITT All version
			BEGIN
				SET @strImportFileHeader	= N'Passport Pricebook  - ITT'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'ITT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertPricebookSendFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- ILT All version
			BEGIN
				SET @strImportFileHeader	= N'Passport Pricebook Item List - ILT'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'ILT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertPromotionItemListSend'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END

			END


			-- CBT All version
			BEGIN
				SET @strImportFileHeader	= N'Passport Pricebook Combo - CBT'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'CBT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertComboSalesFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- MMT All version
			BEGIN
				SET @strImportFileHeader	= N'Passport Pricebook Mix Match - MMT'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'MMT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertMixMatchFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END

		END
		-- ============================================================================================================
		-- [END] PASSPORT
		-- ============================================================================================================



		-- ============================================================================================================
		-- [START] SAPPHIRE/COMMANDER
		-- ============================================================================================================
		BEGIN
			-- Version 3.4
			SET @strRegisterClass		= N'SAPPHIRE/COMMANDER'
			SET @strXmlVersion	= N'all'

			-- HEADER
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetup WHERE strRegisterClass = @strRegisterClass AND strXmlVersion = @strXmlVersion)
				BEGIN				
					-- Insert Header
					INSERT INTO tblSTRegisterSetup
					(
						strRegisterClass,
						strXmlVersion,
						intConcurrencyId
					)
					SELECT 
						strRegisterClass			= @strRegisterClass,
						strXmlVersion	= @strXmlVersion,
						intConcurrencyId		= 1


					-- Get New created Id
					SET @intRegisterSetupId = SCOPE_IDENTITY()

				END
			ELSE
				BEGIN

					SELECT TOP 1
						@intRegisterSetupId = intRegisterSetupId
					FROM tblSTRegisterSetup 
					WHERE strRegisterClass = @strRegisterClass 
						AND strXmlVersion = @strXmlVersion

				END

			-- DETAILS	
			--Insert Details
					
			-- vrubyrept-tax
			BEGIN
				SET @strImportFileHeader	= N'Commander Tax'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-tax'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutCommanderTax'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- vrubyrept-department
			BEGIN
				SET @strImportFileHeader	= N'Commander Department'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-department'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutCommanderDepartment'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END


			-- vrubyrept-fpHose
			BEGIN
				SET @strImportFileHeader	= N'Commander FPHose'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-fpHose'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutCommanderFPHose'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId)
		BEGIN
			-- INSERT
			INSERT INTO tblSTRegisterSetupDetail 
			(
				intRegisterSetupId, 
				-- intImportFileHeaderId, 
				-- strImportFileHeaderName, 
				strFileType, strFilePrefix, 
				strFileNamePattern, 
				strURICommand, 
				strStoredProcedure, 
				intConcurrencyId
			)
			SELECT 
				intRegisterSetupId			= @intRegisterSetupId, 
				-- intImportFileHeaderId		= @intImportFileHeaderId, 
				-- strImportFileHeaderName		= @strImportFileHeader, 
				strFileType					= @strFileType, 
				strFilePrefix				= @strFilePrefix, 
				strFileNamePattern			= @strFileNamePattern, 
				strURICommand				= NULL, 
				strStoredProcedure			= @strStoredProcedure, 
				intConcurrencyId			= 1
		END
		ELSE
		BEGIN
							
			SELECT TOP 1
				@intRegisterSetupDetailId = intRegisterSetupDetailId
			FROM tblSTRegisterSetupDetail
			WHERE intRegisterSetupId = @intRegisterSetupId 
				AND intImportFileHeaderId = @intImportFileHeaderId

			-- UPDATE
			UPDATE tblSTRegisterSetupDetail
			SET 
				-- strImportFileHeaderName		= @strImportFileHeader, 
				strFileType					= @strFileType, 
				strFilePrefix				= @strFilePrefix, 
				strFileNamePattern			= @strFileNamePattern, 
				strURICommand				= NULL, 
				strStoredProcedure			= @strStoredProcedure, 
				intConcurrencyId			= 1
			WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
		END

			-- vrubyrept-plu
			BEGIN
				SET @strImportFileHeader	= N'Commander PLU'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-plu'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutCommanderPLU'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END


			-- vrubyrept-summary
			BEGIN
				SET @strImportFileHeader	= N'Commander Summary'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-summary'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutCommanderSummary'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- vrubyrept-summary
			BEGIN
				SET @strImportFileHeader	= N'Commander Network Card'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-network'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutCommanderNetworkCard'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- vtransset-tlog
			BEGIN
				SET @strImportFileHeader	= N'Commander - Transaction Log Rebate'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vtransset-tlog'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutCommanderTranslog'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- uMaintenance-MixMatch
			BEGIN
				SET @strImportFileHeader	= N'Commander uMaintenance MixMatch'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'uMaintenance-MixMatch'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertMixMatchFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END

			END


			-- uMaintenance-Combo
			BEGIN
				SET @strImportFileHeader	= N'Commander uMaintenance Combo'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'uMaintenance-Combo'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertComboSalesFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- uMaintenance-ItemList
			BEGIN
				SET @strImportFileHeader	= N'Commander uMaintenance Item List'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'uMaintenance-ItemList'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertPromotionItemListSend'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- uPLUs
			BEGIN
				SET @strImportFileHeader	= N'Commander uPLUs'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'uPLUs'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertPricebookSendFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END

			-- vrubyrept-tankMonitor
			BEGIN
				SET @strImportFileHeader	= N'Commander Tank Monitor'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-tankMonitor'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'[to be develop]'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END

			-- vfueltotals
			BEGIN
				SET @strImportFileHeader	= N'Commander Fuel Totals'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vfueltotals'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'[to be develop]'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END

			-- tierProduct
			BEGIN
				SET @strImportFileHeader	= N'Commander Tier Product'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-tierProduct'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'[to be develop]'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END

			-- validate
			BEGIN
				SET @strImportFileHeader	= N'Commander Validate'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'validate'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'[to be develop]'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND strFilePrefix = @strFilePrefix)
									BEGIN
										-- INSERT
										INSERT INTO tblSTRegisterSetupDetail 
										(
											intRegisterSetupId, 
											intImportFileHeaderId, 
											strImportFileHeaderName, 
											strFileType, strFilePrefix, 
											strFileNamePattern, 
											strURICommand, 
											strStoredProcedure, 
											intConcurrencyId
										)
										SELECT 
											intRegisterSetupId			= @intRegisterSetupId, 
											intImportFileHeaderId		= @intImportFileHeaderId, 
											strImportFileHeaderName		= @strImportFileHeader, 
											strFileType					= @strFileType, 
											strFilePrefix				= @strFilePrefix, 
											strFileNamePattern			= @strFileNamePattern, 
											strURICommand				= NULL, 
											strStoredProcedure			= @strStoredProcedure, 
											intConcurrencyId			= 1
									END
								ELSE
									BEGIN
										SELECT TOP 1
											@intRegisterSetupDetailId = intRegisterSetupDetailId
										FROM tblSTRegisterSetupDetail
										WHERE intRegisterSetupId = @intRegisterSetupId 
											AND strFilePrefix = @strFilePrefix

										-- UPDATE										
										UPDATE tblSTRegisterSetupDetail
										SET intImportFileHeaderId		= @intImportFileHeaderId,
											strImportFileHeaderName		= @strImportFileHeader, 
											strFileType					= @strFileType, 
											strFilePrefix				= @strFilePrefix, 
											strFileNamePattern			= @strFileNamePattern, 
											strURICommand				= NULL, 
											strStoredProcedure			= @strStoredProcedure, 
											intConcurrencyId			= 1
										WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
									END
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END

			-- vAppInfo
			BEGIN
				SET @strImportFileHeader	= N'Commander App Info'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vAppInfo'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'[to be develop]'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END

			-- vpopcfg
			BEGIN
				SET @strImportFileHeader	= N'Commander Pop Cfg'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vpopcfg'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'[to be develop]'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END

			-- vrubyrept-tank
			BEGIN
				SET @strImportFileHeader	= N'Commander Tank'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-tank'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'[to be develop]'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END

			-- vrubyrept-loyalty
			BEGIN
				SET @strImportFileHeader	= N'Commander Loyalty'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'vrubyrept-loyalty'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'[to be develop]'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END		
			END
		END
		-- ============================================================================================================
		-- [END] SAPPHIRE/COMMANDER
		-- ============================================================================================================


		
		-- ============================================================================================================
		-- [START] RADIANT
		-- ============================================================================================================
		BEGIN
			-- Version 3.3
			SET @strRegisterClass		= N'RADIANT'
			
			SET @strXmlVersion	= N'3.3'

			-- HEADER
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetup WHERE strRegisterClass = @strRegisterClass AND strXmlVersion = @strXmlVersion)
				BEGIN				
					-- Insert Header
					INSERT INTO tblSTRegisterSetup
					(
						strRegisterClass,
						strXmlVersion,
						intConcurrencyId
					)
					SELECT 
						strRegisterClass			= @strRegisterClass,
						strXmlVersion	= @strXmlVersion,
						intConcurrencyId		= 1


					-- Get New created Id
					SET @intRegisterSetupId = SCOPE_IDENTITY()

				END
			ELSE
				BEGIN

					SELECT TOP 1
						@intRegisterSetupId = intRegisterSetupId
					FROM tblSTRegisterSetup 
					WHERE strRegisterClass = @strRegisterClass 
						AND strXmlVersion = @strXmlVersion

				END


			-- DETAILS	
			--Insert Details
					
			-- MSM 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - MSM'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'MSM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantMSM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- MCM 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - MCM'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'MCM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantMCM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END


			-- ISM 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - ISM'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'ISM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantISM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- FGM 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - FGM'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'FGM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantFGM'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END
			
			-- POS Journal 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - POSJournal'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'POSJournal'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantTranslog'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END

			
			-- Cashier Summary 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - CSH'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'CSH'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantCSH'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END




			-- ITT All version
			BEGIN
				SET @strImportFileHeader	= N'Pricebook File'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'ITT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertPricebookSendFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- ILT All version
			BEGIN
				SET @strImportFileHeader	= N'Promotion Item List'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'ILT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertPromotionItemListSend'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END

			END


			-- CBT All version
			BEGIN
				SET @strImportFileHeader	= N'Pricebook Combo'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'CBT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertComboSalesFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- MMT All version
			BEGIN
				SET @strImportFileHeader	= N'Pricebook Mix Match'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'MMT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertMixMatchFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END
			
			-- MCT All version
			BEGIN
				SET @strImportFileHeader	= N'Department File'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'MCT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertDepartmentSendFile'
						

				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END
			
			SET @strXmlVersion	= N'3.4'

			-- HEADER
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetup WHERE strRegisterClass = @strRegisterClass AND strXmlVersion = @strXmlVersion)
				BEGIN				
					-- Insert Header
					INSERT INTO tblSTRegisterSetup
					(
						strRegisterClass,
						strXmlVersion,
						intConcurrencyId
					)
					SELECT 
						strRegisterClass			= @strRegisterClass,
						strXmlVersion	= @strXmlVersion,
						intConcurrencyId		= 1


					-- Get New created Id
					SET @intRegisterSetupId = SCOPE_IDENTITY()

				END
			ELSE
				BEGIN

					SELECT TOP 1
						@intRegisterSetupId = intRegisterSetupId
					FROM tblSTRegisterSetup 
					WHERE strRegisterClass = @strRegisterClass 
						AND strXmlVersion = @strXmlVersion

				END


			-- DETAILS	
			--Insert Details
					
			-- MSM 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - MSM'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'MSM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantMSM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- MCM 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - MCM'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'MCM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantMCM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END


			-- ISM 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - ISM'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'ISM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantISM'
					
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- FGM 3.3
			BEGIN
				SET @strImportFileHeader	= N'Radiant - FGM'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'FGM'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantFGM'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END
			
			-- POS Journal 3.4
			BEGIN
				SET @strImportFileHeader	= N'Radiant - POSJournal'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'POSJournal'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantTranslog'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END
			
			-- Cashier Summary 3.4
			BEGIN
				SET @strImportFileHeader	= N'Radiant - CSH'
				SET @strFileType			= N'Inbound'
				SET @strFilePrefix			= N'CSH'
				SET @strFileNamePattern		= N'[prefix]+[MMddyyyyHHmmss]'
				SET @strStoredProcedure		= N'uspSTCheckoutRadiantCSH'
				
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
			
			END



			-- ITT All version
			BEGIN
				SET @strImportFileHeader	= N'Pricebook File'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'ITT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertPricebookSendFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- ILT All version
			BEGIN
				SET @strImportFileHeader	= N'Promotion Item List'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'ILT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertPromotionItemListSend'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END

			END


			-- CBT All version
			BEGIN
				SET @strImportFileHeader	= N'Pricebook Combo'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'CBT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertComboSalesFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END


			-- MMT All version
			BEGIN
				SET @strImportFileHeader	= N'Pricebook Mix Match'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'MMT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertMixMatchFile'
						
				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END
			
			-- MCT All version
			BEGIN
				SET @strImportFileHeader	= N'Department File'
				SET @strFileType			= N'Outbound'
				SET @strFilePrefix			= N'MCT'
				SET @strFileNamePattern		= N'[version]+[yyyyMMddHHmmss]'
				SET @strStoredProcedure		= N'uspSTstgInsertDepartmentSendFile'
						

				IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader)
					BEGIN
						-- Get Values
						SELECT TOP 1 
							@intImportFileHeaderId = intImportFileHeaderId
							, @strImportFileHeader = strLayoutTitle
						FROM tblSMImportFileHeader WHERE strLayoutTitle = @strImportFileHeader

						IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegisterSetupDetail WHERE intRegisterSetupId = @intRegisterSetupId AND intImportFileHeaderId = @intImportFileHeaderId)
							BEGIN
								-- INSERT
								INSERT INTO tblSTRegisterSetupDetail 
								(
									intRegisterSetupId, 
									intImportFileHeaderId, 
									strImportFileHeaderName, 
									strFileType, strFilePrefix, 
									strFileNamePattern, 
									strURICommand, 
									strStoredProcedure, 
									intConcurrencyId
								)
								SELECT 
									intRegisterSetupId			= @intRegisterSetupId, 
									intImportFileHeaderId		= @intImportFileHeaderId, 
									strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
							END
						ELSE
							BEGIN
								
								SELECT TOP 1
									@intRegisterSetupDetailId = intRegisterSetupDetailId
								FROM tblSTRegisterSetupDetail
								WHERE intRegisterSetupId = @intRegisterSetupId 
									AND intImportFileHeaderId = @intImportFileHeaderId

								-- UPDATE
								UPDATE tblSTRegisterSetupDetail
								SET strImportFileHeaderName		= @strImportFileHeader, 
									strFileType					= @strFileType, 
									strFilePrefix				= @strFilePrefix, 
									strFileNamePattern			= @strFileNamePattern, 
									strURICommand				= NULL, 
									strStoredProcedure			= @strStoredProcedure, 
									intConcurrencyId			= 1
								WHERE intRegisterSetupDetailId = @intRegisterSetupDetailId
							END
					END
								
			END

		END
		-- ============================================================================================================
		-- [END] RADIANT
		-- ============================================================================================================

		--EXEC('
		--		IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutItemMovements WHERE dblGrossSales IS NULL)
		--			BEGIN
		--				PRINT ''Updating Item Movement Gross sales amount that is = NULL''

		--				UPDATE tblSTCheckoutItemMovements
		--				SET dblGrossSales = (dblCurrentPrice * intQtySold)
		--				WHERE dblGrossSales IS NULL
		--			END
		--	')

		PRINT N'END - Store Register setup entries'
	END
GO

