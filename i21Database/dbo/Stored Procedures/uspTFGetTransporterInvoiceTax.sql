CREATE PROCEDURE [dbo].[uspTFGetTransporterInvoiceTax]
	@Guid NVARCHAR(50),
	@ReportingComponentId NVARCHAR(MAX),
	@DateFrom DATETIME,
	@DateTo DATETIME,
	@IsEdi BIT,
	@Refresh BIT

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

	DECLARE @tmpInvoiceTransaction TFInvoiceTransaction
	DECLARE @tmpRC TABLE (intReportingComponentId INT)

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
	END

	DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'
		
	INSERT INTO @tmpRC
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE @tmpRC where intReportingComponentId = ''
	
	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpRC)
	BEGIN

		DECLARE @RCId INT = NULL

		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC
			
		--INVENTORY TRANSFER - Track MFT Activity
		INSERT INTO @tmpInvoiceTransaction(intId
			, intInvoiceDetailId
			, intTaxAuthorityId
			, strFormCode
			, intReportingComponentId
			, strScheduleCode
			, strType
			--, intProductCode
			--, strProductCode
			, intItemId
			, dblQtyShipped
			, dblGross
			, dblNet
			, dblBillQty
			, dblTax
			, dblTaxExempt
			, strInvoiceNumber
			, strPONumber
			, strBillOfLading
			, dtmDate
			, strDestinationCity
			, strDestinationCounty
			, strDestinationState
			, strOriginCity
			, strOriginCounty
			, strOriginState
			, strCustomerName
			, strCustomerFEIN
			--, strAccountStatusCode
			, strShipVia
			, strTransporterLicense
			, strTransportationMode
			, strTransporterName
			, strTransporterFEIN
			, strConsignorName
			, strConsignorFEIN
			, strTerminalControlNumber
			, strVendorName
			, strVendorFederalTaxId
			, strHeaderCompanyName
			, strHeaderAddress
			, strHeaderCity
			, strHeaderState
			, strHeaderZip
			, strHeaderPhone
			, strHeaderStateTaxID
			, strHeaderFederalTaxID
			, strTransporterIdType
			, strVendorIdType
			, strCustomerIdType
			, strVendorInvoiceNumber
			, strCustomerLicenseNumber
			, strCustomerAccountStatusCode
			, strCustomerStreetAddress
			, strCustomerZipCode
			, strReportingComponentNote
			, strDiversionNumber
			, strDiversionOriginalDestinationState
			, strTransactionType
			, intTransactionNumberId
			, strContactName)
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intTaxAuthorityId) AS intId, *
		FROM (SELECT DISTINCT NULL AS intInvoiceDetailId
				, tblTFReportingComponent.intTaxAuthorityId
				, tblTFReportingComponent.strFormCode
				, tblTFReportingComponent.intReportingComponentId
				, tblTFReportingComponent.strScheduleCode
				, tblTFReportingComponent.strType
				--, tblTFProductCode.intProductCodeId
				--, tblTFProductCode.strProductCode
				, tblICInventoryTransferDetail.intItemId
				, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
				, tblICInventoryTransferDetail.dblQuantity AS dblGross
				, tblICInventoryTransferDetail.dblQuantity AS dblNet
				, tblICInventoryTransferDetail.dblQuantity
				, NULL AS dblTax
				, NULL AS dblTaxExempt
				, NULL AS strInvoiceNumber
				, NULL AS strPONumber
				, tblTRLoadReceipt.strBillOfLading AS strBOLNumber
				, CASE WHEN tblTRLoadHeader.dtmLoadDateTime IS NULL THEN tblICInventoryTransfer.dtmTransferDate ELSE tblTRLoadHeader.dtmLoadDateTime END AS dtmDate
				, tblSMCompanyLocation.strCity AS strDestinationCity
				, NULL AS strDestinationCounty
				, tblSMCompanyLocation.strStateProvince AS strDestinationState
				, tblEMEntityLocation.strCity AS strOriginCity
				, OriginCounty.strCounty AS strOriginCounty
				, tblEMEntityLocation.strState AS strOriginState
				, tblSMCompanySetup.strCompanyName AS strCustomerName
				, tblSMCompanySetup.strEin AS strCustomerFEIN
				--, NULL AS strAccountStatusCode
				, tblSMShipVia.strShipVia
				, tblSMShipVia.strTransporterLicense
				, tblSMTransportationMode.strCode
				, tblEMEntity.strName AS strTransporterName
				, tblEMEntity.strFederalTaxId AS strTransporterFEIN
				, tblEMEntity.strName AS strConsignorName
				, tblEMEntity.strFederalTaxId AS strConsignorFEIN
				, tblTFTerminalControlNumber.strTerminalControlNumber
				, EntityAPVendor.strName AS strVendorName
				, EntityAPVendor.strFederalTaxId AS strVendorFEIN
				, tblSMCompanySetup.strCompanyName
				, tblSMCompanySetup.strAddress
				, tblSMCompanySetup.strCity
				, tblSMCompanySetup.strState
				, tblSMCompanySetup.strZip
				, tblSMCompanySetup.strPhone
				, tblSMCompanySetup.strStateTaxID
				, tblSMCompanySetup.strEin
				, strTransporterIdType = 'FEIN'
				, strVendorIdType = 'FEIN'
				, strCustomerIdType = 'FEIN'
				, strVendorInvoiceNumber = NULL
				, strCustomerLicenseNumber = NULL
				, strCustomerAccountStatusCode = NULL
				, strCustomerStreetAddress = NULL
				, strCustomerZipCode = NULL
				, strReportingComponentNote = tblTFReportingComponent.strNote
				, strDiversionNumber = NULL
				, strDiversionOriginalDestinationState = NULL
				, strTransactionType = 'Transfer'
				, intTransactionNumberId = tblICInventoryTransferDetail.intInventoryTransferDetailId
				, strContactName = tblSMCompanySetup.strContactName
			FROM tblTFReportingComponent
			INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			INNER JOIN tblICInventoryTransferDetail ON tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId 	
				INNER JOIN tblICItem ON tblICItem.intItemId = tblICInventoryTransferDetail.intItemId
				INNER JOIN tblICCategoryTax ON tblICCategoryTax.intCategoryId = tblICItem.intCategoryId 
					INNER JOIN tblSMTaxClass ON tblSMTaxClass.intTaxClassId = tblICCategoryTax.intTaxClassId
						INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxClassId = tblSMTaxClass.intTaxClassId
			INNER JOIN tblICInventoryTransfer ON tblICInventoryTransfer.intInventoryTransferId = tblICInventoryTransferDetail.intInventoryTransferId
			INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadReceiptId = tblICInventoryTransferDetail.intSourceId
				LEFT JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
				LEFT JOIN tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityId = EntityAPVendor.intEntityId
				LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
				LEFT JOIN tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId
				LEFT JOIN tblSMTaxCode OriginCounty ON OriginCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
				LEFT JOIN tblTFTerminalControlNumber ON  tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
				LEFT JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = tblICInventoryTransfer.intToLocationId
			INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
				LEFT JOIN tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityId 
				LEFT JOIN tblEMEntity ON tblSMShipVia.intEntityId = tblEMEntity.intEntityId 
				LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode	
			LEFT JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				LEFT JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
				LEFT JOIN tblSMTaxCode AS TaxCodeCategory ON TaxCodeCategory.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			CROSS JOIN tblSMCompanySetup
			WHERE tblTFReportingComponent.intReportingComponentId = @RCId
				AND tblSMCompanyLocation.ysnTrackMFTActivity = 1
				AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND tblICInventoryTransfer.ysnPosted = 1
				AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR EntityAPVendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR EntityAPVendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				AND (tblTFReportingComponentCriteria.strCriteria IS NULL 
						OR (tblTFReportingComponentCriteria.strCriteria = '<> 0' AND tblSMTaxCode.intTaxCodeId = TaxCodeCategory.intTaxCodeId) -- FOR TRACK MFT ACTIVITY
						OR (TaxCodeCategory.intTaxCodeId IS NULL AND tblTFReportingComponentCriteria.strCriteria = '= 0') -- FOR NO TAX CODE MAPPED TO MFT CATEGORY
					)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					)
		) tblTransactions
	
		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, intProductCodeId
				, strProductCode
				, intItemId
				, dblQtyShipped
				, dblGross
				, dblNet
				, dblBillQty
				, strInvoiceNumber
				, strPONumber
				, strBillOfLading
				, dtmDate
				, strDestinationCity
				, strDestinationCounty
				, strDestinationState
				, strOriginCity
				, strOriginCounty
				, strOriginState
				, strCustomerName
				, strCustomerFederalTaxId
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFederalTaxId
				, strConsignorName
				, strConsignorFederalTaxId
				, strTaxCode
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strTaxPayerName
				, strTaxPayerAddress
				, strCity
				, strState
				, strZipCode
				, strTelephoneNumber
				, strTaxPayerIdentificationNumber
				, strTaxPayerFEIN
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strContactName)
			SELECT DISTINCT @Guid
				, intReportingComponentId
				, intProductCodeId = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.intProductCodeId 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = Trans.intReportingComponentId and tblICItemMotorFuelTax.intItemId = Trans.intItemId)
				, strProductCode = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.strProductCode 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = Trans.intReportingComponentId and tblICItemMotorFuelTax.intItemId = Trans.intItemId)
				, intItemId
				, CONVERT(DECIMAL(18), dblQtyShipped)
				, CONVERT(DECIMAL(18), dblGross)
				, CONVERT(DECIMAL(18), dblNet)
				, CONVERT(DECIMAL(18), dblBillQty)
				, strInvoiceNumber
				, strPONumber
				, strBillOfLading
				, dtmDate
				, strDestinationCity
				, strDestinationCounty
				, strDestinationState
				, strOriginCity
				, strOriginCounty
				, strOriginState
				, strCustomerName
				, strCustomerFEIN
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFEIN
				, strConsignorName
				, strConsignorFEIN
				, strTaxCode
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, strHeaderFederalTaxID
				, @DateFrom
				, @DateTo
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strContactName
			FROM @tmpInvoiceTransaction Trans
		END
		
		IF(NOT EXISTS (SELECT TOP 1 1 FROM @tmpInvoiceTransaction WHERE intReportingComponentId = @RCId) AND @IsEdi = 0)
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, strProductCode
				, dtmDate
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTransactionType)
			VALUES (@Guid
				, @RCId
				, 'No record found.'
				, GETDATE()
				, @DateFrom
				, @DateTo
				, 'Invoice')
		END

		DELETE FROM @tmpInvoiceTransaction
		DELETE FROM @tmpRC WHERE intReportingComponentId = @RCId

		EXEC uspTFProcessBeforePreview @Guid = @Guid
		, @ReportingComponentId = @ReportingComponentId
		, @DateFrom = @DateFrom
		, @DateTo = @DateTo

	END

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