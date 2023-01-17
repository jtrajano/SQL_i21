CREATE PROCEDURE uspTMValidateInvoiceForSync 
	@InvoiceId INT
	,@ResultLog NVARCHAR(MAX) = '' OUTPUT 
AS
BEGIN
	DECLARE @intSiteId INT
	DECLARE @intItemId INT
	DECLARE @intClockId INT
	DECLARE @intInvoiceDetailId INT
	DECLARE @dtmInvoiceDate DATETIME
	DECLARE @intPerformerId INT
	DECLARE @strInvoiceNumber NVARCHAR(100)
	DECLARE @intRowCount INT
	DECLARE @strSiteBillingBy NVARCHAR(10)
	DECLARE @strClassFill NVARCHAR(15)
	DECLARE @intSiteItemId INT
	DECLARE @strItemType NVARCHAR(50)
	DECLARE @intScreenId INT
	DECLARE @intCustomerID INT
	DECLARE @ysnRequireClock BIT

	SET @ResultLog = ''

	SELECT 
		@dtmInvoiceDate = dtmDate
	FROM tblARInvoice
	WHERE intInvoiceId = @InvoiceId 
	
	SELECT 
		A.*
		,strItemType = B.strType
	INTO #tmpTMValidInvoiceDetail 
	FROM tblARInvoiceDetail A
	INNER JOIN tblICItem B
		ON A.intItemId = B.intItemId	
	WHERE intInvoiceId = @InvoiceId
		AND intSiteId IS NOT NULL
	
	SET @intRowCount = 0
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM #tmpTMValidInvoiceDetail WHERE intSiteId IS NOT NULL AND ISNULL(ysnLeaseBilling ,0) <> 1)
	BEGIN
		SET @ResultLog = @ResultLog + 'Exception:No Consumption Site invoice to process.'
	END
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpTMValidInvoiceDetail)
	BEGIN
		SET @intRowCount = @intRowCount + 1
		
		SET @intPerformerId = NULL
		SELECT TOP 1 
			@intSiteId = intSiteId 
			,@intItemId = intItemId
			,@intInvoiceDetailId = intInvoiceDetailId
			,@intPerformerId = intPerformerId
			,@strItemType = strItemType
		FROM #tmpTMValidInvoiceDetail
		
		SELECT 
			@intClockId = intClockID
			,@strSiteBillingBy = strBillingBy
			,@intSiteItemId = intProduct
			,@strClassFill = strClassFillOption
			,@intCustomerID = intCustomerID
			,@ysnRequireClock = ysnRequireClock
		FROM tblTMSite
		WHERE intSiteID = @intSiteId
		
		IF((SELECT ysnActive FROM tblTMSite WHERE intSiteID = @intSiteId) != 1)
		BEGIN
			SET @ResultLog = @ResultLog + 'Exception:Site is Inactive.' + CHAR(10)
			GOTO DONEVALIDATING
		END
		
		IF((SELECT dblBurnRate FROM tblTMSite WHERE intSiteID = @intSiteId) = 0)
		BEGIN
			SET @ResultLog = @ResultLog + 'Exception:Burn Rate is Zero.' + CHAR(10)
			GOTO DONEVALIDATING
		END

		IF((SELECT ISNULL(dblTotalCapacity,0.0) FROM tblTMSite WHERE intSiteID = @intSiteId AND strBillingBy = 'Tank') = 0)
		BEGIN
			SET @ResultLog = @ResultLog + 'Exception:Site total capacity is Zero.' + CHAR(10)
			GOTO DONEVALIDATING
		END
		
		IF(@ysnRequireClock  = 1 AND (NOT EXISTS(SELECT TOP 1 1 FROM tblTMClock WHERE intClockID = @intClockId)))
		BEGIN
			SET @ResultLog = @ResultLog + 'Exception:The Site Clock Location does not exists in Tank Management.' + CHAR(10)
			GOTO DONEVALIDATING
		END

		--Check Product Class
		IF(@intSiteItemId <> @intItemId)
		BEGIN
			IF(@strClassFill = 'No')
			BEGIN
				IF(@strItemType <> 'Service')
				BEGIN
					SET @ResultLog = @ResultLog + 'Exception:The Invoice item is different than the site item.' + CHAR(10)
					GOTO DONEVALIDATING
				END
			END

			IF(@strClassFill = 'Product Class')
			BEGIN
				IF((SELECT TOP 1 intCategoryId FROM tblICItem WHERE intItemId = @intItemId) <> (SELECT TOP 1 intCategoryId FROM tblICItem WHERE intItemId = @intSiteItemId) )
				BEGIN
					IF(@strItemType <> 'Service')
					BEGIN
						SET @ResultLog = @ResultLog + 'Exception:The Invoice item class is different than the site item class.' + CHAR(10)
					END
				GOTO DONEVALIDATING
				END
			END
		END

		
		IF((SELECT TOP 1 strType FROM tblICItem WHERE intItemId = @intItemId) = 'Service')
		BEGIN
			IF(@intPerformerId IS NULL)
			BEGIN
				SET @ResultLog = @ResultLog + 'Exception:Performer is not specified for item ' + (SELECT strItemNo FROM tblICItem WHERE intItemId = @intItemId) + CHAR(10)
			END
		END
		ELSE
		BEGIN
			IF @ysnRequireClock  = 1 AND (NOT EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmInvoiceDate), 0)))
			BEGIN 
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDDReadingSeasonResetArchive WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmInvoiceDate), 0))
				BEGIN
					SET @ResultLog = @ResultLog + 'Exception:Invoice date does not have a matching Clock Reading record.' + CHAR(10)
					GOTO DONEVALIDATING
				END
			END
			IF(@strSiteBillingBy = 'Flow Meter')
			BEGIN
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMSiteDevice WHERE intSiteID = @intSiteId)
				BEGIN
					SET @ResultLog = @ResultLog + 'Exception:Site is a Flow Meter and does not have a device.' + CHAR(10)
					GOTO DONEVALIDATING
				END
				
				IF NOT EXISTS(	SELECT TOP 1 1 
							FROM tblTMSiteDevice A
							INNER JOIN tblTMDevice B
								ON A.intDeviceId = B.intDeviceId
							INNER JOIN tblTMDeviceType C
								ON B.intDeviceTypeId = C.intDeviceTypeId
							WHERE A.intSiteID = @intSiteId
								AND strDeviceType = 'Flow Meter')
				BEGIN
					SET @ResultLog = @ResultLog + 'Exception:Site is a Flow Meter but dont have a flow meter type device record.' + CHAR(10)
					GOTO DONEVALIDATING
				END
				
				IF NOT EXISTS(	SELECT TOP 1 1 
							FROM tblTMSiteDevice A
							INNER JOIN tblTMDevice B
								ON A.intDeviceId = B.intDeviceId
							INNER JOIN tblTMDeviceType C
								ON B.intDeviceTypeId = C.intDeviceTypeId
							INNER JOIN tblTMMeterType D
								ON B.intMeterTypeId = D.intMeterTypeId
							WHERE A.intSiteID = @intSiteId
								AND strDeviceType = 'Flow Meter')
				BEGIN
					SET @ResultLog = @ResultLog + 'Exception:No Meter type setup for flow meter device/s.' + CHAR(10)
					GOTO DONEVALIDATING
				END
			END

			------------------------Check CS Locked Record
			SELECT TOP 1 
				@intScreenId = intScreenId 
			FROM tblSMScreen
			WHERE strModule = 'Tank Management'
				AND strNamespace = 'TankManagement.view.ConsumptionSite'

			IF EXISTS(SELECT TOP 1 1 
						FROM tblSMTransaction 
						WHERE intScreenId = @intScreenId
							AND intRecordId =  @intCustomerID
							AND ysnLocked = 1)
			BEGIN
				SET @ResultLog = @ResultLog + 'Exception:Consumption Site record is locked.' + CHAR(10)
				GOTO DONEVALIDATING
			END

		END
		
		CONTINUELOOP:
		DELETE FROM #tmpTMValidInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId
	END
		
DONEVALIDATING:
	IF((SELECT CASE WHEN @ResultLog LIKE '%Exception%' THEN 1 ELSE 0 END) = 0)
	BEGIN
		SET @ResultLog = 'OK'
	END
END
GO