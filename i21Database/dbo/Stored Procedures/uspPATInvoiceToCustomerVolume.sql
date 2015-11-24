CREATE PROCEDURE [dbo].[uspPATInvoiceToCustomerVolume]
	@intEntityCustomerId INT,
	@intInvoiceId INT,
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
				@UnitAmount NVARCHAR(50) = ''

		-- GET MEMBERSHIP DATE
		SET @dtmMembershipDate = (SELECT dtmMembershipDate FROM tblARCustomer where intEntityCustomerId = @intEntityCustomerId)
	
		IF(ISNULL(@dtmMembershipDate, 0) = 0)
		BEGIN -- NOT ELIGIBLE FOR PATRONAGE
			RETURN;
		END
		
		select 1
		-- CHECK IF ITEM IS LINKED TO PATRONAGE CATEGORY
		SELECT ARD.intItemId,
			   IC.intPatronageCategoryId,
			   PC.strUnitAmount
		  INTO #tempItem
		  FROM tblARInvoice AR
	INNER JOIN tblARInvoiceDetail ARD
			ON ARD.intInvoiceId = AR.intInvoiceId
	INNER JOIN tblICItem IC
			ON IC.intItemId = ARD.intItemId
	INNER JOIN tblPATPatronageCategory PC
			ON PC.intPatronageCategoryId = IC.intPatronageCategoryId
		 WHERE AR.intInvoiceId = @intInvoiceId
		 AND IC.intPatronageCategoryId IS NOT NULL


		IF NOT EXISTS(SELECT * FROM #tempItem)
		BEGIN
			DROP TABLE #tempItem
			RETURN;
		END
		ELSE
		BEGIN
			DECLARE @Total NUMERIC(16,8)

			SET @intPatronageCategoryId = (SELECT intPatronageCategoryId FROM #tempItem)
			SET @UnitAmount = (SELECT strUnitAmount FROM #tempItem)

			SET @intFiscalYear = (SELECT intFiscalYearId 
										FROM tblGLFiscalYear 
										WHERE (SELECT dtmDate 
												FROM tblARInvoice 
												WHERE intInvoiceId = @intInvoiceId) 
										BETWEEN dtmDateFrom AND dtmDateTo)
		
			IF(@UnitAmount = 'Amount')
			BEGIN
				SET @Total = (SELECT dblInvoiceTotal FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId)

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
						IF((SELECT dblVolume FROM [tblPATCustomerVolume] WHERE intCustomerPatronId = @intEntityCustomerId AND intPatronageCategoryId = @intPatronageCategoryId) = @Total)
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
				BEGIN
					INSERT INTO [tblPATCustomerVolume] (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dtmLastActivityDate, dblVolume, intConcurrencyId)
							VALUES (@intEntityCustomerId, @intPatronageCategoryId, @intFiscalYear, GETDATE(),  @Total, 1)
				END
			END
			ELSE
			BEGIN
					DECLARE @intItemId INT,
							@intItems INT,
							@intItemUOM INT,
							@Ret INT,
							@TotalUnit NUMERIC(38,6) = 0,
							@dblUnitQty NUMERIC(38,6),
							@ysnStockUnit BIT,
							@unitMeasureId INT

					SELECT UOM.dblUnitQty,
						   APD.dblQtyOrdered,
						   UOM.ysnStockUnit
					  INTO #tempUOM
					  FROM tblICItemUOM UOM
				INNER JOIN tblARInvoiceDetail APD
						ON APD.intItemId = UOM.intItemId
					 WHERE UOM.ysnStockUnit = 1
					   AND APD.intInvoiceId = @intInvoiceId

					IF NOT EXISTS(SELECT * FROM #tempUOM)
					BEGIN
						DROP TABLE #tempUOM
						RAISERROR('Conversion factor has to be setup between Item UOM and Patronage Category UOM in Inventory UOM maintenance', 16, 1);
						RETURN;
					END
					ELSE
					BEGIN
						SET @TotalUnit = (SELECT SUM(dblUnitQty * dblQtyOrdered) FROM #tempUOM)

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

					
			END
			DROP TABLE #tempItem
			DROP TABLE #tempUOM

		END

END

GO