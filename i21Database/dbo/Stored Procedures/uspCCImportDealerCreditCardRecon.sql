CREATE PROCEDURE [dbo].[uspCCImportDealerCreditCardRecon]
	@guidImportIdentifier UNIQUEIDENTIFIER,
	@return INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	BEGIN TRY

		DECLARE @intImportDealerCreditCardReconId INT,
			@intImportDealerCreditCardReconDetailId AS INT = NULL, 
			@strSiteNumber AS NVARCHAR(100) = NULL,
			@intVendorDefaultId INT = NULL
			--, 
			--@dtmTransactionDate AS DATE = NULL,
			--@dblGross AS NUMERIC(18,6) = NULL,
			--@dblNet AS NUMERIC(18,6) = NULL,
			--@dblFee AS NUMERIC(18,6) = NULL
		
		DECLARE @CursorTran AS CURSOR

		SET @CursorTran = CURSOR FOR
		SELECT DCCD.intImportDealerCreditCardReconDetailId, DCCD.strSiteNumber, DCC.intVendorDefaultId
		FROM tblCCImportDealerCreditCardReconDetail DCCD
		INNER JOIN tblCCImportDealerCreditCardRecon DCC ON DCC.intImportDealerCreditCardReconId = DCCD.intImportDealerCreditCardReconId
		WHERE DCC.guidImportIdentifier = @guidImportIdentifier AND DCCD.ysnValid = 1 

		BEGIN TRANSACTION

		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportDealerCreditCardReconDetailId, @strSiteNumber, @intVendorDefaultId
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			DECLARE @intSiteId INT = NULL
			-- CHECK IF HAS VALID SITE NUMBER
			SELECT @intSiteId = S.intSiteId FROM tblCCSite S
			INNER JOIN tblCCVendorDefault VD ON VD.intVendorDefaultId = S.intVendorDefaultId
			WHERE VD.intVendorDefaultId = @intVendorDefaultId AND S.strSite = @strSiteNumber

			IF (@intSiteId IS NULL)
			BEGIN
				UPDATE tblCCImportDealerCreditCardReconDetail SET strMessage = 'Invalid Site Number', ysnValid = 0 WHERE intImportDealerCreditCardReconDetailId = @intImportDealerCreditCardReconDetailId
			END
			ELSE
			BEGIN
				UPDATE tblCCImportDealerCreditCardReconDetail SET intSiteId = @intSiteId WHERE intImportDealerCreditCardReconDetailId = @intImportDealerCreditCardReconDetailId
			END

			FETCH NEXT FROM @CursorTran INTO @intImportDealerCreditCardReconDetailId, @strSiteNumber, @intVendorDefaultId
		END
		CLOSE @CursorTran
		DEALLOCATE @CursorTran

		-- CHECK IF HAS DIFFERENT TRANSACTION DATE
		IF ((SELECT COUNT(*) FROM (SELECT COUNT(DCCD.dtmTransactionDate) CNT FROM tblCCImportDealerCreditCardReconDetail DCCD INNER JOIN tblCCImportDealerCreditCardRecon DCC ON DCC.intImportDealerCreditCardReconId = DCCD.intImportDealerCreditCardReconId WHERE DCC.guidImportIdentifier = @guidImportIdentifier) A) > 1)
		BEGIN
			UPDATE DCCD SET DCCD.strMessage = ', Has different date with other transaction' FROM tblCCImportDealerCreditCardReconDetail DCCD 
			INNER JOIN tblCCImportDealerCreditCardRecon DCC ON DCC.intImportDealerCreditCardReconId = DCCD.intImportDealerCreditCardReconId 
			WHERE DCC.guidImportIdentifier = @guidImportIdentifier AND DCCD.ysnValid = 0

			UPDATE DCCD SET DCCD.strMessage = 'Has different date with other transaction', DCCD.ysnValid = 0 
			FROM tblCCImportDealerCreditCardReconDetail DCCD 
			INNER JOIN tblCCImportDealerCreditCardRecon DCC ON DCC.intImportDealerCreditCardReconId = DCCD.intImportDealerCreditCardReconId 
			WHERE DCC.guidImportIdentifier = @guidImportIdentifier AND DCCD.ysnValid = 1
		END

		COMMIT

		SELECT @return = intImportDealerCreditCardReconId FROM tblCCImportDealerCreditCardRecon WHERE guidImportIdentifier = @guidImportIdentifier

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
