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

	DECLARE @CountRC INT
	DECLARE @InvoiceDetailId NVARCHAR(50)
	
	DECLARE @TaxCodeId NVARCHAR(10)
	DECLARE @TaxCriteria NVARCHAR(10)
	DECLARE @RCId INT

	DECLARE @tmpInvoiceDetail TFInvoiceDetail
	DECLARE @tmpInvoiceTransaction TFInvoiceTransaction

	DECLARE @tblTempInvoiceDetail TABLE (
		intId INT IDENTITY(1,1),
		intInvoiceDetailId INT)

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
	END
	DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'
		
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
		SELECT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, strInvoiceNumber DESC) AS intId
			, intInvoiceDetailId
			, strInvoiceNumber
		FROM (
			SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId
				, tblARInvoice.strInvoiceNumber
			FROM tblARInvoiceDetail 
			INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
			INNER JOIN tblARCustomer Customer ON Customer.intEntityCustomerId = tblARInvoice.intEntityCustomerId
			INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
			INNER JOIN tblICItemMotorFuelTax ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
			INNER JOIN tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			INNER JOIN tblTFReportingComponent ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblTFTaxCategory ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId AND tblARInvoiceDetailTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId
			INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
			LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = Customer.intAccountStatusId
			LEFT JOIN tblARAccountStatus AccountStatus ON tblARAccountStatus.intAccountStatusId = AccountStatus.intAccountStatusId
			WHERE tblARInvoice.ysnPosted = 1
				AND tblTFReportingComponent.intReportingComponentId = @RCId
				AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR Customer.intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR Customer.intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR AccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR AccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
		)tblTransactions
			
		
		IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId)
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
				, dblTaxExempt
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
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId, intProductCodeId DESC) AS intId
				, *
			FROM (
				SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId
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
					, NULL AS dblTaxExempt
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
					, Transporter.strName AS strTransporterName
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, NULL AS strConsignorName
					, NULL AS strConsignorFEIN
					, NULL AS strTerminalControlNumber
					, NULL AS strVendorName
					, NULL AS strVendorFederalTaxId
					, tblSMCompanySetup.strCompanyName
					, tblSMCompanySetup.strAddress
					, tblSMCompanySetup.strCity
					, tblSMCompanySetup.strState
					, tblSMCompanySetup.strZip
					, tblSMCompanySetup.strPhone
					, tblSMCompanySetup.strStateTaxID
					, tblSMCompanySetup.strFederalTaxID
				FROM tblEMEntity AS Transporter
				INNER JOIN tblSMShipVia ON Transporter.intEntityId = tblSMShipVia.intEntityShipViaId
				INNER JOIN tblARInvoice ON tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId
				INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
				INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
				INNER JOIN tblICItemMotorFuelTax ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
				INNER JOIN vyuTFGetReportingComponentProductCode RCProductCode ON tblICItemMotorFuelTax.intProductCodeId = RCProductCode.intProductCodeId
				INNER JOIN tblTFReportingComponent ON RCProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblTFTaxCategory ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
				INNER JOIN tblSMTaxCode ON tblARInvoiceDetailTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId AND tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
				INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId
				INNER JOIN tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId 
				LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = tblARCustomer.intAccountStatusId
				CROSS JOIN tblSMCompanySetup
				WHERE tblARInvoice.ysnPosted = 1 
					AND tblTFReportingComponent.intReportingComponentId = @RCId
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR tblARCustomer.intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomer.intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
			)tblTransactions
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
				, dblTaxExempt
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
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId, intProductCodeId DESC) AS intId
				, *
			FROM (
				SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId
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
					, NULL AS dblTaxExempt
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
					, NULL AS strConsignorName
					, NULL AS strConsignorFEIN
					, NULL AS strTerminalControlNumber
					, NULL AS strVendorName
					, NULL AS strVendorFederalTaxId
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
				INNER JOIN tblARInvoice ON tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId
				INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
				INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId			
				FULL OUTER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intItemId = tblARInvoiceDetail.intItemId
				INNER JOIN vyuTFGetReportingComponentProductCode RCProductCode ON tblICItemMotorFuelTax.intProductCodeId = RCProductCode.intProductCodeId
				INNER JOIN tblTFReportingComponent ON RCProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
				INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
				INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
				INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId
				INNER JOIN tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId
				LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = tblARCustomer.intAccountStatusId
				CROSS JOIN tblSMCompanySetup
				WHERE tblARInvoice.ysnPosted = 1
					AND tblTFReportingComponent.intReportingComponentId = @RCId
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR tblARCustomer.intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomer.intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
			)tblTransactions
		END
	
		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInvoiceDetail) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN
			-- RETRIEVE TAX CATEGORY BASED ON RECEIPT ITEM ID/S
			SELECT DISTINCT tblSMTaxCode.intTaxCodeId
				, tblTFReportingComponentCriteria.strCriteria
			INTO #tmpTaxCategory
			FROM tblSMTaxCode
			INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblTFReportingComponentCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
			WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId

			SELECT TOP 1 @InvoiceDetailId = intInvoiceDetailId FROM @tmpInvoiceDetail
			
			WHILE EXISTS (SELECT TOP 1 1 FROM #tmpTaxCategory) -- LOOP ON TAX CATEGORY
			BEGIN
				SELECT TOP 1 @TaxCodeId = intTaxCodeId, @TaxCriteria = strCriteria FROM #tmpTaxCategory
				DECLARE @QueryrInvoiceDetailId NVARCHAR(MAX)
				SET @QueryrInvoiceDetailId =  'SELECT DISTINCT tblARInvoiceDetailTax.intInvoiceDetailId
													FROM  tblARInvoiceDetail INNER JOIN
														tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
														WHERE tblARInvoiceDetailTax.intInvoiceDetailId IN(''' + @InvoiceDetailId + ''')
														AND (tblARInvoiceDetailTax.intTaxCodeId = ''' + @TaxCodeId + ''')
														AND (tblARInvoiceDetailTax.dblTax ' + @TaxCriteria + ')'

				DELETE FROM @tblTempInvoiceDetail
				INSERT INTO @tblTempInvoiceDetail
				EXEC(@QueryrInvoiceDetailId)
	
				IF NOT EXISTS (SELECT TOP 1 1 FROM @tblTempInvoiceDetail) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
				BEGIN
					DELETE FROM @tmpInvoiceTransaction WHERE intInvoiceDetailId = @InvoiceDetailId								 
					BREAK
				END				
				DELETE FROM #tmpTaxCategory WHERE intTaxCodeId = @TaxCodeId AND strCriteria = @TaxCriteria
			END								 
			DELETE FROM @tmpInvoiceDetail WHERE intInvoiceDetailId = @InvoiceDetailId

			DROP TABLE #tmpTaxCategory
		END
				
		--INVENTORY TRANSFER
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
				, dblTaxExempt
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
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intTaxAuthorityId, intProductCodeId DESC) AS intId
				, *
			FROM (
				SELECT DISTINCT NULL AS intInvoiceDetailId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, tblTFReportingComponent.strType
					, RCProductCode.intProductCodeId
					, RCProductCode.strProductCode
					, tblICInventoryTransferDetail.intItemId
					, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
					, tblICInventoryReceiptItem.dblGross
					, tblICInventoryReceiptItem.dblNet
					, tblICInventoryTransferDetail.dblQuantity
					, NULL AS dblTax
					, NULL AS dblTaxExempt
					, NULL AS strInvoiceNumber
					, NULL AS strPONumber
					, tblTRLoadReceipt.strBillOfLading AS strBOLNumber
					, tblTRLoadHeader.dtmLoadDateTime AS dtmDate
					, tblSMCompanyLocation.strCity AS strDestinationCity
					, tblSMCompanyLocation.strStateProvince AS strDestinationState
					, tblEMEntityLocation.strCity AS strOriginCity
					, tblEMEntityLocation.strState AS strOriginState
					, tblSMCompanyLocation.strLocationName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFEIN
					, NULL AS strAccountStatusCode
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMShipVia.strTransportationMode
					, tblEMEntity.strName AS strTransporterName
					, tblEMEntity.strFederalTaxId AS strTransporterFEIN
					, tblEMEntity.strName AS strConsignorName
					, tblEMEntity.strFederalTaxId AS strConsignorFEIN
					--, tblTFTaxCategory.strTaxCategory
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
					, tblSMCompanySetup.strFederalTaxID
				FROM  tblICInventoryReceipt 
				INNER JOIN tblICInventoryReceiptItem ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
				RIGHT OUTER JOIN tblICInventoryTransferDetail 
				INNER JOIN tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId 
				INNER JOIN tblICItemMotorFuelTax 
				INNER JOIN vyuTFGetReportingComponentProductCode AS RCProductCode ON tblICItemMotorFuelTax.intProductCodeId = RCProductCode.intProductCodeId 
				INNER JOIN tblTFReportingComponent ON RCProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId 
					ON  tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId 
				INNER JOIN tblTRLoadReceipt ON tblICInventoryTransfer.intInventoryTransferId = tblTRLoadReceipt.intInventoryTransferId 
				INNER JOIN tblTRLoadHeader ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId 
				INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId 
				INNER JOIN tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityShipViaId 
				INNER JOIN tblEMEntity ON tblSMShipVia.intEntityShipViaId = tblEMEntity.intEntityId 
				INNER JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityVendorId 
				INNER JOIN tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityVendorId = EntityAPVendor.intEntityId 
				INNER JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
				INNER JOIN tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId 
				INNER JOIN tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId 
					ON tblICInventoryReceipt.intInventoryReceiptId = tblTRLoadReceipt.intInventoryReceiptId 
				LEFT OUTER JOIN tblTFTaxCategory 
				INNER JOIN tblTFReportingComponentCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId 
				INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId 
					ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentCriteria.intReportingComponentId 
				LEFT OUTER JOIN tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId 
				LEFT OUTER JOIN tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId 
				LEFT OUTER JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARInvoice.intEntityCustomerId 
				LEFT OUTER JOIN tblARAccountStatus AS AccountStatus ON tblARCustomerAccountStatus.intAccountStatusId = AccountStatus.intAccountStatusId 
				CROSS JOIN tblSMCompanySetup
				WHERE tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblSMCompanyLocation.ysnTrackMFTActivity = 1
					AND ISNULL(tblARInvoice.strBOLNumber, '') = ''
					AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND tblICInventoryTransfer.ysnPosted = 1
					AND (tblARInvoice.intEntityCustomerId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId)
						OR NOT EXISTS (SELECT TOP 1 1 FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId))
					AND (tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId)
						OR NOT EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId))
					
			)tblTransactions
		
		IF (@ReportingComponentId <> '')
		BEGIN
			DECLARE @TaxAuthorityCode NVARCHAR(100)
			SELECT TOP 1 @TaxAuthorityCode = strTaxAuthorityCode FROM tblTFTaxAuthority
			WHERE intTaxAuthorityId = (SELECT DISTINCT TOP 1 intTaxAuthorityId FROM @tmpInvoiceTransaction)

			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intTaxAuthorityId
				, strTaxAuthority
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
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
				, leaf)
			SELECT DISTINCT @Guid
				, intTaxAuthorityId
				, @TaxAuthorityCode
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
				, 1
			FROM @tmpInvoiceTransaction
		END
		ELSE
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, '', 0, 1)
		END
		DELETE FROM @tmpInvoiceTransaction
		DELETE FROM #tmpRC WHERE intReportingComponentId = @RCId
	END

	IF(NOT EXISTS (SELECT TOP 1 1 FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid) AND @IsEdi = 0)
	BEGIN
		INSERT INTO tblTFTransaction (uniqTransactionGuid
			, strFormCode
			, strProductCode
			, dtmDate
			, dtmReportingPeriodBegin
			, dtmReportingPeriodEnd
			, leaf)
		VALUES (@Guid
			, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId)
			, 'No record found.'
			, GETDATE()
			, @DateFrom
			, @DateTo
			, 1)
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