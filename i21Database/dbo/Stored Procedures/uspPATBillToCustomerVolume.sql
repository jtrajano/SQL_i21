CREATE PROCEDURE [dbo].[uspPATBillToCustomerVolume] 
	@intEntityCustomerId INT,
	@intBillId INT,
	@ysnPosted BIT,
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
		DECLARE @strStockStatus NVARCHAR(50),
				@intFiscalYear INT


			
		-- GET STOCK STATUS
		SET @strStockStatus = (SELECT strStockStatus FROM tblARCustomer where [intEntityId] = @intEntityCustomerId)
	
		IF(@strStockStatus = '' OR @strStockStatus IS NULL)
		BEGIN -- NOT ELIGIBLE FOR PATRONAGE
			RETURN;
		END

		SET @intFiscalYear = (SELECT intFiscalYearId 
										FROM tblGLFiscalYear 
										WHERE (SELECT dtmDate 
												FROM tblAPBill 
												WHERE intBillId = @intBillId) 
										BETWEEN dtmDateFrom AND dtmDateTo)
							
		IF(@intFiscalYear IS NULL)
		BEGIN -- INVALID
			RETURN;
		END
		
		-- CHECK IF ITEM IS LINKED TO PATRONAGE CATEGORY
		SELECT	AB.intEntityVendorId,
			IC.intPatronageCategoryId,
			AB.ysnPosted,
			dblVolume = SUM(CASE WHEN PC.strUnitAmount = 'Amount' THEN (CASE WHEN ABD.dblQtyReceived <= 0 THEN 0 ELSE (ABD.dblQtyReceived * ABD.dblCost) END) 
						ELSE ABD.dblQtyReceived * UOM.dblUnitQty END),
			@intFiscalYear as fiscalYear
			INTO #tempItem
			FROM tblAPBill AB
		INNER JOIN tblAPBillDetail ABD
				ON ABD.intBillId = AB.intBillId
		INNER JOIN tblICItem IC
				ON IC.intItemId = ABD.intItemId
		INNER JOIN (SELECT	dblUnitQty = CASE WHEN dblUnitQty <= 0 THEN 1 ELSE dblUnitQty END,
							intItemId,
							intItemUOMId,
							ysnStockUnit
							FROM tblICItemUOM WHERE ysnStockUnit = 1
							UNION
					SELECT	dblUnitQty = CASE WHEN A.dblUnitQty <= 0 THEN 1 ELSE A.dblUnitQty END,
							A.intItemId,
							A.intItemUOMId,
							A.ysnStockUnit
							FROM tblICItemUOM A
							INNER JOIN tblAPBillDetail B ON B.intUnitOfMeasureId = A.intItemUOMId) UOM
				ON UOM.intItemId = ABD.intItemId
		INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = IC.intPatronageCategoryId
				AND PC.strPurchaseSale = 'Purchase'
				WHERE AB.intBillId = @intBillId
				AND IC.intPatronageCategoryId IS NOT NULL
				GROUP BY AB.intEntityVendorId,
					IC.intPatronageCategoryId,
					AB.ysnPosted

		IF NOT EXISTS(SELECT * FROM #tempItem)
		BEGIN

			DROP TABLE #tempItem
			RETURN;
		END
		ELSE
		BEGIN
			
			UPDATE tblARCustomer SET dtmLastActivityDate = GETDATE() 
				WHERE [intEntityId] IN (SELECT intEntityVendorId FROM #tempItem)

			MERGE tblPATCustomerVolume AS PAT
			USING #tempItem AS B
			   ON (PAT.intCustomerPatronId = B.intEntityVendorId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId AND PAT.intFiscalYear = B.fiscalYear AND PAT.ysnRefundProcessed <> 1)
			 --WHEN MATCHED AND B.ysnPosted = 0 AND PAT.dblVolume = B.dblVolume
				--THEN DELETE
			 WHEN MATCHED
				  THEN UPDATE SET PAT.dblVolume = CASE WHEN B.ysnPosted = 1 THEN (PAT.dblVolume + B.dblVolume) 
													   ELSE (PAT.dblVolume - B.dblVolume) END
			 WHEN NOT MATCHED BY TARGET
				  THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dblVolume, intConcurrencyId)
					   VALUES (B.intEntityVendorId, B.intPatronageCategoryId, @intFiscalYear,  B.dblVolume, 1);

			DROP TABLE #tempItem
		END
		
END

GO