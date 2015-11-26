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
		DECLARE @dtmMembershipDate DATETIME,
				@intFiscalYear INT

		-- CHECK IF CUSTOMER IS PATRON
		SET @dtmMembershipDate = (SELECT dtmMembershipDate FROM tblARCustomer where intEntityCustomerId = @intEntityCustomerId)
	
		IF(ISNULL(@dtmMembershipDate, 0) = 0)
		BEGIN -- NOT ELIGIBLE FOR PATRONAGE
			RETURN;
		END

		-- CHECK IF ITEM IS LINKED TO PATRONAGE CATEGORY
		SELECT AB.intEntityVendorId,
			   ABD.intItemId,
			   IC.intPatronageCategoryId,
			   PC.strUnitAmount,
			   ABD.dblQtyOrdered,
			   ABD.dblCost,
			   ICU.dblUnitQty,
			   AB.ysnPosted,
			   dblVolume = CASE WHEN PC.strUnitAmount = 'Amount' THEN (ABD.dblQtyOrdered * ABD.dblCost) 
						   ELSE (ABD.dblQtyOrdered * ICU.dblUnitQty) END
		  INTO #tempItem
		  FROM tblAPBill AB
	INNER JOIN tblAPBillDetail ABD
			ON ABD.intBillId = AB.intBillId
	INNER JOIN tblICItem IC
			ON IC.intItemId = ABD.intItemId
	INNER JOIN tblICItemUOM ICU
			ON ICU.intItemId = IC.intItemId
	INNER JOIN tblPATPatronageCategory PC
			ON PC.intPatronageCategoryId = IC.intPatronageCategoryId
		 WHERE AB.intBillId = @intBillId
		   AND IC.intPatronageCategoryId IS NOT NULL
		   AND ICU.ysnStockUnit = 1 -- Confirm with sir Ajith

		IF NOT EXISTS(SELECT * FROM #tempItem)
		BEGIN
			DROP TABLE #tempItem
			RETURN;
		END
		ELSE
		BEGIN

			SET @intFiscalYear = (SELECT intFiscalYearId 
									FROM tblGLFiscalYear 
									WHERE (SELECT dtmDate 
											FROM tblAPBill 
											WHERE intBillId = @intBillId) 
									BETWEEN dtmDateFrom AND dtmDateTo)
			
			
				
			
			MERGE tblPATCustomerVolume AS PAT
			USING #tempItem AS B
			   ON (PAT.intCustomerPatronId = B.intEntityVendorId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId)
			 WHEN MATCHED AND B.ysnPosted = 0 AND PAT.dblVolume = B.dblVolume
				  THEN DELETE
			 WHEN MATCHED
				  THEN UPDATE SET PAT.dblVolume = CASE WHEN B.ysnPosted = 1 THEN (PAT.dblVolume + B.dblVolume) 
													   ELSE (PAT.dblVolume - B.dblVolume) END
			 WHEN NOT MATCHED BY TARGET
				  THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dtmLastActivityDate, dblVolume, intConcurrencyId)
					   VALUES (B.intEntityVendorId, B.intPatronageCategoryId, @intFiscalYear, GETDATE(),  B.dblVolume, 1);

			DROP TABLE #tempItem
		END
		
END


GO