﻿CREATE PROCEDURE [dbo].[uspTFProcessBeforePreview]
	@Guid NVARCHAR(50)
	, @ReportingComponentId NVARCHAR(50)
	, @DateFrom DATETIME
	, @DateTo DATETIME

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @FormCode NVARCHAR(50)
		, @ScheduleCode NVARCHAR(50)
		, @TransactionType NVARCHAR(50)
		, @TaxAuthorityCode NVARCHAR(50)
		, @RCId INT

	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')
		
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC

		SELECT * 
		INTO #tmpTransaction
		FROM tblTFTransaction	
		WHERE uniqTransactionGuid = @Guid
			AND intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)

		SELECT TOP 1 @FormCode = strFormCode
			, @ScheduleCode = strScheduleCode
			, @TransactionType = strTransactionType
			, @TaxAuthorityCode = tblTFTaxAuthority.strTaxAuthorityCode
		FROM tblTFReportingComponent
		LEFT JOIN tblTFTaxAuthority ON tblTFTaxAuthority.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
		WHERE intReportingComponentId = @RCId


		IF (@FormCode = 'MF-360' OR @FormCode = 'SF-900')
		BEGIN
			IF (@TransactionType = 'Invoice')
			BEGIN
				-- MFT-517 -- Hard Code Terminal Control Number to 'BULK'
				UPDATE tblTFTransaction
				SET strTerminalControlNumber = 'BULK   '
				WHERE intTransactionId IN (SELECT DISTINCT intTransactionId FROM #tmpTransaction)
			END			
		END

		IF (@TaxAuthorityCode = 'MS')
		BEGIN
			UPDATE tblTFTransaction
			SET strOriginTCN = ''
				, strDestinationTCN = ''
			WHERE intTransactionId IN (SELECT DISTINCT intTransactionId FROM #tmpTransaction)
				AND (ISNULL(strOriginTCN, '') <> '' OR ISNULL(strDestinationTCN, '') <> '')
		END

		ELSE IF (@TaxAuthorityCode = 'OR')
		BEGIN
			DELETE FROM tblTFTransactionDynamicOR
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicOR(
				intTransactionId
				, strOriginAltFacilityNumber
				, strDestinationAltFacilityNumber
				, strAltDocumentNumber
				, strExplanation
				, strInvoiceNumber
			)
			SELECT intTransactionId
				, [strOriginAltFacilityNumber] = NULL
				, [strDestinationAltFacilityNumber] = CASE WHEN @FormCode IN ('1', '2', '3') THEN Origin.strOregonFacilityNumber ELSE NULL END
				, [strAltDocumentNumber] = NULL
				, [strExplanation] = NULL
				, [strInvoiceNumber] = NULL
			FROM #tmpTransaction Trans
			LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = Trans.intTransactionNumberId
			LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			LEFT JOIN tblSMCompanyLocation Origin ON Origin.intCompanyLocationId = Receipt.intLocationId
			WHERE Trans.strTransactionType = 'Receipt'

			UNION ALL

			SELECT intTransactionId
				, [strOriginAltFacilityNumber] = CASE WHEN @FormCode IN ('5', '5LO', '6', '7', '5BLK', '5CRD', '6BLK', '6CRD') THEN Origin.strOregonFacilityNumber ELSE NULL END
				, [strDestinationAltFacilityNumber] = CASE WHEN @FormCode IN ('5', '5LO', '6', '7', '5BLK', '5CRD', '6BLK', '6CRD') THEN Destination.strOregonFacilityNumber ELSE NULL END
				, [strAltDocumentNumber] = CASE WHEN Invoice.strTransactionType = 'CF Tran' AND @FormCode IN ('5CRD', '6CRD') THEN CFTran.strCardNumber ELSE NULL END
				, [strExplanation] = CASE WHEN Invoice.strTransactionType = 'CF Tran' AND @FormCode IN ('5CRD', '6CRD') THEN TaxException.strException ELSE NULL END
				, [strInvoiceNumber] = CASE WHEN @FormCode IN ('5CRD', '6CRD') THEN Invoice.strInvoiceNumber ELSE NULL END
			FROM #tmpTransaction Trans
			LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionDetailId
			LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = Invoice.intInvoiceId
			LEFT JOIN tblSMCompanyLocation Origin ON Origin.intCompanyLocationId = Invoice.intLocataionId
			LEFT JOIN tblEMEntityLocation Destination ON Destination.intEntityLocationId = Invoice.intShipToLocationId
			LEFT JOIN vyuCFInvoiceReport CFTran ON CFTran.intInvoiceId = Invoice.intInvoiceId AND CFTran.ysnPosted = 1
			LEFT JOIN tblARCustomerTaxingTaxException TaxException ON TaxException.intEntityCustomerId = Invoice.intEntityCustomerId AND TaxException.intItemId = InvoiceDetail.intItemId
			WHERE Trans.strTransactionType = 'Invoice'
			
			
			
		END

		DELETE FROM #tmpRC WHERE intReportingComponentId = @RCId

		DROP TABLE #tmpTransaction
	END

	DROP TABLE #tmpRC

END TRY
BEGIN CATCH
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
	);
END CATCH