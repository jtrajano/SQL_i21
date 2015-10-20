CREATE PROCEDURE [dbo].[uspPATBillToCustomerVolume] 
	@intEntityCustomerId INT,
	@intBillId INT,
	@ysnPosted BIT = NULL,
	@successfulCount INT = 0 OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


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
												FROM tblAPBill 
												WHERE intBillId = @intBillId) 
										BETWEEN dtmDateFrom AND dtmDateTo)

				IF(@UnitAmount = 'Unit')
				BEGIN
					DECLARE @intItemId INT,
							@intItems INT,
							@intItemUOM INT,
							@Ret INT,
							@TotalUnit NUMERIC(38,6) = 0,
							@dblUnitQty NUMERIC(38,6),
							@ysnStockUnit BIT,
							@unitMeasureId INT

					SELECT * 
					  INTO #tempUOM
					  FROM tblICItemUOM 
					 WHERE intItemId in (SELECT intItemId FROM tblAPBillDetail WHERE intBillId = @intBillId)
					   AND intUnitMeasureId = @UOM
					
					IF EXISTS(SELECT * FROM #tempUOM)
					BEGIN
						DECLARE Cursor_Unit CURSOR FOR 	
						 SELECT DISTINCT intItemId, intItemUOMId, dblUnitQty, ysnStockUnit, @unitMeasureId FROM #tempUOM
						   OPEN Cursor_Unit
						  FETCH NEXT FROM Cursor_Unit into @intItems, @intItemUOM, @dblUnitQty, @ysnStockUnit, @unitMeasureId
						  WHILE (@@FETCH_STATUS <> -1)
						  BEGIN
								SET @TotalUnit = @TotalUnit + @dblUnitQty
								FETCH NEXT FROM Cursor_Unit into @intItems, @intItemUOM, @dblUnitQty, @ysnStockUnit, @unitMeasureId
						  END
						CLOSE Cursor_Unit
						DEALLOCATE Cursor_Unit

						IF EXISTS(SELECT * FROM [tblPATCustomerVolume] WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId)
						BEGIN

							IF(@ysnPosted = 1)
							BEGIN
								UPDATE [tblPATCustomerVolume]
								   SET dblVolume = dblVolume + @TotalUnit
								 WHERE intCustomerPatronId = @intEntityCustomerId
								   AND intPatronageCategoryId = @intPatronageCategoryId
							END
							ELSE
							BEGIN
								IF((SELECT dblVolume FROM [tblPATCustomerVolume] WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId) = @TotalUnit)
								BEGIN
									DELETE FROM [tblPATCustomerVolume] 
									 WHERE intCustomerPatronId = @intEntityCustomerId
									   AND intPatronageCategoryId = @intPatronageCategoryId
								END
								ELSE
								BEGIN
									UPDATE [tblPATCustomerVolume]
									   SET dblVolume = dblVolume - @TotalUnit
									 WHERE intCustomerPatronId = @intEntityCustomerId
									   AND intPatronageCategoryId = @intPatronageCategoryId
								END
							END
						
						END
						ELSE
						BEGIN
							INSERT INTO [tblPATCustomerVolume] (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dtmLastActivityDate, dblVolume, intConcurrencyId)
								 VALUES (@intEntityCustomerId, @intPatronageCategoryId, @intFiscalYear, GETDATE(), @TotalUnit, 1)
						END

						DROP TABLE #tempUOM
					END
					ELSE
					BEGIN
						SELECT * 
						  INTO #temp
						  FROM tblICItemUOM 
						 WHERE intItemId in (SELECT intItemId FROM tblAPBillDetail WHERE intBillId = @intBillId)
						   AND ysnStockUnit = 1 AND intUnitMeasureId <> @UOM

						IF NOT EXISTS(SELECT * FROM #temp)
						BEGIN
							RAISERROR('Conversion factor has to be setup between Item UOM and Patronage Category UOM in Inventory UOM maintenance', 16, 1);
							RETURN;
						END
						ELSE
						BEGIN
							DECLARE @tempCount INT,
									@itemCount INT
									
								SET @tempCount = (SELECT COUNT(intItemId) FROM #temp)
								SET @itemCount = (SELECT COUNT(intItemId) FROM tblAPBillDetail WHERE intBillId = @intBillId)

							IF(@tempCount <> @itemCount)
							BEGIN
								RAISERROR('Conversion factor has to be setup between Item UOM and Patronage Category UOM in Inventory UOM maintenance', 16, 1);
								RETURN;
							END
							ELSE
							BEGIN
								DECLARE U_Cursor CURSOR FOR 	
								 SELECT DISTINCT intItemId, intItemUOMId, dblUnitQty, ysnStockUnit, @unitMeasureId FROM #temp
								   OPEN U_Cursor
								  FETCH NEXT FROM U_Cursor into @intItems, @intItemUOM, @dblUnitQty, @ysnStockUnit, @unitMeasureId
								  WHILE (@@FETCH_STATUS <> -1)
								  BEGIN
										SELECT DISTINCT intItemId FROM tblICItemUOM WHERE intItemId IN (SELECT intItemId FROM tblAPBillDetail WHERE intBillId = @intBillId)
									
									
										SET @TotalUnit = @TotalUnit + (SELECT dbo.fnCalculateQtyBetweenUOM(@intItemUOM, @UOM, @dblUnitQty))
										FETCH NEXT FROM U_Cursor into @intItems, @intItemUOM, @dblUnitQty, @ysnStockUnit, @unitMeasureId
								  END
								CLOSE U_Cursor
								DEALLOCATE U_Cursor

								IF EXISTS(SELECT * FROM [tblPATCustomerVolume] WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId)
								BEGIN

									IF(@ysnPosted = 1)
									BEGIN
										UPDATE [tblPATCustomerVolume]
										   SET dblVolume = dblVolume + @TotalUnit
										 WHERE intCustomerPatronId = @intEntityCustomerId
										   AND intPatronageCategoryId = @intPatronageCategoryId
									END
									ELSE
									BEGIN
										IF((SELECT dblVolume FROM [tblPATCustomerVolume] WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId) = @TotalUnit)
										BEGIN
											DELETE FROM [tblPATCustomerVolume] 
											 WHERE intCustomerPatronId = @intEntityCustomerId
											   AND intPatronageCategoryId = @intPatronageCategoryId
										END
										ELSE
										BEGIN
											UPDATE [tblPATCustomerVolume]
											   SET dblVolume = dblVolume - @TotalUnit
											 WHERE intCustomerPatronId = @intEntityCustomerId
											   AND intPatronageCategoryId = @intPatronageCategoryId
										END
									END
						
								END
								ELSE
								BEGIN
									INSERT INTO [tblPATCustomerVolume] (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dtmLastActivityDate, dblVolume, intConcurrencyId)
										 VALUES (@intEntityCustomerId, @intPatronageCategoryId, @intFiscalYear, GETDATE(), @TotalUnit, 1)
								END
							END

							DROP TABLE #temp
						END	
					END
				END
				ELSE
				BEGIN

					SET @Total = (SELECT dblTotal FROM tblAPBill WHERE intBillId = @intBillId)

					IF EXISTS(SELECT * FROM [tblPATCustomerVolume] WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId)
					BEGIN
						IF(@ysnPosted = 1)
						BEGIN
							UPDATE [tblPATCustomerVolume]
							   SET dblVolume = (dblVolume + @Total)
							 WHERE intCustomerPatronId = @intEntityCustomerId
							   AND intPatronageCategoryId = @intPatronageCategoryId
						END
						ELSE
						BEGIN
							IF((SELECT dblVolume FROM [tblPATCustomerVolume] WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId) = @TotalUnit)
							BEGIN
								DELETE FROM [tblPATCustomerVolume] 
									WHERE intCustomerPatronId = @intEntityCustomerId
									AND intPatronageCategoryId = @intPatronageCategoryId
							END
							ELSE
							BEGIN
								UPDATE [tblPATCustomerVolume]
									SET dblVolume = dblVolume - @Total
									WHERE intCustomerPatronId = @intEntityCustomerId
									AND intPatronageCategoryId = @intPatronageCategoryId
							END
						END
					END
					ELSE
						INSERT INTO [tblPATCustomerVolume] (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dtmLastActivityDate, dblVolume, intConcurrencyId)
							 VALUES (@intEntityCustomerId, @intPatronageCategoryId, @intFiscalYear,  GETDATE(), @Total, 1)
					END
			END
		END
		DROP TABLE #tempTable
END
GO

