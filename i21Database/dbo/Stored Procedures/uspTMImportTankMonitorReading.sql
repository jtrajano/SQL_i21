	CREATE PROCEDURE [dbo].[uspTMImportTankMonitorReading] 
		@customerid NVARCHAR(50) = '',
		@ts_capacity NUMERIC(18,6) = 0,
		@str_rpt_date_ti NVARCHAR(20) = NULL,
		@ts_cat_1 NVARCHAR(50) = '', --5 customer Number
		@tk_level NUMERIC(18,6) = NULL,
		@tk_w_dau NUMERIC(18,6) = NULL,
		@tx_serialnum NVARCHAR(50) = '', --11 tank Monitor
		@base_temp NVARCHAR(50) = '',
		@ta_ltankcrit BIT = 0,
		@tx_nosensor BIT = 1,
		@tx_lnoxmit BIT = 1,
		@ts_tankserialnum NVARCHAR(50) = '', --19 tank Serial
		@userID INT = NULL,
		@is_wesroc BIT = 1,
		@qty_in_tank  NUMERIC(18,6) = NULL,
		@resultLog NVARCHAR(4000)= '' OUTPUT,
		@resultSavingStatus int = 3 output, -- should include in build (9/4/2019)
		@intInterfaceTypeId INT = NULL,
		@intImportTankReadingId INT = NULL,
		@intRecord INT = NULL
	AS  
				BEGIN 

		--Return 0 = no match site
		--SET @resultLog = 'hello'
	
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
        DECLARE @SiteTaxable    BIT
		DECLARE @CustomerEntityId INT
		DECLARE @ExceptionValue NVARCHAR(50)
		DECLARE @dblTankReserve NUMERIC(18,6) = 0.00

		
 
		SET @resultLog = '';
		SET @resultSavingStatus = 3;

		--IF(ISNULL(@customerid,'') = '')BEGIN
		--	SET @resultLog = @resultLog +  'Failed customerid validation' + char(10)
		--	RETURN 
		--END
	
		SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS  +  case when @is_wesroc = 1 then 'passed customerid validation' + char(10) else '' end
	
		--IF(ISNULL(@ts_cat_1,'') = '')BEGIN
		--	SET @resultLog = @resultLog +  'Failed Tank Monitor Serial validation' + char(10)
		--	RETURN
		--END
	
		SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + case when @is_wesroc = 1 then 'passed Tank Monitor Serial validation' + char(10) else '' end
	
		--IF(ISNULL(@ts_tankserialnum,'') = '')
		--BEGIN 
		--	SET @resultLog = @resultLog + 'Failed Tank Serial validation' + char(10)
		--	RETURN 
		--END
		SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS +  case when @is_wesroc = 1 then 'passed Tank Serial validation' + char(10) else '' end
	
		IF(@tx_nosensor <> 0) RETURN 10
		IF(@tx_lnoxmit <> 0) RETURN 10
	
		SET @ExceptionValue = 'Exception';

		if (@is_wesroc = 0)
		begin
			SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS +   'ESN = ' + ISNULL(@tx_serialnum COLLATE Latin1_General_CI_AS,'') + char(10)
			SET @ExceptionValue = 'Status';
		end

		SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS +   'Customer Number = ' + ISNULL(@ts_cat_1 COLLATE Latin1_General_CI_AS,'') + char(10)
		--print 'Customer Number = ' + ISNULL(@ts_cat_1,'')
		--Check by customer and Tank monitor serial number

		DECLARE @intCustomerId INT = NULL
		 
		SELECT TOP 1 @siteId = A.intSiteID,  @intCustomerId = B.intCustomerNumber FROM tblTMSite A
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN vyuTMCustomerEntityView C
				ON B.intCustomerNumber = C.A4GLIdentity
			INNER JOIN tblTMSiteDeviceTankMonitor D
				ON A.intSiteID = D.intSiteId
			INNER JOIN tblTMDeviceTankMonitor TD
				ON D.intDeviceTankMonitorId = TD.intDeviceTankMonitorId
			INNER JOIN tblTMDevice E
				ON TD.intDeviceId = E.intDeviceId
			INNER JOIN tblTMDeviceType F
				ON E.intDeviceTypeId = F.intDeviceTypeId		
			WHERE B.intCustomerNumber = (SELECT TOP 1 A4GLIdentity FROM vyuTMCustomerEntityView WHERE vwcus_key = @ts_cat_1 COLLATE Latin1_General_CI_AS)
				AND F.strDeviceType = 'Tank Monitor'
				AND E.strSerialNumber = @tx_serialnum COLLATE Latin1_General_CI_AS
	
		--Check by customer and Tank device serial number
		IF(@siteId IS NULL)
		BEGIN
			SELECT TOP 1 @siteId = A.intSiteID, @intCustomerId = B.intCustomerNumber  FROM tblTMSite A
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
			WHERE B.intCustomerNumber = (SELECT TOP 1 A4GLIdentity FROM vyuTMCustomerEntityView WHERE vwcus_key = @ts_cat_1 COLLATE Latin1_General_CI_AS)
				AND F.strDeviceType = 'Tank'
				AND E.strSerialNumber = @ts_tankserialnum COLLATE Latin1_General_CI_AS
		END
		IF(@ts_capacity = 0)
		BEGIN
			select @ts_capacity =dblTotalCapacity from tblTMSite where intSiteID = @siteId
		END
		IF(@ts_capacity = 0)
		BEGIN
			select @ts_capacity =dblTotalCapacity from tblTMSite where intSiteID = @siteId
		END
		IF(@siteId IS NULL)
		BEGIN 
			SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + @ExceptionValue + ': Not Matching.' + char(10)
			set @resultSavingStatus = 1;

			-- LOG to tblTMImportTankReadingDetail
			INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intRecord, ysnValid, strMessage)
			VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intRecord, 0, 'No matched device and customer number')

			RETURN 
		END

		IF ISDATE(@str_rpt_date_ti COLLATE Latin1_General_CI_AS) = 0
		BEGIN
			-- LOG to tblTMImportTankReadingDetail
			INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, ysnValid, strMessage)
			VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId,  0, 'Invalid Reading Date')
			RETURN 
		END

		SET @rpt_date_ti = @str_rpt_date_ti COLLATE Latin1_General_CI_AS

		SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + 'Site ID = ' + CAST(ISNULL(@siteId,'') AS NVARCHAR(10)) + char(10) 
		SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS +  'Date = ' + CAST(@rpt_date_ti AS NVARCHAR(30))  + char(10) 	
	
		--print 'get DegreeDay'
		--Get degreeDay reading of for the tank monitor date
		SELECT TOP 1 
				@SiteLastDeliveryDate = dtmLastDeliveryDate
				,@SiteClockId = intClockID
			FROM tblTMSite
			WHERE intSiteID = @siteId 
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE dtmDate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0) AND intClockID = @SiteClockId) 
		BEGIN
			--PRINT 'No clock Reading'
			SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + 'No clock Reading' + char(10);
			set @resultSavingStatus = 1;

			-- LOG to tblTMImportTankReadingDetail
			INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid, strMessage)
			VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 0, 'No clock reading')

			RETURN
		END

		-- Check if site has tank
		SET @TankMonitorEventID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strDefaultEventType = 'Event-021')
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMSiteDevice SD
			INNER JOIN tblTMDevice D ON D.intDeviceId = SD.intDeviceId
			INNER JOIN tblTMDeviceType DT ON DT.intDeviceTypeId = D.intDeviceTypeId
			WHERE DT.strDeviceType = 'Tank'
			AND SD.intSiteID = @siteId)
		BEGIN
			INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid, strMessage)
			VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 1, 'Site has no tank')
			print 'capacity <> 0'
			--add insert to event
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
								,'Consumption Site'
								,@rpt_date_ti
								,(	  'Tank Serial Number: ' + ISNULL(@ts_tankserialnum COLLATE Latin1_General_CI_AS,'') + CHAR(10)
									+ 'Monitor Serial Number: ' + ISNULL(@tx_serialnum COLLATE Latin1_General_CI_AS,'') + CHAR(10) 
									+ 'Date: ' + CAST (@rpt_date_ti AS NVARCHAR(25)) + CHAR(10)
									+ 'Percent Full: ' + CAST(ISNULL(@tk_level,0.0) AS NVARCHAR(10)) + CHAR(10) 
									+ (case when @is_wesroc = 1 then 'Inside Temperature: ' + CAST(ISNULL(@base_temp COLLATE Latin1_General_CI_AS,'') AS NVARCHAR(20)) + CHAR(10) else '' end)
								)
								,0
								,0	
								)		 

			RETURN
		END

		IF(@ts_capacity = 0)
		BEGIN
			INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid, strMessage)
			VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 1, 'Site has no tank')
			print 'capacity = 0'			
		    --add insert to event
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
								,'Consumption Site'
								,@rpt_date_ti
								,(	  'Tank Serial Number: ' + ISNULL(@ts_tankserialnum COLLATE Latin1_General_CI_AS,'') + CHAR(10)
									+ 'Monitor Serial Number: ' + ISNULL(@tx_serialnum COLLATE Latin1_General_CI_AS,'') + CHAR(10) 
									+ 'Date: ' + CAST (@rpt_date_ti AS NVARCHAR(25)) + CHAR(10)
									+ 'Percent Full: ' + CAST(ISNULL(@tk_level,0.0) AS NVARCHAR(10)) + CHAR(10) 
									+ (case when @is_wesroc = 1 then 'Inside Temperature: ' + CAST(ISNULL(@base_temp COLLATE Latin1_General_CI_AS,'') AS NVARCHAR(20)) + CHAR(10) else '' end)
								)
								,0
								,0	
								)	
			RETURN
		END
		--Get the event ID of the tank monitor reading event
		--SET @TankMonitorEventID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strDefaultEventType = 'Event-021')
	
		--Check for previous tank monitor reading or duplicate reading
		IF EXISTS(SELECT TOP 1 1 FROM tblTMEvent WHERE (intEventTypeID = @TankMonitorEventID AND dtmTankMonitorReading = @rpt_date_ti AND intSiteID = @siteId ))	
		BEGIN
			SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + 'Duplicate Reading' + char(10)
			SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + @ExceptionValue + ': Duplicate Reading' + char(10)
			set @resultSavingStatus = 1;

			-- LOG to tblTMImportTankReadingDetail
			INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid, strMessage)
			VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 0, 'Duplicate reading')

			RETURN
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblTMEvent 
					WHERE ((intEventTypeID = @TankMonitorEventID AND dtmTankMonitorReading > @rpt_date_ti)) AND intSiteID = @siteId)	
		BEGIN
			SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + 'Reading date is less than the current reading' + char(10)
			set @resultSavingStatus = 1;

			-- LOG to tblTMImportTankReadingDetail
			INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid, strMessage)
			VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 0, 'Reading date is less than the current reading')

			RETURN 
		END
		
		--- Get Last Monitor Reading 
		SELECT TOP 1 
			@intLastMonitorReadingEvent = intEventID
		FROM tblTMEvent 
		WHERE intSiteID = @siteId
			AND intEventTypeID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strDefaultEventType = 'Event-021')
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
								,'Consumption Site'
								,@rpt_date_ti
								,(	  'Tank Serial Number: ' + ISNULL(@ts_tankserialnum COLLATE Latin1_General_CI_AS,'') + CHAR(10)
									+ 'Monitor Serial Number: ' + ISNULL(@tx_serialnum COLLATE Latin1_General_CI_AS,'') + CHAR(10) 
									+ 'Date: ' + CAST (@rpt_date_ti AS NVARCHAR(25)) + CHAR(10)
									+ 'Percent Full: ' + CAST(ISNULL(@tk_level,0.0) AS NVARCHAR(10)) + CHAR(10) 
									+ (case when @is_wesroc = 1 then 'Inside Temperature: ' + CAST(ISNULL(@base_temp COLLATE Latin1_General_CI_AS,'') AS NVARCHAR(20)) + CHAR(10) else '' end)
								)
								,0
								,0	
								)		 
	
		--Check if site is not on hold then update the site
		IF ((SELECT TOP 1 ISNULL(ysnOnHold,0) FROM tblTMSite WHERE intSiteID = @siteId) <> 1)
		BEGIN
			--PRINT 'Update Site'
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

				-- do not update bun rate if eco green importing
				if (@is_wesroc = 1)
				begin
					SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + 'UPDATING burn rate' + char(10) 
					UPDATE tblTMSite
					SET dblBurnRate = @dblNewBurnRate
					WHERE intSiteID = @siteId
				end
			END
		
			if (@is_wesroc = 1)
			begin
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
			end


			--update Estimated % left and Gals left
			UPDATE tblTMSite
			SET dblEstimatedPercentLeft = @tk_level
				,dblEstimatedGallonsLeft = ((@tk_level * dblTotalCapacity) / 100) --(case when @is_wesroc = 1 then ((@tk_level * dblTotalCapacity) / 100) else @qty_in_tank end)
				,dtmLastReadingUpdate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)
			WHERE intSiteID = @siteId

			--update intConcurrencyId
			UPDATE tblTMSite
			SET intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
			WHERE intSiteID = @siteId

			-- Prevent Anova from creating order
			IF(@intInterfaceTypeId != 3)	
			BEGIN
				--prevent eco green from creating order since @ta_ltankcrit is not supplied from API and run out date is not calculated due to lack of requirement to calculate
				if (@is_wesroc = 0)
				begin
					set @dblTankReserve = (select dblTankReserve = sum(isnull(c.dblTankReserve,0.00)) from tblTMSiteDevice b, tblTMDevice c where b.intSiteID = @siteId and c.intDeviceId = b.intDeviceId and isnull(c.ysnAppliance,0) = 0);
					if (@qty_in_tank >= @dblTankReserve)
					begin
						SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + 'Import successful';

						-- LOG to tblTMImportTankReadingDetail
						INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid)
						VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 1)

						return;
					end
					else
					begin
						GOTO CREATECALLENTRY;
					end
				end
			
				IF @ta_ltankcrit = 1
				BEGIN
					GOTO CREATECALLENTRY
				END
				ELSE IF (@intInterfaceTypeId = 1 AND (ISNULL((SELECT DATEDIFF(dd,DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0),dtmRunOutDate) 
									FROM tblTMSite 
									WHERE intSiteID = @siteId),0) <= 5))
				BEGIN
					GOTO CREATECALLENTRY
				END
				ELSE IF @intInterfaceTypeId = 1
				BEGIN
					-- LOG to tblTMImportTankReadingDetail
					INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid)
					VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 1)
				END
			END

			IF(@intInterfaceTypeId = 3)
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM tblTMSite WHERE intSiteID = @siteId AND dtmRunOutDate IS NOT NULL)
				BEGIN
					IF (ISNULL((SELECT DATEDIFF(dd,DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0),dtmRunOutDate) 
								FROM tblTMSite 
								WHERE intSiteID = @siteId),0) <= 5)
					BEGIN
						GOTO CREATECALLENTRY
					END
				END
				ELSE
				BEGIN
					SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + 'Import successful';

					-- LOG to tblTMImportTankReadingDetail
					INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid)
					VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 1)

				END
			END
	
		
			RETURN;
			CREATECALLENTRY:

			IF EXISTS(SELECT TOP 1 1 FROM tblTMDispatch WHERE intSiteID = @siteId) 
			BEGIN
				SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS +  'Already have call entry' + CHAR(10)
				set @resultSavingStatus = 1;
				
				-- LOG to tblTMImportTankReadingDetail
				INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid, strMessage)
				VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 0, 'Already have a call entry')

				RETURN
			END	
		
			--PRINT 'Create Call entry'
			EXEC uspTMGetNextWillCallStartingNumber @strOrderNumber OUTPUT

			SELECT
                [intSiteID] = intSiteID 
                ,[dblPercentLeft] = dblEstimatedPercentLeft
                ,[dblQuantity] = intCalculatedQuantity
                ,[dblMinimumQuantity] = 0
                ,[intProductID] = intProductId
                ,[intSubstituteProductID] = NULL
                ,[dtmRequestedDate] = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
                ,[strComments] = 'Call Entry automatically generated from Tank Monitor Reading'
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
		            ,strContractNumber = ''
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
                        A.intProductID
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
                    ,[dblPrice] = (CASE WHEN [strPricingMethod] LIKE '%Standard Pricing%' 
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
                    ,[strPricingMethod] = (CASE WHEN [strPricingMethod] LIKE '%Standard Pricing%' 
													THEN 'Regular'
												WHEN  [strPricingMethod] LIKE '%Contracts%' 
													THEN 'Contract'
												ELSE 'Special' 
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
		ELSE
		BEGIN
			--update Estimated % left and Gals left
			UPDATE tblTMSite
			SET dblEstimatedPercentLeft = @tk_level
				,dblEstimatedGallonsLeft = ((@tk_level * dblTotalCapacity) / 100)--(case when @is_wesroc = 1 then ((@tk_level * dblTotalCapacity) / 100) else @qty_in_tank end)
				,dtmLastReadingUpdate = DATEADD(dd, DATEDIFF(dd, 0, @rpt_date_ti), 0)
			WHERE intSiteID = @siteId
		END
	
		--print @resultLog
		SET @resultLog = @resultLog COLLATE Latin1_General_CI_AS + 'Import successful'

		-- LOG to tblTMImportTankReadingDetail
		INSERT INTO tblTMImportTankReadingDetail (intImportTankReadingId, strEsn, strCustomerNumber, intCustomerId, intRecord, intSiteId, dtmReadingDate, ysnValid)
		VALUES(@intImportTankReadingId, @tx_serialnum COLLATE Latin1_General_CI_AS, @ts_cat_1, @intCustomerId, @intRecord, @siteId, @rpt_date_ti, 1)

	END