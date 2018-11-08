CREATE PROCEDURE [dbo].[uspTFGetTransporterBulkInvoiceTax]
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

	DECLARE @tmpTransaction TFCommonTransaction
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
		
		-- Note: Result of this SP considered as Invoice even its come from Inventory Receipt
		-- Also this SP all taxes of transactions considered as "= 0"

		DECLARE @RCId INT = NULL
		, @intMaxId INT = 0

		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC

		IF  NOT EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0')
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
					AND (tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Location')				
			) tblTFTransaction
		END

		-- Distinct the Account Status Code
		DECLARE @tmpDetailUniqueAccountStatusCode TABLE(
			intId INT, 
			intDetailId INT,
			PRIMARY KEY CLUSTERED ([intId] ASC) WITH (IGNORE_DUP_KEY = OFF),
			UNIQUE NONCLUSTERED ([intId] ASC, [intDetailId] ASC))
		
		INSERT INTO @tmpDetailUniqueAccountStatusCode
			SELECT MIN(intId) intId, intTransactionDetailId FROM @tmpTransaction 
			GROUP BY intTransactionDetailId HAVING (COUNT(intTransactionDetailId) > 1)

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpDetailUniqueAccountStatusCode)
		BEGIN
			DECLARE @intIdUASC NVARCHAR(30) = NULL, @intDetailUASC INT = NULL

			SELECT TOP 1 @intIdUASC = intId, @intDetailUASC = intDetailId FROM @tmpDetailUniqueAccountStatusCode

			DELETE FROM @tmpTransaction WHERE intId <> @intIdUASC AND intTransactionDetailId = @intDetailUASC

			DELETE FROM @tmpDetailUniqueAccountStatusCode WHERE intId = @intIdUASC
		END

		-- GET MAX intId
		SELECT @intMaxId = MAX(intId) FROM @tmpTransaction	

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0')
		BEGIN				
			INSERT INTO @tmpTransaction(intId
				, intTransactionDetailId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
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
				, strCustomerFederalTaxId
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFederalTaxId
				, strConsignorName
				, strConsignorFederalTaxId
				, strVendorName
				, strVendorFederalTaxId
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxId
				, strHeaderFederalTaxId
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
				, strEmail)
			SELECT DISTINCT (ROW_NUMBER() OVER(ORDER BY intTaxAuthorityId) + @intMaxId) AS intId, *
			FROM (SELECT DISTINCT NULL AS intInvoiceDetailId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, tblTFReportingComponent.strType
					, tblICInventoryTransferDetail.intItemId
					, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
					, tblICInventoryTransferDetail.dblQuantity AS dblGross
					, tblICInventoryTransferDetail.dblQuantity AS dblNet
					, tblICInventoryTransferDetail.dblQuantity
					, NULL AS dblTax
					, NULL AS dblTaxExempt
					, NULL AS strInvoiceNumber
					, NULL AS strPONumber
					, CASE WHEN ISNULL(tblTRLoadReceipt.strBillOfLading, '') = '' THEN tblICInventoryTransfer.strTransferNo ELSE tblTRLoadReceipt.strBillOfLading END AS strBOLNumber
					, CASE WHEN tblTRLoadHeader.dtmLoadDateTime IS NULL THEN tblICInventoryTransfer.dtmTransferDate ELSE tblTRLoadHeader.dtmLoadDateTime END AS dtmDate
					, tblSMCompanyLocation.strCity AS strDestinationCity
					, NULL AS strDestinationCounty
					, tblSMCompanyLocation.strStateProvince AS strDestinationState
					, ShipFromLoc.strCity AS strOriginCity
					, ShipFromLoc.strCountry AS strOriginCounty
					, ShipFromLoc.strStateProvince AS strOriginState
					, tblSMCompanySetup.strCompanyName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFederalTaxId
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, tblEMEntity.strName AS strTransporterName
					, tblEMEntity.strFederalTaxId AS strTransporterFederalTaxId
					, tblEMEntity.strName AS strConsignorName
					, tblEMEntity.strFederalTaxId AS strConsignorFederalTaxId
					, EntityAPVendor.strName AS strVendorName
					, EntityAPVendor.strFederalTaxId AS strVendorFederalTaxId
					, tblTFCompanyPreference.strCompanyName
					, tblTFCompanyPreference.strTaxAddress
					, tblTFCompanyPreference.strCity
					, tblTFCompanyPreference.strState
					, tblTFCompanyPreference.strZipCode
					, tblTFCompanyPreference.strContactPhone
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
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
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
					INNER JOIN tblSMCompanyLocation ShipFromLoc ON ShipFromLoc.intCompanyLocationId = tblICInventoryTransfer.intFromLocationId
				INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadReceiptId = tblICInventoryTransferDetail.intSourceId
					LEFT JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
					LEFT JOIN tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityId = EntityAPVendor.intEntityId
					LEFT JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = tblICInventoryTransfer.intToLocationId
				INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
					INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
					LEFT JOIN tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityId 
					LEFT JOIN tblEMEntity ON tblSMShipVia.intEntityId = tblEMEntity.intEntityId 
					LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode	
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblSMCompanyLocation.ysnTrackMFTActivity = 1
					AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND tblICInventoryTransfer.ysnPosted = 1
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
							OR (ShipFromLoc.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
							OR (ShipFromLoc.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
							OR (tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
							OR (tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
							OR EntityAPVendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
							OR EntityAPVendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND ((tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Location') OR 
						(tblTRLoadReceipt.strOrigin IS NULL OR tblTRLoadDistributionHeader.strDestination IS NULL))
			) tblTransactions
		END
	
		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, intProductCodeId
				, strProductCode
				, intItemId
				, dblReceived
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
				, strContactName
				, strEmail)
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
				, CONVERT(DECIMAL(18), dblReceived)
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
				, REPLACE(strCustomerFederalTaxId, '-', '')
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, REPLACE(strTransporterFederalTaxId, '-', '')
				, strConsignorName
				, REPLACE(strConsignorFederalTaxId, '-', '')
				, strTaxCode
				, strTerminalControlNumber
				, strVendorName
				, REPLACE(strVendorFederalTaxId, '-', '')
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxId
				, REPLACE(strHeaderFederalTaxId, '-', '')
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
				, strEmail
			FROM @tmpTransaction Trans
		END

		IF (NOT EXISTS(SELECT TOP 1 1 FROM @tmpTransaction WHERE intReportingComponentId = @RCId ) AND @IsEdi = 0)
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
