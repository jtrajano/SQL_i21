CREATE PROCEDURE [dbo].[uspPATGatherVolumeForPatronage]
	@transactionIds NVARCHAR(MAX) = NULL,
	@post BIT = NULL,
	@type INT = NULL, -- Reference: 1 => Voucher(Purchase), 2 => Invoice(Sale)
	@successfulCount INT = 0 OUTPUT
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @totalRecords INT = 0;
	DECLARE @error NVARCHAR(MAX);

	DECLARE @tempTransactionIds TABLE(
		[intID] INT
	);

	DECLARE @TransactionName AS VARCHAR(500) = 'GATHERING PATRONAGE VOLUME' + CAST(NEWID() AS NVARCHAR(100));

	DECLARE @tempPatronageVolumes TABLE(
		[intCustomerPatronId] INT,
		[intPatronageCategoryId] INT,
		[ysnPosted] BIT,
		[intFiscalYearId] INT,
		[dblVolume] NUMERIC(18,6)
	)

	INSERT INTO @tempTransactionIds
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	BEGIN TRAN @TransactionName;
	SAVE TRAN @TransactionName;

	BEGIN TRY
	IF(@type = 1)
	BEGIN
			INSERT INTO @tempPatronageVolumes
			SELECT	intCustomerPatronId = AB.intEntityVendorId,
			IC.intPatronageCategoryId,
			ysnPosted = @post,
			FY.intFiscalYearId,
			dblVolume = ROUND(SUM(CASE WHEN PC.strUnitAmount = 'Amount' THEN (CASE WHEN ABD.dblQtyReceived <= 0 THEN 0 ELSE (ABD.dblQtyReceived * ABD.dblCost) END) 
						ELSE ABD.dblQtyReceived * UOM.dblUnitQty END),2)
			FROM tblAPBill AB
			INNER JOIN tblAPBillDetail ABD
					ON ABD.intBillId = AB.intBillId
			INNER JOIN tblARCustomer ARC
					ON ARC.intEntityCustomerId = AB.intEntityVendorId AND ARC.strStockStatus != ''
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
			WHERE AB.intBillId IN (SELECT [intID] FROM @tempTransactionIds) AND AB.dtmDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
			AND IC.intPatronageCategoryId IS NOT NULL
			GROUP BY AB.intEntityVendorId,
			IC.intPatronageCategoryId,
			FY.intFiscalYearId,
			AB.ysnPosted
	END
	ELSE IF(@type = 2)
	BEGIN
		INSERT INTO @tempPatronageVolumes
		SELECT	intCustomerPatronId = AR.intEntityCustomerId,
				IC.intPatronageCategoryId,
				ysnPosted = @post,
				FY.intFiscalYearId,
				dblVolume =	ROUND(SUM(CASE WHEN PC.strUnitAmount = 'Amount' THEN (CASE WHEN ARD.dblQtyShipped <= 0 THEN 0 ELSE (ARD.dblQtyShipped * ARD.dblPrice) END)
							ELSE (CASE WHEN ICU.dblUnitQty <= 0 THEN ARD.dblQtyShipped ELSE (ARD.dblQtyShipped * ICU.dblUnitQty) END ) END),2)
			FROM tblARInvoice AR
			INNER JOIN tblARInvoiceDetail ARD
					ON ARD.intInvoiceId = AR.intInvoiceId
			INNER JOIN tblARCustomer ARC
					ON ARC.intEntityCustomerId = AR.intEntityCustomerId AND ARC.strStockStatus != ''
			INNER JOIN tblICItem IC
					ON IC.intItemId = ARD.intItemId
			INNER JOIN tblICItemUOM ICU
					ON ICU.intItemId = IC.intItemId AND ICU.intItemUOMId = ARD.intItemUOMId
			INNER JOIN tblPATPatronageCategory PC
					ON PC.intPatronageCategoryId = IC.intPatronageCategoryId AND PC.strPurchaseSale = 'Sale'
			CROSS APPLY tblGLFiscalYear FY
		WHERE AR.intInvoiceId IN (SELECT [intID] FROM @tempTransactionIds) AND AR.dtmDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo 
		AND IC.intPatronageCategoryId IS NOT NULL
		GROUP BY AR.intEntityCustomerId,
			IC.intPatronageCategoryId,
			FY.intFiscalYearId,
			AR.ysnPosted
	END

	SELECT @totalRecords = COUNT(*) FROM @tempPatronageVolumes
	IF (@totalRecords = 0)
	BEGIN
		GOTO Post_Commit;
	END


	MERGE tblPATCustomerVolume AS PAT
	USING @tempPatronageVolumes AS B
		ON (PAT.intCustomerPatronId = B.intCustomerPatronId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId AND PAT.intFiscalYear = B.intFiscalYearId AND PAT.ysnRefundProcessed <> 1)
		WHEN MATCHED
			THEN UPDATE SET PAT.dblVolume = CASE WHEN B.ysnPosted = 1 THEN (PAT.dblVolume + B.dblVolume) 
												ELSE (PAT.dblVolume - B.dblVolume) END
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dblVolume, intConcurrencyId)
				VALUES (B.intCustomerPatronId, B.intPatronageCategoryId, B.intFiscalYearId, CASE WHEN B.ysnPosted = 1 THEN B.dblVolume ELSE 0 END, 1);

	IF(@type = 1)
	BEGIN
		UPDATE ARC
		SET dtmLastActivityDate = APB.dtmDate
		FROM tblARCustomer ARC
		INNER JOIN ( 
				SELECT DISTINCT AB.intEntityVendorId, MAX(AB.dtmDate) OVER (PARTITION BY AB.intEntityVendorId) AS dtmDate
				FROM tblAPBill AB
				INNER JOIN tblAPBillDetail ABD
					ON ABD.intBillId = AB.intBillId
				INNER JOIN tblARCustomer ARC
					ON ARC.intEntityCustomerId = AB.intEntityVendorId AND ARC.strStockStatus != ''
				INNER JOIN tblICItem IC
					ON IC.intItemId = ABD.intItemId
				INNER JOIN tblPATPatronageCategory PC
					ON PC.intPatronageCategoryId = IC.intPatronageCategoryId AND PC.strPurchaseSale = 'Purchase'
				WHERE AB.intBillId IN (SELECT [intID] FROM @tempTransactionIds)
		) APB ON APB.intEntityVendorId = ARC.intEntityCustomerId
	END
	ELSE IF(@type = 2)
	BEGIN
		UPDATE ARC
		SET dtmLastActivityDate = ARI.dtmPostDate
		FROM tblARCustomer ARC
		INNER JOIN (
			SELECT DISTINCT ARI.intEntityCustomerId, MAX(ARI.dtmPostDate) OVER (PARTITION BY ARI.intEntityCustomerId) AS dtmPostDate FROM tblARInvoice ARI
			INNER JOIN tblARInvoiceDetail ARD
				ON ARD.intInvoiceId = ARI.intInvoiceId
			INNER JOIN tblICItem IC
				ON IC.intItemId = ARD.intItemId
			INNER JOIN tblICItemUOM ICU
				ON ICU.intItemId = IC.intItemId AND ICU.intItemUOMId = ARD.intItemUOMId
			INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = IC.intPatronageCategoryId AND PC.strPurchaseSale = 'Sale'
			WHERE ARI.intInvoiceId IN (SELECT [intID] FROM @tempTransactionIds)
		) ARI ON ARI.intEntityCustomerId = ARC.intEntityCustomerId
	END
	
	END TRY
	BEGIN CATCH
		GOTO Post_Rollback;
	END CATCH
	
	GOTO Post_Commit

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRAN @TransactionName;
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRAN @TransactionName;
	GOTO Post_Exit

Post_Exit:

END
---------------------------------------------------------------------------------------------------------------------------------------
GO