CREATE PROCEDURE [dbo].[uspTFGetTransporterBulkInvoiceTax]
	@Guid NVARCHAR(50),
	@ReportingComponentId NVARCHAR(MAX),
	@DateFrom DATETIME,
	@DateTo DATETIME,
	@IsEdi BIT,
	@Refresh BIT,
	@IsTransporter BIT = 0
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

		IF  NOT EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND LTRIM(RTRIM(strCriteria)) = '<> 0') OR (ISNULL(@IsTransporter,0) = 1)
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
				, strEmail
				, strImportVerificationNumber
				, strConsignorName
				, strConsignorFederalTaxId
				, strOriginFacilityNumber
				, strDestinationFacilityNumber)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intLoadDistributionDetailId, intTaxAuthorityId DESC) AS intId, *
			FROM (SELECT DISTINCT tblTRLoadDistributionDetail.intLoadDistributionDetailId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, strType = tblTFReportingComponent.strType
					, tblTRLoadDistributionDetail.intItemId
					, tblTRLoadReceipt.strBillOfLading
					, tblTRLoadDistributionDetail.dblUnits AS dblReceived
					, tblTRLoadDistributionDetail.dblUnits AS dblGross
					, tblTRLoadDistributionDetail.dblUnits AS dblNet
					, tblTRLoadDistributionDetail.dblUnits AS dblBillQty
					, tblTRLoadHeader.dtmLoadDateTime
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN Vendor.strName ELSE tblTFCompanyPreference.strCompanyName END AS strVendorName
					, Transporter.strName AS strTransporterName
					, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN Vendor.strFederalTaxId ELSE tblSMCompanySetup.strEin END AS strVendorFederalTaxId
					, Transporter.strFederalTaxId AS strTransporterFederalTaxId
					, tblTFCompanyPreference.strCompanyName
					, tblTFCompanyPreference.strTaxAddress
					, tblTFCompanyPreference.strCity
					, tblTFCompanyPreference.strState
					, tblTFCompanyPreference.strZipCode
					, tblTFCompanyPreference.strContactPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxId = tblSMCompanySetup.strEin
					, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strState ELSE OriginBulkLoc.strStateProvince END AS strOriginState
					, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strCity ELSE OriginBulkLoc.strCity END AS strOriginCity
					, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strCountry ELSE OriginBulkLoc.strCountry END AS strOriginCounty
					, DestinationLoc.strStateProvince strDestinationState
					, DestinationLoc.strCity strDestinationCity
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
					, intTransactionNumberId = tblTRLoadDistributionDetail.intLoadDistributionDetailId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
					, strImportVerificationNumber = tblTRLoadHeader.strImportVerificationNumber
					, Seller.str1099Name
					, Seller.strFederalTaxId
					, strOriginFacilityNumber = CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strOregonFacilityNumber ELSE OriginBulkLoc.strOregonFacilityNumber END
					, strDestinationFacilityNumber = DestinationLoc.strOregonFacilityNumber
				FROM tblTFReportingComponent 
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFProductCode.intProductCodeId					
				INNER JOIN tblTRLoadDistributionDetail ON tblTRLoadDistributionDetail.intItemId = tblICItemMotorFuelTax.intItemId			
				INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblTRLoadDistributionDetail.intLoadDistributionHeaderId 
					LEFT JOIN tblSMCompanyLocation DestinationLoc ON DestinationLoc.intCompanyLocationId = tblTRLoadDistributionHeader.intCompanyLocationId	
				INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
					LEFT JOIN tblEMEntity AS Seller ON Seller.intEntityId = tblTRLoadHeader.intSellerId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblTRLoadHeader.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId 
						LEFT JOIN tblSMTransportationMode ON tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
				INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND tblTRLoadReceipt.intItemId = tblTRLoadDistributionDetail.intItemId AND tblTRLoadReceipt.strReceiptLine = tblTRLoadDistributionDetail.strReceiptLink --AND tblTRLoadReceipt.intItemId = tblICInventoryReceiptItem.intItemId
					LEFT JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblTRLoadReceipt.intTerminalId
					LEFT JOIN tblSMCompanyLocation OriginBulkLoc ON OriginBulkLoc.intCompanyLocationId = tblTRLoadReceipt.intCompanyLocationId	
					LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intSupplyPointId = tblTRLoadReceipt.intSupplyPointId 
						LEFT JOIN tblEMEntityLocation SupplyPointLoc ON SupplyPointLoc.intEntityLocationId = tblTRSupplyPoint.intEntityLocationId
						LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE  tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblTRLoadHeader.ysnPosted = 1
					AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)				
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((tblTRLoadReceipt.strOrigin = 'Terminal' AND SupplyPointLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblTRLoadReceipt.strOrigin != 'Terminal' AND OriginBulkLoc.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblTRLoadReceipt.strOrigin = 'Terminal' AND SupplyPointLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblTRLoadReceipt.strOrigin != 'Terminal' AND OriginBulkLoc.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)					
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((tblTRLoadDistributionHeader.strDestination = 'Location' AND DestinationLoc.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblTRLoadDistributionHeader.strDestination = 'Location' AND DestinationLoc.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR ISNULL(Vendor.intEntityId, 0) NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))	
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0)		
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0)
					AND (tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Location'
						OR tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Location' )
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Transporter.intEntityId IN (SELECT intEntityId FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Transporter.intEntityId NOT IN (SELECT intEntityId FROM tblTFReportingComponentCarrier WHERE intReportingComponentId = @RCId AND ysnInclude = 0))	
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
	


				-- IF Transporter.. receipt side only
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		IF (ISNULL(@IsTransporter,0) = 1) -- IF Transporter.. receipt side only
		BEGIN
			-- TAX CRITERIA
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId))
			BEGIN

				-- TRANSACTION WITHOUT TAX CODE    
				IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND LTRIM(RTRIM(strCriteria)) = '<> 0'))    
				BEGIN   
				
					DELETE @tmpTransaction 
					WHERE intTransactionDetailId IN (	SELECT DISTINCT InventoryTran.intTransactionDetailId     
														FROM @tmpTransaction InventoryTran    

														INNER JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionDetailId = InventoryTran.intTransactionDetailId
														INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
														INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
														--INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND tblTRLoadReceipt.intItemId = DD.intItemId
														INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND tblTRLoadReceipt.intItemId = DD.intItemId AND tblTRLoadReceipt.strReceiptLine = DD.strReceiptLink 

														INNER JOIN tblICInventoryReceipt ON tblTRLoadReceipt.intInventoryReceiptId =  tblICInventoryReceipt.intInventoryReceiptId
														INNER JOIN tblICInventoryReceiptItem ON tblICInventoryReceipt.intInventoryReceiptId =  tblICInventoryReceiptItem.intInventoryReceiptId
														LEFT JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId  AND InventoryTran.intReportingComponentId = @RCId
														WHERE tblICInventoryReceiptItemTax.intTaxCodeId IS NULL     
													)    
				END

		
			--- TRANSACTION WITH TAX CODE    
			

			DELETE @tmpTransaction 
			WHERE intTransactionDetailId IN (SELECT DISTINCT DD.intLoadDistributionDetailId
												FROM @tmpTransaction InventoryTran
												INNER JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionDetailId = InventoryTran.intTransactionDetailId
												INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
												INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
												--INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND tblTRLoadReceipt.intItemId = DD.intItemId
												INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND tblTRLoadReceipt.intItemId = DD.intItemId AND tblTRLoadReceipt.strReceiptLine = DD.strReceiptLink 
												INNER JOIN tblICInventoryReceipt ON tblTRLoadReceipt.intInventoryReceiptId =  tblICInventoryReceipt.intInventoryReceiptId
												INNER JOIN tblICInventoryReceiptItem ON tblICInventoryReceipt.intInventoryReceiptId =  tblICInventoryReceiptItem.intInventoryReceiptId
												LEFT JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId

												INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
												INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
												INNER JOIN tblTFReportingComponentCriteria RCC ON RCC.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId AND RCC.intReportingComponentId = @RCId
												--WHERE InventoryTran.intReportingComponentId = @RCId
												WHERE  ( (RCC.strCriteria = '<> 0' AND  ISNULL(tblICInventoryReceiptItemTax.dblTax,0) = 0) OR (RCC.strCriteria = '= 0' AND  ISNULL(tblICInventoryReceiptItemTax.dblTax,0) > 0))     
												)



			-- TRANSACTION NOT MAPPED ON MFT TAX CATEGORY    
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))    
				BEGIN      
				
						DELETE @tmpTransaction 
						WHERE intTransactionDetailId NOT IN (    
													SELECT DISTINCT InventoryTran.intTransactionDetailId    
													FROM @tmpTransaction InventoryTran    

													INNER JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionDetailId = InventoryTran.intTransactionDetailId
													INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
													INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
													--INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND tblTRLoadReceipt.intItemId = DD.intItemId
													INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND tblTRLoadReceipt.intItemId = DD.intItemId AND tblTRLoadReceipt.strReceiptLine = DD.strReceiptLink 

													INNER JOIN tblICInventoryReceipt ON tblTRLoadReceipt.intInventoryReceiptId =  tblICInventoryReceipt.intInventoryReceiptId
													INNER JOIN tblICInventoryReceiptItem ON tblICInventoryReceipt.intInventoryReceiptId =  tblICInventoryReceiptItem.intInventoryReceiptId
													LEFT JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId

													INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId    
													INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId    
													INNER JOIN tblTFReportingComponentCriteria RCC ON RCC.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId AND RCC.intReportingComponentId = @RCId
													--WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId AND 
													WHERE ISNULL(tblICInventoryReceiptItemTax.dblTax, 0) <> 0    
													)    
				END 

			END
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
				, strEmail
				, strImportVerificationNumber
				, strOriginFacilityNumber
				, strDestinationFacilityNumber)
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
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strCustomerName)), 35) ELSE strCustomerName END AS strCustomerName
				, REPLACE(strCustomerFederalTaxId, '-', '')
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strShipVia)), 35) ELSE strShipVia END AS strShipVia 
				, strTransporterLicense
				, strTransportationMode
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strTransporterName)), 35) ELSE strTransporterName END AS strTransporterName
				, REPLACE(strTransporterFederalTaxId, '-', '')
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strConsignorName)), 35) ELSE strConsignorName END AS strConsignorName 
				, REPLACE(strConsignorFederalTaxId, '-', '')
				, strTaxCode
				, strTerminalControlNumber
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strVendorName)), 35) ELSE strVendorName END AS strVendorName  
				, REPLACE(strVendorFederalTaxId, '-', '')
				, CASE WHEN @IsEdi = 1 THEN LEFT(LTRIM(RTRIM(strHeaderCompanyName)), 35) ELSE strHeaderCompanyName END AS strHeaderCompanyName
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
				, strImportVerificationNumber
				, strOriginFacilityNumber
				, strDestinationFacilityNumber
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
