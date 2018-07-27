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

	DECLARE @CompanyName NVARCHAR(250) = NULL
		, @CompanyEIN NVARCHAR(100) = NULL

	-- USER DEFINED TABLES
	DECLARE @TFTransaction TFTransaction
	DECLARE @tmpInventoryReceiptDetail TFInventoryReceiptDetailTransaction
	DECLARE @tmpDistReceiptDetail TFTransaction
	DECLARE @tmpRC TABLE (intReportingComponentId INT)

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction
	END

	DELETE FROM tblTFTransaction
	WHERE uniqTransactionGuid = @Guid 
		AND strProductCode = 'No record found.'	
	
	INSERT INTO @tmpRC
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE @tmpRC where intReportingComponentId = ''

	SELECT TOP 1 @CompanyName = strCompanyName, @CompanyEIN = strEin FROM tblSMCompanySetup

	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpRC)
	BEGIN

		DECLARE @RCId INT = NULL

		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC

		-- GET RECORDS WITH TAX CRITERIA
		INSERT INTO @tmpInventoryReceiptDetail
		SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId, tblICInventoryReceiptItemTax.intTaxCodeId
			FROM tblTFReportingComponent 
			INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId = tblICItemMotorFuelTax.intItemId
				LEFT JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId
					--LEFT JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
			INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
				INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
				INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
				LEFT JOIN tblSMTaxCode AS OriginCountyTaxCode ON OriginCountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
				LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId
				INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
			LEFT JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId
			LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
			LEFT JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
				LEFT JOIN tblSMCompanyLocation BulkLocation ON BulkLocation.intCompanyLocationId = tblTRLoadDistributionHeader.intCompanyLocationId
				LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = tblTRLoadDistributionHeader.intShipToLocationId
		WHERE tblICInventoryReceipt.ysnPosted = 1
			AND tblTFReportingComponent.intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))		
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR (tblTRLoadDistributionHeader.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					OR tblTRLoadDistributionHeader.strDestination = 'Location' AND BulkLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					OR tblTRLoadDistributionHeader.strDestination = 'Customer' AND CustomerLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
				))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR (tblTRLoadDistributionHeader.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					OR tblTRLoadDistributionHeader.strDestination = 'Location' AND BulkLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					OR tblTRLoadDistributionHeader.strDestination = 'Customer' AND CustomerLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
				))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
			AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
			AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
			AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
			AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0


		IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId)
		BEGIN
			INSERT INTO @TFTransaction(intId
				, intInventoryReceiptItemId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intItemId
				--, intProductCodeId
				--, strProductCode
				, strBillOfLading
				, dblReceived
				, dblGross
				, dblNet
				, dblBillQty
				, dtmReceiptDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFEIN
				, strTransporterFEIN
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, strHeaderFederalTaxID
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
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, strContactName)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId, *
			FROM (SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, strType = tblTFReportingComponent.strType
					, tblICInventoryReceiptItem.intItemId
					--, tblTFReportingComponentProductCode.intProductCodeId
					--, tblTFProductCode.strProductCode
					, tblICInventoryReceipt.strBillOfLading
					--, tblICInventoryReceiptItem.dblReceived
					--, tblICInventoryReceiptItem.dblGross
					--, tblICInventoryReceiptItem.dblNet
					--, tblICInventoryReceiptItem.dblBillQty
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblReceived END dblReceived
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblGross END dblGross
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblNet END dblNet
					, tblICInventoryReceiptItem.dblBillQty
					--(CASE WHEN tblICInventoryReceiptItem.dblBillQty >= tblTRLoadDistributionDetail.dblUnits THEN tblTRLoadDistributionDetail.dblUnits ELSE 0 END) 
					--ELSE tblICInventoryReceiptItem.dblBillQty END dblBillQty
					, tblICInventoryReceipt.dtmReceiptDate
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, Vendor.strName AS strVendorName
					, Transporter.strName AS strTransporterName
					, Vendor.strFederalTaxId AS strVendorFEIN
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, tblSMCompanySetup.strCompanyName
					, tblSMCompanySetup.strAddress
					, tblSMCompanySetup.strCity
					, tblSMCompanySetup.strState
					, tblSMCompanySetup.strZip
					, tblSMCompanySetup.strPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxID = @CompanyEIN
					, tblEMEntityLocation.strState AS strOriginState
					, tblEMEntityLocation.strCity AS strOriginCity
					, OriginCountyTaxCode.strCounty AS strOriginCounty
					--, tblSMCompanyLocation.strStateProvince
					--, tblSMCompanyLocation.strCity
					, CASE WHEN DistributionDetail.strDestination = 'Location' THEN BulkLocation.strStateProvince WHEN DistributionDetail.strDestination = 'Customer' THEN CustomerLocation.strState ELSE tblSMCompanyLocation.strStateProvince END strDestinationState
					, CASE WHEN DistributionDetail.strDestination = 'Location' THEN BulkLocation.strCity WHEN DistributionDetail.strDestination = 'Customer' THEN CustomerLocation.strCity ELSE tblSMCompanyLocation.strCity END strDestinationCity
					, NULL AS strDestinationCounty
					, tblTFTerminalControlNumber.strTerminalControlNumber
					, strTransporterIdType = 'FEIN'
					, strVendorIdType = 'FEIN'
					, strCustomerIdType = 'FEIN'
					, strVendorInvoiceNumber = tblTRLoadReceipt.strBillOfLading
					, strCustomerLicenseNumber = tblTFTaxAuthorityCustomerLicense.strLicenseNumber
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
					, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
					, strTransactionType = 'Receipt'
					, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblSMCompanySetup.strContactName
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
				LEFT JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId  = tblICInventoryReceipt.intInventoryReceiptId AND tblTRLoadReceipt.intItemId = tblICInventoryReceiptItem.intItemId
				LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
				LEFT JOIN (
					SELECT  
						tblTRLoadDistributionDetail.intLoadDistributionDetailId,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.intItemId ELSE  vyuTRGetLoadBlendIngredient.intIngredientItemId END intItemId,
						tblTRLoadDistributionHeader.intLoadHeaderId, 
						tblTRLoadDistributionHeader.intCompanyLocationId, 
						tblTRLoadDistributionHeader.intLoadDistributionHeaderId,
						tblTRLoadDistributionHeader.intShipToLocationId,
						tblTRLoadDistributionHeader.intEntityCustomerId,
						tblTRLoadDistributionHeader.strDestination,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.strReceiptLink ELSE  vyuTRGetLoadBlendIngredient.strReceiptLink END strReceiptLink,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.dblUnits ELSE  vyuTRGetLoadBlendIngredient.dblQuantity END dblUnits
					 FROM tblTRLoadDistributionDetail INNER JOIN tblTRLoadDistributionHeader 
					 ON tblTRLoadDistributionDetail.intLoadDistributionHeaderId = tblTRLoadDistributionHeader.intLoadDistributionHeaderId
					 LEFT JOIN vyuTRGetLoadBlendIngredient ON vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId = tblTRLoadDistributionDetail.intLoadDistributionDetailId
				) DistributionDetail ON DistributionDetail.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND DistributionDetail.intItemId = tblTRLoadReceipt.intItemId AND DistributionDetail.strReceiptLink = tblTRLoadReceipt.strReceiptLine
					LEFT JOIN tblSMCompanyLocation BulkLocation ON BulkLocation.intCompanyLocationId = DistributionDetail.intCompanyLocationId
					LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = DistributionDetail.intShipToLocationId
				LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = DistributionDetail.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
				LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
				CROSS JOIN tblSMCompanySetup
				WHERE  tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblICInventoryReceipt.ysnPosted = 1
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					--	OR (tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					--	OR (tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                        OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                        OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                    ))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					    OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
                        OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
                        OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				) tblTFTransaction
		END
		ELSE
		BEGIN
			INSERT INTO @TFTransaction(intId
				, intInventoryReceiptItemId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intItemId
				--, intProductCodeId
				--, strProductCode
				, strBillOfLading
				, dblReceived
				, dblGross
				, dblNet
				, dblBillQty
				, dtmReceiptDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFEIN
				, strTransporterFEIN
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, strHeaderFederalTaxID
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
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, strContactName)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId, *
			FROM (SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, strType = tblTFReportingComponent.strType
					, tblICInventoryReceiptItem.intItemId
					--, tblTFReportingComponentProductCode.intProductCodeId
					--, tblTFProductCode.strProductCode
					, tblICInventoryReceipt.strBillOfLading
					--, tblICInventoryReceiptItem.dblReceived
					--, tblICInventoryReceiptItem.dblGross
					--, tblICInventoryReceiptItem.dblNet
					--, tblICInventoryReceiptItem.dblBillQty
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblReceived END dblReceived
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblGross END dblGross
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblNet END dblNet
					, tblICInventoryReceiptItem.dblBillQty
					, tblICInventoryReceipt.dtmReceiptDate
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode	
					, Vendor.strName AS strVendorName
					, Transporter.strName AS strTransporterName
					, Vendor.strFederalTaxId AS strVendorFEIN
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, tblSMCompanySetup.strCompanyName
					, tblSMCompanySetup.strAddress
					, tblSMCompanySetup.strCity
					, tblSMCompanySetup.strState
					, tblSMCompanySetup.strZip
					, tblSMCompanySetup.strPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxID = @CompanyEIN
					, tblEMEntityLocation.strState AS strOriginState
					, tblEMEntityLocation.strCity AS strOriginCity
					, OriginCountyTaxCode.strCounty AS strOriginCounty
					--, tblSMCompanyLocation.strStateProvince
					--, tblSMCompanyLocation.strCity 
					, CASE WHEN DistributionDetail.strDestination = 'Location' THEN BulkLocation.strStateProvince WHEN DistributionDetail.strDestination = 'Customer' THEN CustomerLocation.strState ELSE tblSMCompanyLocation.strStateProvince END strDestinationState
					, CASE WHEN DistributionDetail.strDestination = 'Location' THEN BulkLocation.strCity WHEN DistributionDetail.strDestination = 'Customer' THEN CustomerLocation.strCity ELSE tblSMCompanyLocation.strCity END strDestinationCity
					, NULL AS strDestinationCounty
					, tblTFTerminalControlNumber.strTerminalControlNumber
					, strTransporterIdType = 'FEIN'
					, strVendorIdType = 'FEIN'
					, strCustomerIdType = 'FEIN'
					, strVendorInvoiceNumber = tblTRLoadReceipt.strBillOfLading
					, strCustomerLicenseNumber = tblTFTaxAuthorityCustomerLicense.strLicenseNumber
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
					, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
					, strTransactionType = 'Receipt'
					, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblSMCompanySetup.strContactName
				FROM tblTFReportingComponent 
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFProductCode.intProductCodeId
				INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId =  tblICItemMotorFuelTax.intItemId
				--INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
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
				LEFT JOIN (
					SELECT  
						tblTRLoadDistributionDetail.intLoadDistributionDetailId,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.intItemId ELSE  vyuTRGetLoadBlendIngredient.intIngredientItemId END intItemId,
						tblTRLoadDistributionHeader.intLoadHeaderId, 
						tblTRLoadDistributionHeader.intCompanyLocationId, 
						tblTRLoadDistributionHeader.intLoadDistributionHeaderId,
						tblTRLoadDistributionHeader.intShipToLocationId,
						tblTRLoadDistributionHeader.intEntityCustomerId,
						tblTRLoadDistributionHeader.strDestination,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.strReceiptLink ELSE  vyuTRGetLoadBlendIngredient.strReceiptLink END strReceiptLink,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.dblUnits ELSE  vyuTRGetLoadBlendIngredient.dblQuantity END dblUnits
					 FROM tblTRLoadDistributionDetail INNER JOIN tblTRLoadDistributionHeader 
					 ON tblTRLoadDistributionDetail.intLoadDistributionHeaderId = tblTRLoadDistributionHeader.intLoadDistributionHeaderId
					 LEFT JOIN vyuTRGetLoadBlendIngredient ON vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId = tblTRLoadDistributionDetail.intLoadDistributionDetailId
				) DistributionDetail ON DistributionDetail.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND DistributionDetail.intItemId = tblTRLoadReceipt.intItemId AND DistributionDetail.strReceiptLink = tblTRLoadReceipt.strReceiptLine
					LEFT JOIN tblSMCompanyLocation BulkLocation ON BulkLocation.intCompanyLocationId = DistributionDetail.intCompanyLocationId
					LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = DistributionDetail.intShipToLocationId
				LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = DistributionDetail.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
				LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
				CROSS JOIN tblSMCompanySetup
				WHERE  tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblICInventoryReceipt.ysnPosted = 1
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					--	OR (tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					--	OR (tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                        OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                        OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                    ))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					    OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
                        OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
                        OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				) tblTFTransaction
		END
		
		-- TR Billed Qty
		INSERT INTO @tmpDistReceiptDetail (intId, intInventoryReceiptItemId, dblReceived, dblBillQty) 
		SELECT DISTINCT intId, intInventoryReceiptItemId, dblReceived, dblBillQty FROM @TFTransaction WHERE intInventoryReceiptItemId IN (SELECT DISTINCT intInventoryReceiptItemId FROM @tmpInventoryReceiptDetail)	

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpDistReceiptDetail)
		BEGIN
			DECLARE @ReceiptDetailId INT = NULL, @ReceiptDetailItemId INT = NULL, @ReceiptDetailItemReceived NUMERIC(18,6) = NULL, @ReceiptDetailItemBillQty NUMERIC(18,6) = NULL, @RemainingBillQty NUMERIC(18,6) = NULL
			DECLARE @TRDetail TFTransaction 

			SELECT TOP 1 @ReceiptDetailId = intId, @ReceiptDetailItemId = intInventoryReceiptItemId, @ReceiptDetailItemReceived = dblReceived, @ReceiptDetailItemBillQty = dblBillQty FROM @tmpDistReceiptDetail

			IF(@ReceiptDetailItemBillQty >= @ReceiptDetailItemReceived)
			BEGIN
				UPDATE @TFTransaction SET dblBillQty = dblNet WHERE intId = @ReceiptDetailId
				SET @RemainingBillQty =  @ReceiptDetailItemBillQty - @ReceiptDetailItemReceived
				UPDATE @tmpDistReceiptDetail SET dblBillQty = @RemainingBillQty
			END
			ELSE
			BEGIN
				UPDATE @TFTransaction SET dblBillQty = 0 WHERE intId = @ReceiptDetailId
			END

			DELETE FROM @tmpDistReceiptDetail WHERE intId = @ReceiptDetailId

		END

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInventoryReceiptDetail) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN	
			
			DECLARE @InventoryReceiptItemId NVARCHAR(30) = NULL, @intDetailTaxCodeId INT = NULL

			SELECT TOP 1 @InventoryReceiptItemId = intInventoryReceiptItemId, @intDetailTaxCodeId = intTaxCodeId FROM @tmpInventoryReceiptDetail

			DECLARE @tblTaxCriteria TABLE (
				intCriteriaId INT,
				intTaxCategoryId INT,
				strTaxCategory NVARCHAR(500),
				strCriteria NVARCHAR(100),
				intTaxCodeId INT)

			-- Get MFT Tax Criteria
			INSERT INTO @tblTaxCriteria
				SELECT ROW_NUMBER() OVER(ORDER BY intTaxCategoryId, strTaxCategory) AS intCriteriaId, *
				FROM (
					SELECT tblTFTaxCategory.intTaxCategoryId , tblTFTaxCategory.strTaxCategory, tblTFReportingComponentCriteria.strCriteria, tblSMTaxCode.intTaxCodeId
					FROM tblTFReportingComponent
					INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
					LEFT JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
					WHERE tblTFReportingComponent.intReportingComponentId = @RCId
				) Transactions


			WHILE EXISTS (SELECT TOP 1 1 FROM @tblTaxCriteria) -- LOOP ON TAX CATEGORY
			BEGIN

				DECLARE @intCriteriaId INT = NULL, @strCriteriaTaxCodeId NVARCHAR(10) = NULL, @strCriteria NVARCHAR(10) = NULL, @intTaxCategoryId INT = NULL, @intTransTaxCategoryId INT = NULL

				SELECT TOP 1 @intCriteriaId = intCriteriaId,  @strCriteriaTaxCodeId = intTaxCodeId, @strCriteria = strCriteria, @intTaxCategoryId = intTaxCategoryId FROM @tblTaxCriteria
				
				-- GET Tax Transaction Detail
				SELECT TOP 1 @intTransTaxCategoryId = tblSMTaxCode.intTaxCategoryId 
				FROM tblICInventoryReceiptItemTax 
				LEFT JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId 
				LEFT JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				WHERE tblICInventoryReceiptItemTax.intInventoryReceiptItemId = @InventoryReceiptItemId AND tblTFTaxCategory.intTaxCategoryId = @intTaxCategoryId

				IF(@intDetailTaxCodeId IS NULL) -- DOES NOT HAVE THE TAX CODE
				BEGIN
					IF(@strCriteria = '<> 0')
					BEGIN
						DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId								 
						BREAK
					END
				END
				ELSE IF (@intDetailTaxCodeId IS NOT NULL AND @intTransTaxCategoryId IS NULL) -- NOT MAPPED ON MFT TAX CATEGORY
				BEGIN
					IF(@strCriteria = '<> 0')
					BEGIN
						DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId									 
						BREAK
					END
				END
				ELSE
				BEGIN
					DECLARE @tblTempInventoryReceiptDetail TABLE (intInventoryReceiptItemId INT)
					DECLARE @QueryrReceiptItem NVARCHAR(MAX) = NULL
					-- Check if satisfy the tax criteria
					SET @QueryrReceiptItem = 'SELECT DISTINCT tblICInventoryReceiptItemTax.intInventoryReceiptItemId FROM tblICInventoryReceiptItem' 
							+ ' INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId'
							+ '	WHERE  (tblICInventoryReceiptItem.intInventoryReceiptItemId IN(''' + @InventoryReceiptItemId + '''))' 
							+ '	AND (tblICInventoryReceiptItemTax.intTaxCodeId = ''' + @strCriteriaTaxCodeId + ''')'
							+ '	AND (tblICInventoryReceiptItemTax.dblTax ' + @strCriteria + ')'

					INSERT INTO @tblTempInventoryReceiptDetail
					EXEC(@QueryrReceiptItem)

					IF NOT EXISTS (SELECT TOP 1 1 FROM @tblTempInventoryReceiptDetail) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
					BEGIN
						DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId								 
						BREAK
					END

					DELETE FROM @tblTempInventoryReceiptDetail

				END

				DELETE FROM @tblTaxCriteria WHERE intCriteriaId = @intCriteriaId

			END	

			DELETE FROM @tmpInventoryReceiptDetail WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
			
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
				, strContactName)
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
				, strTaxCategory
				, CONVERT(DECIMAL(18), dblGross)
				, CONVERT(DECIMAL(18), dblNet)
				, CONVERT(DECIMAL(18), dblBillQty)
				, dblTax
				, dtmReceiptDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, REPLACE(strVendorFEIN, '-', '')
				, REPLACE(strTransporterFEIN, '-', '')
				, strTerminalControlNumber
				, @DateFrom
				, @DateTo
				--HEADER
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, REPLACE(strHeaderFederalTaxID, '-', '')
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, @CompanyName
				, REPLACE(@CompanyEIN, '-', '')
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
				, strContactName
			FROM @TFTransaction Trans
		END

		IF (NOT EXISTS(SELECT TOP 1 1 FROM @TFTransaction WHERE intReportingComponentId = @RCId ) AND @IsEdi = 0)
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, strProductCode
				, dtmDate
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTransactionType)
			VALUES(@Guid
				, @RCId
				, 'No record found.'
				, GETDATE()
				, @DateFrom
				, @DateTo
				, 'Receipt')
		END
		
		DELETE FROM @TFTransaction
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