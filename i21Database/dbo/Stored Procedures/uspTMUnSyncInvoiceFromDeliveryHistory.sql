CREATE PROCEDURE uspTMUnSyncInvoiceFromDeliveryHistory 
	@InvoiceId INT
	,@ResultLog NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @dtmInvoiceDate DATETIME
	DECLARE @strTransactionType NVARCHAR(20)
	DECLARE @intSiteId INT
	DECLARE @intDeliveryHistoryId INT
	DECLARE @intTopInvoiceDetailId INT
	DECLARE @dblNewBurnRate NUMERIC(18,6)
	DECLARE @intClockId INT
	DECLARE @intDegreeDays INT
	DECLARE @dblAccumulatedDegreeDay NUMERIC(18,6) 
	DECLARE @intClockReadingId INT
	DECLARE @intLastDegreeDays INT
	DECLARE @dblLastAccumulatedDegreeDay NUMERIC(18,6) 
	DECLARE @intLastClockReadingId INT
	DECLARE @dtmPreviousLastDelivery DATETIME
	DECLARE @dtmSiteLastDelivery DATETIME
	DECLARE @intJulianCalendarFillId INT
	DECLARE @intDeliveryHistoryIdOfPreviousDelivery INT
	DECLARE @strBillingBy NVARCHAR(15)
	DECLARE @dblSeasonResetAccumulated NUMERIC(18,6)
	DECLARE @intSeasonResetArchiveID INT
	
	
	PRINT 'Get invoice header detail'
	-----Get invoice header detail
	SELECT 
		@dtmInvoiceDate = DATEADD(DAY, DATEDIFF(DAY, 0, dtmDate), 0) 
		,@strTransactionType = strTransactionType
	FROM tblARInvoice
	WHERE intInvoiceId = @InvoiceId 

	---unsync and Delete from delivery history Virtual Meter Entry
	--IF(@strTransactionType <> 'Credit Memo')
	--BEGIN
		--UPDATE tblTMSite
		--SET	dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) - ISNULL(dblQuantityDelivered,0.0)
		--	,dblYTDSales = ISNULL(dblYTDSales,0.0) - ISNULL(dblExtendedAmount,0.0)
		--	,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
		--FROM  (
		--	SELECT dblQuantityDelivered = SUM(ISNULL(dblQuantityDelivered,0.0))
		--		,dblExtendedAmount = SUM(ISNULL(dblExtendedAmount,0.0))
		--		,intSiteID
		--	FROM tblTMDeliveryHistory WHERE intInvoiceId = @InvoiceId AND ysnMeterReading = 1
		--	GROUP BY intSiteID
		--) A
		--WHERE A.intSiteID = tblTMSite.intSiteID
	--END
	--ELSE
	--BEGIN
	--	UPDATE tblTMSite
	--	SET	dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) + ISNULL(dblQuantityDelivered,0.0)
	--		,dblYTDSales = ISNULL(dblYTDSales,0.0) + ISNULL(dblExtendedAmount,0.0)
	--		,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
	--	FROM  (
	--		SELECT dblQuantityDelivered = SUM(ISNULL(dblQuantityDelivered,0.0))
	--			,dblExtendedAmount = SUM(ISNULL(dblExtendedAmount,0.0))
	--			,intSiteID
	--		FROM tblTMDeliveryHistory WHERE intInvoiceId = @InvoiceId AND ysnMeterReading = 1
	--		GROUP BY intSiteID
	--	) A
	--	WHERE A.intSiteID = tblTMSite.intSiteID
	--END

	DELETE FROM tblTMDeliveryHistory WHERE intInvoiceId = @InvoiceId AND ysnMeterReading = 1

	-----------------------------------------------------------------------------

	
	IF OBJECT_ID('tempdb..#tmpInvoiceDetail') IS NOT NULL DROP TABLE #tmpInvoiceDetail

	SELECT *
		,ysnTMProcessed = 0
	INTO #tmpInvoiceDetail
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @InvoiceId
		AND intSiteId IS NOT NULL
		AND ISNULL(ysnLeaseBilling,0) <> 1
	
	
	
	----Get the Delivery History detail 
	IF OBJECT_ID('tempdb..#tmpDeliveryHistoryDetail') IS NOT NULL DROP TABLE #tmpDeliveryHistoryDetail
	
	SELECT * 
	INTO #tmpDeliveryHistoryDetail
	FROM tblTMDeliveryHistoryDetail
	WHERE intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM #tmpInvoiceDetail)
	
	----Delete delivery history Detail from table
	DELETE FROM tblTMDeliveryHistoryDetail
	WHERE intDeliveryHistoryDetailID IN (SELECT intDeliveryHistoryDetailID FROM #tmpDeliveryHistoryDetail)
	
	----Get the Delivery History Header 
	IF OBJECT_ID('tempdb..#tmpDeliveryHistory') IS NOT NULL DROP TABLE #tmpDeliveryHistory
	
	SELECT * 
		,ysnProcessed = 0
	INTO #tmpDeliveryHistory
	FROM tblTMDeliveryHistory
	WHERE intDeliveryHistoryID IN (SELECT DISTINCT intDeliveryHistoryID 
									FROM #tmpDeliveryHistoryDetail)
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpDeliveryHistory WHERE ysnProcessed = 0)
	BEGIN
		SELECT TOP 1 
			@intDeliveryHistoryId = A.intDeliveryHistoryID
			,@intSiteId = A.intSiteID
			,@intClockId = B.intClockID
			,@dtmPreviousLastDelivery = A.dtmSiteLastDelivery
			,@dtmSiteLastDelivery = B.dtmLastDeliveryDate
			,@strBillingBy = B.strBillingBy
		FROM #tmpDeliveryHistory A
		INNER JOIN tblTMSite B
			ON A.intSiteID = B.intSiteID
		
		-----Get clock reading for the invoice date
		SELECT TOP 1
			@intDegreeDays = intDegreeDays
			,@dblAccumulatedDegreeDay = dblAccumulatedDegreeDay
			,@intClockReadingId = intDegreeDayReadingID
		FROM tblTMDegreeDayReading
		WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmInvoiceDate), 0) 
		
		
		----GET clock reading for last delivery
		IF EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmPreviousLastDelivery), 0))
		BEGIN
			SELECT TOP 1
				@intLastDegreeDays = intDegreeDays
				,@dblLastAccumulatedDegreeDay = dblAccumulatedDegreeDay
				,@intLastClockReadingId = intDegreeDayReadingID
			FROM tblTMDegreeDayReading
			WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmPreviousLastDelivery), 0) 
		END
		ELSE
		BEGIN
		---Check on Season Reset Archive
			SELECT TOP 1
				@intLastDegreeDays = intDegreeDays
				,@dblLastAccumulatedDegreeDay = dblAccumulatedDD
				,@intLastClockReadingId = intDDReadingID
				,@intSeasonResetArchiveID = intSeasonResetArchiveID
			FROM tblTMDDReadingSeasonResetArchive
			WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmPreviousLastDelivery), 0) 

			SELECT TOP 1 @dblSeasonResetAccumulated = dblAccumulatedDD FROM tblTMDDReadingSeasonResetArchive 
			WHERE intSeasonResetArchiveID = @intSeasonResetArchiveID 
			ORDER BY dtmDate DESC

			SET @dblLastAccumulatedDegreeDay = @dblLastAccumulatedDegreeDay - @dblSeasonResetAccumulated
		END
		
		
		---CHECK each delivery history header if it has some delivery details left
		IF EXISTS(SELECT TOP 1 1 FROM tblTMDeliveryHistoryDetail WHERE intDeliveryHistoryID = @intDeliveryHistoryId)
		BEGIN
			PRINT 'Has details left'
			
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
				WHERE Z.intDeliveryHistoryID = @intDeliveryHistoryId
				ORDER BY Z.dblPercentAfterDelivery DESC, Z.intInvoiceDetailId ASC
			)A
			WHERE intDeliveryHistoryID = @intDeliveryHistoryId
			
			UPDATE tblTMDeliveryHistory
			SET dblExtendedAmount = A.dblExtendedAmount
				,dblQuantityDelivered = A.dblQuantityDelivered
			FROM(
				SELECT TOP 1 
					dblExtendedAmount = SUM(ISNULL(dblExtendedAmount,0))
					,dblQuantityDelivered = SUM(ISNULL(dblQuantityDelivered,0))
				FROM tblTMDeliveryHistoryDetail
				WHERE intDeliveryHistoryID = @intDeliveryHistoryId
			)A
			WHERE intDeliveryHistoryID = @intDeliveryHistoryId
			
			---Update Site Info
			--IF(@strBillingBy <> 'Virtual Meter')
			--BEGIN
			--	UPDATE tblTMSite
			--	SET dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) - A.dblQuantityTotal
			--		,dblYTDSales = ISNULL(dblYTDSales,0.0) - ISNULL(A.dblSalesTotal,0.)
			--		,intConcurrencyId = intConcurrencyId + 1
			--	FROM(
			--		SELECT dblQuantityTotal = SUM(ISNULL(dblQuantityDelivered,0))
			--			,dblSalesTotal = SUM(ISNULL(dblExtendedAmount,0))
			--		FROM #tmpDeliveryHistoryDetail 
			--		WHERE intDeliveryHistoryID = @intDeliveryHistoryId
			--	)A
			--	WHERE intSiteID = @intSiteId
				
			--END
			
			--CHECK if invoice date is the last delivery of the site
			IF(DATEADD(DAY, DATEDIFF(DAY, 0, @dtmSiteLastDelivery), 0) = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmInvoiceDate), 0))
			BEGIN
				PRINT 'Delivery History is last delivery of the site'
				
				---Update Site Estimated Gals and last gals in tank
				UPDATE tblTMSite
				SET dblEstimatedPercentLeft = A.dblPercentAfterDelivery
					,dblEstimatedGallonsLeft = ISNULL(A.dblPercentAfterDelivery,0.0) * tblTMSite.dblTotalCapacity /100
					,dtmLastReadingUpdate = @dtmInvoiceDate
				FROM(
					SELECT   
						dblPercentAfterDelivery = MAX(dblPercentAfterDelivery)
					FROM tblTMDeliveryHistoryDetail 
					WHERE intDeliveryHistoryID = @intDeliveryHistoryId
				)A
				WHERE tblTMSite.intSiteID = @intSiteId

				----Update site Lastdelivered gals and last gals in tank
				UPDATE tblTMSite
				SET dblLastDeliveredGal = A.dblShippedQuantity
					,dblLastGalsInTank =   ISNULL(dblTotalCapacity,0)  * ISNULL(A.dblPercentAfterDelivery,0)/100
					,intConcurrencyId = intConcurrencyId + 1
				FROM(
					SELECT   
						dblPercentAfterDelivery = MAX(dblPercentAfterDelivery)
						,dblShippedQuantity = SUM(ISNULL(dblQuantityDelivered,0.0))
					FROM tblTMDeliveryHistoryDetail
					WHERE intDeliveryHistoryID = @intDeliveryHistoryId		
				)A
				WHERE tblTMSite.intSiteID = @intSiteId
				
				
				---- get the invoicedetail Id of the highest percent full
				SELECT TOP 1 @intTopInvoiceDetailId = intInvoiceDetailId 
				FROM tblTMDeliveryHistoryDetail 
				WHERE intDeliveryHistoryID = @intDeliveryHistoryId
				ORDER BY dblPercentAfterDelivery DESC, intInvoiceDetailId ASC
				
				SET @dblNewBurnRate = dbo.[fnTMComputeNewBurnRate](@intSiteId,@intTopInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,0,@intDeliveryHistoryId) 
				
				---Update Site Burn Rate, dblDegreeDayBetweenDelivery,intNextDeliveryDegreeDay based on the new calculated burn rate
				UPDATE tblTMSite
				SET dblBurnRate = (CASE WHEN ysnAdjustBurnRate = 1 
										THEN @dblNewBurnRate
										ELSE dblBurnRate 
									END)
					,dblDegreeDayBetweenDelivery = @dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END)
					,intNextDeliveryDegreeDay = @dblAccumulatedDegreeDay + (@dblNewBurnRate * (CASE WHEN (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) < 0 THEN 0 ELSE (ISNULL(dblLastGalsInTank,0.0) - ISNULL(dblTotalReserve,0.0)) END))
				WHERE intSiteID = @intSiteId

				----UPDATE Delivery history header for the new calc burnrate 
				UPDATE tblTMDeliveryHistory
					SET 
					dblBurnRateAfterDelivery = dbo.[fnTMComputeNewBurnRate](@intSiteId,@intTopInvoiceDetailId,@intClockReadingId,@intLastClockReadingId,0,@intDeliveryHistoryId)
					,dblCalculatedBurnRate = dbo.[fnTMGetCalculatedBurnRate](@intSiteId,@intTopInvoiceDetailId,@intClockReadingId,0,@intDeliveryHistoryId)
				WHERE intDeliveryHistoryID = @intDeliveryHistoryId
				
				--Restore the Call Entry
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDispatch WHERE intSiteID = @intSiteId)
				BEGIN
						--CHECK if a corresponding entry in tblTMDispatchHistory is present for the delivery history
					IF EXISTS(SELECT TOP 1 1 FROM tblTMDispatchHistory WHERE intDeliveryHistoryId = @intDeliveryHistoryId)
					BEGIN
						SET IDENTITY_INSERT tblTMDispatch ON

						INSERT INTO tblTMDispatch (
							[intDispatchID]            
							,[intSiteID]
							,[dblPercentLeft]           
							,[dblQuantity]              
							,[dblMinimumQuantity]       
							,[intProductID]             
							,[intSubstituteProductID]   
							,[dblPrice]                 
							,[dblTotal]                 
							,[dtmRequestedDate]         
							,[intPriority]              
							,[strComments]              
							,[ysnCallEntryPrinted]      
							,[intDriverID]              
							,[intDispatchDriverID]      
							,[strDispatchLoadNumber]    
							,[dtmCallInDate]            
							,[ysnSelected]              
							,[strRoute]                 
							,[strSequence]              
							,[intUserID]                
							,[dtmLastUpdated]           
							,[ysnDispatched]            
							,[strCancelDispatchMessage] 
							,[intDeliveryTermID]        
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
						)	
						SELECT TOP 1 
							[intDispatchID]				= [intDispatchId]
							,intSiteID					= [intSiteId]
							,[dblPercentLeft]           
							,[dblQuantity]              
							,[dblMinimumQuantity]       
							,[intProductID]				= [intProductId]
							,[intSubstituteProductID]   = [intSubstituteProductId]
							,[dblPrice]                 
							,[dblTotal]                 
							,[dtmRequestedDate]         
							,[intPriority]              
							,[strComments]              
							,[ysnCallEntryPrinted]      
							,[intDriverID]              = [intDriverId]              
							,[intDispatchDriverID]		= [intDispatchDriverId]   
							,[strDispatchLoadNumber]    
							,[dtmCallInDate]            
							,[ysnSelected]              
							,[strRoute]                 
							,[strSequence]              
							,[intUserID]				= [intUserId]
							,[dtmLastUpdated]           
							,[ysnDispatched]            
							,[strCancelDispatchMessage] 
							,[intDeliveryTermID]		= [intDeliveryTermId] 
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
						FROM tblTMDispatchHistory
						WHERE intDeliveryHistoryId = @intDeliveryHistoryId

						SET IDENTITY_INSERT tblTMDispatch OFF	

						
					END
				END
				
				---- Update forecasted nad estimated % left
				EXEC uspTMUpdateEstimatedValuesBySite @intSiteId
				EXEC uspTMUpdateForecastedValuesBySite @intSiteId
			END
			ELSE
			BEGIN
				PRINT 'Delivery History is not the last delivery of the site'
				--update Delivery history Header

			END
		END
		ELSE
		BEGIN
			PRINT 'No Details left'
			
				-----Get Julian Calendar Fill Method ID
			SELECT
				@intJulianCalendarFillId = intFillMethodId
			FROM tblTMFillMethod
			WHERE strFillMethod = 'Julian Calendar'
			
			

			---CHECK if the delivery is the last delivery
			IF EXISTS(SELECT TOP 1 1 FROM tblTMDeliveryHistory 
						WHERE intSiteID = @intSiteId
						AND dtmInvoiceDate > @dtmInvoiceDate
						AND ysnMeterReading <> 1)
			BEGIN
				Print 'Delivery History is not the last delivery'

				---DELETE Delivery History Header
				DELETE FROM tblTMDeliveryHistory
				WHERE intDeliveryHistoryID = @intDeliveryHistoryId

				---Update Site Info
				IF(@strBillingBy <> 'Virtual Meter')
				BEGIN
					UPDATE tblTMSite
					SET 
						--dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) - A.dblQuantityTotal
						--,dblYTDSales = ISNULL(dblYTDSales,0.0) - ISNULL(A.dblSalesTotal,0.0)
						dtmLastReadingUpdate = @dtmInvoiceDate
						,intConcurrencyId = intConcurrencyId + 1
					FROM(
						SELECT dblQuantityTotal = SUM(ISNULL(dblQuantityDelivered,0))
							,dblSalesTotal = SUM(ISNULL(dblExtendedAmount,0))
						FROM #tmpDeliveryHistoryDetail 
						WHERE intDeliveryHistoryID = @intDeliveryHistoryId
					)A
					WHERE intSiteID = @intSiteId
				END

			END
			ELSE
			BEGIN
				PRINT 'Delivery History is the last delivery'

				---Check for previous deliveries prior to the Invoice date
				IF EXISTS(SELECT TOP 1 1 
					FROM tblTMDeliveryHistory
					WHERE intSiteID = @intSiteId
						AND dtmInvoiceDate < @dtmInvoiceDate
						AND ysnMeterReading <> 1)
				BEGIN
					PRINT 'Has previous delivery history before invoice date'
					SELECT TOP 1
						@intDeliveryHistoryIdOfPreviousDelivery = intDeliveryHistoryID
						,@dtmPreviousLastDelivery = dtmInvoiceDate
					FROM tblTMDeliveryHistory
					WHERE intSiteID = @intSiteId
						AND dtmInvoiceDate < @dtmInvoiceDate
						AND ysnMeterReading <> 1
					ORDER BY dtmInvoiceDate DESC

					
					---Check if the previous Last Delivery is the same as the previous delivery of the invoice date
					IF((SELECT dtmSiteLastDelivery FROM #tmpDeliveryHistory WHERE intDeliveryHistoryID = @intDeliveryHistoryId) =  @dtmPreviousLastDelivery)
					BEGIN
						PRINT 'update site rollback previous last is valid'
						------Update Site INfo (rollback)
						UPDATE tblTMSite
						SET intLastDeliveryDegreeDay = @dblLastAccumulatedDegreeDay
							,dblLastGalsInTank =   A.dblSiteLastGalsInTank
							,dblLastDeliveredGal = A.dblSiteLastDeliveredGal
							,dtmLastDeliveryDate = A.dtmSiteLastDelivery
							,dtmLastUpdated = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
							,ysnDeliveryTicketPrinted = ISNULL(A.ysnSiteDeliveryTicketPrinted,0)
							,dblEstimatedPercentLeft = A.dblSiteEstimatedPercentLeft
							,dblEstimatedGallonsLeft = tblTMSite.dblTotalCapacity * A.dblSiteEstimatedPercentLeft /100
							,dblPreviousBurnRate = A.dblSitePreviousBurnRate
							,dblBurnRate = A.dblSiteBurnRate
							,dblDegreeDayBetweenDelivery = A.dblSiteDegreeDayBetweenDelivery
							,intNextDeliveryDegreeDay = A.intSiteNextDeliveryDegreeDay
							,dtmLastReadingUpdate = A.dtmSiteLastReadingUpdate
						FROM(
							SELECT TOP 1 * FROM tblTMDeliveryHistory
							WHERE intDeliveryHistoryID = @intDeliveryHistoryId
						)A
						WHERE tblTMSite.intSiteID = @intSiteId

						---Update Site Info
						--IF(@strBillingBy <> 'Virtual Meter')
						--BEGIN
						--	UPDATE tblTMSite
						--	SET dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) - A.dblQuantityTotal
						--		,dblYTDSales = ISNULL(dblYTDSales,0.0) - ISNULL(A.dblSalesTotal,0.)
						--		,intConcurrencyId = intConcurrencyId + 1
						--	FROM(
						--		SELECT dblQuantityTotal = SUM(ISNULL(dblQuantityDelivered,0))
						--			,dblSalesTotal = SUM(ISNULL(dblExtendedAmount,0))
						--		FROM #tmpDeliveryHistoryDetail 
						--		WHERE intDeliveryHistoryID = @intDeliveryHistoryId
						--	)A
						--	WHERE intSiteID = @intSiteId
						--END
			
			
						----Update Next Julian Calendar Date of the site
						UPDATE tblTMSite
						SET dtmNextDeliveryDate = (CASE WHEN intFillMethodId = @intJulianCalendarFillId THEN dbo.fnTMGetNextJulianDeliveryDate(intSiteID) ELSE NULL END)
							,intConcurrencyId = intConcurrencyId + 1
						WHERE intSiteID = @intSiteId

						---DELETE Delivery History Header
						DELETE FROM tblTMDeliveryHistory
						WHERE intDeliveryHistoryID = @intDeliveryHistoryId

						---- Update forecasted nad estimated % left
						EXEC uspTMUpdateEstimatedValuesBySite @intSiteId
						EXEC uspTMUpdateForecastedValuesBySite @intSiteId

					END
					ELSE
					BEGIN
						PRINT 'No REcord in the delivery history for the previouse delivery' 
						------Update Site INfo (rollback) base on the first delivery history before the invoice date

						UPDATE tblTMSite
						SET intLastDeliveryDegreeDay = A.intDegreeDayOnDeliveryDate
							,dblLastGalsInTank =   ISNULL(A.dblActualPercentAfterDelivery,0.0) * ISNULL(tblTMSite.dblTotalCapacity,1) /100
							,dblLastDeliveredGal = A.dblQuantityDelivered
							,dtmLastDeliveryDate = A.dtmInvoiceDate
							,dtmLastUpdated = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
							,dblEstimatedPercentLeft = A.dblActualPercentAfterDelivery
							,dblEstimatedGallonsLeft = tblTMSite.dblTotalCapacity * A.dblActualPercentAfterDelivery /100
							,dblDegreeDayBetweenDelivery =	(tblTMSite.dblBurnRate
																* (CASE WHEN (ISNULL(A.dblActualPercentAfterDelivery,0.0) * ISNULL(tblTMSite.dblTotalCapacity,1) /100) < 0 
																	THEN 0 ELSE (ISNULL(A.dblActualPercentAfterDelivery,0.0) * ISNULL(tblTMSite.dblTotalCapacity,1) /100) END)
															)
							,intNextDeliveryDegreeDay =  ROUND((A.intDegreeDayOnDeliveryDate  
															+	(tblTMSite.dblBurnRate
																	* (CASE WHEN (ISNULL(A.dblActualPercentAfterDelivery,0.0) * ISNULL(tblTMSite.dblTotalCapacity,1) /100) < 0 
																		THEN 0 ELSE (ISNULL(A.dblActualPercentAfterDelivery,0.0) * ISNULL(tblTMSite.dblTotalCapacity,1) /100) END)
																)),0)
							,dtmLastReadingUpdate = A.dtmInvoiceDate
						FROM(
							SELECT TOP 1 * FROM tblTMDeliveryHistory
							WHERE intDeliveryHistoryID = (SELECT TOP 1 intDeliveryHistoryID
															FROM tblTMDeliveryHistory
															WHERE intSiteID = @intSiteId
																AND dtmInvoiceDate < @dtmInvoiceDate
																AND ysnMeterReading <> 1
															ORDER BY dtmInvoiceDate DESC)
						)A
						WHERE tblTMSite.intSiteID = @intSiteId

						---Update Site YTD Info 
						--IF(@strBillingBy <> 'Virtual Meter')
						--BEGIN
						--	UPDATE tblTMSite
						--	SET dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) - A.dblQuantityTotal
						--		,dblYTDSales = ISNULL(dblYTDSales,0.0) - ISNULL(A.dblSalesTotal,0.)
						--		,intConcurrencyId = intConcurrencyId + 1
						--	FROM(
						--		SELECT dblQuantityTotal = SUM(ISNULL(dblQuantityDelivered,0))
						--			,dblSalesTotal = SUM(ISNULL(dblExtendedAmount,0))
						--		FROM #tmpDeliveryHistoryDetail 
						--		WHERE intDeliveryHistoryID = @intDeliveryHistoryId
						--	)A
						--	WHERE intSiteID = @intSiteId
						--END

						--DELETE Delivery History Header
						DELETE FROM tblTMDeliveryHistory
						WHERE intDeliveryHistoryID = @intDeliveryHistoryId

						---- Update forecasted nad estimated % left
						EXEC uspTMUpdateEstimatedValuesBySite @intSiteId
						EXEC uspTMUpdateForecastedValuesBySite @intSiteId
					END
				END
				ELSE
				BEGIN
					Print 'Dont have previous delivery prior to invoicedate'
					------Update Site INfo (rollback)
					UPDATE tblTMSite
					SET intLastDeliveryDegreeDay = @dblLastAccumulatedDegreeDay
						,dblLastGalsInTank =   A.dblSiteLastGalsInTank
						,dblLastDeliveredGal = A.dblSiteLastDeliveredGal
						,dtmLastDeliveryDate = A.dtmSiteLastDelivery
						,dtmLastUpdated = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)
						,ysnDeliveryTicketPrinted = ISNULL(A.ysnSiteDeliveryTicketPrinted,0)
						,dblEstimatedPercentLeft = A.dblSiteEstimatedPercentLeft
						,dblEstimatedGallonsLeft = tblTMSite.dblTotalCapacity * ISNULl(A.dblSiteEstimatedPercentLeft,0.0) /100
						,dblPreviousBurnRate = A.dblSitePreviousBurnRate
						,dblBurnRate = A.dblSiteBurnRate
						,dblDegreeDayBetweenDelivery = A.dblSiteDegreeDayBetweenDelivery
						,intNextDeliveryDegreeDay = A.intSiteNextDeliveryDegreeDay
						,dtmLastReadingUpdate = A.dtmSiteLastReadingUpdate
						,dtmForecastedDelivery = NULL
						,dtmRunOutDate = NULL
					FROM(
						SELECT TOP 1 * FROM tblTMDeliveryHistory
						WHERE intDeliveryHistoryID = @intDeliveryHistoryId
					)A
					WHERE tblTMSite.intSiteID = @intSiteId
			
					---Update Site Info
					--IF(@strBillingBy <> 'Virtual Meter')
					--BEGIN
					--	UPDATE tblTMSite
					--	SET dblYTDGalsThisSeason = ISNULL(dblYTDGalsThisSeason,0.0) - A.dblQuantityTotal
					--		,dblYTDSales = ISNULL(dblYTDSales,0.0) - ISNULL(A.dblSalesTotal,0.)
					--		,intConcurrencyId = intConcurrencyId + 1
					--	FROM(
					--		SELECT dblQuantityTotal = SUM(ISNULL(dblQuantityDelivered,0))
					--			,dblSalesTotal = SUM(ISNULL(dblExtendedAmount,0))
					--		FROM #tmpDeliveryHistoryDetail 
					--		WHERE intDeliveryHistoryID = @intDeliveryHistoryId
					--	)A
					--	WHERE intSiteID = @intSiteId
					--END
			
					----Update Next Julian Calendar Date of the site
					UPDATE tblTMSite
					SET dtmNextDeliveryDate = (CASE WHEN intFillMethodId = @intJulianCalendarFillId THEN dbo.fnTMGetNextJulianDeliveryDate(intSiteID) ELSE NULL END)
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intSiteID = @intSiteId


					---DELETE Delivery History Header
					DELETE FROM tblTMDeliveryHistory
					WHERE intDeliveryHistoryID = @intDeliveryHistoryId

					-- Update forecasted nad estimated % left
					EXEC uspTMUpdateEstimatedValuesBySite @intSiteId
					-- No calculation for forecast since this is the start/setup state of site 
					---EXEC uspTMUpdateForecastedValuesBySite @intSiteId
				END

				--Restore the Call Entry
				--Check if an existing order is present
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDispatch WHERE intSiteID = @intSiteId)
				BEGIN
					--CHECK if a corresponding entry in tblTMDispatchHistory is present for the delivery history
					IF EXISTS(SELECT TOP 1 1 FROM tblTMDispatchHistory WHERE intDeliveryHistoryId = @intDeliveryHistoryId)
					BEGIN
						SET IDENTITY_INSERT tblTMDispatch ON

						INSERT INTO tblTMDispatch (
							[intDispatchID]            
							,[intSiteID]
							,[dblPercentLeft]           
							,[dblQuantity]              
							,[dblMinimumQuantity]       
							,[intProductID]             
							,[intSubstituteProductID]   
							,[dblPrice]                 
							,[dblTotal]                 
							,[dtmRequestedDate]         
							,[intPriority]              
							,[strComments]              
							,[ysnCallEntryPrinted]      
							,[intDriverID]              
							,[intDispatchDriverID]      
							,[strDispatchLoadNumber]    
							,[dtmCallInDate]            
							,[ysnSelected]              
							,[strRoute]                 
							,[strSequence]              
							,[intUserID]                
							,[dtmLastUpdated]           
							,[ysnDispatched]            
							,[strCancelDispatchMessage] 
							,[intDeliveryTermID]        
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
							,dblOriginalPercentLeft	
						)	
						SELECT TOP 1 
							[intDispatchID]				= [intDispatchId]
							,intSiteID					= [intSiteId]
							,[dblPercentLeft]           
							,[dblQuantity]              
							,[dblMinimumQuantity]       
							,[intProductID]				= [intProductId]
							,[intSubstituteProductID]   = [intSubstituteProductId]
							,[dblPrice]                 
							,[dblTotal]                 
							,[dtmRequestedDate]         
							,[intPriority]              
							,[strComments]              
							,[ysnCallEntryPrinted]      
							,[intDriverID]              = [intDriverId]              
							,[intDispatchDriverID]		= [intDispatchDriverId]   
							,[strDispatchLoadNumber]    
							,[dtmCallInDate]            
							,[ysnSelected]              
							,[strRoute]                 
							,[strSequence]              
							,[intUserID]				= [intUserId]
							,[dtmLastUpdated]           
							,[ysnDispatched]            
							,[strCancelDispatchMessage] 
							,[intDeliveryTermID]		= [intDeliveryTermId] 
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
							,dblOriginalPercentLeft
						FROM tblTMDispatchHistory
						WHERE intDeliveryHistoryId = @intDeliveryHistoryId

						SET IDENTITY_INSERT tblTMDispatch OFF	

					
					END
				END

				
			END

			---DELETE Entry from the tblTMDispatchHistory
			DELETE FROM tblTMDispatchHistory WHERE intDeliveryHistoryId = @intDeliveryHistoryId
		END
		
		UPDATE 	#tmpDeliveryHistory 
		SET ysnProcessed = 1
		WHERE intDeliveryHistoryID = @intDeliveryHistoryId
	END
	
END
GO

