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

	DECLARE @InventoryReceiptItemId NVARCHAR(50)
	DECLARE @TaxCodeId NVARCHAR(50)
	DECLARE @TaxCriteria NVARCHAR(10)
	DECLARE @QueryrReceiptItem NVARCHAR(MAX)
	DECLARE @RCId INT
		, @CompanyName NVARCHAR(250)
		, @CompanyEIN NVARCHAR(100)
		, @intReceiptTransactionId INT
		, @intTaxCategoryId INT

	-- USER DEFINED TABLES
	DECLARE @TFReceiptItem TFReceiptItem
	DECLARE @TFTransaction TFTransaction
	--

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction
	END

	DELETE FROM tblTFTransaction
	WHERE uniqTransactionGuid = @Guid 
		AND strProductCode = 'No record found.'	
	
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE #tmpRC where intReportingComponentId = ''

	SELECT TOP 1 @CompanyName = strCompanyName, @CompanyEIN = strEin FROM tblSMCompanySetup

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC

		-- GET INVENTORY RECEIPT/S
		
		SELECT ROW_NUMBER() OVER(ORDER BY RC.intReportingComponentId, ReceiptItem.intInventoryReceiptItemId DESC) AS intId
			, ReceiptItem.intInventoryReceiptItemId
			, Receipt.strBillOfLading
		INTO #tmpReceiptTransaction
		FROM tblICInventoryReceiptItem ReceiptItem
		LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		INNER JOIN tblICItemMotorFuelTax ItemTax ON ItemTax.intItemId = ReceiptItem.intItemId
		INNER JOIN tblTFReportingComponentProductCode RCPC ON RCPC.intProductCodeId = ItemTax.intProductCodeId
		INNER JOIN tblTFReportingComponent RC ON RCPC.intReportingComponentId = RC.intReportingComponentId
		INNER JOIN tblSMCompanyLocation Destination ON Receipt.intLocationId = Destination.intCompanyLocationId
		INNER JOIN tblEMEntity Vendor ON Receipt.intEntityVendorId = Vendor.intEntityId
		INNER JOIN tblEMEntityLocation Origin ON Origin.intEntityLocationId = Receipt.intShipFromId
		WHERE Receipt.ysnPosted = 1
			AND RC.intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(Receipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(Receipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR Origin.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR Origin.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR Destination.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR Destination.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))

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
				, intProductCodeId
				, strProductCode
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
				, intTransactionNumberId)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId
				, *
			FROM (
			SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
				, tblTFReportingComponent.intTaxAuthorityId
				, tblTFReportingComponent.strFormCode
				, tblTFReportingComponent.intReportingComponentId
				, tblTFReportingComponent.strScheduleCode
				, strType = tblTFReportingComponent.strType
				, tblICInventoryReceiptItem.intItemId
				, tblTFReportingComponentProductCode.intProductCodeId
				, tblTFProductCode.strProductCode
				, tblICInventoryReceipt.strBillOfLading
				, tblICInventoryReceiptItem.dblReceived
				, tblICInventoryReceiptItem.dblGross
				, tblICInventoryReceiptItem.dblNet
				, tblICInventoryReceiptItem.dblBillQty
				, tblICInventoryReceipt.dtmReceiptDate
				, tblSMShipVia.strShipVia
				, tblSMShipVia.strTransporterLicense
				, tblSMShipVia.strTransportationMode
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
				, tblSMCompanySetup.strFederalTaxID
				, tblEMEntityLocation.strState AS strOriginState
				, tblEMEntityLocation.strCity AS strOriginCity
				, OriginCountyTaxCode.strCounty AS strOriginCounty
				, tblSMCompanyLocation.strStateProvince
				, tblSMCompanyLocation.strCity AS strDestinationCity
				, NULL AS strDestinationCounty
				, tblTFTerminalControlNumber.strTerminalControlNumber
				, strTransporterIdType = 'FEIN'
				, strVendorIdType = 'FEIN'
				, strCustomerIdType = 'FEIN'
				, strVendorInvoiceNumber = APBill.strVendorOrderNumber
				, strCustomerLicenseNumber = tblTFTaxAuthorityCustomerLicense.strLicenseNumber
				, strCustomerAccountStatusCode = NULL
				, strCustomerStreetAddress = NULL
				, strCustomerZipCode = NULL
				, strReportingComponentNote = tblTFReportingComponent.strNote
				, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
				, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
				, strTransactionType = 'Receipt'
				, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
			FROM tblTFReportingComponent 
			INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId =  tblICItemMotorFuelTax.intItemId
				INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
				INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
				INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
				LEFT JOIN tblSMTaxCode AS OriginCountyTaxCode ON OriginCountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
				INNER JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblICInventoryReceipt.intShipViaId
					INNER JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId 
				INNER JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId 
					LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
				INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
			INNER JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId  = tblICInventoryReceipt.intInventoryReceiptId
			INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
			INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
			LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = tblTRLoadDistributionHeader.intEntityCustomerId
			LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
			LEFT JOIN (
					SELECT TOP 1 tblAPBillDetail.intInventoryReceiptItemId, tblAPBill.intBillId, tblAPBill.strVendorOrderNumber
					FROM tblAPBillDetail 
					INNER JOIN tblAPBill ON tblAPBillDetail.intBillId = tblAPBill.intBillId
				) APBill ON APBill.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId
			CROSS JOIN tblSMCompanySetup
			WHERE  tblTFReportingComponent.intReportingComponentId = @RCId
				AND tblICInventoryReceipt.ysnPosted = 1
				AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				)tblTFTransaction
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
				, intProductCodeId
				, strProductCode
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
				, intTransactionNumberId)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId
				, *
			FROM (
			SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
				, tblTFReportingComponent.intTaxAuthorityId
				, tblTFReportingComponent.strFormCode
				, tblTFReportingComponent.intReportingComponentId
				, tblTFReportingComponent.strScheduleCode
				, strType = tblTFReportingComponent.strType
				, tblICInventoryReceiptItem.intItemId
				, tblTFReportingComponentProductCode.intProductCodeId
				, tblTFProductCode.strProductCode
				, tblICInventoryReceipt.strBillOfLading
				, tblICInventoryReceiptItem.dblReceived
				, tblICInventoryReceiptItem.dblGross
				, tblICInventoryReceiptItem.dblNet
				, tblICInventoryReceiptItem.dblBillQty
				, tblICInventoryReceipt.dtmReceiptDate
				, tblSMShipVia.strShipVia
				, tblSMShipVia.strTransporterLicense
				, tblSMShipVia.strTransportationMode
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
				, tblSMCompanySetup.strFederalTaxID
				, tblEMEntityLocation.strState AS strOriginState
				, tblEMEntityLocation.strCity AS strOriginCity
				, OriginCountyTaxCode.strCounty AS strOriginCounty
				, tblSMCompanyLocation.strStateProvince
				, tblSMCompanyLocation.strCity AS strDestinationCity
				, NULL AS strDestinationCounty
				, tblTFTerminalControlNumber.strTerminalControlNumber
				, strTransporterIdType = 'FEIN'
				, strVendorIdType = 'FEIN'
				, strCustomerIdType = 'FEIN'
				, strVendorInvoiceNumber = APBill.strVendorOrderNumber
				, strCustomerLicenseNumber = tblTFTaxAuthorityCustomerLicense.strLicenseNumber
				, strCustomerAccountStatusCode = NULL
				, strCustomerStreetAddress = NULL
				, strCustomerZipCode = NULL
				, strReportingComponentNote = tblTFReportingComponent.strNote
				, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
				, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
				, strTransactionType = 'Receipt'
				, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId
			FROM tblTFReportingComponent 
			INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId =  tblICItemMotorFuelTax.intItemId
				INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
				INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
				INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
				LEFT JOIN tblSMTaxCode AS OriginCountyTaxCode ON OriginCountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
				INNER JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblICInventoryReceipt.intShipViaId
					INNER JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId 
				INNER JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId 
					LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
				INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
			INNER JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId  = tblICInventoryReceipt.intInventoryReceiptId
			INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
			INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
			LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = tblTRLoadDistributionHeader.intEntityCustomerId
			LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
			LEFT JOIN (
					SELECT TOP 1 tblAPBillDetail.intInventoryReceiptItemId, tblAPBill.intBillId, tblAPBill.strVendorOrderNumber
					FROM tblAPBillDetail 
					INNER JOIN tblAPBill ON tblAPBillDetail.intBillId = tblAPBill.intBillId
				) APBill ON APBill.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId
			CROSS JOIN tblSMCompanySetup
			WHERE tblTFReportingComponent.intReportingComponentId = @RCId 
				AND tblICInventoryReceipt.ysnPosted = 1
				AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				)tblTransactions
		END
		
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpReceiptTransaction) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN
			-- RETRIEVE TAX CATEGORY BASED ON RECEIPT ITEM ID/S
			SELECT ROW_NUMBER() OVER(ORDER BY tblSMTaxCode.intTaxCodeId, tblTFReportingComponentCriteria.strCriteria DESC) AS intId
				, tblSMTaxCode.intTaxCodeId
				, tblTFReportingComponentCriteria.strCriteria
			INTO #tmpTaxCategory
			FROM tblSMTaxCode
			INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblTFReportingComponentCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
			WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId

			SELECT TOP 1 @intReceiptTransactionId = intId, @InventoryReceiptItemId = intInventoryReceiptItemId FROM #tmpReceiptTransaction

			WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTaxCategory) -- LOOP ON TAX CATEGORY
			BEGIN
				SELECT TOP 1 @intTaxCategoryId = intId, @TaxCodeId = intTaxCodeId, @TaxCriteria = strCriteria FROM #tmpTaxCategory

				SET @QueryrReceiptItem = 'SELECT  DISTINCT tblICInventoryReceiptItemTax.intInventoryReceiptItemId FROM
												tblICInventoryReceiptItem INNER JOIN
												tblICInventoryReceiptItemTax 
												ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId 
										WHERE  (tblICInventoryReceiptItem.intInventoryReceiptItemId IN(''' + @InventoryReceiptItemId + '''))
												AND (tblICInventoryReceiptItemTax.intTaxCodeId = ''' + @TaxCodeId + ''')
												AND (tblICInventoryReceiptItemTax.dblTax ' + @TaxCriteria + ')'
				DELETE FROM @TFReceiptItem
				INSERT INTO @TFReceiptItem
				EXEC(@QueryrReceiptItem)
	
				IF NOT EXISTS(SELECT TOP 1 1 FROM @TFReceiptItem) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
				BEGIN
					SELECT DISTINCT tblICInventoryReceiptItemTax.intInventoryReceiptItemId
					INTO #tmpReceiptItem
					FROM tblICInventoryReceiptItem
					INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId
					WHERE tblICInventoryReceiptItem.intInventoryReceiptItemId = @InventoryReceiptItemId
						AND tblICInventoryReceiptItemTax.intTaxCodeId = @TaxCodeId
																
					IF EXISTS(SELECT TOP 1 1  FROM #tmpReceiptItem)
					BEGIN
						DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
						DROP TABLE #tmpReceiptItem
						BREAK
					END
					ELSE
					BEGIN
						IF(@TaxCriteria = '<> 0')
						BEGIN
							DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
							DROP TABLE #tmpReceiptItem
							BREAK
						END
					END

					DROP TABLE #tmpReceiptItem
				END
				DELETE FROM #tmpTaxCategory WHERE intId = @intTaxCategoryId
			END			
			DELETE FROM #tmpReceiptTransaction WHERE intId = @intReceiptTransactionId

			DROP TABLE #tmpTaxCategory
		END
		
		DROP TABLE #tmpReceiptTransaction
			
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
				, intTransactionNumberId)
			SELECT DISTINCT @Guid
				, intItemId
				, intReportingComponentId
				, intProductCodeId
				, strProductCode
				, strBillOfLading
				, dblReceived
				, strTaxCategory
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, dtmReceiptDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFEIN
				, strTransporterFEIN
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
				, strHeaderFederalTaxID
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, @CompanyName
				, @CompanyEIN
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
			FROM @TFTransaction
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
		
		DELETE FROM #tmpRC WHERE @RCId = intReportingComponentId
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