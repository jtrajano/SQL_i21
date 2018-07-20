CREATE PROCEDURE [dbo].[uspTFProcessBeforePreview]
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
			-- CAST(FLOOR(CAST(dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			--AND CAST(FLOOR(CAST(dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)

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
			SELECT Trans.intTransactionId
				, [strOriginAltFacilityNumber] = NULL
				, [strDestinationAltFacilityNumber] = CASE WHEN @ScheduleCode IN ('1', '2', '3') THEN Origin.strOregonFacilityNumber ELSE NULL END
				, [strAltDocumentNumber] = NULL
				, [strExplanation] = NULL
				, [strInvoiceNumber] = NULL
			FROM #tmpTransaction Trans
			LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = Trans.intTransactionNumberId
			LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			LEFT JOIN tblSMCompanyLocation Origin ON Origin.intCompanyLocationId = Receipt.intLocationId
			WHERE Trans.strTransactionType = 'Receipt'

			UNION ALL

			SELECT Trans.intTransactionId
				, [strOriginAltFacilityNumber] = CASE WHEN @ScheduleCode IN ('5', '5LO', '6', '7', '5BLK', '5CRD', '6BLK', '6CRD') THEN Origin.strOregonFacilityNumber ELSE NULL END
				, [strDestinationAltFacilityNumber] = CASE WHEN @ScheduleCode IN ('5', '5LO', '6', '7', '5BLK', '5CRD', '6BLK', '6CRD') THEN Destination.strOregonFacilityNumber ELSE NULL END
				, [strAltDocumentNumber] = CASE WHEN Invoice.strType = 'CF Tran' AND @ScheduleCode IN ('5CRD', '6CRD') THEN CFTran.strCardNumber ELSE NULL END
				, [strExplanation] = CASE WHEN Invoice.strType = 'CF Tran' AND @ScheduleCode IN ('5CRD', '6CRD') THEN TaxException.strExceptionReason ELSE NULL END
				, [strInvoiceNumber] = CASE WHEN @ScheduleCode IN ('5CRD', '6CRD') THEN Invoice.strInvoiceNumber ELSE NULL END
			FROM vyuTFGetTransaction Trans
			LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionNumberId
			LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
			LEFT JOIN tblSMCompanyLocation Origin ON Origin.intCompanyLocationId = Invoice.intCompanyLocationId
			LEFT JOIN tblEMEntityLocation Destination ON Destination.intEntityLocationId = Invoice.intShipToLocationId
			LEFT JOIN vyuCFInvoiceReport CFTran ON CFTran.intInvoiceId = Invoice.intInvoiceId AND CFTran.ysnPosted = 1
			LEFT JOIN tblARCustomerTaxingTaxException TaxException ON TaxException.intEntityCustomerId = Invoice.intEntityCustomerId AND ISNULL(TaxException.intItemId, InvoiceDetail.intItemId) = InvoiceDetail.intItemId AND ISNULL(TaxException.intEntityCustomerLocationId, Invoice.intShipToLocationId) = Invoice.intShipToLocationId
			WHERE Trans.strTransactionType = 'Invoice'
			AND Trans.uniqTransactionGuid = @Guid
			AND Trans.intTransactionId IS NOT NULL
			
		END
		ELSE IF (@TaxAuthorityCode = 'NM' AND @ScheduleCode = 'A')
		BEGIN
			DELETE FROM tblTFTransactionDynamicNM
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicNM(
				intTransactionId
				, strNMCounty
				, strNMLocation
			)
			SELECT Trans.intTransactionId
				, strCounty = ISNULL(TACL.strCounty, '')
				, strLocation = ISNULL(TACL.strLocation, '')
			FROM #tmpTransaction Trans
			LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionNumberId
			LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
			LEFT JOIN vyuTFGetTaxAuthorityCountyLocation TACL ON TACL.intEntityId = Invoice.intEntityCustomerId AND TACL.intEntityLocationId = Invoice.intShipToLocationId
			WHERE Trans.strTransactionType = 'Invoice'
				AND ISNULL(Trans.intProductCodeId, '') != ''
		END

		ELSE IF (@TaxAuthorityCode = 'MI')
		BEGIN
			DELETE FROM tblTFTransactionDynamicMI
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicMI(
				intTransactionId
				, strMIDestinationAddress
				, strMIDestinationCountry
				, strMIDestinationTCN
				, strMIDestinationZipCode
				, strMIOriginAddress
				, strMIOriginCountry
				, strMIOriginZipCode
			)
			SELECT intTransactionId, UnCommonField.*  
			FROM (
				SELECT [strMIDestinationAddress], [strMIDestinationCountry], [strMIDestinationTCN], [strMIDestinationZipCode], [strMIOriginAddress] , [strMIOriginCountry], [strMIOriginZipCode]
				FROM  
				(
					SELECT RCFIELD.strColumn, RCCONFIG.strConfiguration FROM
					tblTFReportingComponentField RCFIELD
					INNER JOIN tblTFReportingComponentConfiguration RCCONFIG ON RCCONFIG.strDescription = RCFIELD.strColumn AND RCCONFIG.intReportingComponentId = RCFIELD.intReportingComponentId
					WHERE RCFIELD.ysnFromConfiguration = 1
					AND RCCONFIG.ysnOutputDesigner = 1
					AND ISNULL(RCCONFIG.strConfiguration, '') <> ''
					AND RCFIELD.intReportingComponentId = @RCId
				) AS SourceTable  
				PIVOT  
				(  
					MAX(strConfiguration)  
					FOR strColumn IN ([strMIDestinationAddress], [strMIDestinationCountry], [strMIDestinationTCN], [strMIDestinationZipCode], [strMIOriginAddress] , [strMIOriginCountry], [strMIOriginZipCode])  
				) AS PvtTbl
			) UnCommonField 
			CROSS JOIN tblTFTransaction

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