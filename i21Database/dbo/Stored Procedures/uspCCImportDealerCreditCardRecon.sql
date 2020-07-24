CREATE PROCEDURE [dbo].[uspCCImportDealerCreditCardRecon]
	@guidImportIdentifier UNIQUEIDENTIFIER,
	@ysnAdjustment BIT = 0,
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

		DECLARE @CursorTran AS CURSOR

		IF(@ysnAdjustment = 0)
		BEGIN
			SET @CursorTran = CURSOR FOR
			SELECT DCCD.intImportDealerCreditCardReconDetailId, DCCD.strSiteNumber, DCC.intVendorDefaultId
			FROM tblCCImportDealerCreditCardReconDetail DCCD
			INNER JOIN tblCCImportDealerCreditCardRecon DCC ON DCC.intImportDealerCreditCardReconId = DCCD.intImportDealerCreditCardReconId
			WHERE DCC.guidImportIdentifier = @guidImportIdentifier AND DCCD.ysnValid = 1 AND DCCD.intSubImportFileHeaderId IS NULL
		END
		ELSE
		BEGIN
			SET @CursorTran = CURSOR FOR
			SELECT DCCD.intImportDealerCreditCardReconDetailId, DCCD.strSiteNumber, DCC.intVendorDefaultId
			FROM tblCCImportDealerCreditCardReconDetail DCCD
			INNER JOIN tblCCImportDealerCreditCardRecon DCC ON DCC.intImportDealerCreditCardReconId = DCCD.intImportDealerCreditCardReconId
			WHERE DCC.guidImportIdentifier = @guidImportIdentifier AND DCCD.ysnValid = 1 AND DCCD.intSubImportFileHeaderId IS NOT NULL
		END

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
				IF(@ysnAdjustment = 0)
				BEGIN
					UPDATE tblCCImportDealerCreditCardReconDetail SET intSiteId = @intSiteId WHERE intImportDealerCreditCardReconDetailId = @intImportDealerCreditCardReconDetailId
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblCCImportDealerCreditCardReconDetail WHERE strSiteNumber = @strSiteNumber)
					BEGIN
						DECLARE @dtmAdjProcessDate DATETIME
						SELECT TOP 1 @dtmAdjProcessDate = dtmTransactionDate FROM tblCCImportDealerCreditCardReconDetail 
						WHERE strSiteNumber = @strSiteNumber
						
						UPDATE tblCCImportDealerCreditCardReconDetail SET intSiteId = @intSiteId, dtmTransactionDate = @dtmAdjProcessDate 
						WHERE intImportDealerCreditCardReconDetailId = @intImportDealerCreditCardReconDetailId
					END
					ELSE
					BEGIN
						UPDATE tblCCImportDealerCreditCardReconDetail SET strMessage = 'Invalid Adjustment', ysnValid = 0 WHERE intImportDealerCreditCardReconDetailId = @intImportDealerCreditCardReconDetailId
					END
				END
			END

			FETCH NEXT FROM @CursorTran INTO @intImportDealerCreditCardReconDetailId, @strSiteNumber, @intVendorDefaultId
		END
		CLOSE @CursorTran
		DEALLOCATE @CursorTran

		IF(@ysnAdjustment = 0)
		BEGIN
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
		END

		-- SUM the Batches to get the Gross, Net, Fees - Applicable for Conoco Philips and DCC - Citgo Format only
		IF EXISTS(SELECT TOP 1 1 FROM tblCCImportDealerCreditCardRecon DCC 
		INNER JOIN tblSMImportFileHeader FH ON FH.intImportFileHeaderId = DCC.intImportFileHeaderId
		WHERE DCC.guidImportIdentifier = @guidImportIdentifier 
		AND FH.strLayoutTitle IN ('DCC - Conoco Philips Format', 'DCC - Citgo Format', 'DCC - Marathon Format', 'DCC - Marathon Adjustment Format'))
		BEGIN
			UPDATE D SET D.dblGross = A.dblGross, D.dblNet = A.dblNet, D.dblFee = A.dblFee  
			FROM tblCCImportDealerCreditCardReconDetail D INNER JOIN
				(
				SELECT DCCD.intImportDealerCreditCardReconId, DCCD.intSiteId, DCCD.dtmTransactionDate, SUM(DCCD.dblBatchGross) dblGross, SUM(DCCD.dblBatchNet) dblNet, SUM(DCCD.dblBatchFee) dblFee
				FROM tblCCImportDealerCreditCardReconDetail DCCD
				INNER JOIN tblCCImportDealerCreditCardRecon DCC ON DCC.intImportDealerCreditCardReconId = DCCD.intImportDealerCreditCardReconId
				WHERE DCC.guidImportIdentifier = @guidImportIdentifier 
				GROUP BY DCCD.intImportDealerCreditCardReconId, DCCD.intSiteId, DCCD.dtmTransactionDate
				) A ON A.intImportDealerCreditCardReconId = D.intImportDealerCreditCardReconId
			AND A.intSiteId = D.intSiteId
			AND A.dtmTransactionDate = D.dtmTransactionDate
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
