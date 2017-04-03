GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportBillTransactions')
	DROP PROCEDURE uspAPImportBillTransactions
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
		EXEC ('
		CREATE PROCEDURE [dbo].[uspAPImportBillTransactions]
			@DateFrom	DATE = NULL,
			@DateTo	DATE = NULL,
			@PeriodFrom	INT = NULL,
			@PeriodTo	INT = NULL,
			@UserId INT,
			@Total INT OUTPUT
		AS
		BEGIN

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF

		BEGIN TRY

		DECLARE @totalPostedImport INT;
		DECLARE @transCount INT = @@TRANCOUNT;
		IF @transCount = 0 --if this is greater than 1, someone already created the transaction and WE ARE COVERED BY THE TRANSACTION SO DON''T WORRY
		BEGIN TRANSACTION

		IF(@UserId <= 0)
		BEGIN
			RAISERROR(''You cannot import without user.'', 16, 1);
		END

		--MAKE SURE USER HAS DEFAULT LOCATION
		DECLARE @userLocation INT;
		SELECT @userLocation = A.intCompanyLocationId FROM tblSMCompanyLocation A
				INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
		WHERE intEntityId = @UserId

		IF(@userLocation IS NULL OR @userLocation <= 0)
		BEGIN
			RAISERROR(''Please setup default location on user screen.'', 16, 1);
		END

		--Validate GL Account
		IF (EXISTS(
			SELECT 1 FROM apcbkmst A INNER JOIN aptrxmst B ON A.apcbk_no = B.aptrx_cbk_no WHERE ISNULL(A.apcbk_gl_ap,0) = 0
			UNION ALL
			SELECT 1 FROM apcbkmst A INNER JOIN apivcmst B ON A.apcbk_no = B.apivc_cbk_no WHERE ISNULL(A.apcbk_gl_ap,0) = 0
			)
		)
		BEGIN
			RAISERROR(''Invalid AP Account found in origin table apcbkmst. Please call iRely assistance.'', 16, 1);
		END

		IF EXISTS(SELECT 1 FROM apcbkmst A
		WHERE A.apcbk_gl_ap NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
		UNION ALL
		SELECT 1 FROM apeglmst A
		WHERE A.apegl_gl_acct NOT IN (SELECT strExternalId FROM tblGLCOACrossReference))
		BEGIN
			RAISERROR(''Invalid GL Account found in origin table apeglmst. Please call iRely assistance.'', 16, 1);
		END

		IF @DateFrom IS NULL AND @DateTo IS NULl
		BEGIN
			--VALIDATE BEFORE IMPORTING
			IF NOT EXISTS(SELECT 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Check'')
			BEGIN
				INSERT INTO tblSMPaymentMethod(strPaymentMethod, ysnActive)
				SELECT ''Check'', 1
			END

			--Check if there is check book that was not exists on tblCMBankAccount
			DECLARE @missingCheckBook NVARCHAR(4), @error NVARCHAR(200);
			SELECT TOP 1 @missingCheckBook = A.apchk_cbk_no FROM apchkmst A 
						LEFT JOIN tblCMBankAccount B
							ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
						WHERE B.strCbkNo IS NULL
			IF @missingCheckBook IS NOT NULL
			BEGIN
				SET @error = ''Check book number '' + @missingCheckBook + '' was not imported.''
				RAISERROR(@error, 16, 1);
			END

			--CREATE AP ACCOUNT CATEGORY
			EXEC uspGLUpdateAPAccountCategory

			EXEC uspAPImportBillsFromAPIVCMST @UserId = @UserId, @DateFrom = @DateFrom, @DateTo= @DateTo, @creditCardOnly = 0, @totalImported = @totalPostedImport OUTPUT
			SET @Total = @totalPostedImport;
			EXEC uspAPImportBillsFromAPTRXMST @UserId = @UserId, @DateFrom = @DateFrom, @DateTo= @DateTo, @totalImported = @totalPostedImport OUTPUT
			SET @Total = @Total + @totalPostedImport;
		END
		ELSE
		BEGIN
			EXEC uspAPImportBillsFromAPIVCMST @UserId = @UserId, @DateFrom = @DateFrom, @DateTo = @DateTo, @creditCardOnly = 1, @totalImported = @totalPostedImport OUTPUT
			SET @Total = @totalPostedImport;
			EXEC uspAPImportBillsFromAPTRXMST @UserId = @UserId, @DateFrom = @DateFrom, @DateTo = @DateTo, @totalImported = @totalPostedImport OUTPUT
			SET @Total = @Total + @totalPostedImport;
		END

		IF @transCount = 0 COMMIT TRANSACTION

		END TRY
		BEGIN CATCH
			DECLARE @ErrorSeverity INT,
					@ErrorNumber   INT,
					@ErrorMessage nvarchar(4000),
					@ErrorState INT,
					@ErrorLine  INT,
					@ErrorProc nvarchar(200);
			-- Grab error information from SQL functions
			SET @ErrorSeverity = ERROR_SEVERITY()
			SET @ErrorNumber   = ERROR_NUMBER()
			SET @ErrorMessage  = ERROR_MESSAGE()
			SET @ErrorState    = ERROR_STATE()
			SET @ErrorLine     = ERROR_LINE()
			SET @ErrorMessage  = ''Failed to import bills.'' + CHAR(13) + 
					''SQL Server Error Message is: '' + CAST(@ErrorNumber AS VARCHAR(10)) + 
					'' Line: '' + CAST(@ErrorLine AS VARCHAR(10)) + '' Error text: '' + @ErrorMessage
			IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
			RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
		END CATCH

		END
	')
END