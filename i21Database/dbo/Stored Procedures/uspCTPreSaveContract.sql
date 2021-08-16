CREATE PROCEDURE [dbo].[uspCTPreSaveContract]		
	@xmlDWG					NVARCHAR(MAX),
	@xmlContractHeaders		NVARCHAR(MAX),
	@xmlContractDetails		NVARCHAR(MAX)
	
AS

BEGIN TRY	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@idoc						INT,
			@strProcess					NVARCHAR(50) = '',
			@Condition					NVARCHAR(100),
			
			--@p_strXML					NVARCHAR(MAX),
			@v_strXML					NVARCHAR(MAX),
			@vd_strXML					NVARCHAR(MAX),
			@v_intStartingNumberId		INT,
			@v_intPatternCode			INT,
			@v_intEntityId				INT = NULL,
			@v_strPatternString			NVARCHAR(50),
			@v_strContractNumber		NVARCHAR(50),
			@v_RowState					NVARCHAR(50),
			@vd_RowState				NVARCHAR(50),
			
			@intContractHeaderId		INT,
			@intContractDetailId		INT
			
	DECLARE @returnTable TABLE
	(
		intContractHeaderId INT,
		strContractNumber NVARCHAR (50)
	)	
			
	-----------------------------------------------------------------------
	----------  V A L I D A T E   D W G   S H O R T   C L O S E  ----------
	-----------------------------------------------------------------------
	IF @xmlDWG <> ''
	BEGIN
		DECLARE @_dwgContractHeaderId INT
			, @_dwgContractDetailId INT
			, @_dwgContractStatusId INT
			
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlDWG

		IF OBJECT_ID('tempdb..#ProcessDWG') IS NOT NULL  	
			DROP TABLE #ProcessDWG

		SELECT * INTO #ProcessDWG
		FROM OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail', 2)
		WITH (intContractHeaderId INT, intContractDetailId INT, intContractStatusId INT)
		
		WHILE EXISTS (SELECT TOP 1 1 FROM #ProcessDWG)
		BEGIN
			SELECT TOP 1 @_dwgContractHeaderId = intContractHeaderId
				, @_dwgContractDetailId = intContractDetailId
				, @_dwgContractStatusId = intContractStatusId
			FROM #ProcessDWG
			
			DECLARE	@intContractStatusId INT
				, @dblBalance NUMERIC(18, 6)
				, @intShortCloseStatusId INT
			
			SELECT TOP 1 @intContractStatusId = intContractStatusId, @dblBalance = dblBalance FROM tblCTContractDetail WHERE intContractDetailId = @_dwgContractDetailId
			SELECT TOP 1 @intShortCloseStatusId = intContractStatusId FROM tblCTContractStatus WHERE strContractStatus = 'Short Close'

			IF @intShortCloseStatusId > 0 AND @_dwgContractStatusId = @intShortCloseStatusId AND @intContractStatusId <> @intShortCloseStatusId
			BEGIN
				DECLARE @ysnDestinationWeight BIT = 0
					, @ysnDestinationGrade BIT = 0
				
				SELECT TOP 1 @ysnDestinationWeight = CASE WHEN ISNULL(w.intWeightGradeId, 0) <> 0 THEN 1 ELSE 0 END
					, @ysnDestinationGrade = CASE WHEN ISNULL(g.intWeightGradeId, 0) <> 0 THEN 1 ELSE 0 END
				FROM tblCTContractHeader ch
				LEFT JOIN tblCTWeightGrade w ON w.intWeightGradeId = ch.intWeightId AND w.strWhereFinalized = 'Destination'
				LEFT JOIN tblCTWeightGrade g ON g.intWeightGradeId = ch.intGradeId AND g.strWhereFinalized = 'Destination'
				WHERE intContractHeaderId = @_dwgContractHeaderId

				IF (@ysnDestinationWeight = 1 OR @ysnDestinationGrade = 1)
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblSCTicket WHERE ysnDestinationWeightGradePost IS NOT NULL AND ysnDestinationWeightGradePost <> 0 AND intContractId = @_dwgContractDetailId)
					BEGIN
						SET @ErrMsg = 'Pending Destination Weights / Grades, unable to short close.'
						RAISERROR(@ErrMsg,16,1)
					END
				END
			END	

			DELETE FROM #ProcessDWG WHERE intContractHeaderId = @_dwgContractHeaderId AND intContractDetailId = @_dwgContractDetailId
		END
	END


	-----------------------------------------------------------------------
	--  P R O C E S S / V A L I D A T E  C O N T R A C T  H E A D E R S  --
	-----------------------------------------------------------------------
	IF @xmlContractHeaders <> ''
	BEGIN
		DECLARE @intEntityId INT
			, @strHeaderRowState NVARCHAR(50)
		
		SET @strProcess = 'Process Contract Headers'
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlContractHeaders

		IF OBJECT_ID('tempdb..#ProcessContractHeaders') IS NOT NULL
			DROP TABLE #ProcessContractHeaders

		SELECT * INTO #ProcessContractHeaders
		FROM OPENXML(@idoc, 'tblCTContractHeaders/tblCTContractHeader', 2)
		WITH
		(
			-- Process Contract Headers
			intContractHeaderId INT,
			intUserId INT,
			tblCTContractDetails NVARCHAR(MAX),
			-- Validate Contract Headers
			intStartingNumberId INT,
			intEntityId INT,
			tblCTContractHeaders NVARCHAR(MAX),
			strRowState NVARCHAR(50)
		)
	
		WHILE EXISTS (SELECT TOP 1 1 FROM #ProcessContractHeaders)
		BEGIN
			-- Process Contract Headers
			SELECT TOP 1 @intContractHeaderId = intContractHeaderId
				, @v_intStartingNumberId = intStartingNumberId
				, @intEntityId = intEntityId
				, @strHeaderRowState = strRowState
				, @v_strXML = tblCTContractHeaders
			FROM #ProcessContractHeaders

			DECLARE @_cpDetailUniqueId			INT,
					@_cpContractDetailId		INT,
					@_cpRowState				NVARCHAR(100),
					@_cpSlice					BIT,
					@_cpParentDetailId			INT,
					@_cpCashPrice				NUMERIC(18,6),
					@_cpPricingTypeId			INT,
					@_cpCostUniqueId			INT,
					@_cpContractCostId			INT,
					@_cpFuturesUniqueId			INT,
					@_cpContractHeaderId		INT,
					@_cpUserId					INT

			EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlContractDetails   

			IF OBJECT_ID('tempdb..#ProcessDetail') IS NOT NULL  	
				DROP TABLE #ProcessDetail	

			SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,* 
			INTO	#ProcessDetail
			FROM	OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail', 2)
			WITH	(intContractDetailId INT, strRowState NVARCHAR(50), ysnSlice BIT, intParentDetailId INT, dblCashPrice NUMERIC(18, 6))
			
			SELECT @_cpDetailUniqueId = MIN(intUniqueId) FROM #ProcessDetail

			WHILE ISNULL(@_cpDetailUniqueId, 0) > 0
			BEGIN
				SELECT	@_cpContractDetailId	=	intContractDetailId, 
						@_cpRowState			=	strRowState,
						@_cpSlice				=	ysnSlice,
						@_cpParentDetailId	=	intParentDetailId,
						@_cpCashPrice			=	dblCashPrice
				FROM	#ProcessDetail 
				WHERE	intUniqueId = @_cpDetailUniqueId

				IF(@_cpRowState = 'Delete')
				BEGIN
					--FEED
					IF EXISTS(SELECT * FROM tblCTContractFeed WHERE intContractDetailId = @_cpContractDetailId AND ISNULL(strFeedStatus,'') ='')
					BEGIN
						DELETE FROM tblCTContractFeed WHERE intContractDetailId = @_cpContractDetailId AND  ISNULL(strFeedStatus,'') =''
					END

					INSERT INTO tblCTContractFeed (intContractHeaderId
						, intContractDetailId
						, strCommodityCode
						, strCommodityDesc
						, strContractBasis
						, strContractBasisDesc
						, strSubLocation
						, strCreatedBy
						, strCreatedByNo
						, strEntityNo
						, strVendorAccountNum
						, strSubmittedBy
						, strSubmittedByNo
						, strTerm
						, strTermCode
						, dtmContractDate
						, dtmStartDate
						, dtmEndDate
						, strPurchasingGroup
						, strContractNumber
						, strERPPONumber
						, strERPItemNumber
						, strERPBatchNumber
						, intContractSeq
						, strItemNo
						, strContractItemNo
						, strContractItemName
						, strOrigin
						, strStorageLocation
						, dblQuantity
						, strQuantityUOM
						, dblNetWeight
						, strNetWeightUOM
						, dblCashPrice
						, dblUnitCashPrice
						, dtmPlannedAvailabilityDate
						, dblBasis
						, strCurrency
						, strPriceUOM
						, strLoadingPoint
						, strPackingDescription
						, strRowState
						, dtmFeedCreated
						, ysnMaxPrice
						, ysnSubstituteItem
						, strLocationName
						, strSalesperson
						, strSalespersonExternalERPId
						, strProducer
						, intItemId)
					SELECT TOP 1 intContractHeaderId
						, intContractDetailId
						, strCommodityCode
						, strCommodityDesc
						, strContractBasis
						, strContractBasisDesc
						, strSubLocation
						, strCreatedBy
						, strCreatedByNo
						, strEntityNo
						, strVendorAccountNum
						, strSubmittedBy
						, strSubmittedByNo
						, strTerm
						, strTermCode
						, dtmContractDate
						, dtmStartDate
						, dtmEndDate
						, strPurchasingGroup
						, strContractNumber
						, strERPPONumber
						, strERPItemNumber
						, strERPBatchNumber
						, intContractSeq
						, strItemNo
						, strContractItemNo
						, strContractItemName
						, strOrigin
						, strStorageLocation
						, dblQuantity
						, strQuantityUOM
						, dblNetWeight
						, strNetWeightUOM
						, dblCashPrice
						, dblUnitCashPrice
						, dtmPlannedAvailabilityDate
						, dblBasis
						, strCurrency
						, strPriceUOM
						, strLoadingPoint
						, strPackingDescription
						, 'Delete'
						, GETDATE()
						, ysnMaxPrice
						, ysnSubstituteItem
						, strLocationName
						, strSalesperson
						, strSalespersonExternalERPId
						, strProducer
						, intItemId
					FROM tblCTContractFeed
					WHERE intContractDetailId = @_cpContractDetailId
					ORDER BY intContractFeedId DESC
					
					--Unslice
					IF(@_cpSlice = 0)
					BEGIN
						UPDATE tblCTContractDetail SET intParentDetailId = @_cpParentDetailId, ysnSlice = 0 WHERE intContractDetailId = @_cpContractDetailId
					END
					
					UPDATE tblCTContractDetail SET intParentDetailId = NULL WHERE intParentDetailId = @_cpContractDetailId

					-- DELETE ALL PAYABLES UNDER DELETED DETAILS IF CREATE OTHER COST PAYABLE ON SAVE CONTRACT SET TO TRUE
					IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
					BEGIN
						EXEC uspCTManagePayable @_cpContractDetailId, 'detail', 1
					END	
			
					-- DELETE DERIVATIVES
					EXEC uspCTManageDerivatives @_cpContractDetailId, 'detail', 1
				END
				ELSE IF(@_cpRowState = 'Modified')
				BEGIN
					SELECT @_cpPricingTypeId = intPricingTypeId FROM tblCTContractDetail WHERE intContractDetailId = @_cpContractDetailId
					IF @_cpPricingTypeId IN (1,6)
					BEGIN
						IF(SELECT dblCashPrice FROM tblCTContractDetail WHERE intContractDetailId = @_cpContractDetailId) <> @_cpCashPrice
						BEGIN
							UPDATE tblCTContractDetail SET ysnPriceChanged = 1 WHERE intContractDetailId = @_cpContractDetailId
						END
					END

					--------------- START CONTRACT COST -------------------
					IF OBJECT_ID('tempdb..#ContractCosts') IS NOT NULL
						DROP TABLE #ContractCosts

					SELECT  * 
					INTO	#ContractCosts
					FROM	OPENXML(@idoc,'tblCTContractDetails/tblCTContractDetail/tblCTContractCosts',2)
					WITH	(intContractCostId INT,intContractDetailId INT,strRowState NVARCHAR(50))     

					IF OBJECT_ID('tempdb..#ProcessCost') IS NOT NULL
						DROP TABLE #ProcessCost
			
					SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intCostUniqueId,*					
					INTO	#ProcessCost
					FROM	#ContractCosts
					WHERE	intContractDetailId = @_cpContractDetailId

					SELECT @_cpCostUniqueId = MIN(intCostUniqueId) FROM #ProcessCost

					WHILE ISNULL(@_cpCostUniqueId, 0) > 0
					BEGIN
						SELECT	@_cpContractCostId = intContractCostId
						FROM	#ProcessCost 
						WHERE	intCostUniqueId = @_cpCostUniqueId
						AND		intContractDetailId = @_cpContractDetailId
			
						-- DELETE SPECIFIC PAYABLES IF CREATE OTHER COST PAYABLE ON SAVE CONTRACT SET TO TRUE
						IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
						BEGIN
							EXEC uspCTManagePayable @_cpContractCostId, 'cost', 1
						END	

						SELECT @_cpCostUniqueId = MIN(intCostUniqueId) FROM #ProcessCost WHERE intCostUniqueId > @_cpCostUniqueId
					END
					--------------- END CONTRACT COST -------------------

					--------------- START CONTRACT FUTURES -------------------
					IF OBJECT_ID('tempdb..#ContractFutures') IS NOT NULL
						DROP TABLE #ContractFutures

					SELECT  *
					INTO	#ContractFutures
					FROM	OPENXML(@idoc,'tblCTContractDetails/tblCTContractDetail/tblCTContractFutures',2)
					WITH	(intContractFuturesId INT,intContractDetailId INT,strRowState NVARCHAR(50))     

					IF OBJECT_ID('tempdb..#ProcessFutures') IS NOT NULL
						DROP TABLE #ProcessFutures
			
					SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intFuturesUniqueId,*					
					INTO	#ProcessFutures
					FROM	#ContractFutures
					WHERE	intContractDetailId = @_cpContractDetailId

					SELECT @_cpFuturesUniqueId = MIN(intFuturesUniqueId) FROM #ProcessFutures

					WHILE ISNULL(@_cpFuturesUniqueId, 0) > 0
					BEGIN
						SELECT	@_cpFuturesUniqueId = intContractFuturesId
						FROM	#ProcessFutures 
						WHERE	intFuturesUniqueId = @_cpFuturesUniqueId
						AND		intContractDetailId = @_cpContractDetailId
			
						-- DELETE SPECIFIC DERIVATIVE
						EXEC uspCTManageDerivatives @_cpFuturesUniqueId, 'futures', 1

						SELECT @_cpFuturesUniqueId = MIN(intFuturesUniqueId) FROM #ProcessFutures WHERE intFuturesUniqueId > @_cpFuturesUniqueId
					END
					--------------- END CONTRACT FUTURES -------------------
				END

				SELECT @_cpDetailUniqueId = MIN(intUniqueId) FROM #ProcessDetail WHERE intUniqueId > @_cpDetailUniqueId
			END

			--Unslice
			EXEC uspQMSampleContractUnSlice @_cpContractHeaderId,@_cpUserId
			EXEC uspLGLoadContractUnSlice @_cpContractHeaderId

			UPDATE tblCTContractDetail SET ysnSlice = NULL WHERE intContractHeaderId = @_cpContractHeaderId	
			UPDATE	CC
			SET		CC.intPrevConcurrencyId = CC.intConcurrencyId
			FROM	tblCTContractCost	CC
			JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
			WHERE	CD.intContractHeaderId	=	@_cpContractHeaderId
			
			-- Validate Contract Headers
			SELECT @v_strXML = REPLACE(@v_strXML, '^|', '<')
			SELECT @v_strXML = REPLACE(@v_strXML, '|^', '>')
			SELECT @v_strXML = '<tblCTContractHeaders>' + @v_strXML + '</tblCTContractHeaders>'

			IF @v_RowState = 'Added'
			BEGIN
				-----------------------  Validate Contract Header  -----------------------			
				DECLARE @_gcnPatternCode	INT,
						@_gcnContractTypeId	INT,
						@_gcnExist			BIT = 1

				SET @_gcnPatternCode	=	@v_intStartingNumberId

				IF	@_gcnPatternCode = 25 SET @_gcnContractTypeId = 1 ELSE SET @_gcnContractTypeId = 2

				WHILE	@_gcnExist	=	1
				BEGIN
					EXEC	uspMFGeneratePatternId 
							@intCategoryId			=	NULL
							,@intItemId				=	NULL
							,@intManufacturingId	=	NULL
							,@intSubLocationId		=	NULL
							,@intLocationId			=	NULL
							,@intOrderTypeId		=	NULL
							,@intBlendRequirementId	=	NULL
							,@intPatternCode		=	@_gcnPatternCode
							,@ysnProposed			=	0
							,@strPatternString 		=	@v_strPatternString out
							,@intEntityId			=	@v_intEntityId

					IF NOT EXISTS(SELECT * FROM tblCTContractHeader WHERE strContractNumber = @v_strPatternString AND intContractTypeId = @_gcnContractTypeId)
						SET	@_gcnExist = 0
				END

				SET @v_strContractNumber = @v_strPatternString
			END

			-----------------------  Validate Contract Header  -----------------------
			DECLARE @_vcnUniqueEntityReference	BIT,
					@_vcnCommodityId			INT,
					@_vcnCommodityUOMId			INT,
					@_vcnCategory				BIT,
					@_vcnQuantity				NUMERIC(18,6),
					@_vcnContractDate			DATETIME,
					@_vcnContractHeaderId		INT,
					@_vcnContractTypeId			INT,
					@_vcnEntityId				INT,
					@_vcnSalespersonId			INT,
					@_vcnContractNumber			NVARCHAR(50),
					@_vcnCustomerContract		NVARCHAR(50),
					@_vcnPricingTypeId			INT,
					@_vcnCreatedById			INT,
					@_vcnCreated				DATETIME,
					@_vcnConcurrencyId			INT,
					@_vcnContractBasisId		INT,
					@_vcnTermId					INT,
					@_vcnContractTextId			INT,
					@_vcnWeightId				INT,
					@_vcnGradeId				INT,
					@_vcnCropYearId				INT,
					@_vcnAssociationId			INT,
					@_vcnProducerId				INT,
					@_vcnMultiplePriceFixation	BIT,
					@_vcnNoOfLots				NUMERIC(18,6),
					@_vcnLotsFixed				NUMERIC(18,6),
					@_vcnYear					INT,
					@_vcnFiscalYearId			INT,
					@_vcnDeferPayRate			NUMERIC(18,6),
					@_vcnTolerancePct			NUMERIC(18,6),
					@_vcnProvisionalInvoicePct  NUMERIC(18,6),
					@_vcnQuantityPerLoad		NUMERIC(18,6),
					@_vcnNoOfLoad				INT,
					@_vcnFutureMarketId			INT,
					@_vcnFutureMonthId			INT,
					@_vcnFutures				NUMERIC(18, 6),
					@_vcnUsed					BIT = 0

			SELECT	@_vcnUniqueEntityReference = ysnUniqueEntityReference FROM tblCTCompanyPreference

			EXEC sp_xml_preparedocument @idoc OUTPUT, @v_strXML 
			
			SELECT	@_vcnCommodityId		        =	intCommodityId,
					@_vcnCommodityUOMId	            =	intCommodityUOMId,
					@_vcnQuantity		            =	dblQuantity,
					@_vcnContractDate	            =	dtmContractDate,
					@_vcnContractHeaderId           =	intContractHeaderId,
					@_vcnContractTypeId	            =	intContractTypeId,
					@_vcnEntityId		            =	intEntityId,
					@_vcnSalespersonId	            =	intSalespersonId,
					@_vcnContractNumber	            =	@v_strContractNumber,
					@_vcnCategory		            =	ysnCategory,
					@_vcnPricingTypeId	            =	intPricingTypeId,
					@_vcnCreatedById		        =	intCreatedById,
					@_vcnCreated			        =	dtmCreated,
					@_vcnConcurrencyId	            =	intConcurrencyId,
					@_vcnContractBasisId	        =	intContractBasisId,
					@_vcnTermId			            =	intTermId,
					@_vcnContractTextId	            =	intContractTextId,
					@_vcnWeightId		            =	intWeightId,
					@_vcnGradeId			        =	intGradeId,
					@_vcnCropYearId		            =	intCropYearId,
					@_vcnAssociationId	            =	intAssociationId,
					@_vcnProducerId		            =	intProducerId,
					@_vcnMultiplePriceFixation		=	ysnMultiplePriceFixation,
					@_vcnNoOfLots					=	dblNoOfLots,
					@_vcnCustomerContract			=   strCustomerContract,
					@_vcnDeferPayRate				=   dblDeferPayRate,
					@_vcnTolerancePct				=   dblTolerancePct,
					@_vcnProvisionalInvoicePct		=   dblProvisionalInvoicePct,
					@_vcnQuantityPerLoad			=   dblQuantityPerLoad,
					@_vcnNoOfLoad					=   intNoOfLoad,
					@_vcnFutureMarketId				=	intFutureMarketId,
					@_vcnFutureMonthId				=	intFutureMonthId,
					@_vcnFutures					=	dblFutures

			FROM	OPENXML(@idoc, 'tblCTContractHeaders/tblCTContractHeader',2)
			WITH
			(
					intCommodityId				INT,
					intCommodityUOMId			INT,
					dblQuantity					NUMERIC(18,6),
					dtmContractDate				DATETIME,
					intContractHeaderId			INT,
					intContractTypeId			INT,
					intEntityId					INT,
					intSalespersonId			INT,
					strContractNumber			NVARCHAR(50),
					ysnCategory					BIT,
					intPricingTypeId			INT,
					intCreatedById				INT,
					dtmCreated					DATETIME,
					intConcurrencyId			INT,
					intContractBasisId			INT,
					intTermId					INT,
					intContractTextId			INT,
					intWeightId					INT,
					intGradeId					INT,
					intCropYearId				INT,
					intAssociationId			INT,
					intProducerId				INT,
					ysnMultiplePriceFixation	BIT,
					dblNoOfLots					NUMERIC(18,6),
					strCustomerContract			NVARCHAR(1000),
					dblDeferPayRate				NUMERIC(18,6),
					dblTolerancePct				NUMERIC(18,6),
					dblProvisionalInvoicePct	NUMERIC(18,6),
					dblQuantityPerLoad			NUMERIC(18,6),
					intNoOfLoad					INT,
					intFutureMarketId			INT,
					intFutureMonthId			INT,
					dblFutures					NUMERIC(18,6)
			);

			IF @v_RowState = 'Added'
			BEGIN
				IF	@_vcnContractTypeId IS NULL
				BEGIN
					SET @ErrMsg = 'Contract Type is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				
				IF	@_vcnEntityId IS NULL
				BEGIN
					SET @ErrMsg = 'Entity is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF ISNULL(@_vcnCategory, 0) = 0 
				BEGIN
					IF	@_vcnCommodityId IS NULL
					BEGIN
						SET @ErrMsg = 'Commodity is missing while creating contract.'
						RAISERROR(@ErrMsg,16,1)
					END
					IF	@_vcnCommodityUOMId IS NULL
					BEGIN
						SET @ErrMsg = 'UOM is missing while creating contract.'
						RAISERROR(@ErrMsg,16,1)
					END
					IF NOT EXISTS(SELECT * FROM tblICCommodityUnitMeasure WHERE intCommodityId = @_vcnCommodityId AND intCommodityUnitMeasureId = @_vcnCommodityUOMId)
					BEGIN
						SET @ErrMsg = 'Combination of commodity id and UOM id is not matching.'
						RAISERROR(@ErrMsg,16,1)
					END
				END
				
				IF	@_vcnQuantity IS NULL
				BEGIN
					SET @ErrMsg = 'Quantity is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				---Quantity UOM

				IF	@_vcnContractDate IS NULL
				BEGIN
					SET @ErrMsg = 'Contract Date is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				
				IF	@_vcnPricingTypeId IS NULL
				BEGIN
					SET @ErrMsg = 'Pricing Type is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnSalespersonId IS NULL
				BEGIN
					SET @ErrMsg = 'Salesperson is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				
				IF LEN(ISNULL(@_vcnCustomerContract,'')) > 30
				BEGIN
					SET @ErrMsg = 'Entity Contract cannot be more than 30 characters.'
					RAISERROR(@ErrMsg,16,1)
				END
				
				IF ISNULL(@_vcnDeferPayRate, 0) > 999.99
				BEGIN
					SET @ErrMsg = 'Defer PayRate cannot be more than 999.99.'
					RAISERROR(@ErrMsg,16,1)
				END
				
				IF ISNULL(@_vcnTolerancePct, 0) > 99999999.9999
				BEGIN
					SET @ErrMsg = 'Tolerance Pct cannot be more than 99999999.9999.'
					RAISERROR(@ErrMsg,16,1)
				END
				
				IF ISNULL(@_vcnProvisionalInvoicePct, 0) > 99999999.9999
				BEGIN
					SET @ErrMsg = 'Tolerance Pct cannot be more than 99999999.9999.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF ISNULL(@_vcnQuantityPerLoad, 0) > 99999999999999.9999
				BEGIN
					SET @ErrMsg = 'Quantity Per Load cannot be more than 99999999999999.9999.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF ISNULL(@_vcnNoOfLoad, 0) > 9999
				BEGIN
					SET @ErrMsg = 'No Of Load cannot be more than 9999.'
					RAISERROR(@ErrMsg,16,1)
				END
				
				IF @_vcnMultiplePriceFixation = 1
				BEGIN
					
					IF ISNULL(@_vcnFutureMarketId, 0) = 0 
					BEGIN
						SET @ErrMsg = 'Future Market is missing while creating contract.'
						RAISERROR(@ErrMsg,16,1)
					END
					
					IF ISNULL(@_vcnFutureMonthId, 0) = 0 
					BEGIN
						SET @ErrMsg = 'Future Month is missing while creating contract.'
						RAISERROR(@ErrMsg,16,1)
					END
					
					IF ISNULL(@_vcnPricingTypeId, 0) = 1 AND @_vcnFutures IS NULL
					BEGIN
						SET @ErrMsg = 'Futures is missing while creating contract.'
						RAISERROR(@ErrMsg,16,1)
					END

					IF ISNULL(@_vcnQuantity, 0) > 0 AND ISNULL(@_vcnNoOfLots, 0) = 0
					BEGIN
						SET @ErrMsg = 'No Of Lots is missing while creating contract.'
						RAISERROR(@ErrMsg,16,1)
					END

				END

				IF	@_vcnContractNumber IS NULL
				BEGIN
					SET @ErrMsg = 'Contract Number is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcnCreatedById IS NULL
				BEGIN
					SET @ErrMsg = 'Created by is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcnCreated IS NULL
				BEGIN
					SET @ErrMsg = 'Created date is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcnConcurrencyId IS NULL
				BEGIN
					SET @ErrMsg = 'Concurrency Id is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				

				IF EXISTS(SELECT * FROM tblCTContractHeader WHERE intContractTypeId  = @_vcnContractTypeId AND strContractNumber = @_vcnContractNumber)
				BEGIN
					SET @ErrMsg = 'Contract number is already available.'
					RAISERROR(@ErrMsg,16,1)
				END

				--Active check
				
				IF	@_vcnEntityId IS NOT NULL AND (
					(@_vcnContractTypeId = 1 AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @_vcnEntityId AND ysnActive = 1 AND strEntityType = 'Vendor') ) OR
					(@_vcnContractTypeId = 2 AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @_vcnEntityId AND ysnActive = 1 AND strEntityType = 'Customer') )
				)
				BEGIN
					SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @_vcnEntityId
					SET @ErrMsg = 'Entity ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnContractBasisId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblSMFreightTerms WHERE intFreightTermId = @_vcnContractBasisId AND ysnActive = 1)
				BEGIN
					SELECT @ErrMsg = strFreightTerm FROM tblSMFreightTerms WHERE intFreightTermId = @_vcnContractBasisId
					SET @ErrMsg = 'Freight Term ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnTermId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblSMTerm WHERE intTermID = @_vcnTermId AND ysnActive = 1)
				BEGIN
					SELECT @ErrMsg = strTerm FROM tblSMTerm WHERE intTermID = @_vcnTermId
					SET @ErrMsg = 'Term ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnSalespersonId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @_vcnSalespersonId AND ysnActive = 1 AND strEntityType = 'Salesperson')
				BEGIN
					SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @_vcnSalespersonId
					SET @ErrMsg = 'Salesperson ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnContractTextId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTContractText WHERE intContractTextId = @_vcnContractTextId AND ysnActive = 1)
				BEGIN
					SELECT @ErrMsg = strTextCode FROM tblCTContractText WHERE intContractTextId = @_vcnContractTextId
					SET @ErrMsg = 'Contract Text ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnGradeId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTWeightGrade WHERE intWeightGradeId = @_vcnGradeId AND ysnActive = 1)
				BEGIN
					SELECT @ErrMsg = strWeightGradeDesc FROM tblCTWeightGrade WHERE intWeightGradeId = @_vcnGradeId
					SET @ErrMsg = 'Grade ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnWeightId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTWeightGrade WHERE intWeightGradeId = @_vcnWeightId AND ysnActive = 1)
				BEGIN
					SELECT @ErrMsg = strWeightGradeDesc FROM tblCTWeightGrade WHERE intWeightGradeId = @_vcnWeightId
					SET @ErrMsg = 'Weight ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnCropYearId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTCropYear WHERE intCropYearId = @_vcnCropYearId AND ysnActive = 1)
				BEGIN
					SELECT @ErrMsg = strCropYear FROM tblCTCropYear WHERE intCropYearId = @_vcnCropYearId
					SET @ErrMsg = 'Crop Year ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnAssociationId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTAssociation WHERE intAssociationId = @_vcnAssociationId AND ysnActive = 1)
				BEGIN
					SELECT @ErrMsg = strName FROM tblCTAssociation WHERE intAssociationId = @_vcnAssociationId
					SET @ErrMsg = 'Association ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END

				IF	@_vcnProducerId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @_vcnProducerId AND strEntityType = 'Producer' AND ysnActive = 1)
				BEGIN
					SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @_vcnProducerId
					SET @ErrMsg = 'Producer ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
					RAISERROR(@ErrMsg,16,1)
				END
				--End Active check

				SELECT	@_vcnYear = YEAR(@_vcnContractDate)
				SELECT @_vcnFiscalYearId = intFiscalYearId FROM tblGLFiscalYear WHERE strFiscalYear = LTRIM(@_vcnYear)
				IF EXISTS(SELECT * FROM tblGLFiscalYearPeriod WHERE intFiscalYearId = @_vcnFiscalYearId AND @_vcnContractDate BETWEEN dtmStartDate AND dtmEndDate AND ysnCTOpen = 0)
				BEGIN
					SET @ErrMsg = 'Selected contract date is in a fiscal period that has been closed.'
					RAISERROR(@ErrMsg,16,1)
				END
			END
			IF @v_RowState = 'Modified'
			BEGIN
				SELECT	@_vcnMultiplePriceFixation	=	ISNULL(@_vcnMultiplePriceFixation,ysnMultiplePriceFixation)
				FROM	tblCTContractHeader
				WHERE	intContractHeaderId	=	@_vcnContractHeaderId

				IF EXISTS(SELECT TOP 1 1 FROM vyuCTSequenceUsageHistory WHERE intContractHeaderId = @_vcnContractHeaderId AND ysnDeleted <> 1)
				BEGIN
					SET @_vcnUsed = 1
				END

				IF @_vcnMultiplePriceFixation = 1 AND @_vcnUsed = 1
				BEGIN
					SELECT @_vcnLotsFixed = dblLotsFixed FROM tblCTPriceFixation WHERE intContractHeaderId = @_vcnContractHeaderId
					IF @_vcnLotsFixed IS NOT NULL AND @_vcnNoOfLots IS NOT NULL AND @_vcnNoOfLots < @_vcnLotsFixed 
					BEGIN
						SET @ErrMsg = 'Cannot reduce number of lots to '+LTRIM(CAST(@_vcnNoOfLots AS INT)) + '. As '+LTRIM(CAST(@_vcnLotsFixed AS INT)) + ' lots are price fixed.'
						RAISERROR(@ErrMsg,16,1)
					END
				END
			END

			--Common added and modified
			IF ISNULL(@_vcnUniqueEntityReference, 0) = 1 AND LTRIM(RTRIM(ISNULL(@_vcnCustomerContract,''))) <> '' AND EXISTS(SELECT TOP 1 1 FROM tblCTContractHeader WHERE strCustomerContract = @_vcnCustomerContract)
			BEGIN
				SELECT @ErrMsg = 'The Vendor/Customer Ref '+@_vcnCustomerContract+' is already available for the selected vendor.'
				RAISERROR(@ErrMsg,16,1)
			END

			INSERT INTO @returnTable(intContractHeaderId, strContractNumber)
			SELECT @_vcnContractHeaderId, @_vcnContractNumber
			
			DELETE FROM #ProcessContractHeaders WHERE intContractHeaderId = @intContractHeaderId
		END
	END


	-----------------------------------------------------------------------
	----------  V A L I D A T E  C O N T R A C T  D E T A I L S  ----------
	-----------------------------------------------------------------------
	IF @xmlContractDetails <> ''
	BEGIN
		DECLARE @strDetailRowState NVARCHAR(50)

		SET @strProcess = 'Validate Contract Details'
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlContractDetails

		IF OBJECT_ID('tempdb..#ValidateContractDetails') IS NOT NULL
			DROP TABLE #ValidateContractDetails

		SELECT * INTO #ValidateContractDetails
		FROM OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail', 2)
		WITH (tblCTContractDetails NVARCHAR(MAX), intContractDetailId INT, strRowState NVARCHAR(50))
		
		WHILE EXISTS (SELECT TOP 1 1 FROM #ValidateContractDetails)
		BEGIN
			SELECT TOP 1 @strDetailRowState = strRowState
				, @intContractDetailId = intContractDetailId
				, @vd_strXML = tblCTContractDetails
			FROM #ValidateContractDetails

			SELECT @vd_strXML = REPLACE(@vd_strXML, '^|', '<')
			SELECT @vd_strXML = REPLACE(@vd_strXML, '|^', '>')
			SELECT @vd_strXML = '<tblCTContractDetails>' + @vd_strXML + '</tblCTContractDetails>'
			
			-----------------------------------------------------------------------
			----------  V A L I D A T E  C O N T R A C T  D E T A I L  ------------
			-----------------------------------------------------------------------
			DECLARE @_vcdContractDetailId		INT,
					@_vcdNewQuantity			NUMERIC(18,6),
					@_vcdNewItemUOMId			INT,
					@_vcdOldQuantity			NUMERIC(18,6),
					@_vcdOldItemUOMId			INT,
					@_vcdNewQuantityInOldUOM	NUMERIC(18,6),
					@_vcdQuantityUsed			NUMERIC(18,6),
					@_vcdNumber					NVARCHAR(100),
					@_vcdContractSeq			INT,
					@_vcdContractHeaderId		INT,
					@_vcdNewStatusId			INT,
					@_vcdOldStatusId			INT,
					@_vcdContractTypeId			INT,
					@_vcdOldItemId				INT,
					@_vcdOldQtyUnitMeasureId	INT,
					@_vcdOldBalance				NUMERIC(18,6),
					@_vcdOldScheduleQty			NUMERIC(18,6),
					@_vcdOldBalanceLoad			NUMERIC(18,6),
					@_vcdOldScheduleLoad		NUMERIC(18,6),
					@_vcdOldNoOfLoad			INT,
					@_vcdNewCompanyLocationId	INT,
					@_vcdNewStartDate			DATETIME,
					@_vcdNewEndDate				DATETIME,
					@_vcdCreatedById			INT,
					@_vcdCreated				DATETIME,
					@_vcdConcurrencyId			INT,
					@_vcdNewItemId				INT,
					@_vcdNewPricingTypeId		INT,
					@_vcdNewScheduleRuleId		INT,
					@_vcdNewSubLocationId		INT,
					@_vcdNewItemContractId		INT,
					@_vcdNewFutureMonthId		INT,
					@_vcdNewProducerId			INT,
					@_vcdSubLocationName		NVARCHAR(100),
					@_vcdItemNo					NVARCHAR(100),
					@_vcdNewBalance				NUMERIC(18,6),
					@_vcdNewScheduleQty			NUMERIC(18,6),
					@_vcdNewNoOfLoad			INT,
					@_vcdLoad					BIT,
					@_vcdSlice					BIT,
					@_vcdNewShipperId			INT,
					@_vcdNewShippingLineId		INT,
					@_vcdAllowNegativeInventory INT,
					@_vcdItemLocationId			INT, 
					@_vcdItemStockUOMId			INT, 
					@_vcdUnitOnHand				NUMERIC(18,6), 
					@_vcdUnitMeasure			NVARCHAR(50),
					@_vcdAllocatedQty			NUMERIC(18,6),
					@_vcdM2MDate				DATETIME,
					@_vcdNewM2MDate				DATETIME,
					@_vcdM2MBatchDate			DATETIME,
					@_vcdM2MDateChanged			BIT,
					@_vcdPricingQuantity		NVARCHAR(100),
					@_vcdLotsFixed				NUMERIC(18,6),
					@_vcdQtyFixed				NUMERIC(18,6),
					@_vcdNewNoOfLots			NUMERIC(18,6),
					@_vcdPricedDivided			BIT

			EXEC sp_xml_preparedocument @idoc OUTPUT, @vd_strXML 
	
			SELECT	@_vcdContractHeaderId		=	intContractHeaderId,
					@_vcdContractDetailId		=	intContractDetailId,
					@_vcdContractSeq			=	intContractSeq,
					@_vcdNewQuantity			=	dblQuantity,
					@_vcdNewItemId				=	intItemId,
					@_vcdNewItemUOMId			=	intItemUOMId,
					@_vcdNewStatusId			=	intContractStatusId,
					@_vcdNewCompanyLocationId	=	intCompanyLocationId,
					@_vcdNewStartDate			=	dtmStartDate,
					@_vcdNewEndDate				=	dtmEndDate,
					@_vcdCreatedById			=	intCreatedById,
					@_vcdCreated				=	dtmCreated,
					@_vcdConcurrencyId			=	intConcurrencyId,
					@_vcdNewPricingTypeId		=	intPricingTypeId,
					@_vcdNewScheduleRuleId		=	intStorageScheduleRuleId,
					@_vcdNewSubLocationId		=	intSubLocationId,
					@_vcdNewBalance				=	dblBalance,
					@_vcdNewScheduleQty			=	dblScheduleQty,
					@_vcdNewNoOfLoad			=	intNoOfLoad,
					@_vcdNewItemContractId		=	intItemContractId,
					@_vcdNewFutureMonthId		=	intFutureMonthId,
					@_vcdNewProducerId			=	intProducerId,
					@_vcdSlice					=	ysnSlice,
					@_vcdNewShipperId			=	intShipperId,
					@_vcdNewShippingLineId		=	intShippingLineId,
					@_vcdNewM2MDate				=	dtmM2MDate,
					@_vcdNewNoOfLots			=	dblNoOfLots,
					@_vcdPricedDivided			=	pricedDivided
			FROM	OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail',2)
			WITH
			(
					intContractDetailId			INT,
					dblQuantity					NUMERIC(18,6),
					intItemUOMId				INT,
					intContractHeaderId			INT,
					intContractStatusId			INT,
					intContractSeq				INT,
					intCompanyLocationId		INT,
					dtmStartDate				DATETIME,
					dtmEndDate					DATETIME,
					intCreatedById				INT,
					dtmCreated					DATETIME,
					intConcurrencyId			INT,
					intItemId					INT,
					intPricingTypeId			INT,
					intStorageScheduleRuleId	INT,
					intSubLocationId			INT,
					dblBalance					NUMERIC(18,6),
					dblScheduleQty				NUMERIC(18,6),
					intNoOfLoad					INT,
					intItemContractId			INT,
					intFutureMonthId			INT,
					intProducerId				INT,
					ysnSlice					BIT,
					intShipperId				INT,
					intShippingLineId			INT,
					dtmM2MDate					DATETIME,
					dblNoOfLots					NUMERIC(18,6),
					pricedDivided				BIT
			)  

			SELECT @_vcdPricingQuantity = strPricingQuantity FROM tblCTCompanyPreference

			IF @_vcdNewCompanyLocationId = 0 SET @_vcdNewCompanyLocationId = NULL

			IF @vd_RowState  <> 'Added'
			BEGIN
				SELECT	@_vcdOldQuantity			=	CD.dblQuantity,
						@_vcdOldItemUOMId			=	CD.intItemUOMId,
						@_vcdContractSeq			=	CD.intContractSeq,
						@_vcdOldStatusId			=	CD.intContractStatusId,
						@_vcdContractTypeId			=	CH.intContractTypeId,
						@_vcdOldItemId				=	CD.intItemId,
						@_vcdOldQtyUnitMeasureId	=	IU.intUnitMeasureId,
						@_vcdOldBalance				=	CD.dblBalance,
						@_vcdOldScheduleQty			=	CD.dblScheduleQty,
						@_vcdOldBalanceLoad			=	CD.dblBalanceLoad,
						@_vcdOldScheduleLoad		=	CD.dblScheduleLoad,
						@_vcdOldNoOfLoad			=	CD.intNoOfLoad,
						@_vcdNewQuantity			=	ISNULL(@_vcdNewQuantity,CD.dblQuantity),
						@_vcdNewItemUOMId			=	ISNULL(@_vcdNewItemUOMId,CD.intItemUOMId),
						@_vcdContractHeaderId		=	ISNULL(@_vcdContractHeaderId,CD.intContractHeaderId),
						@_vcdNewStatusId			=	ISNULL(@_vcdNewStatusId,CD.intContractStatusId),
						@_vcdNewBalance				=	ISNULL(@_vcdNewBalance,CD.dblBalance),
						@_vcdNewScheduleQty			=	ISNULL(@_vcdNewScheduleQty,CD.dblScheduleQty),
						@_vcdNewNoOfLoad			=	ISNULL(@_vcdNewNoOfLoad,CD.intNoOfLoad),
						@_vcdNewPricingTypeId		=	ISNULL(@_vcdNewPricingTypeId,CD.intPricingTypeId),
						@_vcdLoad					=	ysnLoad,
						@_vcdContractSeq			=	ISNULL(@_vcdContractSeq,CD.intContractSeq),
						@_vcdNewItemId				=	ISNULL(@_vcdNewItemId,CD.intItemId),			
						@_vcdNewCompanyLocationId	=	ISNULL(@_vcdNewCompanyLocationId,CD.intCompanyLocationId),
						@_vcdNewStartDate			=	ISNULL(@_vcdNewStartDate,CD.dtmStartDate),
						@_vcdNewEndDate				=	ISNULL(@_vcdNewEndDate,CD.dtmEndDate),
						@_vcdCreatedById			=	ISNULL(@_vcdCreatedById,CD.intCreatedById),
						@_vcdCreated				=	ISNULL(@_vcdCreated,CD.dtmCreated),
						@_vcdConcurrencyId			=	ISNULL(@_vcdConcurrencyId,CD.intConcurrencyId),			
						@_vcdNewScheduleRuleId		=	ISNULL(@_vcdNewScheduleRuleId,CD.intStorageScheduleRuleId),
						@_vcdNewSubLocationId		=	ISNULL(@_vcdNewSubLocationId,CD.intSubLocationId),
						@_vcdNewItemContractId		=	ISNULL(@_vcdNewItemContractId,CD.intItemContractId),
						@_vcdNewFutureMonthId		=	ISNULL(@_vcdNewFutureMonthId,CD.intFutureMonthId),
						@_vcdNewProducerId			=	ISNULL(@_vcdNewProducerId,CD.intProducerId),
						@_vcdSlice					=	ISNULL(@_vcdSlice,CD.ysnSlice),
						@_vcdNewShipperId			=	ISNULL(@_vcdNewShipperId,CD.intShipperId),
						@_vcdNewShippingLineId		=	ISNULL(@_vcdNewShippingLineId,CD.intShippingLineId),
						@_vcdAllocatedQty			=	CD.dblAllocatedQty,
						@_vcdM2MDate				=	CD.dtmM2MDate,
						@_vcdM2MDateChanged			=	CASE WHEN ISNULL(@_vcdNewM2MDate,CD.dtmM2MDate) <> CD.dtmM2MDate THEN 1 ELSE 0 END,
						@_vcdNewNoOfLots			=	ISNULL(@_vcdNewNoOfLots,CD.dblNoOfLots)
				FROM	tblCTContractDetail	CD
				JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
				JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CD.intItemUOMId
				WHERE	intContractDetailId	=	ISNULL(@_vcdContractDetailId, 0)
			END

			SELECT @_vcdSubLocationName = strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @_vcdNewSubLocationId
			SELECT @_vcdItemNo = strItemNo FROM tblICItem WHERE intItemId = @_vcdNewItemId
			SELECT @_vcdNewQuantityInOldUOM = dbo.fnCTConvertQtyToTargetItemUOM(@_vcdNewItemUOMId,@_vcdOldItemUOMId,@_vcdNewQuantity)

			IF @vd_RowState  = 'Added'
			BEGIN
				IF	@_vcdConcurrencyId IS NULL
				BEGIN
					SET @ErrMsg = 'Concurrency Id is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewStatusId IS NULL
				BEGIN
					SET @ErrMsg = 'Contract status is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdContractSeq IS NULL
				BEGIN
					SET @ErrMsg = 'Sequence number is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewCompanyLocationId IS NULL
				BEGIN
					SET @ErrMsg = 'Location is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewStartDate IS NULL
				BEGIN
					SET @ErrMsg = 'Start date is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewEndDate IS NULL
				BEGIN
					SET @ErrMsg = 'End date is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewItemId IS NULL
				BEGIN
					SET @ErrMsg = 'Item is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewItemUOMId IS NULL
				BEGIN
					SET @ErrMsg = 'UOM is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF NOT EXISTS(SELECT * FROM tblICItemUOM WHERE intItemId = @_vcdNewItemId AND intItemUOMId = @_vcdNewItemUOMId)
				BEGIN
					SET @ErrMsg = 'Combination of item id and UOM id is not matching.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewQuantity IS NULL
				BEGIN
					SET @ErrMsg = 'Quantity is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewPricingTypeId IS NULL
				BEGIN
					SET @ErrMsg = 'Pricing type is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewPricingTypeId = 5 AND @_vcdNewScheduleRuleId IS NULL
				BEGIN
					SET @ErrMsg = 'Storage Schedule is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdCreatedById IS NULL
				BEGIN
					SET @ErrMsg = 'Created by is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdCreated IS NULL
				BEGIN
					SET @ErrMsg = 'Created date is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END		
				IF	@_vcdNewM2MDate IS NULL AND @_vcdNewPricingTypeId <> 5
				BEGIN
					SET @ErrMsg = 'M2M Date is missing while creating contract.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewQuantity > 9999999999.999999
				BEGIN
					SET @ErrMsg = 'Quantity cannot be greater than 99999999.999999.'
					RAISERROR(@ErrMsg,16,1)
				END
				IF	@_vcdNewNoOfLoad > 99999
				BEGIN
					SET @ErrMsg = 'No Of Load cannot be greater than 99999.'
					RAISERROR(@ErrMsg,16,1)
				END
				
				--Active check
				IF ISNULL(@_vcdSlice, 0) = 0
				BEGIN
					IF	@_vcdNewItemContractId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTItemContractView WHERE intItemContractId = @_vcdNewItemContractId AND strStatus = 'Active' AND intLocationId = @_vcdNewCompanyLocationId)
					BEGIN
						SELECT @ErrMsg = strContractItemName FROM tblICItemContract WHERE intItemContractId = @_vcdNewItemContractId
						SET @ErrMsg = REPLACE(@ErrMsg,'%','%%')
						SET @ErrMsg = 'Contract Item ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
						RAISERROR(@ErrMsg,16,1)
					END

					IF	@_vcdNewFutureMonthId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblRKFuturesMonth WHERE intFutureMonthId = @_vcdNewFutureMonthId AND ISNULL(ysnExpired, 0) = 0)
					BEGIN
						SELECT @ErrMsg = strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId = @_vcdNewFutureMonthId
						SET @ErrMsg = 'Future Month ' + ISNULL(@ErrMsg,'selected') + ' is expired.'
						RAISERROR(@ErrMsg,16,1)
					END

					IF	@_vcdNewProducerId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @_vcdNewProducerId AND strEntityType = 'Producer' AND ysnActive = 1)
					BEGIN
						SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @_vcdNewProducerId
						SET @ErrMsg = 'Producer ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
						RAISERROR(@ErrMsg,16,1)
					END

					IF	@_vcdNewShipperId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @_vcdNewShipperId AND strEntityType = 'Vendor' AND ysnActive = 1)
					BEGIN
						SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @_vcdNewShipperId
						SET @ErrMsg = 'Shipper ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
						RAISERROR(@ErrMsg,16,1)
					END

					IF	@_vcdNewShippingLineId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @_vcdNewShippingLineId AND strEntityType = 'Vendor' AND ysnActive = 1)
					BEGIN
						SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @_vcdNewShippingLineId
						SET @ErrMsg = 'Shipping Line ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
						RAISERROR(@ErrMsg,16,1)
					END
				END
			END

			IF @vd_RowState  = 'Modified'
			BEGIN
				SELECT @_vcdQuantityUsed = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@_vcdOldItemId,intUnitMeasureId,@_vcdOldQtyUnitMeasureId,dblReservedQuantity)) FROM tblLGReservation WHERE intContractDetailId = @_vcdContractDetailId
				IF @_vcdQuantityUsed > @_vcdNewQuantityInOldUOM
				BEGIN
					SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@_vcdQuantityUsed)+' as it is used in Reservation.'
					RAISERROR(@ErrMsg,16,1) 
				END

				IF @_vcdNewStatusId IN (2,3,5) AND @_vcdOldStatusId NOT IN (2,3,5) AND dbo.fnAPContractHasUnappliedPrepaid(@_vcdContractDetailId) = 1
				BEGIN
					SELECT	@_vcdNumber = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId	=	@_vcdNewStatusId
					SET @ErrMsg = 'Cannot change status of Sequence '+LTRIM(@_vcdContractSeq)+' to '+@_vcdNumber+' as prepaid balance is associated with the contract.'
					RAISERROR(@ErrMsg,16,1) 
				END

				IF @_vcdNewStatusId IN (6) AND @_vcdOldStatusId NOT IN (6) AND ISNULL(@_vcdAllocatedQty, 0) > 0 AND
				@_vcdAllocatedQty > @_vcdNewQuantity - @_vcdNewBalance
				BEGIN
					SELECT	@_vcdNumber = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId	=	@_vcdNewStatusId
					SET @ErrMsg = 'Cannot change status of Sequence '+LTRIM(@_vcdContractSeq)+' to '+@_vcdNumber+' as allocation of '+dbo.fnRemoveTrailingZeroes(@_vcdAllocatedQty)+' quantity is available for this sequence.'
					RAISERROR(@ErrMsg,16,1) 
				END

				IF @_vcdNewPricingTypeId <> 5
				BEGIN
					IF @_vcdLoad = 1
					BEGIN
						IF (@_vcdNewNoOfLoad < @_vcdOldNoOfLoad - @_vcdOldBalanceLoad + @_vcdOldScheduleLoad)
						BEGIN
							SET @ErrMsg = 'No. of Loads for Sequence ' + LTRIM(@_vcdContractSeq) + ' cannot be reduced below ' + LTRIM(@_vcdOldNoOfLoad - @_vcdOldBalanceLoad + @_vcdOldScheduleLoad) + '. As current no. of load is ' + LTRIM(@_vcdOldNoOfLoad) + ' and no. of load in use is ' + LTRIM(@_vcdOldNoOfLoad - @_vcdOldBalanceLoad + @_vcdOldScheduleLoad) + '.'
							RAISERROR(@ErrMsg,16,1) 
						END			
					END
					ELSE
					BEGIN
						IF (@_vcdNewQuantity < @_vcdOldQuantity - @_vcdOldBalance + @_vcdOldScheduleQty)
						BEGIN
							SET @ErrMsg = 'Sequence ' + LTRIM(@_vcdContractSeq) + ' quantity cannot be reduced below ' + LTRIM(@_vcdOldQuantity - @_vcdOldBalance + @_vcdOldScheduleQty) + '. As current contract quantity is ' +  LTRIM(@_vcdOldQuantity) + ' and quantity in use is ' + LTRIM(@_vcdOldQuantity - @_vcdOldBalance + @_vcdOldScheduleQty) + '.'
							RAISERROR(@ErrMsg,16,1) 
						END
					END
				END

				IF	@_vcdM2MDateChanged = 1
				BEGIN 
					SELECT @_vcdM2MBatchDate = MAX(IQ.dtmCreateDateTime) FROM tblRKM2MInquiryTransaction IT
					JOIN tblRKM2MInquiry IQ ON IT.intM2MInquiryId = IT.intM2MInquiryId
					WHERE intContractDetailId = @_vcdContractDetailId

					IF @_vcdNewM2MDate < @_vcdM2MBatchDate
					BEGIN
						SET @ErrMsg = 'M2M date for sequence ' + LTRIM(@_vcdContractSeq) + ' should not be prior to the M2M inquiry date ' + CONVERT(NVARCHAR(20),@_vcdM2MBatchDate,106) + '.' 
						RAISERROR(@ErrMsg,16,1) 
					END
				END

				IF @_vcdOldItemId <> @_vcdNewItemId
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM vyuCTSequenceUsageHistory WHERE intContractDetailId = @_vcdContractDetailId AND ysnDeleted <> 1 AND strScreenName NOT IN('Import', 'Load Schedule'))
					BEGIN
						SET @ErrMsg = 'Cannot change item for Sequence ' + LTRIM(@_vcdContractSeq) + ', which is already in use.'
						RAISERROR(@ErrMsg,16,1) 
					END
				END

				IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @_vcdContractDetailId)
				BEGIN
					IF @_vcdPricingQuantity = 'By Futures Contracts'
					BEGIN
						SELECT @_vcdLotsFixed = dblLotsFixed FROM tblCTPriceFixation WHERE intContractDetailId = @_vcdContractDetailId
						IF @_vcdNewNoOfLots < @_vcdLotsFixed AND ISNULL(@_vcdPricedDivided, 0) = 0
						BEGIN
							SET @ErrMsg = 'Cannot reduce the lots for the Sequence ' + LTRIM(@_vcdContractSeq) + ' to '+dbo.fnRemoveTrailingZeroes(@_vcdNewNoOfLots)+', as '+dbo.fnRemoveTrailingZeroes(@_vcdLotsFixed)+' lots are price fixed.'
							RAISERROR(@ErrMsg,16,1) 
						END
					END
					ELSE
					BEGIN
						SELECT	@_vcdQtyFixed = SUM(dblQuantity) FROM tblCTPriceFixation PF
						JOIN	tblCTPriceFixationDetail FD ON FD.intPriceFixationId = PF.intPriceFixationId
						WHERE	intContractDetailId = @_vcdContractDetailId

						IF @_vcdNewQuantity < @_vcdQtyFixed AND ISNULL(@_vcdPricedDivided, 0) = 0
						BEGIN
							SET @ErrMsg = 'Cannot reduce the quantity for the Sequence ' + LTRIM(@_vcdContractSeq) + ' to '+dbo.fnRemoveTrailingZeroes(@_vcdNewQuantity)+', as '+dbo.fnRemoveTrailingZeroes(@_vcdQtyFixed)+' is price fixed.'
							RAISERROR(@ErrMsg,16,1) 
						END
					END
				END
			END

			IF @vd_RowState  = 'Delete'
			BEGIN
				IF EXISTS (SELECT * FROM tblICInventoryReceipt IR
							JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptId = IR.intInventoryReceiptId
							WHERE IR.strReceiptType = 'Purchase Contract' AND RI.intLineNo = @_vcdContractDetailId)
				BEGIN
					SELECT	@_vcdNumber = IR.strReceiptNumber 
					FROM	tblICInventoryReceipt		IR
					JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptId = IR.intInventoryReceiptId
					WHERE	IR.strReceiptType = 'Purchase Contract' AND RI.intLineNo = @_vcdContractDetailId

					SET @ErrMsg = 'Cannot delete Sequence '+LTRIM(@_vcdContractSeq)+'. As it used in the Inventory Receipt '+@_vcdNumber+'.'
					RAISERROR(@ErrMsg,16,1) 
				END

				IF EXISTS (SELECT * FROM tblICInventoryShipment SH
							JOIN tblICInventoryShipmentItem SI ON SI.intInventoryShipmentId = SH.intInventoryShipmentId
							WHERE SH.intOrderType = 4 AND SI.intLineNo = @_vcdContractDetailId)
				BEGIN
					SELECT	@_vcdNumber = SH.strShipmentNumber  
					FROM	tblICInventoryShipment		SH
					JOIN	tblICInventoryShipmentItem	SI ON SI.intInventoryShipmentId = SH.intInventoryShipmentId
					WHERE	SH.intOrderType = 4 AND SI.intLineNo = @_vcdContractDetailId

					SET @ErrMsg = 'Cannot delete Sequence '+LTRIM(@_vcdContractSeq)+'. As it used in the Inventory Shipment '+@_vcdNumber+'.'
					RAISERROR(@ErrMsg,16,1) 
				END
			END

			IF EXISTS (SELECT *
						FROM tblICItemSubLocation SL
						JOIN tblICItemLocation IL ON IL.intItemLocationId = SL.intItemLocationId
						JOIN tblSMCompanyLocationSubLocation CS	ON CS.intCompanyLocationSubLocationId = SL.intSubLocationId
						WHERE IL.intItemId = @_vcdNewItemId AND CS.intCompanyLocationId = @_vcdNewCompanyLocationId) AND ISNULL(@_vcdNewSubLocationId, 0) <> 0
			BEGIN
				IF NOT EXISTS (SELECT *
								FROM tblICItemSubLocation SL
								JOIN tblICItemLocation IL ON IL.intItemLocationId = SL.intItemLocationId
								JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = SL.intSubLocationId
								WHERE IL.intItemId = @_vcdNewItemId AND CS.intCompanyLocationId = @_vcdNewCompanyLocationId AND SL.intSubLocationId = @_vcdNewSubLocationId)
				BEGIN
					SET @ErrMsg = @_vcdSubLocationName + ' is not configured for Item ' + @_vcdItemNo + '.'
					RAISERROR(@ErrMsg, 16, 1) 
				END
			END

			IF ISNULL(@_vcdSlice, 0) = 0
			BEGIN
				IF	@_vcdNewItemId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE intItemId = @_vcdNewItemId AND strStatus = 'Active')
				BEGIN
					SELECT @ErrMsg = strStatus FROM tblICItem WHERE intItemId = @_vcdNewItemId
					IF @ErrMsg = 'Phased Out'
					BEGIN
						SELECT @_vcdAllowNegativeInventory  = intAllowNegativeInventory, @_vcdItemLocationId = intItemLocationId FROM tblICItemLocation WHERE intItemId = @_vcdNewItemId AND intLocationId = @_vcdNewCompanyLocationId
						IF @_vcdAllowNegativeInventory = 3
						BEGIN
							SELECT @_vcdItemStockUOMId = intItemUOMId FROM tblICItemUOM WHERE  intItemId = @_vcdNewItemId AND ysnStockUnit = 1
							SELECT @_vcdUnitMeasure	=	strUnitMeasure FROM tblICUnitMeasure WHERE  intUnitMeasureId = (SELECT intUnitMeasureId FROM tblICItemUOM WHERE  intItemUOMId = @_vcdNewItemUOMId)
							SELECT @_vcdUnitOnHand	=	ISNULL(dblUnitOnHand, 0) FROM tblICItemStock WHERE intItemId = @_vcdNewItemId AND intItemLocationId = @_vcdItemLocationId
							SELECT @_vcdUnitOnHand	=	dbo.fnCTConvertQtyToTargetItemUOM(@_vcdItemStockUOMId,@_vcdNewItemUOMId,@_vcdUnitOnHand)
							IF @_vcdNewQuantity > @_vcdUnitOnHand
							BEGIN
								SELECT @ErrMsg = strItemNo FROM tblICItem WHERE intItemId = @_vcdNewItemId
								SELECT @ErrMsg = 'Phased Out item ' + @ErrMsg + ' has a stock of ' + dbo.fnRemoveTrailingZeroes(@_vcdUnitOnHand) + ' ' + @_vcdUnitMeasure + '. ' +
								'Which is insufficient to save sequence of ' + dbo.fnRemoveTrailingZeroes(@_vcdNewQuantity) + ' ' + @_vcdUnitMeasure + '. '
								RAISERROR(@ErrMsg,16,1)
							END
						END
					END
					ELSE
					BEGIN
						SELECT @ErrMsg = strItemNo FROM tblICItem WHERE intItemId = @_vcdNewItemId
						SET @ErrMsg = 'Item ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
						RAISERROR(@ErrMsg,16,1)
					END
				END
			END

			DELETE FROM #ValidateContractDetails WHERE intContractDetailId = @intContractDetailId
		END
	END

	SELECT * FROM @returnTable
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH