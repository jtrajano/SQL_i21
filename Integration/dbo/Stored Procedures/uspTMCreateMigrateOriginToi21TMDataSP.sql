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
								
			

    

				BEGIN TRY
					DECLARE @tmpMigrationResult TABLE(
						[intCntId] INT IDENTITY(1,1),
						strError NVARCHAR(MAX),
						strTable NVARCHAR(100),
						intRecordId INT
					)

					BEGIN TRANSACTION

					PRINT ''START UPDATE CUSTOMER RELATED RECORDS''				

					---Check for the non existing record in origin
					IF OBJECT_ID(''tempdb..#NoOriginRecord'') IS NOT NULL DROP TABLE #NoOriginRecord
					SELECT 
						A.intCustomerID
					INTO #NoOriginRecord
					FROM tblTMCustomer A
					LEFT JOIN vwcusmst B
						ON A.intCustomerNumber = B.A4GLIdentity
					WHERE B.A4GLIdentity IS NULL

					IF EXISTS(SELECT TOP 1 1 FROM #NoOriginRecord)
					BEGIN
						INSERT INTO @tmpMigrationResult(
							strError
							,strTable
							,intRecordId
						)
						SELECT 
							strError = ''No equivalent record in origin''
							,strTable = ''tblTMCustomer''
							,intRecordId = intCustomerID
						FROM #NoOriginRecord
					END
					----------------------------------


					---------------------------------------------------
					--- Prepare customer staging table
					-----------------------------------------------------------------------------
					IF OBJECT_ID(''tempdb..#tmpCustomerTable'') IS NOT NULL DROP TABLE #tmpCustomerTable

					SELECT
						intOriginId = A.A4GLIdentity
						,intI21Id = B.intEntityId
					INTO #tmpCustomerTable
					FROM vwcusmst A
					INNER JOIN tblEMEntity B
						ON A.vwcus_key COLLATE Latin1_General_CI_AS = B.strEntityNo
					INNER JOIN tblEMEntityType C
						ON B.intEntityId = C.intEntityId
							AND strType = ''Customer''

					---------------------------------------------------------
					---Check for the tmcustomer table vs i21 customer
					-------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent customer record in i21''
						,strTable = ''tblTMCustomer''
						,intRecordId = A.intCustomerID
					FROM tblTMCustomer A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpCustomerTable WHERE intOriginId = A.intCustomerNumber)
						AND A.intCustomerNumber IS NOT NULL

					------------------------------------
					--Update tblTMCustomer
					-----------------------------------------------
					UPDATE tblTMCustomer
					SET intCustomerNumber = A.intI21Id
					FROM #tmpCustomerTable A
					WHERE tblTMCustomer.intCustomerNumber = A.intOriginId

					--------------------------------------------
					---Check for the lease customer vs i21 customer
					----------------------------------------------------------------------
		
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent customer record in i21 for the lease bill to''
						,strTable = ''tblTMLease''
						,intRecordId = intLeaseId
					FROM tblTMLease A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpCustomerTable WHERE intOriginId = A.intBillToCustomerId)
						AND A.intBillToCustomerId IS NOT NULL
		

					-------------------------------------------------------
					--Update tblTMLease
					----------------------------------------------------------------------
					UPDATE tblTMLease
					SET intBillToCustomerId =  A.intI21Id
					FROM #tmpCustomerTable A
					WHERE tblTMLease.intBillToCustomerId = A.intOriginId

				
					PRINT ''END UPDATE CUSTOMER RELATED RECORDS''


					PRINT ''START UPDATE SALESPERSON RELATED RECORDS''

					--------------------------------
					---Prepare Staging Table
					---------------------------------------------
					IF OBJECT_ID(''tempdb..#tmpSalesPersonTable'') IS NOT NULL DROP TABLE #tmpSalesPersonTable

					SELECT
						intOriginId = A.A4GLIdentity
						,intI21Id = B.intEntityId
					INTO #tmpSalesPersonTable 
					FROM vwslsmst A
					INNER JOIN tblEMEntity B
						ON A.vwsls_slsmn_id COLLATE Latin1_General_CI_AS = B.strEntityNo


					--------------------------------------------
					---Check for the site driver vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent driver record in i21 for the site''
						,strTable = ''tblTMSite''
						,intRecordId = intSiteID
					FROM tblTMSite A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpSalesPersonTable WHERE intOriginId = A.intDriverID)
						AND A.intDriverID IS NOT NULL

					-----------------------------------------------
					-- Update tblTMSite
					---------------------------------------------------
					UPDATE tblTMSite
					SET intDriverID = A.intI21Id
					FROM #tmpSalesPersonTable A
					WHERE tblTMSite.intDriverID = A.intOriginId

					--------------------------------------------
					---Check for the order driver vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent driver record in i21 for the order''
						,strTable = ''tblTMDispatch''
						,intRecordId = intDispatchID
					FROM tblTMDispatch A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpSalesPersonTable WHERE intOriginId = A.intDriverID)
						AND A.intDriverID IS NOT NULL

					------------------------------------------------------------------------------
					-- Update tblTMDispatch
					---------------------------------------------------------------------------
					UPDATE tblTMDispatch
					SET intDriverID = A.intI21Id
					FROM #tmpSalesPersonTable A
					WHERE tblTMDispatch.intDriverID = A.intOriginId


					--------------------------------------------
					---Check for the order dispatch driver vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent driver record in i21 for the order dispatch driver''
						,strTable = ''tblTMDispatch''
						,intRecordId = intDispatchID
					FROM tblTMDispatch A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpSalesPersonTable WHERE intOriginId = A.intDispatchDriverID)
						AND A.intDispatchDriverID IS NOT NULL

					------------------------------------------------------------------------------
					-- Update tblTMDispatch
					---------------------------------------------------------------------------
					UPDATE tblTMDispatch
					SET intDispatchDriverID = A.intI21Id
					FROM #tmpSalesPersonTable A
					WHERE tblTMDispatch.intDispatchDriverID = A.intOriginId


					--------------------------------------------
					---Check for the event performer vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the event performer''
						,strTable = ''tblTMEvent''
						,intRecordId = intEventID
					FROM tblTMEvent A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpSalesPersonTable WHERE intOriginId = A.intPerformerID)
						AND A.intPerformerID IS NOT NULL

					----------------------------------------------------------------------------
					-- Update tblTMEvent
					-----------------------------------------------------------
					UPDATE tblTMEvent
					SET intPerformerID = A.intI21Id
					FROM #tmpSalesPersonTable A
					WHERE tblTMEvent.intPerformerID = A.intOriginId


					--------------------------------------------
					---Check for the delivery history order driver vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the delivery history order driver.''
						,strTable = ''tblTMDeliveryHistory''
						,intRecordId = intDeliveryHistoryID
					FROM tblTMDeliveryHistory A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpSalesPersonTable WHERE intOriginId = A.intWillCallDriverId)
						AND A.intWillCallDriverId IS NOT NULL

					-----------------------------------------------------
					-- Update tblTMDeliveryHistory
					-------------------------------------------------------
					UPDATE tblTMDeliveryHistory
					SET intWillCallDriverId = A.intI21Id
					FROM #tmpSalesPersonTable A
					WHERE tblTMDeliveryHistory.intWillCallDriverId = A.intOriginId


					--------------------------------------------
					---Check for the work order performer vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the work order performer.''
						,strTable = ''tblTMWorkOrder''
						,intRecordId = intWorkOrderID
					FROM tblTMWorkOrder A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpSalesPersonTable WHERE intOriginId = A.intPerformerID)
						AND A.intPerformerID IS NOT NULL

					------------------------------------------------------------
					-- Update tblTMWorkOrder
					----------------------------------------------------------
					UPDATE tblTMWorkOrder
					SET intPerformerID = A.intI21Id
					FROM #tmpSalesPersonTable A
					WHERE tblTMWorkOrder.intPerformerID = A.intOriginId

					PRINT ''END UPDATE SALESPERSON RELATED RECORDS''


					PRINT ''START UPDATE LOCATION RELATED RECORDS''

					-----------------------------------------------------------------
					---Prepare Staging Table
					-----------------------------------------------------------------
					IF OBJECT_ID(''tempdb..#tmpLocationTable'') IS NOT NULL DROP TABLE #tmpLocationTable

					SELECT
						intOriginId = A.A4GLIdentity
						,intI21Id = B.intCompanyLocationId
					INTO #tmpLocationTable 
					FROM vwlocmst A
					INNER JOIN tblSMCompanyLocation B
						ON A.vwloc_loc_no COLLATE Latin1_General_CI_AS = B.strLocationNumber

					--------------------------------------------
					---Check for site location vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the site location.''
						,strTable = ''tblTMSite''
						,intRecordId = intSiteID
					FROM tblTMSite A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpLocationTable WHERE intOriginId = A.intLocationId)
						AND A.intLocationId IS NOT NULL

					-------------------------------------------------------
					-- Update tblTMSite
					-----------------------------------------------------------
					UPDATE tblTMSite
					SET intLocationId = A.intI21Id
					FROM #tmpLocationTable A
					WHERE tblTMSite.intLocationId = A.intOriginId


					--------------------------------------------
					---Check for device location vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the device location.''
						,strTable = ''tblTMDevice''
						,intRecordId = intDeviceId
					FROM tblTMDevice A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpLocationTable WHERE intOriginId = A.intLocationId)
						AND A.intLocationId IS NOT NULL

					---------------------------------------------------------------
					-- Update tblTMDevice
					----------------------------------------------------------------
					UPDATE tblTMDevice
					SET intLocationId = A.intI21Id
					FROM #tmpLocationTable A
					WHERE tblTMDevice.intLocationId = A.intOriginId

					--Update tblTMDeliveryHistory
					UPDATE tblTMDeliveryHistory
					SET strBulkPlantNumber = A.strLocationName
					FROM tblSMCompanyLocation A
					WHERE tblTMDeliveryHistory.strBulkPlantNumber = A.strLocationNumber

					PRINT ''END UPDATE LOCATION RELATED RECORDS''

					PRINT ''START UPDATE TERM RELATED RECORDS''

					----------------------------------------------------
					---Prepare Staging Table
					--------------------------------------------------------
					IF OBJECT_ID(''tempdb..#tmpTermTable'') IS NOT NULL DROP TABLE #tmpTermTable

					SELECT
						intOriginId = A.A4GLIdentity
						,intI21Id = B.intTermID
					INTO #tmpTermTable 
					FROM vwtrmmst A
					INNER JOIN tblSMTerm B
						ON A.vwtrm_desc COLLATE Latin1_General_CI_AS = B.strTerm

					--------------------------------------------
					---Check for site term vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the site term.''
						,strTable = ''tblTMSite''
						,intRecordId = A.intSiteID
					FROM tblTMSite A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpTermTable WHERE intOriginId = A.intDeliveryTermID)
						AND A.intDeliveryTermID IS NOT NULL


					-----------------------------------------------
					-- Update tblTMSite
					-------------------------------------------------------
					UPDATE tblTMSite
					SET intDeliveryTermID = A.intI21Id
					FROM #tmpTermTable A
					WHERE tblTMSite.intDeliveryTermID = A.intOriginId



					--------------------------------------------
					---Check for order term vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the order term.''
						,strTable = ''tblTMDispatch''
						,intRecordId = A.intSiteID
					FROM tblTMDispatch A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpTermTable WHERE intOriginId = A.intDeliveryTermID)
						AND A.intDeliveryTermID IS NOT NULL

					-------------------------------------------------------------------------
					-- Update tblTMDispatch
					-------------------------------------------------------------------------
					UPDATE tblTMDispatch
					SET intDeliveryTermID = A.intI21Id
					FROM #tmpTermTable A
					WHERE tblTMDispatch.intDeliveryTermID = A.intOriginId

					--------------------------------------------
					---Check for delivery history order term vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the delivery history order term.''
						,strTable = ''tblTMDeliveryHistory''
						,intRecordId = A.intDeliveryHistoryID
					FROM tblTMDeliveryHistory A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpTermTable WHERE intOriginId = A.intWillCallDeliveryTermId)
						AND A.intWillCallDeliveryTermId IS NOT NULL

					-----------------------------------------------------------------
					-- Update tblTMDeliveryHistory
					---------------------------------------------------------------------
					UPDATE tblTMDeliveryHistory
					SET intWillCallDeliveryTermId = A.intI21Id
					FROM #tmpTermTable A
					WHERE tblTMDeliveryHistory.intWillCallDeliveryTermId = A.intOriginId

					PRINT ''END UPDATE TERM RELATED RECORDS''


					PRINT ''START UPDATE LOCALE TAX RELATED RECORDS''

					-----------------------------------------------------------------------------
					---Prepare Staging Table
					--------------------------------------------------------------------
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


					--------------------------------------------
					---Check for site tax vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the site tax.''
						,strTable = ''tblTMSite''
						,intRecordId = A.intSiteID
					FROM tblTMSite A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpTaxLocaleTable WHERE intOriginId = A.intTaxStateID)
						AND A.intTaxStateID IS NOT NULL
		
					-------------------------------------------------------
					-- Update tblTMSite
					-----------------------------------------------------------------------
					UPDATE tblTMSite
					SET intTaxStateID = A.intI21Id
					FROM #tmpTaxLocaleTable A
					WHERE tblTMSite.intTaxStateID = A.intOriginId


					--------------------------------------------
					---Check for lease tax vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the site tax.''
						,strTable = ''tblTMLease''
						,intRecordId = A.intLeaseId
					FROM tblTMLease A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpTaxLocaleTable WHERE intOriginId = A.intLeaseTaxGroupId)
						AND A.intLeaseTaxGroupId IS NOT NULL

					---------------------------------------
					--Update tblTMLease
					-----------------------------------------------
					UPDATE tblTMLease
					SET intLeaseTaxGroupId = A.intI21Id
					FROM #tmpTaxLocaleTable A
					WHERE tblTMLease.intLeaseTaxGroupId = A.intOriginId

					PRINT ''END UPDATE LOCALE TAX  RELATED RECORDS''


					PRINT ''START UPDATE ITEM RELATED RECORDS''

					--------------------------------------------------
					---Prepare Staging Table
					---------------------------------------------------------
					IF OBJECT_ID(''tempdb..#tmpItemTable'') IS NOT NULL DROP TABLE #tmpItemTable

					SELECT
						intOriginId = A.A4GLIdentity
						,intI21Id = B.intItemId
					INTO #tmpItemTable 
					FROM vwitmmst A
					INNER JOIN tblICItem B
						ON A.vwitm_no COLLATE Latin1_General_CI_AS = B.strItemNo

				
					--------------------------------------------
					---Check for site item vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the site item.''
						,strTable = ''tblTMSite''
						,intRecordId = A.intSiteID
					FROM tblTMSite A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpItemTable WHERE intOriginId = A.intProduct)
						AND A.intProduct IS NOT NULL

					----------------------------------------------------------------------------------
					-- Update tblTMSite
					----------------------------------------------------------------------------------
					UPDATE tblTMSite
					SET intProduct = A.intI21Id
					FROM #tmpItemTable A
					WHERE tblTMSite.intProduct = A.intOriginId

					--------------------------------------------
					---Check for order substitute item vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the order substitute item.''
						,strTable = ''tblTMDispatch''
						,intRecordId = A.intDispatchID
					FROM tblTMDispatch A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpItemTable WHERE intOriginId = A.intSubstituteProductID)
						AND A.intSubstituteProductID IS NOT NULL

					----------------------------------------------------------------------
					-- Update tblTMDispatch
					----------------------------------------------------------------------
					UPDATE tblTMDispatch
					SET intProductID = A.intI21Id
					FROM #tmpItemTable A
					WHERE tblTMDispatch.intProductID = A.intOriginId

					UPDATE tblTMDispatch
					SET intSubstituteProductID = A.intI21Id
					FROM #tmpItemTable A
					WHERE tblTMDispatch.intSubstituteProductID = A.intOriginId


					--------------------------------------------
					---Check for delivery history substitute item vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the order substitute item.''
						,strTable = ''tblTMDeliveryHistory''
						,intRecordId = A.intDeliveryHistoryID
					FROM tblTMDeliveryHistory A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpItemTable WHERE intOriginId = A.intWillCallSubstituteProductId)
						AND A.intWillCallSubstituteProductId IS NOT NULL

					----------------------------------------------------------------------
					-- Update tblTMDispatch
					----------------------------------------------------------------------
					UPDATE tblTMDeliveryHistory
					SET intWillCallProductId = A.intI21Id
					FROM #tmpItemTable A
					WHERE tblTMDeliveryHistory.intWillCallProductId = A.intOriginId

					UPDATE tblTMDeliveryHistory
					SET intWillCallSubstituteProductId = A.intI21Id
					FROM #tmpItemTable A
					WHERE tblTMDeliveryHistory.intWillCallSubstituteProductId = A.intOriginId


					--------------------------------------------
					---Check for lease code item vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the lease code item.''
						,strTable = ''tblTMLeaseCode''
						,intRecordId = A.intLeaseCodeId
					FROM tblTMLeaseCode A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpItemTable WHERE intOriginId = A.intItemId)
						AND A.intItemId IS NOT NULL

					----------------------------------------------------------------------
					-- Update tblTMLeaseCode
					----------------------------------------------------------------------
					UPDATE tblTMLeaseCode
					SET intItemId = A.intI21Id
					FROM #tmpItemTable A
					WHERE tblTMLeaseCode.intItemId = A.intOriginId

					--------------------------------------------
					---Check for event automation item vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the event automation item.''
						,strTable = ''tblTMEventAutomation''
						,intRecordId = A.intEventAutomationID
					FROM tblTMEventAutomation A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpItemTable WHERE intOriginId = A.intItemId)
						AND A.intItemId IS NOT NULL

					----------------------------------------------------------------------
					-- Update tblTMEventAutomation
					----------------------------------------------------------------------
					UPDATE tblTMEventAutomation
					SET intItemId = A.intI21Id
					FROM #tmpItemTable A
					WHERE tblTMEventAutomation.intItemId = A.intOriginId


					--------------------------------------------
					---Check for budget calculation item vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the budget calculation item.''
						,strTable = ''tblTMBudgetCalculationItemPricing''
						,intRecordId = A.intBudgetCalculationItemPricingId
					FROM tblTMBudgetCalculationItemPricing A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpItemTable WHERE intOriginId = A.intItemId)
						AND A.intItemId IS NOT NULL

					----------------------------------------------------------------------
					-- Update [tblTMBudgetCalculationItemPricing]
					----------------------------------------------------------------------
					UPDATE tblTMBudgetCalculationItemPricing
					SET intItemId = A.intI21Id
					FROM #tmpItemTable A
					WHERE tblTMBudgetCalculationItemPricing.intItemId = A.intOriginId
					PRINT ''END UPDATE ITEM RELATED RECORDS''
	
					PRINT ''START UPDATE CONTRACT RELATED RECORDS''
				
					----------------------------------------------------------------------
					---Prepare Staging Table
					----------------------------------------------------------------------
					IF OBJECT_ID(''tempdb..#tmpContractTable'') IS NOT NULL DROP TABLE #tmpContractTable

					SELECT
						intOriginId = A.A4GLIdentity
						,intI21Id = C.intContractDetailId
					INTO #tmpContractTable 
					FROM vwcntmst A
					INNER JOIN tblCTContractHeader B
						ON A.vwcnt_cnt_no COLLATE Latin1_General_CI_AS = B.strContractNumber
					INNER JOIN tblCTContractDetail C
						ON B.intContractHeaderId = C.intContractHeaderId
						
					--------------------------------------------
					---Check for order contract vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the order contract.''
						,strTable = ''tblTMDispatch''
						,intRecordId = A.intDispatchID
					FROM tblTMDispatch A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpContractTable WHERE intOriginId = A.intContractId)
						AND A.intContractId IS NOT NULL

					----------------------------------------------------------------------
					-- Update tblTMDispatch
					----------------------------------------------------------------------
					UPDATE tblTMDispatch
					SET intContractId = A.intI21Id
					FROM #tmpContractTable A
					WHERE tblTMDispatch.intContractId = A.intOriginId

					--------------------------------------------
					---Check for site link contract vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the order contract.''
						,strTable = ''tblTMSiteLink''
						,intRecordId = A.intSiteLinkID
					FROM tblTMSiteLink A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpContractTable WHERE intOriginId = A.intContractID)
						AND A.intContractID IS NOT NULL

					----------------------------------------------------------------------
					-- Update tblTMSiteLink
					----------------------------------------------------------------------
					UPDATE tblTMSiteLink
					SET intContractID = A.intI21Id
					FROM #tmpContractTable A
					WHERE tblTMSiteLink.intContractID = A.intOriginId


					--------------------------------------------
					---Check for delivery contract vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the order contract.''
						,strTable = ''tblTMDeliveryHistory''
						,intRecordId = A.intDeliveryHistoryID
					FROM tblTMDeliveryHistory A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpContractTable WHERE intOriginId = A.intWillCallContractId)
						AND A.intWillCallContractId IS NOT NULL
				
					----------------------------------------------------------------------
					-- Update tblTMDeliveryHistory
					----------------------------------------------------------------------
					UPDATE tblTMDeliveryHistory
					SET intWillCallContractId = A.intI21Id
					FROM #tmpContractTable A
					WHERE tblTMDeliveryHistory.intWillCallContractId = A.intOriginId

					PRINT ''END UPDATE CONTRACT RELATED RECORDS''
				

					PRINT ''START UPDATE INVOICE RELATED RECORDS''
					----------------------------------------------------------------------
					---Prepare Staging Table
					----------------------------------------------------------------------
					IF OBJECT_ID(''tempdb..#tmpInvoiceTable'') IS NOT NULL DROP TABLE #tmpInvoiceTable

					SELECT
						intOriginId = A.A4GLIdentity
						,intI21Id = B.intInvoiceId
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


				
					--------------------------------------------
					---Check for delivery history invoice vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the delivery history invoice.''
						,strTable = ''tblTMDeliveryHistory''
						,intRecordId = A.intDeliveryHistoryID
					FROM (SELECT 
						Z.strInvoiceNumber
						,X.intCustomerNumber
						,Y.intLocationId
						,Z.intDeliveryHistoryID
					FROM tblTMDeliveryHistory Z
					INNER JOIN tblTMSite Y
						ON Z.intSiteID = Y.intSiteID
					INNER JOIN tblTMCustomer X
						ON Y.intCustomerID = X.intCustomerID) A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpInvoiceTable V 
										WHERE A.intCustomerNumber = V.intEntityId
											AND A.intLocationId = V.intLocationId
											AND RTRIM(A.strInvoiceNumber) = RTRIM(V.strOriginNumber)
											AND ISNULL(A.strInvoiceNumber,'''') <> '''')


					----------------------------------------------------------------------
					-- Update tblTMDeliveryHistory
					----------------------------------------------------------------------
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
				


					--------------------------------------------
					---Check for delivery history invoice vs i21 record
					----------------------------------------------------------------------
					INSERT INTO @tmpMigrationResult(
						strError
						,strTable
						,intRecordId
					)
					SELECT 
						strError = ''No equivalent record in i21 for the delivery history detail invoice.''
						,strTable = ''tblTMDeliveryHistoryDetail''
						,intRecordId = A.intDeliveryHistoryDetailID
					FROM (SELECT 
						AA.strInvoiceNumber
						,X.intCustomerNumber
						,Y.intLocationId
						,AA.intDeliveryHistoryDetailID
					FROM tblTMDeliveryHistory Z
					INNER JOIN tblTMSite Y
						ON Z.intSiteID = Y.intSiteID
					INNER JOIN tblTMCustomer X
						ON Y.intCustomerID = X.intCustomerID
					INNER JOIN tblTMDeliveryHistoryDetail AA
						ON Z.intDeliveryHistoryID = AA.intDeliveryHistoryID) A
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #tmpInvoiceTable V 
										WHERE A.intCustomerNumber = V.intEntityId
											AND A.intLocationId = V.intLocationId
											AND RTRIM(A.strInvoiceNumber) = RTRIM(V.strOriginNumber)
											AND ISNULL(A.strInvoiceNumber,'''') <> '''')


					----------------------------------------------------------------------
					-- Update tblTMDeliveryHistoryDetail
					----------------------------------------------------------------------
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
				

				

					PRINT ''END UPDATE INVOICE RELATED RECORDS''
				

					PRINT ''START UPDATE TM Preference''
					---Update tblTMPreference
				
						UPDATE tblTMPreferenceCompany
						SET ysnOriginToi21TMData = 1
							,ysnUseOriginIntegration = 0

					PRINT ''END UPDATE TM Preference''

					SELECT * FROM @tmpMigrationResult

					IF EXISTS(SELECT TOP 1 1 FROM @tmpMigrationResult)
					BEGIN
						print ''rollback''
						ROLLBACK TRANSACTION
					END
					ELSE
					BEGIN

						PRINT ''START UPDATE Recreate SP and views''

							EXEC uspTMRecreateAccountStatusView
					
							EXEC uspTMRecreateSalesPersonView
					
							EXEC uspTMRecreateCommentsView
					
							EXEC uspTMRecreateContractView
					
							EXEC uspTMRecreateOriginOptionView
					
							EXEC uspTMRecreateCTLMSTView
					
							EXEC uspTMRecreateItemView
					
							EXEC uspTMRecreateInvoiceView
					
							EXEC uspTMRecreateLocaleTaxView
					
							EXEC uspTMRecreateLocationView
					
							EXEC uspTMRecreateCustomerView
					
							EXEC uspTMRecreateTermsView
					
							EXEC uspTMRecreateSiteOrderView
					
							EXEC uspTMAlterCobolWrite
					
							EXEC uspTMRecreateOpenCallEntryView
					
							EXEC uspTMRecreateOpenWorkOrderView
					
							EXEC uspTMRecreateConsumptionSiteSearchView
					
							EXEC uspTMRecreateGetSpecialPricingPriceTableFn
					
							EXEC uspTMRecreateItemUsedBySiteView
					
							EXEC uspTMRecreateLocationUsedBySiteView
					
							EXEC uspTMRecreateDriverUsedBySiteView
					
							EXEC uspTMRecreateLeaseSearchView
					
							EXEC uspTMRecreateDeviceSearchView
					
							EXEC uspTMRecreateGeneratedCallEntryView
					
							EXEC uspTMRecreateDeliveryHistoryCallEntryView
					
							EXEC uspTMRecreateOriginDegreeOptionView
					
							EXEC uspTMRecreateOutOfRangeBurnRateSearchView
					
							EXEC uspTMRecreateLeakGasCheckSearchView
					
							EXEC uspTMRecreateEfficiencySearchView
					
							EXEC uspTMRecreateDeliveriesSearchView
					
							EXEC uspTMRecreateCustomerContractSubReportView
					
							EXEC uspTMRecreateCallEntryPrintOutReportView
					
							EXEC uspTMRecreateDeliveryFillReportView
					
							EXEC uspTMRecreateWorkOrderReportView
					
							EXEC uspTMRecreateDYMOCustomerLabelReportView
					
							EXEC uspTMRecreateAssociateSiteSearchView
					
							

						PRINT ''START UPDATE Recreate SP and views''

						COMMIT TRANSACTION
					END

					

					

				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION
				END CATCH
					
			
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