CREATE PROCEDURE [dbo].[uspSTReportSalesTax]
	@strReportName NVARCHAR(100)
	, @strStoreGroupIds NVARCHAR(200) = NULL
	, @intGroupById INT = NULL
    , @dtmFrom DATETIME = NULL
    , @dtmTo DATETIME = NULL
    , @strStoreIds NVARCHAR(200) = NULL
    , @ysnIncludeZeroValues BIT = 0
	, @ysnSummary BIT = 0


AS

BEGIN
	DECLARE @tmpDetails AS TABLE(dtmCheckoutDate DATETIME
		, intStoreNo NVARCHAR(100)
		, intStoreId INT
		, strStoreName NVARCHAR(100)
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, strDescription NVARCHAR(250)
		, dblPrice NUMERIC(18, 6)
		, dblQuantity NUMERIC(18, 6)
		, dblNetSales NUMERIC(18, 6)
		, dblTax NUMERIC(18, 6)
		, dblAmount NUMERIC(18, 6)
		, dblTotal NUMERIC(18, 6))

	DECLARE @tmpStoreGroup AS TABLE (intStoreId INT, strStoreGroupName NVARCHAR(100))
	DECLARE @tmpStores AS TABLE (Item NVARCHAR(100))

	DECLARE @MainStore AS TABLE (dtmCheckoutDate DATETIME
		, intStoreNo NVARCHAR(100)
		, intStoreId INT
		, strStoreName NVARCHAR(100)
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, strDescription NVARCHAR(250)
		, dblPrice NUMERIC(18, 6)
		, dblQuantity NUMERIC(18, 6)
		, dblTax NUMERIC(18, 6)
		, dblAmount NUMERIC(18, 6))
		
	DECLARE @MainStoreGroup AS TABLE (strStoreGroupName NVARCHAR(100)
		, dtmCheckoutDate DATETIME
		, intStoreNo NVARCHAR(100)
		, intStoreId INT
		, strStoreName NVARCHAR(100)
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, strDescription NVARCHAR(250)
		, dblPrice NUMERIC(18, 6)
		, dblQuantity NUMERIC(18, 6)
		, dblTax NUMERIC(18, 6)
		, dblAmount NUMERIC(18, 6))
		
	DECLARE @MerchandiseDetails AS TABLE (intStoreId INT
		, intStoreNo NVARCHAR(100)
		, strStoreName NVARCHAR(100)
		, intCategoryId INT
		, strDescription NVARCHAR(250)
		, dblTotalSalesAmountRaw NUMERIC(18, 6)
		, intItemsSold INT
		, ysnUseTaxFlag2 BIT
		, dblTotal NUMERIC(18, 6))
		
	INSERT INTO @tmpStores
	SELECT DISTINCT Item FROM dbo.fnSplitString(@strStoreIds, ',')

	INSERT INTO @tmpStoreGroup
	SELECT DISTINCT ST2.intStoreId
		, ST1.strStoreGroupName
	FROM tblSTStoreGroup ST1
	INNER JOIN tblSTStoreGroupDetail ST2 ON ST1.intStoreGroupId = ST2.intStoreGroupId
	WHERE ST1.intStoreGroupId IN (SELECT Item FROM dbo.fnSplitString(@strStoreGroupIds, ','))
	
	IF (@strReportName IN ('Tax Fuel Sales', 'Fuel Tax Total'))
	BEGIN	
		INSERT INTO @MainStore
		SELECT dtmCheckoutDate = CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME)
			, T4.intStoreNo
			, T0.intStoreId
			, strStoreName = T4.strDescription
			, T3.intItemId
			, T3.strItemNo
			, T3.strDescription
			, ROUND(T1.dblAmount / CASE WHEN T1.dblQuantity = 0 THEN 1 ELSE T1.dblQuantity END, 6) AS dblPrice
			, T1.dblQuantity
			, T5.dblTax
			, T1.dblAmount
		FROM tblSTCheckoutHeader T0
		INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
		INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
		INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
		INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
		INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
		WHERE ISNULL(T0.intInvoiceId, 0) <> 0 AND T5.ysnTaxExempt = 0
		GROUP BY CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME)
			, T4.intStoreNo
			, T0.intStoreId
			, T4.strDescription
			, T3.intItemId
			, T3.strItemNo
			, T3.strDescription
			, ROUND(T1.dblAmount / CASE WHEN T1.dblQuantity = 0 THEN 1 ELSE T1.dblQuantity END, 6)
			, T1.dblQuantity
			, T5.dblTax
			, T1.dblAmount

		INSERT INTO @MainStoreGroup
		SELECT T6.strStoreGroupName
			, dtmCheckoutDate = CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME)
			, T4.intStoreNo
			, T0.intStoreId
			, T4.strDescription AS strStoreName
			, T3.intItemId
			, T3.strItemNo
			, T3.strDescription
			, ROUND(T1.dblAmount / CASE WHEN T1.dblQuantity = 0 THEN 1 ELSE T1.dblQuantity END, 6) AS dblPrice
			, T1.dblQuantity
			, T5.dblTax
			, T1.dblAmount
		FROM tblSTCheckoutHeader T0
		INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
		INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
		INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
		INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
		INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
		LEFT JOIN @tmpStoreGroup T6 ON T0.intStoreId = T6.intStoreId
		WHERE ISNULL(T0.intInvoiceId,0) <> 0 AND T5.ysnTaxExempt = 0
		GROUP BY T6.strStoreGroupName
			, CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME)
			, T4.intStoreNo
			, T0.intStoreId
			, T4.strDescription
			, T3.intItemId
			, T3.strItemNo
			, T3.strDescription
			, ROUND(T1.dblAmount / CASE WHEN T1.dblQuantity = 0 THEN 1 ELSE T1.dblQuantity END, 6)
			, T1.dblQuantity
			, T5.dblTax
			, T1.dblAmount
	END

	

	/************ Tax Fuel Sales *************/
	IF (@strReportName = 'Tax Fuel Sales')
	BEGIN
		IF ISNULL(@strStoreGroupIds, '') = ''
		BEGIN
			IF @intGroupById = 0
			BEGIN
				INSERT INTO @tmpDetails
				SELECT dtmCheckoutDate = CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
					, intStoreNo = 0
					, intStoreId = 0
					, strStoreName = ''
					, intItemId
					, strItemNo
					, strDescription
					, dblPrice = AVG(MT.dblPrice)
					, dblQuantity = AVG (MT.dblQuantity)
					, dblNetSales = (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax)
					, dblTax = SUM (MT.dblTax)
					, dblAmount = AVG(MT.dblPrice) * AVG (MT.dblQuantity)
					, dblTotal = SUM(MT.dblAmount)
				FROM @MainStore MT
				WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
					, intItemId
					, strItemNo
					, strDescription
			END
			ELSE
			BEGIN
				INSERT INTO @tmpDetails
				SELECT dtmCheckoutDate = CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
					, intStoreNo
					, intStoreId
					, strStoreName
					, intItemId
					, strItemNo
					, strDescription
					, dblPrice = AVG(MT.dblPrice)
					, dblQuantity = AVG (MT.dblQuantity)
					, dblNetSales = (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax)
					, dblTax = SUM (MT.dblTax)
					, dblAmount = AVG(MT.dblPrice) * AVG (MT.dblQuantity)
					, dblTotal = SUM(MT.dblAmount)
				FROM @MainStore MT
				WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
					, intStoreNo
					, intStoreId
					, strStoreName
					, intItemId
					, strItemNo
					, strDescription
			END
		END
		ELSE
		BEGIN
			IF @intGroupById = 0
			BEGIN
				INSERT INTO @tmpDetails
				SELECT dtmCheckoutDate = CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
					, intStoreNo = 0
					, intStoreId = 0
					, strStoreName = ''
					, intItemId
					, strItemNo
					, strDescription
					, dblPrice = AVG(MT.dblPrice)
					, dblQuantity = SUM (MT.dblQuantity)
					, dblNetSales = (AVG(MT.dblPrice) * SUM(MT.dblQuantity)) - SUM(MT.dblTax)
					, dblTax = SUM (MT.dblTax)
					, dblAmount = AVG(MT.dblPrice) * SUM (MT.dblQuantity)
					, dblTotal = SUM(MT.dblAmount)
				FROM @MainStoreGroup MT
				WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
					, intItemId
					, strItemNo
					, strDescription
			END
			ELSE
			BEGIN
				INSERT INTO @tmpDetails
				SELECT dtmCheckoutDate = CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
					, intStoreNo = strStoreGroupName + ' - ' + CAST(intStoreNo AS NVARCHAR(10))
					, intStoreId
					, strStoreName
					, intItemId
					, strItemNo
					, strDescription
					, dblPrice = AVG(MT.dblPrice)
					, dblQuantity = SUM (MT.dblQuantity)
					, dblNetSales = (AVG(MT.dblPrice) * SUM(MT.dblQuantity)) - SUM(MT.dblTax)
					, dblTax = SUM (MT.dblTax)
					, dblAmount = AVG(MT.dblPrice) * SUM (MT.dblQuantity)
					, dblTotal = SUM(MT.dblAmount)
				FROM @MainStoreGroup MT
				WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
				AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
				AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
					, strStoreGroupName
					, intStoreNo
					, intStoreId
					, strStoreName
					, intItemId
					, strItemNo
					, strDescription
			END
		END

		IF @ysnIncludeZeroValues = 1
		BEGIN
			SELECT dtmCheckoutDate
				, intStoreNo
				, intStoreId
				, strStoreName
				, intItemId
				, strItemNo
				, strDescription
				, dblPrice
				, dblQuantity
				, dblNetSales
				, dblTax
				, dblAmount
			FROM @tmpDetails
		END
		ELSE
		BEGIN
			SELECT dtmCheckoutDate
				, intStoreNo
				, intStoreId
				, strStoreName
				, intItemId
				, strItemNo
				, strDescription
				, dblPrice
				, dblQuantity
				, dblNetSales
				, dblTax
				, dblAmount
			FROM @tmpDetails
			WHERE dblTotal <> 0
		END
	END
	/********** Tax Fuel Sales End ***********/

	
	/************ Fuel Tax Total *************/
	IF (@strReportName = 'Fuel Tax Total')
	BEGIN
		IF ISNULL(@strStoreGroupIds, '') = ''
		BEGIN
			INSERT INTO @tmpDetails (dblQuantity, dblNetSales, dblTax, dblAmount)
			SELECT SUM(dblQuantity), SUM(dblNetSales), SUM(dblTax), SUM(dblAmount) 
			FROM (
				SELECT MT.intItemId
					, MT.intStoreId
					, AVG (MT.dblQuantity) AS dblQuantity
					, (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax) AS dblNetSales
					, SUM (MT.dblTax) AS dblTax
					, AVG(MT.dblPrice) * AVG (MT.dblQuantity) AS dblAmount
				FROM @MainStore MT
				WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY MT.intItemId, MT.intStoreId
			) tmp
		END
		ELSE
		BEGIN
			INSERT INTO @tmpDetails (dblQuantity, dblNetSales, dblTax, dblAmount)
			SELECT SUM(dblQuantity), SUM(dblNetSales), SUM(dblTax), SUM(dblAmount) 
			FROM (
				SELECT MT.intItemId
					, MT.intStoreId
					, AVG (MT.dblQuantity) AS dblQuantity
					, (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax) AS dblNetSales
					, SUM (MT.dblTax) AS dblTax
					, AVG(MT.dblPrice) * AVG (MT.dblQuantity) AS dblAmount
				FROM @MainStoreGroup MT
				WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY MT.intItemId, MT.intStoreId
			) tmp
		END
		SELECT dblQuantity, dblNetSales, dblTax, dblAmount FROM @tmpDetails
	END
	/********** Fuel Tax Total End ***********/

	
	/************ Merchandise Sales *************/
	IF (@strReportName = 'Merchandise Sales' OR @strReportName = 'Merchandise Sales Total')
	BEGIN
		IF ISNULL(@strStoreGroupIds, '') = ''
		BEGIN
			IF @intGroupById = 0
			BEGIN
				INSERT INTO @MerchandiseDetails
				SELECT 0 AS intStoreId
					, 0 AS intStoreNo
					, '' AS strStoreName
					, T5.intCategoryId
					, T5.strDescription
					, ISNULL( SUM(T1.dblTotalSalesAmountRaw), 0) AS dblTotalSalesAmountRaw
					, SUM(T1.intItemsSold) AS intItemsSold
					, T4.ysnUseTaxFlag2
					, ISNULL(SUM(T1.dblTotalSalesAmountRaw), 0) AS dblTotal
				FROM tblSTCheckoutHeader T0
				INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
				INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
				INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
				INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId
				INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
				WHERE ISNULL (T0.intInvoiceId,0) <> 0
					AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY T5.intCategoryId
					, T5.strDescription
					, T4.ysnUseTaxFlag2
				ORDER BY T4.ysnUseTaxFlag2
			END
			ELSE
			BEGIN
				INSERT INTO @MerchandiseDetails
				SELECT T0.intStoreId
					, T2.intStoreNo
					, T2.strDescription AS strStoreName
					, T5.intCategoryId
					, T5.strDescription
					, ISNULL (SUM(T1.dblTotalSalesAmountRaw), 0) AS dblTotalSalesAmountRaw
					, SUM(T1.intItemsSold) AS intItemsSold
					, T4.ysnUseTaxFlag2
					, ISNULL(SUM(T1.dblTotalSalesAmountRaw), 0) AS dblTotal
				FROM tblSTCheckoutHeader T0
				INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
				INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
				INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
				INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId
				INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
				WHERE ISNULL (T0.intInvoiceId,0) <> 0
					AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY T0.intStoreId
					, T2.intStoreNo
					, T2.strDescription
					, T5.intCategoryId
					, T5.strDescription
					, T4.ysnUseTaxFlag2
				ORDER BY T4.ysnUseTaxFlag2
					, T0.intStoreId
			END
		END
		ELSE
		BEGIN
			IF @intGroupById = 0
			BEGIN
				INSERT INTO @MerchandiseDetails
				SELECT 0 AS intStoreId
					, 0 AS intStoreNo
					, '' AS strStoreName
					, T5.intCategoryId
					, T5.strDescription
					, ISNULL(SUM(T1.dblTotalSalesAmountRaw), 0) AS dblTotalSalesAmountRaw
					, SUM(T1.intItemsSold) AS intItemsSold
					, T4.ysnUseTaxFlag2
					, ISNULL(SUM(T1.dblTotalSalesAmountRaw), 0) AS dblTotal
				FROM tblSTCheckoutHeader T0
				INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
				INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
				INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
				INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId
				INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
				LEFT JOIN @tmpStoreGroup T6 ON T0.intStoreId = T6.intStoreId
				WHERE ISNULL (T0.intInvoiceId,0) <> 0
					AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY T5.intCategoryId
					, T5.strDescription
					, T4.ysnUseTaxFlag2
				ORDER BY T4.ysnUseTaxFlag2  
			END
			ELSE
			BEGIN
				INSERT INTO @MerchandiseDetails
				SELECT T0.intStoreId
					, T6.strStoreGroupName + ' - ' + CAST(T2.intStoreNo AS nvarchar(10)) AS intStoreNo
					, T2.strDescription AS strStoreName
					, T5.intCategoryId
					, T5.strDescription
					, ISNULL(SUM(T1.dblTotalSalesAmountRaw), 0) AS dblTotalSalesAmountRaw
					, SUM(T1.intItemsSold) AS intItemsSold
					, T4.ysnUseTaxFlag2
					, ISNULL(SUM(T1.dblTotalSalesAmountRaw), 0) AS dblTotal
				FROM tblSTCheckoutHeader T0
				INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
				INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
				INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
				INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId
				INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
				LEFT JOIN @tmpStoreGroup T6 ON T0.intStoreId = T6.intStoreId
				WHERE ISNULL (T0.intInvoiceId,0) <> 0
					AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY T0.intStoreId
					, T6.strStoreGroupName
					, T2.intStoreNo
					, T2.strDescription
					, T5.intCategoryId
					, T5.strDescription
					, T4.ysnUseTaxFlag2
				ORDER BY T4.ysnUseTaxFlag2
					, T0.intStoreId
			END
		END
		IF @strReportName = 'Merchandise Sales'
		BEGIN
			IF @ysnIncludeZeroValues = 1
			BEGIN
				SELECT intStoreId
					, intStoreNo
					, strStoreName
					, intCategoryId
					, strDescription
					, dblTotalSalesAmountRaw
					, intItemsSold
					, ysnUseTaxFlag2
				FROM @MerchandiseDetails
			END
			ELSE
			BEGIN
				SELECT intStoreId
					, intStoreNo
					, strStoreName
					, intCategoryId
					, strDescription
					, dblTotalSalesAmountRaw
					, intItemsSold
					, ysnUseTaxFlag2
				FROM @MerchandiseDetails
				WHERE dblTotal <> 0
			END
		END
		ELSE
		BEGIN
			SELECT
				SUM(dblTotalSalesAmountRaw) AS dblTotalSalesAmountRaw
				, SUM(intItemsSold) AS intItemsSold
			FROM @MerchandiseDetails
		END

	END
	/********** Merchandise Sales End ***********/
	
	
	/************ Merchandise Sales Tax *************/
	IF (@strReportName = 'Merchandise Sales Tax')
	BEGIN
		IF ISNULL(@strStoreGroupIds, '') = ''
		BEGIN
			IF @intGroupById = 0
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, '' AS strStoreName
						, 'Merchandise Sales Tax Total' AS strDescription
						, SUM(T4.dblTaxableSales) AS dblTaxableSales
						, SUM (T4.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
				END
				ELSE
				BEGIN
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, T1.strDescription AS strStoreName
						, T1.strDescription + ' - ' + T3.strDescription AS strDescription
						, SUM(T4.dblTaxableSales) AS dblTaxableSales
						, SUM (T4.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T1.strDescription, T3.strDescription
				END
			END
			ELSE
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					 SELECT T0.intStoreId
						, T1.intStoreNo
						, T1.strDescription AS strStoreName
						, 'Merchandise Sales Tax Total' AS strDescription
						, SUM(T4.dblTaxableSales) AS dblTaxableSales
						, SUM (T4.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId, T1.intStoreNo, T1.strDescription 
				END
				ELSE
				BEGIN
					SELECT T0.intStoreId
						, T1.intStoreNo
						, T1.strDescription AS strStoreName
						, T1.strDescription + ' - ' + T3.strDescription AS strDescription
						, SUM(T4.dblTaxableSales) AS dblTaxableSales
						, SUM (T4.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId, T1.intStoreNo, T1.strDescription, T3.strDescription
				END
			END
		END
		ELSE
		BEGIN
			IF @intGroupById = 0
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					 SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, '' AS strStoreName
						, 'Merchandise Sales Tax Total' AS strDescription
						, SUM(T4.dblTaxableSales) AS dblTaxableSales
						, SUM (T4.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					LEFT JOIN @tmpStoreGroup T5 ON T0.intStoreId = T5.intStoreId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
				END
				ELSE
				BEGIN
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, T1.strDescription AS strStoreName
						, T1.strDescription + ' - ' + T3.strDescription AS strDescription
						, SUM(T4.dblTaxableSales) AS dblTaxableSales
						, SUM (T4.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					LEFT JOIN @tmpStoreGroup T5 ON T0.intStoreId = T5.intStoreId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T1.strDescription, T3.strDescription
				END
			END
			ELSE
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					 SELECT T0.intStoreId
						, T5.strStoreGroupName + ' - ' + CAST(T1.intStoreNo AS nvarchar(10)) AS intStoreNo
						, T1.strDescription AS strStoreName
						, 'Merchandise Sales Tax Total' AS strDescription
						, SUM(T4.dblTaxableSales) AS dblTaxableSales
						, SUM (T4.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					LEFT JOIN @tmpStoreGroup T5 ON T0.intStoreId = T5.intStoreId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId, T5.strStoreGroupName, T1.intStoreNo, T1.strDescription
				END
				ELSE
				BEGIN
					SELECT T0.intStoreId
						, T5.strStoreGroupName + ' - ' + CAST(T1.intStoreNo AS nvarchar(10)) AS intStoreNo
						, T1.strDescription AS strStoreName
						, T1.strDescription + ' - ' + T3.strDescription AS strDescription
						, SUM(T4.dblTaxableSales) AS dblTaxableSales
						, SUM (T4.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					LEFT JOIN @tmpStoreGroup T5 ON T0.intStoreId = T5.intStoreId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId, T5.strStoreGroupName, T1.intStoreNo, T1.strDescription, T3.strDescription
				END
			END
		END
	END
	/********** Merchandise Sales Tax End ***********/


	/************ Fuel Tax Summary *************/
	IF (@strReportName = 'Fuel Tax Summary')
	BEGIN
		IF ISNULL(@strStoreGroupIds, '') = ''
		BEGIN
			IF @intGroupById = 0
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, '' AS strStoreName
						, 'Fuel Sales Tax Total' AS strDescription
						, SUM (T5.dblTax) AS dblTax
						, SUM (T1.dblAmount) AS dblAmount
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND T5.ysnTaxExempt = 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
				END
				ELSE
				BEGIN
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, T4.strDescription AS strStoreName
						, T4.strDescription + ' - ' + T6.strDescription AS strDescription
						, SUM (T5.dblTax) AS dblTax
						, SUM(T1.dblAmount) AS dblAmount
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND T5.ysnTaxExempt = 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T4.strDescription, T6.strDescription
					ORDER BY intStoreId
				END
			END
			ELSE
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					SELECT  T0.intStoreId
						, T4.intStoreNo
						, T4.strDescription AS strStoreName
						, 'Fuel Sales Tax Total' AS strDescription
						, SUM (T5.dblTax) AS dblTax
						, SUM (T1.dblAmount) AS dblAmount
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND T5.ysnTaxExempt = 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId, T4.intStoreNo, T4.strDescription
					ORDER BY T0.intStoreId
				END
				ELSE
				BEGIN
					SELECT T0.intStoreId
						, T4.intStoreNo
						, T4.strDescription AS strStoreName
						, T4.strDescription + ' - ' + T6.strDescription AS strDescription
						, SUM (T5.dblTax) AS dblTax
						, SUM(T1.dblAmount) AS dblAmount
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND T5.ysnTaxExempt = 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId, T4.intStoreNo, T4.strDescription, T6.strDescription
					ORDER BY T0.intStoreId
				END
			END
		END
		ELSE
		BEGIN
			IF @intGroupById = 0
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, '' AS strStoreName
						, 'Fuel Sales Tax Total' AS strDescription
						, SUM (T5.dblTax) AS dblTax
						, SUM (T1.dblAmount) AS dblAmount
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
					LEFT JOIN @tmpStoreGroup T7 ON T0.intStoreId = T7.intStoreId 
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND T5.ysnTaxExempt = 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
				END
				ELSE
				BEGIN
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, T4.strDescription AS strStoreName
						, T4.strDescription + ' - ' + T6.strDescription AS strDescription
						, SUM (T5.dblTax) AS dblTax
						, SUM(T1.dblAmount) AS dblAmount
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
					LEFT JOIN @tmpStoreGroup T7 ON T0.intStoreId = T7.intStoreId 
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND T5.ysnTaxExempt = 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T4.strDescription, T6.strDescription
				END
			END
			ELSE
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					SELECT T0.intStoreId
						, T7.strStoreGroupName + ' - ' + CAST(T4.intStoreNo AS nvarchar(10)) AS intStoreNo
						, T4.strDescription AS strStoreName
						, 'Fuel Sales Tax Total' AS strDescription
						, SUM (T5.dblTax) AS dblTax
						, SUM (T1.dblAmount) AS dblAmount
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
					LEFT JOIN @tmpStoreGroup T7 ON T0.intStoreId = T7.intStoreId 
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND T5.ysnTaxExempt = 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId, T7.strStoreGroupName ,T4.intStoreNo, T4.strDescription
					ORDER BY intStoreId
				END
				ELSE
				BEGIN
					SELECT T0.intStoreId
						, T7.strStoreGroupName + ' - ' + CAST(T4.intStoreNo AS nvarchar(10)) AS intStoreNo
						, T4.strDescription AS strStoreName
						, T4.strDescription + ' - ' + T6.strDescription AS strDescription
						, SUM (T5.dblTax) AS dblTax
						, SUM(T1.dblAmount) AS dblAmount
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
					LEFT JOIN @tmpStoreGroup T7 ON T0.intStoreId = T7.intStoreId 
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND T5.ysnTaxExempt = 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId, T7.strStoreGroupName ,T4.intStoreNo, T4.strDescription, T6.strDescription
					ORDER BY intStoreId
				END
			END
		END
	END
	/********** Fuel Tax Summary End ***********/
	
	
	/************ Summary *************/
	IF (@strReportName = 'Summary')
	BEGIN
		SELECT T5.ysnTaxExempt
			, T8.strType
			, T1.dblQuantity
			, T1.dblAmount
			, T5.dblTax
			, CASE WHEN ISNULL(T5.ysnTaxExempt, 0) <> 0 THEN T1.dblAmount ELSE 0 END AS dblNonTaxable
			, CASE WHEN ISNULL(T5.ysnTaxExempt, 0) = 0 THEN T1.dblAmount ELSE 0 END AS dblTaxable
			, T5.dblFET
			, T5.dblSET
			, T5.dblSST
			, T5.dblOthers AS dblOtherTax
		FROM tblSTCheckoutHeader T0
		INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
		INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
		INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
		INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
		INNER JOIN (
			SELECT AR.intInvoiceId
				, AR.intItemId
				, AR.dblTax
				, AR.intTaxCodeId
				, AR.ysnTaxExempt
				, dblFET = CASE WHEN AR.intTaxCodeId IN (T4.intGasFETId, T4.intDieselFETId) THEN dblTax ELSE 0 END
				, dblSET = CASE WHEN AR.intTaxCodeId IN (T4.intGasSETId, T4.intDieselSETId) THEN dblTax ELSE 0 END
				, dblSST = CASE WHEN AR.intTaxCodeId = T4.intSSTId THEN dblTax ELSE 0 END
				, dblOthers = CASE WHEN AR.intTaxCodeId IN (T4.intGasFETId, T4.intDieselFETId, T4.intGasSETId, T4.intDieselSETId, T4.intSSTId) THEN 0 ELSE dblTax END
			FROM vyuARInvoiceTaxDetail AR
			INNER JOIN (
				tblSTCheckoutHeader T0
				INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
				INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
				INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
			) ON AR.intInvoiceId = T0.intInvoiceId AND T2.intItemId = AR.intItemId
		) T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
		INNER JOIN tblSMTaxCode T6 ON T5.intTaxCodeId = T6.intTaxCodeId
		INNER JOIN tblSMTaxClass T7 ON T6.intTaxClassId = T7.intTaxClassId
		INNER JOIN tblSMTaxReportType T8 ON T7.intTaxReportTypeId = T8.intTaxReportTypeId
		WHERE ISNULL (T0.intInvoiceId,0) <> 0
			AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
			AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
			AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
		GROUP BY T5.ysnTaxExempt, T8.strType, T1.dblQuantity, T1.dblAmount, T5.dblTax, T5.dblFET, T5.dblSET, T5.dblSST, T5.dblOthers, T8.strType
	END
	/********** Summary End ***********/
	
	
	/************ Sales Tax Review *************/
	IF (@strReportName = 'Sales Tax Review')
	BEGIN
		SELECT *
			, SUM(dblGrossSales - dblSET - dblNonTaxable - dblTax) AS dblTaxableSales
			, (SUM(dblGrossSales - dblSET - dblNonTaxable - dblTax) * (dblSSTRate / 100)) AS dblStateTaxable
		FROM (
			SELECT dtmCheckoutDate
				, intStoreId
				, dblGrossSales
				, dblSET
				, dblNonTaxable = SUM(dblNonTaxable)
				, dblTax
				, (dblSSTRate / 100) AS dblSSTRate
			FROM (
				SELECT MT.dtmCheckoutDate
					, MT.intStoreId
					, SUM(MT.dblAmount) AS dblGrossSales
					, CASE WHEN MT.strType = 'State Excise Tax' THEN dblSET ELSE 0 END AS dblSET
					, MT.dblNonTaxable
					, SUM(MT.dblTax) AS dblTax
					, (SELECT TOP 1 ISNULL(dblRate, 0)
						FROM tblSMTaxCodeRate ST1
						INNER JOIN tblSMTaxCode ST2 ON ST1.intTaxCodeId = ST2.intTaxCodeId
						INNER JOIN tblSMTaxClass ST3 ON ST2.intTaxClassId = ST3.intTaxClassId
						INNER JOIN tblSMTaxReportType ST4 ON ST3.intTaxReportTypeId = ST4.intTaxReportTypeId AND strType = 'State Sales Tax') AS dblSSTRate
				FROM (
					SELECT T0.dtmCheckoutDate
						, T0.intStoreId
						, T5.ysnTaxExempt
						, T8.strType
						, T1.dblAmount
						, T5.dblTax
						, CASE WHEN ISNULL(T5.ysnTaxExempt, 0) <> 0 THEN T1.dblAmount ELSE 0 END AS dblNonTaxable
						, T5.dblSET
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
					INNER JOIN (
						SELECT AR.intInvoiceId
							, AR.intItemId
							, AR.dblTax
							, AR.intTaxCodeId
							, AR.ysnTaxExempt
							, dblFET = CASE WHEN AR.intTaxCodeId IN (T4.intGasFETId, T4.intDieselFETId) THEN dblTax ELSE 0 END
							, dblSET = CASE WHEN AR.intTaxCodeId IN (T4.intGasSETId, T4.intDieselSETId) THEN dblTax ELSE 0 END
							, dblSST = CASE WHEN AR.intTaxCodeId = T4.intSSTId THEN dblTax ELSE 0 END
							, dblOthers = CASE WHEN AR.intTaxCodeId IN (T4.intGasFETId, T4.intDieselFETId, T4.intGasSETId, T4.intDieselSETId, T4.intSSTId) THEN 0 ELSE dblTax END
						FROM vyuARInvoiceTaxDetail AR
						INNER JOIN (
							tblSTCheckoutHeader T0
							INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
							INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
							INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						) ON AR.intInvoiceId = T0.intInvoiceId AND T2.intItemId = AR.intItemId
					) T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
					INNER JOIN tblSMTaxCode T6 ON T5.intTaxCodeId = T6.intTaxCodeId
					INNER JOIN tblSMTaxClass T7 ON T6.intTaxClassId = T7.intTaxClassId
					INNER JOIN tblSMTaxReportType T8 ON T7.intTaxReportTypeId = T8.intTaxReportTypeId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.dtmCheckoutDate
						, T0.intStoreId
						, T5.ysnTaxExempt
						, T8.strType
						, T1.dblQuantity
						, T1.dblAmount
						, T5.dblTax
						, T5.dblSET
						, T8.strType
					
					UNION ALL SELECT T0.dtmCheckoutDate
						, T0.intStoreId
						, 0
						, ''
						, SUM(ISNULL(T1.dblTotalSalesAmountRaw, 0)) AS dblTotalSalesAmountRaw
						, 0
						, 0
						, 0
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
					INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId
					INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.dtmCheckoutDate
						, T0.intStoreId
					
					UNION ALL SELECT T0.dtmCheckoutDate
						, T0.intStoreId
						, 0
						, ''
						, 0
						, SUM(T4.dblTotalTax), 0, 0 AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTStore T1 ON T0.intStoreId = T1.intStoreId
					INNER JOIN tblSTStoreTaxTotals T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
					INNER JOIN tblSTCheckoutSalesTaxTotals T4 ON T0.intCheckoutId = T4.intCheckoutId and T3.intItemId = T4.intItemId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.dtmCheckoutDate
						, T0.intStoreId
						, T1.strDescription
						, T2.intItemId
						, T3.strDescription
				) MT
				GROUP BY MT.dtmCheckoutDate
					, MT.intStoreId
					, MT.strType
					, MT.dblSET
					, MT.dblNonTaxable
					, MT.dblAmount
			) T
			GROUP BY dtmCheckoutDate
				, intStoreId
				, dblGrossSales
				, dblSET
				, dblTax
				, dblSSTRate
		) T
		GROUP BY dtmCheckoutDate
			, intStoreId
			, dblGrossSales
			, dblSET
			, dblNonTaxable
			, dblTax
			, dblSSTRate
	END
	/********** Sales Tax Review End ***********/

END