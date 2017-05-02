GO
	PRINT 'START OF CREATING [uspTMRecreateImportTankMonitorSP] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateImportTankMonitorSP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateImportTankMonitorSP
GO


CREATE PROCEDURE uspTMRecreateImportTankMonitorSP 
AS
BEGIN
	IF EXISTS(select top 1 1 from sys.objects  WHERE object_id = OBJECT_ID(N'[dbo].[uspTMImportTankMonitorReading]') AND type in (N'P', N'PC'))
	BEGIN
		DROP PROCEDURE uspTMImportTankMonitorReading
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1 
	    AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwitmmst') 
		AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst'))
	BEGIN	

		EXEC('
			CREATE PROCEDURE uspTMImportTankMonitorReading 
				@customerid NVARCHAR(50) = '''',
				@ts_capacity NUMERIC(18,6) = 0,
				@str_rpt_date_ti NVARCHAR(20) = NULL,
				@ts_cat_1 NVARCHAR(50) = '''', --5 customer Number
				@tk_level NUMERIC(18,6) = NULL,
				@tk_w_dau NUMERIC(18,6) = NULL,
				@tx_serialnum NVARCHAR(50) = '''', --11 tank Monitor
				@base_temp NVARCHAR(50) = '''',
				@ta_ltankcrit BIT = 0,
				@tx_nosensor BIT = 1,
				@tx_lnoxmit BIT = 1,
				@ts_tankserialnum NVARCHAR(50) = '''', --19 tank Serial
				@userID INT = NULL,
				@resultLog NVARCHAR(4000)= '''' OUTPUT
			AS  
			BEGIN 

				--Return 0 = no match site
				--SET @resultLog = ''hello''
	
				DECLARE @siteId INT
				DECLARE @TankMonitorEventID INT
				DECLARE @SiteLastDeliveryDate DATETIME
				DECLARE @SiteClockId INT
				DECLARE @UpdateBurnRate BIT
				DECLARE @BurnRateChangePercent NUMERIC(18,6)
				DECLARE @BurnRateAverage NUMERIC(18,6)
				DECLARE @rpt_date_ti DATETIME
				DECLARE @strOrderNumber NVARCHAR(50)
				DECLARE @dblNewBurnRate NUMERIC(18,6)
				DECLARE @intClockReadingId INT
				DECLARE @intLastClockReadingId INT
				DECLARE @intLastMonitorReadingEvent INT
	
				SET @rpt_date_ti = @str_rpt_date_ti
 
				SET @resultLog = ''''
				--IF(ISNULL(@customerid,'''') = '''')BEGIN
				--	SET @resultLog = @resultLog +  ''Failed customerid validation'' + char(10)
				--	RETURN 
				--END
	
				SET @resultLog = @resultLog +  ''passed customerid validation'' + char(10)
	
				--IF(ISNULL(@ts_cat_1,'''') = '''')BEGIN
				--	SET @resultLog = @resultLog +  ''Failed Tank Monitor Serial validation'' + char(10)
				--	RETURN
				--END
	
				SET @resultLog = @resultLog + ''passed Tank Monitor Serial validation'' + char(10)
	
				--IF(ISNULL(@ts_tankserialnum,'''') = '''')
				--BEGIN 
				--	SET @resultLog = @resultLog + ''Failed Tank Serial validation'' + char(10)
				--	RETURN 
				--END
				SET @resultLog = @resultLog +  ''passed Tank Serial validation'' + char(10)
	
				IF(@tx_nosensor <> 0) RETURN 10
				IF(@tx_lnoxmit <> 0) RETURN 10
	
				SET @resultLog = @resultLog +   ''Customer Number = '' + ISNULL(@ts_cat_1,'''') + char(10)
				print ''Customer Number = '' + ISNULL(@ts_cat_1,'''')
				--Check by customer and Tank monitor serial number
				SET @siteId = (
					SELECT TOP 1 A.intSiteID FROM tblTMSite A
					INNER JOIN tblTMCustomer B
						ON A.intCustomerID = B.intCustomerID
					INNER JOIN vwcusmst C
						ON B.intCustomerNumber = C.A4GLIdentity
					INNER JOIN tblTMSiteDevice D
						ON A.intSiteID = D.intSiteID
					INNER JOIN tblTMDevice E
						ON D.intDeviceId = E.intDeviceId
					INNER JOIN tblTMDeviceType F
						ON E.intDeviceTypeId = F.intDeviceTypeId		
					WHERE B.intCustomerNumber = (SELECT TOP 1 A4GLIdentity FROM vwcusmst WHERE vwcus_key = @ts_cat_1)
						AND F.strDeviceType = ''Tank Monitor''
						AND E.strSerialNumber = @tx_serialnum
				)
				--Check by customer and Tank device serial number
				IF(@siteId IS NULL)
				BEGIN
					SET @siteId = (
						SELECT TOP 1 A.intSiteID FROM tblTMSite A
						INNER JOIN tblTMCustomer B
							ON A.intCustomerID = B.intCustomerID
						INNER JOIN vwcusmst C
							ON B.intCustomerNumber = C.A4GLIdentity
						INNER JOIN tblTMSiteDevice D
							ON A.intSiteID = D.intSiteID
						INNER JOIN tblTMDevice E
							ON D.intDeviceId = E.intDeviceId
						INNER JOIN tblTMDeviceType F
							ON E.intDeviceTypeId = F.intDeviceTypeId		
						WHERE B.intCustomerNumber = (SELECT TOP 1 A4GLIdentity FROM vwcusmst WHERE vwcus_key = @ts_cat_1)
							AND F.strDeviceType = ''Tank''
							AND E.strSerialNumber = @ts_tankserialnum
					)
				END
				IF(@siteId IS NULL)
				BEGIN 
					SET @resultLog = @resultLog + ''Exception: Not Matching'' + char(10)
					RETURN 
				END 
				SET @resultLog = @resultLog + ''Site ID = '' + CAST(ISNULL(@siteId,'''') AS NVARCHAR(10)) + char(10) 
				SET @resultLog = @resultLog +  ''Date = '' + CAST(@rpt_date_ti AS NVARCHAR(30))  + char(10) 
	
				print ''get DegreeDay''
				--Get degreeDay reading of for the tank monitor date
				SELECT TOP 1 
						@SiteLastDeliveryDate = dtmLastDeliveryDate
						,@SiteClockId = intClockID
					FROM tblTMSite
					WHERE intSiteID = @siteId 
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0) AND intClockID = @SiteClockId) 
				BEGIN
					--PRINT ''No clock Reading''
					SET @resultLog = @resultLog + ''No clock Reading'' + char(10)
					RETURN
				END
				print ''get event id''
				--Get the event ID of the tank monitor reading event
				SET @TankMonitorEventID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strDefaultEventType = ''Event-021'')
	
				--Check for previous tank monitor reading or duplicate reading
				IF EXISTS(SELECT TOP 1 1 FROM tblTMEvent WHERE (intEventTypeID = @TankMonitorEventID AND dtmTankMonitorReading = @rpt_date_ti AND intSiteID = @siteId ))	
				BEGIN
					SET @resultLog = @resultLog + ''Duplicate Reading'' + char(10)
					SET @resultLog = @resultLog + ''Exception: Duplicate Reading'' + char(10)
					RETURN
				END
				IF EXISTS(SELECT TOP 1 1 FROM tblTMEvent 
							WHERE ((intEventTypeID = @TankMonitorEventID AND dtmTankMonitorReading > @rpt_date_ti)) AND intSiteID = @siteId)	
				BEGIN
					SET @resultLog = @resultLog + ''Reading date is less than the current reading'' + char(10)
					RETURN 
				END
		
				--- Get Last Monitor Reading 
				SELECT TOP 1 
					@intLastMonitorReadingEvent = intEventID
				FROM tblTMEvent 
				WHERE intSiteID = @siteId
					AND intEventTypeID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strDefaultEventType = ''Event-021'')
					AND DATEADD(dd, DATEDIFF(dd, 0, dtmTankMonitorReading), 0) >= DATEADD(dd, DATEDIFF(dd, 0, @SiteLastDeliveryDate), 0)
				ORDER BY dtmDate DESC			
	
				--Insert Record to Event Table
				INSERT INTO tblTMEvent (dtmDate
										,intEventTypeID
										,intUserID
										,dtmLastUpdated
										,intSiteID
										,strLevel
										,dtmTankMonitorReading
										,strDescription
										,intDeviceId
										,intPerformerID
										)
								VALUES (
										DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)
										,@TankMonitorEventID
										,@userID
										,DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)
										,@siteId
										,''Consumption Site''
										,@rpt_date_ti
										,(''Tank Serial Number: '' + ISNULL(@ts_tankserialnum,'''') + CHAR(10) + ''Monitor Serial Number: '' + ISNULL(@tx_serialnum,'''') + CHAR(10) 
											+ ''Date: '' + CAST (@rpt_date_ti AS NVARCHAR(25)) + CHAR(10) + ''Percent Full: '' + CAST(ISNULL(@tk_level,0.0) AS NVARCHAR(10)) + CHAR(10) 
											+ ''Inside Temperature: '' + CAST(ISNULL(@base_temp,'''') AS NVARCHAR(20)) + CHAR(10))
										,0
										,0	
										)		 
	
				--Check if site is not on hold then update the site
				IF ((SELECT TOP 1 ysnOnHold FROM tblTMSite WHERE intSiteID = @siteId) <> 1)
				BEGIN
					PRINT ''Update Site''
					SELECT TOP 1 
						@SiteLastDeliveryDate = dtmLastDeliveryDate
						,@SiteClockId = intClockID
					FROM tblTMSite
					WHERE intSiteID = @siteId 
		
					SET @UpdateBurnRate = 1
					--Get degreeDay reading of for the tank monitor date
					IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0) AND intClockID = @SiteClockId)
						SET @UpdateBurnRate = 0
		
		
					--Check ysnAdjustBurnRate of site
					IF (ISNULL((SELECT TOP 1 ysnAdjustBurnRate FROM tblTMSite WHERE intSiteID = @siteId),0) = 0) SET @UpdateBurnRate = 0
		
					IF (@UpdateBurnRate = 1)
					BEGIN
						SET @dblNewBurnRate = 0.0

						SELECT TOP 1 
							@intLastClockReadingId = intDegreeDayReadingID 
						FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @SiteLastDeliveryDate), 0) AND intClockID = @SiteClockId

						SELECT TOP 1 
							@intClockReadingId = intDegreeDayReadingID
						FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0) AND intClockID = @SiteClockId

			


						SELECT TOP 1 
							@dblNewBurnRate = dblBurnRate
						FROM dbo.fnTMComputeNewBurnRateZeroDeliveryTable(@siteId,@intClockReadingId,@intLastClockReadingId,@tk_level,@intLastMonitorReadingEvent)

						SET @resultLog = @resultLog + ''UPDATING burn rate'' + char(10) 
						UPDATE tblTMSite
						SET dblBurnRate = @dblNewBurnRate
						WHERE intSiteID = @siteId
					END
		
					--update runout and forecasted date
					UPDATE tblTMSite
					SET dtmRunOutDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti),  CAST((dblTotalCapacity * @tk_level / 100 / @tk_w_dau) AS INT)) 
						,dtmForecastedDelivery = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti),  CAST((((dblTotalCapacity * @tk_level / 100) - ISNULL(dblTotalReserve,0)) / @tk_w_dau) AS INT)) 
					WHERE intSiteID = @siteId
		
					--update DD Between Delivery
					UPDATE tblTMSite
					SET dblDegreeDayBetweenDelivery = dblBurnRate * ((dblTotalCapacity * @tk_level / 100) - dblTotalReserve)
					WHERE intSiteID = @siteId
		
					--update next degree day Delivery
					UPDATE tblTMSite
					SET intNextDeliveryDegreeDay = CAST( (ISNULL((SELECT TOP 1 dblAccumulatedDegreeDay 
														   FROM tblTMDegreeDayReading 
														   WHERE intClockID = @SiteClockId 
																AND dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)),0.0)
													+ dblDegreeDayBetweenDelivery) AS INT)
					WHERE intSiteID = @siteId


					--update Estimated % left and Gals left
					UPDATE tblTMSite
					SET dblEstimatedPercentLeft = @tk_level
						,dblEstimatedGallonsLeft = (@tk_level * dblTotalCapacity) / 100
						,dtmLastReadingUpdate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)
					WHERE intSiteID = @siteId

					--update intConcurrencyId
					UPDATE tblTMSite
					SET intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
					WHERE intSiteID = @siteId

			
		
					PRINT @ta_ltankcrit
					IF(@ta_ltankcrit = 1)
					BEGIN
						GOTO CREATECALLENTRY
					END
					IF (ISNULL((SELECT DATEDIFF(dd,DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0),dtmRunOutDate) 
								FROM tblTMSite 
								WHERE intSiteID = @siteId),0) <= 5)
					BEGIN
						GOTO CREATECALLENTRY
					END 
		
		
					RETURN
					CREATECALLENTRY:
					IF EXISTS(SELECT TOP 1 1 FROM tblTMDispatch WHERE intSiteID = @siteId) 
					BEGIN
						SET @resultLog = @resultLog +  ''Already have call entry'' + CHAR(10)
						RETURN
					END	
		
					PRINT ''Create Call entry''
					EXEC uspTMGetNextWillCallStartingNumber @strOrderNumber OUTPUT

					--Get customer site details
					SELECT 
						[dblQuantity] = (ISNULL((SELECT TOP 1 vwitm_deflt_percnt FROM vwitmmst WHERE A4GLIdentity = intProductId),0) - @tk_level) * dblTotalCapacity / 100
						,[strPrice] = dbo.fnTMGetSpecialPricing(
									strCustomerNumber
									,strItemNo
									,strLocation
									,strItemClass
									,(DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))
									,(ISNULL((SELECT TOP 1 vwitm_deflt_percnt FROM vwitmmst WHERE A4GLIdentity = intProductId),0) - @tk_level) * dblTotalCapacity / 100
									,strContractNumber)
						,[intSiteID] = intSiteID 
						,[dblPercentLeft] = dblEstimatedPercentLeft
						,[dblMinimumQuantity] = 0
						,[intProductID] = intProductId
						,[intSubstituteProductID] = NULL
						,[dtmRequestedDate] = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
						,[strComments] = ''Call Entry automatically generated from Tank Monitor Reading''
						,[ysnCallEntryPrinted] = 0
						,[intDriverID] = intDriverId
						,[dtmCallInDate] = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
						,[ysnDispatched] = 0
						,[intDeliveryTermID] = intDeliveryTermID
						,[dtmDispatchingDate] = null
						,strItemNo
						,intTaxStateID
						,ISNULL(ysnTaxable,0) AS  ysnTaxable
						,dblPriceAdjustment
						,strContractNumber
						,intContractId = CAST(A.A4GLIdentity AS INT)
						,ysnContractMaxPrice = ISNULL(A.ysnMaxPrice,0)
						,A.dblContractPrice
						,strCustomerNumber
						,strOrderNumber = @strOrderNumber
					INTO #tmpSiteOrder
					FROM (
						SELECT 
							A.* 
							,B.strContractNumber
							,B.A4GLIdentity
							,B.ysnMaxPrice
							,dblContractPrice = B.dblPrice
						FROM vyuTMSiteOrder A
						OUTER APPLY dbo.fnTMGetContractForCustomer(A.strCustomerNumber,A.intSiteID) B
						WHERE A.intSiteID = @siteId
					) A

					SELECT 
						*
						,dblSpecialPrice = (CASE WHEN strPrice LIKE ''%Regular%'' 
												THEN (CAST(LEFT([strPrice],CHARINDEX('':'',[strPrice])- 1) AS DECIMAL(18,6))) + ISNULL(dblPriceAdjustment,0) 
												ELSE CAST(LEFT([strPrice],CHARINDEX('':'',[strPrice])- 1) AS DECIMAL(18,6))
										END)
						,dblSpecialPriceTotal = ROUND((CASE WHEN ysnTaxable = 1 
										THEN
											ROUND(((CASE WHEN strPrice LIKE ''%Regular%'' 
													THEN (CAST(LEFT([strPrice],CHARINDEX('':'',[strPrice])- 1) AS DECIMAL(18,6))) + ISNULL(dblPriceAdjustment,0) 
													ELSE CAST(LEFT([strPrice],CHARINDEX('':'',[strPrice])- 1) AS DECIMAL(18,6))
											END) * [dblQuantity]),2) * (1 + (dbo.[fnTMGetSalesTax](strItemNo,intTaxStateID)))
										ELSE 
											ROUND(((CASE WHEN strPrice LIKE ''%Regular%'' 
													THEN (CAST(LEFT([strPrice],CHARINDEX('':'',[strPrice])- 1) AS DECIMAL(18,6))) + ISNULL(dblPriceAdjustment,0) 
													ELSE CAST(LEFT([strPrice],CHARINDEX('':'',[strPrice])- 1) AS DECIMAL(18,6))
											END) * [dblQuantity]),2)
										END),2)
						,[intUserID] = @userID
						,[strPricingMethod] = RIGHT([strPrice],LEN([strPrice])- CHARINDEX('':'',[strPrice]))
						,dblItemPrice = (SELECT TOP 1 (CASE (SELECT TOP 1 vwcus_prc_lvl FROM vwcusmst WHERE vwcus_key = strCustomerNumber) 
												WHEN 2 THEN vwitm_un_prc2
												WHEN 3 THEN vwitm_un_prc3
												WHEN 4 THEN vwitm_un_prc4
												WHEN 5 THEN vwitm_un_prc5
												WHEN 6 THEN vwitm_un_prc6
												WHEN 7 THEN vwitm_un_prc7
												WHEN 8 THEN vwitm_un_prc8
												WHEN 9 THEN vwitm_un_prc9
												ELSE
													vwitm_un_prc1
												END)
												FROM vwitmmst WHERE A4GLIdentity = intProductID)
					INTO #tmpSiteOrder1
					FROM #tmpSiteOrder 

					SELECT 
						*
						,dblPrice  =    CASE WHEN (intContractId IS NULL)
										THEN
											dblSpecialPrice
										ELSE
											CASE WHEN ysnContractMaxPrice = 1 
											THEN 
												(CASE WHEN dblItemPrice > dblContractPrice THEN dblContractPrice ELSE (dblItemPrice + ISNULL(dblPriceAdjustment,0)) END) 
											ELSE 
												(CASE WHEN ISNULL(strContractNumber,'''') = '''' THEN dblSpecialPrice ELSE dblContractPrice END)
											END
										END
						,dblTotal =     CASE WHEN (intContractId IS NULL)
										THEN       
											dblSpecialPriceTotal
										ELSE
											(
												CASE WHEN ysnTaxable = 1
												THEN CAST((
														CASE WHEN ysnContractMaxPrice = 1 
														THEN 
															ROUND(((CASE WHEN dblItemPrice > dblContractPrice THEN dblContractPrice ELSE (dblItemPrice + ISNULL(dblPriceAdjustment,0)) END) * [dblQuantity]),2) 
														ELSE 
															ROUND(((CASE WHEN ISNULL(strContractNumber,'''') = '''' THEN dblSpecialPrice ELSE dblContractPrice END) * [dblQuantity]), 2)
														END
														) * (1 + (dbo.[fnTMGetSalesTax](strItemNo,intTaxStateID))) AS NUMERIC(18,6))
												ELSE
													(
														CASE WHEN ysnContractMaxPrice = 1 
														THEN 
															ROUND(((CASE WHEN dblItemPrice > dblContractPrice THEN dblContractPrice ELSE (dblItemPrice + ISNULL(dblPriceAdjustment,0)) END) * [dblQuantity]),2) 
														ELSE 
															ROUND(((CASE WHEN ISNULL(strContractNumber,'''') = '''' THEN dblSpecialPrice ELSE dblContractPrice END) * [dblQuantity]), 2)
														END
													)
												END
											)
										END
					INTO #tmpSiteOrder2
					FROM #tmpSiteOrder1
    

					INSERT INTO tblTMDispatch(
						[intSiteID]
						,[dblPercentLeft]
						,[dblQuantity]
						,[dblMinimumQuantity]
						,[intProductID]
						,[intSubstituteProductID]
						,[dblPrice]
						,[dtmRequestedDate]
						,[strComments]
						,[ysnCallEntryPrinted]
						,[intDriverID]
						,[dtmCallInDate]
						,[ysnDispatched]
						,[intDeliveryTermID]
						,[dtmDispatchingDate]
						,[dblTotal]
						,[intUserID]
						,[strPricingMethod]
						,strOrderNumber
					)

					SELECT 
						[intSiteID]
						,@tk_level
						,[dblQuantity]
						,[dblMinimumQuantity]
						,[intProductID]
						,[intSubstituteProductID]
						,[dblPrice]
						,[dtmRequestedDate]
						,[strComments]
						,[ysnCallEntryPrinted]
						,[intDriverID]
						,[dtmCallInDate]
						,[ysnDispatched]
						,[intDeliveryTermID]
						,[dtmDispatchingDate]
						,[dblTotal] 
						,[intUserID] 
						,[strPricingMethod]
						,strOrderNumber 
					FROM #tmpSiteOrder2
			
		
				END
	
				print @resultLog
				SET @resultLog = @resultLog + ''Import successful''
			END
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE PROCEDURE [dbo].[uspTMImportTankMonitorReading] 
				@customerid NVARCHAR(50) = '''',
				@ts_capacity NUMERIC(18,6) = 0,
				@str_rpt_date_ti NVARCHAR(20) = NULL,
				@ts_cat_1 NVARCHAR(50) = '''', --5 customer Number
				@tk_level NUMERIC(18,6) = NULL,
				@tk_w_dau NUMERIC(18,6) = NULL,
				@tx_serialnum NVARCHAR(50) = '''', --11 tank Monitor
				@base_temp NVARCHAR(50) = '''',
				@ta_ltankcrit BIT = 0,
				@tx_nosensor BIT = 1,
				@tx_lnoxmit BIT = 1,
				@ts_tankserialnum NVARCHAR(50) = '''', --19 tank Serial
				@userID INT = NULL,
				@resultLog NVARCHAR(4000)= '''' OUTPUT
			AS  
			BEGIN 

				--Return 0 = no match site
				--SET @resultLog = ''hello''
	
				DECLARE @siteId INT
				DECLARE @TankMonitorEventID INT
				DECLARE @SiteLastDeliveryDate DATETIME
				DECLARE @SiteClockId INT
				DECLARE @UpdateBurnRate BIT
				DECLARE @BurnRateChangePercent NUMERIC(18,6)
				DECLARE @BurnRateAverage NUMERIC(18,6)
				DECLARE @rpt_date_ti DATETIME
				DECLARE @strOrderNumber NVARCHAR(50)
				DECLARE @dblNewBurnRate NUMERIC(18,6)
				DECLARE @intClockReadingId INT
				DECLARE @intLastClockReadingId INT
				DECLARE @intLastMonitorReadingEvent INT
				DECLARE @ItemId			INT
				DECLARE @LocationId		INT	
				DECLARE @TransactionDate	DATETIME
				DECLARE @ItemPrice			NUMERIC(18,6)
				DECLARE @Quantity			NUMERIC(18,6)
				DECLARE @TaxGroupId		INT	
				DECLARE @TotalItemTax	NUMERIC(18,6) = 0.00 	
				DECLARE @CustomerEntityId INT
				DECLARE @SiteTaxable    BIT
	
				SET @rpt_date_ti = @str_rpt_date_ti
 
				SET @resultLog = ''''
				--IF(ISNULL(@customerid,'''') = '''')BEGIN
				--	SET @resultLog = @resultLog +  ''Failed customerid validation'' + char(10)
				--	RETURN 
				--END
	
				SET @resultLog = @resultLog +  ''passed customerid validation'' + char(10)
	
				--IF(ISNULL(@ts_cat_1,'''') = '''')BEGIN
				--	SET @resultLog = @resultLog +  ''Failed Tank Monitor Serial validation'' + char(10)
				--	RETURN
				--END
	
				SET @resultLog = @resultLog + ''passed Tank Monitor Serial validation'' + char(10)
	
				--IF(ISNULL(@ts_tankserialnum,'''') = '''')
				--BEGIN 
				--	SET @resultLog = @resultLog + ''Failed Tank Serial validation'' + char(10)
				--	RETURN 
				--END
				SET @resultLog = @resultLog +  ''passed Tank Serial validation'' + char(10)
	
				IF(@tx_nosensor <> 0) RETURN 10
				IF(@tx_lnoxmit <> 0) RETURN 10
	
				SET @resultLog = @resultLog +   ''Customer Number = '' + ISNULL(@ts_cat_1,'''') + char(10)
				print ''Customer Number = '' + ISNULL(@ts_cat_1,'''')
				--Check by customer and Tank monitor serial number
				SET @siteId = (
					SELECT TOP 1 A.intSiteID FROM tblTMSite A
					INNER JOIN tblTMCustomer B
						ON A.intCustomerID = B.intCustomerID
					INNER JOIN vyuTMCustomerEntityView C
						ON B.intCustomerNumber = C.A4GLIdentity
					INNER JOIN tblTMSiteDevice D
						ON A.intSiteID = D.intSiteID
					INNER JOIN tblTMDevice E
						ON D.intDeviceId = E.intDeviceId
					INNER JOIN tblTMDeviceType F
						ON E.intDeviceTypeId = F.intDeviceTypeId		
					WHERE B.intCustomerNumber = (SELECT TOP 1 A4GLIdentity FROM vyuTMCustomerEntityView WHERE vwcus_key = @ts_cat_1)
						AND F.strDeviceType = ''Tank Monitor''
						AND E.strSerialNumber = @tx_serialnum
				)
				--Check by customer and Tank device serial number
				IF(@siteId IS NULL)
				BEGIN
					SET @siteId = (
						SELECT TOP 1 A.intSiteID FROM tblTMSite A
						INNER JOIN tblTMCustomer B
							ON A.intCustomerID = B.intCustomerID
						INNER JOIN vyuTMCustomerEntityView C
							ON B.intCustomerNumber = C.A4GLIdentity
						INNER JOIN tblTMSiteDevice D
							ON A.intSiteID = D.intSiteID
						INNER JOIN tblTMDevice E
							ON D.intDeviceId = E.intDeviceId
						INNER JOIN tblTMDeviceType F
							ON E.intDeviceTypeId = F.intDeviceTypeId		
						WHERE B.intCustomerNumber = (SELECT TOP 1 A4GLIdentity FROM vyuTMCustomerEntityView WHERE vwcus_key = @ts_cat_1)
							AND F.strDeviceType = ''Tank''
							AND E.strSerialNumber = @ts_tankserialnum
					)
				END
				IF(@siteId IS NULL)
				BEGIN 
					SET @resultLog = @resultLog + ''Exception: Not Matching'' + char(10)
					RETURN 
				END 
				SET @resultLog = @resultLog + ''Site ID = '' + CAST(ISNULL(@siteId,'''') AS NVARCHAR(10)) + char(10) 
				SET @resultLog = @resultLog +  ''Date = '' + CAST(@rpt_date_ti AS NVARCHAR(30))  + char(10) 
	
				print ''get DegreeDay''
				--Get degreeDay reading of for the tank monitor date
				SELECT TOP 1 
						@SiteLastDeliveryDate = dtmLastDeliveryDate
						,@SiteClockId = intClockID
					FROM tblTMSite
					WHERE intSiteID = @siteId 
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0) AND intClockID = @SiteClockId) 
				BEGIN
					--PRINT ''No clock Reading''
					SET @resultLog = @resultLog + ''No clock Reading'' + char(10)
					RETURN
				END
				print ''get event id''
				--Get the event ID of the tank monitor reading event
				SET @TankMonitorEventID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strDefaultEventType = ''Event-021'')
	
				--Check for previous tank monitor reading or duplicate reading
				IF EXISTS(SELECT TOP 1 1 FROM tblTMEvent WHERE (intEventTypeID = @TankMonitorEventID AND dtmTankMonitorReading = @rpt_date_ti AND intSiteID = @siteId ))	
				BEGIN
					SET @resultLog = @resultLog + ''Duplicate Reading'' + char(10)
					SET @resultLog = @resultLog + ''Exception: Duplicate Reading'' + char(10)
					RETURN
				END
				IF EXISTS(SELECT TOP 1 1 FROM tblTMEvent 
							WHERE ((intEventTypeID = @TankMonitorEventID AND dtmTankMonitorReading > @rpt_date_ti)) AND intSiteID = @siteId)	
				BEGIN
					SET @resultLog = @resultLog + ''Reading date is less than the current reading'' + char(10)
					RETURN 
				END
		
				--- Get Last Monitor Reading 
				SELECT TOP 1 
					@intLastMonitorReadingEvent = intEventID
				FROM tblTMEvent 
				WHERE intSiteID = @siteId
					AND intEventTypeID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strDefaultEventType = ''Event-021'')
					AND DATEADD(dd, DATEDIFF(dd, 0, dtmTankMonitorReading), 0) >= DATEADD(dd, DATEDIFF(dd, 0, @SiteLastDeliveryDate), 0)
				ORDER BY dtmDate DESC			
	
				--Insert Record to Event Table
				INSERT INTO tblTMEvent (dtmDate
										,intEventTypeID
										,intUserID
										,dtmLastUpdated
										,intSiteID
										,strLevel
										,dtmTankMonitorReading
										,strDescription
										,intDeviceId
										,intPerformerID
										)
								VALUES (
										DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)
										,@TankMonitorEventID
										,@userID
										,DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)
										,@siteId
										,''Consumption Site''
										,@rpt_date_ti
										,(''Tank Serial Number: '' + ISNULL(@ts_tankserialnum,'''') + CHAR(10) + ''Monitor Serial Number: '' + ISNULL(@tx_serialnum,'''') + CHAR(10) 
											+ ''Date: '' + CAST (@rpt_date_ti AS NVARCHAR(25)) + CHAR(10) + ''Percent Full: '' + CAST(ISNULL(@tk_level,0.0) AS NVARCHAR(10)) + CHAR(10) 
											+ ''Inside Temperature: '' + CAST(ISNULL(@base_temp,'''') AS NVARCHAR(20)) + CHAR(10))
										,0
										,0	
										)		 
	
				--Check if site is not on hold then update the site
				IF ((SELECT TOP 1 ysnOnHold FROM tblTMSite WHERE intSiteID = @siteId) <> 1)
				BEGIN
					PRINT ''Update Site''
					SELECT TOP 1 
						@SiteLastDeliveryDate = dtmLastDeliveryDate
						,@SiteClockId = intClockID
					FROM tblTMSite
					WHERE intSiteID = @siteId 
		
					SET @UpdateBurnRate = 1
					--Get degreeDay reading of for the tank monitor date
					IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0) AND intClockID = @SiteClockId)
						SET @UpdateBurnRate = 0
		
		
					--Check ysnAdjustBurnRate of site
					IF (ISNULL((SELECT TOP 1 ysnAdjustBurnRate FROM tblTMSite WHERE intSiteID = @siteId),0) = 0) SET @UpdateBurnRate = 0
		
					IF (@UpdateBurnRate = 1)
					BEGIN
						SET @dblNewBurnRate = 0.0

						SELECT TOP 1 
							@intLastClockReadingId = intDegreeDayReadingID 
						FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @SiteLastDeliveryDate), 0) AND intClockID = @SiteClockId

						SELECT TOP 1 
							@intClockReadingId = intDegreeDayReadingID
						FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0) AND intClockID = @SiteClockId

			


						SELECT TOP 1 
							@dblNewBurnRate = dblBurnRate
						FROM dbo.fnTMComputeNewBurnRateZeroDeliveryTable(@siteId,@intClockReadingId,@intLastClockReadingId,@tk_level,@intLastMonitorReadingEvent)

						SET @resultLog = @resultLog + ''UPDATING burn rate'' + char(10) 
						UPDATE tblTMSite
						SET dblBurnRate = @dblNewBurnRate
						WHERE intSiteID = @siteId
					END
		
					--update runout and forecasted date
					UPDATE tblTMSite
					SET dtmRunOutDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti),  CAST((dblTotalCapacity * @tk_level / 100 / @tk_w_dau) AS INT)) 
						,dtmForecastedDelivery = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti),  CAST((((dblTotalCapacity * @tk_level / 100) - ISNULL(dblTotalReserve,0)) / @tk_w_dau) AS INT)) 
					WHERE intSiteID = @siteId
		
					--update DD Between Delivery
					UPDATE tblTMSite
					SET dblDegreeDayBetweenDelivery = dblBurnRate * ((dblTotalCapacity * @tk_level / 100) - dblTotalReserve)
					WHERE intSiteID = @siteId
		
					--update next degree day Delivery
					UPDATE tblTMSite
					SET intNextDeliveryDegreeDay = CAST( (ISNULL((SELECT TOP 1 dblAccumulatedDegreeDay 
														   FROM tblTMDegreeDayReading 
														   WHERE intClockID = @SiteClockId 
																AND dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)),0.0)
													+ dblDegreeDayBetweenDelivery) AS INT)
					WHERE intSiteID = @siteId


					--update Estimated % left and Gals left
					UPDATE tblTMSite
					SET dblEstimatedPercentLeft = @tk_level
						,dblEstimatedGallonsLeft = (@tk_level * dblTotalCapacity) / 100
						,dtmLastReadingUpdate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)
					WHERE intSiteID = @siteId

					--update intConcurrencyId
					UPDATE tblTMSite
					SET intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
					WHERE intSiteID = @siteId

			
		
					PRINT @ta_ltankcrit
					IF(@ta_ltankcrit = 1)
					BEGIN
						GOTO CREATECALLENTRY
					END
					IF (ISNULL((SELECT DATEDIFF(dd,DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0),dtmRunOutDate) 
								FROM tblTMSite 
								WHERE intSiteID = @siteId),0) <= 5)
					BEGIN
						GOTO CREATECALLENTRY
					END 
		
		
					RETURN
					CREATECALLENTRY:
					IF EXISTS(SELECT TOP 1 1 FROM tblTMDispatch WHERE intSiteID = @siteId) 
					BEGIN
						SET @resultLog = @resultLog +  ''Already have call entry'' + CHAR(10)
						RETURN
					END	
		
					PRINT ''Create Call entry''
					EXEC uspTMGetNextWillCallStartingNumber @strOrderNumber OUTPUT

					SELECT
						[intSiteID] = intSiteID 
						,[dblPercentLeft] = dblEstimatedPercentLeft
						,[dblQuantity] = intCalculatedQuantity
						,[dblMinimumQuantity] = 0
						,[intProductID] = intProductId
						,[intSubstituteProductID] = NULL
						,[dtmRequestedDate] = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
						,[strComments] = ''Call Entry automatically generated from Tank Monitor Reading''
						,[ysnCallEntryPrinted] = 0
						,[intDriverID] = intDriverId
						,[dtmCallInDate] = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
						,[ysnDispatched] = 0
						,[intDeliveryTermID] = intDeliveryTermID
						,[dtmDispatchingDate] = null
						,strItemNo
						,intTaxStateID
						,ISNULL(ysnTaxable,0) AS  ysnTaxable
						,dblPriceAdjustment
						,intCustomerNumber
						,intLocationId
						,intSitePriceLevel
						,intCalculatedQuantity
						,strOrderNumber = @strOrderNumber
					INTO #tmpSiteOrder
					FROM (
						SELECT 
							X.* 
							,strContractNumber = ''''
						FROM vyuTMSiteOrder X
						INNER JOIN tblTMSite Z
							ON X.intSiteID = Z.intSiteID
					) A
					WHERE intSiteID = @siteId
                
					SELECT 
						A.[intSiteID]
						,A.[dblPercentLeft]
						,A.[dblQuantity]
						,A.[dblMinimumQuantity]
						,A.[intProductID]
						,A.[intSubstituteProductID]
						,A.[dtmRequestedDate]
						,A.[strComments]
						,A.[ysnCallEntryPrinted]
						,A.[intDriverID]
						,A.[dtmCallInDate]
						,A.[ysnDispatched]
						,A.[intDeliveryTermID]
						,A.[dtmDispatchingDate]
						,[dblQuantityToUse] = A.[dblQuantity] 
						,[dblItemTaxTotal] = 0
						,A.[intLocationId]
						,A.[intTaxStateID]
						,[strPricingMethod] = B.strPricing
						,[dblPrice] = B.dblPrice
						,intContractId = B.intContractDetailId
						,dblPriceAdjustment
						INTO #tmpDispatchInsert
						FROM #tmpSiteOrder A
						CROSS APPLY (
										SELECT TOP 1 Value = intIssueUOMId
										FROM tblICItemLocation
										WHERE intItemId = A.intProductID
										AND intLocationId = A.intLocationId
						)C
						CROSS APPLY (
							SELECT TOP 1 dblPrice, strPricing, intContractDetailId FROM dbo.fnTMGetItemPricingDetails(
								A.intProductId
								,A.intCustomerNumber
								,A.intLocationId
								,C.Value
								,NULL /*--@CurrencyId*/
								,GETDATE()
								,intCalculatedQuantity
								,NULL  /*--@ContractHeaderId		INT*/
								,NULL  /*--@ContractDetailId		INT*/
								,NULL  /*--@ContractNumber		NVARCHAR(50)*/
								,NULL  /*--@ContractSeq			INT*/
								,NULL  /*--@AvailableQuantity		NUMERIC(18,6)*/
								,NULL  /*--@UnlimitedQuantity     BIT*/
								,NULL  /*--@OriginalQuantity		NUMERIC(18,6)*/
								,0     /*--@CustomerPricingOnly	BIT*/
								,NULL  /*--@ItemPricingOnly*/
								,0     /*--@ExcludeContractPricing*/
								,NULL  /*--@VendorId				INT*/
								,NULL  /*--@SupplyPointId			INT*/
								,NULL  /*--@LastCost				NUMERIC(18,6)*/
								,NULL  /*--@ShipToLocationId      INT*/
								,NULL  /*--@VendorLocationId		INT*/
								,A.intSitePriceLevel /*-- @PricingLevelId*/
								,NULL
								,NULL
								,NULL /*--TermId*/
								,NULL /*--@GetAllAvailablePricing*/
								)
						) B
                
						/*--SELECT * FROM #tmpDispatchInsert
						--DELETE FROM #tmpDispatchInsert WHERE intSiteID = 3*/
                
						INSERT INTO tblTMDispatch(
							[intSiteID]
							,[dblPercentLeft]
							,[dblQuantity]
							,[dblMinimumQuantity]
							,[intProductID]
							,[intSubstituteProductID]
							,[dblPrice]
							,[dtmRequestedDate]
							,[strComments]
							,[ysnCallEntryPrinted]
							,[intDriverID]
							,[dtmCallInDate]
							,[ysnDispatched]
							,[intDeliveryTermID]
							,[dtmDispatchingDate]
							,[dblTotal]
							,[intUserID]
							,[strPricingMethod]
							,intContractId
							,strOrderNumber
						)

						SELECT 
							[intSiteID]
							,[dblPercentLeft]
							,[dblQuantity]
							,[dblMinimumQuantity]
							,[intProductID]
							,[intSubstituteProductID]
							,[dblPrice] = (CASE WHEN [strPricingMethod] LIKE ''%Standard Pricing%'' 
											THEN ([dblPrice] + ISNULL(dblPriceAdjustment,0.0))
											ELSE [dblPrice] 
											END)
							,[dtmRequestedDate]
							,[strComments]
							,[ysnCallEntryPrinted]
							,[intDriverID]
							,[dtmCallInDate]
							,[ysnDispatched]
							,[intDeliveryTermID]
							,[dtmDispatchingDate]
							,[dblTotal] = 0
							,[intUserID] = @userID
							,[strPricingMethod] = (CASE WHEN [strPricingMethod] LIKE ''%Standard Pricing%'' 
															THEN ''Regular''
														WHEN  [strPricingMethod] LIKE ''%Contracts%'' 
															THEN ''Contract''
														ELSE ''Special'' 
														END)
							,intContractId = intContractId
							,@strOrderNumber
						FROM #tmpDispatchInsert

             
                    
                    
						/*---------------------------------- Update ordernumber of will call and Total*/
						WHILE (EXISTS(SELECT TOP 1 1 FROM #tmpDispatchInsert))
						BEGIN
							SET @TotalItemTax = 0.0
							SELECT TOP 1 @siteId = A.intSiteID 
								,@ItemId = A.intProductID
								,@LocationId = A.[intLocationId]
								,@TransactionDate = A.[dtmCallInDate]
								,@ItemPrice = A.[dblPrice]
								,@Quantity = A.[dblQuantityToUse]
								,@TaxGroupId = A.intTaxStateID
								,@CustomerEntityId = B.intCustomerNumber
								,@SiteTaxable = ISNULL(C.ysnTaxable,0)
							FROM #tmpDispatchInsert A
							INNER JOIN tblTMSite C
								ON A.intSiteID = C.intSiteID
							INNER JOIN tblTMCustomer B
								ON C.intCustomerID = B.intCustomerID
					
							SET @TotalItemTax = dbo.[fnTMGetItemTotalTaxForCustomer](
													@ItemId
													,@CustomerEntityId
													,@TransactionDate
													,@ItemPrice
													,@Quantity
													,@TaxGroupId
													,@LocationId
													,NULL
													,1
													,@SiteTaxable
													,@siteId
													,NULL /*--@FreightTermId*/
													,NULL /*--@CardId*/
													,NULL /*--@VehicleId*/
													,0 /*-- @DisregardExemptionSetup*/
												)
							/*--EXEC [uspTMGetItemTaxTotal] @ItemId,@LocationId,@TransactionDate,@ItemPrice,@Quantity,@TaxGroupId,@TotalItemTax OUT*/
					
							UPDATE tblTMDispatch
							SET dblTotal = A.dblPrice * A.dblQuantityToUse + ISNULL(@TotalItemTax,0.0)
							FROM  #tmpDispatchInsert A
							WHERE A.intSiteID = @siteId
							AND tblTMDispatch.intSiteID = @siteId
					
					         					
							DELETE FROM #tmpDispatchInsert
							WHERE intSiteID = @siteId
						END
						/*---------------------------------------------*/

					UPDATE tblTMSite
					SET intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
					WHERE intSiteID = @siteId
			
		
				END
	
				print @resultLog
				SET @resultLog = @resultLog + ''Import successful''
			END
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateImportTankMonitorSP] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateImportTankMonitorSP] SP'
GO
	EXEC ('uspTMRecreateImportTankMonitorSP')
GO
	PRINT 'END OF Execute [uspTMRecreateImportTankMonitorSP] SP'
GO