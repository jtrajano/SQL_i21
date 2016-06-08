CREATE PROCEDURE [dbo].[uspTRProcessImportRackPrice]
	@ImportRackPriceId INT
AS

BEGIN

	SELECT *
	INTO #tmpValidRackPrices
	FROM tblTRImportRackPriceDetail
	WHERE intImportRackPriceId = @ImportRackPriceId
		AND ysnValid = 1

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpValidRackPrices)
	BEGIN	
		DECLARE @ImportRackPriceDetailId INT
			, @RackPriceId INT
			, @SupplyPointId INT
			, @EffectiveDate DATETIME
			, @Comments NVARCHAR(MAX)

		SELECT TOP 1 @ImportRackPriceDetailId = intImportRackPriceDetailId
			, @SupplyPointId = intSupplyPointId
			, @EffectiveDate = dtmEffectiveDate
			, @Comments = strComments
		FROM #tmpValidRackPrices

		INSERT INTO tblTRRackPriceHeader (
			intSupplyPointId
			, dtmEffectiveDateTime
			, strComments
		)
		VALUES (
			@SupplyPointId
			, @EffectiveDate
			, @Comments
		)

		SELECT @RackPriceId = SCOPE_IDENTITY()

		IF EXISTS(SELECT * FROM tblTRRackPriceHeader WHERE intRackPriceHeaderId = @RackPriceId)
		BEGIN		
			SELECT intImportRackPriceId = @RackPriceId
				, RackPriceDetail.intImportRackPriceDetailItemId
				, RackPriceDetail.intItemId
				, RackPriceDetail.dblVendorPrice
			INTO #tmpRackPriceDetails
			FROM tblTRImportRackPriceDetailItem RackPriceDetail
			LEFT JOIN tblTRImportRackPriceDetail RackPrice ON RackPrice.intImportRackPriceDetailId = RackPriceDetail.intImportRackPriceDetailId
			WHERE RackPrice.intImportRackPriceDetailId = @ImportRackPriceDetailId
				AND RackPriceDetail.ysnValid = 1

			WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRackPriceDetails)
			BEGIN
				DECLARE @RackPriceDetailId INT
					, @ItemId INT
					, @VendorPrice NUMERIC(18, 6)
					, @JobberPrice NUMERIC(18, 6)

				SELECT TOP 1 @RackPriceDetailId = intImportRackPriceDetailId, @ItemId = intItemId, @VendorPrice = dblVendorPrice, @JobberPrice = dblVendorPrice FROM #tmpRackPriceDetails

				SELECT
					intId = intSupplyPointRackPriceEquationId
					, strOperand
					, dblFactor
				INTO #tmpEquations
				FROM tblTRSupplyPointRackPriceEquation
				WHERE intSupplyPointId = @SupplyPointId
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
							SET @JobberPrice += @factor
						END
						ELSE IF (@operator = '-')
						BEGIN
							SET @JobberPrice -= @factor
						END
						ELSE IF (@operator = '*')
						BEGIN
							SET @JobberPrice *= @factor
						END
						ELSE IF (@operator = '/')
						BEGIN
							SET @JobberPrice /= @factor
						END
					END

					DELETE FROM #tmpEquations WHERE intId = @counter
				END

				INSERT INTO tblTRRackPriceDetail(
					intRackPriceHeaderId
					, intItemId
					, dblVendorRack
					, dblJobberRack
				)
				VALUES (
					@RackPriceId
					, @ItemId
					, @VendorPrice
					, @JobberPrice
				)

				DELETE FROM #tmpRackPriceDetails WHERE intImportRackPriceDetailItemId = @RackPriceDetailId
			END
		END

		DELETE FROM #tmpValidRackPrices
		WHERE intImportRackPriceDetailId = @ImportRackPriceDetailId
	END

	DELETE FROM tblTRImportRackPrice
	WHERE intImportRackPriceId = @ImportRackPriceId
END