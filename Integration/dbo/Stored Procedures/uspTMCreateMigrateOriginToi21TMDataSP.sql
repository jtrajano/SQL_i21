GO
	PRINT 'START OF CREATING [uspTMCreateMigrateOriginToi21TMDataSP] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMCreateMigrateOriginToi21TMDataSP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMCreateMigrateOriginToi21TMDataSP
GO


CREATE PROCEDURE uspTMCreateMigrateOriginToi21TMDataSP 
AS
BEGIN
	IF EXISTS(select top 1 1 from sys.procedures where name = 'uspTMMigrateOriginToi21TMData')
	BEGIN
		DROP PROCEDURE uspTMMigrateOriginToi21TMData
	END

	IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwtrmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlclmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcntmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwivcmst') = 1 
		)
	BEGIN
		EXEC('
			CREATE PROCEDURE [dbo].[uspTMMigrateOriginToi21TMData]
			AS
			BEGIN
				PRINT ''START UPDATE CUSTOMER RELATED RECORDS''
				--- Prepare staging table
				IF OBJECT_ID(''tempdb..#tmpCustomerTable'') IS NOT NULL DROP TABLE #tmpCustomerTable

				SELECT
					intOriginId = A.A4GLIdentity
					,intI21Id = B.intEntityId
				INTO #tmpCustomerTable
				FROM vwcusmst A
				INNER JOIN tblEMEntity B
					ON A.vwcus_key COLLATE Latin1_General_CI_AS = B.strEntityNo

				--Update tblTMCustomer
				UPDATE tblTMCustomer
				SET intCustomerNumber = A.intI21Id
				FROM #tmpCustomerTable A
				WHERE tblTMCustomer.intCustomerNumber = A.intOriginId

				--Update tblTMLease
				UPDATE tblTMLease
				SET intBillToCustomerId =  A.intI21Id
				FROM #tmpCustomerTable A
				WHERE tblTMLease.intBillToCustomerId = A.intOriginId

				PRINT ''END UPDATE CUSTOMER RELATED RECORDS''


				PRINT ''START UPDATE SALESPERSON RELATED RECORDS''


				---Prepare Staging Table
				IF OBJECT_ID(''tempdb..#tmpSalesPersonTable'') IS NOT NULL DROP TABLE #tmpSalesPersonTable

				SELECT
					intOriginId = A.A4GLIdentity
					,intI21Id = B.intEntityId
				INTO #tmpSalesPersonTable 
				FROM vwslsmst A
				INNER JOIN tblEMEntity B
					ON A.vwsls_slsmn_id COLLATE Latin1_General_CI_AS = B.strEntityNo

				-- Update tblTMSite
				UPDATE tblTMSite
				SET intDriverID = A.intI21Id
				FROM #tmpSalesPersonTable A
				WHERE tblTMSite.intDriverID = A.intOriginId

				-- Update tblTMDispatch
				UPDATE tblTMDispatch
				SET intDriverID = A.intI21Id
				FROM #tmpSalesPersonTable A
				WHERE tblTMDispatch.intDriverID = A.intOriginId

				UPDATE tblTMDispatch
				SET intDispatchDriverID = A.intI21Id
				FROM #tmpSalesPersonTable A
				WHERE tblTMDispatch.intDispatchDriverID = A.intOriginId

				-- Update tblTMEvent
				UPDATE tblTMEvent
				SET intPerformerID = A.intI21Id
				FROM #tmpSalesPersonTable A
				WHERE tblTMEvent.intPerformerID = A.intOriginId

				-- Update tblTMDeliveryHistory
				UPDATE tblTMDeliveryHistory
				SET intWillCallDriverId = A.intI21Id
				FROM #tmpSalesPersonTable A
				WHERE tblTMDeliveryHistory.intWillCallDriverId = A.intOriginId

				-- Update tblTMWorkOrder
				UPDATE tblTMWorkOrder
				SET intPerformerID = A.intI21Id
				FROM #tmpSalesPersonTable A
				WHERE tblTMWorkOrder.intPerformerID = A.intOriginId


				PRINT ''END UPDATE SALESPERSON RELATED RECORDS''


				PRINT ''START UPDATE LOCATION RELATED RECORDS''


				---Prepare Staging Table
				IF OBJECT_ID(''tempdb..#tmpLocationTable'') IS NOT NULL DROP TABLE #tmpLocationTable

				SELECT
					intOriginId = A.A4GLIdentity
					,intI21Id = B.intCompanyLocationId
				INTO #tmpLocationTable 
				FROM vwlocmst A
				INNER JOIN tblSMCompanyLocation B
					ON A.vwloc_loc_no COLLATE Latin1_General_CI_AS = B.strLocationNumber

				-- Update tblTMSite
				UPDATE tblTMSite
				SET intLocationId = A.intI21Id
				FROM #tmpLocationTable A
				WHERE tblTMSite.intLocationId = A.intOriginId

				-- Update tblTMDevice
				UPDATE tblTMDevice
				SET intLocationId = A.intI21Id
				FROM #tmpLocationTable A
				WHERE tblTMDevice.intLocationId = A.intOriginId

				PRINT ''END UPDATE LOCATION RELATED RECORDS''

				PRINT ''START UPDATE TERM RELATED RECORDS''


				---Prepare Staging Table
				IF OBJECT_ID(''tempdb..#tmpTermTable'') IS NOT NULL DROP TABLE #tmpTermTable

				SELECT
					intOriginId = A.A4GLIdentity
					,intI21Id = B.intTermID
				INTO #tmpTermTable 
				FROM vwtrmmst A
				INNER JOIN tblSMTerm B
					ON A.vwtrm_desc COLLATE Latin1_General_CI_AS = B.strTerm

				-- Update tblTMSite
				UPDATE tblTMSite
				SET intDeliveryTermID = A.intI21Id
				FROM #tmpTermTable A
				WHERE tblTMSite.intDeliveryTermID = A.intOriginId


				-- Update tblTMDispatch
				UPDATE tblTMDispatch
				SET intDeliveryTermID = A.intI21Id
				FROM #tmpTermTable A
				WHERE tblTMDispatch.intDeliveryTermID = A.intOriginId

				-- Update tblTMDeliveryHistory
				UPDATE tblTMDeliveryHistory
				SET intWillCallDeliveryTermId = A.intI21Id
				FROM #tmpTermTable A
				WHERE tblTMDeliveryHistory.intWillCallDeliveryTermId = A.intOriginId

				PRINT ''END UPDATE TERM RELATED RECORDS''


				PRINT ''START UPDATE LOCALE TAX RELATED RECORDS''


				---Prepare Staging Table
				IF OBJECT_ID(''tempdb..#tmpTaxLocaleTable'') IS NOT NULL DROP TABLE #tmpTaxLocaleTable

				SELECT
					intOriginId = A.A4GLIdentity
					,intI21Id = A.intTaxGroupId
				INTO #tmpTaxLocaleTable 
				FROM (
					SELECT DISTINCT
						B.A4GLIdentity
						,A.intTaxGroupId
					FROM tblSMTaxXRef A
					INNER JOIN vwlclmst	B
						ON A.strOrgState COLLATE Latin1_General_CI_AS = B.vwlcl_tax_state COLLATE Latin1_General_CI_AS
						AND A.strOrgLocal1 COLLATE Latin1_General_CI_AS = B.vwlcl_tax_auth_id1 COLLATE Latin1_General_CI_AS 
						AND A.strOrgLocal2 COLLATE Latin1_General_CI_AS = B.vwlcl_tax_auth_id2 COLLATE Latin1_General_CI_AS 
				) A
		

				-- Update tblTMSite
				UPDATE tblTMSite
				SET intTaxStateID = A.intI21Id
				FROM #tmpTaxLocaleTable A
				WHERE tblTMSite.intTaxStateID = A.intOriginId

				--Update tblTMLease
				UPDATE tblTMLease
				SET intLeaseTaxGroupId = A.intI21Id
				FROM #tmpTaxLocaleTable A
				WHERE tblTMLease.intLeaseTaxGroupId = A.intOriginId

				PRINT ''END UPDATE LOCALE TAX  RELATED RECORDS''


				PRINT ''START UPDATE ITEM RELATED RECORDS''


				---Prepare Staging Table
				IF OBJECT_ID(''tempdb..#tmpItemTable'') IS NOT NULL DROP TABLE #tmpItemTable

				SELECT
					intOriginId = A.A4GLIdentity
					,intI21Id = B.intItemId
				INTO #tmpItemTable 
				FROM vwitmmst A
				INNER JOIN tblICItem B
					ON A.vwitm_no COLLATE Latin1_General_CI_AS = B.strItemNo

				-- Update tblTMSite
				UPDATE tblTMSite
				SET intProduct = A.intI21Id
				FROM #tmpItemTable A
				WHERE tblTMSite.intProduct = A.intOriginId

				-- Update tblTMDispatch
				UPDATE tblTMDispatch
				SET intProductID = A.intI21Id
				FROM #tmpItemTable A
				WHERE tblTMDispatch.intProductID = A.intOriginId

				UPDATE tblTMDispatch
				SET intSubstituteProductID = A.intI21Id
				FROM #tmpItemTable A
				WHERE tblTMDispatch.intSubstituteProductID = A.intOriginId

				-- Update tblTMLeaseCode
				UPDATE tblTMLeaseCode
				SET intItemId = A.intI21Id
				FROM #tmpItemTable A
				WHERE tblTMLeaseCode.intItemId = A.intOriginId

				-- Update tblTMEventAutomation
				UPDATE tblTMEventAutomation
				SET intItemId = A.intI21Id
				FROM #tmpItemTable A
				WHERE tblTMEventAutomation.intItemId = A.intOriginId

				-- Update [tblTMBudgetCalculationItemPricing]
				UPDATE tblTMBudgetCalculationItemPricing
				SET intItemId = A.intI21Id
				FROM #tmpItemTable A
				WHERE tblTMBudgetCalculationItemPricing.intItemId = A.intOriginId

				PRINT ''END UPDATE ITEM RELATED RECORDS''


				PRINT ''START UPDATE CONTRACT RELATED RECORDS''
				---Prepare Staging Table
				IF OBJECT_ID(''tempdb..#tmpContractTable'') IS NOT NULL DROP TABLE #tmpContractTable

				SELECT
					intOriginId = A.A4GLIdentity
					,intI21Id = B.intContractHeaderId
				INTO #tmpContractTable 
				FROM vwcntmst A
				INNER JOIN tblCTContractHeader B
					ON A.vwcnt_cnt_no COLLATE Latin1_General_CI_AS = B.strContractNumber

				-- Update tblTMDispatch
				UPDATE tblTMDispatch
				SET intContractId = A.intI21Id
				FROM #tmpContractTable A
				WHERE tblTMDispatch.intContractId = A.intOriginId

				-- Update tblTMSiteLink
				UPDATE tblTMSiteLink
				SET intContractID = A.intI21Id
				FROM #tmpContractTable A
				WHERE tblTMSiteLink.intContractID = A.intOriginId

				-- Update tblTMDeliveryHistory
				UPDATE tblTMDeliveryHistory
				SET intWillCallContractId = A.intI21Id
				FROM #tmpContractTable A
				WHERE tblTMDeliveryHistory.intWillCallContractId = A.intOriginId

				PRINT ''END UPDATE CONTRACT RELATED RECORDS''


				PRINT ''START UPDATE INVOICE RELATED RECORDS''
				---Prepare Staging Table
				IF OBJECT_ID(''tempdb..#tmpInvoiceTable'') IS NOT NULL DROP TABLE #tmpInvoiceTable

				SELECT
					intOriginId = A.A4GLIdentity
					,intI21Id = B.intContractHeaderId
					,stri21Number = B.strInvoiceNumber
					,strOriginNumber = A.vwivc_ivc_no COLLATE Latin1_General_CI_AS
					,intEntityId = C.intEntityId
					,intLocationId = D.intCompanyLocationId
				INTO #tmpInvoiceTable 
				FROM vwivcmst A
				INNER JOIN tblARInvoice B
					ON A.vwivc_ivc_no COLLATE Latin1_General_CI_AS = B.strInvoiceOriginId
				INNER JOIN tblEMEntity C
					ON B.intEntityCustomerId = C.intEntityId
					AND A.vwivc_bill_to_cus COLLATE Latin1_General_CI_AS = C.strEntityNo
				INNER JOIN tblSMCompanyLocation D
					ON B.intCompanyLocationId = D.intCompanyLocationId
					AND A.vwivc_loc_no COLLATE Latin1_General_CI_AS = D.strLocationNumber
				GO

				-- Update tblTMDeliveryHistory
				UPDATE tblTMDeliveryHistory
				SET intInvoiceId = A.intI21Id
					,strInvoiceNumber = A.stri21Number
				FROM (
				SELECT 
					V.stri21Number
					,Z.intDeliveryHistoryID
					,V.intI21Id
				FROM tblTMDeliveryHistory Z
				INNER JOIN tblTMSite Y
					ON Z.intSiteID = Y.intSiteID
				INNER JOIN tblTMCustomer X
					ON Y.intCustomerID = X.intCustomerID
				INNER JOIN #tmpInvoiceTable V
					ON X.intCustomerNumber = V.intEntityId
					AND Y.intLocationId = V.intLocationId
					AND RTRIM(Z.strInvoiceNumber) = RTRIM(V.strOriginNumber)
				) A
				WHERE tblTMDeliveryHistory.intDeliveryHistoryID = A.intDeliveryHistoryID
				GO

				-- Update tblTMDeliveryHistoryDetail
				UPDATE tblTMDeliveryHistoryDetail
				SET strInvoiceNumber = A.stri21Number
				FROM (
					SELECT 
						V.stri21Number
						,W.intDeliveryHistoryDetailID
						,V.intI21Id
					FROM tblTMDeliveryHistory Z
					INNER JOIN tblTMDeliveryHistoryDetail W
						ON Z.intDeliveryHistoryID = W.intDeliveryHistoryID
					INNER JOIN tblTMSite Y
						ON Z.intSiteID = Y.intSiteID
					INNER JOIN tblTMCustomer X
						ON Y.intCustomerID = X.intCustomerID
					INNER JOIN #tmpInvoiceTable V
						ON X.intCustomerNumber = V.intEntityId
						AND Y.intLocationId = V.intLocationId
						AND RTRIM(W.strInvoiceNumber) = RTRIM(V.strOriginNumber)

				) A
				WHERE tblTMDeliveryHistoryDetail.intDeliveryHistoryDetailID = A.intDeliveryHistoryDetailID
				GO

				PRINT ''END UPDATE INVOICE RELATED RECORDS''

			END
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMCreateMigrateOriginToi21TMDataSP] SP'
GO
	PRINT 'START OF Execute [uspTMCreateMigrateOriginToi21TMDataSP] SP'
GO
	EXEC ('uspTMCreateMigrateOriginToi21TMDataSP')
GO
	PRINT 'END OF Execute [uspTMCreateMigrateOriginToi21TMDataSP] SP'
GO