CREATE PROCEDURE [dbo].[usp_PATInvoiceToCategoryVolume] 
	@intEntityCustomerId INT,
	@intInvoiceId INT,
	@ysnPosted BIT = NULL
AS
BEGIN
	-- VARIABLES NEEDED 
DECLARE @dtmMembershipDate DATETIME,
		@intFiscalYear INT,
		@intPatronageCategoryId INT,
		@UOM NVARCHAR(50) = '',
		@UnitAmount NVARCHAR(50) = ''

		-- GET MEMBERSHIP DATE
		SET @dtmMembershipDate = (SELECT dtmMembershipDate FROM tblARCustomer where intEntityCustomerId = @intEntityCustomerId)
	
		IF(ISNULL(@dtmMembershipDate, 0) = 0)
		BEGIN -- NOT ELIGIBLE FOR PATRONAGE
			DROP TABLE #tempTable
			RETURN
		END
		ELSE
		BEGIN
			SELECT EC.intEstateCorporationId
					   ,EC.intCorporateCustomerId
					   ,RR.intRefundTypeId
					   ,RR.strRefundType
					   ,RRD.intRefundTypeDetailId
					   ,PC.intPatronageCategoryId
					   ,PC.strCategoryCode
					   ,PC.strPurchaseSale
					   ,PC.strUnitAmount
					   ,PC.intUnitMeasureId
				  INTO #tempTable
				  FROM tblPATEstateCorporation EC
			INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = EC.intRefundTypeId
			INNER JOIN tblPATRefundRateDetail RRD
					ON RRD.intRefundTypeId = RR.intRefundTypeId
			INNER JOIN tblPATPatronageCategory PC
					ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
				 WHERE intCorporateCustomerId = @intEntityCustomerId
			
			IF NOT EXISTS (SELECT * FROM #tempTable)
			BEGIN -- NOT LINKED TO PATRONAGE CATEGORY, RETURN
				DROP TABLE #tempTable
				RETURN;
			END
			ELSE
			BEGIN
				DECLARE @Total NUMERIC(16,8)

				SET @intPatronageCategoryId = (SELECT intPatronageCategoryId FROM #tempTable)
				SET @UOM = (SELECT intUnitMeasureId FROM #tempTable)
				SET @UnitAmount = (SELECT strUnitAmount FROM #tempTable)

				SET @intFiscalYear = (SELECT intFiscalYearId 
										FROM tblGLFiscalYear 
										WHERE (SELECT dtmDate 
												FROM tblARInvoice 
												WHERE intInvoiceId = @intInvoiceId) 
										BETWEEN dtmDateFrom AND dtmDateTo)

				IF(@UnitAmount = 'Unit')
				BEGIN
					DECLARE @intItemId INT,
							@intItems INT,
							@intItemUOM INT,
							@Ret INT,
							@TotalUnit NUMERIC(38,6) = 0,
							@dblUnitQty NUMERIC(38,6)

					SELECT * 
					  INTO #tempUOM
					  FROM tblICItemUOM 
					 WHERE intItemId in (SELECT intItemId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId)
					   AND ysnStockUnit = 1
					
					DECLARE Cursor_Unit CURSOR FOR 	
					 SELECT DISTINCT intItemId, intItemUOMId, dblUnitQty FROM #tempUOM
					   OPEN Cursor_Unit
					  FETCH NEXT FROM Cursor_Unit into @intItems, @intItemUOM, @dblUnitQty 
					  WHILE (@@FETCH_STATUS <> -1)
					  BEGIN
						IF EXISTS(SELECT * FROM tblICItemUOM WHERE intItemId = @intItems AND intUnitMeasureId = @UOM)
						BEGIN
							SET @TotalUnit = @TotalUnit + @dblUnitQty
						END
						ELSE
						BEGIN
							SET @TotalUnit = @TotalUnit + (SELECT dbo.fnCalculateQtyBetweenUOM(@intItemUOM, @UOM, @dblUnitQty))
						END
							
					  FETCH NEXT FROM Cursor_Unit into @intItems, @intItemUOM, @dblUnitQty
					  END

					  CLOSE Cursor_Unit
				 DEALLOCATE Cursor_Unit
					
					IF EXISTS(SELECT * FROM tblPATCategoryVolume WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId)
					BEGIN
						UPDATE tblPATCategoryVolume
						   SET dblVolume = dblVolume + @TotalUnit
						 WHERE intCustomerPatronId = @intEntityCustomerId
						   AND intPatronageCategoryId = @intPatronageCategoryId
					END
					ELSE
					BEGIN
						INSERT INTO tblPATCategoryVolume
							 VALUES (@intEntityCustomerId, @intPatronageCategoryId, @intFiscalYear, @TotalUnit, 1)
					END

					DROP TABLE #tempUOM
				END
				ELSE
				BEGIN

					SET @Total = (SELECT dblInvoiceTotal FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId)

					IF EXISTS(SELECT * FROM tblPATCategoryVolume WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId)
					BEGIN
						UPDATE tblPATCategoryVolume
						   SET dblVolume = (dblVolume + @Total)
						 WHERE intCustomerPatronId = @intEntityCustomerId
						   AND intPatronageCategoryId = @intPatronageCategoryId
					END
					ELSE
						INSERT INTO tblPATCategoryVolume
							 VALUES (@intEntityCustomerId, @intPatronageCategoryId, @intFiscalYear, @Total, 1)
					END
			END
		END
		DROP TABLE #tempTable
END


GO