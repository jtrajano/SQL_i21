﻿CREATE PROCEDURE [dbo].[uspPATGatherVolumeForPatronage]
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
	DECLARE @TYPE_PURCHASE NVARCHAR(10) = 'Purchase' COLLATE Latin1_General_CI_AS;
	DECLARE @TYPE_SALE NVARCHAR(10) = 'Sale' COLLATE Latin1_General_CI_AS;
	DECLARE @TYPE_AMOUNT NVARCHAR(10) = 'Amount' COLLATE Latin1_General_CI_AS;

	DECLARE @TransactionName AS VARCHAR(500) = 'GATHERING PATRONAGE VOLUME' + CAST(NEWID() AS NVARCHAR(100));

	DECLARE @tempTransactionIds TABLE(
        [intID] INT
    );

	DECLARE @patronageVolumeStaging TABLE(
		[intTransactionDetailId] INT,
		[intTransactionId] INT,
		[dtmDate] DATETIME,
		[intFiscalYearId] INT,
		[intCustomerPatronId] INT,
		[intItemId] INT,
		[intPatronageCategoryId] INT,
		[strPurchaseSale] NVARCHAR(25),
		[strUnitAmount] NVARCHAR(25),
		[dblQuantity] NUMERIC(18,6),
		[dblCost] NUMERIC(18,6),
		[dblUnitQty] NUMERIC(18,6),
		[ysnDirectCategory] BIT
	);

	DECLARE @tempPatronageVolumes TABLE(
		[intCustomerPatronId] INT,
		[intPatronageCategoryId] INT,
		[ysnPosted] BIT,
		[intFiscalYearId] INT,
		[dblVolume] NUMERIC(18,6)
	);

	INSERT INTO @tempTransactionIds
	SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@transactionIds)

	BEGIN TRAN @TransactionName;
	SAVE TRAN @TransactionName;

	-----====== Begin - Build Patronage Staging Table ======-----
	IF(@type = 1) -- PURCHASE / DIRECT IN
	BEGIN
			INSERT INTO @patronageVolumeStaging
			SELECT	ABD.intBillDetailId,
					AB.intBillId,
					dtmDate = DATEADD(dd, DATEDIFF(dd, 0, AB.dtmDate), 0),
					FY.intFiscalYearId,
					intCustomerPatronId = AB.intEntityVendorId,
					IC.intItemId,
					IC.intPatronageCategoryId,
					PC.strPurchaseSale,
					PC.strUnitAmount,
					ABD.dblQtyReceived,
					ABD.dblCost,
					UOM.dblUnitQty,
					ysnDirectCategory = 0
			FROM tblAPBill AB
			INNER JOIN tblAPBillDetail ABD
					ON ABD.intBillId = AB.intBillId
			INNER JOIN tblARCustomer ARC
				ON ARC.intEntityId = AB.intEntityVendorId AND ARC.strStockStatus != ''
			INNER JOIN tblICItem IC
				ON IC.intItemId = ABD.intItemId
			INNER JOIN tblICItemUOM UOM
				ON UOM.intItemUOMId = ABD.intUnitOfMeasureId AND UOM.intItemId = IC.intItemId
			INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = IC.intPatronageCategoryId AND PC.strPurchaseSale = @TYPE_PURCHASE
			CROSS APPLY tblGLFiscalYear FY
			WHERE AB.intBillId IN (SELECT [intID] FROM @tempTransactionIds) AND AB.dtmDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
			AND IC.intPatronageCategoryId IS NOT NULL
			UNION 
			SELECT	ABD.intBillDetailId,
					AB.intBillId,
					dtmDate = DATEADD(dd, DATEDIFF(dd, 0, AB.dtmDate), 0),
					FY.intFiscalYearId,
					intCustomerPatronId = AB.intEntityVendorId,
					IC.intItemId,
					IC.intPatronageCategoryDirectId, 
					PC.strPurchaseSale,
					PC.strUnitAmount,
					ABD.dblQtyReceived,
					ABD.dblCost,
					UOM.dblUnitQty,
					ysnDirectCategory = 1
			FROM tblAPBill AB
			INNER JOIN tblAPBillDetail ABD
				ON ABD.intBillId = AB.intBillId
			INNER JOIN tblICInventoryReceiptItem IRItem
				ON IRItem.intInventoryReceiptItemId = ABD.intInventoryReceiptItemId 
			INNER JOIN tblICInventoryReceipt IR
				ON IR.intInventoryReceiptId = IRItem.intInventoryReceiptId AND IR.intSourceType = 1
			INNER JOIN tblSCTicket SC
				ON SC.intTicketId = IRItem.intSourceId AND SC.intTicketTypeId = 8
			INNER JOIN tblARCustomer ARC
				ON ARC.intEntityId = AB.intEntityVendorId AND ARC.strStockStatus != ''
			INNER JOIN tblICItem IC
				ON IC.intItemId = ABD.intItemId
			INNER JOIN tblICItemUOM UOM
				ON UOM.intItemUOMId = ABD.intUnitOfMeasureId AND UOM.intItemId = IC.intItemId
			INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = IC.intPatronageCategoryDirectId AND PC.strPurchaseSale = @TYPE_PURCHASE
			CROSS APPLY tblGLFiscalYear FY
			WHERE AB.intBillId IN (SELECT [intID] FROM @tempTransactionIds) AND AB.dtmDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
			AND IC.intPatronageCategoryDirectId IS NOT NULL
	END
	ELSE IF(@type = 2) -- SALE / DIRECT OUT
	BEGIN
		INSERT INTO @patronageVolumeStaging
		SELECT		ARID.intInvoiceDetailId,
					ARI.intInvoiceId,
					dtmDate = DATEADD(dd, DATEDIFF(dd, 0, ARI.dtmDate), 0),
					FY.intFiscalYearId,
					intCustomerPatronId = ARI.intEntityCustomerId,
					IC.intItemId,
					IC.intPatronageCategoryId,
					PC.strPurchaseSale,
					PC.strUnitAmount,
					ARID.dblQtyShipped,
					ARID.dblPrice,
					UOM.dblUnitQty,
					ysnDirectCategory = 0
			FROM tblARInvoice ARI
			INNER JOIN tblARInvoiceDetail ARID
					ON ARID.intInvoiceId = ARI.intInvoiceId
			INNER JOIN tblARCustomer ARC
				ON ARC.intEntityId = ARI.intEntityCustomerId AND ARC.strStockStatus != ''
			INNER JOIN tblICItem IC
				ON IC.intItemId = ARID.intItemId
			INNER JOIN tblICItemUOM UOM
				ON UOM.intItemId = IC.intItemId AND UOM.intItemUOMId = ARID.intItemUOMId
			INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = IC.intPatronageCategoryId AND PC.strPurchaseSale = @TYPE_SALE
			CROSS APPLY tblGLFiscalYear FY
			WHERE ARI.intInvoiceId IN (SELECT [intID] FROM @tempTransactionIds) AND ARI.dtmDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
			AND IC.intPatronageCategoryId IS NOT NULL
			UNION 
			SELECT	ARID.intInvoiceDetailId,
					ARI.intInvoiceId,
					dtmDate = DATEADD(dd, DATEDIFF(dd, 0, ARI.dtmDate), 0),
					FY.intFiscalYearId,
					intCustomerPatronId = ARI.intEntityCustomerId,
					IC.intItemId,
					IC.intPatronageCategoryId,
					PC.strPurchaseSale,
					PC.strUnitAmount,
					ARID.dblQtyShipped,
					ARID.dblPrice,
					UOM.dblUnitQty,
					ysnDirectCategory = 1
			FROM tblARInvoice ARI
			INNER JOIN tblARInvoiceDetail ARID
				ON ARID.intInvoiceId = ARI.intInvoiceId
			INNER JOIN tblICInventoryShipmentItem ISItem
				ON ISItem.intInventoryShipmentId = ARID.intInventoryShipmentItemId
			INNER JOIN tblICInventoryShipment InvShip
				ON InvShip.intInventoryShipmentId = ISItem.intInventoryShipmentId AND InvShip.intSourceType = 1
			INNER JOIN tblSCTicket SC
				ON SC.intTicketId = ISItem.intSourceId AND SC.intTicketTypeId = 9
			INNER JOIN tblARCustomer ARC
				ON ARC.intEntityId = ARI.intEntityCustomerId AND ARC.strStockStatus != ''
			INNER JOIN tblICItem IC
				ON IC.intItemId = ARID.intItemId
			INNER JOIN tblICItemUOM UOM
				ON UOM.intItemId = IC.intItemId AND UOM.intItemUOMId = ARID.intItemUOMId
			INNER JOIN tblPATPatronageCategory PC
				ON PC.intPatronageCategoryId = IC.intPatronageCategoryDirectId AND PC.strPurchaseSale = @TYPE_SALE
			CROSS APPLY tblGLFiscalYear FY
			WHERE ARI.intInvoiceId IN (SELECT [intID] FROM @tempTransactionIds) AND ARI.dtmDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
			AND IC.intPatronageCategoryDirectId IS NOT NULL
	END
	-----====== END - Build Patronage Staging Table ======-----
	
	-----====== BEGIN - Filter Customer Volume with Direct Sale ======-----
	IF EXISTS(SELECT COUNT(*) FROM @patronageVolumeStaging GROUP BY intTransactionDetailId HAVING COUNT(intTransactionDetailId) > 1)
	BEGIN
		DELETE FROM @patronageVolumeStaging WHERE intTransactionDetailId IN 
			(SELECT intTransactionDetailId FROM @patronageVolumeStaging GROUP BY intTransactionDetailId, strPurchaseSale HAVING COUNT(intTransactionDetailId) > 1) AND ysnDirectCategory <> 1;
	END
	-----====== END - Filter Customer Volume with Direct Sale ======-----
	SELECT * FROM @patronageVolumeStaging;
	-----====== BEGIN - Count Eligible Customer Volume ======-----
	SELECT @totalRecords = COUNT(*) FROM @patronageVolumeStaging;
	IF (@totalRecords = 0)
	BEGIN
		GOTO Post_Commit;
	END
	-----====== END - Count Eligible Customer Volume ======-----

	-----====== BEGIN - Compute Patronage Volume ======-----
	INSERT INTO @tempPatronageVolumes
	SELECT	PVS.intCustomerPatronId,
			PVS.intPatronageCategoryId,
			ysnPosted = @post,
			PVS.intFiscalYearId,
			dblVolume = ROUND(SUM(CASE WHEN PVS.strUnitAmount = @TYPE_AMOUNT THEN (CASE WHEN PVS.dblQuantity <= 0 THEN 0 ELSE (PVS.dblQuantity * PVS.dblCost) END) 
						ELSE PVS.dblQuantity * PVS.dblUnitQty END), 2)
	FROM @patronageVolumeStaging PVS
	GROUP BY	PVS.intCustomerPatronId,
				PVS.intPatronageCategoryId,
				PVS.ysnDirectCategory,
				PVS.intFiscalYearId
	-----====== END - Compute Patronage Volume ======-----
				
				
	BEGIN TRY
	-----====== BEGIN - Merge Patronage Volume ======-----
	MERGE tblPATCustomerVolume AS CustVol
	USING @tempPatronageVolumes AS PatVol
		ON (CustVol.intCustomerPatronId = PatVol.intCustomerPatronId AND CustVol.intPatronageCategoryId = PatVol.intPatronageCategoryId 
			AND CustVol.intFiscalYear = PatVol.intFiscalYearId AND CustVol.ysnRefundProcessed <> 1)
		WHEN MATCHED
			THEN UPDATE SET CustVol.dblVolume = CASE WHEN PatVol.ysnPosted = 1 THEN (CustVol.dblVolume + PatVol.dblVolume) 
												ELSE (CustVol.dblVolume - PatVol.dblVolume) END
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dblVolume, intConcurrencyId)
				VALUES (PatVol.intCustomerPatronId, PatVol.intPatronageCategoryId, PatVol.intFiscalYearId, CASE WHEN PatVol.ysnPosted = 1 THEN PatVol.dblVolume ELSE 0 END, 1);
	-----====== END - Merge Patronage Volume ======-----


	
	-----====== BEGIN - Update Customer Volume Log ======-----
	IF(@post = 1)
	BEGIN
		INSERT INTO tblPATCustomerVolumeLog(intInvoiceId,intBillId,dtmTransactionDate,ysnDirectSale,intItemId,dblVolume)
		SELECT	intInvoiceId = NULL,
				intBillId = PVS.intTransactionId,
				dtmTransactionDate = PVS.dtmDate,
				ysnDirectSale = PVS.ysnDirectCategory,
				intItemId = PVS.intItemId,
				dblVolume = ROUND((CASE WHEN PVS.strUnitAmount = @TYPE_AMOUNT THEN (CASE WHEN PVS.dblQuantity <= 0 THEN 0 ELSE (PVS.dblQuantity * PVS.dblCost) END) 
						ELSE PVS.dblQuantity * PVS.dblUnitQty END),2)
		FROM @patronageVolumeStaging PVS
		WHERE PVS.strPurchaseSale = @TYPE_PURCHASE
		UNION ALL
		SELECT	intInvoiceId = PVS.intTransactionId,
				intBillId = NULL,
				dtmTransactionDate = PVS.dtmDate,
				ysnDirectSale = PVS.ysnDirectCategory,
				intItemId = PVS.intItemId,
				dblVolume = ROUND((CASE WHEN PVS.strUnitAmount = @TYPE_AMOUNT THEN (CASE WHEN PVS.dblQuantity <= 0 THEN 0 ELSE (PVS.dblQuantity * PVS.dblCost) END) 
						ELSE PVS.dblQuantity * PVS.dblUnitQty END),2)
		FROM @patronageVolumeStaging PVS
		WHERE PVS.strPurchaseSale = @TYPE_SALE
	END
	ELSE
	BEGIN
		IF(@type = 1)
		BEGIN
			UPDATE tblPATCustomerVolumeLog
			SET ysnIsUnposted = 1
			WHERE ysnIsUnposted <> 1 AND intBillId IN (SELECT intTransactionId FROM @patronageVolumeStaging WHERE strPurchaseSale = @TYPE_PURCHASE)
		END
		ELSE
		BEGIN
			UPDATE tblPATCustomerVolumeLog
			SET ysnIsUnposted = 1
			WHERE ysnIsUnposted <> 1 AND intInvoiceId IN (SELECT intTransactionId FROM @patronageVolumeStaging WHERE strPurchaseSale = @TYPE_SALE)
		END
	END
	-----====== END - Update Customer Volume Log ======-----


	-----====== BEGIN - Update Customer Last Activity Date ======-----
	UPDATE ARC
	SET dtmLastActivityDate = PVS.dtmDate
	FROM tblARCustomer ARC
	INNER JOIN (
		SELECT DISTINCT PVS.intCustomerPatronId, MAX(PVS.dtmDate) OVER(PARTITION BY PVS.intCustomerPatronId) AS dtmDate
		FROM @patronageVolumeStaging PVS
	) PVS ON PVS.intCustomerPatronId = ARC.intEntityId
	-----====== END - Update Customer Last Activity Date ======-----


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