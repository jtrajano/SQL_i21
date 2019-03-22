CREATE PROCEDURE [dbo].[uspAPImportVendorPricingFromCSV]
	@userId INT,
	@csvFile NVARCHAR(500),
	@totalImport INT OUTPUT
AS
BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @sql NVARCHAR(MAX);

IF @transCount = 0 BEGIN TRANSACTION

	IF OBJECT_ID('tempdb..#tmpVendorPricing') IS NOT NULL DROP TABLE #tmpVendorPricing

	CREATE TABLE #tmpVendorPricing(
		[strVendorId] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
		,[strLocationName] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
		,[strItemNo] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
		,[strDescription] NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL
		,[strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[strPrice] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,[strCurrency] NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL
		,[strBeginDate] CHAR(12) COLLATE Latin1_General_CI_AS NULL
		,[strEndDate] CHAR(12) COLLATE Latin1_General_CI_AS NULL
	)

	BEGIN TRY

		SET @sql = 'BULK INSERT #tmpVendorPricing
		FROM ''' + @csvFile + 
		'''WITH
		(
		FIELDTERMINATOR = '','',
		FIRSTROW = 2,
		ROWTERMINATOR = ''0x0a''
		)'

		EXEC(@sql);

	END TRY
	BEGIN CATCH
		RAISERROR('Invalid csv format.', 16, 1);
	END CATCH

	INSERT INTO tblAPVendorPricing(
		[intEntityVendorId]
		,[intEntityLocationId]
		,[intItemId]
		,[intItemUOMId]
		,[dtmBeginDate]
		,[dtmEndDate]
		,[dblUnit]
		,[intCurrencyId]
	)
	SELECT
		vendor.intEntityId
		,loc.intEntityLocationId
		,itemData.intItemId
		,itemUOM.intUnitMeasureId
		,CONVERT(DATETIME2, pricing.strBeginDate, 101)
		,CONVERT(DATETIME2, dbo.fnTrimX(pricing.strEndDate), 101)
		-- ,CONVERT(DATETIME, pricing.strBeginDate, 101)
		-- ,CONVERT(DATETIME, pricing.strEndDate, 101)
		,CAST(pricing.strPrice AS DECIMAL(38,30))
		,cur.intCurrencyID
	FROM #tmpVendorPricing pricing
	INNER JOIN tblAPVendor vendor ON pricing.strVendorId = vendor.strVendorId
	INNER JOIN tblEMEntityLocation loc ON vendor.intEntityId = loc.intEntityId AND pricing.strLocationName = loc.strLocationName
	INNER JOIN (
		SELECT 
			item.intItemId
			,item.strItemNo
			,itemVendorXRef.strVendorProduct
			,itemVendorXRef.intVendorId
		FROM tblICItem item 
		LEFT JOIN tblICItemVendorXref itemVendorXRef ON item.intItemId = itemVendorXRef.intItemId
	) itemData
		ON pricing.strItemNo = itemData.strItemNo OR (pricing.strItemNo = itemData.strVendorProduct AND itemData.intVendorId = vendor.intEntityId)
	INNER JOIN (tblICItemUOM itemUOM INNER JOIN 
	tblICUnitMeasure unitMeasure ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId)
		ON itemData.intItemId = itemUOM.intItemId AND (pricing.strUnitMeasure = unitMeasure.strUnitMeasure OR pricing.strUnitMeasure = unitMeasure.strSymbol)
	INNER JOIN tblSMCurrency cur ON pricing.strCurrency = cur.strCurrency

	SET @totalImport = @@ROWCOUNT;

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END