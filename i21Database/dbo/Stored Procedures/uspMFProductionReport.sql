CREATE PROCEDURE [dbo].[uspMFProductionReport] 
(
	@intDay				INT = 1
  , @strType			NVARCHAR = NULL /* eg. Production, RMUsageDetail, RMUsagePerLot, PMUsageDetail, . Sending NULL Value will return all. */
  , @strLocation		NVARCHAR = NULL /* Location Name. Sending NULL Value will return all. */
  , @strExcludeItem		NVARCHAR = NULL /* Item No (Product / WSI Item)*/
  , @strExcludeCategory	NVARCHAR = NULL /* Category (Product Category/ WSI Item Category)*/
) 
AS
/****************************************************************
	Title: Production Report
	Description: Production Report that allows the user to filter and choose the type of report.
	JIRA: MFG-5049
	Created By: Jonathan Valenzuela
	Date: 05/23/2023
*****************************************************************/
DECLARE @dtmProductionDate DATETIME

DECLARE @tblLocation TABLE 
(
	strLocationName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
);

DECLARE @tblItem TABLE 
(
	strItemNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
);

DECLARE @tblCategory TABLE 
(
	strCategory NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
);


/* Set Parameter into Table. */

/* Location. */
INSERT INTO @tblLocation
SELECT Item
FROM dbo.fnSplitStringWithTrim(@strLocation, ',');

/* Excluded Item. */
INSERT INTO @tblItem
SELECT Item
FROM dbo.fnSplitStringWithTrim(@strExcludeItem, ',');

/* Excluded Category. */
INSERT INTO @tblCategory
SELECT Item
FROM dbo.fnSplitStringWithTrim(@strExcludeCategory, ',');

IF @dtmProductionDate IS NULL
	BEGIN
		SELECT @dtmProductionDate = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101)) - @intDay
	END
ELSE
	BEGIN
		SELECT @dtmProductionDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmProductionDate, 101))
	END

