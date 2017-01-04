﻿CREATE PROCEDURE [dbo].[uspPATPostTransferInstruments]
	@intTransferId INT = NULL,
	@ysnPosted BIT = NULL,
	@intUserId INT = NULL,
	@batchIdUsed NVARCHAR(40) = NULL OUTPUT,
	@successfulCount INT = 0 OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT 
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--DECLARE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Transfer Instruments'
DECLARE @totalRecords INT
DECLARE @GLEntries AS RecapTableType 
DECLARE @error NVARCHAR(200)
DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @batchId NVARCHAR(40);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

	SELECT	T.intTransferId,
			TD.intTransferDetailId,
			T.intTransferType,
			TD.intTransferorId,
			TD.strEquityType,
			TD.intFiscalYearId,
			TD.intPatronageCategoryId,
			TD.intRefundTypeId,
			TD.intCustomerStockId,
			TD.dblParValue,
			TD.dblQuantityAvailable,
			TD.intTransfereeId,
			TD.intToFiscalYearId,
			TD.intToRefundTypeId,
			TD.intToStockId,
			TD.dblTransferPercentage,
			TD.strToCertificateNo,
			TD.dtmToIssueDate,
			TD.strToStockStatus,
			TD.dblToParValue,
			TD.dblQuantityTransferred
	INTO #tempTransferDetails
	FROM tblPATTransfer T
	INNER JOIN tblPATTransferDetail TD
		ON TD.intTransferId = T.intTransferId
	WHERE T.intTransferId = @intTransferId

	SELECT @totalRecords = COUNT(*) FROM #tempTransferDetails

	BEGIN TRANSACTION
	---------------- BEGIN - GET GL ENTRIES ----------------
	IF(@ysnPosted = 1)
	BEGIN
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATCreateTransferInstrumentsGLEntries](@intTransferId, @batchId, @intUserId)
	END
	ELSE
	BEGIN
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATReverseTransferInstrumentsGLEntries](@intTransferId, @dateToday, @batchId, @intUserId)

		
		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intTransferId 
		AND strModuleName = @MODULE_NAME AND strTransactionForm = @SCREEN_NAME
	END
	---------------- END - GET GL ENTRIES ----------------

	---------------- BEGIN - BOOK GL ----------------
	BEGIN TRY
		SELECT * FROM @GLEntries
		EXEC uspGLBookEntries @GLEntries, @ysnPosted
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END CATCH
	---------------- END - BOOK GL ----------------

	---------------- BEGIN - UPDATE TABLES ----------------
	UPDATE tblPATTransfer SET ysnPosted = @ysnPosted
	WHERE intTransferId = @intTransferId

	IF EXISTS(SELECT 1 FROM #tempTransferDetails WHERE intTransferType = 2)
	BEGIN
		---------------------------- TRANSFER STOCK TO EQUITY -----------------------------
		MERGE tblPATCustomerEquity AS CE-- WHERE ysnEquityPaid = 0 AND strEquityType = 'Undistributed') AS CE
		USING (SELECT * FROM #tempTransferDetails WHERE intTransferType = 2) TD
			ON (TD.intToFiscalYearId = CE.intFiscalYearId AND TD.intTransferorId = CE.intCustomerId AND TD.intToRefundTypeId = CE.intRefundTypeId AND CE.ysnEquityPaid = 0 AND CE.strEquityType = 'Undistributed')
			WHEN MATCHED
				THEN UPDATE SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity + TD.dblQuantityTransferred ELSE CE.dblEquity - TD.dblQuantityTransferred END
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, ysnEquityPaid, intConcurrencyId)
				VALUES(TD.intTransferorId, TD.intToFiscalYearId, 'Undistributed', TD.intToRefundTypeId, TD.dblQuantityTransferred, 0, 1);

		UPDATE CS
		SET CS.dblSharesNo = CASE WHEN @ysnPosted = 1 THEN CS.dblSharesNo - tempTD.dblQuantityTransferred ELSE CS.dblSharesNo + tempTD.dblQuantityTransferred END,
			CS.strActivityStatus = CASE WHEN @ysnPosted = 1 THEN 'Xferred' ELSE 'Open' END,
			CS.dtmTransferredDate = GETDATE()
		FROM tblPATCustomerStock AS CS 
		INNER JOIN #tempTransferDetails AS tempTD
			ON CS.intCustomerPatronId = tempTD.intTransferorId AND CS.intStockId = tempTD.intCustomerStockId
		WHERE CS.strActivityStatus = 'Open' AND CS.ysnPosted <> 1

	END

	IF EXISTS(SELECT 1 FROM #tempTransferDetails WHERE intTransferType = 4)
	BEGIN
		---------------------  TRANSFER EQUITY TO STOCK ---------------------------------
		IF(@ysnPosted = 1)
		BEGIN
			INSERT INTO tblPATCustomerStock(intCustomerPatronId, intStockId, strCertificateNo, strStockStatus, dblSharesNo, dtmIssueDate, strActivityStatus, dblParValue, dblFaceValue, ysnPosted, intConcurrencyId)
			SELECT intTransferorId, intToStockId, strToCertificateNo, strToStockStatus, dblQuantityTransferred, dtmToIssueDate, 'Open', dblToParValue, (dblQuantityTransferred * dblToParValue), 0, 0
			FROM #tempTransferDetails WHERE intTransferType = 4;
		END
		ELSE
		BEGIN
			DELETE FROM tblPATCustomerStock WHERE strCertificateNo IN (SELECT strToCertificateNo FROM #tempTransferDetails where intTransferType = 4)
		END

		UPDATE CE
		SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity - tempTD.dblQuantityTransferred ELSE CE.dblEquity + tempTD.dblQuantityTransferred END
		FROM tblPATCustomerEquity CE
		INNER JOIN #tempTransferDetails AS tempTD
			ON CE.intCustomerId = tempTD.intTransferorId AND CE.intFiscalYearId = tempTD.intFiscalYearId AND CE.intRefundTypeId = tempTD.intRefundTypeId AND CE.ysnEquityPaid <> 1 AND tempTD.intTransferType = 4;
	END

	IF ExISTS(SELECT 1 FROM #tempTransferDetails WHERE intTransferType = 5)
	BEGIN
		---------------------  TRANSFER EQUITY TO EQUITY RESERVE ---------------------------------

		MERGE tblPATCustomerEquity CE
		USING (SELECT * FROM #tempTransferDetails WHERE intTransferType = 5) TD
			ON (TD.intFiscalYearId = CE.intFiscalYearId AND CE.intCustomerId = TD.intTransferorId AND CE.ysnEquityPaid <> 1 AND CE.strEquityType = 'Reserve')
			WHEN MATCHED
				THEN UPDATE SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity + TD.dblQuantityTransferred ELSE CE.dblEquity - TD.dblQuantityTransferred END
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, ysnEquityPaid, intConcurrencyId)
				VALUES (TD.intTransferorId, TD.intFiscalYearId, 'Reserve', TD.intRefundTypeId, TD.dblQuantityTransferred, 0, 1);

		UPDATE CE
		SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity - tempTD.dblQuantityTransferred ELSE CE.dblEquity + tempTD.dblQuantityTransferred END
		FROM tblPATCustomerEquity AS CE
		INNER JOIN #tempTransferDetails AS tempTD
			ON CE.intCustomerId = tempTD.intTransferorId AND CE.intFiscalYearId = tempTD.intFiscalYearId AND CE.intRefundTypeId = tempTD.intRefundTypeId AND CE.strEquityType = 'Undistributed' AND tempTD.intTransferType = 5
	END

	IF ExISTS(SELECT 1 FROM #tempTransferDetails WHERE intTransferType = 6)
	BEGIN
		---------------------  TRANSFER EQUITY RESERVE TO EQUITY ---------------------------------

		MERGE tblPATCustomerEquity CE
		USING (SELECT * FROM #tempTransferDetails WHERE intTransferType = 6) TD
			ON (TD.intToFiscalYearId = CE.intFiscalYearId AND CE.intCustomerId = TD.intTransferorId AND CE.intRefundTypeId = TD.intToRefundTypeId AND CE.ysnEquityPaid <> 1 AND CE.strEquityType = 'Undistributed')
			WHEN MATCHED
				THEN UPDATE SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity + TD.dblQuantityTransferred ELSE CE.dblEquity - TD.dblQuantityTransferred END
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, ysnEquityPaid, intConcurrencyId)
				VALUES (TD.intTransferorId, TD.intToFiscalYearId, 'Undistributed', TD.intToRefundTypeId, TD.dblQuantityTransferred, 0, 1);

		UPDATE CE
		SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity - tempTD.dblQuantityTransferred ELSE CE.dblEquity + tempTD.dblQuantityTransferred END
		FROM tblPATCustomerEquity AS CE
		INNER JOIN #tempTransferDetails AS tempTD
			ON CE.intCustomerId = tempTD.intTransferorId AND CE.intFiscalYearId = tempTD.intFiscalYearId AND CE.intRefundTypeId = tempTD.intRefundTypeId AND CE.strEquityType = 'Reserve' AND tempTD.intTransferType = 6
			
	END
	---------------- END - UPDATE TABLES ----------------
	
---------------------------------------------------------------------------------------------------------------------------------------
IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempTransferDetails')) DROP TABLE #tempTransferDetails
END