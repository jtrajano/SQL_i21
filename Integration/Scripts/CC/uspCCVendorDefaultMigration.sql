IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCCVendorDefaultMigration]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspCCVendorDefaultMigration]
GO

CREATE PROCEDURE [dbo].[uspCCVendorDefaultMigration]
	@intUserId INT,
	@strSource NVARCHAR(100)
AS
BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	BEGIN TRY

		--RETURN FLAG
		--		-1 - Already Imported
		--		-2 - On Progress
		--		1 - Successful

		DECLARE @strImportType NVARCHAR(50) = 'CCR VENDOR DEFAULT'

		-- CHECK IF ALREADY IMPORTED
		IF EXISTS(SELECT TOP 1 1 FROM tblCCImportStatus WHERE strImportType = @strImportType AND ysnActive = 1)
		BEGIN
			RETURN -1
		END

		-- CHECK IF CURRENTLY RUNNING
		IF EXISTS(SELECT TOP 1 1 FROM tblCCImportStatus WHERE strImportType = @strImportType AND ysnOnProcess = 1)
		BEGIN
			RETURN -2
		END

		BEGIN TRANSACTION
	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblCCImportStatus WHERE strImportType = @strImportType)
		BEGIN
			INSERT INTO [dbo].[tblCCImportStatus]
			   ([strImportType]
			   ,[strDescription]
			   ,[strSource]
			   ,[dtmImportDate]
			   ,[intUserId]
			   ,[ysnOnProcess])
		 VALUES
			   (@strImportType
			   ,'CCR VENDOR DEFAULT INFORMATION - VENDOR SCREEN - CREDIT CARD RECON'
			   ,@strSource
			   ,GETDATE()
			   ,@intUserId
			   ,1)
		END
		ELSE
		BEGIN
			UPDATE [dbo].[tblCCImportStatus] SET [dtmImportDate] = GETDATE(), ysnOnProcess = 1 WHERE [strImportType] = @strImportType
		END

		DECLARE @intVendorId AS INT = NULL, 
			@intBankAccountId AS INT = NULL, 
			@intCompanyLocationId AS INT = NULL, 
			@strApType AS NVARCHAR(100) = NULL, 
			@strEnterTotalsAsGrossOrNet AS NVARCHAR(100) = NULL, 
			@strFileType AS NVARCHAR(100) = NULL,	 
			@strImportFileName AS NVARCHAR(100) = NULL,
			@strImportFilePath NVARCHAR(250) = NULL,
			@strImportAuxiliaryFileName  AS NVARCHAR(100) = NULL
	 
		DECLARE @CursorTran AS CURSOR

		SET @CursorTran = CURSOR FOR
		SELECT VENDOR.intEntityId intVendorId,
			BA.intBankAccountId intBankAccountId,
			CL.intCompanyLocationId intCompanyLocationId,
			CRV.apcrv_ap_type strApType,
			CRV.apcrv_enter_totals_gn strEnterTotalsAsGrossOrNet, 
			CRV.apcrv_import_type strFileType,
			CRV.apcrv_import_name strImportFileName,
			CRV.apcrv_import_path strImportFilePath,
			CRV.apcrv_aux_import_name strImportAuxiliaryFileName 
		FROM apcrvmst CRV
		INNER JOIN tblAPVendor VENDOR ON VENDOR.strVendorId = CRV.apcrv_vnd_no COLLATE Latin1_General_CI_AS
		LEFT JOIN tblCMBankAccount BA ON BA.strCbkNo COLLATE Latin1_General_CI_AS = CRV.apcrv_cbk_no
		LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationNumber COLLATE Latin1_General_CI_AS = CRV.apcrv_loc_no
	
		OPEN @CursorTran

		FETCH NEXT FROM @CursorTran INTO @intVendorId, @intBankAccountId, @intCompanyLocationId, @strApType, @strEnterTotalsAsGrossOrNet, @strFileType, @strImportFileName, @strImportFilePath, @strImportAuxiliaryFileName
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @intVendorDefaultId INT = NULL
	
			SELECT @intVendorDefaultId = intVendorDefaultId FROM tblCCVendorDefault WHERE intVendorId = @intVendorId 
	
			IF(@intVendorDefaultId IS NULL)
			BEGIN
				INSERT INTO tblCCVendorDefault (intVendorId
					,intBankAccountId
					,intCompanyLocationId
					,strApType 
					,strEnterTotalsAsGrossOrNet
					,strFileType
					,strImportFileName
					,strImportFilePath
					,strImportAuxiliaryFileName
					,intConcurrencyId) 
				VALUES (@intVendorId
					,@intBankAccountId
					,@intCompanyLocationId
					,CASE WHEN @strApType = 'D' THEN 'Cash Deposited' WHEN @strApType = 'C' THEN 'Credit On Account' ELSE '' END
					,CASE WHEN @strEnterTotalsAsGrossOrNet = 'G' THEN 'Gross' WHEN @strEnterTotalsAsGrossOrNet = 'N' THEN 'Net' END
					,ISNULL(@strFileType, '')
					,@strImportFileName
					,@strImportFilePath
					,@strImportAuxiliaryFileName
					,1)
			END
			ELSE
			BEGIN
				UPDATE tblCCVendorDefault SET intVendorId = @intVendorId
					,intBankAccountId = @intBankAccountId
					,intCompanyLocationId = @intCompanyLocationId
					,strApType = CASE WHEN @strApType = 'D' THEN 'Cash Deposited' WHEN @strApType = 'C' THEN 'Credit On Account' ELSE '' END
					,strEnterTotalsAsGrossOrNet = CASE WHEN @strEnterTotalsAsGrossOrNet = 'G' THEN 'Gross' WHEN @strEnterTotalsAsGrossOrNet = 'N' THEN 'Net' END
					,strFileType = ISNULL(@strFileType, '')
					,strImportFileName = @strImportFileName
					,strImportFilePath = @strImportFilePath
					,strImportAuxiliaryFileName = @strImportAuxiliaryFileName
				WHERE intVendorDefaultId = @intVendorDefaultId
			END

			FETCH NEXT FROM @CursorTran INTO @intVendorId, @intBankAccountId, @intCompanyLocationId, @strApType, @strEnterTotalsAsGrossOrNet, @strFileType, @strImportFileName, @strImportFilePath, @strImportAuxiliaryFileName
		END
		CLOSE @CursorTran
		DEALLOCATE @CursorTran

		UPDATE [dbo].[tblCCImportStatus] SET ysnOnProcess = 0, ysnActive = 1 WHERE [strImportType] = @strImportType

		COMMIT

		RETURN 1

	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		)
	END CATCH
END
GO