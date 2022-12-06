ALTER PROCEDURE [dbo].[uspQMUpdateReconciliationIntegration] 
	  @intCatalogueReconciliationId		INT = NULL	
	, @intUserId						INT = NULL
AS  

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @intTranCount	 			INT
SET @intTranCount = @@trancount;

BEGIN TRY
	IF @intTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION uspQMUpdateReconIntegration
			
    IF OBJECT_ID('tempdb..#VOUCHERS') IS NOT NULL DROP TABLE #VOUCHERS
	IF OBJECT_ID('tempdb..#SAMPLES') IS NOT NULL DROP TABLE #SAMPLES

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
		 , strCatReconGrade						= CRD.intPreInvoiceGradeId
		 , strPreInvoiceGrade					= BD.strComment
    INTO #VOUCHERS 
    FROM tblQMCatalogueReconciliation CR
	INNER JOIN tblQMCatalogueReconciliationDetail CRD ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
	INNER JOIN tblAPBillDetail BD ON CRD.intBillDetailId = BD.intBillDetailId
    INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
	LEFT JOIN tblICCommodityAttribute CA ON CRD.intPreInvoiceGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
    WHERE CR.intCatalogueReconciliationId = @intCatalogueReconciliationId
      AND (CRD.dblPreInvoicePrice <> BD.dblCost
        OR CRD.dblPreInvoiceQuantity <> BD.dblQtyOrdered
        OR CRD.strPreInvoiceChopNo <> BD.strPreInvoiceGardenNumber
        OR CRD.intPreInvoiceGardenMarkId <> BD.intGardenMarkId
        OR CA.strDescription <> BD.strComment)		
	
	--UPDATE BILL DETAIL
	IF EXISTS (SELECT TOP 1 1 FROM #VOUCHERS)
		BEGIN
			UPDATE BD
			SET dblCost						= ISNULL(V.dblCatReconPrice, 0)
			  , dblQtyReceived				= ISNULL(V.dblCatReconQty, 0)
			  , dblQtyOrdered				= ISNULL(V.dblCatReconQty, 0)
			  , strPreInvoiceGardenNumber	= V.strCatReconChopNo
			  , intGardenMarkId				= NULLIF(V.intCatReconGardenMarkId, 0)
			  , strComment					= V.strCatReconGrade
			FROM tblAPBillDetail BD
			INNER JOIN #VOUCHERS V ON V.intBillDetailId = BD.intBillDetailId

			--AUDIT LOG FOR VOUCHERS
			WHILE EXISTS (SELECT TOP 1 1 FROM #VOUCHERS)
				BEGIN
					DECLARE @BillSingleAuditLogParam	AS SingleAuditLogParam 
					DECLARE @intBillId		INT = NULL
						  
					SELECT TOP 1 @intBillId = intBillId
					FROM #VOUCHERS

					--AUDIT LOG FOR VOUCHER	HEADER AND DETAILS			
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
						, [Change]		= 'Update Received'
						, [From]		= CAST(dblPreInvoiceQuantity AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND dblPreInvoiceQuantity <> dblCatReconQty

					UNION ALL

					SELECT [Id]			= 4
						, [Action]		= NULL
						, [Change]		= 'Update Ordered'
						, [From]		= CAST(dblPreInvoiceQuantity AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND dblPreInvoiceQuantity <> dblCatReconQty

					UNION ALL

					SELECT [Id]			= 5
						, [Action]		= NULL
						, [Change]		= 'Update Pre-Invoice Garden Number'
						, [From]		= strPreInvoiceChopNo
						, [To]			= strCatReconChopNo
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND strPreInvoiceChopNo <> strCatReconChopNo

					UNION ALL

					SELECT [Id]			= 6
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

					SELECT [Id]			= 7
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
		 , dblCatReconQty						= CRD.dblPreInvoiceQuantity
		 , dblSampleQty							= S.dblRepresentingQty
		 , strCatReconChopNo					= CRD.strPreInvoiceChopNo
		 , strSampleChopNo						= S.strChopNumber
		 , intCatReconGardenMarkId				= CRD.intPreInvoiceGardenMarkId
		 , intSampleGardenMarkId				= S.intGardenMarkId
		 , intCatReconGradeId					= CRD.intPreInvoiceGradeId
		 , intSampleGradeId						= S.intGradeId
    INTO #SAMPLES 
    FROM tblQMCatalogueReconciliation CR
	INNER JOIN tblQMCatalogueReconciliationDetail CRD ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
	INNER JOIN tblQMSample S ON CRD.intSampleId = S.intSampleId
	INNER JOIN tblMFBatch MFB ON S.intSampleId = MFB.intSampleId
    WHERE CR.intCatalogueReconciliationId = @intCatalogueReconciliationId
      AND (S.dblB1Price <> CRD.dblPreInvoicePrice
        OR S.dblRepresentingQty <> CRD.dblPreInvoiceQuantity
        OR S.strChopNumber <> CRD.strPreInvoiceChopNo
        OR S.intGardenMarkId <> CRD.intPreInvoiceGardenMarkId
        OR S.intGradeId <> CRD.intPreInvoiceGradeId)
	
	--UPDATE SAMPLE
	IF EXISTS (SELECT TOP 1 1 FROM #SAMPLES)
		BEGIN
			UPDATE S
			SET dblB1Price			= ISNULL(SS.dblCatReconPrice, 0)
			  , dblRepresentingQty	= ISNULL(SS.dblCatReconQty, 0)
			  , strChopNumber		= SS.strCatReconChopNo
			  , intGardenMarkId		= NULLIF(SS.intCatReconGardenMarkId, 0)
			  , intGradeId			= NULLIF(SS.intCatReconGradeId, 0)
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
						, [Change]		= 'Update Representing Quantity'
						, [From]		= CAST(dblSampleQty AS NVARCHAR(100))
						, [To]			= CAST(dblCatReconQty AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND dblSampleQty <> dblCatReconQty

					UNION ALL
					
					SELECT [Id]			= 4
						, [Action]		= NULL
						, [Change]		= 'Update Chop Number'
						, [From]		= CAST(strSampleChopNo AS NVARCHAR(100))
						, [To]			= CAST(strCatReconChopNo AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND strSampleChopNo <> strCatReconChopNo

					UNION ALL

					SELECT [Id]			= 5
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

					SELECT [Id]			= 6
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