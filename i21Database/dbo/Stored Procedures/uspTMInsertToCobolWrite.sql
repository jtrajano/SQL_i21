CREATE PROCEDURE uspTMInsertToCobolWrite 
	@InvoiceId INT
AS
BEGIN
	IF OBJECT_ID('tempdb..#tmpCOBOLInvoiceDetail') IS NOT NULL DROP TABLE #tmpCOBOLInvoiceDetail
	
	SELECT *
		,intTMLineNumber = ROW_NUMBER() OVER (ORDER BY intInvoiceDetailId)
	INTO #tmpCOBOLInvoiceDetail
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @InvoiceId
		AND ISNULL(intSiteId,0) <> 0
		AND ISNULL(ysnLeaseBilling,0) <> 1
			
	INSERT INTO tblTMCOBOLWRITE
			([CustomerNumber]
			,[SiteNumber]
			,[MeterReading]
			,[InvoiceNumber]
			,[BulkPlantNumber]
			,[InvoiceDate]
			,[ItemNumber]
			,[ItemAvailableForTM]
			,[ReversePreviousDelivery]
			,[PerformerID]
			,[InvoiceLineNumber]
			,[ExtendedAmount]
			,[QuantityDelivered]
			,[ActualPercentAfterDelivery]
			,[InvoiceType]
			,[SalesPersonID])
	SELECT 	
			[CustomerNumber] = E.strEntityNo
			,[SiteNumber] = RIGHT('0000'+CAST(D.intSiteNumber AS VARCHAR(4)),4)
			,[MeterReading] = A.dblNewMeterReading
			,[InvoiceNumber] = B.strInvoiceNumber
			,[BulkPlantNumber] = F.strLocationName
			,[InvoiceDate] =   CAST(YEAR(B.dtmDate) AS NVARCHAR(4)) + RIGHT('00'+ CAST(MONTH(B.dtmDate) AS NVARCHAR(2)),2) + RIGHT('00'+ CAST(DAY(B.dtmDate) AS NVARCHAR(2)),2)
			,[ItemNumber] = C.strItemNo
			,[ItemAvailableForTM] = (CASE WHEN C.strType = 'Service' THEN 'S' ELSE '' END)
			,[ReversePreviousDelivery] = ''
			,[PerformerID] = H.strSalespersonId
			,[InvoiceLineNumber] = A.intTMLineNumber
			,[ExtendedAmount] = ISNULL(A.dblTotal,0) + ISNULL(A.dblTotalTax,0)
			,[QuantityDelivered] = A.dblQtyShipped
			,[ActualPercentAfterDelivery] = A.dblPercentFull
			,[InvoiceType] = (CASE WHEN B.strTransactionType = 'Credit Memo' THEN 'C' ELSE 'I' END)
			,[SalesPersonID] = G.strSalespersonId
	FROM #tmpCOBOLInvoiceDetail A
	INNER JOIN tblARInvoice B
		ON A.intInvoiceId = B.intInvoiceId
	INNER JOIN tblICItem C
		ON A.intItemId = C.intItemId
	INNER JOIN tblTMSite D
		ON A.intSiteId = D.intSiteID
	INNER JOIN tblEMEntity E
		ON B.intEntityCustomerId = E.intEntityId
	INNER JOIN tblSMCompanyLocation F
		ON B.intCompanyLocationId = F.intCompanyLocationId
	LEFT JOIN vyuEMSalesperson G
		ON B.intEntitySalespersonId = G.[intEntityId]
	LEFT JOIN vyuEMSalesperson H
		ON A.intPerformerId = H.[intEntityId]
	
END
GO