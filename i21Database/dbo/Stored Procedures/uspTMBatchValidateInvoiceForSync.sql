CREATE PROCEDURE uspTMBatchValidateInvoiceForSync 
	@InvoiceTableId Id READONLY
AS
BEGIN

	DECLARE @ValidationResult TABLE(
		intInvoiceId INT,
		strErrorMessage NVARCHAR(MAX)
	)

	--------------------------------------------------------------------
	--Check if invoice have at least 1 siteId on the invoice details
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT 
		intInvoiceId
		,'No Consumption Site invoice to process.'
	FROM @InvoiceTableId A
	LEFT JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	WHERE (B.ysnLeaseBilling = 0 OR B.ysnLeaseBilling IS NULL)
		AND B.intSiteId IS NULL
		AND intInvoiceId NOT IN (
									SELECT DISTINCT
										intInvoiceId
									FROM @InvoiceTableId A
									INNER JOIN tblARInvoiceDetail B
										ON A.intId = B.intInvoiceId
									WHERE (B.ysnLeaseBilling = 0 OR B.ysnLeaseBilling IS NULL)
								)
	IF EXISTS(SELECT TOP 1 1 FROM @ValidationResult)
	BEGIN
		GOTO DONEVALIDATING
	END
	
	
	--------------------------------------------------------------------
	---Check if site is active
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'Site is Inactive.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE C.ysnActive IS NULL OR C.ysnActive = 0
		AND Z.intInvoiceId IS NULL



	--------------------------------------------------------------------
	---Check Site burn rate if zero
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'Burn Rate is Zero.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE C.dblBurnRate IS NULL OR C.dblBurnRate = 0
		AND Z.intInvoiceId IS NULL



	--------------------------------------------------------------------
	---Check Site Tank Capacity if zero
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'Site total capacity is Zero.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE (C.dblTotalCapacity IS NULL OR C.dblTotalCapacity = 0)
		AND C.strBillingBy = 'Tank'
		AND Z.intInvoiceId IS NULL
	



	--------------------------------------------------------------------
	---Check Site Clock Location if exists
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'The Site Clock Location does not exists in Tank Management.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	LEFT JOIN tblTMClock D
		ON C.intClockID = D.intClockID
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE D.intClockID IS NULL
		AND Z.intInvoiceId IS NULL

	IF EXISTS(SELECT TOP 1 1 FROM @ValidationResult)
	BEGIN
		GOTO DONEVALIDATING
	END


	--------------------------------------------------------------------
	---Check Site Item vs Invoice
	--------------------------------------------------------------------
	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'The Invoice item is different than the site item.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	INNER JOIN tblICItem D
		ON B.intItemId = D.intItemId
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE B.intItemId <> C.intProduct
		AND strClassFillOption = 'No'
		AND D.strType <> 'Service'
		AND Z.intInvoiceId IS NULL

	IF EXISTS(SELECT TOP 1 1 FROM @ValidationResult)
	BEGIN
		GOTO DONEVALIDATING
	END

	--------------------------------------------------------------------
	---Check Site Item CAtegory vs Invoice item Category
	--------------------------------------------------------------------
	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'The Invoice item class is different than the site item class.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	INNER JOIN tblICItem D
		ON B.intItemId = D.intItemId
	INNER JOIN tblICItem E
		ON C.intProduct = E.intItemId
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE B.intItemId <> C.intProduct
		AND strClassFillOption = 'Product Class'
		AND D.strType <> 'Service'
		AND D.intCategoryId <> E.intCategoryId
		AND Z.intInvoiceId IS NULL

	IF EXISTS(SELECT TOP 1 1 FROM @ValidationResult)
	BEGIN
		GOTO DONEVALIDATING
	END

	--------------------------------------------------------------------
	---Check Performer if item is service type
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'Performer is not specified for item.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	INNER JOIN tblICItem D
		ON B.intItemId = D.intItemId
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE B.intItemId <> C.intProduct
		AND D.strType = 'Service'
		AND B.intPerformerId IS NULL
		AND Z.intInvoiceId IS NULL




	--------------------------------------------------------------------
	---Check Clock reading for the Invoice Date
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'Invoice date does not have a matching Clock Reading record.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	INNER JOIN tblICItem D
		ON B.intItemId = D.intItemId
	INNER JOIN tblARInvoice E
		ON B.intInvoiceId = E.intInvoiceId
	OUTER APPLY(
		SELECT TOP 1 dtmDate FROM tblTMDegreeDayReading WHERE intClockID = C.intClockID AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, E.dtmDate), 0)
	)F
	OUTER APPLY(
		SELECT TOP 1 dtmDate FROM tblTMDDReadingSeasonResetArchive WHERE intClockID = C.intClockID AND dtmDate = DATEADD(DAY, DATEDIFF(DAY, 0, E.dtmDate), 0)
	)G
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE F.dtmDate IS NULL 
		AND G.dtmDate IS NULL
		AND Z.intInvoiceId IS NULL
		AND C.ysnRequireClock = 1


	--------------------------------------------------------------------
	---Check for Site Device if billing by is Flow meter
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'Site is a Flow Meter and does not have a device.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	OUTER APPLY(
		SELECT TOP 1 intSiteID FROM tblTMSiteDevice WHERE intSiteID = C.intSiteID
	)D
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE D.intSiteID IS NULL
		AND C.strBillingBy = 'Flow Meter'
		AND Z.intInvoiceId IS NULL


	--------------------------------------------------------------------
	---Check for Flow Meter Device if billing by is Flow meter
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'Site is a Flow Meter but dont have a flow meter type device record.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	OUTER APPLY(
		SELECT TOP 1 AA.intSiteID 
		FROM tblTMSiteDevice AA 
		INNER JOIN tblTMDevice BB
			ON AA.intDeviceId = BB.intDeviceId
		INNER JOIN tblTMDeviceType CC
			ON BB.intDeviceTypeId = CC.intDeviceTypeId
		WHERE AA.intSiteID = C.intSiteID
			AND CC.strDeviceType = 'Flow Meter'
	)D
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE D.intSiteID IS NULL
		AND C.strBillingBy = 'Flow Meter'
		AND Z.intInvoiceId IS NULL

	
	--------------------------------------------------------------------
	---Check for Flow Meter Device if billing by is Flow meter
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'No Meter type setup for flow meter device/s.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	OUTER APPLY(
		SELECT TOP 1 intSiteID 
		FROM tblTMSiteDevice AA
		INNER JOIN tblTMDevice BB
			ON AA.intDeviceId = BB.intDeviceId
		INNER JOIN tblTMDeviceType CC
			ON BB.intDeviceTypeId = CC.intDeviceTypeId
		LEFT JOIN tblTMMeterType DD
			ON BB.intMeterTypeId = DD.intMeterTypeId
		WHERE AA.intSiteID = C.intSiteID
			AND CC.strDeviceType = 'Flow Meter'
			AND DD.intMeterTypeId IS NULL

	)D
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE D.intSiteID IS NULL
		AND C.strBillingBy = 'Flow Meter'
		AND Z.intInvoiceId IS NULL

	


	--------------------------------------------------------------------
	---Check Locked CS record
	--------------------------------------------------------------------

	INSERT INTO @ValidationResult(
		intInvoiceId
		,strErrorMessage
	)
	SELECT DISTINCT
		B.intInvoiceId
		,'Consumption Site record is locked.'
	FROM @InvoiceTableId A
	INNER JOIN tblARInvoiceDetail B
		ON A.intId = B.intInvoiceId
	INNER JOIN tblTMSite C
		ON B.intSiteId = C.intSiteID
	OUTER APPLY(
		SELECT TOP 1 intTransactionId 
		FROM tblSMTransaction AA 
		INNER JOIN tblSMScreen BB
			ON AA.intScreenId = BB.intScreenId
		WHERE BB.strModule = 'Tank Management'
				AND strNamespace = 'TankManagement.view.ConsumptionSite'
			AND intRecordId =  C.intSiteID
			AND ysnLocked = 1
	)D
	OUTER APPLY(
		SELECT TOP 1 intInvoiceId FROM @ValidationResult WHERE intInvoiceId = A.intId
	)Z
	WHERE D.intTransactionId IS NOT NULL
		AND Z.intInvoiceId IS NULL	


	DONEVALIDATING:
	SELECT * FROM @ValidationResult
		
END	
GO	
	
	
	
		