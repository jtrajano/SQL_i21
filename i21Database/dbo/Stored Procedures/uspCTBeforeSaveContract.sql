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
			@intParentDetailId			INT

	SELECT	@ysnMultiplePriceFixation	=	ysnMultiplePriceFixation,
			@strContractNumber			=	strContractNumber
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId			=	@intContractHeaderId

	IF @strXML = 'Delete'
	BEGIN
		SET	@Action = @strXML
		SET @Condition = 'intContractHeaderId = ' + STR(@intContractHeaderId)
		EXEC [dbo].[uspCTGetTableDataInXML] 'tblCTContractDetail', @Condition, @strXML OUTPUT,null,'intContractDetailId,''Delete'' AS strRowState'
	END

	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXML   

	IF OBJECT_ID('tempdb..#ProcessDetail') IS NOT NULL  	
		DROP TABLE #ProcessDetail	

	SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,* 
	INTO	#ProcessDetail
	FROM	OPENXML(@idoc,'tblCTContractDetails/tblCTContractDetail',2)          
	WITH	(intContractDetailId INT,strRowState NVARCHAR(50),ysnSlice BIT, intParentDetailId INT)      

	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessDetail

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId	=	intContractDetailId, 
				@strRowState			=	strRowState,
				@ysnSlice				=	ysnSlice,
				@intParentDetailId		=	intParentDetailId 
		FROM	#ProcessDetail 
		WHERE	intUniqueId = @intUniqueId

		IF(@strRowState = 'Delete')
		BEGIN
			--FEED
			IF EXISTS(SELECT * FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId AND ISNULL(strFeedStatus,'') ='')
			BEGIN
				DELETE FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId AND  ISNULL(strFeedStatus,'') =''
			END

			INSERT	INTO tblCTContractFeed (intContractHeaderId, intContractDetailId, strCommodityCode, strCommodityDesc, strContractBasis, strContractBasisDesc, strSubLocation, strCreatedBy, strCreatedByNo, strEntityNo, strVendorAccountNum, strSubmittedBy, strSubmittedByNo, strTerm, strTermCode, dtmContractDate, dtmStartDate, dtmEndDate, strPurchasingGroup, strContractNumber, strERPPONumber, strERPItemNumber, strERPBatchNumber, intContractSeq, strItemNo, strContractItemNo, strContractItemName, strOrigin, strStorageLocation, dblQuantity, strQuantityUOM, dblNetWeight, strNetWeightUOM, dblCashPrice, dblUnitCashPrice, dtmPlannedAvailabilityDate, dblBasis, strCurrency, strPriceUOM, strLoadingPoint, strPackingDescription, strRowState, dtmFeedCreated)
			SELECT	TOP 1 intContractHeaderId, intContractDetailId, strCommodityCode, strCommodityDesc, strContractBasis, strContractBasisDesc, strSubLocation, strCreatedBy, strCreatedByNo, strEntityNo, strVendorAccountNum, strSubmittedBy, strSubmittedByNo, strTerm, strTermCode, dtmContractDate, dtmStartDate, dtmEndDate, strPurchasingGroup, strContractNumber, strERPPONumber, strERPItemNumber, strERPBatchNumber, intContractSeq, strItemNo, strContractItemNo, strContractItemName, strOrigin, strStorageLocation, dblQuantity, strQuantityUOM, dblNetWeight, strNetWeightUOM, dblCashPrice, dblUnitCashPrice, dtmPlannedAvailabilityDate, dblBasis, strCurrency, strPriceUOM, strLoadingPoint, strPackingDescription,
					'Delete',GETDATE()
			FROM	tblCTContractFeed
			WHERE	intContractDetailId = @intContractDetailId
			ORDER BY intContractFeedId DESC			
		END
		--Unslice
		IF(@ysnSlice = 0)
		BEGIN
			UPDATE tblCTContractDetail SET intParentDetailId = @intParentDetailId,ysnSlice = 0 WHERE intContractDetailId = @intContractDetailId
		END

		UPDATE tblCTContractDetail SET intParentDetailId = NULL WHERE intParentDetailId = @intContractDetailId

		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessDetail WHERE intUniqueId > @intUniqueId
	END

	
	--Unslice
	EXEC uspQMSampleContractUnSlice @intContractHeaderId,@intUserId
	EXEC uspLGLoadContractUnSlice @intContractHeaderId

	UPDATE tblCTContractDetail SET ysnSlice = NULL WHERE intContractHeaderId = @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH