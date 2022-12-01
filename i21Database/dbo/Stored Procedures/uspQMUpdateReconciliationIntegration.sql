CREATE PROCEDURE [dbo].[uspQMUpdateReconciliationIntegration] 
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
		SAVE TRANSACTION uspARUpdateInvoiceIntegrations
			
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
		 , intCatReconGardenMarkId				= GM.intGardenMarkId
		 , intPreInvoiceGardenMarkId			= BD.intGardenMarkId
		 , strCatReconGrade						= CRD.strPreInvoiceGrade
		 , strPreInvoiceGrade					= BD.strComment
    INTO #VOUCHERS 
    FROM tblQMCatalogueReconciliation CR
	INNER JOIN tblQMCatalogueReconciliationDetail CRD ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
	INNER JOIN tblAPBillDetail BD ON CRD.intBillDetailId = BD.intBillDetailId
    INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
	LEFT JOIN tblQMGardenMark GM ON CRD.strPreInvoiceGarden = GM.strGardenMark
    WHERE CR.intCatalogueReconciliationId = @intCatalogueReconciliationId
      AND (CRD.dblPreInvoicePrice <> BD.dblCost
        OR CRD.dblPreInvoiceQuantity <> BD.dblQtyOrdered
        OR CRD.strPreInvoiceChopNo <> BD.strPreInvoiceGardenNumber
        OR GM.intGardenMarkId <> BD.intGardenMarkId
        OR CRD.strPreInvoiceGrade <> BD.strComment)		
	
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
			WHILE EXISTS (SELECT TOP 1 1 #VOUCHERS)
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
						, [From]		= CAST(intPreInvoiceGardenMarkId AS NVARCHAR(100))
						, [To]			= CAST(intCatReconGardenMarkId AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND intPreInvoiceGardenMarkId <> intCatReconGardenMarkId

					UNION ALL

					SELECT [Id]			= 7
						, [Action]		= NULL
						, [Change]		= 'Update Comment'
						, [From]		= CAST(strPreInvoiceGrade AS NVARCHAR(100))
						, [To]			= CAST(strCatReconGrade AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #VOUCHERS 
					WHERE intBillId = @intBillId
					  AND strPreInvoiceGrade <> strCatReconGrade
						  
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
		 , dblSampleQty							= S.dblB1QtyBought
		 , strCatReconChopNo					= CRD.strPreInvoiceChopNo
		 , strSampleChopNo						= S.strChopNumber
		 , intCatReconGardenMarkId				= GM.intGardenMarkId
		 , intSampleGardenMarkId				= S.intGardenMarkId
		 , intCatReconGradeId					= CA.intCommodityAttributeId
		 , intSampleGradeId						= S.intGradeId
    INTO #SAMPLES 
    FROM tblQMCatalogueReconciliation CR
	INNER JOIN tblQMCatalogueReconciliationDetail CRD ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
	INNER JOIN tblQMSample S ON CRD.intSampleId = S.intSampleId
	--INNER JOIN tblMFBatch MFB ON S.intSampleId = MFB.intSampleId	
	LEFT JOIN tblQMGardenMark GM ON CRD.strPreInvoiceGarden = GM.strGardenMark
    LEFT JOIN tblICCommodityAttribute CA ON CRD.strPreInvoiceGrade = CA.strDescription AND CA.strType = 'Grade'	
    WHERE CR.intCatalogueReconciliationId = @intCatalogueReconciliationId
      AND (S.dblB1Price <> CRD.dblPreInvoicePrice
        OR S.dblB1QtyBought <> CRD.dblPreInvoiceQuantity
        OR S.strChopNumber <> CRD.strPreInvoiceChopNo
        OR S.intGardenMarkId <> GM.intGardenMarkId
        OR S.intGradeId <> CA.intCommodityAttributeId)
	
	--UPDATE SAMPLE
	IF EXISTS (SELECT TOP 1 1 FROM #SAMPLES)
		BEGIN
			UPDATE S
			SET dblB1Price			= ISNULL(SS.dblCatReconPrice, 0)
			  , dblB1QtyBought		= ISNULL(SS.dblCatReconQty, 0)
			  , strChopNumber		= SS.strCatReconChopNo
			  , intGardenMarkId		= NULLIF(SS.intCatReconGardenMarkId, 0)
			  , intGradeId			= NULLIF(SS.intCatReconGradeId, 0)
			FROM tblQMSample S
			INNER JOIN #SAMPLES SS ON S.intSampleId = SS.intSampleId

			--AUDIT LOG FOR SAMPLES
			WHILE EXISTS (SELECT TOP 1 1 #SAMPLES)
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
						, [Change]		= 'Update Initial Bought Qty'
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
						, [From]		= strSampleChopNo
						, [To]			= strCatReconChopNo
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND strSampleChopNo <> strCatReconChopNo

					UNION ALL

					SELECT [Id]			= 5
						, [Action]		= NULL
						, [Change]		= 'Update Garden Mark'
						, [From]		= CAST(intSampleGardenMarkId AS NVARCHAR(100))
						, [To]			= CAST(intCatReconGardenMarkId AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND intSampleGardenMarkId <> intCatReconGardenMarkId

					UNION ALL

					SELECT [Id]			= 6
						, [Action]		= NULL
						, [Change]		= 'Update Grade'
						, [From]		= CAST(intSampleGradeId AS NVARCHAR(100))
						, [To]			= CAST(intCatReconGradeId AS NVARCHAR(100))
						, [ParentId]	= 1
					FROM #SAMPLES 
					WHERE intSampleId = @intSampleId
					  AND intSampleGradeId <> intCatReconGradeId
						  
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
			ROLLBACK TRANSACTION uspARUpdateInvoiceIntegrations;
	END

	EXEC sp_executesql @strThrow

END CATCH