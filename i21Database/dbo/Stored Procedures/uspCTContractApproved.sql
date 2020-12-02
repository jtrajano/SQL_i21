﻿CREATE PROCEDURE [dbo].[uspCTContractApproved]
	@intContractHeaderId	INT,
	@intApprovedById		INT,
	@intContractDetailId	INT = NULL,
	@ysnApproved			BIT = 0,
	@ysnFromContractSave	BIT = 0 
AS

BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intApprovedContractId	INT,
			@intTransactionId		INT, 
			@intScreenId			INT,
			@intContractScreenId	INT,
			@intAmendmentScreenId	INT,
			@strScreenName			NVARCHAR(100),
			@ysnSendFeedOnPrice		BIT,
			@ysnOnceApproved		BIT
			
	SELECT	@intContractScreenId	=	intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'
	SELECT	@intAmendmentScreenId	=	intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Amendments'
	SELECT  @intTransactionId		=	intTransactionId,@ysnOnceApproved = ysnOnceApproved FROM tblSMTransaction WHERE intRecordId = @intContractHeaderId AND intScreenId = @intContractScreenId
	SELECT	@ysnSendFeedOnPrice		=	ysnSendFeedOnPrice FROM tblCTCompanyPreference


	IF EXISTS(SELECT TOP 1 1 FROM tblSMApproval WHERE intTransactionId  = @intTransactionId AND intScreenId = @intAmendmentScreenId)
	BEGIN
		SELECT @intScreenId = @intAmendmentScreenId
	END
	ELSE
	BEGIN
		SELECT @intScreenId = @intContractScreenId
	END
	SELECT	@strScreenName = strScreenName FROM tblSMScreen WHERE  @intScreenId = intScreenId

	DECLARE	@SCOPE_IDENTITY TABLE (intApprovedContractId INT)

	IF @ysnApproved = 1
	BEGIN
		UPDATE tblCTContractHeader SET strAmendmentLog = NULL WHERE intContractHeaderId = @intContractHeaderId
	END

	INSERT INTO tblCTApprovedContract
	(
			intContractHeaderId,	intContractDetailId,	intEntityId,
			intGradeId,				intWeightId,			intTermId,
			intPositionId,			intContractBasisId,		intContractStatusId,
			dtmStartDate,			dtmEndDate,				dtmPlannedAvailabilityDate,
			intItemId,				dblQuantity,			intQtyUOMId,
			intFutureMarketId,		intFutureMonthId,		dblFutures,
			dblBasis,				dblCashPrice,			intCurrencyId,
			intPriceUOMId,			intSubLocationId,		intStorageLocationId,
			intPurchasingGroupId,	intApprovedById,		dtmApproved,
			strOrigin,				dblNetWeight,			intNetWeightUOMId,
			intItemContractId,		strApprovalType,		strVendorLotID,
			dblNoOfLots,			intCertificationId,		intLoadingPortId,
			ysnApproved,			strPackingDescription
	)
	OUTPUT	inserted.intApprovedContractId INTO @SCOPE_IDENTITY
	SELECT	CD.intContractHeaderId,
			CD.intContractDetailId,
			CH.intEntityId,
			CH.intGradeId,
			CH.intWeightId,
			CH.intTermId,
			CH.intPositionId,
			CH.intContractBasisId,
			CD.intContractStatusId,
			CD.dtmStartDate,
			CD.dtmEndDate,
			CD.dtmPlannedAvailabilityDate,
			CD.intItemId,
			CD.dblQuantity,
			CD.intUnitMeasureId AS intQtyUOMId,
			CD.intFutureMarketId,
			CD.intFutureMonthId,
			CASE WHEN CD.intPricingTypeId IN (1,3) THEN CD.dblFutures ELSE NULL END,
			CD.dblBasis,
			CASE WHEN CD.intPricingTypeId IN (1,6) THEN CD.dblCashPrice ELSE NULL END,
			CD.intCurrencyId,
			PU.intUnitMeasureId AS intPriceUOMId,
			CD.intSubLocationId,
			CD.intStorageLocationId,
			CD.intPurchasingGroupId,
			@intApprovedById,
			GETDATE(),
			OG.strCountry AS strOrigin,
			CD.dblNetWeight,
			WU.intUnitMeasureId AS intNetWeightUOMId,
			CD.intItemContractId,
			@strScreenName,
			CD.strVendorLotID,
			CASE WHEN ISNULL(CH.ysnMultiplePriceFixation,0) = 1 THEN CH.dblNoOfLots  ELSE CD.dblNoOfLots END,
			CF.intCertificationId,
			intLoadingPortId,
			@ysnApproved,
			CD.strPackingDescription

	FROM	tblCTContractDetail		CD 
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId	LEFT
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId			LEFT
	JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICItemUOM			WU	ON	WU.intItemUOMId				=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId			
										AND	CA.strType					=	'Origin'				LEFT
	JOIN	tblSMCountry			OG	ON	OG.intCountryID				=	CA.intCountryID			LEFT
	JOIN	(
					SELECT * FROM 
					(
						SELECT	ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY intContractCertificationId ASC) intRowNum,
								intContractDetailId,intCertificationId
						FROM	tblCTContractCertification
					) t
					WHERE intRowNum = 1
			) CF ON CF.intContractDetailId  =	CD.intContractDetailId
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId
	AND		CD.intContractDetailId	=	CASE WHEN @intContractDetailId IS NULL THEN CD.intContractDetailId ELSE @intContractDetailId END
	AND		CD.intContractStatusId	NOT IN (2,5)
	AND		CD.intPricingTypeId IN (SELECT CASE WHEN ISNULL(@ysnSendFeedOnPrice,0) = 1 THEN Item  ELSE CD.intPricingTypeId END FROM dbo.fnSplitString('1,6',','))

	SELECT @intApprovedContractId = MIN(intApprovedContractId) FROM @SCOPE_IDENTITY

	WHILE ISNULL(@intApprovedContractId,0) > 0 
	BEGIN
		EXEC uspCTProcessApprovedContractToFeed @intApprovedContractId
		
		-- Add Payables if Create Other Cost Payable on Save Contract set to true
		IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
		BEGIN
			if (@ysnFromContractSave = 1)
			begin
				EXEC uspCTManagePayable @intContractHeaderId, 'header', 0
			end
		END
		
		SELECT @intApprovedContractId = MIN(intApprovedContractId) FROM @SCOPE_IDENTITY WHERE intApprovedContractId > @intApprovedContractId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH