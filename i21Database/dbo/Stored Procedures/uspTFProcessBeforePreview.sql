CREATE PROCEDURE [dbo].[uspTFProcessBeforePreview]
	@Guid NVARCHAR(50)
	, @ReportingComponentId NVARCHAR(50)
	, @DateFrom DATETIME
	, @DateTo DATETIME

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

	DECLARE @FormCode NVARCHAR(50)
		, @ScheduleCode NVARCHAR(50)
		, @TransactionType NVARCHAR(50)
		, @TaxAuthorityCode NVARCHAR(50)
		, @TaxAuthorityId INT
		, @StoreProcedure NVARCHAR(100)
		, @RCId INT
		
	DECLARE @tmpRC TABLE (intReportingComponentId INT)


	INSERT INTO @tmpRC
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')
		
	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC

		SELECT * 
		INTO #tmpTransaction
		FROM tblTFTransaction	
		WHERE uniqTransactionGuid = @Guid
			AND intReportingComponentId = @RCId
			-- CAST(FLOOR(CAST(dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			--AND CAST(FLOOR(CAST(dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)

		SELECT TOP 1 @FormCode = strFormCode
			, @ScheduleCode = strScheduleCode
			, @TransactionType = strTransactionType
			, @TaxAuthorityCode = tblTFTaxAuthority.strTaxAuthorityCode
			, @TaxAuthorityId = tblTFTaxAuthority.intTaxAuthorityId
			, @StoreProcedure = tblTFReportingComponent.strStoredProcedure
		FROM tblTFReportingComponent
		LEFT JOIN tblTFTaxAuthority ON tblTFTaxAuthority.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
		WHERE intReportingComponentId = @RCId


		IF (@FormCode = 'MF-360' OR @FormCode = 'SF-900')
		BEGIN
			IF (@TransactionType = 'Invoice')
			BEGIN
				-- MFT-517 -- Hard Code Terminal Control Number to 'BULK'
				UPDATE tblTFTransaction
				SET strTerminalControlNumber = 'BULK   '
				WHERE intTransactionId IN (SELECT DISTINCT intTransactionId FROM #tmpTransaction)
			END			
		END

		IF (@TaxAuthorityCode = 'MS')
		BEGIN
			UPDATE tblTFTransaction
			SET strOriginTCN = ''
				, strDestinationTCN = ''
			WHERE intTransactionId IN (SELECT DISTINCT intTransactionId FROM #tmpTransaction)
				AND (ISNULL(strOriginTCN, '') <> '' OR ISNULL(strDestinationTCN, '') <> '')
		END
		ELSE IF (@TaxAuthorityCode = 'OR')
		BEGIN
			DELETE FROM tblTFTransactionDynamicOR
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			IF (@StoreProcedure = 'uspTFGetTransporterBulkInvoiceTax') -- FOR SPECIAL SP's
			BEGIN
				INSERT INTO tblTFTransactionDynamicOR(
					intTransactionId
					, strOriginAltFacilityNumber
					, strDestinationAltFacilityNumber
				)
				SELECT Trans.intTransactionId
					, [strOriginAltFacilityNumber] = CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strOregonFacilityNumber ELSE OriginBulkLoc.strOregonFacilityNumber END
					, [strDestinationAltFacilityNumber] = DestinationLoc.strOregonFacilityNumber 
				FROM tblTFTransaction Trans
				INNER JOIN tblTRLoadDistributionDetail ON tblTRLoadDistributionDetail.intLoadDistributionDetailId = Trans.intTransactionNumberId
				INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblTRLoadDistributionDetail.intLoadDistributionHeaderId 
					LEFT JOIN tblSMCompanyLocation DestinationLoc ON DestinationLoc.intCompanyLocationId = tblTRLoadDistributionHeader.intCompanyLocationId
				INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
				INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND tblTRLoadReceipt.intItemId = tblTRLoadDistributionDetail.intItemId AND tblTRLoadDistributionDetail.strReceiptLink = tblTRLoadReceipt.strReceiptLine
					LEFT JOIN tblSMCompanyLocation OriginBulkLoc ON OriginBulkLoc.intCompanyLocationId = tblTRLoadReceipt.intCompanyLocationId	
					LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intSupplyPointId = tblTRLoadReceipt.intSupplyPointId 
						LEFT JOIN tblEMEntityLocation SupplyPointLoc ON SupplyPointLoc.intEntityLocationId = tblTRSupplyPoint.intEntityLocationId				
				WHERE Trans.strTransactionType = 'Receipt'
				AND Trans.uniqTransactionGuid = @Guid
				AND Trans.intReportingComponentId = @ReportingComponentId
				AND Trans.intTransactionId IS NOT NULL
			END
			ELSE
			BEGIN
				INSERT INTO tblTFTransactionDynamicOR(
					intTransactionId
					, strOriginAltFacilityNumber
					, strDestinationAltFacilityNumber
					, strAltDocumentNumber
					, strExplanation
					, strInvoiceNumber
				)
				SELECT Trans.intTransactionId
					, [strOriginAltFacilityNumber] = NULL
					, [strDestinationAltFacilityNumber] = CASE WHEN @ScheduleCode IN ('1', '2', '3') THEN Origin.strOregonFacilityNumber ELSE NULL END
					, [strAltDocumentNumber] = NULL
					, [strExplanation] = NULL
					, [strInvoiceNumber] = NULL
				FROM #tmpTransaction Trans
				LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = Trans.intTransactionNumberId
				LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				LEFT JOIN tblSMCompanyLocation Origin ON Origin.intCompanyLocationId = Receipt.intLocationId
				WHERE Trans.strTransactionType = 'Receipt'

				UNION ALL

				SELECT Trans.intTransactionId
					, [strOriginAltFacilityNumber] = CASE WHEN @ScheduleCode IN ('5', '5LO', '6', '7', '5BLK', '6BLK') THEN Origin.strOregonFacilityNumber WHEN @ScheduleCode IN ('5CRD', '6CRD') THEN tblCFSite.strOregonFacilityNumber ELSE NULL END
					--, [strDestinationAltFacilityNumber] = CASE WHEN @ScheduleCode IN ('5', '5LO', '6', '7', '5BLK', '6BLK', '5CRD', '6CRD') AND Invoice.strType = 'Tank Delivery' THEN tblTMSite.strFacilityNumber ELSE Destination.strOregonFacilityNumber END
					, [strDestinationAltFacilityNumber] = CASE WHEN Invoice.intFreightTermId = 3 THEN Origin.strOregonFacilityNumber WHEN @ScheduleCode IN ('5CRD', '6CRD') THEN NULL WHEN Invoice.strType = 'Tank Delivery' AND tblTMSite.intSiteID IS NOT NULL THEN tblTMSite.strFacilityNumber ELSE Destination.strOregonFacilityNumber END
					, [strAltDocumentNumber] = CASE WHEN Invoice.strType = 'CF Tran' AND @ScheduleCode IN ('5CRD', '6CRD') THEN tblCFCard.strCardNumber ELSE NULL END
					, [strExplanation] = CASE WHEN Invoice.strType = 'CF Tran' AND @ScheduleCode IN ('5CRD', '6CRD') THEN tblCFVehicle.strVehicleDescription ELSE NULL END
					, [strInvoiceNumber] = CASE WHEN @ScheduleCode IN ('5BLK', '6BLK', '5CRD', '6CRD') THEN Invoice.strInvoiceNumber ELSE NULL END
				FROM tblTFTransaction Trans
				LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionNumberId
					--LEFT JOIN tblTMDeliveryHistoryDetail ON tblTMDeliveryHistoryDetail.intInvoiceDetailId = InvoiceDetail.intInvoiceDetailId
					--LEFT JOIN tblTMDeliveryHistory ON tblTMDeliveryHistory.intDeliveryHistoryID = tblTMDeliveryHistoryDetail.intDeliveryHistoryID
					LEFT JOIN tblTMSite ON tblTMSite.intSiteID = InvoiceDetail.intSiteId
				LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
				LEFT JOIN tblSMCompanyLocation Origin ON Origin.intCompanyLocationId = Invoice.intCompanyLocationId
				LEFT JOIN tblEMEntityLocation Destination ON Destination.intEntityLocationId = Invoice.intShipToLocationId
					--LEFT JOIN tblEMEntityLocation Destination ON Destination.intEntityLocationId = Invoice.intShipToLocationId
				LEFT JOIN tblCFTransaction ON tblCFTransaction.intInvoiceId = Invoice.intInvoiceId
					LEFT JOIN tblCFCard ON tblCFCard.intCardId = tblCFTransaction.intCardId
					LEFT JOIN tblCFVehicle ON tblCFVehicle.intVehicleId = tblCFTransaction.intVehicleId
					LEFT JOIN tblCFSite ON tblCFSite.intSiteId = tblCFTransaction.intSiteId
				--LEFT JOIN vyuCFInvoiceReport CFTran ON CFTran.intInvoiceId = Invoice.intInvoiceId AND CFTran.ysnPosted = 1
				--LEFT JOIN tblARCustomerTaxingTaxException TaxException ON TaxException.intEntityCustomerId = Invoice.intEntityCustomerId AND ISNULL(TaxException.intItemId, InvoiceDetail.intItemId) = InvoiceDetail.intItemId AND ISNULL(TaxException.intEntityCustomerLocationId, Invoice.intShipToLocationId) = Invoice.intShipToLocationId
				WHERE Trans.strTransactionType = 'Invoice'
				AND Trans.uniqTransactionGuid = @Guid
				AND Trans.intReportingComponentId = @ReportingComponentId
				AND Trans.intTransactionId IS NOT NULL
			END
			
		END
		ELSE IF (@TaxAuthorityCode = 'NM' AND @ScheduleCode = 'A')
		BEGIN
			DELETE FROM tblTFTransactionDynamicNM
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicNM(
				intTransactionId
				, strNMCounty
				, strNMLocation
			)
			SELECT Trans.intTransactionId
				, strCounty = ISNULL(TACL.strCounty, '')
				, strLocation = ISNULL(TACL.strLocation, '')
			FROM #tmpTransaction Trans
			LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionNumberId
			LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
			LEFT JOIN vyuTFGetTaxAuthorityCountyLocation TACL ON TACL.intEntityId = Invoice.intEntityCustomerId AND TACL.intEntityLocationId = Invoice.intShipToLocationId
			WHERE Trans.strTransactionType = 'Invoice'
				AND ISNULL(Trans.intProductCodeId, '') != ''
		END
		ELSE IF (@TaxAuthorityCode = 'PA')
		BEGIN
			SELECT Trans.intTransactionId
			INTO #tmpUpdatePA
			FROM #tmpTransaction Trans
			LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionNumberId
			LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
			WHERE Trans.strTransactionType = 'Invoice'
				AND ISNULL(Trans.intProductCodeId, '') != ''
				AND Trans.uniqTransactionGuid = @Guid
				AND Invoice.strType = 'CF Tran'
				AND Trans.intReportingComponentId IN (SELECT intReportingComponentId FROM vyuTFGetReportingComponent
													WHERE strTaxAuthorityCode = 'PA'
														AND strScheduleCode IN ('5', '5Q', '6', '7', '8', '9', '10'))
			
			UPDATE tblTFTransaction
			SET strTransportationMode = 'GS'
			WHERE intTransactionId IN (SELECT intTransactionId FROM #tmpUpdatePA)

			DROP TABLE #tmpUpdatePA
		END
		ELSE IF (@TaxAuthorityCode = 'NC')
		BEGIN
			DECLARE @lpgId INT,
				@cngId INT;

			SELECT TOP 1 @lpgId = intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = @TaxAuthorityId AND strProductCode = '054'
			SELECT TOP 1 @cngId = intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = @TaxAuthorityId AND strProductCode = '224'

			SELECT Trans.intTransactionId
			INTO #tmpUpdateNC
			FROM #tmpTransaction Trans
			WHERE ISNULL(Trans.intProductCodeId, '') != ''
				AND Trans.uniqTransactionGuid = @Guid
				AND Trans.intProductCodeId IN (@lpgId, @cngId)
				AND Trans.intReportingComponentId IN (SELECT intReportingComponentId FROM vyuTFGetReportingComponent
													WHERE strTaxAuthorityCode = @TaxAuthorityCode
														AND strFormCode = 'Gas-1252')
			
			UPDATE tblTFTransaction
			SET dblBillQty = (CASE WHEN intProductCodeId = @lpgId THEN dblBillQty / 1.353
									WHEN intProductCodeId = @cngId THEN dblBillQty / 123.57 END)
			WHERE intTransactionId IN (SELECT intTransactionId FROM #tmpUpdateNC)

			DROP TABLE #tmpUpdateNC
		END

		ELSE IF (@TaxAuthorityCode = 'MI')
		BEGIN
			DELETE FROM tblTFTransactionDynamicMI
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicMI(
				intTransactionId
				, strMIDestinationAddress
				, strMIDestinationCountry
				, strMIDestinationTCN
				, strMIDestinationZipCode
				, strMIOriginAddress
				, strMIOriginCountry
				, strMIOriginZipCode
			)
			SELECT intTransactionId, UnCommonField.*  
			FROM (
				SELECT [strMIDestinationAddress], [strMIDestinationCountry], [strMIDestinationTCN], [strMIDestinationZipCode], [strMIOriginAddress] , [strMIOriginCountry], [strMIOriginZipCode]
				FROM  
				(
					SELECT RCFIELD.strColumn, RCCONFIG.strConfiguration FROM
					tblTFReportingComponentField RCFIELD
					INNER JOIN tblTFReportingComponentConfiguration RCCONFIG ON RCCONFIG.strDescription = RCFIELD.strColumn AND RCCONFIG.intReportingComponentId = RCFIELD.intReportingComponentId
					WHERE RCFIELD.ysnFromConfiguration = 1
					AND RCCONFIG.ysnOutputDesigner = 1
					AND ISNULL(RCCONFIG.strConfiguration, '') <> ''
					AND RCFIELD.intReportingComponentId = @RCId
				) AS SourceTable  
				PIVOT  
				(  
					MAX(strConfiguration)  
					FOR strColumn IN ([strMIDestinationAddress], [strMIDestinationCountry], [strMIDestinationTCN], [strMIDestinationZipCode], [strMIOriginAddress] , [strMIOriginCountry], [strMIOriginZipCode])  
				) AS PvtTbl
			) UnCommonField 
			CROSS JOIN tblTFTransaction
		END
		ELSE IF (@TaxAuthorityCode = 'MN' AND @ScheduleCode = 'PDA-46H')
		BEGIN

			INSERT INTO tblTFTransactionDynamicMN 
			SELECT trans.intTransactionId, Item.strDescription FROM #tmpTransaction trans INNER JOIN tblICItem Item ON Item.intItemId = trans.intItemId
		
		END
		ELSE IF (@TaxAuthorityCode = 'TX')
		BEGIN
			DELETE FROM tblTFTransactionDynamicTX
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)
			
			INSERT INTO tblTFTransactionDynamicTX (intTransactionId,strTXPurchaserSignedStatementNumber, intConcurrencyId)
			SELECT Trans.intTransactionId, tblTRLoadHeader.strPurchaserSignedStatementNumber, 1
			FROM tblTFTransaction Trans
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intInvoiceDetailId =  Trans.intTransactionNumberId
			INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
			INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
			INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
			WHERE Trans.uniqTransactionGuid = @Guid
			AND Trans.intReportingComponentId = @ReportingComponentId
			AND Trans.strTransactionType = 'Invoice'
			AND Trans.intTransactionId IS NOT NULL
		END
		ELSE IF (@TaxAuthorityCode = 'MD')
		BEGIN
			DELETE FROM tblTFTransactionDynamicMD
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)
			
			INSERT INTO tblTFTransactionDynamicMD (intTransactionId, strMDDeliveryMethod, strMDFreightPaidBy, strMDConsignorAddress, strMDProductCode, strMDTransportationMode, intConcurrencyId)
			SELECT Trans.intTransactionId, 
				CASE WHEN tblSMShipVia.ysnCompanyOwnedCarrier = 1 THEN 'COT' ELSE 'CCT' END, 
				'', 
				SellerLoc.strAddress + ', ' +  SellerLoc.strCity + ', ' + SellerLoc.strState,
				CASE WHEN Trans.strProductCode = '125' THEN 'AG' 
					WHEN Trans.strProductCode = '065' THEN 'G' 
					WHEN Trans.strProductCode IN ('124','241') THEN 'GH' 	
					WHEN Trans.strProductCode = '150' THEN 'F.O.' 
					WHEN Trans.strProductCode IN ('072','142') THEN 'K' 
					WHEN Trans.strProductCode IN ('160','170','171','228') THEN 'D'
					WHEN Trans.strProductCode = '130' THEN 'A'
				ELSE '' END,
				CASE WHEN Trans.strTransportationMode = 'J' THEN 'TR' ELSE Trans.strTransportationMode END,
				1
			FROM tblTFTransaction Trans
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intInvoiceDetailId =  Trans.intTransactionNumberId
			INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
			INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
			INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
			LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblTRLoadHeader.intShipViaId
			LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = tblTRLoadHeader.intSellerId
			LEFT JOIN tblEMEntityLocation SellerLoc ON SellerLoc.intEntityId = Seller.intEntityId
			WHERE Trans.uniqTransactionGuid = @Guid
			AND Trans.intReportingComponentId = @ReportingComponentId
			AND Trans.strTransactionType = 'Invoice'
			AND Trans.intTransactionId IS NOT NULL

			UNION ALL

			SELECT Trans.intTransactionId, 
				CASE WHEN tblSMShipVia.ysnCompanyOwnedCarrier = 1 THEN 'COT' ELSE 'CCT' END, 
				'', 
				SellerLoc.strAddress + ', ' +  SellerLoc.strCity + ', ' + SellerLoc.strState,
				CASE WHEN Trans.strProductCode = '125' THEN 'AG' 
					WHEN Trans.strProductCode = '065' THEN 'G' 
					WHEN Trans.strProductCode IN ('124','241') THEN 'GH' 
					WHEN Trans.strProductCode = '150' THEN 'F.O.' 
					WHEN Trans.strProductCode IN ('072','142') THEN 'K' 
					WHEN Trans.strProductCode IN ('160','170','171','228') THEN 'D'
					WHEN Trans.strProductCode = '130' THEN 'A'
				ELSE '' END,
				CASE WHEN Trans.strTransportationMode = 'J' THEN 'TR' ELSE Trans.strTransportationMode END,
				1
			FROM tblTFTransaction Trans
			INNER JOIN tblICInventoryReceiptItem ON tblICInventoryReceiptItem.intInventoryReceiptItemId =  Trans.intTransactionNumberId
			INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId
			INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId
			INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
			LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblTRLoadHeader.intShipViaId
			LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = tblTRLoadHeader.intSellerId
			LEFT JOIN tblEMEntityLocation SellerLoc ON SellerLoc.intEntityId = Seller.intEntityId
			WHERE Trans.uniqTransactionGuid = @Guid
			AND Trans.intReportingComponentId = @ReportingComponentId
			AND Trans.strTransactionType = 'Receipt'
			AND Trans.intTransactionId IS NOT NULL

		END
		ELSE IF (@TaxAuthorityCode = 'VA')
		BEGIN
			DELETE FROM tblTFTransactionDynamicVA
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicVA 
			(intTransactionId, strVALocalityCode, strVALocalityName, strVADestinationAddress, strVADestinationZipCode, intConcurrencyId)
			SELECT Trans.intTransactionId, tblTFLocality.strLocalityCode, tblTFLocality.strLocalityName, tblEMEntityLocation.strAddress, tblEMEntityLocation.strZipCode, 1
			FROM tblTFTransaction Trans
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intInvoiceDetailId = Trans.intTransactionNumberId
			INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
			INNER JOIN tblTFReportingComponent ON tblTFReportingComponent.intReportingComponentId = Trans.intReportingComponentId
			INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblARInvoice.intShipToLocationId
				LEFT JOIN tblTFLocality ON tblTFLocality.strLocalityZipCode = tblEMEntityLocation.strZipCode AND tblTFLocality.strLocalityCode = tblEMEntityLocation.strOregonFacilityNumber
			WHERE Trans.uniqTransactionGuid = @Guid
			AND Trans.intReportingComponentId = @ReportingComponentId
			AND Trans.strTransactionType = 'Invoice'
			AND tblTFReportingComponent.strScheduleCode IN ('16A', '16B', '17A', '17B')
			AND Trans.intTransactionId IS NOT NULL

		END
		ELSE IF (@TaxAuthorityCode = 'GA')
		BEGIN
			DELETE FROM tblTFTransactionDynamicGA
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicGA (intTransactionId
				, strGAOriginAddress
				, strGADestinationAddress
				, intConcurrencyId)
			SELECT Trans.intTransactionId
					, [strGAOriginAddress] = tblEMEntityLocation.strAddress
					, [strGADestinationAddress] = tblSMCompanyLocation.strAddress
					, 1
			FROM tblTFTransaction Trans
			INNER JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = Trans.intTransactionNumberId
			INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = Receipt.intShipFromEntityId
				LEFT JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = Receipt.intLocationId
			WHERE Trans.uniqTransactionGuid = @Guid
				AND Trans.strTransactionType = 'Receipt'
				AND Trans.intTransactionId IS NOT NULL
			UNION ALL
			SELECT Trans.intTransactionId
					, [strGAOriginAddress] = tblSMCompanyLocation.strAddress
					, [strGADestinationAddress] = tblEMEntityLocation.strAddress
					, 1
			FROM tblTFTransaction Trans
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intInvoiceDetailId =  Trans.intTransactionNumberId
			INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
			 	LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblARInvoice.intShipToLocationId
				LEFT JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = tblARInvoice.intCompanyLocationId
			WHERE Trans.uniqTransactionGuid = @Guid
				AND Trans.strTransactionType = 'Invoice'
				AND Trans.intTransactionId IS NOT NULL

		END
		ELSE IF (@TaxAuthorityCode = 'FL' AND @ScheduleCode = '5LO_Sum')
		BEGIN
			DELETE FROM tblTFTransactionDynamicFL
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicFL (intTransactionId
				, strFLCountyCode
				, strFLCounty
				, dblFLRate1
				, dblFLRate2
				, dblFLEntitled
				, dblFLNotEntitled
				, intConcurrencyId)
			SELECT Trans.intTransactionId
					, CL.strLocation
					, CL.strCounty
					, CL.dblRate1
					, CL.dblRate2
					, ISNULL(Trans.dblNet, 0) * ISNULL(CL.dblRate1, 0)
					, ISNULL(Trans.dblNet, 0) * ISNULL(CL.dblRate2, 0)
					, 1
			FROM #tmpTransaction Trans
			INNER JOIN tblTFTaxAuthorityCountyLocation TCL ON TCL.intTaxAuthorityCountyLocationId = Trans.intTaxAuthorityCountyLocationId
			INNER JOIN tblTFCountyLocation CL ON CL.intCountyLocationId = TCL.intCountyLocationId
			WHERE Trans.uniqTransactionGuid = @Guid
				AND Trans.intTransactionId IS NOT NULL

		END
		ELSE IF (@TaxAuthorityCode = 'WV' AND @FormCode = 'MFT-507')
		BEGIN
			DELETE FROM tblTFTransactionDynamicWV
			WHERE intTransactionId IN (
				SELECT intTransactionId FROM #tmpTransaction
			)

			INSERT INTO tblTFTransactionDynamicWV (intTransactionId
				,strWVLegalCustomerName
				,intConcurrencyId)
			SELECT Trans.intTransactionId
				, tblEMEntity.str1099Name  AS strCustomerLegalName
				,1
			FROM tblTFTransaction Trans
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intInvoiceDetailId =  Trans.intTransactionNumberId
			INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
			INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblARInvoice.intEntityCustomerId
			WHERE Trans.uniqTransactionGuid = @Guid
			AND Trans.intTransactionId IS NOT NULL	
		END

		DELETE FROM @tmpRC WHERE intReportingComponentId = @RCId

		DROP TABLE #tmpTransaction
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