

GO
PRINT 'START OF CREATING [uspTMImportTankMonitorReading] SP'
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMImportTankMonitorReading]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMImportTankMonitorReading
GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwitmmst') AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst')
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
		SET @TankMonitorEventID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strEventType = ''Event-021'')
	
		--Check for previous tank monitor reading or duplicate reading
		IF EXISTS(SELECT TOP 1 1 FROM tblTMEvent WHERE (intEventTypeID = @TankMonitorEventID AND dtmTankMonitorReading = @rpt_date_ti AND intSiteID = @siteId ))	
		BEGIN
			SET @resultLog = @resultLog + ''Duplicate Reading'' + char(10)
			SET @resultLog = @resultLog + ''Exception: Duplicate Reading'' + char(10)
			RETURN
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblTMEvent 
					WHERE ((intEventTypeID = @TankMonitorEventID AND strDescription LIKE ''%'' + CAST(@rpt_date_ti AS NVARCHAR(25)) + ''%'')
						OR (intEventTypeID = @TankMonitorEventID AND dtmTankMonitorReading > @rpt_date_ti)) AND intSiteID = @siteId)	
		BEGIN
			SET @resultLog = @resultLog + ''Reading date is less than the current reading'' + char(10)
			RETURN 
		END			
	
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
									+ ''Date: '' + CAST (@rpt_date_ti AS NVARCHAR(25)) + CHAR(10) + ''Percent Full: '' + CAST(ISNULL(@tk_level,'''') AS NVARCHAR(10)) + CHAR(10) 
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
				SET @resultLog = @resultLog + ''UPDATING burn rate'' + char(10) 
				UPDATE tblTMSite
				SET dblBurnRate = (CASE WHEN ISNULL(dblPreviousBurnRate,0) = 0 THEN dblBurnRate ELSE ((ISNULL(dblBurnRate,0) * 2) + ISNULL(dblPreviousBurnRate,0))/3.0 END)
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
				SET @resultLog = @resultLog +  ''Alredy have call entry'' + CHAR(10)
				RETURN
			END	
		
			PRINT ''Create Call entry''
			EXEC uspTMGetNextWillCallStartingNumber @strOrderNumber OUTPUT
			INSERT INTO [dbo].[tblTMDispatch]
				   ([intSiteID]
				   ,[dblPercentLeft]
				   ,[dblQuantity]
				   ,[dblMinimumQuantity]
				   ,[intProductID]
				   ,[dblPrice]
				   ,[dblTotal]
				   ,[dtmRequestedDate]
				   ,[strComments]
				   ,[ysnCallEntryPrinted]
				   ,[intDriverID]
				   ,[dtmCallInDate]
				   ,[intUserID]
				   ,[intDeliveryTermID]
				   ,[strOrderNumber] 
			  )		   
			 (SELECT TOP 1 
				   @siteId
				   ,@tk_level
				   ,(ISNULL((SELECT TOP 1 vwitm_deflt_percnt FROM vwitmmst WHERE A4GLIdentity = intProduct),0) - @tk_level) * dblTotalCapacity / 100
				   ,(ISNULL((SELECT TOP 1 vwitm_deflt_percnt FROM vwitmmst WHERE A4GLIdentity = intProduct),0) - @tk_level) * dblTotalCapacity / 100
				   ,intProduct
				   ,0
				   ,0
				   ,DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
				   ,''Call Entry automatically generated from Tank Monitor Reading''
				   ,0
				   ,intDriverID
				   ,DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
				   ,@userID
				   ,intDeliveryTermID
				   ,@strOrderNumber
			FROM tblTMSite
			WHERE intSiteID = 	@siteId  
			)
		
		END
	
		print @resultLog
		SET @resultLog = @resultLog + ''Import successful''
	END
	')
END

GO
PRINT 'END OF CREATING [uspTMImportTankMonitorReading] SP'
GO
