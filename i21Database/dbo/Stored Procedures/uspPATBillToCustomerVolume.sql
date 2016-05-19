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
		DECLARE @strStockStatus NVARCHAR(50), @strPreferedStockStatus NVARCHAR(50), @intFiscalYear INT, @intEligible INT

		-- GET STOCK STATUS
		SET @strStockStatus = (SELECT strStockStatus FROM tblARCustomer where intEntityCustomerId = @intEntityCustomerId)

		IF(@strStockStatus = '' OR @strStockStatus IS NULL)
		BEGIN -- NOT ELIGIBLE FOR PATRONAGE
			RETURN;
		END

		-- GET STOCK STATUS FROM PREFERENCE
		SET @strPreferedStockStatus = (SELECT strRefund FROM tblPATCompanyPreference)

		CREATE TABLE #statusTable ( strStockStatus NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL )

		IF(@strPreferedStockStatus = 'A')
		BEGIN
			DELETE FROM #statusTable
			INSERT INTO #statusTable VALUES ('Voting');
			INSERT INTO #statusTable VALUES ('Non-Voting');
			INSERT INTO #statusTable VALUES ('Producer');
			INSERT INTO #statusTable VALUES ('Other');
		END
		ELSE IF(@strPreferedStockStatus = 'S')
		BEGIN
			DELETE FROM #statusTable
			INSERT INTO #statusTable VALUES ('Voting');
			INSERT INTO #statusTable VALUES ('Non-Voting');
		END
		ELSE IF(@strPreferedStockStatus = 'V')
		BEGIN
			DELETE FROM #statusTable
			INSERT INTO #statusTable VALUES ('Voting');
		END
		
		SET @intEligible = CASE WHEN @strStockStatus IN (SELECT strStockStatus FROM #statusTable) THEN 1 ELSE 0 END

		DROP TABLE #statusTable

		IF( @intEligible = 0 )
		BEGIN -- NOT ELIGIBLE FOR PATRONAGE
			RETURN;
		END

		SET @intFiscalYear = (SELECT intFiscalYearId 
										FROM tblGLFiscalYear 
										WHERE (SELECT dtmDate 
												FROM tblAPBill 
												WHERE intBillId = @intBillId) 
										BETWEEN dtmDateFrom AND dtmDateTo)

		-- CHECK IF ITEM IS LINKED TO PATRONAGE CATEGORY
		SELECT AB.intEntityVendorId,
			   IC.intPatronageCategoryId,
			   AB.ysnPosted,
			   dblVolume = sum (CASE WHEN PC.strUnitAmount = 'Amount' THEN (ABD.dblQtyReceived * ABD.dblCost) 
						   ELSE (ABD.dblQtyReceived * ICU.dblUnitQty) END),
						   @intFiscalYear as fiscalYear
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
		   AND PC.strPurchaseSale = 'Purchase'
		 WHERE AB.intBillId = @intBillId
		   AND IC.intPatronageCategoryId IS NOT NULL
		   AND ICU.ysnStockUnit = 1 -- Confirm with sir Ajith
		   group by AB.intEntityVendorId,
			   IC.intPatronageCategoryId,
			   AB.ysnPosted

		IF NOT EXISTS(SELECT * FROM #tempItem)
		BEGIN

			DROP TABLE #tempItem
			RETURN;
		END
		ELSE
		BEGIN
			

			--select * from #tempItem
			MERGE tblPATCustomerVolume AS PAT
			USING #tempItem AS B
			   ON (PAT.intCustomerPatronId = B.intEntityVendorId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId AND PAT.intFiscalYear = B.fiscalYear)
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