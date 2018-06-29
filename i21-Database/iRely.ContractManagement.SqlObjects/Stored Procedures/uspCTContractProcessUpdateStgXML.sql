CREATE PROCEDURE [dbo].[uspCTContractProcessUpdateStgXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg									 NVARCHAR(MAX)
	DECLARE @intContractStageId						 INT
	DECLARE @intContractHeaderId					 INT
	DECLARE @strCustomerContract					 NVARCHAR(MAX)
	DECLARE @strContractNumber						 NVARCHAR(MAX)
	DECLARE @strHeaderXML							 NVARCHAR(MAX)
	DECLARE @strDetailXML							 NVARCHAR(MAX)
	DECLARE @strCostXML								 NVARCHAR(MAX)
	DECLARE @strDocumentXML							 NVARCHAR(MAX)
	DECLARE @strReference							 NVARCHAR(MAX)
	DECLARE @strRowState							 NVARCHAR(MAX)
	DECLARE @strFeedStatus							 NVARCHAR(MAX)
	DECLARE @dtmFeedDate							 DATETIME
	DECLARE @strMessage								 NVARCHAR(MAX)
	DECLARE @intMultiCompanyId						 INT
	DECLARE @intEntityId							 INT
	DECLARE @strTransactionType						 NVARCHAR(MAX)
	DECLARE @strTagRelaceXML						 NVARCHAR(MAX)
	DECLARE @NewContractHeaderId					 INT
	DECLARE @NewContractDetailId					 INT
	DECLARE @NewContractCostId						 INT	
	DECLARE @intContractAcknowledgementStageId       INT
	DECLARE @strHeaderCondition						 NVARCHAR(MAX)
	DECLARE @strCostCondition						 NVARCHAR(MAX)
	DECLARE @strContractDetailAllId					 NVARCHAR(MAX)
	DECLARE @strAckHeaderXML						 NVARCHAR(MAX)
	DECLARE @strAckDetailXML						 NVARCHAR(MAX)
	DECLARE @strAckCostXML							 NVARCHAR(MAX)
	DECLARE @strAckDocumentXML						 NVARCHAR(MAX)
	DECLARE @idoc									 INT
	DECLARE @intLastModifiedById					 INT

	DECLARE @tblCTContractHeader AS TABLE
	(
		 intContractHeaderId					 INT
		,intConcurrencyId						 INT
		,intContractTypeId						 INT
		,intEntityId							 INT
		,intBookId								 INT
		,intSubBookId							 INT
		,intCounterPartyId						 INT
		,intEntityContactId						 INT
		,intContractPlanId						 INT
		,intCommodityId							 INT
		,dblQuantity							 NUMERIC(18,6)
		,intCommodityUOMId						 INT
		,strContractNumber						 NVARCHAR(50)
		,dtmContractDate						 DATETIME
		,strCustomerContract					 NVARCHAR(30)
		,strCPContract							 NVARCHAR(30)
		,dtmDeferPayDate						 DATETIME
		,dblDeferPayRate						 NUMERIC(18,6)
		,intContractTextId						 INT
		,ysnSigned								 BIT
		,dtmSigned								 DATETIME
		,ysnPrinted								 BIT
		,intSalespersonId						 INT
		,intGradeId								 INT
		,intWeightId							 INT
		,intCropYearId							 INT
		,strInternalComment						 NVARCHAR(MAX)
		,strPrintableRemarks					 NVARCHAR(MAX)
		,intAssociationId						 INT
		,intTermId								 INT
		,intPricingTypeId						 INT
		,intApprovalBasisId						 INT
		,intContractBasisId						 INT
		,intPositionId							 INT
		,intInsuranceById						 INT
		,intInvoiceTypeId						 INT
		,dblTolerancePct						 NUMERIC(18,6)
		,dblProvisionalInvoicePct				 NUMERIC(18,6)
		,ysnSubstituteItem						 BIT
		,ysnUnlimitedQuantity					 BIT
		,ysnMaxPrice							 BIT
		,intINCOLocationTypeId					 INT
		,intWarehouseId							 INT
		,intCountryId							 INT
		,intCompanyLocationPricingLevelId        INT
		,ysnProvisional							 BIT
		,ysnLoad								 BIT
		,intNoOfLoad							 INT
		,dblQuantityPerLoad						 NUMERIC(18,6)
		,intLoadUOMId							 INT
		,ysnCategory							 BIT
		,ysnMultiplePriceFixation				 BIT
		,intFutureMarketId						 INT
		,intFutureMonthId						 INT
		,dblFutures								 NUMERIC(18,6)
		,dblNoOfLots							 NUMERIC(18,6)
		,intCategoryUnitMeasureId				 INT
		,intLoadCategoryUnitMeasureId			 INT
		,intArbitrationId						 INT
		,intProducerId							 INT
		,ysnClaimsToProducer					 BIT
		,ysnRiskToProducer						 BIT
		,ysnExported							 BIT
		,dtmExported							 DATETIME
		,intCreatedById							 INT
		,dtmCreated								 DATETIME
		,intLastModifiedById					 INT
		,dtmLastModified						 DATETIME
		,ysnMailSent							 BIT
		,strAmendmentLog						 NVARCHAR(MAX)
		,ysnBrokerage							 BIT
		,intCompanyId							 INT
		,intContractHeaderRefId					 INT
	  )
	
	 DECLARE @tblCTContractDetail AS TABLE
	 (
		 intContractDetailId			INT
		,intSplitFromId					INT
		,intParentDetailId				INT
		,ysnSlice						BIT
		,intConcurrencyId				INT
		,intContractHeaderId			INT
		,intContractStatusId			INT
		,intContractSeq					INT
		,intCompanyLocationId			INT
		,dtmStartDate					DATETIME
		,dtmEndDate						DATETIME
		,intFreightTermId				INT
		,intShipViaId					INT
		,intItemContractId				INT
		,intItemId						INT
		,strItemSpecification			NVARCHAR(MAX)
		,intCategoryId					INT
		,dblQuantity					NUMERIC(18,6)
		,intItemUOMId					INT
		,dblOriginalQty					NUMERIC(18,6)
		,dblBalance						NUMERIC(18,6)
		,dblIntransitQty				NUMERIC(18,6)
		,dblScheduleQty					NUMERIC(18,6)
		,dblShippingInstructionQty		NUMERIC(18,6)
		,dblNetWeight				    NUMERIC(18,6)
		,intNetWeightUOMId				INT
		,intUnitMeasureId				INT
		,intCategoryUOMId				INT
		,intNoOfLoad					INT
		,dblQuantityPerLoad				NUMERIC(18,6)
		,intIndexId						INT
		,dblAdjustment					NUMERIC(18,6)
		,intAdjItemUOMId				INT
		,intPricingTypeId				INT
		,intFutureMarketId				INT
		,intFutureMonthId				INT
		,dblFutures						NUMERIC(18,6)
		,dblBasis						NUMERIC(18,6)
		,dblOriginalBasis				NUMERIC(18,6)
		,dblConvertedBasis				NUMERIC(18,6)
		,intBasisCurrencyId				INT
		,intBasisUOMId					INT
		,dblRatio						NUMERIC(18,6)
		,dblCashPrice					NUMERIC(18,6)
		,dblTotalCost					NUMERIC(18,6)
		,intCurrencyId					INT
		,intPriceItemUOMId				INT
		,dblNoOfLots					NUMERIC(18,6)
		,dtmLCDate						DATETIME
		,dtmLastPricingDate				DATETIME
		,dblConvertedPrice				NUMERIC(18,6)
		,intConvPriceCurrencyId			INT
		,intConvPriceUOMId				INT
		,intMarketZoneId				INT
		,intDiscountTypeId				INT
		,intDiscountId					INT
		,intDiscountScheduleId			INT
		,intDiscountScheduleCodeId		INT
		,intStorageScheduleRuleId		INT
		,intContractOptHeaderId			INT
		,strBuyerSeller					NVARCHAR(50)
		,intBillTo						INT
		,intFreightRateId				INT
		,strFobBasis					NVARCHAR(50)
		,intRailGradeId					INT
		,strRailRemark					NVARCHAR(250)
		,strLoadingPointType			NVARCHAR(50)
		,intLoadingPortId				INT
		,strDestinationPointType		NVARCHAR(50)
		,intDestinationPortId			INT
		,strShippingTerm				NVARCHAR(64)
		,intShippingLineId				INT
		,strVessel						NVARCHAR(64)
		,intDestinationCityId			INT
		,intShipperId					INT
		,strRemark						NVARCHAR(MAX)
		,intSubLocationId				INT
		,intStorageLocationId			INT
		,intPurchasingGroupId			INT
		,intFarmFieldId					INT
		,intSplitId						INT
		,strGrade						NVARCHAR(128)
		,strGarden						NVARCHAR(128)
		,strVendorLotID					NVARCHAR(100)
		,strInvoiceNo					NVARCHAR(100)
		,strReference					NVARCHAR(50)
		,strERPPONumber					NVARCHAR(100)
		,strERPItemNumber				NVARCHAR(100)
		,strERPBatchNumber				NVARCHAR(100)
		,intUnitsPerLayer				INT
		,intLayersPerPallet				INT
		,dtmEventStartDate				DATETIME
		,dtmPlannedAvailabilityDate		DATETIME
		,dtmUpdatedAvailabilityDate		DATETIME
		,dtmM2MDate						DATETIME
		,intBookId						INT
		,intSubBookId					INT
		,intContainerTypeId				INT
		,intNumberOfContainers			INT
		,intInvoiceCurrencyId			INT
		,dtmFXValidFrom					DATETIME
		,dtmFXValidTo					DATETIME
		,dblRate						NUMERIC(18,6)
		,dblFXPrice						NUMERIC(18,6)
		,ysnUseFXPrice					BIT
		,intFXPriceUOMId				INT
		,strFXRemarks					NVARCHAR(MAX)
		,dblAssumedFX					NUMERIC(18,6)
		,strFixationBy					NVARCHAR(50)
		,strPackingDescription			NVARCHAR(50)
		,intCurrencyExchangeRateId		INT
		,intRateTypeId					INT
		,intCreatedById					INT
		,dtmCreated						DATETIME
		,intLastModifiedById			INT
		,dtmLastModified				DATETIME
		,ysnInvoice						BIT
		,ysnProvisionalInvoice			BIT
		,ysnQuantityFinal				BIT
		,intProducerId					INT
		,ysnClaimsToProducer			BIT
		,ysnRiskToProducer				BIT
		,ysnBackToBack					BIT
		,dblAllocatedQty				NUMERIC(18,6)
		,dblReservedQty					NUMERIC(18,6)
		,dblAllocationAdjQty			NUMERIC(18,6)
		,dblInvoicedQty					NUMERIC(18,6)
		,ysnPriceChanged				BIT
		,intContractDetailRefId			INT
	 )
	
	 DECLARE @tblCTContractCost AS TABLE
	 (
		 intContractCostId		INT
		,intConcurrencyId		INT
		,intContractDetailId	INT
		,intItemId				INT
		,intVendorId			INT
		,strCostMethod			NVARCHAR(30)
		,intCurrencyId			INT
		,dblRate				NUMERIC(18,6)
		,intItemUOMId			INT
		,intRateTypeId			INT
		,dblFX					NUMERIC(18,6)
		,ysnAccrue				BIT
		,ysnMTM					BIT
		,ysnPrice				BIT
		,ysnAdditionalCost		BIT
		,ysnBasis				BIT
		,ysnReceivable			BIT
		,strPaidBy				NVARCHAR(50)
		,dtmDueDate				DATETIME
		,strReference			NVARCHAR(200)
		,strRemarks				NVARCHAR(MAX)
		,strStatus				NVARCHAR(50)
		,dblReqstdAmount		NUMERIC(18,6)
		,dblRcvdPaidAmount		NUMERIC(18,6)
		,strAPAR				NVARCHAR(100)
		,strPayToReceiveFrom	NVARCHAR(100)
		,strReferenceNo			NVARCHAR(200)
		,intContractCostRefId   INT
	 )

	 DECLARE @tblCTContractDocument AS TABLE
	 (
	     intContractDocumentId		INT
		,intContractHeaderId		INT
		,intDocumentId				INT
		,intConcurrencyId			INT
		,intContractDocumentRefId   INT
	 )

	SELECT @intContractStageId = MIN(intContractStageId)
	FROM tblCTContractStage 
	WHERE strRowState ='Modified' AND ISNULL(strFeedStatus,'')=''
	

	
	WHILE @intContractStageId > 0
	BEGIN
			
			SET @intContractHeaderId	= NULL
			SET @strContractNumber		= NULL
			SET @strHeaderXML			= NULL
			SET @strDetailXML			= NULL
			SET @strCostXML				= NULL
			SET @strDocumentXML			= NULL
			SET @strReference			= NULL
			SET @strRowState			= NULL
			SET @strFeedStatus			= NULL
			SET @dtmFeedDate			= NULL
			SET @strMessage				= NULL
			SET @intMultiCompanyId		= NULL
			SET @intEntityId			= NULL
			SET @strTransactionType		= NULL
			SET @intLastModifiedById	= NULL

			 SELECT
			  @intContractHeaderId	= intContractHeaderId	
			 ,@strContractNumber	= strContractNumber
			 ,@strCustomerContract	= strContractNumber		
			 ,@strHeaderXML			= strHeaderXML		
			 ,@strDetailXML			= strDetailXML		
			 ,@strCostXML			= strCostXML
			 ,@strDocumentXML		= strDocumentXML		
			 ,@strReference			= strReference			
			 ,@strRowState			= strRowState			
			 ,@strFeedStatus		= strFeedStatus			
			 ,@dtmFeedDate			= dtmFeedDate			
			 ,@strMessage			= strMessage			
			 ,@intMultiCompanyId	= intMultiCompanyId
			 ,@intEntityId			= intEntityId			
			 ,@strTransactionType	= strTransactionType
			 FROM tblCTContractStage
			 WHERE intContractStageId = @intContractStageId
			 
			
			 IF @strTransactionType ='Sales Contract'
			 BEGIN
					
					------------------Header------------------------------------------------------
					EXEC sp_xml_preparedocument @idoc OUTPUT,@strHeaderXML

					DELETE FROM @tblCTContractHeader

					INSERT INTO @tblCTContractHeader
					(
						 intContractHeaderId				
						,intConcurrencyId					
						,intContractTypeId					
						,intEntityId						
						,intBookId							
						,intSubBookId						
						,intCounterPartyId					
						,intEntityContactId					
						,intContractPlanId					
						,intCommodityId						
						,dblQuantity						
						,intCommodityUOMId					
						,strContractNumber					
						,dtmContractDate					
						,strCustomerContract				
						,strCPContract						
						,dtmDeferPayDate					
						,dblDeferPayRate					
						,intContractTextId					
						,ysnSigned							
						,dtmSigned							
						,ysnPrinted							
						,intSalespersonId					
						,intGradeId							
						,intWeightId						
						,intCropYearId						
						,strInternalComment					
						,strPrintableRemarks				
						,intAssociationId					
						,intTermId							
						,intPricingTypeId					
						,intApprovalBasisId					
						,intContractBasisId					
						,intPositionId						
						,intInsuranceById					
						,intInvoiceTypeId					
						,dblTolerancePct					
						,dblProvisionalInvoicePct			
						,ysnSubstituteItem					
						,ysnUnlimitedQuantity				
						,ysnMaxPrice						
						,intINCOLocationTypeId				
						,intWarehouseId						
						,intCountryId						
						,intCompanyLocationPricingLevelId   
						,ysnProvisional						
						,ysnLoad							
						,intNoOfLoad						
						,dblQuantityPerLoad					
						,intLoadUOMId						
						,ysnCategory						
						,ysnMultiplePriceFixation			
						,intFutureMarketId					
						,intFutureMonthId					
						,dblFutures							
						,dblNoOfLots						
						,intCategoryUnitMeasureId			
						,intLoadCategoryUnitMeasureId		
						,intArbitrationId					
						,intProducerId						
						,ysnClaimsToProducer				
						,ysnRiskToProducer					
						,ysnExported						
						,dtmExported						
						,intCreatedById						
						,dtmCreated							
						,intLastModifiedById				
						,dtmLastModified					
						,ysnMailSent						
						,strAmendmentLog					
						,ysnBrokerage						
						,intCompanyId						
						,intContractHeaderRefId				
					)
					
					SELECT 
						 intContractHeaderId				
						,intConcurrencyId					
						,intContractTypeId					
						,intEntityId						
						,intBookId							
						,intSubBookId						
						,intCounterPartyId					
						,intEntityContactId					
						,intContractPlanId					
						,intCommodityId						
						,dblQuantity						
						,intCommodityUOMId					
						,strContractNumber					
						,dtmContractDate					
						,strCustomerContract				
						,strCPContract						
						,dtmDeferPayDate					
						,dblDeferPayRate					
						,intContractTextId					
						,ysnSigned							
						,dtmSigned							
						,ysnPrinted							
						,intSalespersonId					
						,intGradeId							
						,intWeightId						
						,intCropYearId						
						,strInternalComment					
						,strPrintableRemarks				
						,intAssociationId					
						,intTermId							
						,intPricingTypeId					
						,intApprovalBasisId					
						,intContractBasisId					
						,intPositionId						
						,intInsuranceById					
						,intInvoiceTypeId					
						,dblTolerancePct					
						,dblProvisionalInvoicePct			
						,ysnSubstituteItem					
						,ysnUnlimitedQuantity				
						,ysnMaxPrice						
						,intINCOLocationTypeId				
						,intWarehouseId						
						,intCountryId						
						,intCompanyLocationPricingLevelId   
						,ysnProvisional						
						,ysnLoad							
						,intNoOfLoad						
						,dblQuantityPerLoad					
						,intLoadUOMId						
						,ysnCategory						
						,ysnMultiplePriceFixation			
						,intFutureMarketId					
						,intFutureMonthId					
						,dblFutures							
						,dblNoOfLots						
						,intCategoryUnitMeasureId			
						,intLoadCategoryUnitMeasureId		
						,intArbitrationId					
						,intProducerId						
						,ysnClaimsToProducer				
						,ysnRiskToProducer					
						,ysnExported						
						,dtmExported						
						,intCreatedById						
						,dtmCreated							
						,intLastModifiedById				
						,dtmLastModified					
						,ysnMailSent						
						,strAmendmentLog					
						,ysnBrokerage						
						,intCompanyId						
						,intContractHeaderRefId		
					FROM OPENXML(@idoc, 'tblCTContractHeaders/tblCTContractHeader', 2) WITH 
					(
							 intContractHeaderId					 INT
							,intConcurrencyId						 INT
							,intContractTypeId						 INT
							,intEntityId							 INT
							,intBookId								 INT
							,intSubBookId							 INT
							,intCounterPartyId						 INT
							,intEntityContactId						 INT
							,intContractPlanId						 INT
							,intCommodityId							 INT
							,dblQuantity							 NUMERIC(18,6)
							,intCommodityUOMId						 INT
							,strContractNumber						 NVARCHAR(50)
							,dtmContractDate						 DATETIME
							,strCustomerContract					 NVARCHAR(30)
							,strCPContract							 NVARCHAR(30)
							,dtmDeferPayDate						 DATETIME
							,dblDeferPayRate						 NUMERIC(18,6)
							,intContractTextId						 INT
							,ysnSigned								 BIT
							,dtmSigned								 DATETIME
							,ysnPrinted								 BIT
							,intSalespersonId						 INT
							,intGradeId								 INT
							,intWeightId							 INT
							,intCropYearId							 INT
							,strInternalComment						 NVARCHAR(MAX)
							,strPrintableRemarks					 NVARCHAR(MAX)
							,intAssociationId						 INT
							,intTermId								 INT
							,intPricingTypeId						 INT
							,intApprovalBasisId						 INT
							,intContractBasisId						 INT
							,intPositionId							 INT
							,intInsuranceById						 INT
							,intInvoiceTypeId						 INT
							,dblTolerancePct						 NUMERIC(18,6)
							,dblProvisionalInvoicePct				 NUMERIC(18,6)
							,ysnSubstituteItem						 BIT
							,ysnUnlimitedQuantity					 BIT
							,ysnMaxPrice							 BIT
							,intINCOLocationTypeId					 INT
							,intWarehouseId							 INT
							,intCountryId							 INT
							,intCompanyLocationPricingLevelId        INT
							,ysnProvisional							 BIT
							,ysnLoad								 BIT
							,intNoOfLoad							 INT
							,dblQuantityPerLoad						 NUMERIC(18,6)
							,intLoadUOMId							 INT
							,ysnCategory							 BIT
							,ysnMultiplePriceFixation				 BIT
							,intFutureMarketId						 INT
							,intFutureMonthId						 INT
							,dblFutures								 NUMERIC(18,6)
							,dblNoOfLots							 NUMERIC(18,6)
							,intCategoryUnitMeasureId				 INT
							,intLoadCategoryUnitMeasureId			 INT
							,intArbitrationId						 INT
							,intProducerId							 INT
							,ysnClaimsToProducer					 BIT
							,ysnRiskToProducer						 BIT
							,ysnExported							 BIT
							,dtmExported							 DATETIME
							,intCreatedById							 INT
							,dtmCreated								 DATETIME
							,intLastModifiedById					 INT
							,dtmLastModified						 DATETIME
							,ysnMailSent							 BIT
							,strAmendmentLog						 NVARCHAR(MAX)
							,ysnBrokerage							 BIT
							,intCompanyId							 INT
							,intContractHeaderRefId					 INT
					)
					
					SELECT @NewContractHeaderId = SH.intContractHeaderId,@intLastModifiedById = CH.intLastModifiedById 
					FROM tblCTContractHeader SH  
					JOIN @tblCTContractHeader CH ON CH.intContractHeaderId = SH.intContractHeaderRefId

					IF EXISTS
					(
						SELECT 1 FROM tblCTContractHeader SH  
						JOIN @tblCTContractHeader CH ON CH.intContractHeaderId = SH.intContractHeaderRefId
						WHERE CH.intBookId <> SH.intBookId
					)
					BEGIN
							EXEC uspCTChangeContractStatus @NewContractHeaderId,3,@intLastModifiedById,'Header'
							
							INSERT INTO tblCTContractAcknowledgementStage 
							(
									 intContractHeaderId
									,strContractAckNumber
									,dtmFeedDate
									,strMessage
									,strTransactionType
									,intMultiCompanyId
									,strBookStatus
							)
							SELECT 
								 @NewContractHeaderId
								,@strContractNumber
								,GETDATE()
								,'Success'
								,@strTransactionType
								,@intMultiCompanyId
								,'BookChanged'
						
						SELECT @intContractAcknowledgementStageId = SCOPE_IDENTITY();

						SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@NewContractHeaderId)
						
						EXEC uspCTGetTableDataInXML 'tblCTContractHeader',@strHeaderCondition,@strAckHeaderXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckHeaderXML =@strAckHeaderXML 
						WHERE   intContractAcknowledgementStageId =@intContractAcknowledgementStageId
                        								 
					END
					
					ELSE
					
					BEGIN

						UPDATE SH 
						SET  
							 SH.intBookId						 = 	CH.intBookId						
							,SH.intSubBookId					 = 	CH.intSubBookId					
							,SH.intCounterPartyId				 = 	CH.intCounterPartyId				
							,SH.intEntityContactId				 = 	CH.intEntityContactId				
							,SH.intContractPlanId				 = 	CH.intContractPlanId				
							,SH.intCommodityId					 = 	CH.intCommodityId					
							,SH.dblQuantity						 = 	CH.dblQuantity						
							,SH.intCommodityUOMId				 = 	CH.intCommodityUOMId				
							,SH.dtmContractDate					 = 	CH.dtmContractDate
							,SH.strCPContract					 = 	CH.strCPContract					
							,SH.dtmDeferPayDate					 = 	CH.dtmDeferPayDate					
							,SH.dblDeferPayRate					 = 	CH.dblDeferPayRate					
							,SH.intContractTextId				 = 	CH.intContractTextId				
							,SH.ysnSigned						 = 	CH.ysnSigned						
							,SH.dtmSigned						 = 	CH.dtmSigned						
							,SH.ysnPrinted						 = 	CH.ysnPrinted						
							,SH.intSalespersonId				 = 	CH.intSalespersonId				
							,SH.intGradeId						 = 	CH.intGradeId						
							,SH.intWeightId						 = 	CH.intWeightId						
							,SH.intCropYearId					 = 	CH.intCropYearId					
							,SH.strInternalComment				 = 	CH.strInternalComment				
							,SH.strPrintableRemarks				 = 	CH.strPrintableRemarks				
							,SH.intAssociationId				 = 	CH.intAssociationId				
							,SH.intTermId						 = 	CH.intTermId						
							,SH.intPricingTypeId				 = 	CH.intPricingTypeId				
							,SH.intApprovalBasisId				 = 	CH.intApprovalBasisId				
							,SH.intContractBasisId				 = 	CH.intContractBasisId				
							,SH.intPositionId					 = 	CH.intPositionId					
							,SH.intInsuranceById				 = 	CH.intInsuranceById				
							,SH.intInvoiceTypeId				 = 	CH.intInvoiceTypeId				
							,SH.dblTolerancePct					 = 	CH.dblTolerancePct					
							,SH.dblProvisionalInvoicePct		 = 	CH.dblProvisionalInvoicePct		
							,SH.ysnSubstituteItem				 = 	CH.ysnSubstituteItem				
							,SH.ysnUnlimitedQuantity			 = 	CH.ysnUnlimitedQuantity			
							,SH.ysnMaxPrice						 = 	CH.ysnMaxPrice						
							,SH.intINCOLocationTypeId			 = 	CH.intINCOLocationTypeId			
							,SH.intWarehouseId					 = 	CH.intWarehouseId					
							,SH.intCountryId					 = 	CH.intCountryId					
							,SH.intCompanyLocationPricingLevelId =  CH.intCompanyLocationPricingLevelId  
							,SH.ysnProvisional					 = 	CH.ysnProvisional					
							,SH.ysnLoad							 = 	CH.ysnLoad							
							,SH.intNoOfLoad						 = 	CH.intNoOfLoad						
							,SH.dblQuantityPerLoad				 = 	CH.dblQuantityPerLoad				
							,SH.intLoadUOMId					 = 	CH.intLoadUOMId					
							,SH.ysnCategory						 = 	CH.ysnCategory						
							,SH.ysnMultiplePriceFixation		 = 	CH.ysnMultiplePriceFixation		
							,SH.intFutureMarketId				 = 	CH.intFutureMarketId				
							,SH.intFutureMonthId				 = 	CH.intFutureMonthId				
							,SH.dblFutures						 = 	CH.dblFutures						
							,SH.dblNoOfLots						 = 	CH.dblNoOfLots						
							,SH.intCategoryUnitMeasureId		 = 	CH.intCategoryUnitMeasureId		
							,SH.intLoadCategoryUnitMeasureId	 = 	CH.intLoadCategoryUnitMeasureId	
							,SH.intArbitrationId				 = 	CH.intArbitrationId				
							,SH.intProducerId					 = 	CH.intProducerId					
							,SH.ysnClaimsToProducer				 = 	CH.ysnClaimsToProducer				
							,SH.ysnRiskToProducer				 = 	CH.ysnRiskToProducer				
							,SH.ysnExported						 = 	CH.ysnExported						
							,SH.dtmExported						 = 	CH.dtmExported						
							,SH.intCreatedById					 = 	CH.intCreatedById					
							,SH.dtmCreated						 = 	CH.dtmCreated						
							,SH.intLastModifiedById				 = 	CH.intLastModifiedById				
							,SH.dtmLastModified					 = 	CH.dtmLastModified					
							,SH.ysnMailSent						 = 	CH.ysnMailSent						
							,SH.strAmendmentLog					 = 	CH.strAmendmentLog					
							,SH.ysnBrokerage					 = 	CH.ysnBrokerage					
							,SH.intCompanyId					 = 	CH.intCompanyId					
						FROM tblCTContractHeader SH  
						JOIN @tblCTContractHeader CH ON CH.intContractHeaderId = SH.intContractHeaderRefId

						INSERT INTO tblCTContractAcknowledgementStage 
						(
								 intContractHeaderId
								,strContractAckNumber
								,dtmFeedDate
								,strMessage
								,strTransactionType
								,intMultiCompanyId
						)
						SELECT 
							 @NewContractHeaderId
							,@strContractNumber
							,GETDATE()
							,'Success'
							,@strTransactionType
							,@intMultiCompanyId

						SELECT @intContractAcknowledgementStageId = SCOPE_IDENTITY();

						SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@NewContractHeaderId)
						
						EXEC uspCTGetTableDataInXML 'tblCTContractHeader',@strHeaderCondition,@strAckHeaderXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckHeaderXML =@strAckHeaderXML 
						WHERE   intContractAcknowledgementStageId =@intContractAcknowledgementStageId
					-----------------------------------Detail-------------------------------------------
						EXEC sp_xml_removedocument @idoc
						EXEC sp_xml_preparedocument @idoc OUTPUT,@strDetailXML

						DELETE FROM @tblCTContractDetail

						INSERT INTO @tblCTContractDetail
						(
							 intContractDetailId		
							,intSplitFromId				
							,intParentDetailId			
							,ysnSlice					
							,intConcurrencyId			
							,intContractHeaderId		
							,intContractStatusId		
							,intContractSeq				
							,intCompanyLocationId		
							,dtmStartDate				
							,dtmEndDate					
							,intFreightTermId			
							,intShipViaId				
							,intItemContractId			
							,intItemId					
							,strItemSpecification		
							,intCategoryId				
							,dblQuantity				
							,intItemUOMId				
							,dblOriginalQty				
							,dblBalance					
							,dblIntransitQty			
							,dblScheduleQty				
							,dblShippingInstructionQty	
							,dblNetWeight				
							,intNetWeightUOMId			
							,intUnitMeasureId			
							,intCategoryUOMId			
							,intNoOfLoad				
							,dblQuantityPerLoad			
							,intIndexId					
							,dblAdjustment				
							,intAdjItemUOMId			
							,intPricingTypeId			
							,intFutureMarketId			
							,intFutureMonthId			
							,dblFutures					
							,dblBasis					
							,dblOriginalBasis			
							,dblConvertedBasis			
							,intBasisCurrencyId			
							,intBasisUOMId				
							,dblRatio					
							,dblCashPrice				
							,dblTotalCost				
							,intCurrencyId				
							,intPriceItemUOMId			
							,dblNoOfLots				
							,dtmLCDate					
							,dtmLastPricingDate			
							,dblConvertedPrice			
							,intConvPriceCurrencyId		
							,intConvPriceUOMId			
							,intMarketZoneId			
							,intDiscountTypeId			
							,intDiscountId				
							,intDiscountScheduleId		
							,intDiscountScheduleCodeId	
							,intStorageScheduleRuleId	
							,intContractOptHeaderId		
							,strBuyerSeller				
							,intBillTo					
							,intFreightRateId			
							,strFobBasis				
							,intRailGradeId				
							,strRailRemark				
							,strLoadingPointType		
							,intLoadingPortId			
							,strDestinationPointType	
							,intDestinationPortId		
							,strShippingTerm			
							,intShippingLineId			
							,strVessel					
							,intDestinationCityId		
							,intShipperId				
							,strRemark					
							,intSubLocationId			
							,intStorageLocationId		
							,intPurchasingGroupId		
							,intFarmFieldId				
							,intSplitId					
							,strGrade					
							,strGarden					
							,strVendorLotID				
							,strInvoiceNo				
							,strReference				
							,strERPPONumber				
							,strERPItemNumber			
							,strERPBatchNumber			
							,intUnitsPerLayer			
							,intLayersPerPallet			
							,dtmEventStartDate			
							,dtmPlannedAvailabilityDate	
							,dtmUpdatedAvailabilityDate	
							,dtmM2MDate					
							,intBookId					
							,intSubBookId				
							,intContainerTypeId			
							,intNumberOfContainers		
							,intInvoiceCurrencyId		
							,dtmFXValidFrom				
							,dtmFXValidTo				
							,dblRate					
							,dblFXPrice					
							,ysnUseFXPrice				
							,intFXPriceUOMId			
							,strFXRemarks				
							,dblAssumedFX				
							,strFixationBy				
							,strPackingDescription		
							,intCurrencyExchangeRateId	
							,intRateTypeId				
							,intCreatedById				
							,dtmCreated					
							,intLastModifiedById		
							,dtmLastModified			
							,ysnInvoice					
							,ysnProvisionalInvoice		
							,ysnQuantityFinal			
							,intProducerId				
							,ysnClaimsToProducer		
							,ysnRiskToProducer			
							,ysnBackToBack				
							,dblAllocatedQty			
							,dblReservedQty				
							,dblAllocationAdjQty		
							,dblInvoicedQty				
							,ysnPriceChanged			
							,intContractDetailRefId		
						)
						SELECT 
							 intContractDetailId		
							,intSplitFromId				
							,intParentDetailId			
							,ysnSlice					
							,intConcurrencyId			
							,intContractHeaderId		
							,intContractStatusId		
							,intContractSeq				
							,intCompanyLocationId		
							,dtmStartDate				
							,dtmEndDate					
							,intFreightTermId			
							,intShipViaId				
							,intItemContractId			
							,intItemId					
							,strItemSpecification		
							,intCategoryId				
							,dblQuantity				
							,intItemUOMId				
							,dblOriginalQty				
							,dblBalance					
							,dblIntransitQty			
							,dblScheduleQty				
							,dblShippingInstructionQty	
							,dblNetWeight				
							,intNetWeightUOMId			
							,intUnitMeasureId			
							,intCategoryUOMId			
							,intNoOfLoad				
							,dblQuantityPerLoad			
							,intIndexId					
							,dblAdjustment				
							,intAdjItemUOMId			
							,intPricingTypeId			
							,intFutureMarketId			
							,intFutureMonthId			
							,dblFutures					
							,dblBasis					
							,dblOriginalBasis			
							,dblConvertedBasis			
							,intBasisCurrencyId			
							,intBasisUOMId				
							,dblRatio					
							,dblCashPrice				
							,dblTotalCost				
							,intCurrencyId				
							,intPriceItemUOMId			
							,dblNoOfLots				
							,dtmLCDate					
							,dtmLastPricingDate			
							,dblConvertedPrice			
							,intConvPriceCurrencyId		
							,intConvPriceUOMId			
							,intMarketZoneId			
							,intDiscountTypeId			
							,intDiscountId				
							,intDiscountScheduleId		
							,intDiscountScheduleCodeId	
							,intStorageScheduleRuleId	
							,intContractOptHeaderId		
							,strBuyerSeller				
							,intBillTo					
							,intFreightRateId			
							,strFobBasis				
							,intRailGradeId				
							,strRailRemark				
							,strLoadingPointType		
							,intLoadingPortId			
							,strDestinationPointType	
							,intDestinationPortId		
							,strShippingTerm			
							,intShippingLineId			
							,strVessel					
							,intDestinationCityId		
							,intShipperId				
							,strRemark					
							,intSubLocationId			
							,intStorageLocationId		
							,intPurchasingGroupId		
							,intFarmFieldId				
							,intSplitId					
							,strGrade					
							,strGarden					
							,strVendorLotID				
							,strInvoiceNo				
							,strReference				
							,strERPPONumber				
							,strERPItemNumber			
							,strERPBatchNumber			
							,intUnitsPerLayer			
							,intLayersPerPallet			
							,dtmEventStartDate			
							,dtmPlannedAvailabilityDate	
							,dtmUpdatedAvailabilityDate	
							,dtmM2MDate					
							,intBookId					
							,intSubBookId				
							,intContainerTypeId			
							,intNumberOfContainers		
							,intInvoiceCurrencyId		
							,dtmFXValidFrom				
							,dtmFXValidTo				
							,dblRate					
							,dblFXPrice					
							,ysnUseFXPrice				
							,intFXPriceUOMId			
							,strFXRemarks				
							,dblAssumedFX				
							,strFixationBy				
							,strPackingDescription		
							,intCurrencyExchangeRateId	
							,intRateTypeId				
							,intCreatedById				
							,dtmCreated					
							,intLastModifiedById		
							,dtmLastModified			
							,ysnInvoice					
							,ysnProvisionalInvoice		
							,ysnQuantityFinal			
							,intProducerId				
							,ysnClaimsToProducer		
							,ysnRiskToProducer			
							,ysnBackToBack				
							,dblAllocatedQty			
							,dblReservedQty				
							,dblAllocationAdjQty		
							,dblInvoicedQty				
							,ysnPriceChanged			
							,intContractDetailRefId		
						FROM OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail', 2) WITH
						(
							 intContractDetailId			INT
							,intSplitFromId					INT
							,intParentDetailId				INT
							,ysnSlice						BIT
							,intConcurrencyId				INT
							,intContractHeaderId			INT
							,intContractStatusId			INT
							,intContractSeq					INT
							,intCompanyLocationId			INT
							,dtmStartDate					DATETIME
							,dtmEndDate						DATETIME
							,intFreightTermId				INT
							,intShipViaId					INT
							,intItemContractId				INT
							,intItemId						INT
							,strItemSpecification			NVARCHAR(MAX)
							,intCategoryId					INT
							,dblQuantity					NUMERIC(18,6)
							,intItemUOMId					INT
							,dblOriginalQty					NUMERIC(18,6)
							,dblBalance						NUMERIC(18,6)
							,dblIntransitQty				NUMERIC(18,6)
							,dblScheduleQty					NUMERIC(18,6)
							,dblShippingInstructionQty		NUMERIC(18,6)
							,dblNetWeight				    NUMERIC(18,6)
							,intNetWeightUOMId				INT
							,intUnitMeasureId				INT
							,intCategoryUOMId				INT
							,intNoOfLoad					INT
							,dblQuantityPerLoad				NUMERIC(18,6)
							,intIndexId						INT
							,dblAdjustment					NUMERIC(18,6)
							,intAdjItemUOMId				INT
							,intPricingTypeId				INT
							,intFutureMarketId				INT
							,intFutureMonthId				INT
							,dblFutures						NUMERIC(18,6)
							,dblBasis						NUMERIC(18,6)
							,dblOriginalBasis				NUMERIC(18,6)
							,dblConvertedBasis				NUMERIC(18,6)
							,intBasisCurrencyId				INT
							,intBasisUOMId					INT
							,dblRatio						NUMERIC(18,6)
							,dblCashPrice					NUMERIC(18,6)
							,dblTotalCost					NUMERIC(18,6)
							,intCurrencyId					INT
							,intPriceItemUOMId				INT
							,dblNoOfLots					NUMERIC(18,6)
							,dtmLCDate						DATETIME
							,dtmLastPricingDate				DATETIME
							,dblConvertedPrice				NUMERIC(18,6)
							,intConvPriceCurrencyId			INT
							,intConvPriceUOMId				INT
							,intMarketZoneId				INT
							,intDiscountTypeId				INT
							,intDiscountId					INT
							,intDiscountScheduleId			INT
							,intDiscountScheduleCodeId		INT
							,intStorageScheduleRuleId		INT
							,intContractOptHeaderId			INT
							,strBuyerSeller					NVARCHAR(50)
							,intBillTo						INT
							,intFreightRateId				INT
							,strFobBasis					NVARCHAR(50)
							,intRailGradeId					INT
							,strRailRemark					NVARCHAR(250)
							,strLoadingPointType			NVARCHAR(50)
							,intLoadingPortId				INT
							,strDestinationPointType		NVARCHAR(50)
							,intDestinationPortId			INT
							,strShippingTerm				NVARCHAR(64)
							,intShippingLineId				INT
							,strVessel						NVARCHAR(64)
							,intDestinationCityId			INT
							,intShipperId					INT
							,strRemark						NVARCHAR(MAX)
							,intSubLocationId				INT
							,intStorageLocationId			INT
							,intPurchasingGroupId			INT
							,intFarmFieldId					INT
							,intSplitId						INT
							,strGrade						NVARCHAR(128)
							,strGarden						NVARCHAR(128)
							,strVendorLotID					NVARCHAR(100)
							,strInvoiceNo					NVARCHAR(100)
							,strReference					NVARCHAR(50)
							,strERPPONumber					NVARCHAR(100)
							,strERPItemNumber				NVARCHAR(100)
							,strERPBatchNumber				NVARCHAR(100)
							,intUnitsPerLayer				INT
							,intLayersPerPallet				INT
							,dtmEventStartDate				DATETIME
							,dtmPlannedAvailabilityDate		DATETIME
							,dtmUpdatedAvailabilityDate		DATETIME
							,dtmM2MDate						DATETIME
							,intBookId						INT
							,intSubBookId					INT
							,intContainerTypeId				INT
							,intNumberOfContainers			INT
							,intInvoiceCurrencyId			INT
							,dtmFXValidFrom					DATETIME
							,dtmFXValidTo					DATETIME
							,dblRate						NUMERIC(18,6)
							,dblFXPrice						NUMERIC(18,6)
							,ysnUseFXPrice					BIT
							,intFXPriceUOMId				INT
							,strFXRemarks					NVARCHAR(MAX)
							,dblAssumedFX					NUMERIC(18,6)
							,strFixationBy					NVARCHAR(50)
							,strPackingDescription			NVARCHAR(50)
							,intCurrencyExchangeRateId		INT
							,intRateTypeId					INT
							,intCreatedById					INT
							,dtmCreated						DATETIME
							,intLastModifiedById			INT
							,dtmLastModified				DATETIME
							,ysnInvoice						BIT
							,ysnProvisionalInvoice			BIT
							,ysnQuantityFinal				BIT
							,intProducerId					INT
							,ysnClaimsToProducer			BIT
							,ysnRiskToProducer				BIT
							,ysnBackToBack					BIT
							,dblAllocatedQty				NUMERIC(18,6)
							,dblReservedQty					NUMERIC(18,6)
							,dblAllocationAdjQty			NUMERIC(18,6)
							,dblInvoicedQty					NUMERIC(18,6)
							,ysnPriceChanged				BIT
							,intContractDetailRefId			INT
						)
						UPDATE SD
						SET  
							 SD.intSplitFromId					= CD.intSplitFromId				
							--,SD.intParentDetailId				= CD.intParentDetailId			
							,SD.ysnSlice						= CD.ysnSlice					
							--,SD.intConcurrencyId				= CD.intConcurrencyId			
							--,SD.intContractHeaderId				= CD.intContractHeaderId		
							,SD.intContractStatusId				= CD.intContractStatusId		
							,SD.intContractSeq					= CD.intContractSeq				
							,SD.intCompanyLocationId			= CD.intCompanyLocationId		
							,SD.dtmStartDate					= CD.dtmStartDate				
							,SD.dtmEndDate						= CD.dtmEndDate					
							,SD.intFreightTermId				= CD.intFreightTermId			
							,SD.intShipViaId					= CD.intShipViaId				
							,SD.intItemContractId				= CD.intItemContractId			
							,SD.intItemId						= CD.intItemId					
							,SD.strItemSpecification			= CD.strItemSpecification		
							,SD.intCategoryId					= CD.intCategoryId				
							,SD.dblQuantity						= CD.dblQuantity				
							,SD.intItemUOMId					= CD.intItemUOMId				
							,SD.dblOriginalQty					= CD.dblOriginalQty				
							,SD.dblBalance						= CD.dblBalance					
							,SD.dblIntransitQty					= CD.dblIntransitQty			
							,SD.dblScheduleQty					= CD.dblScheduleQty				
							,SD.dblShippingInstructionQty		= CD.dblShippingInstructionQty
							,SD.dblNetWeight					= CD.dblNetWeight				
							,SD.intNetWeightUOMId				= CD.intNetWeightUOMId			
							,SD.intUnitMeasureId				= CD.intUnitMeasureId			
							,SD.intCategoryUOMId				= CD.intCategoryUOMId			
							,SD.intNoOfLoad						= CD.intNoOfLoad				
							,SD.dblQuantityPerLoad				= CD.dblQuantityPerLoad			
							,SD.intIndexId						= CD.intIndexId					
							,SD.dblAdjustment					= CD.dblAdjustment				
							,SD.intAdjItemUOMId					= CD.intAdjItemUOMId			
							,SD.intPricingTypeId				= CD.intPricingTypeId			
							,SD.intFutureMarketId				= CD.intFutureMarketId			
							,SD.intFutureMonthId				= CD.intFutureMonthId			
							,SD.dblFutures						= CD.dblFutures					
							,SD.dblBasis						= CD.dblBasis					
							,SD.dblOriginalBasis				= CD.dblOriginalBasis			
							,SD.dblConvertedBasis				= CD.dblConvertedBasis			
							,SD.intBasisCurrencyId				= CD.intBasisCurrencyId			
							,SD.intBasisUOMId					= CD.intBasisUOMId				
							,SD.dblRatio						= CD.dblRatio					
							,SD.dblCashPrice					= CD.dblCashPrice				
							,SD.dblTotalCost					= CD.dblTotalCost				
							,SD.intCurrencyId					= CD.intCurrencyId				
							,SD.intPriceItemUOMId				= CD.intPriceItemUOMId			
							,SD.dblNoOfLots						= CD.dblNoOfLots				
							,SD.dtmLCDate						= CD.dtmLCDate					
							,SD.dtmLastPricingDate				= CD.dtmLastPricingDate			
							,SD.dblConvertedPrice				= CD.dblConvertedPrice			
							,SD.intConvPriceCurrencyId			= CD.intConvPriceCurrencyId		
							,SD.intConvPriceUOMId				= CD.intConvPriceUOMId			
							,SD.intMarketZoneId					= CD.intMarketZoneId			
							,SD.intDiscountTypeId				= CD.intDiscountTypeId			
							,SD.intDiscountId					= CD.intDiscountId				
							,SD.intDiscountScheduleId			= CD.intDiscountScheduleId		
							,SD.intDiscountScheduleCodeId		= CD.intDiscountScheduleCodeId
							,SD.intStorageScheduleRuleId		= CD.intStorageScheduleRuleId	
							,SD.intContractOptHeaderId			= CD.intContractOptHeaderId		
							,SD.strBuyerSeller					= CD.strBuyerSeller				
							,SD.intBillTo						= CD.intBillTo					
							,SD.intFreightRateId				= CD.intFreightRateId			
							,SD.strFobBasis						= CD.strFobBasis				
							,SD.intRailGradeId					= CD.intRailGradeId				
							,SD.strRailRemark					= CD.strRailRemark				
							,SD.strLoadingPointType				= CD.strLoadingPointType		
							,SD.intLoadingPortId				= CD.intLoadingPortId			
							,SD.strDestinationPointType			= CD.strDestinationPointType	
							,SD.intDestinationPortId			= CD.intDestinationPortId		
							,SD.strShippingTerm					= CD.strShippingTerm			
							,SD.intShippingLineId				= CD.intShippingLineId			
							,SD.strVessel						= CD.strVessel					
							,SD.intDestinationCityId			= CD.intDestinationCityId		
							,SD.intShipperId					= CD.intShipperId				
							,SD.strRemark						= CD.strRemark					
							,SD.intSubLocationId				= CD.intSubLocationId			
							,SD.intStorageLocationId			= CD.intStorageLocationId		
							,SD.intPurchasingGroupId			= CD.intPurchasingGroupId		
							,SD.intFarmFieldId					= CD.intFarmFieldId				
							,SD.intSplitId						= CD.intSplitId					
							,SD.strGrade						= CD.strGrade					
							,SD.strGarden						= CD.strGarden					
							,SD.strVendorLotID					= CD.strVendorLotID				
							,SD.strInvoiceNo					= CD.strInvoiceNo				
							,SD.strReference					= CD.strReference				
							,SD.strERPPONumber					= CD.strERPPONumber				
							,SD.strERPItemNumber				= CD.strERPItemNumber			
							,SD.strERPBatchNumber				= CD.strERPBatchNumber			
							,SD.intUnitsPerLayer				= CD.intUnitsPerLayer			
							,SD.intLayersPerPallet				= CD.intLayersPerPallet			
							,SD.dtmEventStartDate				= CD.dtmEventStartDate			
							,SD.dtmPlannedAvailabilityDate		= CD.dtmPlannedAvailabilityDate
							,SD.dtmUpdatedAvailabilityDate		= CD.dtmUpdatedAvailabilityDate
							,SD.dtmM2MDate						= CD.dtmM2MDate					
							,SD.intBookId						= CD.intBookId					
							,SD.intSubBookId					= CD.intSubBookId				
							,SD.intContainerTypeId				= CD.intContainerTypeId			
							,SD.intNumberOfContainers			= CD.intNumberOfContainers		
							,SD.intInvoiceCurrencyId			= CD.intInvoiceCurrencyId		
							,SD.dtmFXValidFrom					= CD.dtmFXValidFrom				
							,SD.dtmFXValidTo					= CD.dtmFXValidTo				
							,SD.dblRate							= CD.dblRate					
							,SD.dblFXPrice						= CD.dblFXPrice					
							,SD.ysnUseFXPrice					= CD.ysnUseFXPrice				
							,SD.intFXPriceUOMId					= CD.intFXPriceUOMId			
							,SD.strFXRemarks					= CD.strFXRemarks				
							,SD.dblAssumedFX					= CD.dblAssumedFX				
							,SD.strFixationBy					= CD.strFixationBy				
							,SD.strPackingDescription			= CD.strPackingDescription		
							,SD.intCurrencyExchangeRateId		= CD.intCurrencyExchangeRateId
							,SD.intRateTypeId					= CD.intRateTypeId				
							,SD.intCreatedById					= CD.intCreatedById				
							,SD.dtmCreated						= CD.dtmCreated					
							,SD.intLastModifiedById				= CD.intLastModifiedById		
							,SD.dtmLastModified					= CD.dtmLastModified			
							,SD.ysnInvoice						= CD.ysnInvoice					
							,SD.ysnProvisionalInvoice			= CD.ysnProvisionalInvoice		
							,SD.ysnQuantityFinal				= CD.ysnQuantityFinal			
							,SD.intProducerId					= CD.intProducerId				
							,SD.ysnClaimsToProducer				= CD.ysnClaimsToProducer		
							,SD.ysnRiskToProducer				= CD.ysnRiskToProducer			
							,SD.ysnBackToBack					= CD.ysnBackToBack				
							,SD.dblAllocatedQty					= CD.dblAllocatedQty			
							,SD.dblReservedQty					= CD.dblReservedQty				
							,SD.dblAllocationAdjQty				= CD.dblAllocationAdjQty		
							,SD.dblInvoicedQty					= CD.dblInvoicedQty				
							,SD.ysnPriceChanged					= CD.ysnPriceChanged	
						FROM tblCTContractDetail SD 
						JOIN @tblCTContractDetail CD ON CD.intContractDetailId = SD.intContractDetailRefId
							
						SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@NewContractHeaderId)
						
						EXEC uspCTGetTableDataInXML 'tblCTContractDetail',@strHeaderCondition,@strAckDetailXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckDetailXML =@strAckDetailXML 
						WHERE   intContractAcknowledgementStageId =@intContractAcknowledgementStageId

					-----------------------------------------Cost-------------------------------------------
						EXEC sp_xml_removedocument  @idoc
						EXEC sp_xml_preparedocument @idoc OUTPUT,@strCostXML

						DELETE FROM @tblCTContractCost

						INSERT INTO @tblCTContractCost
						(
							 intContractCostId	
							,intConcurrencyId	
							,intContractDetailId
							,intItemId			
							,intVendorId		
							,strCostMethod		
							,intCurrencyId		
							,dblRate			
							,intItemUOMId		
							,intRateTypeId		
							,dblFX				
							,ysnAccrue			
							,ysnMTM				
							,ysnPrice			
							,ysnAdditionalCost	
							,ysnBasis			
							,ysnReceivable		
							,strPaidBy			
							,dtmDueDate			
							,strReference		
							,strRemarks			
							,strStatus			
							,dblReqstdAmount	
							,dblRcvdPaidAmount	
							,strAPAR			
							,strPayToReceiveFrom
							,strReferenceNo		
							,intContractCostRefId
                       )
					   SELECT 
					    intContractCostId	
					   ,intConcurrencyId	
					   ,intContractDetailId
					   ,intItemId			
					   ,intVendorId		
					   ,strCostMethod		
					   ,intCurrencyId		
					   ,dblRate			
					   ,intItemUOMId		
					   ,intRateTypeId		
					   ,dblFX				
					   ,ysnAccrue			
					   ,ysnMTM				
					   ,ysnPrice			
					   ,ysnAdditionalCost	
					   ,ysnBasis			
					   ,ysnReceivable		
					   ,strPaidBy			
					   ,dtmDueDate			
					   ,strReference		
					   ,strRemarks			
					   ,strStatus			
					   ,dblReqstdAmount	
					   ,dblRcvdPaidAmount	
					   ,strAPAR			
					   ,strPayToReceiveFrom
					   ,strReferenceNo		
					   ,intContractCostRefId
					FROM OPENXML(@idoc, 'tblCTContractCosts/tblCTContractCost', 2) WITH 
					(
						 intContractCostId		INT
						,intConcurrencyId		INT
						,intContractDetailId	INT
						,intItemId				INT
						,intVendorId			INT
						,strCostMethod			NVARCHAR(30)
						,intCurrencyId			INT
						,dblRate				NUMERIC(18,6)
						,intItemUOMId			INT
						,intRateTypeId			INT
						,dblFX					NUMERIC(18,6)
						,ysnAccrue				BIT
						,ysnMTM					BIT
						,ysnPrice				BIT
						,ysnAdditionalCost		BIT
						,ysnBasis				BIT
						,ysnReceivable			BIT
						,strPaidBy				NVARCHAR(50)
						,dtmDueDate				DATETIME
						,strReference			NVARCHAR(200)
						,strRemarks				NVARCHAR(MAX)
						,strStatus				NVARCHAR(50)
						,dblReqstdAmount		NUMERIC(18,6)
						,dblRcvdPaidAmount		NUMERIC(18,6)
						,strAPAR				NVARCHAR(100)
						,strPayToReceiveFrom	NVARCHAR(100)
						,strReferenceNo			NVARCHAR(200)
						,intContractCostRefId   INT
					)
						
						UPDATE SCost
						SET 
						   -- SCost.intContractCostId			= PCost.intContractCostId	
						   --,SCost.intConcurrencyId			= PCost.intConcurrencyId	
						   --,SCost.intContractDetailId			= PCost.intContractDetailId
						    SCost.intItemId						= PCost.intItemId			
						   ,SCost.intVendorId					= PCost.intVendorId		
						   ,SCost.strCostMethod					= PCost.strCostMethod		
						   ,SCost.intCurrencyId					= PCost.intCurrencyId		
						   ,SCost.dblRate						= PCost.dblRate			
						   ,SCost.intItemUOMId					= PCost.intItemUOMId		
						   ,SCost.intRateTypeId					= PCost.intRateTypeId		
						   ,SCost.dblFX							= PCost.dblFX				
						   ,SCost.ysnAccrue						= PCost.ysnAccrue			
						   ,SCost.ysnMTM						= PCost.ysnMTM				
						   ,SCost.ysnPrice						= PCost.ysnPrice			
						   ,SCost.ysnAdditionalCost				= PCost.ysnAdditionalCost	
						   ,SCost.ysnBasis						= PCost.ysnBasis			
						   ,SCost.ysnReceivable					= PCost.ysnReceivable		
						   ,SCost.strPaidBy						= PCost.strPaidBy			
						   ,SCost.dtmDueDate					= PCost.dtmDueDate			
						   ,SCost.strReference					= PCost.strReference		
						   ,SCost.strRemarks					= PCost.strRemarks			
						   ,SCost.strStatus						= PCost.strStatus			
						   ,SCost.dblReqstdAmount				= PCost.dblReqstdAmount	
						   ,SCost.dblRcvdPaidAmount				= PCost.dblRcvdPaidAmount	
						   ,SCost.strAPAR						= PCost.strAPAR			
						   ,SCost.strPayToReceiveFrom			= PCost.strPayToReceiveFrom
						   ,SCost.strReferenceNo				= PCost.strReferenceNo		
						   --,SCost.intContractCostRefId			= PCost.intContractCostRefId
						FROM  tblCTContractCost  SCost
						JOIN  @tblCTContractCost PCost ON PCost.intContractCostId = SCost.intContractCostRefId

						SELECT @strContractDetailAllId = STUFF((
													SELECT DISTINCT ',' + LTRIM(intContractDetailId)
													FROM tblCTContractDetail
													WHERE intContractHeaderId = @NewContractHeaderId
													FOR XML PATH('')
													), 1, 1, '')

					SELECT @strCostCondition = 'intContractDetailId IN ('+ LTRIM(@strContractDetailAllId)+')'

					EXEC uspCTGetTableDataInXML 'tblCTContractCost',@strCostCondition,@strAckCostXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckCostXML = @strAckCostXML 
						WHERE   intContractAcknowledgementStageId = @intContractAcknowledgementStageId

				------------------------------------------------------------Document-----------------------------------------------------
						EXEC sp_xml_removedocument @idoc
						EXEC sp_xml_preparedocument @idoc OUTPUT,@strDocumentXML

						DELETE FROM @tblCTContractDocument

						INSERT INTO @tblCTContractDocument
						(
							 intContractDocumentId		
							,intContractHeaderId		
							,intDocumentId				
							,intConcurrencyId			
							,intContractDocumentRefId   
						)
						SELECT
						 intContractDocumentId		
						,intContractHeaderId		
						,intDocumentId				
						,intConcurrencyId			
						,intContractDocumentRefId  
						FROM OPENXML(@idoc, 'tblCTContractDocuments/tblCTContractDocument', 2) WITH 
						(
							 intContractDocumentId		INT
							,intContractHeaderId		INT
							,intDocumentId				INT
							,intConcurrencyId			INT
							,intContractDocumentRefId   INT
						)

						UPDATE SDocument
						SET  
							 --SDocument.intContractDocumentId	  = 	PDocument.intContractDocumentId	
							--,SDocument.intContractHeaderId	  = 	PDocument.intContractHeaderId		
							   SDocument.intDocumentId			  = 	PDocument.intDocumentId			
							--,SDocument.intConcurrencyId		  = 	PDocument.intConcurrencyId			
							--,SDocument.intContractDocumentRefId = 	PDocument.intContractDocumentRefId
						FROM tblCTContractDocument  SDocument
						JOIN @tblCTContractDocument PDocument ON PDocument.intContractDocumentId = SDocument.intContractDocumentRefId
						
						EXEC uspCTGetTableDataInXML 'tblCTContractDocument',@strHeaderCondition,@strAckDocumentXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckDocumentXML =@strAckDocumentXML 
						WHERE   intContractAcknowledgementStageId =@intContractAcknowledgementStageId
					
					----------------------------CALL Stored procedure for APPROVAL -----------------------------------------------------------
					
					DECLARE @intCreatedById INT
					SELECT @intCreatedById = intLastModifiedById FROM tblCTContractHeader WHERE intContractHeaderId = @NewContractHeaderId

					DECLARE @config AS ApprovalConfigurationType
					INSERT INTO @config (strApprovalFor, strValue)
					SELECT 'Contract Type', 'Sale'

					EXEC uspSMSubmitTransaction
					  @type = 'ContractManagement.view.Contract',
					  @recordId = @NewContractHeaderId,
					  @transactionNo = @strContractNumber,
					  @transactionEntityId = @intEntityId,
					  @currentUserEntityId = @intCreatedById,
					  @amount = 0,
					  @approverConfiguration = @config 

					--------------------------------------------------------------------------------------------------------------------------
               END

			 END
		
			 UPDATE tblCTContractStage SET strFeedStatus = 'Processed' WHERE intContractStageId = @intContractStageId

		SELECT @intContractStageId = MIN(intContractStageId)
		FROM tblCTContractStage
		WHERE intContractStageId > @intContractStageId
		AND strRowState ='Modified' AND ISNULL(strFeedStatus,'')=''

	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
