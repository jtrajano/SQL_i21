CREATE PROCEDURE [dbo].[uspTFGetInvoiceTax]
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

	DECLARE @Count INT
	DECLARE @CountRC INT
	DECLARE @InvoiceDetailId NVARCHAR(50)
	DECLARE @QueryInvoice NVARCHAR(MAX)
	DECLARE @QueryReceipt NVARCHAR(MAX)
	DECLARE @QueryTaxCategory NVARCHAR(MAX)

	DECLARE @TaxCodeId NVARCHAR(50)
	DECLARE @TaxCategoryCount INT
	DECLARE @TaxCriteria NVARCHAR(10)
	DECLARE @TaxCategory NVARCHAR(MAX)
	DECLARE @QueryrInvoiceDetailId NVARCHAR(MAX)
	DECLARE @IsValidCategory INT
	DECLARE @QueryInvoiceNumber NVARCHAR(MAX)
	DECLARE @QueryRC NVARCHAR(MAX)
	DECLARE @RCId NVARCHAR(50)

	DECLARE @tmpInvoiceDetail TFInvoiceDetail
	DECLARE @tmpInvoiceTransaction TFInvoiceDetail

	DECLARE @tblTempInvoiceDetail TABLE (
		intId INT IDENTITY(1,1),
		intInvoiceDetailId INT)

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransactions --WHERE uniqTransactionGuid = @Guid
	END
	DELETE FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'
		
	-- ORIGIN
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC

		INSERT INTO @tmpInvoiceDetail(intId
			, intInvoiceDetailId
			, strInvoiceNumber)
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY tblARInvoiceDetail.intInvoiceDetailId, tblARInvoice.strInvoiceNumber DESC) AS intId
			, tblARInvoiceDetail.intInvoiceDetailId
			, tblARInvoice.strInvoiceNumber
		FROM tblARInvoiceDetail 
		INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
		LEFT JOIN tblARCustomer Customer ON Customer.intEntityCustomerId = tblARInvoice.intEntityCustomerId
		INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
		INNER JOIN tblICItemMotorFuelTax ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
		INNER JOIN tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
		INNER JOIN tblTFReportingComponent ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
		INNER JOIN tblTFTaxCriteria ON tblTFTaxCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
		INNER JOIN tblTFTaxCategory ON tblTFTaxCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
		INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId AND tblARInvoiceDetailTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId
		INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
		WHERE tblARInvoice.ysnPosted = 1
			AND tblTFReportingComponent.intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND Origin.strState IN (SELECT strState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')
			AND Origin.strState NOT IN (SELECT strState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
			AND Destination.strStateProvince IN (SELECT strStateProvince FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
			AND Destination.strStateProvince NOT IN (SELECT strStateProvince FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
			AND Customer.intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId)
			
		
		IF EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = @RCId)
		BEGIN
			INSERT INTO @tmpInvoiceTransaction(intId
				, intInvoiceDetailId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intProductCode
				, strProductCode
				, intItemId
				, dblQtyShipped
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, strInvoiceNumber
				, strPONumber
				, strBillOfLading
				, dtmDate
				, strDestinationCity
				, strDestinationState
				, strOriginCity
				, strOriginState
				, strCustomerName
				, strCustomerFEIN
				, strAccountStatusCode
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
				, strHeaderFederalTaxID)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY tblARInvoiceDetail.intInvoiceDetailId, tblTFReportingComponent.intTaxAuthorityId, RCProductCode.intProductCodeId DESC) AS intId
				, tblARInvoiceDetail.intInvoiceDetailId
				, tblTFReportingComponent.intTaxAuthorityId
				, tblTFReportingComponent.strFormCode
				, tblTFReportingComponent.intReportingComponentId
				, tblTFReportingComponent.strScheduleCode
				, tblTFReportingComponent.strType
				, RCProductCode.intProductCodeId
				, RCProductCode.strProductCode
				, tblARInvoiceDetail.intItemId
				, tblARInvoiceDetail.dblQtyShipped
				, tblARInvoiceDetail.dblQtyShipped AS dblNet
				, tblARInvoiceDetail.dblQtyShipped AS dblGross
				, tblARInvoiceDetail.dblQtyShipped AS dblBillQty
				, tblARInvoiceDetailTax.dblTax
				, tblARInvoice.strInvoiceNumber
				, tblARInvoice.strPONumber
				, tblARInvoice.strBOLNumber
				, tblARInvoice.dtmDate
				, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity
				, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState
				, tblSMCompanyLocation.strCity AS strOriginCity
				, tblSMCompanyLocation.strStateProvince AS strOriginState
				, tblEMEntity.strName
				, tblEMEntity.strFederalTaxId AS strCustomerFEIN
				, tblARAccountStatus.strAccountStatusCode
				, tblSMShipVia.strShipVia
				, tblSMShipVia.strTransporterLicense
				, tblSMShipVia.strTransportationMode
				, tblEMEntity_Transporter.strName AS strTransporterName
				, tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN
				, NULL
				, NULL
				, tblSMTaxCode.strTaxCode
				, NULL
				, NULL
				, NULL
				, tblSMCompanySetup.strCompanyName
				, tblSMCompanySetup.strAddress
				, tblSMCompanySetup.strCity
				, tblSMCompanySetup.strState
				, tblSMCompanySetup.strZip
				, tblSMCompanySetup.strPhone
				, tblSMCompanySetup.strStateTaxID
				, tblSMCompanySetup.strFederalTaxID
			FROM tblEMEntity AS tblEMEntity_Transporter
			INNER JOIN tblSMShipVia ON tblEMEntity_Transporter.intEntityId = tblSMShipVia.intEntityShipViaId
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
			INNER JOIN tblARInvoice ON tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId
			INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
			INNER JOIN vyuTFGetReportingComponentProductCode RCProductCode ON tblICItemMotorFuelTax.intProductCodeId = RCProductCode.intProductCodeId
			INNER JOIN tblTFReportingComponent ON RCProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblTFTaxCriteria ON tblTFTaxCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblTFTaxCategory ON tblTFTaxCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
			INNER JOIN tblICItemMotorFuelTax ON tblARInvoiceDetailTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId AND tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
			INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
			INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId
			INNER JOIN tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId 
			FULL OUTER JOIN tblARAccountStatus AccountStatus ON tblARCustomer.intAccountStatusId = AccountStatus.intAccountStatusId
			CROSS JOIN tblSMCompanySetup
			WHERE tblARInvoice.ysnPosted = 1 
				AND tblTFReportingComponent.intReportingComponentId = @RCId
				AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND Origin.strState IN (SELECT strState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')
				AND Origin.strState NOT IN (SELECT strState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
				AND Destination.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
				AND Destination.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
				AND Customer.intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId)
				AND AccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId)
		END
		ELSE
		BEGIN
			INSERT INTO @tmpInvoiceTransaction(intId
				, intInvoiceDetailId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intProductCode
				, strProductCode
				, intItemId
				, dblQtyShipped
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, strInvoiceNumber
				, strPONumber
				, strBillOfLading
				, dtmDate
				, strDestinationCity
				, strDestinationState
				, strOriginCity
				, strOriginState
				, strCustomerName
				, strCustomerFEIN
				, strAccountStatusCode
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
				, strHeaderFederalTaxID)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY tblARInvoiceDetail.intInvoiceDetailId, tblTFReportingComponent.intTaxAuthorityId, RCProductCode.intProductCodeId DESC) AS intId
				, tblARInvoiceDetail.intInvoiceDetailId
				, tblTFReportingComponent.intTaxAuthorityId
				, tblTFReportingComponent.strFormCode
				, tblTFReportingComponent.intReportingComponentId
				, tblTFReportingComponent.strScheduleCode
				, tblTFReportingComponent.strType
				, RCProductCode.intProductCodeId
				, RCProductCode.strProductCode
				, tblARInvoiceDetail.intItemId
				, tblARInvoiceDetail.dblQtyShipped
				, tblARInvoiceDetail.dblQtyShipped AS dblNet
				, tblARInvoiceDetail.dblQtyShipped AS dblGross
				, tblARInvoiceDetail.dblQtyShipped AS dblBillQty
				, tblARInvoiceDetailTax.dblTax
				, tblARInvoice.strInvoiceNumber
				, tblARInvoice.strPONumber
				, tblARInvoice.strBOLNumber
				, tblARInvoice.dtmDate
				, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity
				, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState
				, tblSMCompanyLocation.strCity AS strOriginCity
				, tblSMCompanyLocation.strStateProvince AS strOriginState
				, tblEMEntity.strName
				, tblEMEntity.strFederalTaxId AS strCustomerFEIN
				, tblARAccountStatus.strAccountStatusCode
				, tblSMShipVia.strShipVia
				, tblSMShipVia.strTransporterLicense
				, tblSMShipVia.strTransportationMode
				, tblEMEntity_Transporter.strName AS strTransporterName
				, tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN
				, NULL
				, NULL
				, tblSMTaxCode.strTaxCode
				, NULL
				, NULL
				, NULL
				, tblSMCompanySetup.strCompanyName
				, tblSMCompanySetup.strAddress
				, tblSMCompanySetup.strCity
				, tblSMCompanySetup.strState
				, tblSMCompanySetup.strZip
				, tblSMCompanySetup.strPhone
				, tblSMCompanySetup.strStateTaxID
				, tblSMCompanySetup.strFederalTaxID
			FROM tblEMEntity AS tblEMEntity_Transporter
			INNER JOIN tblSMShipVia ON tblEMEntity_Transporter.intEntityId = tblSMShipVia.intEntityShipViaId
			INNER JOIN tblARInvoiceDetail ON tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId
			INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
			INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
			FULL OUTER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intItemId = tblARInvoiceDetail.intItemId
			INNER JOIN vyuTFGetReportingComponentProductCode RCProductCode ON tblICItemMotorFuelTax.intProductCodeId = RCProductCode.intProductCodeId
			INNER JOIN tblTFReportingComponent ON RCProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
			INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
			INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId
			INNER JOIN tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId
			FULL OUTER JOIN tblARAccountStatus AccountStatus ON tblARCustomer.intAccountStatusId = AccountStatus.intAccountStatusId
			CROSS JOIN tblSMCompanySetup
			WHERE tblARInvoice.ysnPosted = 1
				AND tblTFReportingComponent.intReportingComponentId = @RCId
				AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND Origin.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')
				AND Origin.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
				AND Destination.strStateProvince IN (SELECT strStateProvince FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
				AND Destination.strStateProvince NOT IN (SELECT strStateProvince FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
				AND Customer.intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId)
				AND AccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId)
		END
	
		-- RETRIEVE TAX CATEGORY BASED ON RECEIPT ITEM ID/S
		SELECT DISTINCT tblSMTaxCode.intTaxCodeId
			, tblTFTaxCriteria.strCriteria
		INTO #tmpTaxCategory
		FROM tblSMTaxCode
		INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
		INNER JOIN tblTFTaxCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFTaxCriteria.intTaxCategoryId
		WHERE tblTFTaxCriteria.intReportingComponentId = @RCId

		SET @Count = (SELECT count(intId) FROM @tblTempInvoiceTransaction) 				
		WHILE(@Count > 0) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN
			SET @InvoiceDetailId = (SELECT intInvoiceDetailId FROM @tblTempInvoiceTransaction WHERE intId = @Count)
			
			WHILE EXISTS (SELECT TOP 1 1 FROM #tmpTaxCategory) -- LOOP ON TAX CATEGORY
			BEGIN
				SELECT TOP 1 @TaxCodeId = intTaxCodeId, @TaxCriteria = strCriteria FROM #tmpTaxCategory

				SET @QueryrInvoiceDetailId =  'SELECT DISTINCT tblARInvoiceDetailTax.intInvoiceDetailId
													FROM  tblARInvoiceDetail INNER JOIN
														tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
														WHERE tblARInvoiceDetailTax.intInvoiceDetailId IN(''' + @InvoiceDetailId + ''')
														AND (tblARInvoiceDetailTax.intTaxCodeId = ''' + @TaxCodeId + ''')
														AND (tblARInvoiceDetailTax.dblTax ' + @TaxCriteria + ')'

										   
				DELETE FROM @tblTempInvoiceDetail
				INSERT INTO @tblTempInvoiceDetail
				EXEC(@QueryrInvoiceDetailId)
	
				IF EXISTS (SELECT TOP 1 1 FROM @tblTempInvoiceDetail) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
				BEGIN
					DELETE FROM TFInvoiceTransaction WHERE intInvoiceDetailId = @InvoiceDetailId								 
					BREAK
				END
				
				DELETE FROM #tmpTaxCategory WHERE intTaxCodeId = @TaxCodeId AND strCriteria = @TaxCriteria
			END
								 
			SET @Count = @Count - 1
		END

		--INVENTORY TRANSFER
		DECLARE @InvTransferQuery NVARCHAR(MAX)
		DECLARE @InvQueryPart1 NVARCHAR(MAX)
		DECLARE @InvQueryPart2 NVARCHAR(MAX)

		DECLARE @CriteriaCount INT
		DECLARE @Criteria NVARCHAR(200) = ''
		SET @CriteriaCount = (SELECT COUNT(tblTFReportingComponent.intReportingComponentId)
		FROM  tblTFReportingComponent INNER JOIN tblTFTaxCriteria 
		ON tblTFReportingComponent.intReportingComponentId = tblTFTaxCriteria.intReportingComponentId
		WHERE tblTFReportingComponent.intReportingComponentId = @RCId AND tblTFTaxCriteria.strCriteria = '= 0')

		IF(@CriteriaCount > 0) 
		BEGIN
			SET @Criteria = 'AND tblTFTaxCriteria.strCriteria <> ''= 0'' AND tblTFTaxCriteria.strCriteria <> ''<> 0'''
		END

		SET @InvQueryPart1 = 'SELECT DISTINCT NULL AS intInvoiceDetailId,                                  
					tblTFReportingComponent.intTaxAuthorityId, 
					tblTFReportingComponent.strFormCode, 
					tblTFReportingComponent.intReportingComponentId, 
					tblTFReportingComponent.strScheduleCode, 
					tblTFReportingComponent.strType, 
					tblTFReportingComponentProductCode.intProductCode, 
					tblTFReportingComponentProductCode.strProductCode, 
					tblICInventoryTransferDetail.intItemId, 
					tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped, 
					tblICInventoryTransferDetail.dblQuantity AS dblGross, 
					tblICInventoryTransferDetail.dblQuantity AS dblNet, 
					tblICInventoryTransferDetail.dblQuantity, 
					NULL AS dblTax, 
					NULL AS strInvoiceNumber, 
					NULL AS strPONumber, 
					tblTRLoadReceipt.strBillOfLading AS strBOLNumber,
					tblTRLoadHeader.dtmLoadDateTime AS dtmDate,
					tblSMCompanyLocation.strCity AS strDestinationCity,
					tblSMCompanyLocation.strStateProvince AS strDestinationState,
					tblEMEntityLocation.strCity AS strOriginCity, 
					tblEMEntityLocation.strState AS strOriginState, 
					tblSMCompanyLocation.strLocationName AS strCustomerName, 
					NULL AS strCustomerFEIN, 
					NULL AS strAccountStatusCode, 
					tblSMShipVia.strShipVia, 
					tblSMShipVia.strTransporterLicense, 
					tblSMShipVia.strTransportationMode, 
					tblEMEntity.strName AS strTransporterName, 
					tblEMEntity.strFederalTaxId AS strTransporterFEIN,
					tblEMEntity.strName AS strConsignorName, 
					tblEMEntity.strFederalTaxId AS strConsignorFEIN, 
					NULL AS strTaxCode, 
					tblTFTerminalControlNumber.strTerminalControlNumber, 
					EntityAPVendor.strName AS strVendorName, 
					EntityAPVendor.strFederalTaxId AS strVendorFEIN, 
					tblSMCompanySetup.strCompanyName, 
					tblSMCompanySetup.strAddress, 
					tblSMCompanySetup.strCity, 
					tblSMCompanySetup.strState, 
					tblSMCompanySetup.strZip, 
					tblSMCompanySetup.strPhone, 
					tblSMCompanySetup.strStateTaxID, 
					tblSMCompanySetup.strFederalTaxID '

		SET @InvQueryPart2 = 'FROM tblTFTaxCategory INNER JOIN
					tblTFTaxCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFTaxCriteria.intTaxCategoryId INNER JOIN
					tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId RIGHT OUTER JOIN
					tblICInventoryTransferDetail INNER JOIN
					tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId INNER JOIN
					tblICItemMotorFuelTax INNER JOIN
					tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCode INNER JOIN
					tblTFReportingComponent ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON 
					tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId INNER JOIN
					tblTRLoadReceipt ON tblICInventoryTransfer.intInventoryTransferId = tblTRLoadReceipt.intInventoryTransferId INNER JOIN
					tblTRLoadHeader ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId INNER JOIN
					tblTRLoadDistributionHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId INNER JOIN
					tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityShipViaId INNER JOIN
					tblEMEntity ON tblSMShipVia.intEntityShipViaId = tblEMEntity.intEntityId INNER JOIN
					tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityVendorId INNER JOIN
					tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityVendorId = EntityAPVendor.intEntityId INNER JOIN
					tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId INNER JOIN
					tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId INNER JOIN
					tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId ON 
					tblTFTaxCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId LEFT OUTER JOIN
					tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId LEFT OUTER JOIN
					tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId CROSS JOIN
					tblSMCompanySetup
			WHERE (tblTFReportingComponent.intReportingComponentId IN (' + @RCId + ')) 
			AND (tblSMCompanyLocation.ysnTrackMFTActivity = 1)
			AND (tblARInvoice.strBOLNumber IS NULL)
			AND (tblTRLoadHeader.dtmLoadDateTime BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + ''')
			AND (tblICInventoryTransfer.ysnPosted = 1) ' + @Criteria + ''

			SET @InvTransferQuery = @InvQueryPart1 + @InvQueryPart2
			INSERT INTO TFInvoiceTransaction
			EXEC(@InvTransferQuery)

		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransactions (uniqTransactionGuid
				, intTaxAuthorityId
				, strTaxAuthority
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
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
				, strDestinationState
				, strOriginCity
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
				, strType
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
				, leaf)
			SELECT DISTINCT @Guid
				, intTaxAuthorityId
				, (SELECT strTaxAuthorityCode FROM tblTFTaxAuthority WHERE intTaxAuthorityId = (SELECT DISTINCT TOP 1 intTaxAuthorityId FROM TFInvoiceTransaction))
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, intProductCode
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
				, strDestinationState
				, strOriginCity
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
				, strType
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
				, 1
			FROM TFInvoiceTransaction
		END
		ELSE
		BEGIN
			INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, '', 0, 1)
		END

		SET @CountRC = @CountRC - 1
	END

	DECLARE @HasResult INT
	SELECT TOP 1 @HasResult = intId from TFInvoiceTransaction
	IF(@HasResult IS NULL AND @IsEdi = 'false')
	BEGIN
		INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)VALUES(@Guid, 0, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId), 0,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
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