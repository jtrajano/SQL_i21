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
				, strDestinationCounty
				, strDestinationState
				, strOriginCity
				, strOriginCounty
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
				, strHeaderFederalTaxID
			)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId, intProductCodeId DESC) AS intId
				, *
			FROM (
				SELECT DISTINCT NULL AS intInvoiceDetailId											
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, tblTFReportingComponent.strType
					, vyuTFGetReportingComponentProductCode.intProductCodeId
					, vyuTFGetReportingComponentProductCode.strProductCode
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
					, tblTRLoadHeader.dtmLoadDateTime AS dtmDate
					, tblSMCompanyLocation.strCity AS strDestinationCity
					, NULL AS strDestinationCounty
					, tblSMCompanyLocation.strStateProvince AS strDestinationState
					, tblEMEntityLocation.strCity AS strOriginCity
					, NULL AS strOriginCounty
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
				FROM tblTFTaxCategory
				INNER JOIN tblTFReportingComponentCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
				INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				RIGHT OUTER JOIN tblICInventoryTransferDetail
				INNER JOIN tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId
				INNER JOIN tblICItemMotorFuelTax
				INNER JOIN vyuTFGetReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId
				INNER JOIN tblTFReportingComponent ON vyuTFGetReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					ON tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId
				INNER JOIN tblTRLoadReceipt ON tblICInventoryTransfer.intInventoryTransferId = tblTRLoadReceipt.intInventoryTransferId
				INNER JOIN tblTRLoadHeader ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
				INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
				INNER JOIN tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityId
				INNER JOIN tblEMEntity ON tblSMShipVia.intEntityId = tblEMEntity.intEntityId
				INNER JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
				INNER JOIN tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityId = EntityAPVendor.intEntityId
				INNER JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId
				INNER JOIN tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId
				INNER JOIN tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
					ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				LEFT OUTER JOIN tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId
				LEFT OUTER JOIN tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId
				CROSS JOIN tblSMCompanySetup
				WHERE tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblSMCompanyLocation.ysnTrackMFTActivity = 1
					AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND tblICInventoryTransfer.ysnPosted = 1
					AND tblSMShipVia.ysnCompanyOwnedCarrier = 1
					AND strCriteria <> '= 0' AND strCriteria <> '<> 0'
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			)tblTransactions

			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, intProductCodeId
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
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFederalTaxId
				, strConsignorName
				, strConsignorFederalTaxId
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strCustomerName
				, strCustomerFederalTaxId
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
				, intIntegrationError)
			SELECT DISTINCT @Guid
				, RC.intReportingComponentId
				, VPC.intProductCodeId
				, IPC.strProductCode
				, NULL AS intItemId
				, TR.dblTransactionOutboundGrossGals AS dblQtyShipped
				, TR.dblTransactionOutboundGrossGals AS dblGross
				, TR.dblTransactionOutboundNetGals AS dblNet
				, TR.dblTransactionOutboundBilledGals AS dblQuantity
				, NULL AS dblTax
				, NULL AS dblTaxExempt
				, NULL AS strInvoiceNumber
				, NULL AS strPONumber
				, TR.strTransactionBillOfLading
				, CONVERT(NVARCHAR(50), TR.dtmTransactionDate)
				, TR.strCustomerCity AS strDestinationCity
				, TR.strCustomerState AS strDestinationState
				, TR.strVendorCity AS strOriginCity
				, TR.strVendorState AS strOriginState
				, TR.strCarrierTransportationMode AS strShipVia
				, TR.strCarrierLicenseNumber1 AS strTransporterLicense
				, TR.strCarrierTransportationMode AS strTransportationMode
				, TR.strCarrierName AS strTransporterName
				, TR.strCarrierFEIN AS strTransporterFEIN
				, TR.strCarrierName AS strConsignorName
				, TR.strCarrierFEIN AS strConsignorFEIN
				, TR.strVendorTerminalControlNumber AS strTerminalControlNumber
				, TR.strVendorName
				, TR.strVendorFEIN
				, TR.strCustomerName
				, TR.strCustomerTaxID1
				, SMCOMPSETUP.strCompanyName
				, SMCOMPSETUP.strAddress
				, SMCOMPSETUP.strCity
				, SMCOMPSETUP.strState
				, SMCOMPSETUP.strZip
				, SMCOMPSETUP.strPhone
				, SMCOMPSETUP.strStateTaxID
				, SMCOMPSETUP.strFederalTaxID
				, @DateFrom
				, @DateTo
				, (SELECT COUNT(*) FROM tblTFIntegrationError)
			FROM tblTFReportingComponentCriteria
			RIGHT OUTER JOIN vyuTFGetReportingComponentProductCode AS VPC
			INNER JOIN tblTFReportingComponent AS RC ON VPC.intReportingComponentId = RC.intReportingComponentId
			INNER JOIN tblTFIntegrationItemProductCode AS IPC ON VPC.strProductCode = IPC.strProductCode
			INNER JOIN tblTFIntegrationTransaction AS TR ON IPC.strItemNumber = TR.strItemNumber ON tblTFReportingComponentCriteria.intReportingComponentId = RC.intReportingComponentId
			CROSS JOIN tblSMCompanySetup AS SMCOMPSETUP
			WHERE RC.intReportingComponentId = @RCId
				AND TR.strSourceSystem NOT IN ('F')
				AND TR.strTransactionType IN ('T', 'O')
				AND TR.strCarrierCompanyOwnedIndicator = 'Y'
				AND strCriteria <> '= 0' AND strCriteria <> '<> 0'
				AND CAST(FLOOR(CAST(TR.dtmTransactionDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(TR.dtmTransactionDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR TR.strVendorState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR TR.strVendorState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR TR.strCustomerState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR TR.strCustomerState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
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
				, strDestinationCounty
				, strDestinationState
				, strOriginCity
				, strOriginCounty
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
				, strHeaderFederalTaxID
			)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId, intProductCodeId DESC) AS intId
				, *
			FROM (
				SELECT DISTINCT NULL AS intInvoiceDetailId											
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, tblTFReportingComponent.strType
					, vyuTFGetReportingComponentProductCode.intProductCodeId
					, vyuTFGetReportingComponentProductCode.strProductCode
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
					, tblTRLoadHeader.dtmLoadDateTime AS dtmDate
					, tblSMCompanyLocation.strCity AS strDestinationCity
					, NULL AS strDestinationCounty
					, tblSMCompanyLocation.strStateProvince AS strDestinationState
					, tblEMEntityLocation.strCity AS strOriginCity
					, NULL AS strOriginCounty
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
				FROM tblTFTaxCategory
				INNER JOIN tblTFReportingComponentCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
				INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				RIGHT OUTER JOIN tblICInventoryTransferDetail
				INNER JOIN tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId
				INNER JOIN tblICItemMotorFuelTax
				INNER JOIN vyuTFGetReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId
				INNER JOIN tblTFReportingComponent ON vyuTFGetReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					ON tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId
				INNER JOIN tblTRLoadReceipt ON tblICInventoryTransfer.intInventoryTransferId = tblTRLoadReceipt.intInventoryTransferId
				INNER JOIN tblTRLoadHeader ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
				INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
				INNER JOIN tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityId
				INNER JOIN tblEMEntity ON tblSMShipVia.intEntityId = tblEMEntity.intEntityId
				INNER JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
				INNER JOIN tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityId = EntityAPVendor.intEntityId
				INNER JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId
				INNER JOIN tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId
				INNER JOIN tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
					ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				LEFT OUTER JOIN tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId
				LEFT OUTER JOIN tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId
				CROSS JOIN tblSMCompanySetup
				WHERE tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblSMCompanyLocation.ysnTrackMFTActivity = 1
					AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND tblICInventoryTransfer.ysnPosted = 1
					AND tblSMShipVia.ysnCompanyOwnedCarrier = 1
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			)tblTransactions

			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, intProductCodeId
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
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFederalTaxId
				, strConsignorName
				, strConsignorFederalTaxId
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strCustomerName
				, strCustomerFederalTaxId
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
				, intIntegrationError)
			SELECT DISTINCT @Guid
				, RC.intReportingComponentId
				, VPC.intProductCodeId
				, IPC.strProductCode
				, NULL AS intItemId
				, TR.dblTransactionOutboundGrossGals AS dblQtyShipped
				, TR.dblTransactionOutboundGrossGals AS dblGross
				, TR.dblTransactionOutboundNetGals AS dblNet
				, TR.dblTransactionOutboundBilledGals AS dblQuantity
				, NULL AS dblTax
				, NULL AS dblTaxExempt
				, NULL AS strInvoiceNumber
				, NULL AS strPONumber
				, TR.strTransactionBillOfLading
				, CONVERT(NVARCHAR(50), TR.dtmTransactionDate)
				, TR.strCustomerCity AS strDestinationCity
				, TR.strCustomerState AS strDestinationState
				, TR.strVendorCity AS strOriginCity
				, TR.strVendorState AS strOriginState
				, TR.strCarrierTransportationMode AS strShipVia
				, TR.strCarrierLicenseNumber1 AS strTransporterLicense
				, TR.strCarrierTransportationMode AS strTransportationMode
				, TR.strCarrierName AS strTransporterName
				, TR.strCarrierFEIN AS strTransporterFEIN
				, TR.strCarrierName AS strConsignorName
				, TR.strCarrierFEIN AS strConsignorFEIN
				, TR.strVendorTerminalControlNumber AS strTerminalControlNumber
				, TR.strVendorName
				, TR.strVendorFEIN
				, TR.strCustomerName
				, TR.strCustomerTaxID1
				, SMCOMPSETUP.strCompanyName
				, SMCOMPSETUP.strAddress
				, SMCOMPSETUP.strCity
				, SMCOMPSETUP.strState
				, SMCOMPSETUP.strZip
				, SMCOMPSETUP.strPhone
				, SMCOMPSETUP.strStateTaxID
				, SMCOMPSETUP.strFederalTaxID
				, @DateFrom
				, @DateTo
				, (SELECT COUNT(*) FROM tblTFIntegrationError)
			FROM tblTFReportingComponentCriteria
			RIGHT OUTER JOIN vyuTFGetReportingComponentProductCode AS VPC
			INNER JOIN tblTFReportingComponent AS RC ON VPC.intReportingComponentId = RC.intReportingComponentId
			INNER JOIN tblTFIntegrationItemProductCode AS IPC ON VPC.strProductCode = IPC.strProductCode
			INNER JOIN tblTFIntegrationTransaction AS TR ON IPC.strItemNumber = TR.strItemNumber ON tblTFReportingComponentCriteria.intReportingComponentId = RC.intReportingComponentId
			CROSS JOIN tblSMCompanySetup AS SMCOMPSETUP
			WHERE RC.intReportingComponentId = @RCId
				AND TR.strSourceSystem NOT IN ('F')
				AND TR.strTransactionType IN ('T', 'O')
				AND TR.strCarrierCompanyOwnedIndicator = 'Y'
				AND CAST(FLOOR(CAST(TR.dtmTransactionDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(TR.dtmTransactionDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR TR.strVendorState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR TR.strVendorState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR TR.strCustomerState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR TR.strCustomerState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
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
				, dtmReportingPeriodEnd)
			SELECT DISTINCT @Guid
				, intReportingComponentId
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
			FROM @tmpInvoiceTransaction
		END

		DELETE FROM #tmpRC WHERE intReportingComponentId = @RCId
	END

	IF(NOT EXISTS (SELECT TOP 1 1 FROM @tmpInvoiceTransaction WHERE intReportingComponentId = @Guid) AND @IsEdi = 0)
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