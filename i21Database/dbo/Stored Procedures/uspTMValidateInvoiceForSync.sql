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


	SET @ResultLog = ''

	SELECT 
		@dtmInvoiceDate = dtmDate
	FROM tblARInvoice
	WHERE intInvoiceId = @InvoiceId 
	
	SELECT *
	INTO #tmpInvoiceDetail
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @InvoiceId
		AND intSiteId IS NOT NULL
	
	SET @intRowCount = 0
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM #tmpInvoiceDetail WHERE intSiteId IS NOT NULL AND ISNULL(ysnLeaseBilling ,0) <> 1)
	BEGIN
		SET @ResultLog = @ResultLog + 'Exception:No Consumption Site invoice to process.'
	END
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpInvoiceDetail)
	BEGIN
		SET @intRowCount = @intRowCount + 1
		
		SET @intPerformerId = NULL
		SELECT TOP 1 
			@intSiteId = intSiteId 
			,@intItemId = intItemId
			,@intInvoiceDetailId = intInvoiceDetailId
			,@intPerformerId = intPerformerId
		FROM #tmpInvoiceDetail
		
		SELECT 
			@intClockId = intClockID
			,@strSiteBillingBy = strBillingBy
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
		
		IF(NOT EXISTS(SELECT TOP 1 1 FROM tblTMClock WHERE intClockID = @intClockId))
		BEGIN
			SET @ResultLog = @ResultLog + 'Exception:The Site Clock Location does not exists in Tank Management.' + CHAR(10)
			GOTO DONEVALIDATING
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
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE intClockID = @intClockId AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, @dtmInvoiceDate), 0))
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
		END
		
		CONTINUELOOP:
		DELETE FROM #tmpInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId
	END
		
DONEVALIDATING:
	IF((SELECT CASE WHEN @ResultLog LIKE '%Exception%' THEN 1 ELSE 0 END) = 0)
	BEGIN
		SET @ResultLog = 'OK'
	END
END
GO