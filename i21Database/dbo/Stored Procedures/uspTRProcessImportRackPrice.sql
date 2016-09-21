CREATE PROCEDURE [dbo].[uspTRProcessImportRackPrice]
	@ImportRackPriceId INT
AS

BEGIN

	SELECT *
	INTO #tmpValidRackPrices
	FROM tblTRImportRackPriceDetail
	WHERE intImportRackPriceId = @ImportRackPriceId
		AND ysnValid = 1

	DECLARE @COUNT INT

	SELECT @COUNT = COUNT(*) FROM #tmpValidRackPrices

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

		SET @RackPriceId = NULL
		SELECT TOP 1 @RackPriceId = intRackPriceHeaderId FROM tblTRRackPriceHeader WHERE intSupplyPointId = @SupplyPointId AND dtmEffectiveDateTime = @EffectiveDate


		IF (ISNULL(@RackPriceId, '') = '')
		BEGIN
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
		END		

		IF EXISTS(SELECT TOP 1 1 FROM tblTRRackPriceHeader WHERE intRackPriceHeaderId = @RackPriceId)
		BEGIN		
			SELECT intImportRackPriceId = @RackPriceId
				, RackPriceDetail.intImportRackPriceDetailItemId
				, RackPriceDetail.intImportRackPriceDetailId
				, RackPriceDetail.intItemId
				, RackPriceDetail.dblVendorPrice
			INTO #tmpRackPriceDetails
			FROM tblTRImportRackPriceDetailItem RackPriceDetail
			LEFT JOIN tblTRImportRackPriceDetail RackPrice ON RackPrice.intImportRackPriceDetailId = RackPriceDetail.intImportRackPriceDetailId
			WHERE RackPrice.intImportRackPriceDetailId = @ImportRackPriceDetailId
				AND RackPriceDetail.ysnValid = 1

			SELECT @COUNT = COUNT(*) FROM #tmpRackPriceDetails

			WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRackPriceDetails)
			BEGIN
				DECLARE @RackPriceDetailItemId INT
					, @ItemId INT
					, @VendorPrice NUMERIC(18, 6)
					, @JobberPrice NUMERIC(18, 6)

				SELECT TOP 1 @RackPriceDetailItemId = intImportRackPriceDetailItemId, @ItemId = intItemId, @VendorPrice = dblVendorPrice, @JobberPrice = dblVendorPrice FROM #tmpRackPriceDetails

				SELECT
					intId = intSupplyPointRackPriceEquationId
					, strOperand
					, dblFactor
				INTO #tmpEquations
				FROM tblTRSupplyPointRackPriceEquation
				WHERE intSupplyPointId = @SupplyPointId
					AND intItemId = @ItemId
				ORDER BY intSupplyPointRackPriceEquationId

				SELECT @COUNT = COUNT(*) FROM #tmpEquations

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

				IF EXISTS(SELECT TOP 1 1 FROM tblTRRackPriceDetail WHERE intRackPriceHeaderId = @RackPriceId AND intItemId = @ItemId)
				BEGIN
					UPDATE tblTRRackPriceDetail
					SET dblVendorRack = @VendorPrice
						, dblJobberRack = @JobberPrice
					WHERE intRackPriceHeaderId = @RackPriceId AND intItemId = @ItemId
				END
				ELSE
				BEGIN
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
				END

				DELETE FROM #tmpRackPriceDetails WHERE intImportRackPriceDetailItemId = @RackPriceDetailItemId

				DROP TABLE #tmpEquations
			END

			DROP TABLE #tmpRackPriceDetails
		END

		DELETE FROM #tmpValidRackPrices
		WHERE intImportRackPriceDetailId = @ImportRackPriceDetailId
	END

	DELETE FROM tblTRImportRackPrice
	WHERE intImportRackPriceId = @ImportRackPriceId

	DROP TABLE #tmpValidRackPrices
END