/* Production */
IF (@strType = 'Production' OR @strType = NULL)
	BEGIN
		SELECT [Production Date]
		     , [Item]
		     , [Description]
		     , [Work Order #]
		     , [Job #]
		     , [Production Lot]
		     , [Pallet No]
		     , [Quantity]
		     , [Quantity UOM]
		     , [Weight]
		     , [Weight UOM]
		     , [Line]			 
		FROM vyuMFGetProduction
			  /* @strLocation = NULL then Return All. */
		WHERE (@strLocation IS NULL OR strLocationName IN (SELECT strLocationName FROM @tblLocation))
			  /* @strExcludeItem = NULL then Return All item. */
		  AND (@strExcludeItem IS NULL OR [Item] NOT IN (SELECT strItemNo FROM @tblItem))
			  /* @strExcludeCategory = NULL then Return All Category. */
		  AND (@strExcludeCategory IS NULL OR strCategoryCode NOT IN (SELECT strCategory FROM @tblCategory))
			  /* Production Date */
		  AND 
		  (
				/* Ignore Production Date fiter when @intDay is -1. */
				(@intDay = -1 AND 1 = 1)
				/* Apply Production Date fiter when @intDay is 1. */
		    OR  (@intDay = 1 AND [Production Date] = @dtmProductionDate)
		  )
		ORDER BY dtmPlannedDate
			   , intWorkOrderId

	END

/* RMUsageDetail */
IF (@strType = 'RMUsageDetail' OR @strType = NULL)
	BEGIN
		SELECT [Dump Date]
			 , [Product]
			 , [Product Description]
			 , [Production Lot]
			 , Line
			 , [Work Order #]
			 , [Job #]
			 , [WSI Item]
			 , [WSI Item Description]
			 , dblRequiredQty
			 , [Pallet Id]
			 , [Lot #]
			 , [Quantity]
			 , [Quantity UOM]
			 , [Weight]
			 , [Weight UOM]
		FROM vyuMFGetRMUsage
			  /* @strLocation = NULL then Return All. */
		WHERE (@strLocation IS NULL OR strLocationName IN (SELECT strLocationName FROM @tblLocation))
			  /* @strExcludeItem = NULL then Return All item. */
		  AND (@strExcludeItem IS NULL OR [WSI Item] NOT IN (SELECT strItemNo FROM @tblItem))
			  /* @strExcludeCategory = NULL then Return All Category. */
		  AND (@strExcludeCategory IS NULL OR strCategoryCode NOT IN (SELECT strCategory FROM @tblCategory))
			  /* Dump Date */
		  AND 
		  (
				/* Ignore Dump Date fiter when @intDay is -1. */
				(@intDay = -1 AND 1 = 1)
				/* Apply Dump Date fiter when @intDay is 1. */
		    OR  (@intDay = 1 AND [Dump Date] = @dtmProductionDate)
		  )
		ORDER BY dtmPlannedDate
			   , intWorkOrderId
	END

/* RMUsagePerLot */
IF (@strType = 'RMUsagePerLot' OR @strType = NULL)
	BEGIN
		SELECT [Dump Date]
			 , [Product]
			 , [Product Description]
			 , [Production Lot]
			 , Line
			 , [Work Order #]
			 , [Job #]
			 , [WSI Item]
			 , [WSI Item Description]
			 , [Lot #]
			 , Quantity
			 , [Quantity UOM]
			 , [Weight]
			 , [Weight UOM]
		FROM vyuMFGetRMUsageByLot
			  /* @strLocation = NULL then Return All. */
		WHERE (@strLocation IS NULL OR strLocationName IN (SELECT strLocationName FROM @tblLocation))
			  /* @strExcludeItem = NULL then Return All item. */
		  AND (@strExcludeItem IS NULL OR [WSI Item] NOT IN (SELECT strItemNo FROM @tblItem))
			  /* @strExcludeCategory = NULL then Return All Category. */
		  AND (@strExcludeCategory IS NULL OR strCategoryCode NOT IN (SELECT strCategory FROM @tblCategory))
		      /* Dump Date */
		  AND 
		  (
				/* Ignore Dump Date fiter when @intDay is -1. */
				(@intDay = -1 AND 1 = 1)
				/* Apply Dump Date fiter when @intDay is 1. */
		    OR  (@intDay = 1 AND [Dump Date] = @dtmProductionDate)
		  )
		ORDER BY dtmPlannedDate
			   , intWorkOrderId

	END

/* PMUsageDetail */
IF (@strType = 'PMUsageDetail' OR @strType = NULL)
	BEGIN
		SELECT [Dump Date]
			 , [Product]
			 , [Product Description]
			 , [Production Lot]
			 , Line
			 , [Work Order #]
			 , [Job #]
			 , [WSI Item]
			 , [WSI Item Description]
			 , dblRequiredQty
			 , [Total Consumed Quantity]
			 , [Used in Packaging]
			 , [UOM]
			 , [Damaged]
		FROM vyuMFGetPMUsage
			  /* @strLocation = NULL then Return All. */
		WHERE (@strLocation IS NULL OR strLocationName IN (SELECT strLocationName FROM @tblLocation))
			  /* @strExcludeItem = NULL then Return All item. */
		  AND (@strExcludeItem IS NULL OR [WSI Item] NOT IN (SELECT strItemNo FROM @tblItem))
		      /* @strExcludeCategory = NULL then Return All Category. */
		  AND (@strExcludeCategory IS NULL OR strCategoryCode NOT IN (SELECT strCategory FROM @tblCategory))
		      /* Dump Date */
		  AND 
		  (
				/* Ignore Dump Date fiter when @intDay is -1. */
				(@intDay = -1 AND 1 = 1)
				/* Apply Dump Date fiter when @intDay is 1. */
		    OR  (@intDay = 1 AND [Dump Date] = @dtmProductionDate)
		  )
		ORDER BY dtmPlannedDate
			   , intWorkOrderId

	END

/* OverUnderWeight */
IF (@strType = 'OverUnderWeight' OR @strType = NULL)
	BEGIN
		SELECT [Production Date]
			 , Item
			 , [Description]
			 , [Work Order #]
			 , [Job #]
			 , [Production Lot]
			 , [Good produced Pouches]
			 , [Total Pouches passed through counter]
			 , [Underweight Pouches]
			 , [Overweight Pouches]
			 , [Total sweeps (lb)]
		FROM vyuMFGetOverAndUnderWeight
			   /* @strLocation = NULL then Return All. */
		WHERE (@strLocation IS NULL OR strLocationName IN (SELECT strLocationName FROM @tblLocation))
			   /* @strExcludeItem = NULL then Return All item. */
		  AND (@strExcludeItem IS NULL OR [Item] NOT IN (SELECT strItemNo FROM @tblItem))
			   /* @strExcludeCategory = NULL then Return All Category. */
		  AND (@strExcludeCategory IS NULL OR strCategoryCode NOT IN (SELECT strCategory FROM @tblCategory))
		      /* Production Date */
		  AND 
		  (
				/* Ignore Production Date fiter when @intDay is -1. */
				(@intDay = -1 AND 1 = 1)
				/* Apply Production Date fiter when @intDay is 1. */
		    OR  (@intDay = 1 AND [Production Date] = @dtmProductionDate)
		  )
		ORDER BY dtmPlannedDate
			   , intWorkOrderId

	END