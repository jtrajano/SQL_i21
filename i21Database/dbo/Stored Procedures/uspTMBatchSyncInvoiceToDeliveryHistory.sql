CREATE PROCEDURE uspTMBatchSyncInvoiceToDeliveryHistory 
	@Invoices Id READONLY
	,@intUserId INT
AS
BEGIN

	
	DECLARE @dtmDateSync DATETIME
	DECLARE @siteId INT
	DECLARE @InvoicesToProcess Id
	DECLARE @dtmDateToProcess DATETIME
	DECLARE @TMOrderHistoryStagingTable AS TMOrderHistoryStagingTable
	
	DECLARE @errorTable TABLE(
			intInvoiceId INT
			,strErrorMessage NVARCHAR(MAX)
	)

	DECLARE @processingTable TABLE(
			intInvoiceId INT
			,dtmInvoiceDate DATETIME
			,intInvoiceCompanyLocationId INT
			,strInvoiceTransactionType NVARCHAR(100)
			,strInvoiceCompanyLocation NVARCHAR(200)
			,strInvoiceNumber NVARCHAR(50)
	)

	DECLARE @insertedHistory TABLE (  --- Will reset inside the loop
		intSiteID 			  INT
		,intDeliveryHistoryId INT
	)

	---Check for Invoice Dates
	IF OBJECT_ID (N'tempdb.dbo.#tmpTMInvoiceAndDate') IS NOT NULL
		DROP TABLE #tmpTMInvoiceAndDate
	SELECT 
		intInvoiceId
		,dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, dtmDate), 0)
	INTO #tmpTMInvoiceAndDate
	FROM tblARInvoice
	WHERE intInvoiceId IN (SELECT intId FROM @Invoices)	

	---Get unique dates
	IF OBJECT_ID (N'tempdb.dbo.#tmpTMInvoiceDateList') IS NOT NULL
		DROP TABLE #tmpTMInvoiceDateList
	SELECT DISTINCT
		dtmDate 
	INTO #tmpTMInvoiceDateList
	FROM #tmpTMInvoiceAndDate
	ORDER BY dtmDate ASC
	
	--loop through dates and process
	SET @dtmDateToProcess = (SELECT TOP 1 dtmDate FROM #tmpTMInvoiceDateList ORDER BY dtmDate ASC)

	WHILE @dtmDateToProcess IS NOT NULL
	BEGIN

		DELETE FROM @InvoicesToProcess
		DELETE FROM @processingTable

		INSERT INTO @InvoicesToProcess
		SELECT intInvoiceId
		FROM #tmpTMInvoiceAndDate 
		WHERE dtmDate = @dtmDateToProcess

		--- Use single Invoice process if processing a single invoice
		IF(SELECT DISTINCT COUNT(intId) FROM @InvoicesToProcess) = 1
		BEGIN
			DECLARE @ResultLogForSync NVARCHAR(MAX) = ''
			DECLARE @intInvoiceForSyncId INT = 0
			
			SELECT TOP 1 @intInvoiceForSyncId = intId FROM @InvoicesToProcess

			EXEC dbo.uspTMSyncInvoiceToDeliveryHistory @intInvoiceForSyncId, @intUserId, @ResultLogForSync OUT
			GOTO NEXTREC
		END

		--Get Validation result
		INSERT INTO @errorTable (
			intInvoiceId
			,strErrorMessage
		)
		EXEC uspTMBatchValidateInvoiceForSync 
			@InvoiceTableId = @InvoicesToProcess


		
		--GEt Invoice header
		INSERT INTO @processingTable(
			intInvoiceId
			,dtmInvoiceDate
			,intInvoiceCompanyLocationId
			,strInvoiceTransactionType
			,strInvoiceCompanyLocation
			,strInvoiceNumber
		)
		SELECT 
			intInvoiceId = A.intInvoiceId
			,dtmInvoiceDate = DATEADD(DAY, DATEDIFF(DAY, 0, A.dtmDate), 0) 
			,intInvoiceCompanyLocationId = A.intCompanyLocationId 
			,strInvoiceTransactionType = A.strTransactionType 
			,strInvoiceCompanyLocation = B.strLocationName
			,strInvoiceNumber = A.strInvoiceNumber
		FROM tblARInvoice A 
		INNER JOIN tblSMCompanyLocation B
			ON A.intCompanyLocationId = B.intCompanyLocationId
		WHERE A.intInvoiceId IN (SELECT intId FROM @InvoicesToProcess)
			AND A.intInvoiceId NOT IN (SELECT DISTINCT intInvoiceId FROM @errorTable)
			AND A.strTransactionType IN ('Invoice', 'Cash')


		--get Invoice Details information 
		IF OBJECT_ID (N'tempdb.dbo.#tmpInvoiceDetail') IS NOT NULL
			DROP TABLE #tmpInvoiceDetail
		
		SELECT 
			A.intInvoiceId
			,A.intInvoiceDetailId
			,A.intSiteId
			,A.dblQtyShipped
			,A.dblTotal
			,A.dblTotalTax
			,A.intItemId
			,A.intPerformerId
			,A.dblPercentFull
			,A.dblNewMeterReading
			,A.intDispatchId
			,B.dtmInvoiceDate
		INTO #tmpInvoiceDetail
		FROM tblARInvoiceDetail A
		INNER JOIN @processingTable B
			ON A.intInvoiceId = B.intInvoiceId
		WHERE A.intSiteId IS NOT NULL
			AND (A.ysnLeaseBilling IS NULL OR A.ysnLeaseBilling = 0 )
			AND (A.ysnVirtualMeterReading IS NULL OR A.ysnVirtualMeterReading = 0 )

		------------------------------------------------------------
		-----Create Service Event for Service Item
		------------------------------------------------------------
			
				---------- Create Service Event with the Event Automation
				INSERT INTO tblTMEvent(
					dtmDate
					,intEventTypeID
					,intPerformerID
					,intUserID
					,strLevel
					,strDescription
					,intSiteID
					
				)
				SELECT 
					DATEADD(DAY, DATEDIFF(DAY, 0, D.dtmInvoiceDate), 0)
					,A.intEventTypeID
					,intPerformerID  = C.intPerformerId
					,intUserID = @intUserId
					,'Consumption Site'
					,B.strDescription + '. Invoice: ' + RTRIM(D.strInvoiceNumber) + ' from ' + RTRIM(D.strInvoiceCompanyLocation)
					,C.intSiteId
				FROM tblTMEventAutomation A
				INNER JOIN tblTMEventType B
					ON A.intEventTypeID = B.intEventTypeID
				INNER JOIN #tmpInvoiceDetail C
					ON A.intItemId = C.intItemId
				INNER JOIN @processingTable D
					ON C.intInvoiceId = D.intInvoiceId
				INNER JOIN tblICItem E
					ON C.intItemId = E.intItemId
				WHERE E.strType = 'Service'
			
		------------------------------------------------------------
		------------------------------------------------------------
		------------------------------------------------------------

		IF OBJECT_ID (N'tempdb.dbo.#tmpNonServiceInvoiceDetail') IS NOT NULL
			DROP TABLE #tmpNonServiceInvoiceDetail

		----GEt all non Service item
		SELECT A.*
		INTO #tmpNonServiceInvoiceDetail
		FROM #tmpInvoiceDetail A
		INNER JOIN tblICItem B
			ON A.intItemId = B.intItemId
		INNER JOIN tblTMSite C
			ON A.intSiteId = C.intSiteID
		WHERE B.strType <> 'Service'


		-----Get Invoice Header to be Processed
		IF OBJECT_ID (N'tempdb.dbo.#tmpFinalInvoiceHeader') IS NOT NULL
			DROP TABLE #tmpFinalInvoiceHeader
		SELECT 
			A.*
		INTO #tmpFinalInvoiceHeader
		FROM @processingTable A
		WHERE intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM #tmpNonServiceInvoiceDetail)

		

		IF OBJECT_ID (N'tempdb.dbo.#tmpFinalNonServiceInvoiceDetail') IS NOT NULL
			DROP TABLE #tmpFinalNonServiceInvoiceDetail
		SELECT 
			A.*
			,dblHighestPercentFull = B.dblPercentFull
			,dblInvoiceTotalQuantity = B.dblTotalQuantity
			,dblClockAccumulatedDegreeDay = D.dblAccumulatedDegreeDay
			,dblLastDelClockAccumulatedDegreeDay = F.dblAccumulatedDegreeDay
			,intHighestPercentFullInvoiceDetailId = B.intInvoiceDetailId
			,dblNewBurnRate = H.dblBurnRate
			,ysnMaxExceed = H.ysnMaxExceed
			,intInvoiceDateClockReadingId = D.intDegreeDayReadingID
			,intElapseDays =  ISNULL((DATEDIFF(DAY,E.dtmLastDeliveryDate,C.dtmInvoiceDate)),0)
			,intLastDeliveryHistoryId = I.intDeliveryHistoryID
			,ysnLessThanLastDeliveryDate = (CASE WHEN(DATEADD(DAY, DATEDIFF(DAY, 0, C.dtmInvoiceDate), 0)  < DATEADD(DAY, DATEDIFF(DAY, 0, I.dtmInvoiceDate), 0) ) THEN 1 ELSE 0 END)
			,dblCalculatedBurnRate = J.dblCalculatedBurnRate
			,dtmLatestDeliveryHistory = I.dtmInvoiceDate
			,ysnMultipleInvoiceHeader = ISNULL(K.ysnMultipleInvoiceHeader,0)
		INTO #tmpFinalNonServiceInvoiceDetail
		FROM #tmpNonServiceInvoiceDetail A
		INNER JOIN #tmpFinalInvoiceHeader C
			ON A.intInvoiceId = C.intInvoiceId
		INNER JOIN tblTMSite E
			ON A.intSiteId = E.intSiteID
		--Get the highest percent full for each invoice and the invoicedetail that have it
		OUTER APPLY (
			SELECT TOP 1
					dblPercentFull = ISNULL(AA.dblPercentFull,0.0)
					,dblTotalQuantity = ISNULL(AA.dblQtyShipped,0.0)
					,AA.intInvoiceDetailId
					,AA.intInvoiceId
			FROM #tmpNonServiceInvoiceDetail AA
			WHERE --AA.intInvoiceId = A.intInvoiceId
				AA.intSiteId = A.intSiteId
			ORDER BY AA.dblPercentFull DESC
		)B
		---Get the Clock Reading information on Delivery Date
		OUTER APPLY (
			SELECT TOP 1
				dblAccumulatedDegreeDay
				,intDegreeDayReadingID
			FROM tblTMDegreeDayReading
			WHERE intClockID = E.intClockID AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, C.dtmInvoiceDate), 0) 
		)D
		---Get the Clock Reading information on previously delivery
		OUTER APPLY (
			SELECT TOP 1
				dblAccumulatedDegreeDay
				,intDegreeDayReadingID
			FROM tblTMDegreeDayReading
			WHERE intClockID = E.intClockID AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, E.dtmLastDeliveryDate), 0) 
		)F
		-----Get the Clock Reading information on previously sync invoice (left over scenario)
		OUTER APPLY (
			SELECT TOP 1 intDeliveryHistoryID 
			FROM tblTMDeliveryHistory 
			WHERE intSiteID = E.intSiteID 
				AND dtmInvoiceDate = C.dtmInvoiceDate AND ysnMeterReading <> 1
		)G
		----New Burn Rate and Exceed calculation
		OUTER APPLY (
			SELECT TOP 1 
				dblBurnRate
				,ysnMaxExceed
			FROM dbo.fnTMComputeNewBurnRateTable(E.intSiteID,B.intInvoiceDetailId,D.intDegreeDayReadingID,F.intDegreeDayReadingID,0,G.intDeliveryHistoryID)
		)H
		-----Get Latest Delivery history
		OUTER APPLY (
			SELECT TOP 1 
				intDeliveryHistoryID 
				,dtmInvoiceDate
			FROM tblTMDeliveryHistory 
			WHERE intSiteID = E.intSiteID 
				AND ysnMeterReading <> 1
		)I
		-- get calculatedBurnRate
		OUTER APPLY (
			SELECT dblCalculatedBurnRate = dbo.[fnTMGetCalculatedBurnRate](E.intSiteID,B.intInvoiceDetailId,D.intDegreeDayReadingID,0,null)
		)J
		---Determine if the Multiple Invoice
		OUTER APPLY (
			SELECT TOP 1 ysnMultipleInvoiceHeader = 1
			FROM #tmpNonServiceInvoiceDetail AA
			WHERE AA.intInvoiceId = B.intInvoiceId
				AND AA.intSiteId = A.intSiteId
				AND AA.intInvoiceDetailId = A.intInvoiceDetailId
		)K

		--	print '1234'
		--SELECT * FROM #tmpFinalNonServiceInvoiceDetail


		--------------------------------------------------------------------------
		-------------Insert into Delivery History
		--------------------------------------------------------------------------
		
				--------------------------------------------------------------------------------------------------
				-----------------START Invoice Date is Equal the last delivery date and have delivery History record
				--------------------------------------------------------------------------------------------------
				BEGIN

					IF OBJECT_ID (N'tempdb.dbo.#tmpInvoiceDateEqualLastDeliveryDateDetail') IS NOT NULL
					DROP TABLE #tmpInvoiceDateEqualLastDeliveryDateDetail
					
					SELECT
						A.intLastDeliveryHistoryId
						,A.dblPercentFull
						,C.strInvoiceTransactionType
						,A.dblTotal
						,A.dblTotalTax
						,A.dblQtyShipped 
						,C.strInvoiceNumber
						,A.intSiteId
						,D.strItemNo
						,A.intInvoiceDetailId
						,C.dtmInvoiceDate
						,A.dblNewBurnRate
						,A.dblClockAccumulatedDegreeDay
						,A.dblCalculatedBurnRate
						,A.ysnMaxExceed
						,A.intDispatchId
					INTO #tmpInvoiceDateEqualLastDeliveryDateDetail
					FROM #tmpFinalNonServiceInvoiceDetail A
					INNER JOIN tblTMSite B
						ON A.intSiteId = B.intSiteID
					INNER JOIN #tmpFinalInvoiceHeader C
						ON A.intInvoiceId = C.intInvoiceId
					INNER JOIN tblICItem D
						ON A.intItemId = D.intItemId
					INNER JOIN tblTMDeliveryHistory E
						ON B.intSiteID = E.intSiteID
							AND A.intLastDeliveryHistoryId = E.intDeliveryHistoryID
					WHERE DATEADD(DAY, DATEDIFF(DAY, 0, B.dtmLastDeliveryDate), 0) = DATEADD(DAY, DATEDIFF(DAY, 0, C.dtmInvoiceDate), 0)
						AND DATEADD(DAY, DATEDIFF(DAY, 0, A.dtmLatestDeliveryHistory), 0) = DATEADD(DAY, DATEDIFF(DAY, 0, C.dtmInvoiceDate), 0)
						AND A.intLastDeliveryHistoryId IS NOT NULL
						AND E.ysnMeterReading <> 1
					
					---Add to detail of the delivery history
					INSERT INTO tblTMDeliveryHistoryDetail(
					intDeliveryHistoryID
					,dblPercentAfterDelivery
					,dblExtendedAmount
					,dblQuantityDelivered
					,strInvoiceNumber
					,strItemNumber
					,intInvoiceDetailId
					)
					SELECT 
						intDeliveryHistoryID = A.intLastDeliveryHistoryId
						,dblPercentAfterDelivery = ISNULL(A.dblPercentFull,0)
						,dblExtendedAmount = CASE WHEN A.strInvoiceTransactionType = 'Credit Memo' OR A.strInvoiceTransactionType = 'Cash Refund' THEN 0 - (ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)) ELSE ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0) END
						,dblQuantityDelivered = CASE WHEN A.strInvoiceTransactionType = 'Credit Memo' OR A.strInvoiceTransactionType = 'Cash Refund' THEN 0 - A.dblQtyShipped ELSE A.dblQtyShipped END
						,strInvoiceNumber = A.strInvoiceNumber
						,strItemNumber = A.strItemNo
						,intInvoiceDetailId
					FROM #tmpInvoiceDateEqualLastDeliveryDateDetail A
					
					IF EXISTS(SELECT TOP 1 1 FROM #tmpInvoiceDateEqualLastDeliveryDateDetail)
					BEGIN

						---- Update delivery History Table Header
						UPDATE tblTMDeliveryHistory
							SET dblActualPercentAfterDelivery = A.dblPercentAfterDelivery
							,strInvoiceNumber = A.strInvoiceNumber
							,strProductDelivered = A.strItemNumber
							,dblGallonsInTankAfterDelivery = A.dblGalsAfterDelivery
						FROM (
							SELECT 
								intRow = ROW_NUMBER() OVER(PARTITION BY Z.intDeliveryHistoryID ORDER BY Z.dblPercentAfterDelivery DESC)
								,Z.dblPercentAfterDelivery
								,Z.strInvoiceNumber
								,Z.strItemNumber
								,dblGalsAfterDelivery = ISNULL(Z.dblPercentAfterDelivery,0) * ISNULL(X.dblTotalCapacity,0) / 100
								,Z.intDeliveryHistoryID
							FROM tblTMDeliveryHistoryDetail Z
							INNER JOIN tblTMDeliveryHistory Y
								ON Z.intDeliveryHistoryID = Y.intDeliveryHistoryID
							INNER JOIN tblTMSite X
								ON Y.intSiteID = X.intSiteID
							WHERE Z.intDeliveryHistoryID IN (SELECT intLastDeliveryHistoryId FROM #tmpInvoiceDateEqualLastDeliveryDateDetail)
						)A
						WHERE tblTMDeliveryHistory.intDeliveryHistoryID = A.intDeliveryHistoryID
							AND A.intRow = 1
						
						UPDATE tblTMDeliveryHistory
						SET dblExtendedAmount = A.dblExtendedAmount
							,dblQuantityDelivered = A.dblQuantityDelivered
						FROM(
							SELECT 
								AA.intDeliveryHistoryID
								,dblExtendedAmount = SUM(ISNULL(AA.dblExtendedAmount,0))
								,dblQuantityDelivered = SUM(ISNULL(AA.dblQuantityDelivered,0))
							FROM tblTMDeliveryHistoryDetail AA
							WHERE AA.intDeliveryHistoryID IN (SELECT intLastDeliveryHistoryId FROM #tmpInvoiceDateEqualLastDeliveryDateDetail)
							GROUP BY AA.intDeliveryHistoryID
						)A
						WHERE tblTMDeliveryHistory.intDeliveryHistoryID = A.intDeliveryHistoryID



						---Update Site
						UPDATE tblTMSite
						SET dtmLastReadingUpdate = A.dtmInvoiceDate
							,dblLastDeliveredGal = dblQuantityTotal
						FROM(
							SELECT dblQuantityTotal = SUM(ISNULL(dblQtyShipped,0))
								,dblSalesTotal = SUM(ISNULL(dblTotal,0)) + SUM(ISNULL(dblTotalTax,0))
								,dtmInvoiceDate
								,intSiteId
							FROM #tmpInvoiceDateEqualLastDeliveryDateDetail
							GROUP BY intSiteId,dtmInvoiceDate
						)A
						WHERE intSiteID = A.intSiteId

						---Update Site Estimated Gals and last gals in tank
						UPDATE tblTMSite
						SET dblEstimatedPercentLeft = A.dblPercentAfterDelivery
							,dblEstimatedGallonsLeft = ISNULL(A.dblPercentAfterDelivery,0.0) * tblTMSite.dblTotalCapacity /100
							,dblLastDeliveredGal = A.dblShippedQuantity
							,dblLastGalsInTank =   ISNULL(tblTMSite.dblTotalCapacity,0)  * ISNULL(A.dblPercentAfterDelivery,0)/100
						FROM(
							SELECT  
								dblPercentAfterDelivery = MAX(A.dblPercentAfterDelivery)
								,dblShippedQuantity = SUM(A.dblQuantityDelivered)
								,B.intSiteID
							FROM tblTMDeliveryHistoryDetail A
							INNER JOIN tblTMDeliveryHistory B
								ON A.intDeliveryHistoryID = B.intDeliveryHistoryID
							WHERE B.intSiteID IN (SELECT intSiteId FROM #tmpInvoiceDateEqualLastDeliveryDateDetail)
							GROUP BY B.intSiteID
						)A
						WHERE tblTMSite.intSiteID = A.intSiteID

						---Update Site Burn Rate, dblDegreeDayBetweenDelivery,intNextDeliveryDegreeDay based on the new calculated burn rate
						UPDATE tblTMSite
						SET dblBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 
												THEN ISNULL(A.dblNewBurnRate,0.0)
												ELSE dblBurnRate 
											END)
							,dblDegreeDayBetweenDelivery = ISNULL(A.dblNewBurnRate,0.0) * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END)
							,intNextDeliveryDegreeDay = A.dblClockAccumulatedDegreeDay + (A.dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END))
						FROM #tmpInvoiceDateEqualLastDeliveryDateDetail A
						WHERE tblTMSite.intSiteID = A.intSiteId

						----UPDATE Delivery history header for the new calc burnrate 
						UPDATE tblTMDeliveryHistory
						SET dblBurnRateAfterDelivery = A.dblNewBurnRate
							,dblCalculatedBurnRate = A.dblCalculatedBurnRate
						FROM #tmpInvoiceDateEqualLastDeliveryDateDetail A
						WHERE tblTMDeliveryHistory.intDeliveryHistoryID = A.intLastDeliveryHistoryId

						---Insert into out of range table
						INSERT INTO tblTMSyncOutOfRange
						(
							intSiteID
							,dtmDateSync
							,ysnCommit
						)
						SELECT DISTINCT
							intSiteID		= A.intSiteId
							,dtmDateSync	= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0)
							,ysnCommit		= 1
						FROM #tmpInvoiceDateEqualLastDeliveryDateDetail A
						WHERE A.ysnMaxExceed = 1 OR A.dblCalculatedBurnRate < 0


						IF OBJECT_ID (N'tempdb.dbo.#tmpSiteUpdateList1') IS NOT NULL
						DROP TABLE #tmpSiteUpdateList1

						---GEt the list of sites to be updated
						SELECT DISTINCT 
							A.intSiteId
							,A.intDispatchId
							,dtmInvoiceDate = DATEADD(DAY, DATEDIFF(DAY, 0, A.dtmInvoiceDate), 0)
						INTO #tmpSiteUpdateList1
						FROM #tmpInvoiceDateEqualLastDeliveryDateDetail A
						
						

						--- Insert Dispatch to tblTMDispatchHistory table
						DELETE FROM @TMOrderHistoryStagingTable
						INSERT INTO @TMOrderHistoryStagingTable(
							intDispatchId
							,ysnDelete
							,intSourceType
							,intDeliveryHistoryId
						)
						SELECT DISTINCT
							intDispatchId				= intDispatchId
							,ysnDelete 					= 1
							,intSourceType				= 1
							,intDeliveryHistoryId		= intLastDeliveryHistoryId 
						FROM #tmpInvoiceDateEqualLastDeliveryDateDetail
						WHERE intDispatchId IS NOT NULL

						EXEC uspTMArchiveRestoreOrders @TMOrderHistoryStagingTable, @intUserId


						---- Update forecasted and estimated % left
						SET @siteId = (SELECT TOP 1 intSiteId FROM #tmpSiteUpdateList1 ORDER BY intSiteId ASC)
						WHILE ISNULL(@siteId,0) > 0
						BEGIN
							EXEC uspTMUpdateEstimatedValuesBySite @siteId
							EXEC uspTMUpdateForecastedValuesBySite @siteId
							EXEC uspTMUpdateNextJulianDeliveryBySite @siteId
						
							SET @siteId = (	SELECT TOP 1 intSiteId 
											FROM #tmpSiteUpdateList1 
											WHERE intSiteId > @siteId 
											ORDER BY intSiteId ASC)
						END
					END
				END

				--------------------------------------------------------------------------------------------------
				-----------------END Invoice Date is Equal the last delivery date and have delivery History record
				--------------------------------------------------------------------------------------------------

				--------------------------------------------------------------------------------------------------
				------------------Start Invoice date is greater than the last delivery date
				--------------------------------------------------------------------------------------------------
				BEGIN
					IF OBJECT_ID (N'tempdb.dbo.#tmpInvoiceDateGreaterThanLastDelivery') IS NOT NULL
					DROP TABLE #tmpInvoiceDateGreaterThanLastDelivery
					
					SELECT
						A.*
						,intRow = ROW_NUMBER() OVER(PARTITION BY A.intSiteId ORDER BY A.intInvoiceId ASC)
					INTO #tmpInvoiceDateGreaterThanLastDelivery
					FROM #tmpFinalNonServiceInvoiceDetail A
					WHERE A.ysnLessThanLastDeliveryDate = 0

					IF EXISTS(SELECT TOP 1 1 FROM #tmpInvoiceDateGreaterThanLastDelivery)
					BEGIN
						DELETE FROM @insertedHistory
						INSERT INTO tblTMDeliveryHistory(
							strInvoiceNumber
							,strBulkPlantNumber
							,dtmInvoiceDate
							,strProductDelivered
							,dblQuantityDelivered
							,intDegreeDayOnDeliveryDate
							,intDegreeDayOnLastDeliveryDate
							,dblBurnRateAfterDelivery
							,dblCalculatedBurnRate
							,ysnAdjustBurnRate
							,intElapsedDegreeDaysBetweenDeliveries
							,intElapsedDaysBetweenDeliveries
							,strSeason
							,dblWinterDailyUsageBetweenDeliveries
							,dblSummerDailyUsageBetweenDeliveries
							,dblGallonsInTankbeforeDelivery
							,dblGallonsInTankAfterDelivery
							,dblEstimatedPercentBeforeDelivery
							,dblActualPercentAfterDelivery
							,dblMeterReading
							,dblLastMeterReading
							,intUserID
							,dtmLastUpdated
							,intSiteID
							,strSalesPersonID
							,dblExtendedAmount
							,ysnForReview
							,dtmMarkForReviewDate
							,dblWillCallCalculatedQuantity
							,dblWillCallDesiredQuantity
							,intWillCallDriverId
							,intWillCallProductId
							,intWillCallSubstituteProductId
							,dblWillCallPrice
							,intWillCallDeliveryTermId
							,dtmWillCallRequestedDate
							,intWillCallPriority
							,dblWillCallTotal
							,strWillCallComments
							,dtmWillCallCallInDate
							,intWillCallUserId
							,ysnWillCallPrinted
							,dtmWillCallDispatch
							,strWillCallOrderNumber
							,intWillCallContractId
							,dtmSiteLastDelivery
							,dblSiteBurnRate
							,dblSitePreviousBurnRate	
							,dtmSiteOnHoldStartDate
							,dtmSiteOnHoldEndDate
							,ysnSiteHoldDDCalculations
							,ysnSiteOnHold
							,dblSiteLastDeliveredGal
							,ysnSiteDeliveryTicketPrinted
							,dblSiteDegreeDayBetweenDelivery
							,intSiteNextDeliveryDegreeDay
							,dblSiteLastGalsInTank
							,dblSiteEstimatedPercentLeft
							,dtmSiteLastReadingUpdate
							,intWillCallRouteId
							,intWillCallDispatchId
							,ysnWillCallLeakCheckRequired
							,intInvoiceId
							,dblWillCallPercentLeft
							,dblWillCallOriginalPercentLeft
							,dtmNextDeliveryDate
							,dtmRunOutDate
							,dtmForecastedDelivery
						)
						OUTPUT INSERTED.intSiteID,INSERTED.intDeliveryHistoryID INTO @insertedHistory
						SELECT
							strInvoiceNumber = C.strInvoiceNumber
							,strBulkPlantNumber = D.strLocationName
							,dtmInvoiceDate = C.dtmDate
							,strProductDelivered = E.strItemNo
							,dblQuantityDelivered = K.dblTotalDelivered
							,intDegreeDayOnDeliveryDate = B.dblClockAccumulatedDegreeDay
							,intDegreeDayOnLastDeliveryDate = B.dblLastDelClockAccumulatedDegreeDay
							,dblBurnRateAfterDelivery = ISNULL(B.dblNewBurnRate,0.0)
							,dblCalculatedBurnRate = B.dblCalculatedBurnRate
							,ysnAdjustBurnRate = ISNULL(A.ysnAdjustBurnRate,0)
							,intElapsedDegreeDaysBetweenDeliveries = dbo.fnTMGetElapseDegreeDayForCalculation(A.intSiteID,B.intInvoiceDateClockReadingId,null)
							,intElapsedDaysBetweenDeliveries = B.intElapseDays
							,strSeason = (CASE WHEN MONTH(C.dtmDate) >= H.intBeginSummerMonth AND  MONTH(C.dtmDate) < H.intBeginWinterMonth THEN 'Summer' ELSE 'Winter' END)
							,dblWinterDailyUsageBetweenDeliveries = A.dblWinterDailyUse
							,dblSummerDailyUsageBetweenDeliveries = A.dblSummerDailyUse
							,dblGallonsInTankbeforeDelivery = A.dblEstimatedGallonsLeft
							,dblGallonsInTankAfterDelivery = A.dblTotalCapacity * (ISNULL(B.dblPercentFull,0)/100)
							,dblEstimatedPercentBeforeDelivery = A.dblEstimatedPercentLeft
							,dblActualPercentAfterDelivery = B.dblPercentFull
							,dblMeterReading = B.dblNewMeterReading
							,dblLastMeterReading = A.dblLastMeterReading
							,intUserID = @intUserId
							,dtmLastUpdated = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
							,intSiteID = A.intSiteID
							,strSalesPersonID = I.strEntityNo
							,dblExtendedAmount = ISNULL(J.dblTotal,0.0) +  ISNULL(J.dblTotalTax,0.0)
							,ysnForReview = 0
							,dtmMarkForReviewDate = NULL
							,dblWillCallCalculatedQuantity  = G.dblQuantity
							,dblWillCallDesiredQuantity = G.dblMinimumQuantity
							,intWillCallDriverId = G.intDriverID
							,intWillCallProductId = G.intProductID
							,intWillCallSubstituteProductId = G.intSubstituteProductID
							,dblWillCallPrice = G.dblPrice
							,intWillCallDeliveryTermId = G.intDeliveryTermID
							,dtmWillCallRequestedDate = G.dtmRequestedDate
							,intWillCallPriority = G.intPriority
							,dblWillCallTotal = G.dblTotal
							,strWillCallComments = G.strComments
							,dtmWillCallCallInDate = G.dtmCallInDate
							,intWillCallUserId = G.intUserID
							,ysnWillCallPrinted = G.ysnCallEntryPrinted
							,dtmWillCallDispatch = G.dtmDispatchingDate
							,strWillCallOrderNumber = G.strOrderNumber
							,intWillCallContractId = G.intContractId
							,dtmSiteLastDelivery = A.dtmLastDeliveryDate	
							,dblSiteBurnRate = A.dblBurnRate
							,dblSitePreviousBurnRate	= A.dblPreviousBurnRate
							,dtmSiteOnHoldStartDate = A.dtmOnHoldStartDate
							,dtmSiteOnHoldEndDate = A.dtmOnHoldEndDate
							,ysnSiteHoldDDCalculations = A.ysnHoldDDCalculations
							,ysnSiteOnHold = A.ysnOnHold
							,dblSiteLastDeliveredGal = A.dblLastDeliveredGal
							,ysnSiteDeliveryTicketPrinted = A.ysnDeliveryTicketPrinted
							,dblSiteDegreeDayBetweenDelivery = A.dblDegreeDayBetweenDelivery
							,intSiteNextDeliveryDegreeDay = A.intNextDeliveryDegreeDay
							,dblSiteLastGalsInTank = A.dblLastGalsInTank
							,dblSiteEstimatedPercentLeft = A.dblEstimatedPercentLeft
							,dtmSiteLastReadingUpdate = ISNULL(A.dtmLastReadingUpdate,DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0))
							,intWillCallRouteId = G.intRouteId
							,intWillCallDispatchId = G.intDispatchID
							,ysnWillCallLeakCheckRequired = ISNULL(G.ysnLeakCheckRequired,0)
							,intInvoiceId = B.intInvoiceId
							,dblWillCallPercentLeft = G.dblPercentLeft
							,dblWillCallOriginalPercentLeft = G.dblOriginalPercentLeft
							,dtmNextDeliveryDate = A.dtmNextDeliveryDate
							,dtmRunOutDate = A.dtmRunOutDate
							,dtmForecastedDelivery = A.dtmForecastedDelivery
						FROM tblTMSite A
						INNER JOIN #tmpInvoiceDateGreaterThanLastDelivery B
							ON A.intSiteID = B.intSiteId
						INNER JOIN tblARInvoice C
							ON B.intInvoiceId = C.intInvoiceId
						INNER JOIN tblSMCompanyLocation D
							ON C.intCompanyLocationId = D.intCompanyLocationId
						INNER JOIN tblICItem E
							ON B.intItemId = E.intItemId
						LEFT JOIN tblTMDispatch G
							ON A.intSiteID = G.intSiteID
								AND G.intDispatchID = B.intDispatchId
						INNER JOIN tblTMClock H
							ON A.intClockID = H.intClockID
						LEFT JOIN tblEMEntity I
							ON I.intEntityId = C.intEntitySalespersonId
						OUTER APPLY (
							SELECT TOP 1 
								dblTotal = SUM(ISNULL(dblTotal,0.0))
								,dblTotalTax = SUM(ISNULL(dblTotalTax,0.0))
							FROM #tmpInvoiceDateGreaterThanLastDelivery 
							WHERE intSiteId = A.intSiteID
							
						)J
						--Get the total Quantity of the invoice/multiple Invoices
						OUTER APPLY (
							SELECT  dblTotalDelivered = SUM(ISNULL(AA.dblQtyShipped,0.0))
							FROM #tmpInvoiceDateGreaterThanLastDelivery AA
							WHERE AA.intSiteId = A.intSiteID
						)K
						WHERE B.ysnLessThanLastDeliveryDate = 0
							AND B.ysnMultipleInvoiceHeader = 1
							AND B.intRow = 1

						------------------------------------------------------------------
						---Insert into out of range table
						------------------------------------------------------------------
						SET @dtmDateSync = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0)

						INSERT INTO tblTMSyncOutOfRange
						(
							intSiteID
							,dtmDateSync
							,ysnCommit
						)
						SELECT 
							intSiteID		= A.intSiteId
							,dtmDateSync	= @dtmDateSync
							,ysnCommit		= 1
						FROM #tmpInvoiceDateGreaterThanLastDelivery A
						OUTER APPLY(
							SELECT TOP 1 intSiteId 
							FROM tblTMSyncOutOfRange
							WHERE intSiteId = A.intSiteId
								AND dtmDateSync = @dtmDateSync
						)B
						WHERE (A.ysnMaxExceed = 1 OR A.dblCalculatedBurnRate < 0)
							AND B.intSiteId IS NULL
							AND A.ysnLessThanLastDeliveryDate = 0

						--Insert Delivery History Detail	
						INSERT INTO tblTMDeliveryHistoryDetail(
							intDeliveryHistoryID
							,dblPercentAfterDelivery
							,dblExtendedAmount
							,dblQuantityDelivered
							,strInvoiceNumber
							,strItemNumber
							,intInvoiceDetailId
						)
						SELECT 
							intDeliveryHistoryID = D.intDeliveryHistoryID
							,dblPercentAfterDelivery = ISNULL(dblPercentFull,0)
							,dblExtendedAmount = ISNULL(dblTotal,0) + ISNULL(dblTotalTax,0)
							,dblQuantityDelivered = dblQtyShipped
							,strInvoiceNumber = B.strInvoiceNumber
							,strItemNumber = C.strItemNo
							,A.intInvoiceDetailId
						FROM #tmpInvoiceDateGreaterThanLastDelivery A
						INNER JOIN #tmpFinalInvoiceHeader B
							ON A.intInvoiceId = B.intInvoiceId
						INNER JOIN tblICItem C
							ON A.intItemId = C.intItemId
						INNER JOIN tblTMDeliveryHistory D
							ON --A.intInvoiceId = D.intInvoiceId
								A.intSiteId = D.intSiteID
								AND DATEADD(dd, DATEDIFF(dd, 0, D.dtmInvoiceDate),0) = @dtmDateToProcess
						WHERE A.ysnLessThanLastDeliveryDate = 0

					
						IF OBJECT_ID (N'tempdb.dbo.#tmpSiteUpdateList') IS NOT NULL
						DROP TABLE #tmpSiteUpdateList

						---GEt the list of sites to be updated
						SELECT DISTINCT 
							A.intSiteId
							,A.dblClockAccumulatedDegreeDay
							,A.dblHighestPercentFull
							,A.dblInvoiceTotalQuantity
							,A.dblNewBurnRate
							,A.intInvoiceId
							,dtmInvoiceDate = DATEADD(DAY, DATEDIFF(DAY, 0, A.dtmInvoiceDate), 0)
							,A.intDispatchId
						INTO #tmpSiteUpdateList
						FROM #tmpInvoiceDateGreaterThanLastDelivery A
						WHERE A.ysnLessThanLastDeliveryDate = 0

						-----Update Site
						UPDATE tblTMSite
						SET intLastDeliveryDegreeDay = A.dblClockAccumulatedDegreeDay
							,dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(A.dblHighestPercentFull,0)/100
							,dblLastDeliveredGal = C.dblTotalQuantityDelivered
							,dtmLastDeliveryDate = B.dtmInvoiceDate
							,dtmLastUpdated = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
							,ysnDeliveryTicketPrinted = 0
							,dblEstimatedPercentLeft = ISNULL(A.dblHighestPercentFull,0)
							,dblEstimatedGallonsLeft = dblTotalCapacity * ISNULL(A.dblHighestPercentFull,0) /100
							,dblPreviousBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 
														THEN dblBurnRate 
														ELSE dblPreviousBurnRate 
													END)
							,dblBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 
												THEN A.dblNewBurnRate
												ELSE dblBurnRate 
											END)
							,dtmLastReadingUpdate = B.dtmInvoiceDate
						FROM #tmpSiteUpdateList A
						INNER JOIN #tmpFinalInvoiceHeader B
							ON A.intInvoiceId = B.intInvoiceId
						OUTER APPLY(
							SELECT TOP 1 
								dblTotalQuantityDelivered = SUM(BB.dblQuantityDelivered)
							FROM tblTMDeliveryHistory AA
							INNER JOIN tblTMDeliveryHistoryDetail BB
								ON AA.intDeliveryHistoryID = BB.intDeliveryHistoryID
							WHERE AA.intSiteID = A.intSiteId
								AND DATEADD(dd, DATEDIFF(dd, 0, AA.dtmInvoiceDate),0) = DATEADD(dd, DATEDIFF(dd, 0, @dtmDateToProcess),0)
							GROUP BY AA.dtmInvoiceDate,AA.intSiteID
							ORDER BY AA.dtmInvoiceDate DESC
						)C
						WHERE  tblTMSite.intSiteID = A.intSiteId
						
					
						------------------------------------------------------------------------------

						--Update Next Delivery Degree Day and degree day Between
						UPDATE tblTMSite
						SET		intNextDeliveryDegreeDay = dblClockAccumulatedDegreeDay + (A.dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END))
								,dblDegreeDayBetweenDelivery = A.dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END)
						FROM #tmpSiteUpdateList A
						WHERE tblTMSite.intSiteID = A.intSiteId 

					
				

						--- Insert Dispatch to tblTMDispatchHistory table
						DELETE FROM @TMOrderHistoryStagingTable
						INSERT INTO @TMOrderHistoryStagingTable(
							intDispatchId
							,ysnDelete
							,intSourceType
							,intDeliveryHistoryId
						)
						SELECT DISTINCT
							intDispatchId				= intDispatchId
							,ysnDelete 					= 1
							,intSourceType				= 1
							,intDeliveryHistoryId		= B.intDeliveryHistoryId 
						FROM #tmpInvoiceDateGreaterThanLastDelivery A
						INNER JOIN @insertedHistory B
							ON A.intSiteId = B.intSiteId
						WHERE intDispatchId IS NOT NULL
							
						

						EXEC uspTMArchiveRestoreOrders @TMOrderHistoryStagingTable, @intUserId


						---- Update forecasted and estimated % left
						SET @siteId = (SELECT TOP 1 intSiteId FROM #tmpSiteUpdateList ORDER BY intSiteId ASC)
						WHILE ISNULL(@siteId,0) > 0
						BEGIN
							EXEC uspTMUpdateEstimatedValuesBySite @siteId
							EXEC uspTMUpdateForecastedValuesBySite @siteId
							EXEC uspTMUpdateNextJulianDeliveryBySite @siteId
						
							SET @siteId = (	SELECT TOP 1 intSiteId 
											FROM #tmpSiteUpdateList 
											WHERE intSiteId > @siteId 
											ORDER BY intSiteId ASC)
						END
					END
				END
				--------------------------------------------------------------------------------------------------
				------------------END Invoice date is greater than the last delivery date
				--------------------------------------------------------------------------------------------------


		NEXTREC:
		--- Loop Iterator
		SET @dtmDateToProcess = (SELECT TOP 1 dtmDate FROM #tmpTMInvoiceDateList WHERE dtmDate > @dtmDateToProcess ORDER BY dtmDate ASC)
	END			
END
GO
