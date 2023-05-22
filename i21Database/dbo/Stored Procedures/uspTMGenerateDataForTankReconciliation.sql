CREATE PROCEDURE [dbo].[uspTMGenerateDataForTankReconciliation]
	@strReportName							NVARCHAR(1000),
	@strConsumptionSiteFilter				NVARCHAR(1000),
	@strStoresIncluded						NVARCHAR(1000),
	@strStoresIncludedDescription			NVARCHAR(1000),
	@strConsumptionSitesIncluded			NVARCHAR(1000),
	@strConsumptionSitesIncludedDescription	NVARCHAR(1000),
	@dtmDateFrom							DATETIME,
	@dtmDateTo								DATETIME,
	@intTankReconciliationId				INT	OUTPUT
AS
BEGIN
	INSERT INTO tblTMTankReconciliation (strReportName, dtmReportProducedOn, strConsumptionSiteFilter, strStoresIncluded,
											strStoresIncludedDescription, strConsumptionSitesIncluded, strConsumptionSitesIncludedDescription, dtmDateFrom, dtmDateTo)
	VALUES (@strReportName, GETDATE(), @strConsumptionSiteFilter, @strStoresIncluded, 
											@strStoresIncludedDescription, @strConsumptionSitesIncluded, @strConsumptionSitesIncludedDescription, @dtmDateFrom, @dtmDateTo)

	SET @intTankReconciliationId = SCOPE_IDENTITY()

	WHILE @dtmDateFrom <= @dtmDateTo
	BEGIN
		IF @strReportName = 'Regulatory'
		BEGIN
			INSERT INTO tblTMTankReconciliationDetail (	intTankReconciliationId, 
														strTankNumber, 
														strFuelGradeDescription, 
														dtmDate, 
														dblStartVolume, 
														dblDeliveries, 
														dblSales, 
														dblEndVolume, 
														ysnIncluded)
			SELECT		@intTankReconciliationId,
						a.strDescription,
						c.strDescription,
						@dtmDateFrom,
						CASE
							WHEN dbo.fnTMIsConsumptionSiteAtAStore(a.intSiteID) = 1
							THEN dbo.fnTMGetFuelTankReadingStartOrEndVolume(@dtmDateFrom, a.intSiteID, 1, 1)
							ELSE dbo.fnTMGetFuelTankReadingStartOrEndVolume(@dtmDateFrom, a.intSiteID, 0, 1)
							END AS dtmStartVolume,
						dbo.fnTMGetDeliveries(@dtmDateFrom, a.intSiteID, 0) as dblDeliveries,
						CASE
							WHEN dbo.fnTMIsConsumptionSiteAtAStore(a.intSiteID) = 1
							THEN dbo.fnTMGetSalesFromStoreEOD(@dtmDateFrom, a.intSiteID)
							ELSE dbo.fnTMGetSalesFromIC(@dtmDateFrom, a.intSiteID)
							END as dblSales,
						CASE
							WHEN dbo.fnTMIsConsumptionSiteAtAStore(a.intSiteID) = 1
							THEN dbo.fnTMGetFuelTankReadingStartOrEndVolume(@dtmDateFrom, a.intSiteID, 1, 0)
							ELSE dbo.fnTMGetFuelTankReadingStartOrEndVolume(@dtmDateFrom, a.intSiteID, 0, 0)
							END AS dtmEndVolume,
						1 as ysnIncluded
			FROM		tblTMSite a
			LEFT JOIN	tblTMSiteDevice b
			ON			a.intSiteID = b.intSiteID
			LEFT JOIN	tblICItem c
			ON			a.intProduct = c.intItemId
			WHERE		a.intSiteID IN (
										SELECT		intSiteID 
										FROM		tblTMSite
										WHERE		@strConsumptionSiteFilter = 'All Sites' AND
													ysnCompanySite = 1
										
										UNION
										
										SELECT		* from dbo.fnSplitString(REPLACE(@strConsumptionSitesIncluded, ' ', ''),',')
										WHERE		@strConsumptionSiteFilter = 'Selected Sites'

										UNION
										
										SELECT		c.intSiteID
										FROM		tblSTStore a
										INNER JOIN	tblSTStoreFuelTanks b
										ON			a.intStoreId = b.intStoreId
										INNER JOIN	tblTMSite c
										ON			a.intCompanyLocationId = c.intLocationId AND c.ysnCompanySite = 1
										INNER JOIN	tblTMSiteDevice d
										ON			d.intSiteID = c.intSiteID AND
													b.intDeviceId = d.intDeviceId
										WHERE		a.intStoreId IN (SELECT * from dbo.fnSplitString(REPLACE(@strStoresIncluded, ' ', ''),',')) AND
													@strConsumptionSiteFilter = 'Stores'
										)
		END
		ELSE IF @strReportName = 'Audited'
		BEGIN
			INSERT INTO tblTMTankReconciliationDetail (	intTankReconciliationId, 
													strTankNumber, 
													strFuelGradeDescription, 
													dtmDate, 
													dblStartVolume, 
													dblDeliveries, 
													dblSales, 
													dblEndVolume, 
													ysnIncluded)
			SELECT		@intTankReconciliationId,
						a.strDescription,
						c.strDescription,
						@dtmDateFrom,
						ISNULL(dbo.fnICGetItemRunningStockQty(a.intProduct, a.intLocationId, null, null, null, null, null, DATEADD(MINUTE, -1, @dtmDateFrom), 1),0) AS dtmStartVolume,
						dbo.fnTMGetDeliveries(@dtmDateFrom, a.intSiteID, 0) as dblDeliveries,
						CASE
							WHEN dbo.fnTMIsConsumptionSiteAtAStore(a.intSiteID) = 1
							THEN dbo.fnTMGetSalesFromStoreEOD(@dtmDateFrom, a.intSiteID)
							ELSE dbo.fnTMGetSalesFromIC(@dtmDateFrom, a.intSiteID)
							END as dblSales,
						CASE
							WHEN dbo.fnTMIsConsumptionSiteAtAStore(a.intSiteID) = 1
							THEN dbo.fnTMGetFuelTankReadingStartOrEndVolume(@dtmDateFrom, a.intSiteID, 1, 0)
							ELSE dbo.fnTMGetFuelTankReadingStartOrEndVolume(@dtmDateFrom, a.intSiteID, 0, 0)
							END AS dtmEndVolume,
						1 as ysnIncluded
			FROM		tblTMSite a
			LEFT JOIN	tblTMSiteDevice b
			ON			a.intSiteID = b.intSiteID
			LEFT JOIN	tblICItem c
			ON			a.intProduct = c.intItemId
			WHERE		a.intSiteID IN (
										SELECT		intSiteID 
										FROM		tblTMSite
										WHERE		@strConsumptionSiteFilter = 'All Sites' AND
													ysnCompanySite = 1
										
										UNION
										
										SELECT		* from dbo.fnSplitString(REPLACE(@strConsumptionSitesIncluded, ' ', ''),',')
										WHERE		@strConsumptionSiteFilter = 'Selected Sites'

										UNION
										
										SELECT		c.intSiteID
										FROM		tblSTStore a
										INNER JOIN	tblSTStoreFuelTanks b
										ON			a.intStoreId = b.intStoreId
										INNER JOIN	tblTMSite c
										ON			a.intCompanyLocationId = c.intLocationId AND c.ysnCompanySite = 1
										INNER JOIN	tblTMSiteDevice d
										ON			d.intSiteID = c.intSiteID AND
													b.intDeviceId = d.intDeviceId
										WHERE		a.intStoreId IN (SELECT * from dbo.fnSplitString(REPLACE(@strStoresIncluded, ' ', ''),',')) AND
													@strConsumptionSiteFilter = 'Stores'
										)
		END
		ELSE
		BEGIN
			INSERT INTO tblTMTankReconciliationDetail (	intTankReconciliationId, 
													strTankNumber, 
													strFuelGradeDescription, 
													dtmDate, 
													dblStartVolume, 
													dblDeliveries, 
													dblSales, 
													dblEndVolume, 
													ysnIncluded)
			SELECT		@intTankReconciliationId,
						a.strDescription,
						c.strDescription,
						@dtmDateFrom,
						ISNULL(dbo.fnICGetItemRunningStockQty(a.intProduct, a.intLocationId, null, null, null, null, null, DATEADD(MINUTE, -1, @dtmDateFrom), 1), 0) AS dtmStartVolume,
						dbo.fnTMGetDeliveries(@dtmDateFrom, a.intSiteID, 0) as dblDeliveries,
						CASE
							WHEN dbo.fnTMIsConsumptionSiteAtAStore(a.intSiteID) = 1
							THEN dbo.fnTMGetSalesFromStoreEOD(@dtmDateFrom, a.intSiteID)
							ELSE dbo.fnTMGetSalesFromIC(@dtmDateFrom, a.intSiteID)
							END as dblSales,
						CASE
							WHEN dbo.fnTMIsConsumptionSiteAtAStore(a.intSiteID) = 1
							THEN dbo.fnTMGetFuelTankReadingStartOrEndVolume(@dtmDateFrom, a.intSiteID, 1, 0)
							ELSE dbo.fnTMGetFuelTankReadingStartOrEndVolume(@dtmDateFrom, a.intSiteID, 0, 0)
							END AS dtmEndVolume,
						1 as ysnIncluded
			FROM		tblTMSite a
			LEFT JOIN	tblTMSiteDevice b
			ON			a.intSiteID = b.intSiteID
			LEFT JOIN	tblICItem c
			ON			a.intProduct = c.intItemId
			WHERE		a.intSiteID IN (
										SELECT		intSiteID 
										FROM		tblTMSite
										WHERE		@strConsumptionSiteFilter = 'All Sites' AND
													ysnCompanySite = 1
										
										UNION
										
										SELECT		* from dbo.fnSplitString(REPLACE(@strConsumptionSitesIncluded, ' ', ''),',')
										WHERE		@strConsumptionSiteFilter = 'Selected Sites'

										UNION
										
										SELECT		c.intSiteID
										FROM		tblSTStore a
										INNER JOIN	tblSTStoreFuelTanks b
										ON			a.intStoreId = b.intStoreId
										INNER JOIN	tblTMSite c
										ON			a.intCompanyLocationId = c.intLocationId AND c.ysnCompanySite = 1
										INNER JOIN	tblTMSiteDevice d
										ON			d.intSiteID = c.intSiteID AND
													b.intDeviceId = d.intDeviceId
										WHERE		a.intStoreId IN (SELECT * from dbo.fnSplitString(REPLACE(@strStoresIncluded, ' ', ''),',')) AND
													@strConsumptionSiteFilter = 'Stores'
										)
		END

		SET @dtmDateFrom = DATEADD(DAY,1,@dtmDateFrom)
	END
END