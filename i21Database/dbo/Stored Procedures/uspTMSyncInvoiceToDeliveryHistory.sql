CREATE PROCEDURE uspTMSyncInvoiceToDeliveryHistory 
	@InvoiceId INT
	,@intUserId INT
	,@ResultLog NVARCHAR(MAX) OUTPUT
AS
BEGIN
	

	DECLARE @intSiteId INT
	DECLARE @intItemId INT
	DECLARE @intClockId INT
	DECLARE @intDegreeDays INT
	DECLARE @dblAccumulatedDegreeDay NUMERIC(18,6)
	DECLARE @intLastDegreeDays INT
	DECLARE @dblLastAccumulatedDegreeDay NUMERIC(18,6)
	DECLARE @intInvoiceDetailId INT
	DECLARE @dtmInvoiceDate DATETIME
	DECLARE @dtmLastDeliveryDate DATETIME
	DECLARE @intPerformerId INT
	DECLARE @strInvoiceNumber NVARCHAR(100)
	DECLARE @strInvoiceCompanyLocation NVARCHAR(100)
	DECLARE @intInvoiceCompanyLocationId INT
	DECLARE @ysnLessThanLastDeliveryDate BIT
	DECLARE @intClockReadingId INT
	DECLARE @intLastClockReadingId INT
	DECLARE @intElapseDays INT
	DECLARE @intElapseDegreeDays INT
	DECLARE @dblPercentAfterDelivery NUMERIC(18,6)
	DECLARE @dblQuantityShipped NUMERIC(18,6)
	DECLARE @dblTotalTax NUMERIC(18,6)
	DECLARE @dblItemTotal NUMERIC(18,6)
	DECLARE @dblNewBurnRate NUMERIC(18,6)
	DECLARE @intJulianCalendarFillId INT
	DECLARE @strTransactionType NVARCHAR(50)
	DECLARE @intPreviousDeliveryHistoryId INT
	DECLARE @intDeliveryHistoryInvoiceDetailId INT
	DECLARE @intNewDeliveryHistoryId INT
	DECLARE @intTopInvoiceDetailId INT
	DECLARE @strBillingBy NVARCHAR(15)
	DECLARE @intSeasonResetId INT
	DECLARE @dblLastAccumulatedDDOnSeasonReset NUMERIC(18,6)
	DECLARE @ysnMaxExceed BIT
	DECLARE @dtmCurrentSeasonStart DATETIME
	DECLARE @intAccumulatedDDAfterLastDeliveryBeforeReset INT
	DECLARE @intCustomerId INT
	DECLARE @intScreenId INT
	


	EXEC uspTMValidateInvoiceForSync @InvoiceId, @ResultLog OUT
	
	IF((SELECT CASE WHEN @ResultLog LIKE '%Exception%' THEN 1 ELSE 0 END) = 1)
	BEGIN
		GOTO DONESYNCHING
	END
	
	----------------------------------------------
	SELECT TOP 1
		@intScreenId = intScreenId
	FROM tblSMScreen 
	WHERE strModule = 'Tank Management'
		AND strNamespace = 'TankManagement.view.ConsumptionSite'

	----------------------------------------------


	PRINT 'Get invoice header detail'
	-----Get invoice header detail
	SELECT 
		@dtmInvoiceDate = DATEADD(DAY, DATEDIFF(DAY, 0, dtmDate), 0) 
		,@intInvoiceCompanyLocationId = intCompanyLocationId
		,@strTransactionType = strTransactionType
	FROM tblARInvoice
	WHERE intInvoiceId = @InvoiceId 
	
	-----Get Julian Calendar Fill Method ID
	SELECT
		@intJulianCalendarFillId = intFillMethodId
	FROM tblTMFillMethod
	WHERE strFillMethod = 'Julian Calendar'
	
	---Get Company Location
	SELECT
		@strInvoiceCompanyLocation = strLocationName
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intInvoiceCompanyLocationId


	---Get Invoice detail for Deliveries
	IF OBJECT_ID('tempdb..#tmpInvoiceDetail') IS NOT NULL DROP TABLE #tmpInvoiceDetail
	SELECT *
		,ysnTMProcessed = 0
	INTO #tmpInvoiceDetail
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @InvoiceId
		AND intSiteId IS NOT NULL
		AND ISNULL(ysnLeaseBilling,0) <> 1
		AND ISNULL(ysnVirtualMeterReading,0) <> 1
	
	-- Process Delivery
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpInvoiceDetail)
	BEGIN
		SET @intPerformerId = NULL
		SELECT TOP 1 
			@intSiteId = intSiteId 
			,@intItemId = intItemId
			,@intInvoiceDetailId = intInvoiceDetailId
			,@intPerformerId = intPerformerId
			,@dblPercentAfterDelivery = dblPercentFull
			,@dblQuantityShipped = dblQtyShipped
			,@dblTotalTax = dblTotalTax
			,@dblItemTotal = dblTotal
		FROM #tmpInvoiceDetail

		SELECT @strBillingBy = strBillingBy FROM tblTMSite WHERE intSiteID = @intSiteId
		
		print 'Check ysnProcessed'
		---Check ysnProcessed
		IF((SELECT TOP 1 ysnTMProcessed FROM #tmpInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId) = 1)
		BEGIN
			GOTO CONTINUELOOP
		END

		---- Set ysnProcessed to 1 for the current item
		UPDATE #tmpInvoiceDetail
		SET ysnTMProcessed = 1
		WHERE intInvoiceDetailId = @intInvoiceDetailId

		-------GEt site Detail
		SELECT @intClockId = intClockID
		,@dtmLastDeliveryDate = dtmLastDeliveryDate
		,@intCustomerId = intCustomerID
		FROM tblTMSite
		WHERE intSiteID = @intSiteId
		
		-----Get clock reading for the invoice date
		SELECT TOP 1
			@intDegreeDays = intDegreeDays
			,@dblAccumulatedDegreeDay = dblAccumulatedDegreeDay
			,@intClockReadingId = intDegreeDayReadingID
		FROM tblTMDegreeDayReading
		WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmInvoiceDate), 0) 
		
		IF((@dtmLastDeliveryDate IS NOT NULL) )
		BEGIN
			------Check if invoice date is less than or equal to site last delivery date
			IF(@dtmInvoiceDate <= @dtmLastDeliveryDate)
			BEGIN
				SET @ysnLessThanLastDeliveryDate = 1
			END
			
			----------Get clock reading for the last Delivery date
			SELECT TOP 1
				@intLastDegreeDays = intDegreeDays
				,@dblLastAccumulatedDegreeDay = dblAccumulatedDegreeDay
				,@intLastClockReadingId = intDegreeDayReadingID
			FROM tblTMDegreeDayReading
			WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmLastDeliveryDate), 0) 
			
		END
		
		
		---GET  Elapse Degree Day and Days
		IF(@dtmLastDeliveryDate IS NOT NULL AND @dtmInvoiceDate > @dtmLastDeliveryDate)
		BEGIN
			SET @intElapseDays = DATEDIFF(DAY,@dtmLastDeliveryDate,@dtmInvoiceDate)
		END
		ELSE
		BEGIN
			SET @intElapseDays = 0
		END


		---------------------------------------------------------------------------------
		---------------------------Lock CS Record----------------------------------------
		---------------------------------------------------------------------------------

		IF EXISTS(SELECT TOP 1 1 FROM tblSMTransaction WHERE intScreenId = @intScreenId AND intRecordId = @intCustomerId) 
		BEGIN
			UPDATE tblSMTransaction
			SET ysnLocked = 1
				,dtmDate = GETDATE()
				,intLockedBy = @intUserId
			WHERE intScreenId = @intScreenId AND intRecordId = @intCustomerId
		END
		ELSE
		BEGIN
			INSERT INTO tblSMTransaction(
				ysnLocked 
				,dtmDate
				,intLockedBy
				,intRecordId
				,intScreenId
			)
			SELECT 
				ysnLocked = 1
				,dtmDate = GETDATE()
				,intLockedBy = @intUserId
				,intRecordId = @intCustomerId
				,intScreenId = @intScreenId
		END

		---------------------------------------------------------------------------------
		---------------------------------------------------------------------------------



		
		PRINT 'BEGIN'
		
		----Check for service item
		IF((SELECT TOP 1 strType FROM tblICItem WHERE intItemId = @intItemId) = 'Service')
		BEGIN
			PRINT 'Service'
			---------- Create Service Event with the Event Automation
			SELECT TOP 1 @strInvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @InvoiceId
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
				DATEADD(DAY, DATEDIFF(DAY, 0, @dtmInvoiceDate), 0)
				,A.intEventTypeID
				,@intPerformerId
				,@intUserId
				,'Consumption Site'
				,B.strDescription + '. Invoice: ' + RTRIM(@strInvoiceNumber) + ' from ' + RTRIM(@strInvoiceCompanyLocation)
				,@intSiteId
			FROM tblTMEventAutomation A
			INNER JOIN tblTMEventType B
				ON A.intEventTypeID = B.intEventTypeID
			WHERE A.intItemId = @intItemId
				
			GOTO CONTINUELOOP
		END
		ELSE
		BEGIN
		----None Service Starts here	
			PRINT 'Non Service'

			------Check for multiple line item for a site
			IF OBJECT_ID('tempdb..#tmpSiteInvoiceLineItems') IS NOT NULL DROP TABLE #tmpSiteInvoiceLineItems

			SELECT A.* INTO #tmpSiteInvoiceLineItems
			FROM #tmpInvoiceDetail A
			INNER JOIN tblICItem B
				ON A.intItemId = B.intItemId
			WHERE intSiteId = @intSiteId
				AND  B.strType <> 'Service'
			ORDER BY dblPercentFull DESC, dblNewMeterReading DESC, intInvoiceDetailId ASC
			
			-----Get the detail that has the highest percentful after delivery
			SELECT TOP 1 @intTopInvoiceDetailId = intInvoiceDetailId FROM #tmpSiteInvoiceLineItems
			
			-----Mark Invoice detail that are of the same site as processed
			UPDATE #tmpInvoiceDetail 
			SET ysnTMProcessed = 1
			FROM  #tmpSiteInvoiceLineItems A
			WHERE #tmpInvoiceDetail.intInvoiceDetailId = A.intInvoiceDetailId
			
			
			
			IF(@ysnLessThanLastDeliveryDate = 1)
			BEGIN
				PRINT 'Left Over Invoice'
				IF(@dtmLastDeliveryDate = @dtmInvoiceDate AND EXISTS(SELECT TOP 1 1FROM tblTMDeliveryHistory WHERE intSiteID = @intSiteId AND dtmInvoiceDate = @dtmInvoiceDate AND ysnMeterReading <> 1))
				BEGIN
					PRINT 'Same date as the last delivery'
					
					-----Get the previous delivery record
					SELECT TOP 1 @intNewDeliveryHistoryId = intDeliveryHistoryID FROM tblTMDeliveryHistory WHERE intSiteID = @intSiteId AND dtmInvoiceDate = @dtmInvoiceDate AND ysnMeterReading <> 1
					
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
						intDeliveryHistoryID = @intNewDeliveryHistoryId
						,dblPercentAfterDelivery = ISNULL(dblPercentFull,0)
						,dblExtendedAmount = CASE WHEN @strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund' THEN 0 - (ISNULL(dblTotal,0) + ISNULL(dblTotalTax,0)) ELSE ISNULL(dblTotal,0) + ISNULL(dblTotalTax,0) END
						,dblQuantityDelivered = CASE WHEN @strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund' THEN 0 - dblQtyShipped ELSE dblQtyShipped END
						,strInvoiceNumber = B.strInvoiceNumber
						,strItemNumber = C.strItemNo
						,intInvoiceDetailId
					FROM #tmpSiteInvoiceLineItems A
					INNER JOIN tblARInvoice B
						ON A.intInvoiceId = B.intInvoiceId
					INNER JOIN tblICItem C
						ON A.intItemId = C.intItemId
						
					---- Update delivery History Table Header
					UPDATE tblTMDeliveryHistory
						SET dblActualPercentAfterDelivery = A.dblPercentAfterDelivery
						,strInvoiceNumber = A.strInvoiceNumber
						,strProductDelivered = A.strItemNumber
						,dblGallonsInTankAfterDelivery = A.dblGalsAfterDelivery
					FROM (
						SELECT TOP 1 
							Z.dblPercentAfterDelivery
							,Z.strInvoiceNumber
							,Z.strItemNumber
							,dblGalsAfterDelivery = ISNULL(Z.dblPercentAfterDelivery,0) * ISNULL(X.dblTotalCapacity,0) / 100
						FROM tblTMDeliveryHistoryDetail Z
						INNER JOIN tblTMDeliveryHistory Y
							ON Z.intDeliveryHistoryID = Y.intDeliveryHistoryID
						INNER JOIN tblTMSite X
							ON Y.intSiteID = X.intSiteID
						WHERE Z.intDeliveryHistoryID = @intNewDeliveryHistoryId
						ORDER BY Z.dblPercentAfterDelivery DESC, Z.intInvoiceDetailId ASC
					)A
					WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId
					
					UPDATE tblTMDeliveryHistory
					SET dblExtendedAmount = A.dblExtendedAmount
						,dblQuantityDelivered = A.dblQuantityDelivered
					FROM(
						SELECT TOP 1 
							dblExtendedAmount = SUM(ISNULL(dblExtendedAmount,0))
							,dblQuantityDelivered = SUM(ISNULL(dblQuantityDelivered,0))
						FROM tblTMDeliveryHistoryDetail
						WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId
					)A
					WHERE tblTMDeliveryHistory.intDeliveryHistoryID = @intNewDeliveryHistoryId
					
					---Update Site Info
					IF(@strBillingBy <> 'Virtual Meter')
					BEGIN
						--UPDATE tblTMSite
						--SET dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) + A.dblQuantityTotal 
						--	,dblYTDSales = ISNULL(dblYTDSales,0.0) + ISNULL(A.dblSalesTotal,0.0)
						--FROM(
						--	SELECT dblQuantityTotal = CASE WHEN @strTransactionType = 'Credit Memo' THEN 0 - SUM(ISNULL(dblQtyShipped,0)) ELSE SUM(ISNULL(dblQtyShipped,0)) END
						--		,dblSalesTotal = CASE WHEN @strTransactionType = 'Credit Memo' THEN 0 - (SUM(ISNULL(dblTotal,0)) + SUM(ISNULL(dblTotalTax,0))) ELSE SUM(ISNULL(dblTotal,0)) + SUM(ISNULL(dblTotalTax,0)) END
						--	FROM #tmpSiteInvoiceLineItems
						--)A
						--WHERE intSiteID = @intSiteId
						print 'Virtual Meter'
					END
					UPDATE tblTMSite
					SET dtmLastReadingUpdate = @dtmInvoiceDate
						,dblLastDeliveredGal = dblQuantityTotal
					FROM(
						SELECT dblQuantityTotal = SUM(ISNULL(dblQtyShipped,0))
							,dblSalesTotal = SUM(ISNULL(dblTotal,0)) + SUM(ISNULL(dblTotalTax,0))
						FROM #tmpSiteInvoiceLineItems
					)A
					WHERE intSiteID = @intSiteId
					
					---Update Site Estimated Gals and last gals in tank
					UPDATE tblTMSite
					SET dblEstimatedPercentLeft = A.dblPercentAfterDelivery
						,dblEstimatedGallonsLeft = ISNULL(A.dblPercentAfterDelivery,0.0) * tblTMSite.dblTotalCapacity /100
					FROM(
						SELECT   
							dblPercentAfterDelivery = MAX(dblPercentAfterDelivery)
						FROM tblTMDeliveryHistoryDetail 
						WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId
					)A
					WHERE tblTMSite.intSiteID = @intSiteId

					UPDATE tblTMSite
					SET dblLastDeliveredGal = A.dblShippedQuantity
						,dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(A.dblPercentAfterDelivery,0)/100
					FROM(
						SELECT   
							dblPercentAfterDelivery = MAX(dblPercentAfterDelivery)
							,dblShippedQuantity = SUM(ISNULL(dblQuantityDelivered,0.0))
						FROM tblTMDeliveryHistoryDetail	
						WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId	 
					)A
					WHERE tblTMSite.intSiteID = @intSiteId
					
					---- get the invoicedetail Id of the highest percent full
					SELECT TOP 1 @intTopInvoiceDetailId = intInvoiceDetailId 
					FROM tblTMDeliveryHistoryDetail 
					WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId
					ORDER BY dblPercentAfterDelivery DESC, intInvoiceDetailId ASC
					
					SET @ysnMaxExceed = 0
					SET @dblNewBurnRate = 0.0

					SELECT TOP 1 
						@dblNewBurnRate = dblBurnRate
						,@ysnMaxExceed = ysnMaxExceed
					FROM dbo.fnTMComputeNewBurnRateTable(@intSiteId,@intTopInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,0,@intNewDeliveryHistoryId)
					
					
					---Update Site Burn Rate, dblDegreeDayBetweenDelivery,intNextDeliveryDegreeDay based on the new calculated burn rate
					UPDATE tblTMSite
					SET dblBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 
											THEN ISNULL(@dblNewBurnRate,0.0)
											ELSE dblBurnRate 
										END)
						,dblDegreeDayBetweenDelivery = ISNULL(@dblNewBurnRate,0.0) * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END)
						,intNextDeliveryDegreeDay = @dblAccumulatedDegreeDay + (@dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END))
					WHERE intSiteID = @intSiteId



					----UPDATE Delivery history header for the new calc burnrate 
					UPDATE tblTMDeliveryHistory
						SET 
						dblBurnRateAfterDelivery = @dblNewBurnRate
						,dblCalculatedBurnRate = dbo.[fnTMGetCalculatedBurnRate](@intSiteId,@intTopInvoiceDetailId,@intClockReadingId,0,@intNewDeliveryHistoryId)
					WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId

					---Check Max exceed
					IF(@ysnMaxExceed = 1 OR (SELECT TOP 1 dblCalculatedBurnRate FROM tblTMDeliveryHistory WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId) < 0)
					BEGIN
						---Insert into out of range table
						IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMSyncOutOfRange WHERE intSiteID = @intSiteId AND DATEADD(dd, DATEDIFF(dd, 0, dtmDateSync),0) = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0))
						BEGIN
							INSERT INTO tblTMSyncOutOfRange
							(
								intSiteID
								,dtmDateSync
								,ysnCommit
							)
							SELECT 
								intSiteID		= @intSiteId
								,dtmDateSync	= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0)
								,ysnCommit		= 1
						END
						
					END
					
					---- Update forecasted nad estimated % left
					EXEC uspTMUpdateEstimatedValuesBySite @intSiteId
					EXEC uspTMUpdateForecastedValuesBySite @intSiteId
					EXEC uspTMUpdateNextJulianDeliveryBySite @intSiteId
				END
				ELSE
				BEGIN
					PRINT 'Previous Dates'
					IF EXISTS(SELECT TOP 1 1 FROM tblTMDeliveryHistory WHERE intSiteID = @intSiteId AND dtmInvoiceDate = @dtmInvoiceDate AND ysnMeterReading <> 1)
					BEGIN
						PRINT 'Has previous entry'
						
						-----Get the previous delivery record
						SELECT TOP 1 @intNewDeliveryHistoryId = intDeliveryHistoryID FROM tblTMDeliveryHistory WHERE intSiteID = @intSiteId AND dtmInvoiceDate = @dtmInvoiceDate AND ysnMeterReading <> 1
						
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
							intDeliveryHistoryID = @intNewDeliveryHistoryId
							,dblPercentAfterDelivery = ISNULL(dblPercentFull,0)
							,dblExtendedAmount = (CASE WHEN @strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund' THEN 0 - (ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)) ELSE ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0) END)
							,dblQuantityDelivered = (CASE WHEN @strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund' THEN 0 - A.dblQtyShipped ELSE A.dblQtyShipped END)
							,strInvoiceNumber = B.strInvoiceNumber
							,strItemNumber = C.strItemNo
							,intInvoiceDetailId
						FROM #tmpSiteInvoiceLineItems A
						INNER JOIN tblARInvoice B
							ON A.intInvoiceId = B.intInvoiceId
						INNER JOIN tblICItem C
							ON A.intItemId = C.intItemId
							
						---- Update delivery History Table Header
						UPDATE tblTMDeliveryHistory
							SET dblActualPercentAfterDelivery = A.dblPercentAfterDelivery
							,strInvoiceNumber = A.strInvoiceNumber
							,strProductDelivered = A.strItemNumber
							,dblGallonsInTankAfterDelivery = A.dblGalsAfterDelivery
						FROM (
							SELECT TOP 1 
								Z.dblPercentAfterDelivery
								,Z.strInvoiceNumber
								,Z.strItemNumber
								,dblGalsAfterDelivery = ISNULL(Z.dblPercentAfterDelivery,0) * ISNULL(X.dblTotalCapacity,0) / 100
							FROM tblTMDeliveryHistoryDetail Z
							INNER JOIN tblTMDeliveryHistory Y
								ON Z.intDeliveryHistoryID = Y.intDeliveryHistoryID
							INNER JOIN tblTMSite X
								ON Y.intSiteID = X.intSiteID
							WHERE Z.intDeliveryHistoryID = @intNewDeliveryHistoryId
							ORDER BY Z.dblPercentAfterDelivery DESC, Z.intInvoiceDetailId ASC
						)A
						WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId
						
						UPDATE tblTMDeliveryHistory
						SET dblExtendedAmount = A.dblExtendedAmount
							,dblQuantityDelivered = A.dblQuantityDelivered
						FROM(
							SELECT TOP 1 
								dblExtendedAmount = SUM(ISNULL(dblExtendedAmount,0))
								,dblQuantityDelivered = SUM(ISNULL(dblQuantityDelivered,0))
							FROM tblTMDeliveryHistoryDetail
							WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId
						)A
						WHERE tblTMDeliveryHistory.intDeliveryHistoryID = @intNewDeliveryHistoryId
						
						-----Update Site
						IF(@strBillingBy <> 'Virtual Meter')
						BEGIN
							--UPDATE tblTMSite
							--SET dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) + A.dblQuantityTotal
							--	,dblYTDSales = ISNULL(dblYTDSales,0.0) + A.dblSalesTotal
							--	,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
							--FROM(
							--	SELECT dblQuantityTotal = CASE WHEN @strTransactionType = 'Credit Memo' THEN 0 - SUM(ISNULL(dblQtyShipped,0)) ELSE dblQtyShipped END
							--		,dblSalesTotal = CASE WHEN @strTransactionType = 'Credit Memo' THEN 0 - (SUM(ISNULL(dblTotal,0)) + SUM(ISNULL(dblTotalTax,0))) ELSE SUM(ISNULL(dblTotal,0)) + SUM(ISNULL(dblTotalTax,0)) END
							--	FROM #tmpSiteInvoiceLineItems
							--)A
							--WHERE intSiteID = @intSiteId
							print 'Virtual Meter'
						END
					END
					ELSE
					BEGIN
						PRINT 'No previous entry'
						
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
						SELECT TOP 1
							strInvoiceNumber = C.strInvoiceNumber
							,strBulkPlantNumber = D.strLocationName
							,dtmInvoiceDate = C.dtmDate
							,strProductDelivered = E.strItemNo
							,dblQuantityDelivered = CASE WHEN @strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund' THEN 0 - (SELECT SUM(ISNULL(dblQtyShipped,0.0)) FROM #tmpSiteInvoiceLineItems) ELSE (SELECT SUM(ISNULL(dblQtyShipped,0.0)) FROM #tmpSiteInvoiceLineItems) END
							,intDegreeDayOnDeliveryDate = @dblAccumulatedDegreeDay
							,intDegreeDayOnLastDeliveryDate = @dblLastAccumulatedDegreeDay
							,dblBurnRateAfterDelivery = A.dblBurnRate
							,dblCalculatedBurnRate = A.dblBurnRate
							,ysnAdjustBurnRate = 0
							,intElapsedDegreeDaysBetweenDeliveries = 0
							,intElapsedDaysBetweenDeliveries = 0
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
							,dblExtendedAmount = CASE WHEN @strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund' THEN 0 - (SELECT SUM(ISNULL(dblTotal,0.0)) + SUM(ISNULL(dblTotalTax,0.0)) FROM #tmpSiteInvoiceLineItems) ELSE (SELECT SUM(ISNULL(dblTotal,0.0)) + SUM(ISNULL(dblTotalTax,0.0)) FROM #tmpSiteInvoiceLineItems) END
							,ysnForReview = 1
							,dtmMarkForReviewDate = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
							,dblWillCallCalculatedQuantity  = NULL
							,dblWillCallDesiredQuantity = NULL
							,intWillCallDriverId = NULL
							,intWillCallProductId = NULL
							,intWillCallSubstituteProductId = NULL
							,dblWillCallPrice = NULL
							,intWillCallDeliveryTermId = NULL
							,dtmWillCallRequestedDate = NULL
							,intWillCallPriority = NULL
							,dblWillCallTotal = NULL
							,strWillCallComments = NULL
							,dtmWillCallCallInDate = NULL
							,intWillCallUserId = NULL
							,ysnWillCallPrinted = NULL
							,dtmWillCallDispatch = NULL
							,strWillCallOrderNumber = NULL
							,intWillCallContractId = NULL
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
						INNER JOIN tblARInvoiceDetail B
							ON A.intSiteID = B.intSiteId
						INNER JOIN tblARInvoice C
							ON B.intInvoiceId = C.intInvoiceId
						INNER JOIN tblSMCompanyLocation D
							ON C.intCompanyLocationId = D.intCompanyLocationId
						INNER JOIN tblICItem E
							ON B.intItemId = E.intItemId
						INNER JOIN (SELECT TOP 1 * FROM #tmpSiteInvoiceLineItems) F
							ON B.intInvoiceDetailId = F.intInvoiceDetailId
						LEFT JOIN tblTMDispatch G
							ON A.intSiteID = G.intSiteID
						INNER JOIN tblTMClock H
							ON A.intClockID = H.intClockID
						LEFT JOIN tblEMEntity I
							ON I.intEntityId = C.intEntitySalespersonId
						
						SET @intNewDeliveryHistoryId = @@IDENTITY
						
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
							intDeliveryHistoryID = @intNewDeliveryHistoryId
							,dblPercentAfterDelivery = ISNULL(dblPercentFull,0)
							,dblExtendedAmount = CASE WHEN @strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund' THEN 0 - (ISNULL(dblTotal,0) + ISNULL(dblTotalTax,0)) ELSE ISNULL(dblTotal,0) + ISNULL(dblTotalTax,0) END
							,dblQuantityDelivered =  CASE WHEN @strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund' THEN 0 - dblQtyShipped ELSE dblQtyShipped END
							,strInvoiceNumber = B.strInvoiceNumber
							,strItemNumber = C.strItemNo
							,intInvoiceDetailId
						FROM #tmpSiteInvoiceLineItems A
						INNER JOIN tblARInvoice B
							ON A.intInvoiceId = B.intInvoiceId
						INNER JOIN tblICItem C
							ON A.intItemId = C.intItemId
							
						-----Update Site

						--IF(@strBillingBy <> 'Virtual Meter')
						--BEGIN
						--	UPDATE tblTMSite
						--	SET dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) + A.dblQuantityTotal
						--		,dblYTDSales = ISNULL(dblYTDSales,0.0) + A.dblSalesTotal
						--		,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
						--	FROM(
						--		SELECT dblQuantityTotal = SUM(ISNULL(dblQtyShipped,0))
						--			,dblSalesTotal = SUM(ISNULL(dblTotal,0)) + SUM(ISNULL(dblTotalTax,0))
						--		FROM #tmpSiteInvoiceLineItems
						--	)A
						--	WHERE intSiteID = @intSiteId
						--END
				
					END

					EXEC uspTMUpdateNextJulianDeliveryBySite @intSiteId
				END
			END
			ELSE
			BEGIN
				---------GET New Burn rate 
				SET @ysnMaxExceed = 0
				SET @dblNewBurnRate = 0.0

				SELECT TOP 1 
					@dblNewBurnRate = dblBurnRate
					,@ysnMaxExceed = ysnMaxExceed
				FROM dbo.fnTMComputeNewBurnRateTable(@intSiteId,@intTopInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,0,NULL) 


				IF(@strTransactionType = 'Invoice' OR @strTransactionType = 'Cash')
				BEGIN
					PRINT 'Invoice'
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
					SELECT TOP 1
						strInvoiceNumber = C.strInvoiceNumber
						,strBulkPlantNumber = D.strLocationName
						,dtmInvoiceDate = C.dtmDate
						,strProductDelivered = E.strItemNo
						,dblQuantityDelivered = (SELECT SUM(ISNULL(dblQtyShipped,0.0)) FROM #tmpSiteInvoiceLineItems)
						,intDegreeDayOnDeliveryDate = @dblAccumulatedDegreeDay
						,intDegreeDayOnLastDeliveryDate = @dblLastAccumulatedDegreeDay
						,dblBurnRateAfterDelivery = ISNULL(@dblNewBurnRate,0.0)
						,dblCalculatedBurnRate = dbo.[fnTMGetCalculatedBurnRate](A.intSiteID,@intTopInvoiceDetailId,@intClockReadingId,0,null)
						,ysnAdjustBurnRate = ISNULL(A.ysnAdjustBurnRate,0)
						,intElapsedDegreeDaysBetweenDeliveries = dbo.fnTMGetElapseDegreeDayForCalculation(@intSiteId,@intClockReadingId,null)
						,intElapsedDaysBetweenDeliveries = @intElapseDays
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
						,dblExtendedAmount = (SELECT SUM(ISNULL(dblTotal,0.0)) + SUM(ISNULL(dblTotalTax,0.0)) FROM #tmpSiteInvoiceLineItems)
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
					INNER JOIN tblARInvoiceDetail B
						ON A.intSiteID = B.intSiteId
					INNER JOIN tblARInvoice C
						ON B.intInvoiceId = C.intInvoiceId
					INNER JOIN tblSMCompanyLocation D
						ON C.intCompanyLocationId = D.intCompanyLocationId
					INNER JOIN tblICItem E
						ON B.intItemId = E.intItemId
					INNER JOIN (SELECT TOP 1 * FROM #tmpSiteInvoiceLineItems) F
						ON B.intInvoiceDetailId = F.intInvoiceDetailId
					LEFT JOIN tblTMDispatch G
						ON A.intSiteID = G.intSiteID
					INNER JOIN tblTMClock H
						ON A.intClockID = H.intClockID
					LEFT JOIN tblEMEntity I
						ON I.intEntityId = C.intEntitySalespersonId
					
					SET @intNewDeliveryHistoryId = @@IDENTITY
					
					---Check Max exceed
					IF(@ysnMaxExceed = 1 OR (SELECT TOP 1 dblCalculatedBurnRate FROM tblTMDeliveryHistory WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId) < 0)
					BEGIN
						---Insert into out of range table
						IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMSyncOutOfRange WHERE intSiteID = @intSiteId AND DATEADD(dd, DATEDIFF(dd, 0, dtmDateSync),0) = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0))
						BEGIN
							INSERT INTO tblTMSyncOutOfRange
							(
								intSiteID
								,dtmDateSync
								,ysnCommit
							)
							SELECT 
								intSiteID		= @intSiteId
								,dtmDateSync	= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0)
								,ysnCommit		= 1
						END
						
					END

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
						intDeliveryHistoryID = @intNewDeliveryHistoryId
						,dblPercentAfterDelivery = ISNULL(dblPercentFull,0)
						,dblExtendedAmount = ISNULL(dblTotal,0) + ISNULL(dblTotalTax,0)
						,dblQuantityDelivered = dblQtyShipped
						,strInvoiceNumber = B.strInvoiceNumber
						,strItemNumber = C.strItemNo
						,intInvoiceDetailId
					FROM #tmpSiteInvoiceLineItems A
					INNER JOIN tblARInvoice B
						ON A.intInvoiceId = B.intInvoiceId
					INNER JOIN tblICItem C
						ON A.intItemId = C.intItemId
			
					---Update Site Info
					--UPDATE tblTMSite
					--SET dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(@dblPercentAfterDelivery,0)/100
					--WHERE intSiteID = @intSiteId

					--IF(@strBillingBy <> 'Virtual Meter')
					--BEGIN
					--	UPDATE tblTMSite
					--	SET	dblYTDGalsThisSeason = dblYTDGalsThisSeason + @dblQuantityShipped
					--		,dblYTDSales = dblYTDSales + @dblItemTotal + @dblTotalTax
					--	WHERE intSiteID = @intSiteId
					--END

					
					

					UPDATE tblTMSite
					SET intLastDeliveryDegreeDay = @dblAccumulatedDegreeDay
						,dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(@dblPercentAfterDelivery,0)/100
						
						,dblLastDeliveredGal = @dblQuantityShipped
						,dtmLastDeliveryDate = @dtmInvoiceDate
						,dtmLastUpdated = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
						,ysnDeliveryTicketPrinted = 0
						,dblEstimatedPercentLeft = @dblPercentAfterDelivery
						,dblEstimatedGallonsLeft = dblTotalCapacity * @dblPercentAfterDelivery /100
						,dblPreviousBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 
													THEN dblBurnRate 
													ELSE dblPreviousBurnRate 
												END)
						,dblBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 
											THEN @dblNewBurnRate
											ELSE dblBurnRate 
										END)
						
						
						,dtmLastReadingUpdate = @dtmInvoiceDate
					WHERE intSiteID = @intSiteId


					----------------------- checking for season reset-------------------------
					SET @intAccumulatedDDAfterLastDeliveryBeforeReset = 0
					SET @dtmCurrentSeasonStart = NULL
					
					--Check Current season 
					SELECT TOP 1 @dtmCurrentSeasonStart = dtmDate 
					FROM tblTMDegreeDayReading
					WHERE ysnSeasonStart = 1 
						AND intClockID = @intClockId
						AND dtmDate > @dtmInvoiceDate
					ORDER BY dtmDate DESC

					IF(@dtmCurrentSeasonStart IS NOT NULL)
					BEGIN
						SELECT @intAccumulatedDDAfterLastDeliveryBeforeReset = SUM(intDegreeDays)
						FROM tblTMDegreeDayReading
						WHERE intClockID = @intClockId
							AND dtmDate < @dtmCurrentSeasonStart
							AND dtmDate > @dtmInvoiceDate

						SET @intAccumulatedDDAfterLastDeliveryBeforeReset = @dblAccumulatedDegreeDay + @intAccumulatedDDAfterLastDeliveryBeforeReset
					END

					
					------------------------------------------------------------------------------

					--Update Next Delivery Degree Day and degree day Between
					UPDATE tblTMSite
						SET	intNextDeliveryDegreeDay = @dblAccumulatedDegreeDay - @intAccumulatedDDAfterLastDeliveryBeforeReset + (@dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END))
						,dblDegreeDayBetweenDelivery = @dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END)
					WHERE intSiteID = @intSiteId

				
			
					----Update Next Julian Calendar Date of the site
					--TM-3174 - Remove this part that cause a blank for next julian calendar
					--UPDATE tblTMSite
					--SET dtmNextDeliveryDate = (CASE WHEN intFillMethodId = @intJulianCalendarFillId THEN dbo.fnTMGetNextJulianDeliveryDate(intSiteID) ELSE NULL END)
					--	,intConcurrencyId = intConcurrencyId + 1
					--WHERE intSiteID = @intSiteId
					
					---- Update forecasted nad estimated % left
					EXEC uspTMUpdateEstimatedValuesBySite @intSiteId
					EXEC uspTMUpdateForecastedValuesBySite @intSiteId
					EXEC uspTMUpdateNextJulianDeliveryBySite @intSiteId
					

					IF EXISTS(SELECT TOP 1 1 FROM tblTMDispatch WHERE intSiteID = @intSiteId)
					BEGIN
						--- Insert Dispatch to tblTMDispatchHistory table
						INSERT INTO tblTMDispatchHistory (
							[intDispatchId]            
							,[intSiteId]
							,[intDeliveryHistoryId]                
							,[dblPercentLeft]           
							,[dblQuantity]              
							,[dblMinimumQuantity]       
							,[intProductId]             
							,[intSubstituteProductId]   
							,[dblPrice]                 
							,[dblTotal]                 
							,[dtmRequestedDate]         
							,[intPriority]              
							,[strComments]              
							,[ysnCallEntryPrinted]      
							,[intDriverId]              
							,[intDispatchDriverId]      
							,[strDispatchLoadNumber]    
							,[dtmCallInDate]            
							,[ysnSelected]              
							,[strRoute]                 
							,[strSequence]              
							,[intUserId]                
							,[dtmLastUpdated]           
							,[ysnDispatched]            
							,[strCancelDispatchMessage] 
							,[intDeliveryTermId]        
							,[dtmDispatchingDate]       
							,[strWillCallStatus]			
							,[strPricingMethod]			
							,[strOrderNumber]			
							,[dtmDeliveryDate]			
							,[dblDeliveryQuantity]		
							,[dblDeliveryPrice]			
							,[dblDeliveryTotal]			
							,[intContractId]				
							,[ysnLockPrice]				
							,[intRouteId]				
							,[ysnReceived]				
							,[ysnLeakCheckRequired]
							,[dblOriginalPercentLeft]		
							,[dtmReceivedDate]
							,intPaymentId
						)	
						SELECT TOP 1 
							[intDispatchId]				= [intDispatchID]
							,[intSiteId]				= intSiteID
							,[intDeliveryHistoryId]		= @intNewDeliveryHistoryId             
							,[dblPercentLeft]           
							,[dblQuantity]              
							,[dblMinimumQuantity]       
							,[intProductId]				= [intProductID] 
							,[intSubstituteProductId]   = [intSubstituteProductID]
							,[dblPrice]                 
							,[dblTotal]                 
							,[dtmRequestedDate]         
							,[intPriority]              
							,[strComments]              
							,[ysnCallEntryPrinted]      
							,[intDriverId]              = [intDriverID]              
							,[intDispatchDriverId]		= [intDispatchDriverID]   
							,[strDispatchLoadNumber]    
							,[dtmCallInDate]            
							,[ysnSelected]              
							,[strRoute]                 
							,[strSequence]              
							,[intUserId]				= [intUserID]
							,[dtmLastUpdated]           
							,[ysnDispatched]            
							,[strCancelDispatchMessage] 
							,[intDeliveryTermId]		= [intDeliveryTermID] 
							,[dtmDispatchingDate]       
							,[strWillCallStatus]			
							,[strPricingMethod]			
							,[strOrderNumber]			
							,[dtmDeliveryDate]			
							,[dblDeliveryQuantity]		
							,[dblDeliveryPrice]			
							,[dblDeliveryTotal]			
							,[intContractId]				
							,[ysnLockPrice]				
							,[intRouteId]				
							,[ysnReceived]				
							,[ysnLeakCheckRequired]
							,[dblOriginalPercentLeft]
							,[dtmReceivedDate]
							,intPaymentId
						FROM tblTMDispatch
						WHERE intSiteID = @intSiteId
					END


					DELETE FROM tblTMDispatch
					WHERE intSiteID = @intSiteId
				END
				
			END
		END
		CONTINUELOOP:

		
		-------------------------------------------------------
		-------------------------Unlock Record
		-------------------------------------------------------
		UPDATE tblSMTransaction
		SET ysnLocked = 0
			,dtmDate = NULL
			,intLockedBy = NULL
		WHERE intScreenId = @intScreenId AND intRecordId = @intCustomerId

		-------------------------------------------------------
		-------------------------------------------------------
		

		DELETE FROM #tmpInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId
		PRINT 'DONE'
	END

