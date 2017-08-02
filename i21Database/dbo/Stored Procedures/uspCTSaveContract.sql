﻿CREATE PROCEDURE [dbo].[uspCTSaveContract]
	
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
			@strRowState				NVARCHAR(100),
			@intNetWeightUOMId			INT,
			@dblNetWeight				NUMERIC(18,6),
			@intItemUOMId				INT,
			@intContractStatusId		INT,
			@intContractScreenId		INT,
			@ysnOnceApproved			BIT,
			@ysnFeedOnApproval			BIT,
			@intTransactionId			INT,
			@intApproverId				INT,
			@intCompanyLocationId		INT

	SELECT	@ysnMultiplePriceFixation	=	ysnMultiplePriceFixation,
			@strContractNumber			=	strContractNumber
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId			=	@intContractHeaderId

	SELECT @ysnFeedOnApproval	=	ysnFeedOnApproval from tblCTCompanyPreference

	SELECT	@intContractScreenId=	intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'

	SELECT  @ysnOnceApproved  =	ysnOnceApproved,
			@intTransactionId = intTransactionId 
	FROM	tblSMTransaction 
	WHERE	intRecordId = @intContractHeaderId 
	AND		intScreenId = @intContractScreenId

	SELECT	TOP 1
			@intApproverId	  =	intApproverId 
	FROM	tblSMApproval 
	WHERE	intTransactionId  =	@intTransactionId 
	AND		intScreenId = @intContractScreenId 
	AND		strStatus = 'Approved' 
	ORDER BY intApprovalId DESC

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
				@intLastModifiedById=	intLastModifiedById,
				@intNetWeightUOMId	=	intNetWeightUOMId,
				@dblNetWeight		=	dblNetWeight,
				@intItemUOMId		=	intItemUOMId,
				@intContractStatusId=	intContractStatusId,
				@intCompanyLocationId = intCompanyLocationId

		FROM	tblCTContractDetail 
		WHERE	intContractDetailId =	@intContractDetailId 
		
		IF ISNULL(@intNetWeightUOMId,0) > 0 AND @dblNetWeight IS NULL
		BEGIN
			UPDATE tblCTContractDetail SET dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intNetWeightUOMId,dblQuantity) WHERE intContractDetailId = @intContractDetailId
		END

		EXEC	uspCTSequencePriceChanged @intContractDetailId,null,'Sequence'
		
		IF @intPricingTypeId = 2 AND @dblOriginalBasis IS NULL
		BEGIN
			UPDATE tblCTContractDetail SET dblOriginalBasis = dblBasis WHERE intContractDetailId = @intContractDetailId
		END

		IF @dblOriginalBasis IS NOT NULL AND  @dblBasis <> @dblOriginalBasis
		BEGIN
			EXEC uspCTUpdateSequenceBasis @intContractDetailId,@dblBasis
		END

		EXEC uspLGUpdateLoadItem @intContractDetailId
		EXEC uspLGUpdateCompanyLocation @intContractDetailId
		UPDATE tblQMSample SET intLocationId = @intCompanyLocationId WHERE intContractDetailId = @intContractDetailId

		EXEC uspCTSplitSequencePricing @intContractDetailId, @intLastModifiedById

		IF	@intContractStatusId	=	1	AND
			@ysnOnceApproved		=	1	AND
			@ysnFeedOnApproval		=	1	AND
			NOT EXISTS (SELECT * from tblCTApprovedContract WHERE intContractHeaderId = @intContractHeaderId)
		BEGIN
			EXEC uspCTContractApproved	@intContractHeaderId, @intApproverId, @intContractDetailId, 1
		END

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

	--Slice
	EXEC uspQMSampleContractSlice @intContractHeaderId
	EXEC uspLGLoadContractSlice @intContractHeaderId
	UPDATE tblCTContractDetail SET ysnSlice = NULL WHERE intContractHeaderId = @intContractHeaderId

	--Update Signature Date
	IF EXISTS(SELECT * FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId AND ysnSigned = 1 AND dtmSigned IS NULL)
	BEGIN
		UPDATE tblCTContractHeader SET dtmSigned = DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) WHERE intContractHeaderId = @intContractHeaderId		
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO