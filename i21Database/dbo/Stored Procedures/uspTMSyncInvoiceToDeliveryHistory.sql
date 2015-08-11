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
	


	EXEC uspTMValidateInvoiceForSync @InvoiceId, @ResultLog OUT
	
	IF((SELECT CASE WHEN @ResultLog LIKE '%Exception%' THEN 1 ELSE 0 END) = 1)
	BEGIN
		GOTO DONESYNCHING
	END
	
	-----Get invoice header total
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

	IF OBJECT_ID('tempdb..#tmpInvoiceDetail') IS NOT NULL DROP TABLE #tmpInvoiceDetail

	SELECT *
		,ysnTMProcessed = 0
	INTO #tmpInvoiceDetail
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @InvoiceId
		AND intSiteId IS NOT NULL
		
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
		
		IF((SELECT TOP 1 ysnTMProcessed FROM #tmpInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId) = 1)
		BEGIN
			GOTO CONTINUELOOP
		END

		---- Set ysnProcessed to 1 for the current item
		UPDATE #tmpInvoiceDetail
		SET ysnTMProcessed = 1
		WHERE intInvoiceDetailId = @intInvoiceDetailId

		-------Check for last Delivery Date
		SELECT @intClockId = intClockID
		,@dtmLastDeliveryDate = dtmLastDeliveryDate
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
			IF EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmLastDeliveryDate), 0) )
			BEGIN
				SELECT TOP 1
					@intLastDegreeDays = intDegreeDays
					,@dblLastAccumulatedDegreeDay = dblAccumulatedDegreeDay
					,@intLastClockReadingId = intDegreeDayReadingID
				FROM tblTMDegreeDayReading
				WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmLastDeliveryDate), 0) 
			END
			ELSE
			BEGIN
				SELECT TOP 1
					@intLastDegreeDays = intDegreeDays
					,@dblLastAccumulatedDegreeDay = dblAccumulatedDD
					,@intLastClockReadingId = intDDReadingID
				FROM tblTMDDReadingSeasonResetArchive
				WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmLastDeliveryDate), 0) 
			END
		END
		
		
		---GET  Elapse Degree Day and Days
		IF(@dtmLastDeliveryDate IS NOT NULL AND @dtmInvoiceDate > @dtmLastDeliveryDate)
		BEGIN
			SET @intElapseDays = DATEDIFF(DAY,@dtmInvoiceDate,@dtmLastDeliveryDate)
		END
		ELSE
		BEGIN
			SET @intElapseDays = 0
		END
		
		
		----Check for service item
		IF((SELECT TOP 1 strType FROM tblICItem WHERE intItemId = @intItemId) = 'Service')
		BEGIN
			PRINT 'Service'
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
				
			---- Update consumption Site
			UPDATE tblTMSite
			SET intLastDeliveryDegreeDay = @dblAccumulatedDegreeDay
				,dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(@dblPercentAfterDelivery,0)/100
				,dblYTDGalsThisSeason = dblYTDGalsThisSeason + @dblQuantityShipped
				,dblYTDSales = dblYTDSales + @dblItemTotal + @dblTotalTax
				,dblLastDeliveredGal = @dblQuantityShipped
				,dtmLastDeliveryDate = @dtmInvoiceDate
				,dtmLastUpdated = GETDATE()
				,ysnDeliveryTicketPrinted = 0
				,dblPreviousBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 THEN dblBurnRate ELSE dblPreviousBurnRate END)
				,dblBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 THEN dbo.[fnTMComputeNewBurnRate](@intSiteId,@intInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,0) ELSE dblBurnRate END)
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intSiteID = @intSiteId
				
				
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
			ORDER BY dblPercentFull DESC,intInvoiceDetailId ASC
			
			IF((SELECT COUNT(intInvoiceDetailId) FROM #tmpSiteInvoiceLineItems) > 1)
			BEGIN
				---Multiple Invoice Begin Here
				PRINT 'Multiple Invoice'
				---------GET New Burn rate 
				SET @dblNewBurnRate = dbo.[fnTMComputeNewBurnRate](@intSiteId,@intInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,1) 
				IF(@ysnLessThanLastDeliveryDate = 1)
				BEGIN
					PRINT 'Left Over'
					IF(@strTransactionType = 'Invoice')
					BEGIN
						PRINT 'Invoice'
						----- Check for previous deliveries with same date
						IF EXISTS(SELECT TOP 1 1 FROM tblTMDeliveryHistory WHERE dtmInvoiceDate = @dtmInvoiceDate AND intSiteID = @intSiteId)
						BEGIN
							PRINT 'Has previous transaction'
							SELECT TOP 1 @intPreviousDeliveryHistoryId = intDeliveryHistoryID
								,@intDeliveryHistoryInvoiceDetailId = intInvoiceDetailId
							FROM tblTMDeliveryHistory WHERE dtmInvoiceDate = @dtmInvoiceDate AND intSiteID = @intSiteId

							------Check if have Delivery Detail Records
							IF EXISTS(SELECT TOP 1 1 FROM tblTMDeliveryHistoryDetail WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId)
							BEGIN
								PRINT 'With Existing Delivery Detail'
							END
							ELSE
							BEGIN
								PRINT 'Without Existing Delivery Detail'
								--- insert Header to detail
								INSERT INTO tblTMDeliveryHistoryDetail(
									strInvoiceNumber
									,dblQuantityDelivered
									,strItemNumber
									,intDeliveryHistoryID
									,dblPercentAfterDelivery
									,dblExtendedAmount
									,intInvoiceDetailId
								)
								SELECT TOP 1 
									strInvoiceNumber = A.strInvoiceNumber
									,dblQuantityDelivered = A.dblQuantityDelivered
									,strItemNumber = A.strProductDelivered
									,intDeliveryHistoryID = A.intDeliveryHistoryID
									,dblPercentAfterDelivery = dblActualPercentAfterDelivery
									,dblExtendedAmount = ISNULL(B.dblTotal,0) + ISNULL(B.dblTotalTax,0)
									,intInvoiceDetailId = A.intInvoiceDetailId
								FROM tblTMDeliveryHistory A
								INNER JOIN tblARInvoiceDetail B
									ON A.intInvoiceDetailId = B.intInvoiceDetailId
								WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId	
							END

						
							----- Insert Invoicedetail to History Detail
							INSERT INTO tblTMDeliveryHistoryDetail(
								strInvoiceNumber
								,dblQuantityDelivered
								,strItemNumber
								,intDeliveryHistoryID
								,dblPercentAfterDelivery
								,dblExtendedAmount
								,intInvoiceDetailId
							)
							SELECT 
								strInvoiceNumber = B.strInvoiceNumber
								,dblQuantityDelivered = A.dblQtyShipped
								,strItemNumber = C.strItemNo
								,intDeliveryHistoryID = @intPreviousDeliveryHistoryId
								,dblPercentAfterDelivery = A.dblPercentFull
								,dblExtendedAmount = ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)
								,intInvoiceDetailId = A.intInvoiceDetailId
							FROM #tmpSiteInvoiceLineItems A
							INNER JOIN tblARInvoice B
								ON A.intInvoiceId = B.intInvoiceId
							INNER JOIN tblICItem C
								ON A.intItemId = C.intItemId
							WHERE A.intInvoiceDetailId <> ISNULL((SELECT intInvoiceDetailId FROM tblTMDeliveryHistory WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId),0)
							

							----Check which has higher percent after delivery AND update delivery Header
							IF((SELECT dblActualPercentAfterDelivery FROM tblTMDeliveryHistory WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId) < (SELECT TOP 1 dblPercentFull FROM #tmpSiteInvoiceLineItems ORDER BY dblPercentFull DESC,intInvoiceDetailId ASC))
							BEGIN
								PRINT 'Detail has higher %'
								UPDATE tblTMDeliveryHistory
								SET	intInvoiceDetailId = NULL
									,strInvoiceNumber = Z.strInvoiceNumber
									,dblActualPercentAfterDelivery = Z.dblPercentFull
									,strProductDelivered = Z.strItemNo
								FROM (
									SELECT TOP 1
										B.strInvoiceNumber
										,C.strItemNo
										,A.dblPercentFull
										,dblExtendedAmount = ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)
									FROM #tmpSiteInvoiceLineItems A
									INNER JOIN tblARInvoice B
										ON A.intInvoiceId = B.intInvoiceId
									INNER JOIN tblICItem C
										ON A.intItemId = C.intItemId 
									ORDER BY A.dblPercentFull DESC, A.intInvoiceDetailId ASC
								)Z
								WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId

							END

							----Update Header Quantity Delivered and extended amount Based on Detail total and set intInvoiceDetailId to null
							UPDATE tblTMDeliveryHistory
							SET dblQuantityDelivered = (SELECT SUM(ISNULL(dblQuantityDelivered,0)) FROM tblTMDeliveryHistoryDetail WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId)
								,dblExtendedAmount = (SELECT SUM(ISNULL(dblExtendedAmount,0)) FROM tblTMDeliveryHistoryDetail WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId)
								,intInvoiceDetailId = NULL
							WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId

							---Update Site Info
							UPDATE tblTMSite
							SET 
								dblYTDGalsThisSeason = dblYTDGalsThisSeason + ISNULL((SELECT SUM(ISNULL(dblQtyShipped,0)) FROM #tmpSiteInvoiceLineItems),0)
								,dblYTDSales = dblYTDSales + ISNULL((SELECT SUM(ISNULL(dblTotal,0) + ISNULL(dblTotalTax,0)) FROM #tmpSiteInvoiceLineItems),0)
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intSiteID = @intSiteId

							---- Mark the invoice details as processed for the site
							UPDATE #tmpInvoiceDetail
							SET ysnTMProcessed = 1
							FROM #tmpSiteInvoiceLineItems A
							WHERE #tmpInvoiceDetail.intInvoiceDetailId = A.intInvoiceDetailId

						END
						ELSE
						BEGIN
							PRINT 'No Previous Transaction'
							---- Insert Header
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
								,intInvoiceId
					
							)
							SELECT TOP 1
								strInvoiceNumber = C.strInvoiceNumber
								,strBulkPlantNumber = D.strLocationName
								,dtmInvoiceDate = C.dtmDate
								,strProductDelivered = E.strItemNo
								,dblQuantityDelivered = B.dblQtyShipped
								,intDegreeDayOnDeliveryDate = @dblAccumulatedDegreeDay
								,intDegreeDayOnLastDeliveryDate = @dblLastAccumulatedDegreeDay
								,dblBurnRateAfterDelivery = dbo.[fnTMComputeNewBurnRate](A.intSiteID,B.intInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,1)
								,dblCalculatedBurnRate = dbo.[fnTMGetCalculatedBurnRate](A.intSiteID,B.intInvoiceDetailId,@intClockReadingId,1)
								,ysnAdjustBurnRate = ISNULL(A.ysnAdjustBurnRate,0)
								,intElapsedDegreeDaysBetweenDeliveries = 0
								,intElapsedDaysBetweenDeliveries = 0
								,strSeason = H.strCurrentSeason
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
								,strSalesPersonID = I.strSalespersonId
								,dblExtendedAmount = B.dblTotal + ISNULL(B.dblTotalTax,0.0)
								,ysnForReview = 1
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
								,intInvoiceId = C.intInvoiceId
							FROM tblTMSite A
							INNER JOIN tblARInvoiceDetail B
								ON A.intSiteID = B.intSiteId
							INNER JOIN tblARInvoice C
								ON B.intInvoiceId = C.intInvoiceId
							INNER JOIN tblSMCompanyLocation D
								ON C.intCompanyLocationId = D.intCompanyLocationId
							INNER JOIN tblICItem E
								ON B.intItemId = E.intItemId
							INNER JOIN #tmpSiteInvoiceLineItems F
								ON B.intInvoiceDetailId = F.intInvoiceDetailId
							LEFT JOIN tblTMDispatch G
								ON A.intSiteID = G.intSiteID
							INNER JOIN tblTMClock H
								ON A.intClockID = H.intClockID
							LEFT JOIN tblARSalesperson I
								ON I.intEntitySalespersonId = C.intEntitySalespersonId
							ORDER BY F.dblPercentFull DESC,F.intInvoiceDetailId ASC

							SET @intNewDeliveryHistoryId = @@IDENTITY

							---- INSERT Delivery History Details
							INSERT INTO tblTMDeliveryHistoryDetail(
								strInvoiceNumber
								,dblQuantityDelivered
								,strItemNumber
								,intDeliveryHistoryID
								,dblPercentAfterDelivery
								,dblExtendedAmount
								,intInvoiceDetailId
							)
							SELECT 
								strInvoiceNumber = B.strInvoiceNumber
								,dblQuantityDelivered = A.dblQtyShipped
								,strItemNumber = C.strItemNo
								,intDeliveryHistoryID = @intNewDeliveryHistoryId
								,dblPercentAfterDelivery = A.dblPercentFull
								,dblExtendedAmount = ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)
								,intInvoiceDetailId = A.intInvoiceDetailId
							FROM #tmpSiteInvoiceLineItems A
							INNER JOIN tblARInvoice B
								ON A.intInvoiceId = B.intInvoiceId
							INNER JOIN tblICItem C
								ON A.intItemId = C.intItemId
						
							-----GET totals of the invoice details
							SELECT TOP 1 
								@dblPercentAfterDelivery = dblPercentFull 
							FROM #tmpSiteInvoiceLineItems

							SET @dblQuantityShipped = (SELECT SUM(ISNULL(dblQtyShipped,0)) FROM #tmpSiteInvoiceLineItems)
							SET @dblItemTotal = (SELECT SUM(ISNULL(dblTotal,0)) FROM #tmpSiteInvoiceLineItems)
							SET @dblTotalTax = (SELECT SUM(ISNULL(dblTotalTax,0)) FROM #tmpSiteInvoiceLineItems)

							----Update Header Quantity Delivered and extended amount Based on Detail total and set intInvoiceDetailId to null
							UPDATE tblTMDeliveryHistory
							SET dblQuantityDelivered = @dblQuantityShipped
								,dblExtendedAmount = @dblItemTotal + @dblTotalTax
								,intInvoiceDetailId = NULL
							WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId

						
						
							---Update Site Info
							UPDATE tblTMSite
							SET intLastDeliveryDegreeDay = @dblAccumulatedDegreeDay
								,dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(@dblPercentAfterDelivery,0)/100
								,dblYTDGalsThisSeason = dblYTDGalsThisSeason + @dblQuantityShipped
								,dblYTDSales = dblYTDSales + @dblItemTotal + @dblTotalTax
								,dblLastDeliveredGal = @dblQuantityShipped
								,dtmLastDeliveryDate = @dtmInvoiceDate
								,dtmLastUpdated = GETDATE()
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
								,dblDegreeDayBetweenDelivery = @dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END)
								,intNextDeliveryDegreeDay = @dblAccumulatedDegreeDay + (@dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END))
								,dtmLastReadingUpdate = @dtmInvoiceDate
							WHERE intSiteID = @intSiteId
					
				
							----Update Next Julian Calendar Date of the site
							UPDATE tblTMSite
							SET dtmNextDeliveryDate = (CASE WHEN intFillMethodId = @intJulianCalendarFillId THEN dbo.fnTMGetNextJulianDeliveryDate(intSiteID) ELSE NULL END)
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intSiteID = @intSiteId

							---- Mark the invoice details as processed for the site
							UPDATE #tmpInvoiceDetail
							SET ysnTMProcessed = 1
							FROM #tmpSiteInvoiceLineItems A
							WHERE #tmpInvoiceDetail.intInvoiceDetailId = A.intInvoiceDetailId
						END
					END
				END
				ELSE
				BEGIN
					PRINT 'Standard Multiple'
					
					IF(@strTransactionType = 'Invoice')
					BEGIN
						PRINT 'Invoice'
						---- Insert Header
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
							,intInvoiceId
					
						)
						SELECT TOP 1
							strInvoiceNumber = C.strInvoiceNumber
							,strBulkPlantNumber = D.strLocationName
							,dtmInvoiceDate = C.dtmDate
							,strProductDelivered = E.strItemNo
							,dblQuantityDelivered = B.dblQtyShipped
							,intDegreeDayOnDeliveryDate = @dblAccumulatedDegreeDay
							,intDegreeDayOnLastDeliveryDate = @dblLastAccumulatedDegreeDay
							,dblBurnRateAfterDelivery = dbo.[fnTMComputeNewBurnRate](A.intSiteID,B.intInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,1)
							,dblCalculatedBurnRate = dbo.[fnTMGetCalculatedBurnRate](A.intSiteID,B.intInvoiceDetailId,@intClockReadingId,1)
							,ysnAdjustBurnRate = ISNULL(A.ysnAdjustBurnRate,0)
							,intElapsedDegreeDaysBetweenDeliveries = dbo.fnTMGetElapseDegreeDayForCalculation(@intSiteId,@intInvoiceDetailId)
							,intElapsedDaysBetweenDeliveries = @intElapseDays
							,strSeason = H.strCurrentSeason
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
							,strSalesPersonID = I.strSalespersonId
							,dblExtendedAmount = B.dblTotal + ISNULL(B.dblTotalTax,0.0)
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
							,intInvoiceId = C.intInvoiceId
						FROM tblTMSite A
						INNER JOIN tblARInvoiceDetail B
							ON A.intSiteID = B.intSiteId
						INNER JOIN tblARInvoice C
							ON B.intInvoiceId = C.intInvoiceId
						INNER JOIN tblSMCompanyLocation D
							ON C.intCompanyLocationId = D.intCompanyLocationId
						INNER JOIN tblICItem E
							ON B.intItemId = E.intItemId
						INNER JOIN #tmpSiteInvoiceLineItems F
							ON B.intInvoiceDetailId = F.intInvoiceDetailId
						LEFT JOIN tblTMDispatch G
							ON A.intSiteID = G.intSiteID
						INNER JOIN tblTMClock H
							ON A.intClockID = H.intClockID
						LEFT JOIN tblARSalesperson I
							ON I.intEntitySalespersonId = C.intEntitySalespersonId
						ORDER BY F.dblPercentFull DESC,F.intInvoiceDetailId ASC

						SET @intNewDeliveryHistoryId = @@IDENTITY

						---- INSERT Delivery History Details
						INSERT INTO tblTMDeliveryHistoryDetail(
							strInvoiceNumber
							,dblQuantityDelivered
							,strItemNumber
							,intDeliveryHistoryID
							,dblPercentAfterDelivery
							,dblExtendedAmount
							,intInvoiceDetailId
						)
						SELECT 
							strInvoiceNumber = B.strInvoiceNumber
							,dblQuantityDelivered = A.dblQtyShipped
							,strItemNumber = C.strItemNo
							,intDeliveryHistoryID = @intNewDeliveryHistoryId
							,dblPercentAfterDelivery = A.dblPercentFull
							,dblExtendedAmount = ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)
							,intInvoiceDetailId = A.intInvoiceDetailId
						FROM #tmpSiteInvoiceLineItems A
						INNER JOIN tblARInvoice B
							ON A.intInvoiceId = B.intInvoiceId
						INNER JOIN tblICItem C
							ON A.intItemId = C.intItemId
						
						-----GET totals of the invoice details
						SELECT TOP 1 
							@dblPercentAfterDelivery = dblPercentFull 
						FROM #tmpSiteInvoiceLineItems

						SET @dblQuantityShipped = (SELECT SUM(ISNULL(dblQtyShipped,0)) FROM #tmpSiteInvoiceLineItems)
						SET @dblItemTotal = (SELECT SUM(ISNULL(dblTotal,0)) FROM #tmpSiteInvoiceLineItems)
						SET @dblTotalTax = (SELECT SUM(ISNULL(dblTotalTax,0)) FROM #tmpSiteInvoiceLineItems)

						----Update Header Quantity Delivered and extended amount Based on Detail total and set intInvoiceDetailId to null
						UPDATE tblTMDeliveryHistory
						SET dblQuantityDelivered = @dblQuantityShipped
							,dblExtendedAmount = @dblItemTotal + @dblTotalTax
							,intInvoiceDetailId = NULL
						WHERE intDeliveryHistoryID = @intNewDeliveryHistoryId

						
						
						---Update Site Info
						UPDATE tblTMSite
						SET intLastDeliveryDegreeDay = @dblAccumulatedDegreeDay
							,dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(@dblPercentAfterDelivery,0)/100
							,dblYTDGalsThisSeason = dblYTDGalsThisSeason + @dblQuantityShipped
							,dblYTDSales = dblYTDSales + @dblItemTotal + @dblTotalTax
							,dblLastDeliveredGal = @dblQuantityShipped
							,dtmLastDeliveryDate = @dtmInvoiceDate
							,dtmLastUpdated = GETDATE()
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
							,dblDegreeDayBetweenDelivery = @dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END)
							,intNextDeliveryDegreeDay = @dblAccumulatedDegreeDay + (@dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END))
							,dtmLastReadingUpdate = @dtmInvoiceDate
						WHERE intSiteID = @intSiteId
					
				
						----Update Next Julian Calendar Date of the site
						UPDATE tblTMSite
						SET dtmNextDeliveryDate = (CASE WHEN intFillMethodId = @intJulianCalendarFillId THEN dbo.fnTMGetNextJulianDeliveryDate(intSiteID) ELSE NULL END)
							,intConcurrencyId = intConcurrencyId + 1
						WHERE intSiteID = @intSiteId

						---- Mark the invoice details as processed for the site
						UPDATE #tmpInvoiceDetail
						SET ysnTMProcessed = 1
						FROM #tmpSiteInvoiceLineItems A
						WHERE #tmpInvoiceDetail.intInvoiceDetailId = A.intInvoiceDetailId

					END
				END
			END
			ELSE
			BEGIN
				---Single Invoice Begin Here
				PRINT 'Single Invoice'
				---------GET New Burn rate 
				SET @dblNewBurnRate = dbo.[fnTMComputeNewBurnRate](@intSiteId,@intInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,0) 
				
				IF(@ysnLessThanLastDeliveryDate = 1)
				BEGIN
					----Left-over Invoices
					PRINT 'Single left over Invoice'
					IF(@strTransactionType = 'Invoice')
					BEGIN
						PRINT 'INVOICE'
						----- Check for previous deliveries with same date
						IF EXISTS(SELECT TOP 1 1 FROM tblTMDeliveryHistory WHERE dtmInvoiceDate = @dtmInvoiceDate AND intSiteID = @intSiteId)
						BEGIN
							PRINT 'Has previous transaction'
							SELECT TOP 1 @intPreviousDeliveryHistoryId = intDeliveryHistoryID
								,@intDeliveryHistoryInvoiceDetailId = intInvoiceDetailId
							FROM tblTMDeliveryHistory WHERE dtmInvoiceDate = @dtmInvoiceDate AND intSiteID = @intSiteId

							------Check if have Delivery Detail Records
							IF EXISTS(SELECT TOP 1 1 FROM tblTMDeliveryHistoryDetail WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId)
							BEGIN
								PRINT 'With Existing Delivery Detail'

							END
							ELSE
							BEGIN
								PRINT 'Without Existing Delivery Detail'

								--- insert Header to detail
								INSERT INTO tblTMDeliveryHistoryDetail(
									strInvoiceNumber
									,dblQuantityDelivered
									,strItemNumber
									,intDeliveryHistoryID
									,dblPercentAfterDelivery
									,dblExtendedAmount
									,intInvoiceDetailId
								)
								SELECT TOP 1 
									strInvoiceNumber = A.strInvoiceNumber
									,dblQuantityDelivered = A.dblQuantityDelivered
									,strItemNumber = A.strProductDelivered
									,intDeliveryHistoryID = A.intDeliveryHistoryID
									,dblPercentAfterDelivery = dblActualPercentAfterDelivery
									,dblExtendedAmount = ISNULL(B.dblTotal,0) + ISNULL(B.dblTotalTax,0)
									,intInvoiceDetailId = A.intInvoiceDetailId
								FROM tblTMDeliveryHistory A
								INNER JOIN tblARInvoiceDetail B
									ON A.intInvoiceDetailId = B.intInvoiceDetailId
								WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId					
							END

							----- Insert Invoicedetail to History Detail
							INSERT INTO tblTMDeliveryHistoryDetail(
								strInvoiceNumber
								,dblQuantityDelivered
								,strItemNumber
								,intDeliveryHistoryID
								,dblPercentAfterDelivery
								,dblExtendedAmount
								,intInvoiceDetailId
							)
							SELECT 
								strInvoiceNumber = B.strInvoiceNumber
								,dblQuantityDelivered = A.dblQtyShipped
								,strItemNumber = C.strItemNo
								,intDeliveryHistoryID = @intPreviousDeliveryHistoryId
								,dblPercentAfterDelivery = A.dblPercentFull
								,dblExtendedAmount = ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)
								,intInvoiceDetailId = A.intInvoiceDetailId
							FROM #tmpSiteInvoiceLineItems A
							INNER JOIN tblARInvoice B
								ON A.intInvoiceId = B.intInvoiceId
							INNER JOIN tblICItem C
								ON A.intItemId = C.intItemId
							WHERE intInvoiceDetailId <> ISNULL((SELECT intInvoiceDetailId FROM tblTMDeliveryHistory WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId),0)


							----Check which has higher percent after delivery AND update delivery Header
							IF((SELECT dblActualPercentAfterDelivery FROM tblTMDeliveryHistory WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId) < (SELECT TOP 1 dblPercentFull FROM #tmpSiteInvoiceLineItems))
							BEGIN
								UPDATE tblTMDeliveryHistory
								SET	intInvoiceDetailId = NULL
									,strInvoiceNumber = Z.strInvoiceNumber
								FROM (
									SELECT TOP 1
										B.strInvoiceNumber
										,C.strItemNo
										,A.dblPercentFull
										,dblExtendedAmount = ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)
										,strProductDelivered = Z.strItemNo
									FROM #tmpSiteInvoiceLineItems A
									INNER JOIN tblARInvoice B
										ON A.intInvoiceId = B.intInvoiceId
									INNER JOIN tblICItem C
										ON A.intItemId = C.intItemId 
									ORDER BY A.dblPercentFull DESC, A.intInvoiceDetailId ASC
								)Z
								WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId
							END

							----Update Header Quantity Delivered and extended amount Based on Detail total and set intInvoiceDetailId to null
							UPDATE tblTMDeliveryHistory
							SET dblQuantityDelivered = (SELECT SUM(ISNULL(dblQuantityDelivered,0)) FROM tblTMDeliveryHistoryDetail WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId)
								,dblExtendedAmount = (SELECT SUM(ISNULL(dblExtendedAmount,0)) FROM tblTMDeliveryHistoryDetail WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId)
								,intInvoiceDetailId = NULL
							WHERE intDeliveryHistoryID = @intPreviousDeliveryHistoryId

							---Update Site Info
							UPDATE tblTMSite
							SET 
								dblYTDGalsThisSeason = dblYTDGalsThisSeason + ISNULL((SELECT SUM(ISNULL(dblQtyShipped,0)) FROM #tmpSiteInvoiceLineItems),0)
								,dblYTDSales = dblYTDSales + ISNULL((SELECT SUM(ISNULL(dblTotal,0) + ISNULL(dblTotalTax,0)) FROM #tmpSiteInvoiceLineItems),0)
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intSiteID = @intSiteId
						END
						ELSE
						BEGIN
							PRINT 'No Previous Transaction'
							---- Insert Delivery History
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
								,intInvoiceId
								,intInvoiceDetailId
					
							)
							SELECT
								strInvoiceNumber = C.strInvoiceNumber
								,strBulkPlantNumber = D.strLocationName
								,dtmInvoiceDate = C.dtmDate
								,strProductDelivered = E.strItemNo
								,dblQuantityDelivered = B.dblQtyShipped
								,intDegreeDayOnDeliveryDate = @dblAccumulatedDegreeDay
								,intDegreeDayOnLastDeliveryDate = @dblLastAccumulatedDegreeDay
								,dblBurnRateAfterDelivery = A.dblBurnRate
								,dblCalculatedBurnRate = A.dblBurnRate
								,ysnAdjustBurnRate = 0
								,intElapsedDegreeDaysBetweenDeliveries = 0
								,intElapsedDaysBetweenDeliveries = 0
								,strSeason = H.strCurrentSeason
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
								,strSalesPersonID = I.strSalespersonId
								,dblExtendedAmount = B.dblTotal + ISNULL(B.dblTotalTax,0.0)
								,ysnForReview = 1
								,dtmMarkForReviewDate = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
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
								,intInvoiceId = C.intInvoiceId
								,intInvoiceDetailId = F.intInvoiceDetailId
							FROM tblTMSite A
							INNER JOIN tblARInvoiceDetail B
								ON A.intSiteID = B.intSiteId
							INNER JOIN tblARInvoice C
								ON B.intInvoiceId = C.intInvoiceId
							INNER JOIN tblSMCompanyLocation D
								ON C.intCompanyLocationId = D.intCompanyLocationId
							INNER JOIN tblICItem E
								ON B.intItemId = E.intItemId
							INNER JOIN #tmpSiteInvoiceLineItems F
								ON B.intInvoiceDetailId = F.intInvoiceDetailId
							LEFT JOIN tblTMDispatch G
								ON A.intSiteID = G.intSiteID
							INNER JOIN tblTMClock H
								ON A.intClockID = H.intClockID
							LEFT JOIN tblARSalesperson I
								ON I.intEntitySalespersonId = C.intEntitySalespersonId
				
							---Update Site Info
							UPDATE tblTMSite
							SET 
								dblYTDGalsThisSeason = dblYTDGalsThisSeason + @dblQuantityShipped
								,dblYTDSales = dblYTDSales + @dblItemTotal + @dblTotalTax
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intSiteID = @intSiteId
						END
					END
				END
				ELSE
				BEGIN
					---- Insert Delivery History
					PRINT 'Standard Single'
					IF(@strTransactionType = 'Invoice')
					BEGIN
						PRINT 'Invoice'
						INSERT INTO tblTMDeliveryHistory(
							--SELECT * FROM tblTMDeliveryHistory
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
							,intInvoiceId
							,intInvoiceDetailId
						)
						SELECT
							strInvoiceNumber = C.strInvoiceNumber
							,strBulkPlantNumber = D.strLocationName
							,dtmInvoiceDate = C.dtmDate
							,strProductDelivered = E.strItemNo
							,dblQuantityDelivered = B.dblQtyShipped
							,intDegreeDayOnDeliveryDate = @dblAccumulatedDegreeDay
							,intDegreeDayOnLastDeliveryDate = @dblLastAccumulatedDegreeDay
							,dblBurnRateAfterDelivery = dbo.[fnTMComputeNewBurnRate](A.intSiteID,B.intInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,0)
							,dblCalculatedBurnRate = dbo.[fnTMGetCalculatedBurnRate](A.intSiteID,B.intInvoiceDetailId,@intClockReadingId,0)
							,ysnAdjustBurnRate = ISNULL(A.ysnAdjustBurnRate,0)
							,intElapsedDegreeDaysBetweenDeliveries = dbo.fnTMGetElapseDegreeDayForCalculation(@intSiteId,@intInvoiceDetailId)
							,intElapsedDaysBetweenDeliveries = @intElapseDays
							,strSeason = H.strCurrentSeason
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
							,strSalesPersonID = I.strSalespersonId
							,dblExtendedAmount = B.dblTotal + ISNULL(B.dblTotalTax,0.0)
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
							,intInvoiceId = C.intInvoiceId
							,intInvoiceDetailId = F.intInvoiceDetailId
						FROM tblTMSite A
						INNER JOIN tblARInvoiceDetail B
							ON A.intSiteID = B.intSiteId
						INNER JOIN tblARInvoice C
							ON B.intInvoiceId = C.intInvoiceId
						INNER JOIN tblSMCompanyLocation D
							ON C.intCompanyLocationId = D.intCompanyLocationId
						INNER JOIN tblICItem E
							ON B.intItemId = E.intItemId
						INNER JOIN #tmpSiteInvoiceLineItems F
							ON B.intInvoiceDetailId = F.intInvoiceDetailId
						INNER JOIN tblTMDispatch G
							ON A.intSiteID = G.intSiteID
						INNER JOIN tblTMClock H
							ON A.intClockID = H.intClockID
						LEFT JOIN tblARSalesperson I
							ON I.intEntitySalespersonId = C.intEntitySalespersonId
				
						---Update Site Info
						UPDATE tblTMSite
						SET intLastDeliveryDegreeDay = @dblAccumulatedDegreeDay
							,dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(@dblPercentAfterDelivery,0)/100
							,dblYTDGalsThisSeason = dblYTDGalsThisSeason + @dblQuantityShipped
							,dblYTDSales = dblYTDSales + @dblItemTotal + @dblTotalTax
							,dblLastDeliveredGal = @dblQuantityShipped
							,dtmLastDeliveryDate = @dtmInvoiceDate
							,dtmLastUpdated = GETDATE()
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
							,dblDegreeDayBetweenDelivery = @dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END)
							,intNextDeliveryDegreeDay = @dblAccumulatedDegreeDay + (@dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END))
							,dtmLastReadingUpdate = @dtmInvoiceDate
						WHERE intSiteID = @intSiteId
					
				
						----Update Next Julian Calendar Date of the site
						UPDATE tblTMSite
						SET dtmNextDeliveryDate = (CASE WHEN intFillMethodId = @intJulianCalendarFillId THEN dbo.fnTMGetNextJulianDeliveryDate(intSiteID) ELSE NULL END)
							,intConcurrencyId = intConcurrencyId + 1
						WHERE intSiteID = @intSiteId
					END
				END
			END
		END
		CONTINUELOOP:
		DELETE FROM #tmpInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId
		PRINT 'DONE'
	END
		
DONESYNCHING:
END
GO