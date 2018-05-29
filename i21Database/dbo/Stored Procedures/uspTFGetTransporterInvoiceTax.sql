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
--===================================================== i21 INVENTORY TRANSFER =====================================================

	DECLARE @CountRC INT
	DECLARE @QueryRC NVARCHAR(MAX)
	DECLARE @RCId NVARCHAR(50)

	DECLARE @tblTempReportingComponent TABLE (
		intId INT IDENTITY(1,1)
		, intReportingComponentId INT)
		
	DECLARE @tmpInvoiceTransaction TFInvoiceTransaction

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction
	END

	DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'

	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE #tmpRC where intReportingComponentId = ''
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC
		
		--INVENTORY TRANSFER
		IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponent
					INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentCriteria.intReportingComponentId
					WHERE tblTFReportingComponent.intReportingComponentId = @RCId
						AND tblTFReportingComponentCriteria.strCriteria = '= 0')
		BEGIN
			INSERT INTO @tmpInvoiceTransaction(intId
				, intInvoiceDetailId
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
				, strCustomerFEIN
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
			)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId) AS intId, *
			FROM (SELECT DISTINCT NULL AS intInvoiceDetailId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, tblTFReportingComponent.strType
					, tblICInventoryTransferDetail.intItemId
					, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
					, tblICInventoryTransferDetail.dblQuantity AS dblNet
					, tblICInventoryTransferDetail.dblQuantity AS dblGross
					, tblICInventoryTransferDetail.dblQuantity AS dblBillQty
					, NULL AS dblTax
					, NULL AS dblTaxExempt
					, tblARInvoice.strInvoiceNumber
					, tblARInvoice.strPONumber
					, tblARInvoice.strBOLNumber
					, tblARInvoice.dtmDate
					, tblARInvoice.strShipToCity AS strDestinationCity
					, DestinationCounty.strCounty AS strDestinationCounty
					, tblARInvoice.strShipToState AS strDestinationState
					, tblSMCompanyLocation.strCity AS strOriginCity
					, NULL AS strOriginCounty
					, tblSMCompanyLocation.strStateProvince AS strOriginState
					, tblEMEntity.strName
					, tblEMEntity.strFederalTaxId AS strCustomerFEIN
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, Transporter.strName AS strTransporterName
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, Transporter.strName AS strConsignorName
					, Transporter.strFederalTaxId AS strConsignorFEIN
					, tblTFTerminalControlNumber.strTerminalControlNumber AS strTerminalControlNumber
					, tblSMCompanySetup.strCompanyName AS strVendorName
					, tblSMCompanySetup.strEin AS strVendorFederalTaxId
					, tblSMCompanySetup.strCompanyName
					, tblSMCompanySetup.strAddress
					, tblSMCompanySetup.strCity
					, tblSMCompanySetup.strState
					, tblSMCompanySetup.strZip
					, tblSMCompanySetup.strPhone
					, tblSMCompanySetup.strStateTaxID
					, tblSMCompanySetup.strEin
				FROM tblTFReportingComponent
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
					INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICInventoryTransferDetail ON tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId
				INNER JOIN tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId
					INNER JOIN tblTRLoadReceipt ON tblICInventoryTransfer.intInventoryTransferId = tblTRLoadReceipt.intInventoryTransferId
						LEFT JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
						LEFT JOIN tblEMEntity AS EntityAPVendor ON EntityAPVendor.intEntityId = tblAPVendor.intEntityId 
						LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intSupplyPointId = tblTRLoadReceipt.intSupplyPointId
							LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
						LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblTRSupplyPoint.intEntityLocationId 
							LEFT JOIN tblSMTaxCode AS DestinationCounty ON DestinationCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
					INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId 
						LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblTRLoadHeader.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
						LEFT JOIN tblSMTransportationMode ON tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
					INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
						LEFT JOIN tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
						LEFT JOIN tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId
							LEFT JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
								LEFT JOIN tblEMEntity ON tblEMEntity.intEntityId = tblARCustomer.intEntityId
								LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
								LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId				
				CROSS JOIN tblSMCompanySetup
				WHERE tblTFReportingComponent.intReportingComponentId = @RCId
				AND tblSMCompanyLocation.ysnTrackMFTActivity = 1
				AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			    AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0

			)tblTransactions

			--INSERT INTO tblTFTransaction (uniqTransactionGuid
			--	, intReportingComponentId
			--	, intProductCodeId
			--	, strProductCode
			--	, intItemId
			--	, dblQtyShipped
			--	, dblGross
			--	, dblNet
			--	, dblBillQty
			--	, dblTax
			--	, dblTaxExempt
			--	, strInvoiceNumber
			--	, strPONumber
			--	, strBillOfLading
			--	, dtmDate
			--	, strDestinationCity
			--	, strDestinationState
			--	, strOriginCity
			--	, strOriginState
			--	, strShipVia
			--	, strTransporterLicense
			--	, strTransportationMode
			--	, strTransporterName
			--	, strTransporterFederalTaxId
			--	, strConsignorName
			--	, strConsignorFederalTaxId
			--	, strTerminalControlNumber
			--	, strVendorName
			--	, strVendorFederalTaxId
			--	, strCustomerName
			--	, strCustomerFederalTaxId
			--	, strTaxPayerName
			--	, strTaxPayerAddress
			--	, strCity
			--	, strState
			--	, strZipCode
			--	, strTelephoneNumber
			--	, strTaxPayerIdentificationNumber
			--	, strTaxPayerFEIN
			--	, dtmReportingPeriodBegin
			--	, dtmReportingPeriodEnd
			--	, intIntegrationError)
			--SELECT DISTINCT @Guid
			--	, RC.intReportingComponentId
			--	, VPC.intProductCodeId
			--	, IPC.strProductCode
			--	, NULL AS intItemId
			--	, TR.dblTransactionOutboundGrossGals AS dblQtyShipped
			--	, TR.dblTransactionOutboundGrossGals AS dblGross
			--	, TR.dblTransactionOutboundNetGals AS dblNet
			--	, TR.dblTransactionOutboundBilledGals AS dblQuantity
			--	, NULL AS dblTax
			--	, NULL AS dblTaxExempt
			--	, NULL AS strInvoiceNumber
			--	, NULL AS strPONumber
			--	, TR.strTransactionBillOfLading
			--	, CONVERT(NVARCHAR(50), TR.dtmTransactionDate)
			--	, TR.strCustomerCity AS strDestinationCity
			--	, TR.strCustomerState AS strDestinationState
			--	, TR.strVendorCity AS strOriginCity
			--	, TR.strVendorState AS strOriginState
			--	, TR.strCarrierTransportationMode AS strShipVia
			--	, TR.strCarrierLicenseNumber1 AS strTransporterLicense
			--	, TR.strCarrierTransportationMode AS strTransportationMode
			--	, TR.strCarrierName AS strTransporterName
			--	, TR.strCarrierFEIN AS strTransporterFEIN
			--	, TR.strCarrierName AS strConsignorName
			--	, TR.strCarrierFEIN AS strConsignorFEIN
			--	, TR.strVendorTerminalControlNumber AS strTerminalControlNumber
			--	, TR.strVendorName
			--	, TR.strVendorFEIN
			--	, TR.strCustomerName
			--	, TR.strCustomerTaxID1
			--	, SMCOMPSETUP.strCompanyName
			--	, SMCOMPSETUP.strAddress
			--	, SMCOMPSETUP.strCity
			--	, SMCOMPSETUP.strState
			--	, SMCOMPSETUP.strZip
			--	, SMCOMPSETUP.strPhone
			--	, SMCOMPSETUP.strStateTaxID
			--	, SMCOMPSETUP.strFederalTaxID
			--	, @DateFrom
			--	, @DateTo
			--	, (SELECT COUNT(*) FROM tblTFIntegrationError)
			--FROM tblTFReportingComponentCriteria
			--RIGHT OUTER JOIN vyuTFGetReportingComponentProductCode AS VPC
			--INNER JOIN tblTFReportingComponent AS RC ON VPC.intReportingComponentId = RC.intReportingComponentId
			--INNER JOIN tblTFIntegrationItemProductCode AS IPC ON VPC.strProductCode = IPC.strProductCode
			--INNER JOIN tblTFIntegrationTransaction AS TR ON IPC.strItemNumber = TR.strItemNumber ON tblTFReportingComponentCriteria.intReportingComponentId = RC.intReportingComponentId
			--CROSS JOIN tblSMCompanySetup AS SMCOMPSETUP
			--WHERE RC.intReportingComponentId = @RCId
			--	AND TR.strSourceSystem NOT IN ('F')
			--	AND TR.strTransactionType IN ('T', 'O')
			--	AND TR.strCarrierCompanyOwnedIndicator = 'Y'
			--	AND strCriteria <> '= 0' AND strCriteria <> '<> 0'
			--	AND CAST(FLOOR(CAST(TR.dtmTransactionDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			--	AND CAST(FLOOR(CAST(TR.dtmTransactionDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			--	AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
			--		OR TR.strVendorState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			--	AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
			--		OR TR.strVendorState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			--	AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
			--		OR TR.strCustomerState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			--	AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
			--		OR TR.strCustomerState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
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
			)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId) AS intId, *
			FROM (SELECT DISTINCT NULL AS intInvoiceDetailId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, tblTFReportingComponent.strType
					, tblICInventoryTransferDetail.intItemId
					, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
					, tblICInventoryTransferDetail.dblQuantity AS dblNet
					, tblICInventoryTransferDetail.dblQuantity AS dblGross
					, tblICInventoryTransferDetail.dblQuantity AS dblBillQty
					, NULL AS dblTax
					, NULL AS dblTaxExempt
					, tblARInvoice.strInvoiceNumber
					, tblARInvoice.strPONumber
					, tblARInvoice.strBOLNumber
					, tblARInvoice.dtmDate
					, tblARInvoice.strShipToCity AS strDestinationCity
					, DestinationCounty.strCounty AS strDestinationCounty
					, tblARInvoice.strShipToState AS strDestinationState
					, tblSMCompanyLocation.strCity AS strOriginCity
					, NULL AS strOriginCounty
					, tblSMCompanyLocation.strStateProvince AS strOriginState
					, tblEMEntity.strName
					, tblEMEntity.strFederalTaxId AS strCustomerFEIN
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, Transporter.strName AS strTransporterName
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, Transporter.strName AS strConsignorName
					, Transporter.strFederalTaxId AS strConsignorFEIN
					, tblTFTerminalControlNumber.strTerminalControlNumber AS strTerminalControlNumber
					, tblSMCompanySetup.strCompanyName AS strVendorName
					, tblSMCompanySetup.strEin AS strVendorFederalTaxId
					, tblSMCompanySetup.strCompanyName
					, tblSMCompanySetup.strAddress
					, tblSMCompanySetup.strCity
					, tblSMCompanySetup.strState
					, tblSMCompanySetup.strZip
					, tblSMCompanySetup.strPhone
					, tblSMCompanySetup.strStateTaxID
					, tblSMCompanySetup.strEin
				FROM tblTFReportingComponent
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
					INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblICInventoryTransferDetail ON tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId
				INNER JOIN tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId
					INNER JOIN tblTRLoadReceipt ON tblICInventoryTransfer.intInventoryTransferId = tblTRLoadReceipt.intInventoryTransferId
						LEFT JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
						LEFT JOIN tblEMEntity AS EntityAPVendor ON EntityAPVendor.intEntityId = tblAPVendor.intEntityId 
						LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intSupplyPointId = tblTRLoadReceipt.intSupplyPointId
							LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
						LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblTRSupplyPoint.intEntityLocationId 
							LEFT JOIN tblSMTaxCode AS DestinationCounty ON DestinationCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
					INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId 
						LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblTRLoadHeader.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
						LEFT JOIN tblSMTransportationMode ON tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
					INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
						LEFT JOIN tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
						LEFT JOIN tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId
							LEFT JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
								LEFT JOIN tblEMEntity ON tblEMEntity.intEntityId = tblARCustomer.intEntityId
								LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
								LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId				
				CROSS JOIN tblSMCompanySetup
				WHERE tblTFReportingComponent.intReportingComponentId = @RCId
				AND tblSMCompanyLocation.ysnTrackMFTActivity = 1
				AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			    AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0

			)tblTransactions

			--INSERT INTO tblTFTransaction (uniqTransactionGuid
			--	, intReportingComponentId
			--	, intProductCodeId
			--	, strProductCode
			--	, intItemId
			--	, dblQtyShipped
			--	, dblGross
			--	, dblNet
			--	, dblBillQty
			--	, dblTax
			--	, dblTaxExempt
			--	, strInvoiceNumber
			--	, strPONumber
			--	, strBillOfLading
			--	, dtmDate
			--	, strDestinationCity
			--	, strDestinationState
			--	, strOriginCity
			--	, strOriginState
			--	, strShipVia
			--	, strTransporterLicense
			--	, strTransportationMode
			--	, strTransporterName
			--	, strTransporterFederalTaxId
			--	, strConsignorName
			--	, strConsignorFederalTaxId
			--	, strTerminalControlNumber
			--	, strVendorName
			--	, strVendorFederalTaxId
			--	, strCustomerName
			--	, strCustomerFederalTaxId
			--	, strTaxPayerName
			--	, strTaxPayerAddress
			--	, strCity
			--	, strState
			--	, strZipCode
			--	, strTelephoneNumber
			--	, strTaxPayerIdentificationNumber
			--	, strTaxPayerFEIN
			--	, dtmReportingPeriodBegin
			--	, dtmReportingPeriodEnd
			--	, intIntegrationError)
			--SELECT DISTINCT @Guid
			--	, RC.intReportingComponentId
			--	, VPC.intProductCodeId
			--	, IPC.strProductCode
			--	, NULL AS intItemId
			--	, TR.dblTransactionOutboundGrossGals AS dblQtyShipped
			--	, TR.dblTransactionOutboundGrossGals AS dblGross
			--	, TR.dblTransactionOutboundNetGals AS dblNet
			--	, TR.dblTransactionOutboundBilledGals AS dblQuantity
			--	, NULL AS dblTax
			--	, NULL AS dblTaxExempt
			--	, NULL AS strInvoiceNumber
			--	, NULL AS strPONumber
			--	, TR.strTransactionBillOfLading
			--	, CONVERT(NVARCHAR(50), TR.dtmTransactionDate)
			--	, TR.strCustomerCity AS strDestinationCity
			--	, TR.strCustomerState AS strDestinationState
			--	, TR.strVendorCity AS strOriginCity
			--	, TR.strVendorState AS strOriginState
			--	, TR.strCarrierTransportationMode AS strShipVia
			--	, TR.strCarrierLicenseNumber1 AS strTransporterLicense
			--	, TR.strCarrierTransportationMode AS strTransportationMode
			--	, TR.strCarrierName AS strTransporterName
			--	, TR.strCarrierFEIN AS strTransporterFEIN
			--	, TR.strCarrierName AS strConsignorName
			--	, TR.strCarrierFEIN AS strConsignorFEIN
			--	, TR.strVendorTerminalControlNumber AS strTerminalControlNumber
			--	, TR.strVendorName
			--	, TR.strVendorFEIN
			--	, TR.strCustomerName
			--	, TR.strCustomerTaxID1
			--	, SMCOMPSETUP.strCompanyName
			--	, SMCOMPSETUP.strAddress
			--	, SMCOMPSETUP.strCity
			--	, SMCOMPSETUP.strState
			--	, SMCOMPSETUP.strZip
			--	, SMCOMPSETUP.strPhone
			--	, SMCOMPSETUP.strStateTaxID
			--	, SMCOMPSETUP.strFederalTaxID
			--	, @DateFrom
			--	, @DateTo
			--	, (SELECT COUNT(*) FROM tblTFIntegrationError)
			--FROM tblTFReportingComponentCriteria
			--RIGHT OUTER JOIN vyuTFGetReportingComponentProductCode AS VPC
			--INNER JOIN tblTFReportingComponent AS RC ON VPC.intReportingComponentId = RC.intReportingComponentId
			--INNER JOIN tblTFIntegrationItemProductCode AS IPC ON VPC.strProductCode = IPC.strProductCode
			--INNER JOIN tblTFIntegrationTransaction AS TR ON IPC.strItemNumber = TR.strItemNumber ON tblTFReportingComponentCriteria.intReportingComponentId = RC.intReportingComponentId
			--CROSS JOIN tblSMCompanySetup AS SMCOMPSETUP
			--WHERE RC.intReportingComponentId = @RCId
			--	AND TR.strSourceSystem NOT IN ('F')
			--	AND TR.strTransactionType IN ('T', 'O')
			--	AND TR.strCarrierCompanyOwnedIndicator = 'Y'
			--	AND CAST(FLOOR(CAST(TR.dtmTransactionDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			--	AND CAST(FLOOR(CAST(TR.dtmTransactionDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			--	AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
			--		OR TR.strVendorState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			--	AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
			--		OR TR.strVendorState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			--	AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
			--		OR TR.strCustomerState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			--	AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
			--		OR TR.strCustomerState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
		END

		
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

		DELETE FROM #tmpRC WHERE intReportingComponentId = @RCId
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