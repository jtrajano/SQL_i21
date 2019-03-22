CREATE PROCEDURE [uspTRFixRackPrices]
	@ForceValue BIT = 0
	, @SupplyPointId INT = NULL

AS

BEGIN

	SELECT Detail.intRackPriceDetailId
		, Header.intSupplyPointId
		, Detail.intItemId
		, Detail.dblVendorRack
	INTO #tmpRackPrices
	FROM tblTRRackPriceHeader Header
	LEFT JOIN tblTRRackPriceDetail Detail ON Detail.intRackPriceHeaderId = Header.intRackPriceHeaderId
	WHERE ISNULL(Detail.intRackPriceDetailId, '') <> ''
		AND Header.intSupplyPointId = ISNULL(@SupplyPointId, Header.intSupplyPointId)

	DECLARE @RackPriceDetailId INT
		, @SupplyPoint INT
		, @ItemId INT
		, @Value NUMERIC(18, 6)

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpRackPrices)
	BEGIN
		
		SELECT TOP 1 @RackPriceDetailId = intRackPriceDetailId
			, @SupplyPoint = intSupplyPointId
			, @ItemId = intItemId
			, @Value = dblVendorRack
		FROM #tmpRackPrices

		SELECT
			intId = intSupplyPointRackPriceEquationId
			, strOperand
			, dblFactor
		INTO #tmpEquations
		FROM tblTRSupplyPointRackPriceEquation
		WHERE intSupplyPointId = @SupplyPoint
			AND intItemId = @ItemId
		ORDER BY intSupplyPointRackPriceEquationId

		DECLARE @counter INT
			, @operator NVARCHAR(10)
			, @factor NUMERIC(18, 6)

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpEquations)
		BEGIN
			SELECT TOP 1 @counter = intId
				, @operator = strOperand
				, @factor = dblFactor
			FROM #tmpEquations

			IF (ISNULL(@operator, '') <> '')
			BEGIN
				IF (@operator = '+')
				BEGIN
					SET @Value += @factor
				END
				ELSE IF (@operator = '-')
				BEGIN
					SET @Value -= @factor
				END
				ELSE IF (@operator = '*')
				BEGIN
					SET @Value *= @factor
				END
				ELSE IF (@operator = '/')
				BEGIN
					SET @Value /= @factor
				END
			END

			DELETE FROM #tmpEquations WHERE intId = @counter
		END

		IF (@ForceValue = 1)
		BEGIN
			UPDATE tblTRRackPriceDetail
			SET dblJobberRack = @Value
			WHERE intRackPriceDetailId = @RackPriceDetailId
				AND intItemId = @ItemId
		END
		ELSE
		BEGIN
			UPDATE tblTRRackPriceDetail
			SET dblJobberRack = @Value
			WHERE intRackPriceDetailId = @RackPriceDetailId
				AND intItemId = @ItemId
				AND ISNULL(dblJobberRack, 0) = 0
		END
		

		DROP TABLE #tmpEquations

		DELETE FROM #tmpRackPrices WHERE intRackPriceDetailId = @RackPriceDetailId
	END

	DROP TABLE #tmpRackPrices

END