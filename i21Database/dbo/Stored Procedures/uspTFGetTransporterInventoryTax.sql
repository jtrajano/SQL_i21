﻿CREATE PROCEDURE [dbo].[uspTFGetTransporterInventoryTax]
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

	DECLARE @TFTransaction TFTransaction
	DECLARE @tmpDistReceiptDetail TFTransaction
	DECLARE @tmpInventoryDetailTax TFInventoryDetailTax

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
			INSERT INTO @TFTransaction(intId
				, intInventoryReceiptItemId
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
				, strCustomerName
				, strCustomerFederalTaxId
				, strReportingComponentNote
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, strContactName
				, strEmail)
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
					, Vendor.strFederalTaxId AS strVendorFEIN
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, tblTFCompanyPreference.strCompanyName
					, tblTFCompanyPreference.strTaxAddress
					, tblTFCompanyPreference.strCity
					, tblTFCompanyPreference.strState
					, tblTFCompanyPreference.strZipCode
					, tblTFCompanyPreference.strContactPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxID = tblSMCompanySetup.strEin
					, tblEMEntityLocation.strState AS strOriginState
					, tblEMEntityLocation.strCity AS strOriginCity
					, OriginCountyTaxCode.strCounty AS strOriginCounty
					, CASE WHEN tblTRLoadDistributionHeader.strDestination = 'Location' THEN DestinationLoc.strStateProvince ELSE CustomerLoc.strState END strDestinationState
					, CASE WHEN tblTRLoadDistributionHeader.strDestination = 'Location' THEN DestinationLoc.strCity ELSE CustomerLoc.strCity END strDestinationCity
					, NULL AS strDestinationCounty
					, tblTFTerminalControlNumber.strTerminalControlNumber
					, strTransporterIdType = 'FEIN'
					, strVendorIdType = 'FEIN'
					, strCustomerIdType = 'FEIN'
					, strVendorInvoiceNumber = tblTRLoadReceipt.strBillOfLading	
					, strCustomerLicenseNumber = NULL
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, tblSMCompanySetup.strCompanyName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFederalTaxId
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strTransactionType = 'Receipt'
					, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
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
				INNER JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId  = tblICInventoryReceipt.intInventoryReceiptId AND tblTRLoadReceipt.intItemId = tblICInventoryReceiptItem.intItemId
				INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
				INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId 
					LEFT JOIN tblSMCompanyLocation DestinationLoc ON DestinationLoc.intCompanyLocationId = tblTRLoadDistributionHeader.intCompanyLocationId
					LEFT JOIN tblEMEntityLocation CustomerLoc ON CustomerLoc.intEntityLocationId = tblTRLoadDistributionHeader.intShipToLocationId
					LEFT JOIN tblARCustomer ON tblARCustomer.intEntityId = tblTRLoadDistributionHeader.intEntityCustomerId
						LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
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
						OR ((tblTRLoadDistributionHeader.strDestination = 'Location' AND DestinationLoc.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblTRLoadDistributionHeader.strDestination = 'Customer' AND CustomerLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblTRLoadDistributionHeader.strDestination = 'Location' AND DestinationLoc.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblTRLoadDistributionHeader.strDestination = 'Customer' AND CustomerLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))	
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))		
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
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
				, strCustomerName
				, strCustomerFederalTaxId
				, strReportingComponentNote
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, strContactName
				, strEmail)
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
					, Vendor.strFederalTaxId AS strVendorFEIN
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, tblTFCompanyPreference.strCompanyName
					, tblTFCompanyPreference.strTaxAddress
					, tblTFCompanyPreference.strCity
					, tblTFCompanyPreference.strState
					, tblTFCompanyPreference.strZipCode
					, tblTFCompanyPreference.strContactPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxID = tblSMCompanySetup.strEin
					, tblEMEntityLocation.strState AS strOriginState
					, tblEMEntityLocation.strCity AS strOriginCity
					, OriginCountyTaxCode.strCounty AS strOriginCounty
					, CASE WHEN tblTRLoadDistributionHeader.strDestination = 'Location' THEN DestinationLoc.strStateProvince ELSE CustomerLoc.strState END strDestinationState
					, CASE WHEN tblTRLoadDistributionHeader.strDestination = 'Location' THEN DestinationLoc.strCity ELSE CustomerLoc.strCity END strDestinationCity
					, NULL AS strDestinationCounty
					, tblTFTerminalControlNumber.strTerminalControlNumber
					, strTransporterIdType = 'FEIN'
					, strVendorIdType = 'FEIN'
					, strCustomerIdType = 'FEIN'
					, strVendorInvoiceNumber = tblTRLoadReceipt.strBillOfLading	
					, strCustomerLicenseNumber = NULL
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, tblSMCompanySetup.strCompanyName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFederalTaxId
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strTransactionType = 'Receipt'
					, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
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
				INNER JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId  = tblICInventoryReceipt.intInventoryReceiptId AND tblTRLoadReceipt.intItemId = tblICInventoryReceiptItem.intItemId
				INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
				INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId 
					LEFT JOIN tblSMCompanyLocation DestinationLoc ON DestinationLoc.intCompanyLocationId = tblTRLoadDistributionHeader.intCompanyLocationId
					LEFT JOIN tblEMEntityLocation CustomerLoc ON CustomerLoc.intEntityLocationId = tblTRLoadDistributionHeader.intShipToLocationId
					LEFT JOIN tblARCustomer ON tblARCustomer.intEntityId = tblTRLoadDistributionHeader.intEntityCustomerId
						LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
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
						OR ((tblTRLoadDistributionHeader.strDestination = 'Location' AND DestinationLoc.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblTRLoadDistributionHeader.strDestination = 'Customer' AND CustomerLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblTRLoadDistributionHeader.strDestination = 'Location' AND DestinationLoc.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblTRLoadDistributionHeader.strDestination = 'Customer' AND CustomerLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))	
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))		
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
			) tblTFTransaction
		END

		-- Distinct the Account Status Code
		DECLARE @tmpDetailUniqueAccountStatusCode TABLE(
			intId INT, 
			intDetailId INT,
			PRIMARY KEY CLUSTERED ([intId] ASC) WITH (IGNORE_DUP_KEY = OFF),
			UNIQUE NONCLUSTERED ([intId] ASC, [intDetailId] ASC))
		
		INSERT INTO @tmpDetailUniqueAccountStatusCode
			SELECT MIN(intId) intId, intInventoryReceiptItemId FROM @TFTransaction 
			GROUP BY intInventoryReceiptItemId HAVING (COUNT(intInventoryReceiptItemId) > 1)

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpDetailUniqueAccountStatusCode)
		BEGIN
			DECLARE @intIdUASC NVARCHAR(30) = NULL, @intDetailUASC INT = NULL

			SELECT TOP 1 @intIdUASC = intId, @intDetailUASC = intDetailId FROM @tmpDetailUniqueAccountStatusCode

			DELETE FROM @TFTransaction WHERE intId <> @intIdUASC AND intInventoryReceiptItemId = @intDetailUASC

			DELETE FROM @tmpDetailUniqueAccountStatusCode WHERE intId = @intIdUASC
		END

		-- TAX CRITERIA
		IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId))
		BEGIN

			-- TRANSACTION WITHOUT TAX CODE
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))
			BEGIN	
				DELETE @TFTransaction WHERE intInventoryReceiptItemId IN (
					SELECT DISTINCT InventoryTran.intInventoryReceiptItemId 
					FROM @TFTransaction InventoryTran
					LEFT JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = InventoryTran.intInventoryReceiptItemId
					WHERE tblICInventoryReceiptItemTax.intTaxCodeId IS NULL	
				)
			END

			-- TRANSACTION WITH TAX CODE
			INSERT INTO @tmpInventoryDetailTax (intInventoryDetailId, intTaxCodeId, strCriteria, dblTax)
			SELECT InventoryTran.intInventoryReceiptItemId, tblICInventoryReceiptItemTax.intTaxCodeId, tblTFReportingComponentCriteria.strCriteria, tblICInventoryReceiptItemTax.dblTax
			FROM @TFTransaction InventoryTran
				INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = InventoryTran.intInventoryReceiptItemId
				INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
				INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
			WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId

			WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInventoryDetailTax)
			BEGIN		
				DECLARE @InventoryDetailId INT = NULL, @intTaxCodeId INT = NULL, @strCriteria NVARCHAR(100) = NULL,  @dblTax NUMERIC(18,8) = NULL

				SELECT TOP 1 @InventoryDetailId = intInventoryDetailId, @intTaxCodeId = intTaxCodeId, @strCriteria = strCriteria, @dblTax = dblTax FROM @tmpInventoryDetailTax

				IF(@strCriteria = '<> 0' AND @dblTax = 0)	
				BEGIN
					DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryDetailId										 
				END
				ELSE IF (@strCriteria = '= 0' AND @dblTax > 0)
				BEGIN
					DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryDetailId										 
				END

				DELETE @tmpInventoryDetailTax WHERE intInventoryDetailId = @InventoryDetailId AND intTaxCodeId = @intTaxCodeId

			END

			DELETE @tmpInventoryDetailTax

			-- TRANSACTION NOT MAPPED ON MFT TAX CATEGORY
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))
			BEGIN 	
				DELETE @TFTransaction WHERE intInventoryReceiptItemId NOT IN (
					SELECT DISTINCT InventoryTran.intInventoryReceiptItemId
					FROM @TFTransaction InventoryTran
						INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = InventoryTran.intInventoryReceiptItemId 
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
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, dblQtyShipped
				, strContactName
				, strEmail)
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
				, CONVERT(DECIMAL(18), dblReceived)
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
				, strCustomerName
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
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, CONVERT(DECIMAL(18), dblGross)
				, strContactName
				, strEmail
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