-------------------------------------- Meter Reading--------------------------------------------------
	---Get Invoice detail for Virtual meter reading
	IF OBJECT_ID('tempdb..#tmpVirtualMeterInvoiceDetail') IS NOT NULL DROP TABLE #tmpVirtualMeterInvoiceDetail
	SELECT *
		,ysnTMProcessed = 0
	INTO #tmpVirtualMeterInvoiceDetail
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @InvoiceId
		AND intSiteId IS NOT NULL
		AND ISNULL(ysnLeaseBilling,0) <> 1
		AND ISNULL(ysnVirtualMeterReading,0) = 1
	
	---Process Virtual Meter Reading
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpVirtualMeterInvoiceDetail)
	BEGIN
		SET @intPerformerId = NULL
		SELECT TOP 1 
			@intSiteId = intSiteId 
			,@intItemId = intItemId
			,@intInvoiceDetailId = intInvoiceDetailId
			,@intPerformerId = intPerformerId
			,@dblPercentAfterDelivery = dblPercentFull
			,@dblQuantityShipped = dblQtyShipped
			,@dblTotalTax = dblTotalTax
			,@dblItemTotal = dblTotal
		FROM #tmpVirtualMeterInvoiceDetail

		--- INsert to delivery History
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
			,ysnMeterReading
			,intInvoiceId
			,intInvoiceDetailId
			,intWillCallRouteId
			,intWillCallDispatchId
			,ysnWillCallLeakCheckRequired
			,dblWillCallPercentLeft
			,dblWillCallOriginalPercentLeft
			,dtmNextDeliveryDate
			,dtmRunOutDate
			,dtmForecastedDelivery
		)
		SELECT TOP 1
			strInvoiceNumber = C.strInvoiceNumber
			,strBulkPlantNumber = D.strLocationName
			,dtmInvoiceDate = C.dtmDate
			,strProductDelivered = E.strItemNo
			,dblQuantityDelivered = CASE WHEN (@strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund') THEN 0 - ISNULL(B.dblQtyShipped,0.0) ELSE ISNULL(B.dblQtyShipped,0.0) END
			,intDegreeDayOnDeliveryDate = NULL
			,intDegreeDayOnLastDeliveryDate = NULL
			,dblBurnRateAfterDelivery = A.dblBurnRate
			,dblCalculatedBurnRate = A.dblBurnRate
			,ysnAdjustBurnRate = A.ysnAdjustBurnRate
			,intElapsedDegreeDaysBetweenDeliveries = 0
			,intElapsedDaysBetweenDeliveries = 0
			,strSeason = (CASE WHEN MONTH(C.dtmDate) >= H.intBeginSummerMonth AND  MONTH(C.dtmDate) < H.intBeginWinterMonth THEN 'Summer' ELSE 'Winter' END)
			,dblWinterDailyUsageBetweenDeliveries = A.dblWinterDailyUse
			,dblSummerDailyUsageBetweenDeliveries = A.dblSummerDailyUse
			,dblGallonsInTankbeforeDelivery = A.dblEstimatedGallonsLeft
			,dblGallonsInTankAfterDelivery = A.dblTotalCapacity * (ISNULL(B.dblPercentFull,0)/100)
			,dblEstimatedPercentBeforeDelivery = A.dblEstimatedPercentLeft
			,dblActualPercentAfterDelivery = B.dblPercentFull
			,dblMeterReading = B.dblNewMeterReading
			,dblLastMeterReading = B.dblPreviousMeterReading
			,intUserID = @intUserId
			,dtmLastUpdated = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
			,intSiteID = A.intSiteID
			,strSalesPersonID = I.strEntityNo
			,dblExtendedAmount = CASE WHEN (@strTransactionType = 'Credit Memo' OR @strTransactionType = 'Cash Refund') THEN 0 - ISNULL(B.dblTotal,0.0) ELSE ISNULL(B.dblTotal,0.0) END
			,ysnForReview = 0
			,dtmMarkForReviewDate = NULL
			,dblWillCallCalculatedQuantity  = NULL
			,dblWillCallDesiredQuantity = NULL
			,intWillCallDriverId = NULL
			,intWillCallProductId = NULL
			,intWillCallSubstituteProductId = NULL
			,dblWillCallPrice = NULL
			,intWillCallDeliveryTermId = NULL
			,dtmWillCallRequestedDate = NULL
			,intWillCallPriority = NULL
			,dblWillCallTotal = NULL
			,strWillCallComments = NULL
			,dtmWillCallCallInDate = NULL
			,intWillCallUserId = NULL
			,ysnWillCallPrinted = NULL
			,dtmWillCallDispatch = NULL
			,strWillCallOrderNumber = NULL
			,intWillCallContractId = NULL
			,ysnMeterReading = 1
			,intInvoiceId = C.intInvoiceId
			,intInvoiceDetailId = B.intInvoiceDetailId
			,intWillCallRouteId = G.intRouteId
			,intWillCallDispatchId = G.intDispatchID
			,ysnWillCallLeakCheckRequired = ISNULL(G.ysnLeakCheckRequired,0)
			,dblWillCallPercentLeft = G.dblPercentLeft
			,dblWillCallOriginalPercentLeft = G.dblOriginalPercentLeft
			,dtmNextDeliveryDate = A.dtmNextDeliveryDate
			,dtmRunOutDate = A.dtmRunOutDate
			,dtmForecastedDelivery = A.dtmForecastedDelivery
		FROM tblTMSite A
		INNER JOIN tblARInvoiceDetail B
			ON A.intSiteID = B.intSiteId
		INNER JOIN #tmpVirtualMeterInvoiceDetail J
			ON B.intInvoiceDetailId = J.intInvoiceDetailId
		INNER JOIN tblARInvoice C
			ON B.intInvoiceId = C.intInvoiceId
		INNER JOIN tblSMCompanyLocation D
			ON C.intCompanyLocationId = D.intCompanyLocationId
		INNER JOIN tblICItem E
			ON B.intItemId = E.intItemId
		LEFT JOIN tblTMDispatch G
			ON A.intSiteID = G.intSiteID
		INNER JOIN tblTMClock H
			ON A.intClockID = H.intClockID
		LEFT JOIN tblEMEntity I
			ON I.intEntityId = C.intEntitySalespersonId

		----Update Site Info
		--UPDATE tblTMSite
		--SET	dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) + CASE WHEN @strTransactionType = 'Credit Memo' THEN 0 - ISNULL(@dblQuantityShipped,0.0) ELSE ISNULL(@dblQuantityShipped,0.0) END
		--	,dblYTDSales = ISNULL(dblYTDSales,0.0) + CASE WHEN @strTransactionType = 'Credit Memo' THEN 0 - (ISNULL(@dblItemTotal,0.0) + ISNULL(@dblTotalTax,0.0)) ELSE ISNULL(@dblItemTotal,0.0) + ISNULL(@dblTotalTax,0.0) END
		--	,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
		--WHERE intSiteID = @intSiteId

		EXEC uspTMUpdateNextJulianDeliveryBySite @intSiteId

		
		DELETE FROM #tmpVirtualMeterInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId
	END
		
DONESYNCHING:
END

GO
