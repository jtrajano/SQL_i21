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
		, dblAmount NUMERIC(18, 6))

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
		, dblAmount NUMERIC(18, 6)
		, intInvoiceDetailId INT)
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
		, dblAmount NUMERIC(18, 6)
		, intInvoiceDetailId INT)
		
	DECLARE @MerchandiseDetails AS TABLE (intStoreId INT
		, intStoreNo NVARCHAR(100)
		, strStoreName NVARCHAR(100)
		, intCategoryId INT
		, strDescription NVARCHAR(250)
		, dblTotalSalesAmountRaw NUMERIC(18, 6)
		, intItemsSold INT
		, ysnUseTaxFlag2 BIT
		, dblTotal NUMERIC(18, 6)
		, dblTotalTax NUMERIC(18, 6))

	DECLARE @CategorySalesTotalDetails AS TABLE (intStoreId INT, 
		intStoreNo INT,
		dblTaxableTotalSales DECIMAL(18, 2),
		dblNonTaxableTotalSales DECIMAL(18, 2),
		intItemsSold INT,
		dblTaxableTotalTax DECIMAL(18, 2),
		dblTaxableNetSales DECIMAL(18, 2),
		dblNonTaxableTotalTax DECIMAL(18, 2),
		dblNonTaxableNetSales DECIMAL(18, 2)
	)
		
	DECLARE @SummaryTotalDetails AS TABLE (intStoreId INT
			, dblTaxableTotalSales NUMERIC(18, 6)
			, dblNonTaxableTotalSales NUMERIC(18, 6)
		)

	INSERT INTO @tmpStores
	SELECT DISTINCT Item FROM dbo.fnSplitString(@strStoreIds, ',')

	INSERT INTO @tmpStoreGroup
	SELECT DISTINCT ST2.intStoreId
		, ST1.strStoreGroupName
	FROM tblSTStoreGroup ST1
	INNER JOIN tblSTStoreGroupDetail ST2 ON ST1.intStoreGroupId = ST2.intStoreGroupId
	WHERE ST1.intStoreGroupId IN (SELECT Item FROM dbo.fnSplitString(@strStoreGroupIds, ','))
	
	IF (@strReportName IN ('Tax Fuel Sales', 'Fuel Tax Total', 'Summary', 'Sales Tax Review'))
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
			, T5.intInvoiceDetailId
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
			, T5.intInvoiceDetailId

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
			, T5.intInvoiceDetailId
		FROM tblSTCheckoutHeader T0
		INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
		INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
		INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
		INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
		INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId
		LEFT JOIN @tmpStoreGroup T6 ON T0.intStoreId = T6.intStoreId
		WHERE ISNULL(T0.intInvoiceId, 0) <> 0 AND T5.ysnTaxExempt = 0
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
			, T5.intInvoiceDetailId
	END

	

	/************ Tax Fuel Sales *************/
	IF (@strReportName = 'Tax Fuel Sales')
	BEGIN
		IF ISNULL(@strStoreGroupIds, '') = ''
		BEGIN
			IF @intGroupById = 0
			BEGIN
				INSERT INTO @tmpDetails
				SELECT dtmCheckoutDate, intStoreNo, intStoreId, strStoreName, intItemId, strItemNo, strDescription,
				   AVG(dblPrice), SUM(dblQuantity) AS dblQuantity, SUM(dblNetSales) AS dblNetSales, SUM(dblTax) AS dblTax,
				   SUM(dblAmount) AS dblAmount
				FROM 
				(
				  SELECT dtmCheckoutDate = CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
						, intStoreNo = 0
						, intStoreId = 0
						, strStoreName = ''
						, intItemId
						, strItemNo
						, strDescription
						, MT.dblPrice 
						, AVG (MT.dblQuantity) AS dblQuantity
						, (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax) AS dblNetSales
						, SUM(MT.dblTax) AS dblTax 
						, AVG(MT.dblPrice) * AVG (MT.dblQuantity) AS dblAmount
						, MT.intInvoiceDetailId
					FROM @MainStore MT
					WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END, MT.strStoreName, intItemId
						, strItemNo, strDescription, MT.dblPrice, MT.intInvoiceDetailId
				) tbl
				GROUP BY dtmCheckoutDate, intStoreNo, intStoreId, strStoreName, intItemId, strItemNo, strDescription
			END
			ELSE
			BEGIN
				INSERT INTO @tmpDetails
				SELECT dtmCheckoutDate, intStoreNo, intStoreId, strStoreName, intItemId, strItemNo, strDescription,
				   AVG(dblPrice), SUM(dblQuantity) AS dblQuantity, SUM(dblNetSales) AS dblNetSales, SUM(dblTax) AS dblTax,
				   SUM(dblAmount) AS dblAmount
				FROM 
				(
				  SELECT dtmCheckoutDate = CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
						, intStoreNo
						, intStoreId
						, strStoreName
						, intItemId
						, strItemNo
						, strDescription
						, MT.dblPrice 
						, AVG (MT.dblQuantity) AS dblQuantity
						, (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax) AS dblNetSales
						, SUM(MT.dblTax) AS dblTax 
						, AVG(MT.dblPrice) * AVG (MT.dblQuantity) AS dblAmount
						, MT.intInvoiceDetailId
					FROM @MainStore MT
					WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END, intStoreNo, intStoreId, MT.strStoreName, intItemId
						, strItemNo, strDescription, MT.dblPrice, MT.intInvoiceDetailId
				) tbl
				GROUP BY dtmCheckoutDate, intStoreNo, intStoreId, strStoreName, intItemId, strItemNo, strDescription
			END
		END
		ELSE
		BEGIN
			IF @intGroupById = 0
			BEGIN
				INSERT INTO @tmpDetails
				SELECT dtmCheckoutDate, intStoreNo, intStoreId, strStoreName, intItemId, strItemNo, strDescription,
				   AVG(dblPrice), SUM(dblQuantity) AS dblQuantity, SUM(dblNetSales) AS dblNetSales, SUM(dblTax) AS dblTax,
				   SUM(dblAmount) AS dblAmount
				FROM 
				(
				  SELECT dtmCheckoutDate = CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
						, intStoreNo = 0
						, intStoreId = 0
						, strStoreName = ''
						, intItemId
						, strItemNo
						, strDescription
						, MT.dblPrice 
						, AVG (MT.dblQuantity) AS dblQuantity
						, (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax) AS dblNetSales
						, SUM(MT.dblTax) AS dblTax 
						, AVG(MT.dblPrice) * AVG (MT.dblQuantity) AS dblAmount
						, MT.intInvoiceDetailId
					FROM @MainStore MT
					WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END, MT.strStoreName, intItemId
						, strItemNo, strDescription, MT.dblPrice, MT.intInvoiceDetailId
				) tbl
				GROUP BY dtmCheckoutDate, intStoreNo, intStoreId, strStoreName, intItemId, strItemNo, strDescription
			END
			ELSE
			BEGIN
				INSERT INTO @tmpDetails
				SELECT dtmCheckoutDate, intStoreNo, intStoreId, strStoreName, intItemId, strItemNo, strDescription,
				   AVG(dblPrice), SUM(dblQuantity) AS dblQuantity, SUM(dblNetSales) AS dblNetSales, SUM(dblTax) as dblTax,
				   SUM(dblAmount) as dblAmount
				FROM 
				(
				  SELECT dtmCheckoutDate = CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END
						, intStoreNo
						, intStoreId
						, strStoreName
						, intItemId
						, strItemNo
						, strDescription
						, MT.dblPrice 
						, AVG (MT.dblQuantity) AS dblQuantity
						, (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax) AS dblNetSales
						, SUM(MT.dblTax) AS dblTax 
						, AVG(MT.dblPrice) * AVG (MT.dblQuantity) AS dblAmount
						, MT.intInvoiceDetailId
					FROM @MainStore MT
					WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY CASE WHEN @ysnSummary = 1 THEN NULL ELSE dtmCheckoutDate END, intStoreNo, intStoreId, MT.strStoreName, intItemId
						, strItemNo, strDescription, MT.dblPrice, MT.intInvoiceDetailId
				) tbl
				GROUP BY dtmCheckoutDate, intStoreNo, intStoreId, strStoreName, intItemId, strItemNo, strDescription
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
			WHERE dblAmount <> 0
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
					, MT.intInvoiceDetailId
				FROM @MainStore MT
				WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY MT.intItemId, MT.intStoreId, MT.intInvoiceDetailId
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
	IF (@strReportName IN ('Merchandise Sales', 
			'Merchandise Sales Total' ,'Summary', 'Sales Tax Review'))
	BEGIN
		IF ISNULL(@strStoreGroupIds, '') = ''
		BEGIN
			IF @intGroupById = 0
			BEGIN
				INSERT INTO @MerchandiseDetails
				SELECT  intStoreId
					, intStoreNo
					, strDescription
					, intCategoryId
					, strDescription
					, SUM(dblTotalSalesAmountRaw) AS dblTotalSalesAmountRaw
					, SUM(intItemsSold) AS intItemsSold
					, ysnUseTaxFlag2
					, SUM(dblTotal) AS dblTotal
					, SUM(dblTotalTax) AS dblTotalTax
				FROM (
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, '' AS strStoreName
						, T5.intCategoryId
						, T5.strDescription
						, ISNULL( AVG(T1.dblTotalSalesAmountComputed), 0) AS dblTotalSalesAmountRaw
						, AVG(T1.intItemsSold) AS intItemsSold
						, T4.ysnUseTaxFlag2
						, ISNULL(AVG(T1.dblTotalSalesAmountComputed), 0) AS dblTotal
						, AVG(T6.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
					INNER JOIN tblICItemLocation T8 ON T3.intItemId = T8.intItemId
					INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId and T4.intLocationId = T8.intLocationId
					INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
					--INNER JOIN tblSTCheckoutSalesTaxTotals T6 ON T0.intCheckoutId = T6.intCheckoutId
					INNER JOIN (
						SELECT T0.intCheckoutId
							, SUM(T1.dblTotalTax) AS dblTotalTax 
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutSalesTaxTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						GROUP BY T0.intCheckoutId
					) T6 ON T0.intCheckoutId = T6.intCheckoutId
					LEFT JOIN vyuSTStoreMaintenanceDepartments T7 ON T4.intCategoryId = T7.intCategoryId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0 AND ISNULL(T7.ysnFuelCategory, 0) <> 1
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T5.intCategoryId
						, T5.strDescription
						, T4.ysnUseTaxFlag2
						, T0.dtmCheckoutDate
				) tbl
				GROUP BY intStoreId
					, intStoreNo
					, strDescription
					, intCategoryId
					, strDescription
					, ysnUseTaxFlag2
				ORDER BY ysnUseTaxFlag2
			END
			ELSE
			BEGIN
				INSERT INTO @MerchandiseDetails
				SELECT  intStoreId
					, intStoreNo
					, strDescription
					, intCategoryId
					, strDescription
					, SUM(dblTotalSalesAmountRaw) AS dblTotalSalesAmountRaw
					, SUM(intItemsSold) AS intItemsSold
					, ysnUseTaxFlag2
					, SUM(dblTotal) AS dblTotal
					, SUM(dblTotalTax) AS dblTotalTax
				FROM (
					SELECT T0.intStoreId
						, T2.intStoreNo
						, T2.strDescription AS strStoreName
						, T5.intCategoryId
						, T5.strDescription
						, ISNULL (AVG(T1.dblTotalSalesAmountComputed), 0) AS dblTotalSalesAmountRaw
						, AVG(T1.intItemsSold) AS intItemsSold
						, T4.ysnUseTaxFlag2
						, ISNULL(AVG(T1.dblTotalSalesAmountComputed), 0) AS dblTotal
						, AVG(T6.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
					INNER JOIN tblICItemLocation T8 ON T3.intItemId = T8.intItemId
					INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId and T4.intLocationId = T8.intLocationId
					INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
					--INNER JOIN tblSTCheckoutSalesTaxTotals T6 ON T0.intCheckoutId = T6.intCheckoutId
					INNER JOIN (
						SELECT T0.intCheckoutId
							, SUM(T1.dblTotalTax) AS dblTotalTax 
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutSalesTaxTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						GROUP BY T0.intCheckoutId
					) T6 ON T0.intCheckoutId = T6.intCheckoutId
					LEFT JOIN vyuSTStoreMaintenanceDepartments T7 ON T4.intCategoryId = T7.intCategoryId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0 AND ISNULL(T7.ysnFuelCategory, 0) <> 1
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId
						, T2.intStoreNo
						, T2.strDescription
						, T5.intCategoryId
						, T5.strDescription
						, T4.ysnUseTaxFlag2
						, T0.dtmCheckoutDate
				) tbl
				GROUP BY intStoreId
					, intStoreNo
					, strDescription
					, intCategoryId
					, strDescription
					, ysnUseTaxFlag2
				ORDER BY ysnUseTaxFlag2
						, intCategoryId
			END
		END
		ELSE
		BEGIN
			IF @intGroupById = 0
			BEGIN
				INSERT INTO @MerchandiseDetails
				SELECT  intStoreId
					, intStoreNo
					, strDescription
					, intCategoryId
					, strDescription
					, SUM(dblTotalSalesAmountRaw) AS dblTotalSalesAmountRaw
					, SUM(intItemsSold) AS intItemsSold
					, ysnUseTaxFlag2
					, SUM(dblTotal) AS dblTotal
					, SUM(dblTotalTax) AS dblTotalTax
				FROM (
					SELECT 0 AS intStoreId
						, 0 AS intStoreNo
						, '' AS strStoreName
						, T5.intCategoryId
						, T5.strDescription
						, ISNULL(AVG(T1.dblTotalSalesAmountComputed), 0) AS dblTotalSalesAmountRaw
						, AVG(T1.intItemsSold) AS intItemsSold
						, T4.ysnUseTaxFlag2
						, ISNULL(AVG(T1.dblTotalSalesAmountComputed), 0) AS dblTotal
						, AVG(T7.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
					INNER JOIN tblICItemLocation T9 ON T3.intItemId = T9.intItemId
					INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId and T4.intLocationId = T9.intLocationId
					INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
					LEFT JOIN @tmpStoreGroup T6 ON T0.intStoreId = T6.intStoreId
					--INNER JOIN tblSTCheckoutSalesTaxTotals T7 ON T0.intCheckoutId = T7.intCheckoutId
					INNER JOIN (
						SELECT T0.intCheckoutId
							, SUM(T1.dblTotalTax) AS dblTotalTax 
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutSalesTaxTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						GROUP BY T0.intCheckoutId
					) T7 ON T0.intCheckoutId = T7.intCheckoutId
					LEFT JOIN vyuSTStoreMaintenanceDepartments T8 ON T4.intCategoryId = T8.intCategoryId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0 AND ISNULL(T8.ysnFuelCategory, 0) <> 1
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T5.intCategoryId
						, T5.strDescription
						, T4.ysnUseTaxFlag2
						, T0.dtmCheckoutDate
					) tbl
				GROUP BY intStoreId
					, intStoreNo
					, strDescription
					, intCategoryId
					, strDescription
					, ysnUseTaxFlag2
				ORDER BY ysnUseTaxFlag2
			END
			ELSE
			BEGIN
				INSERT INTO @MerchandiseDetails
				SELECT  intStoreId
					, intStoreNo
					, strDescription
					, intCategoryId
					, strDescription
					, SUM(dblTotalSalesAmountRaw) AS dblTotalSalesAmountRaw
					, SUM(intItemsSold) AS intItemsSold
					, ysnUseTaxFlag2
					, SUM(dblTotal) AS dblTotal
					, SUM(dblTotalTax) AS dblTotalTax
				FROM (
					SELECT T0.intStoreId
						, T6.strStoreGroupName + ' - ' + CAST(T2.intStoreNo AS nvarchar(10)) AS intStoreNo
						, T2.strDescription AS strStoreName
						, T5.intCategoryId
						, T5.strDescription
						, ISNULL(AVG(T1.dblTotalSalesAmountComputed), 0) AS dblTotalSalesAmountRaw
						, AVG(T1.intItemsSold) AS intItemsSold
						, T4.ysnUseTaxFlag2
						, ISNULL(AVG(T1.dblTotalSalesAmountComputed), 0) AS dblTotal
						, AVG(T7.dblTotalTax) AS dblTotalTax
					FROM tblSTCheckoutHeader T0
					INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
					INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId
					INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId
					INNER JOIN tblICItemLocation T9 ON T3.intItemId = T9.intItemId
					INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId and T4.intLocationId = T9.intLocationId
					INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId
					LEFT JOIN @tmpStoreGroup T6 ON T0.intStoreId = T6.intStoreId
					--INNER JOIN tblSTCheckoutSalesTaxTotals T7 ON T0.intCheckoutId = T7.intCheckoutId
					INNER JOIN (
						SELECT T0.intCheckoutId
							, SUM(T1.dblTotalTax) AS dblTotalTax 
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutSalesTaxTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						GROUP BY T0.intCheckoutId
					) T7 ON T0.intCheckoutId = T7.intCheckoutId
					LEFT JOIN vyuSTStoreMaintenanceDepartments T8 ON T4.intCategoryId = T8.intCategoryId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0 AND ISNULL(T8.ysnFuelCategory, 0) <> 1
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
						, T0.dtmCheckoutDate
					) tbl
					GROUP BY intStoreId
						, intStoreNo
						, strDescription
						, intCategoryId
						, strDescription
						, ysnUseTaxFlag2
					ORDER BY ysnUseTaxFlag2
						, intCategoryId
			END
		END

		IF @ysnIncludeZeroValues = 1
		BEGIN 
			INSERT INTO @CategorySalesTotalDetails
			SELECT intStoreId, intStoreNo, 
				ISNULL(SUM(dblTotalSalesAmountRaw), 0) AS dblTaxableTotalSales,
				0 AS dblNonTaxableTotalSales,
				ISNULL(SUM(intItemsSold), 0) AS intItemsSold,
				ISNULL(AVG(dblTotalTax), 0) AS dblTaxableTotalTax,
				ISNULL(SUM(dblTotalSalesAmountRaw), 0) - ISNULL(AVG(dblTotalTax), 0) AS dblTaxableNetSales,
				0 AS dbNonlTaxableTotalTax,
				0 AS dblNonTaxableNetSales
			FROM @MerchandiseDetails
			WHERE ysnUseTaxFlag2 <> 0
			GROUP BY intStoreId, intStoreNo
			UNION
			SELECT intStoreId, intStoreNo, 
				0 AS dblTaxableTotalSales,
				ISNULL(SUM(dblTotalSalesAmountRaw), 0) AS dblNonTaxableTotalSales,
				ISNULL(SUM(intItemsSold), 0) AS intItemsSold,
				0 AS dblTaxableTotalTax,
				0 AS dblTaxableNetSales,
				ISNULL(AVG(dblTotalTax), 0) AS dblNonTaxableTotalTax,
				ISNULL(SUM(dblTotalSalesAmountRaw), 0) AS dblNonTaxableNetSales
			FROM @MerchandiseDetails
			WHERE ysnUseTaxFlag2 = 0
			GROUP BY intStoreId, intStoreNo
		END
		ELSE
		BEGIN
			INSERT INTO @CategorySalesTotalDetails
			SELECT intStoreId, intStoreNo, 
				ISNULL(SUM(dblTotalSalesAmountRaw), 0) AS dblTaxableTotalSales,
				0 AS dblNonTaxableTotalSales,
				ISNULL(SUM(intItemsSold), 0) AS intItemsSold,
				ISNULL(AVG(dblTotalTax), 0) AS dblTaxableTotalTax,
				ISNULL(SUM(dblTotalSalesAmountRaw), 0) - ISNULL(AVG(dblTotalTax), 0) AS dblTaxableNetSales,
				0 AS dbNonlTaxableTotalTax,
				0 AS dblNonTaxableNetSales
			FROM @MerchandiseDetails
			WHERE ysnUseTaxFlag2 <> 0 AND dblTotalSalesAmountRaw <> 0
			GROUP BY intStoreId, intStoreNo
			UNION
			SELECT intStoreId, intStoreNo, 
				0 AS dblTaxableTotalSales,
				ISNULL(SUM(dblTotalSalesAmountRaw), 0) AS dblNonTaxableTotalSales,
				ISNULL(SUM(intItemsSold), 0) AS intItemsSold,
				0 AS dblTaxableTotalTax,
				0 AS dblTaxableNetSales,
				ISNULL(AVG(dblTotalTax), 0) AS dblNonTaxableTotalTax,
				ISNULL(SUM(dblTotalSalesAmountRaw), 0) AS dblNonTaxableNetSales
			FROM @MerchandiseDetails
			WHERE ysnUseTaxFlag2 = 0 AND dblTotalSalesAmountRaw <> 0
			GROUP BY intStoreId, intStoreNo
		END

		IF @strReportName IN ('Merchandise Sales', 'Merchandise Sales Total')
		BEGIN
			SELECT intStoreId, intStoreNo
			, SUM(dblNonTaxableTotalSales) + SUM(dblTaxableTotalSales) AS dblTotalSalesAmountRaw
			, SUM(intItemsSold) AS intItemsSold
			, (SUM(dblTaxableTotalTax)) AS dblTotalTax
			, ((SUM(dblNonTaxableTotalSales) + SUM(dblTaxableTotalSales)) - SUM(dblTaxableTotalTax)) AS dblTotalNetSales
			FROM @CategorySalesTotalDetails
			GROUP BY intStoreId, intStoreNo
		END
		IF @strReportName IN ('Summary', 'Sales Tax Review')
		BEGIN
			INSERT INTO @SummaryTotalDetails
			SELECT intStoreId, SUM(dblTaxableTotalSales) as dblTaxableTotalSales,
				SUM(dblNonTaxableTotalSales) as dblNonTaxableTotalSales
			FROM @CategorySalesTotalDetails
			GROUP BY intStoreId
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
					SELECT 
						intStoreId, intStoreNo, strStoreName, strDescription, SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
					FROM (
						SELECT 
							intStoreId, intStoreNo, strStoreName, strDescription, dblTax, dblAmount = CASE WHEN intRowId = 1 THEN dblAmount ELSE 0 END
						FROM (
							SELECT 0 AS intStoreId
							, 0 AS intStoreNo
							, '' AS strStoreName
							, 'Fuel Sales Tax Total' AS strDescription
							, T5.dblTax
							, T1.dblAmount
							, T5.intInvoiceDetailId
							, intRowId = ROW_NUMBER() OVER (PARTITION BY T5.intInvoiceDetailId ORDER BY T5.intInvoiceDetailId, T5.intInvoiceDetailTaxId)
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
						INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
						INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND  T3.intItemId = T5.intItemId
						INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
							AND T5.ysnTaxExempt = 0
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
							AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						) as tbl
					) tbl
					GROUP BY intStoreId, intStoreNo, strStoreName, strDescription
				END
				ELSE
				BEGIN
					SELECT 
						intStoreId, intStoreNo, strStoreName, strDescription, SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
					FROM (
						SELECT 
							intStoreId, intStoreNo, strStoreName, strDescription, dblTax, dblAmount = CASE WHEN intRowId = 1 THEN dblAmount ELSE 0 END
						FROM (
							SELECT 0 AS intStoreId
							, 0 AS intStoreNo
							, T4.strDescription AS strStoreName
							, 'Fuel Sales Tax Total' AS strDescription
							, T5.dblTax
							, T1.dblAmount
							, T5.intInvoiceDetailId
							, intRowId = ROW_NUMBER() OVER (PARTITION BY T5.intInvoiceDetailId ORDER BY T5.intInvoiceDetailId, T5.intInvoiceDetailTaxId)
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
						INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
						INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND  T3.intItemId = T5.intItemId
						INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
							AND T5.ysnTaxExempt = 0
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
							AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						) as tbl
					) tbl
					GROUP BY intStoreId, intStoreNo, strStoreName, strDescription
				END
			END
			ELSE
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					SELECT 
						intStoreId, intStoreNo, strStoreName, strDescription, SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
					FROM (
						SELECT 
							intStoreId, intStoreNo, strStoreName, strDescription, dblTax, dblAmount = CASE WHEN intRowId = 1 THEN dblAmount ELSE 0 END
						FROM (
							SELECT T0.intStoreId
							, T4.intStoreNo
							, T4.strDescription AS strStoreName
							, 'Fuel Sales Tax Total' AS strDescription
							, T5.dblTax
							, T1.dblAmount
							, T5.intInvoiceDetailId
							, intRowId = ROW_NUMBER() OVER (PARTITION BY T5.intInvoiceDetailId ORDER BY T5.intInvoiceDetailId, T5.intInvoiceDetailTaxId)
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
						INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
						INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND  T3.intItemId = T5.intItemId
						INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
							AND T5.ysnTaxExempt = 0
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
							AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						) as tbl
					) tbl
					GROUP BY intStoreId, intStoreNo, strStoreName, strDescription
				END
				ELSE
				BEGIN
					SELECT 
						intStoreId, intStoreNo, strStoreName, strDescription, SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
					FROM (
						SELECT 
							intStoreId, intStoreNo, strStoreName, strDescription, dblTax, dblAmount = CASE WHEN intRowId = 1 THEN dblAmount ELSE 0 END
						FROM (
							SELECT T0.intStoreId
							, T4.intStoreNo
							, T4.strDescription AS strStoreName
							, T4.strDescription + ' - ' + T6.strDescription AS strDescription
							, T5.dblTax
							, T1.dblAmount
							, T5.intInvoiceDetailId
							, intRowId = ROW_NUMBER() OVER (PARTITION BY T5.intInvoiceDetailId ORDER BY T5.intInvoiceDetailId, T5.intInvoiceDetailTaxId)
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
						INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
						INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND  T3.intItemId = T5.intItemId
						INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
							AND T5.ysnTaxExempt = 0
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
							AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						) as tbl
					) tbl
					GROUP BY intStoreId, intStoreNo, strStoreName, strDescription
				END
			END
		END
		ELSE
		BEGIN
			IF @intGroupById = 0
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					SELECT 
						intStoreId, intStoreNo, strStoreName, strDescription, SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
					FROM (
						SELECT 
							intStoreId, intStoreNo, strStoreName, strDescription, dblTax, dblAmount = CASE WHEN intRowId = 1 THEN dblAmount ELSE 0 END
						FROM (
							SELECT 0 AS intStoreId
							, 0 AS intStoreNo
							, '' AS strStoreName
							, 'Fuel Sales Tax Total' AS strDescription
							, T5.dblTax
							, T1.dblAmount
							, T5.intInvoiceDetailId
							, intRowId = ROW_NUMBER() OVER (PARTITION BY T5.intInvoiceDetailId ORDER BY T5.intInvoiceDetailId, T5.intInvoiceDetailTaxId)
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
						INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
						INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND  T3.intItemId = T5.intItemId
						INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
						LEFT JOIN @tmpStoreGroup T7 ON T0.intStoreId = T7.intStoreId 
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
							AND T5.ysnTaxExempt = 0
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
							AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						) as tbl
					) tbl
					GROUP BY intStoreId, intStoreNo, strStoreName, strDescription
				END
				ELSE
				BEGIN
					SELECT 
						intStoreId, intStoreNo, strStoreName, strDescription, SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
					FROM (
						SELECT 
							intStoreId, intStoreNo, strStoreName, strDescription, dblTax, dblAmount = CASE WHEN intRowId = 1 THEN dblAmount ELSE 0 END
						FROM (
							SELECT 0 AS intStoreId
							, 0 AS intStoreNo
							, T4.strDescription AS strStoreName
							, T4.strDescription + ' - ' + T6.strDescription AS strDescription
							, T5.dblTax
							, T1.dblAmount
							, T5.intInvoiceDetailId
							, intRowId = ROW_NUMBER() OVER (PARTITION BY T5.intInvoiceDetailId ORDER BY T5.intInvoiceDetailId, T5.intInvoiceDetailTaxId)
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
						INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
						INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND  T3.intItemId = T5.intItemId
						INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
						LEFT JOIN @tmpStoreGroup T7 ON T0.intStoreId = T7.intStoreId 
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
							AND T5.ysnTaxExempt = 0
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
							AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						) as tbl
					) tbl
					GROUP BY intStoreId, intStoreNo, strStoreName, strDescription
				END
			END
			ELSE
			BEGIN
				IF (@ysnSummary = 1)
				BEGIN
					SELECT 
						intStoreId, intStoreNo, strStoreName, strDescription, SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
					FROM (
						SELECT 
							intStoreId, intStoreNo, strStoreName, strDescription, dblTax, dblAmount = CASE WHEN intRowId = 1 THEN dblAmount ELSE 0 END
						FROM (
							SELECT 0 AS intStoreId
							, T7.strStoreGroupName + ' - ' + CAST(T4.intStoreNo AS nvarchar(10)) AS intStoreNo
							, T4.strDescription AS strStoreName
							, 'Fuel Sales Tax Total' AS strDescription
							, T5.dblTax
							, T1.dblAmount
							, T5.intInvoiceDetailId
							, intRowId = ROW_NUMBER() OVER (PARTITION BY T5.intInvoiceDetailId ORDER BY T5.intInvoiceDetailId, T5.intInvoiceDetailTaxId)
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
						INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
						INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND  T3.intItemId = T5.intItemId
						INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
						LEFT JOIN @tmpStoreGroup T7 ON T0.intStoreId = T7.intStoreId 
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
							AND T5.ysnTaxExempt = 0
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
							AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						) as tbl
					) tbl
					GROUP BY intStoreId, intStoreNo, strStoreName, strDescription
				END
				ELSE
				BEGIN
					SELECT 
						intStoreId, intStoreNo, strStoreName, strDescription, SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
					FROM (
						SELECT 
							intStoreId, intStoreNo, strStoreName, strDescription, dblTax, dblAmount = CASE WHEN intRowId = 1 THEN dblAmount ELSE 0 END
						FROM (
							SELECT T0.intStoreId
							, T7.strStoreGroupName + ' - ' + CAST(T4.intStoreNo AS nvarchar(10)) AS intStoreNo
							, T4.strDescription AS strStoreName
							, T4.strDescription + ' - ' + T6.strDescription AS strDescription
							, T5.dblTax
							, T1.dblAmount
							, T5.intInvoiceDetailId
							, intRowId = ROW_NUMBER() OVER (PARTITION BY T5.intInvoiceDetailId ORDER BY T5.intInvoiceDetailId, T5.intInvoiceDetailTaxId)
						FROM tblSTCheckoutHeader T0
						INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId
						INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId
						INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId
						INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId
						INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND  T3.intItemId = T5.intItemId
						INNER JOIN tblSMTaxGroup T6 ON T5.strTaxGroup = T6.strTaxGroup
						LEFT JOIN @tmpStoreGroup T7 ON T0.intStoreId = T7.intStoreId 
						WHERE ISNULL (T0.intInvoiceId,0) <> 0
							AND T5.ysnTaxExempt = 0
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
							AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
							AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
						) as tbl
					) tbl
					GROUP BY intStoreId, intStoreNo, strStoreName, strDescription
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
			, AVG(T10.dblQuantity) AS dblQuantity
			, AVG(T10.dblAmount) AS dblAmount
			, SUM(T5.dblTax) AS dblTax
			, T9.dblNonTaxableTotalSales AS dblNonTaxable
			, T9.dblTaxableTotalSales AS dblTaxable
			, T5.dblFET
			, T5.dblSET
			, T5.dblSST
			, SUM(T5.dblOthers) AS dblOtherTax
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
		LEFT JOIN tblSMTaxCode T6 ON T5.intTaxCodeId = T6.intTaxCodeId
		LEFT JOIN tblSMTaxClass T7 ON T6.intTaxClassId = T7.intTaxClassId
		LEFT JOIN tblSMTaxReportType T8 ON T7.intTaxReportTypeId = T8.intTaxReportTypeId
		INNER JOIN @SummaryTotalDetails T9 ON T0.intStoreId = T9.intStoreId
		INNER JOIN (
			SELECT intStoreId, SUM(dblQuantity) AS dblQuantity, SUM(dblNetSales) AS dblNetSales, 
				SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
			FROM (
				SELECT MT.intItemId
					, MT.intStoreId
					, AVG (MT.dblQuantity) AS dblQuantity
					, (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax) AS dblNetSales
					, SUM (MT.dblTax) AS dblTax
					, AVG(MT.dblPrice) * AVG (MT.dblQuantity) AS dblAmount
					, MT.intInvoiceDetailId
				FROM @MainStore MT
				WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
					AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
					AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
				GROUP BY MT.intItemId, MT.intStoreId, MT.intInvoiceDetailId
			) tmp GROUP BY intStoreId
		) T10 ON T0.intStoreId = T10.intStoreId
		WHERE ISNULL (T0.intInvoiceId,0) <> 0
			AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
			AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
			AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
		GROUP BY T5.ysnTaxExempt, T5.dblFET, T5.dblSET, T5.dblSST
		, T8.strType
		, T9.dblNonTaxableTotalSales, T9.dblTaxableTotalSales
	END
	/********** Summary End ***********/
	
	/************ Sales Tax Review *************/
	IF (@strReportName = 'Sales Tax Review')
	BEGIN
		SELECT *
			, SUM(dblGrossSales - dblSET - dblNonTaxable - dblTax) AS dblTaxableSales
			, (SUM(dblGrossSales - dblSET - dblNonTaxable - dblTax) * dblSSTRate) AS dblStateTaxable
		FROM (
			SELECT intStoreId
				, dblGrossSales
				, SUM(dblSET) AS dblSET
				, dblNonTaxable = AVG(dblNonTaxable)
				, SUM(dblTax) + AVG(dblTaxable) AS dblTax
				, (dblSSTRate / 100) AS dblSSTRate
			FROM (
				SELECT MT.intStoreId
					, AVG(MT.dblAmount) AS dblGrossSales
					, CASE WHEN MT.strType = 'State Excise Tax' THEN SUM(dblSET) ELSE 0 END AS dblSET
					, MT.dblNonTaxable
					, MT.dblTaxable
					, CASE WHEN MT.strType = 'State Sales Tax' THEN SUM(MT.dblTax) ELSE 0 END AS dblTax
					, (SELECT TOP 1 ISNULL(dblRate, 0)
						FROM tblSMTaxCodeRate ST1
						INNER JOIN tblSMTaxCode ST2 ON ST1.intTaxCodeId = ST2.intTaxCodeId
						INNER JOIN tblSMTaxClass ST3 ON ST2.intTaxClassId = ST3.intTaxClassId
						INNER JOIN tblSMTaxReportType ST4 ON ST3.intTaxReportTypeId = ST4.intTaxReportTypeId AND strType = 'State Sales Tax') AS dblSSTRate
				FROM (
					SELECT T0.intStoreId
						, T5.ysnTaxExempt
						, T8.strType
						, T10.dblAmount
						, T5.dblTax
						, T11.dblNonTaxableTotalSales AS dblNonTaxable
						, T11.dblTaxableTotalSales AS dblTaxable
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
					LEFT JOIN tblSMTaxCode T6 ON T5.intTaxCodeId = T6.intTaxCodeId
					LEFT JOIN tblSMTaxClass T7 ON T6.intTaxClassId = T7.intTaxClassId
					LEFT JOIN tblSMTaxReportType T8 ON T7.intTaxReportTypeId = T8.intTaxReportTypeId
					INNER JOIN (
						SELECT intStoreId, SUM(dblQuantity) AS dblQuantity, SUM(dblNetSales) AS dblNetSales, 
							SUM(dblTax) AS dblTax, SUM(dblAmount) AS dblAmount
						FROM (
							SELECT MT.intItemId
								, MT.intStoreId
								, AVG (MT.dblQuantity) AS dblQuantity
								, (AVG(MT.dblPrice) * AVG(MT.dblQuantity)) - SUM(MT.dblTax) AS dblNetSales
								, SUM (MT.dblTax) AS dblTax
								, AVG(MT.dblPrice) * AVG (MT.dblQuantity) AS dblAmount
								, MT.intInvoiceDetailId
							FROM @MainStore MT
							WHERE CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
								AND CAST(FLOOR(CAST(MT.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
								AND MT.intStoreId IN (SELECT Item FROM @tmpStores)
							GROUP BY MT.intItemId, MT.intStoreId, MT.intInvoiceDetailId
						) tmp GROUP BY intStoreId
					) T10 ON T0.intStoreId = T10.intStoreId
					INNER JOIN @SummaryTotalDetails T11 ON T0.intStoreId = T11.intStoreId
					WHERE ISNULL (T0.intInvoiceId,0) <> 0
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) >= CAST(FLOOR(CAST(@dtmFrom AS FLOAT)) AS DATETIME)
						AND CAST(FLOOR(CAST(T0.dtmCheckoutDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmTo AS FLOAT)) AS DATETIME)
						AND T0.intStoreId IN (SELECT Item FROM @tmpStores)
					GROUP BY T0.intStoreId
						, T5.ysnTaxExempt
						, T8.strType
						, T1.dblQuantity
						, T10.dblAmount
						, T11.dblNonTaxableTotalSales
						, T11.dblTaxableTotalSales
						, T5.dblTax
						, T5.dblSET
						, T8.strType
				) MT
				GROUP BY MT.intStoreId
					, MT.strType
					, MT.dblSET
					, MT.dblNonTaxable
					, MT.dblTaxable
			) T
			GROUP BY intStoreId
				, dblGrossSales
				, dblSSTRate
		) T
		GROUP BY intStoreId
			, dblGrossSales
			, dblSET
			, dblNonTaxable
			, dblTax
			, dblSSTRate
	END
	/********** Sales Tax Review End ***********/

END