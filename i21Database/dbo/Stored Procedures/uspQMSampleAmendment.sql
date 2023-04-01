CREATE PROCEDURE [dbo].[uspQMSampleAmendment] 
	  @intSampleId			INT = NULL	
	, @intUserId			INT = NULL
AS  

DECLARE @intTranCount		    INT
DECLARE @intLoadId			    INT = NULL
DECLARE @intLoadDetailId	    INT = NULL
DECLARE @intContractDetailId    INT = NULL
DECLARE @intContractHeaderId    INT = NULL
DECLARE @ysnSuccess			    BIT = 1
DECLARE @strErrorMsg		    NVARCHAR(MAX) = NULL
DECLARE @strCatalogueIds	    NVARCHAR(MAX) = NULL
DECLARE @strMarketZone          NVARCHAR(50) = NULL
DECLARE @dblSamplePrice			NUMERIC(18, 6) = 0
DECLARE @dblSampleQty			NUMERIC(18, 6) = 0

SET @intTranCount = @@trancount;

BEGIN TRY
	IF @intTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION uspQMSampleAmendment

	SELECT TOP 1 @intLoadId			    = LGD.intLoadId
			   , @intLoadDetailId	    = LGD.intLoadDetailId
               , @strMarketZone         = MZ.strMarketZoneCode
               , @intContractDetailId   = S.intContractDetailId
			   , @dblSamplePrice 		= S.dblB1Price
			   , @dblSampleQty			= ISNULL(dbo.fnCalculateQtyBetweenUoms(ITEM.strItemNo, RIUM.strUnitMeasure, SIUM.strUnitMeasure, S.dblRepresentingQty), 0)
			   , @intContractHeaderId	= CD.intContractHeaderId
	FROM tblQMSample S
    INNER JOIN tblMFBatch B ON S.intSampleId = B.intSampleId
    LEFT JOIN tblLGLoadDetail LGD ON B.intBatchId = LGD.intBatchId
    LEFT JOIN tblARMarketZone MZ ON S.intMarketZoneId = MZ.intMarketZoneId
	LEFT JOIN tblCTContractDetail CD ON S.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblICItem ITEM ON ITEM.intItemId = S.intItemId
	LEFT JOIN tblICUnitMeasure SIUM ON SIUM.intUnitMeasureId = S.intSampleUOMId
	LEFT JOIN tblICUnitMeasure RIUM ON RIUM.intUnitMeasureId = S.intRepresentingUOMId
	WHERE S.intSampleId = @intSampleId
	
    --CHECK IF HAS AMENDMENTS    
    IF OBJECT_ID('tempdb..#AMENDMENTS') IS NOT NULL DROP TABLE #AMENDMENTS

    SELECT intSampleId							= S.intSampleId
         , intCatalogueReconciliationId			= CRD.intCatalogueReconciliationId
		 , intCatalogueReconciliationDetailId	= CRD.intCatalogueReconciliationDetailId
         , intBillDetailId						= CRD.intBillDetailId
         , intCatalogueCreatedById				= CR.intEntityId
         , strReconciliationNumber				= CR.strReconciliationNumber
         , ysnPosted							= CR.ysnPosted
         , intBillId							= B.intBillId
         , strBillId							= B.strBillId
         , intBillCreatedById					= B.intEntityId         

		 , dblSamplePrice						= S.dblB1Price
		 , dblPreInvoicePrice					= CRD.dblPreInvoicePrice
		 , dblSampleQty							= ISNULL(@dblSampleQty, 0)
		 , dblPreInvoiceQuantity				= CRD.dblPreInvoiceQuantity
		 , strSampleChopNumber					= S.strChopNumber
		 , strPreInvoiceChopNo					= CRD.strPreInvoiceChopNo
		 , intSampleGardenMarkId				= S.intGardenMarkId
		 , intPreInvoiceGardenMarkId			= CRD.intPreInvoiceGardenMarkId
		 , intSampleGradeId						= S.intGradeId
		 , intPreInvoiceGradeId					= CRD.intPreInvoiceGradeId
    INTO #AMENDMENTS 
    FROM tblQMSample S
    INNER JOIN tblMFBatch BATCH ON S.intSampleId = BATCH.intSampleId
    INNER JOIN tblQMCatalogueReconciliationDetail CRD ON S.intSampleId = CRD.intSampleId
    INNER JOIN tblQMCatalogueReconciliation CR ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
    INNER JOIN tblAPBillDetail BD ON CRD.intBillDetailId = BD.intBillDetailId
    INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
    WHERE S.intSampleId = @intSampleId
      AND (S.dblB1Price <> CRD.dblPreInvoicePrice
        OR ISNULL(@dblSampleQty, 0) <> CRD.dblPreInvoiceQuantity
        OR S.strChopNumber <> CRD.strPreInvoiceChopNo
        OR S.intGardenMarkId <> CRD.intPreInvoiceGardenMarkId
        OR S.intGradeId <> CRD.intPreInvoiceGradeId)
	
	IF EXISTS (SELECT TOP 1 1 FROM #AMENDMENTS)
	BEGIN
        SELECT @strCatalogueIds = LEFT(intCatalogueReconciliationId, LEN(intCatalogueReconciliationId) - 1)
        FROM (
            SELECT DISTINCT CAST(intCatalogueReconciliationId AS VARCHAR(200))  + ', '
            FROM #AMENDMENTS
            WHERE ysnPosted = 1
            FOR XML PATH ('')
        ) C (intCatalogueReconciliationId)

		--UNPOST CAT RECON and VOUCHER
		EXEC dbo.uspQMPostCatalogueReconciliation @strCatalogueIds     = @strCatalogueIds
											    , @intEntityId         = @intUserId
											    , @ysnPost             = 0
											    , @ysnSuccess		   = @ysnSuccess OUT
											    , @strErrorMsg		   = @strErrorMsg OUT

		--UPDATE CAT RECON DETAILS
		UPDATE CRD
		SET dblPreInvoicePrice			= S.dblB1Price
		  , dblBasePrice				= S.dblB1Price
		  , dblPreInvoiceQuantity		= ISNULL(A.dblSampleQty, 0)
		  , dblQuantity					= ISNULL(A.dblSampleQty, 0)
		  , strPreInvoiceChopNo			= S.strChopNumber
		  , strChopNo					= S.strChopNumber
		  , intPreInvoiceGardenMarkId	= S.intGardenMarkId
		  , intGardenMarkId				= S.intGardenMarkId
		  , intPreInvoiceGradeId		= S.intGradeId
		  , intGradeId					= S.intGradeId
		  , ysnMismatched				= CAST(1 AS BIT)
		FROM tblQMCatalogueReconciliationDetail CRD
        INNER JOIN #AMENDMENTS A ON CRD.intCatalogueReconciliationId = A.intCatalogueReconciliationId
		INNER JOIN tblQMSample S ON S.intSampleId = CRD.intSampleId
		WHERE S.intSampleId = @intSampleId

        --UPDATE BILL DETAILS
		UPDATE BD
		SET dblCost							= ISNULL(S.dblB1Price, 0)
		  , dblCashPrice					= ISNULL(S.dblB1Price, 0)
		  , dblQtyReceived					= ISNULL(A.dblSampleQty, 0)
		  , dblQtyOrdered					= ISNULL(A.dblSampleQty, 0)
		  , strPreInvoiceGardenNumber		= S.strChopNumber
		  , intGardenMarkId					= NULLIF(GM.intGardenMarkId, 0)
		  , strComment						= CA.strDescription
		FROM tblAPBillDetail BD 
		INNER JOIN tblQMCatalogueReconciliationDetail CRD ON BD.intBillDetailId = CRD.intBillDetailId
        INNER JOIN #AMENDMENTS A ON CRD.intCatalogueReconciliationId = A.intCatalogueReconciliationId
		INNER JOIN tblQMSample S ON S.intSampleId = CRD.intSampleId
		LEFT JOIN tblQMGardenMark GM ON S.intGardenMarkId = GM.intGardenMarkId
		LEFT JOIN tblICCommodityAttribute CA ON S.intGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
		WHERE S.intSampleId = @intSampleId

		--UPDATE BILL TOTALS
		DECLARE @billIds AS Id

		INSERT INTO @billIds
		SELECT DISTINCT BD.intBillId
		FROM tblAPBillDetail BD 
		INNER JOIN tblQMCatalogueReconciliationDetail CRD ON BD.intBillDetailId = CRD.intBillDetailId
        INNER JOIN #AMENDMENTS A ON CRD.intCatalogueReconciliationId = A.intCatalogueReconciliationId
		INNER JOIN tblQMSample S ON S.intSampleId = CRD.intSampleId
		WHERE S.intSampleId = @intSampleId

		IF EXISTS (SELECT TOP 1 1 FROM @billIds)
			EXEC uspAPUpdateVoucherTotal @billIds
		
		--UPDATE BATCH
        UPDATE B
        SET dblBoughtPrice                  = ISNULL(S.dblB1Price, 0)
          , dblTotalQuantity                = ISNULL(@dblSampleQty, 0)
          , strTeaGardenChopInvoiceNumber   = S.strChopNumber
          , intGardenMarkId                 = S.intGardenMarkId
          , strLeafGrade                    = CA.strDescription
          , intContractDetailId             = @intContractDetailId
        FROM tblMFBatch B
        INNER JOIN tblQMSample S ON S.intSampleId = B.intSampleId
		LEFT JOIN tblICCommodityAttribute CA ON S.intGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
        WHERE B.intSampleId = @intSampleId

        --PO UPDATE
        IF @intLoadId IS NOT NULL 
            BEGIN 
                --UNPOST LOAD SHIPMENT
                EXEC dbo.uspLGPostLoadSchedule @intLoadId               = @intLoadId
                                             , @intEntityUserSecurityId = @intUserId
                                             , @ysnPost                 = 0
                                             , @ysnRecap                = 0

                IF @intContractDetailId IS NOT NULL
                    BEGIN
						--UPDATE LOAD SHIPMENT
                        UPDATE tblLGLoadDetail
                        SET intPContractDetailId = @intContractDetailId
                        WHERE intLoadId = @intLoadId
                          AND intLoadDetailId = @intLoadDetailId

						UPDATE tblLGLoadDetail
                        SET dblUnitPrice = @dblSamplePrice
                        WHERE intLoadId = @intLoadId
                          AND intLoadDetailId = @intLoadDetailId
						  AND dblUnitPrice <> @dblSamplePrice

						UPDATE tblLGLoadDetail
                        SET dblQuantity = ISNULL(@dblSampleQty, 0)
                        WHERE intLoadId = @intLoadId
                          AND intLoadDetailId = @intLoadDetailId
						  AND dblQuantity <> ISNULL(@dblSampleQty, 0)

						--AUDIT LOG FOR LOAD SHIPMENT
						DECLARE @LoadShipmentSingleAuditLogParam		AS SingleAuditLogParam

						INSERT INTO @LoadShipmentSingleAuditLogParam (
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
						FROM tblLGLoad
						WHERE intLoadId = @intLoadId

						UNION ALL

						SELECT [Id]			= 2
							, [Action]		= NULL
							, [Change]		= 'Update Price'
							, [From]		= CAST(dblUnitPrice AS NVARCHAR(100))
							, [To]			= CAST(@dblSamplePrice AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM tblLGLoadDetail
						WHERE intLoadId = @intLoadId
                          AND intLoadDetailId = @intLoadDetailId
						  AND dblUnitPrice <> @dblSamplePrice

						UNION ALL

						SELECT [Id]			= 3
							, [Action]		= NULL
							, [Change]		= 'Update Quantity'
							, [From]		= CAST(dblQuantity AS NVARCHAR(100))
							, [To]			= CAST(@dblSampleQty AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM tblLGLoadDetail
						WHERE intLoadId = @intLoadId
                          AND intLoadDetailId = @intLoadDetailId
						  AND dblQuantity <> @dblSampleQty

						--AUDIT LOG FOR VOUCHER
						EXEC uspSMSingleAuditLog @screenName		= 'Logistics.view.ShipmentSchedule'
											   , @recordId			= @intLoadId
											   , @entityId			= @intUserId
											   , @AuditLogParam		= @LoadShipmentSingleAuditLogParam

						--UPDATE CONTRACT DETAILS
						UPDATE tblCTContractDetail
						SET dblCashPrice = @dblSamplePrice
						WHERE intContractHeaderId = @intContractHeaderId
                          AND intContractDetailId = @intContractDetailId
						  AND dblCashPrice <> @dblSamplePrice

						UPDATE tblCTContractDetail
						SET dblQuantity = @dblSampleQty
						WHERE intContractHeaderId = @intContractHeaderId
                          AND intContractDetailId = @intContractDetailId
						  AND dblQuantity <> @dblSampleQty

						--AUDIT LOG FOR CONTRACT
						DECLARE @ContractSingleAuditLogParam		AS SingleAuditLogParam

						INSERT INTO @ContractSingleAuditLogParam (
							  [Id]
							, [Action]
							, [Change]
							, [From]
							, [To]
							, [ParentId]
						)
						SELECT [Id]			= 1
							, [Action]		= 'Update Amendments'
							, [Change]		= 'Updated - Record: ' + CAST(intContractHeaderId AS NVARCHAR(100))
							, [From]		= NULL
							, [To]			= NULL
							, [ParentId]	= NULL
						FROM tblCTContractHeader
						WHERE intContractHeaderId = @intContractHeaderId

						UNION ALL

						SELECT [Id]			= 2
							, [Action]		= NULL
							, [Change]		= 'Update Price'
							, [From]		= CAST(dblCashPrice AS NVARCHAR(100))
							, [To]			= CAST(@dblSamplePrice AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM tblCTContractDetail
						WHERE intContractHeaderId = @intContractHeaderId
                          AND intContractDetailId = @intContractDetailId
						  AND dblCashPrice <> @dblSamplePrice

						UNION ALL

						SELECT [Id]			= 3
							, [Action]		= NULL
							, [Change]		= 'Update Quantity'
							, [From]		= CAST(dblQuantity AS NVARCHAR(100))
							, [To]			= CAST(@dblSampleQty AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM tblCTContractDetail
						WHERE intContractHeaderId = @intContractHeaderId
                          AND intContractDetailId = @intContractDetailId
						  AND dblQuantity <> @dblSampleQty

						--AUDIT LOG FOR VOUCHER
						EXEC uspSMSingleAuditLog @screenName		= 'ContractManagement.view.ContractSequence'
											   , @recordId			= @intContractHeaderId
											   , @entityId			= @intUserId
											   , @AuditLogParam		= @ContractSingleAuditLogParam
                    END 

                IF @intLoadDetailId IS NOT NULL
                    EXEC uspIPProcessOrdersToFeed @intLoadId, @intLoadDetailId, @intUserId, 'Modified'
            END

        --APPROVAL AND AUDIT LOG
        WHILE EXISTS (SELECT TOP 1 1 FROM #AMENDMENTS)
            BEGIN 
                DECLARE @configCatRecon						AS ApprovalConfigurationType
                DECLARE @configBillDetails					AS ApprovalConfigurationType
				DECLARE @CatReconSingleAuditLogParam		AS SingleAuditLogParam
				DECLARE @BillSingleAuditLogParam			AS SingleAuditLogParam
                DECLARE @intCatalogueReconciliationId		INT = NULL					  
                      , @intCatalogueCreatedById			INT = NULL
                      , @strReconciliationNumber			NVARCHAR(50) = NULL
					  
                SELECT TOP 1 @intCatalogueReconciliationId			= intCatalogueReconciliationId
                           , @intCatalogueCreatedById				= intCatalogueCreatedById
						   , @strReconciliationNumber				= strReconciliationNumber						   
                FROM #AMENDMENTS

				DELETE FROM @CatReconSingleAuditLogParam
				DELETE FROM @BillSingleAuditLogParam

				--AUDIT LOG FOR CAT RECON HEADER				
				INSERT INTO @CatReconSingleAuditLogParam (
					  [Id]
					, [Action]
					, [Change]
					, [From]
					, [To]
					, [ParentId]
				)
				SELECT [Id]			= 1
					, [Action]		= 'Update Amendments'
					, [Change]		= 'Updated - Record: ' + CAST(intCatalogueReconciliationId AS NVARCHAR(100))
					, [From]		= NULL
					, [To]			= NULL
					, [ParentId]	= NULL
				FROM tblQMCatalogueReconciliation 
				WHERE intCatalogueReconciliationId = @intCatalogueReconciliationId
							
                WHILE EXISTS (SELECT TOP 1 1 FROM #AMENDMENTS WHERE intCatalogueReconciliationId = @intCatalogueReconciliationId)
					BEGIN 
						DECLARE @intCatalogueReconciliationDetailId	INT = NULL
							  , @intBillId							INT = NULL
							  , @intBillDetailId					INT = NULL
							  , @intBillCreatedById					INT = NULL
							  , @strBillId							NVARCHAR(50) = NULL

						SELECT TOP 1 @intCatalogueReconciliationDetailId	= intCatalogueReconciliationDetailId
                                   , @intBillId								= intBillId
								   , @intBillDetailId						= intBillDetailId
                                   , @intBillCreatedById					= intBillCreatedById                           
                                   , @strBillId								= strBillId
						FROM #AMENDMENTS
						WHERE intCatalogueReconciliationId = @intCatalogueReconciliationId

						--AUDIT LOG FOR CAT RECON DETAILS	
						INSERT INTO @CatReconSingleAuditLogParam (
							  [Id]
							, [Action]
							, [Change]
							, [From]
							, [To]
							, [ParentId]
						)
						SELECT [Id]			= 2
							, [Action]		= NULL
							, [Change]		= 'Update Pre-Invoice Price'
							, [From]		= CAST(dblPreInvoicePrice AS NVARCHAR(100))
							, [To]			= CAST(dblSamplePrice AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS 
						WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND dblPreInvoicePrice <> dblSamplePrice

						UNION ALL

						SELECT [Id]			= 3
							, [Action]		= NULL
							, [Change]		= 'Update Pre-Invoice Quantity'
							, [From]		= CAST(dblPreInvoiceQuantity AS NVARCHAR(100))
							, [To]			= CAST(dblSampleQty AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS 
						WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND dblPreInvoiceQuantity <> dblSampleQty

						UNION ALL

						SELECT [Id]			= 4
							, [Action]		= NULL
							, [Change]		= 'Update Pre-Invoice Chop Number'
							, [From]		= strPreInvoiceChopNo
							, [To]			= strSampleChopNumber
							, [ParentId]	= 1
						FROM #AMENDMENTS 
						WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND strPreInvoiceChopNo <> strSampleChopNumber

						UNION ALL

						SELECT [Id]			= 5
							, [Action]		= NULL
							, [Change]		= 'Update Pre-Invoice Garden Mark'
							, [From]		= CAST(GM.strGardenMark AS NVARCHAR(100))
							, [To]			= CAST(AGM.strGardenMark AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS A
						LEFT JOIN tblQMGardenMark GM ON A.intPreInvoiceGardenMarkId = GM.intGardenMarkId
						LEFT JOIN tblQMGardenMark AGM ON A.intSampleGardenMarkId = AGM.intGardenMarkId
						WHERE A.intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND A.intPreInvoiceGardenMarkId <> A.intSampleGardenMarkId

						UNION ALL

						SELECT [Id]			= 6
							, [Action]		= NULL
							, [Change]		= 'Update Pre-Invoice Grade'
							, [From]		= CAST(CA.strDescription AS NVARCHAR(100))
							, [To]			= CAST(ACA.strDescription AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS A
						LEFT JOIN tblICCommodityAttribute CA ON A.intPreInvoiceGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
						LEFT JOIN tblICCommodityAttribute ACA ON A.intSampleGradeId = ACA.intCommodityAttributeId AND ACA.strType = 'Grade'
						WHERE A.intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND A.intPreInvoiceGradeId <> A.intSampleGradeId
						  
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
						FROM #AMENDMENTS 
						WHERE intBillDetailId = @intBillDetailId

						UNION ALL

						SELECT [Id]			= 2
							, [Action]		= NULL
							, [Change]		= 'Update Cost'
							, [From]		= CAST(dblPreInvoicePrice AS NVARCHAR(100))
							, [To]			= CAST(dblSamplePrice AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS 
						WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND dblPreInvoicePrice <> dblSamplePrice

						UNION ALL

						SELECT [Id]			= 3
							, [Action]		= NULL
							, [Change]		= 'Update Cash Price'
							, [From]		= CAST(dblPreInvoicePrice AS NVARCHAR(100))
							, [To]			= CAST(dblSamplePrice AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS 
						WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND dblPreInvoicePrice <> dblSamplePrice

						UNION ALL

						SELECT [Id]			= 4
							, [Action]		= NULL
							, [Change]		= 'Update Received'
							, [From]		= CAST(dblPreInvoiceQuantity AS NVARCHAR(100))
							, [To]			= CAST(dblSampleQty AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS 
						WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND dblPreInvoiceQuantity <> dblSampleQty

						UNION ALL

						SELECT [Id]			= 5
							, [Action]		= NULL
							, [Change]		= 'Update Ordered'
							, [From]		= CAST(dblPreInvoiceQuantity AS NVARCHAR(100))
							, [To]			= CAST(dblSampleQty AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS 
						WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND dblPreInvoiceQuantity <> dblSampleQty

						UNION ALL

						SELECT [Id]			= 6
							, [Action]		= NULL
							, [Change]		= 'Update Pre-Invoice Garden Number'
							, [From]		= strPreInvoiceChopNo
							, [To]			= strSampleChopNumber
							, [ParentId]	= 1
						FROM #AMENDMENTS 
						WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND strPreInvoiceChopNo <> strSampleChopNumber

						UNION ALL

						SELECT [Id]			= 7
							, [Action]		= NULL
							, [Change]		= 'Update Garden Mark'
							, [From]		= CAST(GM.strGardenMark AS NVARCHAR(100))
							, [To]			= CAST(AGM.strGardenMark AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS A
						LEFT JOIN tblQMGardenMark GM ON A.intPreInvoiceGardenMarkId = GM.intGardenMarkId
						LEFT JOIN tblQMGardenMark AGM ON A.intSampleGardenMarkId = AGM.intGardenMarkId
						WHERE A.intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND A.intPreInvoiceGardenMarkId <> A.intSampleGardenMarkId

						UNION ALL

						SELECT [Id]			= 8
							, [Action]		= NULL
							, [Change]		= 'Update Comment'
							, [From]		= CAST(CA.strDescription AS NVARCHAR(100))
							, [To]			= CAST(ACA.strDescription AS NVARCHAR(100))
							, [ParentId]	= 1
						FROM #AMENDMENTS A
						LEFT JOIN tblICCommodityAttribute CA ON A.intPreInvoiceGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
						LEFT JOIN tblICCommodityAttribute ACA ON A.intSampleGradeId = ACA.intCommodityAttributeId AND ACA.strType = 'Grade'
						WHERE A.intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
						  AND A.intPreInvoiceGradeId <> A.intSampleGradeId
						  
						--AUDIT LOG FOR VOUCHER
						EXEC uspSMSingleAuditLog @screenName		= 'AccountsPayable.view.Voucher'
											   , @recordId			= @intBillId
											   , @entityId			= @intUserId
											   , @AuditLogParam		= @BillSingleAuditLogParam

						--APPROVAL FOR VOUCHER
						EXEC uspSMSubmitTransaction @type					= 'AccountsPayable.view.Voucher'
												  , @recordId				= @intBillId
												  , @transactionNo			= @strBillId
												  , @transactionEntityId	= @intBillCreatedById
												  , @currentUserEntityId	= @intUserId
												  , @amount					= 0
												  , @approverConfiguration	= @configBillDetails

						DELETE FROM #AMENDMENTS WHERE intCatalogueReconciliationDetailId = @intCatalogueReconciliationDetailId
					END
				
				--AUDIT LOG FOR CAT RECON
				EXEC uspSMSingleAuditLog @screenName		= 'Quality.view.CatalogueReconciliation'
									   , @recordId			= @intCatalogueReconciliationId
									   , @entityId			= @intUserId
									   , @AuditLogParam		= @CatReconSingleAuditLogParam
				
				--APPROVAL FOR CAT RECON
				EXEC uspSMSubmitTransaction @type					= 'Quality.view.CatalogueReconciliation'
										  , @recordId				= @intCatalogueReconciliationId
										  , @transactionNo			= @strReconciliationNumber
										  , @transactionEntityId	= @intCatalogueCreatedById
										  , @currentUserEntityId	= @intUserId
										  , @amount					= 0
										  , @approverConfiguration	= @configCatRecon

				

                DELETE FROM #AMENDMENTS WHERE intCatalogueReconciliationId = @intCatalogueReconciliationId
            END
	END 
        
	IF @intTranCount = 0
		COMMIT;
END TRY
BEGIN CATCH
	SET @strErrorMsg = ERROR_MESSAGE()
	DECLARE @strThrow	 NVARCHAR(MAX) = 'RAISERROR(''' + @strErrorMsg + ''', 11, 1)'
	
	IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @strThrow = 'THROW 51000, ''' + @strErrorMsg + ''', 1'
		
		IF XACT_STATE() = -1
			ROLLBACK;
		IF XACT_STATE() = 1 AND @intTranCount = 0
			ROLLBACK
		IF XACT_STATE() = 1 AND @intTranCount > 0
			ROLLBACK TRANSACTION uspQMSampleAmendment;
	END

	EXEC sp_executesql @strThrow

END CATCH