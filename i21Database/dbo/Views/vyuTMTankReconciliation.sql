CREATE VIEW [dbo].[vyuTMTankReconciliation]  
AS  
SELECT		b.intTankReconciliationDetailId, 
			b.intTankReconciliationId, 
			b.strTankNumber, 
			b.strFuelGradeDescription, 
			b.dtmDate, 
			b.dblStartVolume, 
			b.dblDeliveries, 
			b.dblSales, 
			b.dblCalculatedInventory, 
			b.dblEndVolume, 
			b.dblBookVariance, 
			b.dblBookVariancePercentage,
			CASE	
					WHEN a.strReportName = 'Audited'
					THEN 'Audited Tank Reconciliation Report'
					WHEN a.strReportName = 'Unaudited'
					THEN 'Unaudited Tank Reconciliation Report'
					WHEN a.strReportName = 'Regulatory'
					THEN 'Fuel Tank Reconciliation Report - Regulatory'
					ELSE ''
					END AS strReportName,
				a.strStoresIncludedDescription,
				a.strConsumptionSitesIncludedDescription,
				CONVERT(VARCHAR(10),a.dtmDateFrom,101) + ' - ' + CONVERT(VARCHAR(10),a.dtmDateTo,101) as strDateRange,
			a.dtmReportProducedOn,
			CASE
				WHEN a.strConsumptionSiteFilter = 'All Sites'
				THEN 'Consumption Site Filter:'
				WHEN a.strConsumptionSiteFilter = 'Selected Sites'
				THEN 'Consumption Sites Included:'
				WHEN a.strConsumptionSiteFilter = 'Stores'
				THEN 'Stores Included:'
				ELSE ''
				END AS strConsumptionSiteFilterLabel,
			CASE
				WHEN a.strConsumptionSiteFilter = 'All Sites'
				THEN 'All Sites'
				WHEN a.strConsumptionSiteFilter = 'Selected Sites'
				THEN a.strConsumptionSitesIncludedDescription
				WHEN a.strConsumptionSiteFilter = 'Stores'
				THEN a.strStoresIncludedDescription
				ELSE ''
				END AS strConsumptionSiteFilterValue,
			CASE
				WHEN a.strReportName = 'Regulatory'
				THEN 'Start Volume'
				ELSE '*Start Volume'
				END AS strStartVolumeLabel,
			CASE
				WHEN a.strReportName = 'Regulatory'
				THEN ''
				ELSE '* = For Audited\Unaudited Reports, all manual adjustments that increase inventory are reflected in the Start Volume of the following day.'
				END AS strFooter
FROM		tblTMTankReconciliationDetail b
INNER JOIN	tblTMTankReconciliation a
ON			a.intTankReconciliationId = b.intTankReconciliationId
WHERE		ysnIncluded = 1