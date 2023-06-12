CREATE PROCEDURE [dbo].[uspQMUpdateReconciliationIntegration] 
	  @intCatalogueReconciliationId		INT = NULL	
	, @intUserId						INT = NULL
AS  

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
--SET ANSI_WARNINGS OFF

DECLARE @intTranCount	 			INT
SET @intTranCount = @@trancount;

BEGIN TRY
	IF @intTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION uspQMUpdateReconIntegration
			
    IF OBJECT_ID('tempdb..#VOUCHERS') IS NOT NULL DROP TABLE #VOUCHERS
	IF OBJECT_ID('tempdb..#SAMPLES') IS NOT NULL DROP TABLE #SAMPLES
	IF OBJECT_ID('tempdb..#LOADSHIPMENTS') IS NOT NULL DROP TABLE #LOADSHIPMENTS
	IF OBJECT_ID('tempdb..#MFBATCH') IS NOT NULL DROP TABLE #MFBATCH

	--CHECK IF HAS CHANGES FOR BATCH
	SELECT intBatchId						= B.intBatchId
		, intSampleId						= B.intSampleId
		, strLeafGrade						= CA.strDescription
		, strTeaGardenChopInvoiceNumber		= CRD.strPreInvoiceChopNo
		, intGardenMarkId					= CRD.intPreInvoiceGardenMarkId
		, dblTotalQuantity					= dbo.fnCalculateQtyBetweenUOM(WIUOM.intItemUOMId, QIUOM.intItemUOMId, CRD.dblPreInvoiceQuantity)
		, dblBoughtPrice					=CRD.dblBasePrice
	INTO #MFBATCH
	FROM tblMFBatch B
	INNER JOIN tblQMCatalogueReconciliationDetail CRD ON B.intSampleId = CRD.intSampleId
	LEFT JOIN tblICCommodityAttribute CA ON CRD.intPreInvoiceGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
	LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = B.intWeightUOMId
	LEFT JOIN tblICItemUOM QIUOM ON QIUOM.intUnitMeasureId = B.intItemUOMId AND QIUOM.intItemId = B.intTealingoItemId
	LEFT JOIN tblICItemUOM WIUOM ON WIUOM.intUnitMeasureId = WUM.intUnitMeasureId AND WIUOM.intItemId = B.intTealingoItemId
	WHERE CRD.intCatalogueReconciliationId = @intCatalogueReconciliationId
	    AND B.intSampleId IS NOT NULL
		AND ((B.strTeaGardenChopInvoiceNumber <> CRD.strPreInvoiceChopNo AND CRD.strPreInvoiceChopNo = CRD.strChopNo)
		OR (B.intGardenMarkId <> CRD.intPreInvoiceGardenMarkId AND CRD.intPreInvoiceGardenMarkId = CRD.intGardenMarkId)
		OR (B.strLeafGrade <> CA.strDescription AND CRD.intPreInvoiceGradeId = CRD.intGradeId)
		OR (B.dblBasePrice <> CRD.dblBasePrice AND CRD.dblPreInvoicePrice  = CRD.dblBasePrice)
		OR (B.dblTotalQuantity <> CRD.dblPreInvoiceQuantity AND CRD.dblPreInvoiceQuantity = CRD.dblQuantity))

	--UPDATE BATCH
	IF EXISTS (SELECT TOP 1 1 FROM #MFBATCH)
		BEGIN
			UPDATE MF
			SET strLeafGrade					= MFB.strLeafGrade
			  , strTeaGardenChopInvoiceNumber	= MFB.strTeaGardenChopInvoiceNumber
			  , intGardenMarkId					= MFB.intGardenMarkId
			  , dblTotalQuantity				= MFB.dblTotalQuantity
			  , dblBoughtPrice					= MFB.dblBoughtPrice
			  , dblBasePrice					= MFB.dblBoughtPrice
			FROM tblMFBatch MF
			INNER JOIN #MFBATCH MFB ON MF.intBatchId = MFB.intBatchId
		END

	--CHECK IF HAS CHANGES FOR VOUCHERS
    SELECT intCatalogueReconciliationId			= CRD.intCatalogueReconciliationId
		 , intCatalogueReconciliationDetailId	= CRD.intCatalogueReconciliationDetailId
         , intBillDetailId						= CRD.intBillDetailId
         , intCatalogueCreatedById				= CR.intEntityId
         , strReconciliationNumber				= CR.strReconciliationNumber
         , ysnPosted							= CR.ysnPosted
         , intBillId							= B.intBillId
         , strBillId							= B.strBillId
         , intBillCreatedById					= B.intEntityId         
		 , dblCatReconPrice						= CRD.dblPreInvoicePrice
		 , dblPreInvoicePrice					= BD.dblCost
		 , dblCatReconQty						= CRD.dblPreInvoiceQuantity
		 , dblPreInvoiceQuantity				= BD.dblQtyOrdered
		 , strCatReconChopNo					= CRD.strPreInvoiceChopNo
		 , strPreInvoiceChopNo					= BD.strPreInvoiceGardenNumber
		 , intCatReconGardenMarkId				= CRD.intPreInvoiceGardenMarkId
		 , intPreInvoiceGardenMarkId			= BD.intGardenMarkId
		 , strCatReconGrade						= CA.strDescription
		 , strPreInvoiceGrade					= BD.strComment
    INTO #VOUCHERS 
    FROM tblQMCatalogueReconciliation CR
	INNER JOIN tblQMCatalogueReconciliationDetail CRD ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
	INNER JOIN tblAPBillDetail BD ON CRD.intBillDetailId = BD.intBillDetailId
    INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
	LEFT JOIN tblICCommodityAttribute CA ON CRD.intPreInvoiceGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
    WHERE CR.intCatalogueReconciliationId = @intCatalogueReconciliationId
      AND ((CRD.dblPreInvoicePrice <> BD.dblCost AND CRD.dblPreInvoicePrice = CRD.dblBasePrice)
        OR (CRD.dblPreInvoiceQuantity <> BD.dblQtyOrdered AND CRD.dblPreInvoiceQuantity = CRD.dblQuantity)
        OR (CRD.strPreInvoiceChopNo <> BD.strPreInvoiceGardenNumber AND CRD.strPreInvoiceChopNo = CRD.strChopNo)
        OR (CRD.intPreInvoiceGardenMarkId <> BD.intGardenMarkId AND CRD.intPreInvoiceGardenMarkId = CRD.intGardenMarkId)
        OR (CA.strDescription <> BD.strComment AND CRD.intPreInvoiceGradeId = CRD.intGradeId))
	
	--UPDATE BILL DETAIL
	IF EXISTS (SELECT TOP 1 1 FROM #VOUCHERS)
		BEGIN
			UPDATE BD
			SET dblCost						= ISNULL(V.dblCatReconPrice, 0)
			  , dblCashPrice				= ISNULL(V.dblCatReconPrice, 0)
			  , dblQtyReceived				= ISNULL(V.dblCatReconQty, 0)
			  , dblQtyOrdered				= ISNULL(V.dblCatReconQty, 0)
			  , strPreInvoiceGardenNumber	= CAST(V.strCatReconChopNo AS NVARCHAR(100))
			  , intGardenMarkId				= NULLIF(V.intCatReconGardenMarkId, 0)
			  , strComment					= CAST(V.strCatReconGrade AS NVARCHAR(100))
			FROM tblAPBillDetail BD
			INNER JOIN #VOUCHERS V ON V.intBillDetailId = BD.intBillDetailId

			--UPDATE BILL TOTALS
			DECLARE @billIds AS Id

			INSERT INTO @billIds
			SELECT DISTINCT BD.intBillId
			FROM tblAPBillDetail BD
			INNER JOIN #VOUCHERS V ON V.intBillDetailId = BD.intBillDetailId

			IF EXISTS (SELECT TOP 1 1 FROM @billIds)
				EXEC uspAPUpdateVoucherTotal @billIds

			--AUDIT LOG FOR VOUCHERS
			WHILE EXISTS (SELECT TOP 1 1 FROM #VOUCHERS)
				BEGIN
					DECLARE @BillSingleAuditLogParam	AS SingleAuditLogParam 
					DECLARE @intBillId		INT = NULL
						  
					SELECT TOP 1 @intBillId = intBillId
					FROM #VOUCHERS

					--AUDIT LOG FOR VOUCHER	HEADER AND DETAILS			
					DELETE FROM @BillSingleAuditLogParam
					INSERT INTO @BillSingleAuditLogParam (
						  [Id]
						, [Action]
						, [Change]
						, [From]
						, [To]
						, [ParentId]
					)
					SELECT [Id]			= 1
						, [Action]		= 'Update Amendments'
						, [Change]		= 'Updated - Record: ' + CAST(intBillId AS NVARCHAR(100))
						, [From]		= NULL
						, [To]			= NULL
						, [ParentId]	= NULL
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId

					UNION ALL

					SELECT [Id]			= 2
						, [Action]		= NULL
						, [Change]		= 'Update Cost'
						, [From]		= CAST(dblPreInvoicePrice AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconPrice AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND dblPreInvoicePrice <> dblCatReconPrice

					UNION ALL

					SELECT [Id]			= 3
						, [Action]		= NULL
						, [Change]		= 'Update Cash Price'
						, [From]		= CAST(dblPreInvoicePrice AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconPrice AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND dblPreInvoicePrice <> dblCatReconPrice

					UNION ALL

					SELECT [Id]			= 4
						, [Action]		= NULL
						, [Change]		= 'Update Received'
						, [From]		= CAST(dblPreInvoiceQuantity AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND dblPreInvoiceQuantity <> dblCatReconQty

					UNION ALL

					SELECT [Id]			= 5
						, [Action]		= NULL
						, [Change]		= 'Update Ordered'
						, [From]		= CAST(dblPreInvoiceQuantity AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND dblPreInvoiceQuantity <> dblCatReconQty

					UNION ALL

					SELECT [Id]			= 6
						, [Action]		= NULL
						, [Change]		= 'Update Pre-Invoice Garden Number'
						, [From]		= CAST(strPreInvoiceChopNo AS NVARCHAR(100))
						, [To]			= CAST(strCatReconChopNo AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND strPreInvoiceChopNo <> strCatReconChopNo

					UNION ALL

					SELECT [Id]			= 7
						, [Action]		= NULL
						, [Change]		= 'Update Garden Mark'
						, [From]		= CAST(VGM.strGardenMark AS NVARCHAR(100))
						, [To]			= CAST(GM.strGardenMark AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS V
					LEFT JOIN tblQMGardenMark GM ON V.intCatReconGardenMarkId = GM.intGardenMarkId
					LEFT JOIN tblQMGardenMark VGM ON V.intPreInvoiceGardenMarkId = VGM.intGardenMarkId
					WHERE V.intBillId = @intBillId
					  AND V.intPreInvoiceGardenMarkId <> V.intCatReconGardenMarkId

					UNION ALL

					SELECT [Id]			= 8
						, [Action]		= NULL
						, [Change]		= 'Update Comment'
						, [From]		= CAST(strPreInvoiceGrade AS NVARCHAR(100))
						, [To]			= CAST(strCatReconGrade AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS V
					WHERE V.intBillId = @intBillId
					  AND V.strPreInvoiceGrade <> V.strCatReconGrade
						  
					--AUDIT LOG FOR VOUCHER
					EXEC uspSMSingleAuditLog @screenName		= 'AccountsPayable.view.Voucher'
											, @recordId			= @intBillId
											, @entityId			= @intUserId
											, @AuditLogParam	= @BillSingleAuditLogParam
				
					DELETE FROM #VOUCHERS WHERE intBillId = @intBillId
				END
		END

	--CHECK IF HAS CHANGES FOR SAMPLES
	SELECT intSampleId							= S.intSampleId
         , intCatalogueReconciliationId			= CRD.intCatalogueReconciliationId
		 , intCatalogueReconciliationDetailId	= CRD.intCatalogueReconciliationDetailId
         , intCatalogueCreatedById				= CR.intEntityId
         , strReconciliationNumber				= CR.strReconciliationNumber
         , ysnPosted							= CR.ysnPosted
		 , dblCatReconPrice						= CRD.dblPreInvoicePrice
		 , dblSamplePrice						= S.dblB1Price		 
		 , dblSampleQty							= ISNULL(S.dblSampleQty, 0)
		 , dblRepresentingQty					= ISNULL(S.dblRepresentingQty, 0)
		 , dblCatReconSampleQty					= ISNULL(CRD.dblPreInvoiceQuantity, 0)
		 , dblCatReconRepQty					= ISNULL(dbo.fnCalculateQtyBetweenUoms(ITEM.strItemNo, SIUM.strUnitMeasure, RIUM.strUnitMeasure, CRD.dblPreInvoiceQuantity), 0)
		 , strCatReconChopNo					= CRD.strPreInvoiceChopNo
		 , strSampleChopNo						= S.strChopNumber
		 , intCatReconGardenMarkId				= CRD.intPreInvoiceGardenMarkId
		 , intSampleGardenMarkId				= S.intGardenMarkId
		 , intCatReconGradeId					= CRD.intPreInvoiceGradeId
		 , intSampleGradeId						= S.intGradeId
		 , dblSupplierValuationPrice			= S.dblSupplierValuationPrice
		 , dblB1QtyBought						= S.dblB1QtyBought
    INTO #SAMPLES 
    FROM tblQMCatalogueReconciliation CR
	INNER JOIN tblQMCatalogueReconciliationDetail CRD ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
	INNER JOIN tblQMSample S ON CRD.intSampleId = S.intSampleId
	INNER JOIN tblMFBatch MFB ON S.intSampleId = MFB.intSampleId
	LEFT JOIN tblICItem ITEM ON ITEM.intItemId = S.intItemId
	LEFT JOIN tblICUnitMeasure SIUM ON SIUM.intUnitMeasureId = S.intSampleUOMId
	LEFT JOIN tblICUnitMeasure RIUM ON RIUM.intUnitMeasureId = S.intRepresentingUOMId
    WHERE CR.intCatalogueReconciliationId = @intCatalogueReconciliationId
      AND ((S.dblB1Price <> CRD.dblPreInvoicePrice AND CRD.dblPreInvoicePrice = CRD.dblBasePrice)
        OR (S.dblRepresentingQty <> CRD.dblPreInvoiceQuantity AND CRD.dblPreInvoiceQuantity = CRD.dblQuantity)
        OR (S.strChopNumber <> CRD.strPreInvoiceChopNo AND CRD.strPreInvoiceChopNo = CRD.strChopNo)
        OR (S.intGardenMarkId <> CRD.intPreInvoiceGardenMarkId AND CRD.intPreInvoiceGardenMarkId = CRD.intGardenMarkId)
        OR (S.intGradeId <> CRD.intPreInvoiceGradeId AND CRD.intPreInvoiceGradeId = CRD.intGradeId))
	
	--UPDATE SAMPLE
	IF EXISTS (SELECT TOP 1 1 FROM #SAMPLES)
		BEGIN
			UPDATE S
			SET dblB1Price					= ISNULL(SS.dblCatReconPrice, 0)
			  , dblSupplierValuationPrice	= ISNULL(SS.dblCatReconPrice, 0)
			  , dblSampleQty				= ISNULL(SS.dblCatReconSampleQty, 0)
			  , dblRepresentingQty			= ISNULL(SS.dblCatReconRepQty, 0)
			  , dblB1QtyBought				= ISNULL(SS.dblCatReconRepQty, 0)
			  , strChopNumber				= SS.strCatReconChopNo
			  , intGardenMarkId				= NULLIF(SS.intCatReconGardenMarkId, 0)
			  , intGradeId					= NULLIF(SS.intCatReconGradeId, 0)
			FROM tblQMSample S
			INNER JOIN #SAMPLES SS ON S.intSampleId = SS.intSampleId

			--AUDIT LOG FOR SAMPLES
			WHILE EXISTS (SELECT TOP 1 1 FROM #SAMPLES)
				BEGIN
					DECLARE @SampleAuditLogParam	AS SingleAuditLogParam 
					DECLARE @intSampleId			INT = NULL
						  
					SELECT TOP 1 @intSampleId = intSampleId
					FROM #SAMPLES

					--AUDIT LOG FOR VOUCHER	HEADER AND DETAILS	
					DELETE FROM @SampleAuditLogParam
					INSERT INTO @SampleAuditLogParam (
						  [Id]
						, [Action]
						, [Change]
						, [From]
						, [To]
						, [ParentId]
					)
					SELECT [Id]			= 1
						, [Action]		= 'Update Amendments'
						, [Change]		= 'Updated - Record: ' + CAST(intSampleId AS NVARCHAR(100))
						, [From]		= NULL
						, [To]			= NULL
						, [ParentId]	= NULL
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId

					UNION ALL

					SELECT [Id]			= 2
						, [Action]		= NULL
						, [Change]		= 'Update Initial Price'
						, [From]		= CAST(dblSamplePrice AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconPrice AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND dblSamplePrice <> dblCatReconPrice

					UNION ALL

					SELECT [Id]			= 3
						, [Action]		= NULL
						, [Change]		= 'Update Supplier Valuation Price'
						, [From]		= CAST(dblSupplierValuationPrice AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconPrice AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND dblSupplierValuationPrice <> dblCatReconPrice

					UNION ALL

					SELECT [Id]			= 4
						, [Action]		= NULL
						, [Change]		= 'Update Net Quantity'
						, [From]		= CAST(dblSampleQty AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconSampleQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND dblSampleQty <> dblCatReconSampleQty

					UNION ALL

					SELECT [Id]			= 5
						, [Action]		= NULL
						, [Change]		= 'Update Quantity'
						, [From]		= CAST(dblRepresentingQty AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconRepQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND dblRepresentingQty <> dblCatReconRepQty

					UNION ALL

					SELECT [Id]			= 6
						, [Action]		= NULL
						, [Change]		= 'Update Buyer 1 Quantity Bought'
						, [From]		= CAST(dblB1QtyBought AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconRepQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND dblRepresentingQty <> dblCatReconRepQty

					UNION ALL
					
					SELECT [Id]			= 7
						, [Action]		= NULL
						, [Change]		= 'Update Chop Number'
						, [From]		= CAST(strSampleChopNo AS NVARCHAR(100))
						, [To]			= CAST(strCatReconChopNo AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND strSampleChopNo <> strCatReconChopNo

					UNION ALL

					SELECT [Id]			= 8
						, [Action]		= NULL
						, [Change]		= 'Update Garden Mark'
						, [From]		= CAST(SGM.strGardenMark AS NVARCHAR(100))
						, [To]			= CAST(GM.strGardenMark AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES S
					LEFT JOIN tblQMGardenMark GM ON S.intCatReconGardenMarkId = GM.intGardenMarkId
					LEFT JOIN tblQMGardenMark SGM ON S.intSampleGardenMarkId = SGM.intGardenMarkId
					WHERE S.intSampleId = @intSampleId
					  AND S.intSampleGardenMarkId <> S.intCatReconGardenMarkId

					UNION ALL

					SELECT [Id]			= 9
						, [Action]		= NULL
						, [Change]		= 'Update Grade'
						, [From]		= CAST(SCA.strDescription AS NVARCHAR(100))
						, [To]			= CAST(CA.strDescription AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES S
					LEFT JOIN tblICCommodityAttribute CA ON S.intCatReconGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
					LEFT JOIN tblICCommodityAttribute SCA ON S.intSampleGradeId = SCA.intCommodityAttributeId AND SCA.strType = 'Grade'
					WHERE S.intSampleId = @intSampleId
					  AND S.intSampleGradeId <> S.intCatReconGradeId
						  
					--AUDIT LOG FOR VOUCHER
					EXEC uspSMSingleAuditLog @screenName		= 'Quality.view.QualitySample'
											, @recordId			= @intSampleId
											, @entityId			= @intUserId
											, @AuditLogParam	= @SampleAuditLogParam
				
					DELETE FROM #SAMPLES WHERE intSampleId = @intSampleId
				END
		END
	
	--CHECK IF HAS CHANGES FOR LOAD SHIPMENT
	SELECT intCatalogueReconciliationId			= CRD.intCatalogueReconciliationId
		 , intCatalogueReconciliationDetailId	= CRD.intCatalogueReconciliationDetailId
         , intCatalogueCreatedById				= CR.intEntityId
		 , intLoadDetailId						= LD.intLoadDetailId
		 , intLoadId							= L.intLoadId		 
         , strReconciliationNumber				= CR.strReconciliationNumber
         , ysnPosted							= CR.ysnPosted
		 , dblCatReconPrice						= CRD.dblPreInvoicePrice
		 , dblCatReconQty						= ISNULL(dbo.fnCalculateQtyBetweenUoms(ITEM.strItemNo, SIUM.strUnitMeasure, LIUM.strUnitMeasure, CRD.dblPreInvoiceQuantity), 0)
		 , dblCatReconGrossQty					= ISNULL(CRD.dblPreInvoiceQuantity, 0)
		 , dblLoadPrice							= ISNULL(LD.dblUnitPrice, 0)
		 , dblLoadQty							= ISNULL(LD.dblQuantity, 0)
		 , dblGrossQty							= ISNULL(LD.dblGross, 0)
		 , dblNetQty							= ISNULL(LD.dblNet, 0)
		 , dblTareQty 							= ISNULL(LD.dblTare, 0)
	INTO #LOADSHIPMENTS
	FROM tblQMCatalogueReconciliation CR
	INNER JOIN tblQMCatalogueReconciliationDetail CRD ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
	INNER JOIN tblQMSample S ON CRD.intSampleId = S.intSampleId
	INNER JOIN tblMFBatch MFB ON S.intSampleId = MFB.intSampleId
	INNER JOIN tblLGLoadDetail LD ON LD.intBatchId = MFB.intBatchId
	INNER JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
	LEFT JOIN tblICItem ITEM ON ITEM.intItemId = S.intItemId
	LEFT JOIN tblICUnitMeasure SIUM ON SIUM.intUnitMeasureId = S.intSampleUOMId
	LEFT JOIN tblICItemUOM IUOM ON LD.intItemUOMId = IUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure LIUM ON LIUM.intUnitMeasureId = IUOM.intUnitMeasureId
    WHERE CR.intCatalogueReconciliationId = @intCatalogueReconciliationId
      AND ((LD.dblUnitPrice <> CRD.dblPreInvoicePrice AND CRD.dblPreInvoicePrice = CRD.dblBasePrice)
        OR (LD.dblQuantity <> CRD.dblPreInvoiceQuantity AND CRD.dblPreInvoiceQuantity = CRD.dblQuantity))

	--UPDATE LOAD SHIPMENT
	IF EXISTS (SELECT TOP 1 1 FROM #LOADSHIPMENTS)
		BEGIN
			UPDATE LG
			SET dblUnitPrice	= LS.dblCatReconPrice
			  , dblQuantity		= LS.dblCatReconQty
			  , dblGross		= LS.dblCatReconGrossQty
			  , dblNet			= LS.dblCatReconGrossQty			  
			  , dblTare			= 0
			  , dblAmount 		= LS.dblCatReconPrice * LS.dblCatReconGrossQty
			  , dblForexAmount	= LS.dblCatReconPrice * LS.dblCatReconGrossQty
			FROM tblLGLoadDetail LG
			INNER JOIN #LOADSHIPMENTS LS ON LG.intLoadDetailId = LS.intLoadDetailId

			--AUDIT LOG FOR LOAD SHIPMENT
			WHILE EXISTS (SELECT TOP 1 1 FROM #LOADSHIPMENTS)
				BEGIN
					DECLARE @LoadShipmentAuditLogParam	AS SingleAuditLogParam 
					DECLARE @intLoadDetailId			INT = NULL
					DECLARE @intLoadId					INT = NULL

					SELECT TOP 1 @intLoadId			= intLoadId
							   , @intLoadDetailId	= intLoadDetailId
					FROM #LOADSHIPMENTS

					--AUDIT LOG FOR LOAD SHIPMENT DETAILS
					DELETE FROM @LoadShipmentAuditLogParam			
					INSERT INTO @LoadShipmentAuditLogParam (
						  [Id]
						, [Action]
						, [Change]
						, [From]
						, [To]
						, [ParentId]
					)
					SELECT [Id]			= 1
						, [Action]		= 'Update Amendments'
						, [Change]		= 'Updated - Record: ' + CAST(intLoadId AS NVARCHAR(100))
						, [From]		= NULL
						, [To]			= NULL
						, [ParentId]	= NULL
					FROM #LOADSHIPMENTS 
					WHERE intLoadId = @intLoadId
					  AND intLoadDetailId = @intLoadDetailId

					UNION ALL

					SELECT [Id]			= 2
						, [Action]		= NULL
						, [Change]		= 'Update Unit Price'
						, [From]		= CAST(dblLoadPrice AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconPrice AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #LOADSHIPMENTS 
					WHERE intLoadId = @intLoadId
					  AND intLoadDetailId = @intLoadDetailId
					  AND dblLoadPrice <> dblCatReconPrice

					UNION ALL

					SELECT [Id]			= 3
						, [Action]		= NULL
						, [Change]		= 'Update Quantity'
						, [From]		= CAST(dblLoadQty AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #LOADSHIPMENTS 
					WHERE intLoadId = @intLoadId
					  AND intLoadDetailId = @intLoadDetailId
					  AND dblLoadQty <> dblCatReconQty

					UNION ALL

					SELECT [Id]			= 4
						, [Action]		= NULL
						, [Change]		= 'Update Gross Quantity'
						, [From]		= CAST(dblGrossQty AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconGrossQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #LOADSHIPMENTS 
					WHERE intLoadId = @intLoadId
					  AND intLoadDetailId = @intLoadDetailId
					  AND dblGrossQty <> dblCatReconGrossQty

					UNION ALL

					SELECT [Id]			= 5
						, [Action]		= NULL
						, [Change]		= 'Update Net Quantity'
						, [From]		= CAST(dblNetQty AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconGrossQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #LOADSHIPMENTS 
					WHERE intLoadId = @intLoadId
					  AND intLoadDetailId = @intLoadDetailId
					  AND dblNetQty <> dblCatReconGrossQty
					  					
					--AUDIT LOG FOR LOAD SHIPMENT
					EXEC uspSMSingleAuditLog @screenName		= 'Logistics.view.ShipmentSchedule'
											, @recordId			= @intLoadId
											, @entityId			= @intUserId
											, @AuditLogParam	= @LoadShipmentAuditLogParam

					--PO FEED
					EXEC uspIPProcessOrdersToFeed @intLoadId		= @intLoadId
											    , @intLoadDetailId	= @intLoadDetailId
												, @intEntityId		= @intUserId
												, @strRowState		= 'Modified'

					DELETE FROM #LOADSHIPMENTS WHERE intLoadDetailId = @intLoadDetailId
				END
		END


	IF @intTranCount = 0
		COMMIT;
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg varchar(4000) = ERROR_MESSAGE()
	DECLARE @strThrow	 NVARCHAR(MAX) = 'RAISERROR(''' + @strErrorMsg + ''', 11, 1)'
	
	IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @strThrow = 'THROW 51000, ''' + @strErrorMsg + ''', 1'
		
		IF XACT_STATE() = -1
			ROLLBACK;
		IF XACT_STATE() = 1 AND @intTranCount = 0
			ROLLBACK
		IF XACT_STATE() = 1 AND @intTranCount > 0
			ROLLBACK TRANSACTION uspQMUpdateReconIntegration;
	END

	EXEC sp_executesql @strThrow

END CATCH