CREATE PROCEDURE [dbo].[uspTFGetInventoryTax]
	@Guid NVARCHAR(50)
	, @ReportingComponentId NVARCHAR(MAX)
	, @DateFrom DATETIME
	, @DateTo DATETIME
	, @IsEdi BIT
	, @Refresh BIT

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

	DECLARE @tmpTransaction TFCommonTransaction
	DECLARE @tmpDetailTax TFCommonDetailTax
	DECLARE @tmpDetailTaxGrouped TABLE (intTransactionDetailId INT
		, strCriteria NVARCHAR(20)
		, dblTax DECIMAL(18, 6)
	)
	DECLARE @tmpRC TABLE (intReportingComponentId INT)

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction
	END
	
	INSERT INTO @tmpRC
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE @tmpRC where intReportingComponentId = ''

	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpRC)
	BEGIN

		DECLARE @RCId INT = NULL

		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC

		IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId)
		BEGIN
			INSERT INTO @tmpTransaction(intId
				, intTransactionDetailId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intItemId
				, strBillOfLading
				, dblReceived
				, dblGross
				, dblNet
				, dblBillQty
				, dtmDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFederalTaxId
				, strTransporterFederalTaxId
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxId
				, strHeaderFederalTaxId
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, strTerminalControlNumber
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strCustomerName
				, strCustomerFederalTaxId
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, strContactName
				, strEmail
				, strImportVerificationNumber
				, strConsignorName
				, strConsignorFederalTaxId)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId, *
			FROM (SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, strType = tblTFReportingComponent.strType
					, tblICInventoryReceiptItem.intItemId
					, tblICInventoryReceipt.strBillOfLading
					, tblICInventoryReceiptItem.dblOpenReceive
					, tblICInventoryReceiptItem.dblGross
					, tblICInventoryReceiptItem.dblNet
					, tblICInventoryReceiptItem.dblBillQty
					, tblICInventoryReceipt.dtmReceiptDate
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, Vendor.strName AS strVendorName
					, Transporter.strName AS strTransporterName
					, Vendor.strFederalTaxId AS strVendorFederalTaxId
					, Transporter.strFederalTaxId AS strTransporterFederalTaxId
					, tblTFCompanyPreference.strCompanyName
					, tblTFCompanyPreference.strTaxAddress
					, tblTFCompanyPreference.strCity
					, tblTFCompanyPreference.strState
					, tblTFCompanyPreference.strZipCode
					, tblTFCompanyPreference.strContactPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxId = tblSMCompanySetup.strEin
					, tblEMEntityLocation.strState AS strOriginState
					, tblEMEntityLocation.strCity AS strOriginCity
					, OriginCountyTaxCode.strCounty AS strOriginCounty
					, tblSMCompanyLocation.strStateProvince strDestinationState
					, tblSMCompanyLocation.strCity strDestinationCity	
					, NULL AS strDestinationCounty
					, tblTFTerminalControlNumber.strTerminalControlNumber
					, strTransporterIdType = 'FEIN'
					, strVendorIdType = 'FEIN'
					, strCustomerIdType = 'FEIN'
					, strVendorInvoiceNumber = APBill.strVendorOrderNumber
					, strCustomerLicenseNumber = NULL
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, tblSMCompanySetup.strCompanyName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFederalTaxId
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
					, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
					, strTransactionType = 'Receipt'
					, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
					, strImportVerificationNumber = tblTRLoadHeader.strImportVerificationNumber
					, Seller.str1099Name
					, Seller.strFederalTaxId
				FROM tblTFReportingComponent 
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFProductCode.intProductCodeId		
				INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId =  tblICItemMotorFuelTax.intItemId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
					INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
					INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
					LEFT JOIN tblSMTaxCode AS OriginCountyTaxCode ON OriginCountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblICInventoryReceipt.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId 
						LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
					LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId 
						LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
				LEFT JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId AND tblTRLoadReceipt.intItemId = tblICInventoryReceiptItem.intItemId
				LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
					LEFT JOIN tblEMEntity AS Seller ON Seller.intEntityId = tblTRLoadHeader.intSellerId
				LEFT JOIN (
					SELECT DISTINCT tblAPBillDetail.intInventoryReceiptItemId, tblAPBillDetail.intItemId, tblAPBill.strVendorOrderNumber
					FROM tblAPBillDetail 
					INNER JOIN tblAPBill ON tblAPBillDetail.intBillId = tblAPBill.intBillId
				) APBill ON APBill.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId AND APBill.intItemId = tblICInventoryReceiptItem.intItemId
				--LEFT JOIN (
				--	SELECT  
				--		tblTRLoadDistributionDetail.intLoadDistributionDetailId,
				--		CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.intItemId ELSE  vyuTRGetLoadBlendIngredient.intIngredientItemId END intItemId,
				--		tblTRLoadDistributionHeader.intLoadHeaderId, 
				--		tblTRLoadDistributionHeader.intCompanyLocationId, 
				--		tblTRLoadDistributionHeader.intLoadDistributionHeaderId,
				--		tblTRLoadDistributionHeader.intShipToLocationId,
				--		tblTRLoadDistributionHeader.intEntityCustomerId,
				--		tblTRLoadDistributionHeader.strDestination,
				--		CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.strReceiptLink ELSE  vyuTRGetLoadBlendIngredient.strReceiptLink END strReceiptLink,
				--		CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.dblUnits ELSE  vyuTRGetLoadBlendIngredient.dblQuantity END dblUnits
				--	 FROM tblTRLoadDistributionDetail INNER JOIN tblTRLoadDistributionHeader 
				--	 ON tblTRLoadDistributionDetail.intLoadDistributionHeaderId = tblTRLoadDistributionHeader.intLoadDistributionHeaderId
				--	 LEFT JOIN vyuTRGetLoadBlendIngredient ON vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId = tblTRLoadDistributionDetail.intLoadDistributionDetailId
				--) DistributionDetail ON DistributionDetail.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND DistributionDetail.intItemId = tblTRLoadReceipt.intItemId AND DistributionDetail.strReceiptLink = tblTRLoadReceipt.strReceiptLine
				--	LEFT JOIN tblSMCompanyLocation BulkLocation ON BulkLocation.intCompanyLocationId = tblICInventoryReceipt.intLocationId
				--	LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = DistributionDetail.intShipToLocationId
				--LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = DistributionDetail.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
				LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE  tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblICInventoryReceipt.ysnPosted = 1
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR (tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR (tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					--	OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					--	OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					--	OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					--))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					--    OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					--    OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					--    OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					--))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR ISNULL(Vendor.intEntityId, 0) NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					--AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					--AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Transporter.intEntityId IN (SELECT intEntityId FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Transporter.intEntityId NOT IN (SELECT intEntityId FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 0))	
				) tblTFTransaction
		END
		ELSE
		BEGIN
			INSERT INTO @tmpTransaction(intId
				, intTransactionDetailId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intItemId
				, strBillOfLading
				, dblReceived
				, dblGross
				, dblNet
				, dblBillQty
				, dtmDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFederalTaxId
				, strTransporterFederalTaxId
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxId
				, strHeaderFederalTaxId
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, strTerminalControlNumber
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strCustomerName
				, strCustomerFederalTaxId
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, strContactName
				, strEmail
				, strImportVerificationNumber
				, strConsignorName
				, strConsignorFederalTaxId)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId, *
			FROM (SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, strType = tblTFReportingComponent.strType
					, tblICInventoryReceiptItem.intItemId
					, tblICInventoryReceipt.strBillOfLading
					, tblICInventoryReceiptItem.dblOpenReceive
					, tblICInventoryReceiptItem.dblGross
					, tblICInventoryReceiptItem.dblNet
					, tblICInventoryReceiptItem.dblBillQty
					, tblICInventoryReceipt.dtmReceiptDate
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode	
					, Vendor.strName AS strVendorName
					, Transporter.strName AS strTransporterName
					, Vendor.strFederalTaxId AS strVendorFederalTaxId
					, Transporter.strFederalTaxId AS strTransporterFederalTaxId
					, tblTFCompanyPreference.strCompanyName
					, tblTFCompanyPreference.strTaxAddress
					, tblTFCompanyPreference.strCity
					, tblTFCompanyPreference.strState
					, tblTFCompanyPreference.strZipCode
					, tblTFCompanyPreference.strContactPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxId = tblSMCompanySetup.strEin
					, tblEMEntityLocation.strState AS strOriginState
					, tblEMEntityLocation.strCity AS strOriginCity
					, OriginCountyTaxCode.strCounty AS strOriginCounty
					, tblSMCompanyLocation.strStateProvince strDestinationState
					, tblSMCompanyLocation.strCity strDestinationCity
					, NULL AS strDestinationCounty
					, tblTFTerminalControlNumber.strTerminalControlNumber
					, strTransporterIdType = 'FEIN'
					, strVendorIdType = 'FEIN'
					, strCustomerIdType = 'FEIN'
					, strVendorInvoiceNumber = APBill.strVendorOrderNumber
					, strCustomerLicenseNumber = NULL
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, tblSMCompanySetup.strCompanyName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFederalTaxId
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
					, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
					, strTransactionType = 'Receipt'
					, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
					, strImportVerificationNumber = tblTRLoadHeader.strImportVerificationNumber
					, Seller.str1099Name
					, Seller.strFederalTaxId
				FROM tblTFReportingComponent 
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFProductCode.intProductCodeId
				INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId =  tblICItemMotorFuelTax.intItemId
				INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
					INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
					INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
					LEFT JOIN tblSMTaxCode AS OriginCountyTaxCode ON OriginCountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblICInventoryReceipt.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId 
						LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
					LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId 
						LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
				LEFT JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId AND tblTRLoadReceipt.intItemId = tblICInventoryReceiptItem.intItemId
				LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
					LEFT JOIN tblEMEntity AS Seller ON Seller.intEntityId = tblTRLoadHeader.intSellerId
				LEFT JOIN (
					SELECT DISTINCT tblAPBillDetail.intInventoryReceiptItemId, tblAPBillDetail.intItemId, tblAPBill.strVendorOrderNumber
					FROM tblAPBillDetail 
					INNER JOIN tblAPBill ON tblAPBillDetail.intBillId = tblAPBill.intBillId
				) APBill ON APBill.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId AND APBill.intItemId = tblICInventoryReceiptItem.intItemId
				--LEFT JOIN (
				--	SELECT  
				--		tblTRLoadDistributionDetail.intLoadDistributionDetailId,
				--		CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.intItemId ELSE  vyuTRGetLoadBlendIngredient.intIngredientItemId END intItemId,
				--		tblTRLoadDistributionHeader.intLoadHeaderId, 
				--		tblTRLoadDistributionHeader.intCompanyLocationId, 
				--		tblTRLoadDistributionHeader.intLoadDistributionHeaderId,
				--		tblTRLoadDistributionHeader.intShipToLocationId,
				--		tblTRLoadDistributionHeader.intEntityCustomerId,
				--		tblTRLoadDistributionHeader.strDestination,
				--		CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.strReceiptLink ELSE  vyuTRGetLoadBlendIngredient.strReceiptLink END strReceiptLink,
				--		CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.dblUnits ELSE  vyuTRGetLoadBlendIngredient.dblQuantity END dblUnits
				--	 FROM tblTRLoadDistributionDetail INNER JOIN tblTRLoadDistributionHeader 
				--	 ON tblTRLoadDistributionDetail.intLoadDistributionHeaderId = tblTRLoadDistributionHeader.intLoadDistributionHeaderId
				--	 LEFT JOIN vyuTRGetLoadBlendIngredient ON vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId = tblTRLoadDistributionDetail.intLoadDistributionDetailId
				--) DistributionDetail ON DistributionDetail.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND DistributionDetail.intItemId = tblTRLoadReceipt.intItemId AND DistributionDetail.strReceiptLink = tblTRLoadReceipt.strReceiptLine
				--	LEFT JOIN tblSMCompanyLocation BulkLocation ON BulkLocation.intCompanyLocationId = DistributionDetail.intCompanyLocationId
				--	LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = DistributionDetail.intShipToLocationId
				--LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = DistributionDetail.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
				LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE  tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblICInventoryReceipt.ysnPosted = 1
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR (tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR (tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					--	OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					--	OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					--	OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					--))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					--    OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					--	OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					--	OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					--))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR ISNULL(Vendor.intEntityId, 0) NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					--AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					--AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Transporter.intEntityId IN (SELECT intEntityId FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Transporter.intEntityId NOT IN (SELECT intEntityId FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 0))	
				) tblTFTransaction
		END

		-- TAX CRITERIA
		IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId))
		BEGIN

			-- TRANSACTION WITHOUT TAX CODE
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))
			BEGIN	
				DELETE @tmpTransaction WHERE intTransactionDetailId IN (
					SELECT DISTINCT InventoryTran.intTransactionDetailId 
					FROM @tmpTransaction InventoryTran
					LEFT JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = InventoryTran.intTransactionDetailId
					WHERE tblICInventoryReceiptItemTax.intTaxCodeId IS NULL	
				)
			END

			-- TRANSACTION WITH TAX CODE
			INSERT INTO @tmpDetailTax (intTransactionDetailId, intTaxCodeId, strCriteria, dblTax)
			SELECT InventoryTran.intTransactionDetailId, tblICInventoryReceiptItemTax.intTaxCodeId, tblTFReportingComponentCriteria.strCriteria, tblICInventoryReceiptItemTax.dblTax
			FROM @tmpTransaction InventoryTran
				INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = InventoryTran.intTransactionDetailId
				INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
				INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
			WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId

			INSERT INTO @tmpDetailTaxGrouped (intTransactionDetailId, strCriteria, dblTax)
			SELECT InventoryTran.intTransactionDetailId, tblTFReportingComponentCriteria.strCriteria, SUM(tblICInventoryReceiptItemTax.dblTax)
			FROM @tmpTransaction InventoryTran
				INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = InventoryTran.intTransactionDetailId
				INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
				INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
			WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId
			GROUP BY InventoryTran.intTransactionDetailId, tblTFReportingComponentCriteria.strCriteria 

			WHILE EXISTS(SELECT TOP 1 1 FROM @tmpDetailTax)
			BEGIN		
				DECLARE @InventoryDetailId INT = NULL, @intTaxCodeId INT = NULL, @strCriteria NVARCHAR(100) = NULL,  @dblTax NUMERIC(18,8) = NULL

				SELECT TOP 1 @InventoryDetailId = intTransactionDetailId, @intTaxCodeId = intTaxCodeId, @strCriteria = strCriteria, @dblTax = dblTax FROM @tmpDetailTax

				IF(@strCriteria = '<> 0' AND @dblTax = 0)	
				BEGIN
					IF((SELECT dblTax FROM @tmpDetailTaxGrouped WHERE intTransactionDetailId = @InventoryDetailId ) = 0)  
					BEGIN  
						DELETE FROM @tmpTransaction WHERE intTransactionDetailId = @InventoryDetailId 
					END       										 
				END
				ELSE IF (@strCriteria = '= 0' AND @dblTax > 0)
				BEGIN
				IF((SELECT dblTax FROM @tmpDetailTaxGrouped WHERE intTransactionDetailId = @InventoryDetailId ) > 0)  
					BEGIN  
						DELETE FROM @tmpTransaction WHERE intTransactionDetailId = @InventoryDetailId	
					END    								 
				END

				DELETE @tmpDetailTax WHERE intTransactionDetailId = @InventoryDetailId AND intTaxCodeId = @intTaxCodeId
			END

		   DELETE @tmpDetailTax  

			-- TRANSACTION NOT MAPPED ON MFT TAX CATEGORY
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))
			BEGIN 	
				DELETE @tmpTransaction WHERE intTransactionDetailId NOT IN (
					SELECT DISTINCT InventoryTran.intTransactionDetailId
					FROM @tmpTransaction InventoryTran
						INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = InventoryTran.intTransactionDetailId 
						INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
						INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
						INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
						WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId AND ISNULL(tblICInventoryReceiptItemTax.dblTax, 0) <> 0
					)
			END

		END
			
		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intItemId
				, intReportingComponentId
				, intProductCodeId
				, strProductCode
				, strBillOfLading
				, dblReceived
				, strTaxCode
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, dtmDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFederalTaxId
				, strTransporterFederalTaxId
				, strTerminalControlNumber
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTaxPayerName
				, strTaxPayerAddress
				, strCity
				, strState
				, strZipCode
				, strTelephoneNumber
				, strTaxPayerIdentificationNumber
				, strTaxPayerFEIN
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, strCustomerName
				, strCustomerFederalTaxId
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
				, strVendorLicenseNumber
				, dblQtyShipped
				, strContactName
				, strEmail
				, strImportVerificationNumber
				, strConsignorName
				, strConsignorFederalTaxId)
			SELECT DISTINCT @Guid
				, intItemId
				, intReportingComponentId
				, intProductCodeId = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.intProductCodeId 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = Trans.intReportingComponentId and tblICItemMotorFuelTax.intItemId = Trans.intItemId)
				, strProductCode = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.strProductCode 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = Trans.intReportingComponentId and tblICItemMotorFuelTax.intItemId = Trans.intItemId)
				, strBillOfLading
				, CONVERT(DECIMAL(18), dblReceived)
				, strTaxCode
				, CONVERT(DECIMAL(18), dblGross)
				, CONVERT(DECIMAL(18), dblNet)
				, CONVERT(DECIMAL(18), dblReceived)
				, dblTax
				, dtmDate
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strShipVia)), 35) ELSE strShipVia END AS strShipVia 
				, strTransporterLicense
				, strTransportationMode
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strVendorName)), 35) ELSE strVendorName END AS strVendorName  
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strTransporterName)), 35) ELSE strTransporterName END AS strTransporterName  
				, REPLACE(strVendorFederalTaxId, '-', '')
				, REPLACE(strTransporterFederalTaxId, '-', '')
				, strTerminalControlNumber
				, @DateFrom
				, @DateTo
				--HEADER
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strHeaderCompanyName)), 35) ELSE strHeaderCompanyName END AS strHeaderCompanyName 
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxId
				, REPLACE(strHeaderFederalTaxId, '-', '')
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strCustomerName)), 35) ELSE strCustomerName END AS strCustomerName  
				, REPLACE(strCustomerFederalTaxId, '-', '')
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
				, strVendorLicenseNumber
				, CONVERT(DECIMAL(18), dblGross)
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strContactName)), 35) ELSE strContactName END AS strContactName 
				, strEmail
				, strImportVerificationNumber
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strConsignorName)), 35) ELSE strConsignorName END AS strConsignorName  
				, REPLACE(strConsignorFederalTaxId, '-', '')
			FROM @tmpTransaction Trans
		END

		IF (NOT EXISTS(SELECT TOP 1 1 FROM @tmpTransaction WHERE intReportingComponentId = @RCId ))
		BEGIN

			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, strProductCode
				, dtmDate
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTransactionType
				, strEmail
				, strContactName
				, strTaxPayerName
				, strTaxPayerAddress
				, strCity
				, strState
				, strZipCode
				, strTelephoneNumber)
			SELECT @Guid
				, @RCId
				, 'No record found.'
				, @DateFrom
				, @DateFrom
				, @DateTo
				, 'Receipt'
				, strContactEmail
				, strContactName
				, strCompanyName
				, strTaxAddress
				, strCity
				, strState
				, strZipCode
				, strContactPhone
			FROM tblTFCompanyPreference
			
		END
		
		DELETE FROM @tmpTransaction
		DELETE FROM @tmpRC WHERE @RCId = intReportingComponentId

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