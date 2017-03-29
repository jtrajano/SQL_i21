CREATE PROCEDURE [dbo].[uspPATGatherVolumeForPatronage]
	@transactionIds NVARCHAR(MAX) = NULL,
	@post BIT = NULL,
	@type INT = NULL, -- Reference: 1 => Voucher(Purchase), 2 => Invoice(Sale)
	@successfulCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT 
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @totalRecords INT = 0;
	DECLARE @error NVARCHAR(MAX);

	SELECT [intID] 
	INTO #tempTranscationIds
	FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	IF(@type = 1)
	BEGIN
		SELECT	intCustomerPatronId = AB.intEntityVendorId,
				IC.intPatronageCategoryId,
				ysnPosted = @post,
				FY.intFiscalYearId,
				dblVolume = SUM(CASE WHEN PC.strUnitAmount = 'Amount' THEN (CASE WHEN ABD.dblQtyReceived <= 0 THEN 0 ELSE (ABD.dblQtyReceived * ABD.dblCost) END) 
							ELSE ABD.dblQtyReceived * UOM.dblUnitQty END)
				INTO #tempPatronageVolumes
				FROM tblAPBill AB
				INNER JOIN tblAPBillDetail ABD
						ON ABD.intBillId = AB.intBillId
				INNER JOIN tblARCustomer ARC
						ON ARC.[intEntityId] = AB.intEntityVendorId AND ARC.strStockStatus != ''
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
					ON PC.intPatronageCategoryId = IC.intPatronageCategoryId AND PC.strPurchaseSale = 'Purchase'
				CROSS APPLY tblGLFiscalYear FY
		WHERE AB.intBillId IN (SELECT intID FROM #tempTranscationIds) AND AB.dtmDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
		AND IC.intPatronageCategoryId IS NOT NULL
		GROUP BY AB.intEntityVendorId,
		IC.intPatronageCategoryId,
		FY.intFiscalYearId,
		AB.ysnPosted
	END
	ELSE IF(@type = 2)
	BEGIN
			SELECT	intCustomerPatronId = AR.intEntityCustomerId,
					IC.intPatronageCategoryId,
					ysnPosted = @post,
					dblVolume =	SUM(CASE WHEN PC.strUnitAmount = 'Amount' THEN (CASE WHEN ARD.dblQtyShipped <= 0 THEN 0 ELSE (ARD.dblQtyShipped * ARD.dblPrice) END)
								ELSE (CASE WHEN ICU.dblUnitQty <= 0 THEN ARD.dblQtyShipped ELSE (ARD.dblQtyShipped * ICU.dblUnitQty) END ) END),
					FY.intFiscalYearId
				INTO #tempItem
				FROM tblARInvoice AR
				INNER JOIN tblARInvoiceDetail ARD
						ON ARD.intInvoiceId = AR.intInvoiceId
				INNER JOIN tblICItem IC
						ON IC.intItemId = ARD.intItemId
				INNER JOIN tblICItemUOM ICU
						ON ICU.intItemId = IC.intItemId
						AND ICU.intItemUOMId = ARD.intItemUOMId
				INNER JOIN tblPATPatronageCategory PC
						ON PC.intPatronageCategoryId = IC.intPatronageCategoryId AND PC.strPurchaseSale = 'Sale'
				CROSS APPLY tblGLFiscalYear FY
	WHERE AR.intInvoiceId IN (SELECT intID FROM #tempTranscationIds) AND AR.dtmDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
		   AND IC.intPatronageCategoryId IS NOT NULL
		   GROUP BY AR.intEntityCustomerId,
			   IC.intPatronageCategoryId,
			   AR.ysnPosted
	END

	IF NOT EXISTS(SELECT * FROM #tempPatronageVolumes)
	BEGIN
		GOTO Post_Exit
	END

	BEGIN TRANSACTION

	UPDATE tblARCustomer SET dtmLastActivityDate = GETDATE() 
	WHERE [intEntityId] IN (SELECT intCustomerPatronId FROM #tempPatronageVolumes)

	BEGIN TRY
	MERGE tblPATCustomerVolume AS PAT
	USING #tempPatronageVolumes AS B
		ON (PAT.intCustomerPatronId = B.intCustomerPatronId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId AND PAT.intFiscalYear = B.intFiscalYearId AND PAT.ysnRefundProcessed <> 1)
		WHEN MATCHED
			THEN UPDATE SET PAT.dblVolume = CASE WHEN B.ysnPosted = 1 THEN (PAT.dblVolume + B.dblVolume) 
												ELSE (PAT.dblVolume - B.dblVolume) END
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dblVolume, intConcurrencyId)
				VALUES (B.intCustomerPatronId, B.intPatronageCategoryId, B.intFiscalYearId,  B.dblVolume, 1);

	SELECT @totalRecords = COUNT(*) FROM #tempPatronageVolumes
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END CATCH

	GOTO Post_Commit

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0 
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempPatronageVolumes')) DROP TABLE #tempPatronageVolumes
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempTranscationIds')) DROP TABLE #tempTranscationIds
END
---------------------------------------------------------------------------------------------------------------------------------------
GO