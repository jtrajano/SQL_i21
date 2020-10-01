CREATE PROCEDURE [dbo].[uspCTBeforeSaveContract]
		
	@intContractHeaderId	INT,
	@intUserId				INT,
	@strXML					NVARCHAR(MAX)
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@dblCashPrice				NUMERIC(18,6),
			@intPricingTypeId			INT,
			@intLastModifiedById		INT,
			@ysnMultiplePriceFixation	BIT,
			@strContractNumber			NVARCHAR(100),
			@dblBasis					NUMERIC(18,6),
			@dblOriginalBasis			NUMERIC(18,6),
			@Action						NVARCHAR(100),
			@Condition					NVARCHAR(100),
			@idoc						INT,
			@intUniqueId				INT,
			@strRowState				NVARCHAR(100),
			@ysnSlice					BIT,
			@intParentDetailId			INT,
			@intContractCostId			INT,
			@intCostUniqueId			INT,
			@intFuturesUniqueId			INT

	SELECT	@ysnMultiplePriceFixation	=	ysnMultiplePriceFixation,
			@strContractNumber			=	strContractNumber
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId			=	@intContractHeaderId

	IF @strXML = 'Delete'
	BEGIN
		SET	@Action = @strXML
		SET @Condition = 'intContractHeaderId = ' + STR(@intContractHeaderId)
		EXEC [dbo].[uspCTGetTableDataInXML] 'tblCTContractDetail', @Condition, @strXML OUTPUT,null,'intContractDetailId,''Delete'' AS strRowState'

		-- DELETE ALL PAYABLES IF CREATE OTHER COST PAYABLE ON SAVE CONTRACT SET TO TRUE
		IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
		BEGIN
			EXEC uspCTManagePayable @intContractHeaderId, 'header', 1
		END		
		
		-- DELETE DERIVATIVES
		EXEC uspCTManageDerivatives @intContractHeaderId, 'header', 1
	END

	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXML   

	IF OBJECT_ID('tempdb..#ProcessDetail') IS NOT NULL  	
		DROP TABLE #ProcessDetail	

	SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,* 
	INTO	#ProcessDetail
	FROM	OPENXML(@idoc,'tblCTContractDetails/tblCTContractDetail',2)          
	WITH	(intContractDetailId INT,strRowState NVARCHAR(50),ysnSlice BIT, intParentDetailId INT, dblCashPrice NUMERIC(18,6))      

	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessDetail

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId	=	intContractDetailId, 
				@strRowState			=	strRowState,
				@ysnSlice				=	ysnSlice,
				@intParentDetailId		=	intParentDetailId,
				@dblCashPrice			=	dblCashPrice
		FROM	#ProcessDetail 
		WHERE	intUniqueId = @intUniqueId

		IF(@strRowState = 'Delete')
		BEGIN
			--FEED
			IF EXISTS(SELECT TOP 1 1 FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId AND ISNULL(strFeedStatus,'') ='')
			BEGIN
				DELETE FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId AND  ISNULL(strFeedStatus,'') =''
			END

			INSERT	INTO tblCTContractFeed (intContractHeaderId, intContractDetailId, strCommodityCode, strCommodityDesc, strContractBasis, strContractBasisDesc, 
			strSubLocation, strCreatedBy, strCreatedByNo, strEntityNo, strVendorAccountNum, strSubmittedBy, strSubmittedByNo, strTerm, strTermCode, dtmContractDate, 
			dtmStartDate, dtmEndDate, strPurchasingGroup, strContractNumber, strERPPONumber, strERPItemNumber, strERPBatchNumber, intContractSeq, strItemNo, 
			strContractItemNo, strContractItemName, strOrigin, strStorageLocation, dblQuantity, strQuantityUOM, dblNetWeight, strNetWeightUOM, dblCashPrice, 
			dblUnitCashPrice, dtmPlannedAvailabilityDate, dblBasis, strCurrency, strPriceUOM, strLoadingPoint, strPackingDescription, strRowState, dtmFeedCreated,
			ysnMaxPrice,ysnSubstituteItem,strLocationName,strSalesperson,strSalespersonExternalERPId,strProducer,intItemId)
			SELECT	TOP 1 intContractHeaderId, intContractDetailId, strCommodityCode, strCommodityDesc, strContractBasis, strContractBasisDesc, 
			strSubLocation, strCreatedBy, strCreatedByNo, strEntityNo, strVendorAccountNum, strSubmittedBy, strSubmittedByNo, strTerm, strTermCode, dtmContractDate, 
			dtmStartDate, dtmEndDate, strPurchasingGroup, strContractNumber, strERPPONumber, strERPItemNumber, strERPBatchNumber, intContractSeq, strItemNo, 
			strContractItemNo, strContractItemName, strOrigin, strStorageLocation, dblQuantity, strQuantityUOM, dblNetWeight, strNetWeightUOM, dblCashPrice, 
			dblUnitCashPrice, dtmPlannedAvailabilityDate, dblBasis, strCurrency, strPriceUOM, strLoadingPoint, strPackingDescription,'Delete',GETDATE(),	
			ysnMaxPrice,ysnSubstituteItem,strLocationName,strSalesperson,strSalespersonExternalERPId,strProducer,intItemId

			FROM	tblCTContractFeed
			WHERE	intContractDetailId = @intContractDetailId
			ORDER BY intContractFeedId DESC			

			--Unslice
			IF(@ysnSlice = 0)
			BEGIN
				UPDATE tblCTContractDetail SET intParentDetailId = @intParentDetailId,ysnSlice = 0 WHERE intContractDetailId = @intContractDetailId
			END

			UPDATE tblCTContractDetail SET intParentDetailId = NULL WHERE intParentDetailId = @intContractDetailId

			-- DELETE ALL PAYABLES UNDER DELETED DETAILS IF CREATE OTHER COST PAYABLE ON SAVE CONTRACT SET TO TRUE
			IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
			BEGIN
				EXEC uspCTManagePayable @intContractDetailId, 'detail', 1
			END	
			
			-- DELETE DERIVATIVES
			EXEC uspCTManageDerivatives @intContractDetailId, 'detail', 1
		END
		ELSE IF(@strRowState = 'Modified')
		BEGIN
			SELECT @intPricingTypeId = intPricingTypeId FROM tblCTContractDetail WITH (UPDLOCK) WHERE intContractDetailId = @intContractDetailId
			IF @intPricingTypeId IN (1,6)
			BEGIN
				IF(SELECT dblCashPrice FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId) <> @dblCashPrice
				BEGIN
					UPDATE tblCTContractDetail SET ysnPriceChanged = 1 WHERE intContractDetailId = @intContractDetailId
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
			WHERE	intContractDetailId = @intContractDetailId

			SELECT @intCostUniqueId = MIN(intCostUniqueId) FROM #ProcessCost

			WHILE ISNULL(@intCostUniqueId,0) > 0
			BEGIN
				SELECT	@intContractCostId = intContractCostId
				FROM	#ProcessCost 
				WHERE	intCostUniqueId = @intCostUniqueId
				AND		intContractDetailId = @intContractDetailId
			
				-- DELETE SPECIFIC PAYABLES IF CREATE OTHER COST PAYABLE ON SAVE CONTRACT SET TO TRUE
				IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
				BEGIN
					EXEC uspCTManagePayable @intContractCostId, 'cost', 1
				END	

				SELECT @intCostUniqueId = MIN(intCostUniqueId) FROM #ProcessCost WHERE intCostUniqueId > @intCostUniqueId
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
			WHERE	intContractDetailId = @intContractDetailId

			SELECT @intFuturesUniqueId = MIN(intFuturesUniqueId) FROM #ProcessFutures

			WHILE ISNULL(@intFuturesUniqueId,0) > 0
			BEGIN
				SELECT	@intFuturesUniqueId = intContractFuturesId
				FROM	#ProcessFutures 
				WHERE	intFuturesUniqueId = @intFuturesUniqueId
				AND		intContractDetailId = @intContractDetailId
			
				-- DELETE SPECIFIC DERIVATIVE
				EXEC uspCTManageDerivatives @intFuturesUniqueId, 'futures', 1

				SELECT @intFuturesUniqueId = MIN(intFuturesUniqueId) FROM #ProcessFutures WHERE intFuturesUniqueId > @intFuturesUniqueId
			END
			--------------- END CONTRACT FUTURES -------------------
		END

		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessDetail WHERE intUniqueId > @intUniqueId
	END

	IF ((SELECT COUNT(*) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND ysnSlice = 0) >= 1)
	BEGIN
		--Unslice
		EXEC uspQMSampleContractUnSlice @intContractHeaderId,@intUserId
		EXEC uspLGLoadContractUnSlice @intContractHeaderId
	END

	UPDATE tblCTContractDetail SET ysnSlice = NULL WHERE intContractHeaderId = @intContractHeaderId	

	UPDATE	CC
	SET		CC.intPrevConcurrencyId = CC.intConcurrencyId
	FROM	tblCTContractCost	CC
	JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH