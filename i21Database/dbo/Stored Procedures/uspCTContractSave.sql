CREATE PROCEDURE [dbo].[uspCTContractSave]
	
	@intContractHeaderId int,
	@strXML	NVARCHAR(MAX)
	
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
			@strRowState				NVARCHAR(100)

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
	WITH	(intContractDetailId	INT,strRowState	NVARCHAR(50))      

	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessDetail

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT @intContractDetailId = intContractDetailId,@strRowState = strRowState FROM #ProcessDetail WHERE intUniqueId = @intUniqueId
		IF(@strRowState = 'Delete')
		BEGIN
			IF EXISTS(SELECT * FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId AND ISNULL(strFeedStatus,'') ='')
			BEGIN
				DELETE FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId AND  ISNULL(strFeedStatus,'') =''
				IF EXISTS(SELECT * FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId)
				BEGIN
					INSERT	INTO tblCTContractFeed (intContractHeaderId,intContractDetailId,strCommodityCode,strCommodityDesc,strERPPONumber,intContractSeq,strItemNo,strRowState,dtmFeedCreated)
					SELECT	TOP 1 intContractHeaderId,intContractDetailId,strCommodityCode,strCommodityDesc,strERPPONumber,intContractSeq,
							(SELECT TOP 1 strItemNo FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId AND ISNULL(strItemNo,'') <> '') strItemNo,
							'Delete',GETDATE()
					FROM	tblCTContractFeed
					WHERE	intContractDetailId = @intContractDetailId
					ORDER BY intContractFeedId DESC
				END
			END
			ELSE
			BEGIN
				INSERT	INTO tblCTContractFeed (intContractHeaderId,intContractDetailId,strCommodityCode,strCommodityDesc,strERPPONumber,intContractSeq,strItemNo,strRowState,dtmFeedCreated)
				SELECT	TOP 1 intContractHeaderId,intContractDetailId,strCommodityCode,strCommodityDesc,strERPPONumber,intContractSeq,
						(SELECT TOP 1 strItemNo FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId AND ISNULL(strItemNo,'') <> '') strItemNo,
						'Delete',GETDATE()
				FROM	tblCTContractFeed
				WHERE	intContractDetailId = @intContractDetailId
				ORDER BY intContractFeedId DESC
			END
		END
		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessDetail WHERE intUniqueId > @intUniqueId
	END

	SELECT @intContractDetailId = NULL

	SELECT @intContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT	@intPricingTypeId	=	NULL,
				@dblCashPrice		=	NULL,
				@dblBasis			=	NULL,
				@dblOriginalBasis	=	NULL

		SELECT	@intPricingTypeId	=	intPricingTypeId,
				@dblCashPrice		=	dblCashPrice,
				@dblBasis			=	dblBasis,
				@dblOriginalBasis	=	dblOriginalBasis,
				@intLastModifiedById=	intLastModifiedById
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId =	@intContractDetailId 
		
		EXEC	uspCTSequencePriceChanged @intContractDetailId,null,'Sequence'
		
		IF @dblOriginalBasis IS NOT NULL AND  @dblBasis <> @dblOriginalBasis
		BEGIN
			EXEC uspCTUpdateSequenceBasis @intContractDetailId,@dblBasis
		END

		EXEC uspLGUpdateLoadItem @intContractDetailId

		EXEC uspCTSplitSequencePricing @intContractDetailId, @intLastModifiedById

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END

	IF ISNULL(@ysnMultiplePriceFixation,0) = 0
	BEGIN
		UPDATE	PF
		SET		PF.[dblTotalLots] = (SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId OR ISNULL(intSplitFromId,0) = CD.intContractDetailId)
		FROM	tblCTPriceFixation	PF
		JOIN	tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
		WHERE	CD.intContractHeaderId = @intContractHeaderId
	END
	
	EXEC uspCTUpdateAdditionalCost @intContractHeaderId

	IF EXISTS(SELECT * FROM tblCTContractImport WHERE strContractNumber = @strContractNumber AND ysnImported = 0)
	BEGIN
		UPDATE	tblCTContractImport
		SET		ysnImported = 1,
				intContractHeaderId = @intContractHeaderId
		WHERE	strContractNumber = @strContractNumber AND ysnImported = 0
	END

	EXEC uspQMSampleContractSlice @intContractHeaderId

	UPDATE tblCTContractDetail SET ysnSlice = NULL WHERE intContractHeaderId = @intContractHeaderId
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO