CREATE FUNCTION [dbo].[fnTMGetInvalidInvoicesForSync]
(
	 @Invoices	[dbo].[InvoicePostingTable] Readonly
	,@Post		BIT	= 0
)
RETURNS @returntable TABLE
(
	 [intInvoiceId]				INT				NOT NULL
	,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceDetailId]		INT				NULL
	,[intItemId]				INT				NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)
AS
BEGIN

	INSERT INTO @returntable (intInvoiceId,[strInvoiceNumber],[strTransactionType],[intInvoiceDetailId],[intItemId],[strBatchId],[strPostingError])
	SELECT * FROM (
		SELECT
			intInvoiceId = A.intInvoiceId
			,[strInvoiceNumber] = C.[strInvoiceNumber]
			,C.[strTransactionType]		
			,C.[intInvoiceDetailId]		
			,C.[intItemId]				
			,C.[strBatchId]	
			,[strPostingError] = (CASE WHEN D.ysnActive <> 1 THEN
										'Site is Inactive.'
									WHEN D.dblBurnRate = 0 THEN
										'Burn Rate is Zero.'
									WHEN ISNULL(D.dblTotalCapacity,0.0) = 0 AND D.strBillingBy = 'Tank'  THEN
										'Site total capacity is Zero.'
									WHEN E.intClockID IS NULL THEN
										'The Site Clock Location does not exists in Tank Management.'
									WHEN D.strClassFillOption = 'No' AND D.intProduct <> B.intItemId AND G.strType <> 'Service'  THEN
										'The Invoice item is different than the site item.'
									WHEN D.strClassFillOption = 'Product Class' AND F.intCategoryId <> G.intCategoryId AND G.strType <> 'Service' THEN
										'The Invoice item class is different than the site item class.'
									WHEN G.strType = 'Service' AND B.intPerformerId IS NULL THEN
										'Performer is not specified for item'
									WHEN H.intClockID IS NULL THEN
										'Invoice date does not have a matching Clock Reading record.'
									ELSE ''
								END)
		FROM tblARInvoice A
		INNER JOIN tblARInvoiceDetail B
			ON A.intInvoiceId = B.intInvoiceId
		INNER JOIN @Invoices C
			ON A.intInvoiceId = C.intInvoiceId
		INNER JOIN tblTMSite D
			ON B.intSiteId = D.intSiteID
		INNER JOIN tblTMClock E
			ON D.intClockID = E.intClockID
		LEFT JOIN tblTMDegreeDayReading H
			ON E.intClockID = H.intClockID
				AND A.dtmDate = H.dtmDate
		LEFT JOIN tblICItem F
			ON D.intProduct = F.intItemId
		LEFT JOIN tblICItem G
			ON B.intItemId = G.intItemId
		LEFT JOIN tblTMSiteDevice I
			ON D.intSiteID = I.intSiteID
		LEFT JOIN tblTMDevice	J
			ON I.intDeviceId = J.intDeviceId
		LEFT JOIN tblTMDeviceType K
			ON J.intDeviceTypeId = K.intDeviceTypeId
				AND K.strDeviceType <> 'Flow Meter'
		WHERE B.intSiteId IS NOT NULL	
			AND ISNULL(B.ysnLeaseBilling,0) <> 1
			AND D.strBillingBy <> 'Flow Meter'

		UNION ALL

		SELECT
			intInvoiceId = A.intInvoiceId
			,[strInvoiceNumber] = C.[strInvoiceNumber]
			,C.[strTransactionType]		
			,C.[intInvoiceDetailId]		
			,C.[intItemId]				
			,C.[strBatchId]	
			,[strPostingError] = (CASE WHEN D.strBillingBy = 'Flow Meter' AND J.intDeviceId IS NULL THEN
										'Site is a Flow Meter but dont have a flow meter type device record.'
								END)
		FROM tblARInvoice A
		INNER JOIN tblARInvoiceDetail B
			ON A.intInvoiceId = B.intInvoiceId
		INNER JOIN @Invoices C
			ON A.intInvoiceId = C.intInvoiceId
		INNER JOIN tblTMSite D
			ON B.intSiteId = D.intSiteID
		INNER JOIN tblTMClock E
			ON D.intClockID = E.intClockID
		LEFT JOIN tblTMDegreeDayReading H
			ON E.intClockID = H.intClockID
				AND A.dtmDate = H.dtmDate
		LEFT JOIN tblICItem F
			ON D.intProduct = F.intItemId
		LEFT JOIN tblICItem G
			ON B.intItemId = G.intItemId
		LEFT JOIN (
			SELECT 
				I.intSiteID
				,intDeviceId = (SELECT TOP 1 
									CC.intDeviceId 
								FROM tblTMSiteDevice CC
								INNER JOIN tblTMDevice AA
									ON CC.intDeviceId = AA.intDeviceId
								INNER JOIN tblTMDeviceType BB
									ON AA.intDeviceTypeId = BB.intDeviceTypeId
								WHERE BB.strDeviceType = 'Flow Meter'
									AND CC.intSiteID = I.intSiteID)
							
			FROM tblTMSite I) J
			ON D.intSiteID = J.intSiteID
		WHERE D.strBillingBy = 'Flow Meter'
			AND ISNULL(B.ysnLeaseBilling,0) <> 1
	) AA WHERE AA.[strPostingError] <> '' AND AA.[strPostingError] IS NOT NULL

																												
	RETURN
END
