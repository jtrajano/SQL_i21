CREATE PROCEDURE [dbo].[uspCTReportContractDetail]
	
	@intContractHeaderId INT
	
AS

BEGIN TRY
	
	DECLARE	@ErrMsg NVARCHAR(MAX)

	
	DECLARE @TotalQuantity DECIMAL(24,10),
			@TotalNetQuantity DECIMAL(24,10),
			@dblNoOfLots NVARCHAR(20),

			@IntNoOFUniFormItemUOM INT,
			@IntNoOFUniFormNetWeightUOM INT,
			@intLastApprovedContractId INT,
			@intPrevApprovedContractId INT,
			@strAmendedColumns NVARCHAR(MAX),
			@intContractDetailId INT

	DECLARE @Amend TABLE (intContractDetailId INT, strAmendedColumns NVARCHAR(MAX))

	SELECT @IntNoOFUniFormItemUOM=COUNT(DISTINCT intItemUOMId)  FROM tblCTContractDetail WHERE intContractHeaderId= @intContractHeaderId
	SELECT @IntNoOFUniFormNetWeightUOM=COUNT(DISTINCT intNetWeightUOMId)  FROM tblCTContractDetail WHERE intContractHeaderId= @intContractHeaderId

	SELECT  @dblNoOfLots = dblNoOfLots FROM tblCTContractHeader WHERE intContractHeaderId=@intContractHeaderId
	SELECT  @TotalQuantity = dblQuantity FROM tblCTContractHeader WHERE intContractHeaderId=@intContractHeaderId
	SELECT  @TotalNetQuantity =SUM(dblNetWeight) FROM tblCTContractDetail WHERE intContractHeaderId=@intContractHeaderId

	SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId

	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT @strAmendedColumns = ''
		SELECT TOP 1 @intLastApprovedContractId =  intApprovedContractId
		FROM   tblCTApprovedContract 
		WHERE  intContractDetailId = @intContractDetailId AND strApprovalType IN ('Contract','Contract Amendment ')
		ORDER BY intApprovedContractId DESC

		SELECT TOP 1 @intPrevApprovedContractId =  intApprovedContractId
		FROM   tblCTApprovedContract 
		WHERE  intContractDetailId = @intContractDetailId AND intApprovedContractId <> @intLastApprovedContractId 
		ORDER BY intApprovedContractId DESC
             
		IF @intPrevApprovedContractId IS NOT NULL AND @intLastApprovedContractId IS NOT NULL
		BEGIN
			EXEC uspCTCompareRecords 'tblCTApprovedContract', @intPrevApprovedContractId, @intLastApprovedContractId,'intApprovedById,dtmApproved,
			intContractBasisId,dtmPlannedAvailabilityDate,strOrigin,dblNetWeight,intNetWeightUOMId,
			intSubLocationId,intStorageLocationId,intPurchasingGroupId,strApprovalType', @strAmendedColumns OUTPUT
		END

		INSERT INTO @Amend
		SELECT @intContractDetailId,@strAmendedColumns

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END
	


	SELECT	CD.intContractHeaderId,
			CD.intContractSeq,
			CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106) strPeriod,
			LTRIM(CD.dblQuantity) + ' ' + UM.strUnitMeasure strQunatity,
			CD.dblQuantity,
			CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN LTRIM(CAST(CD.dblCashPrice AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
					WHEN 	CD.intPricingTypeId = 2	THEN LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ', ' + MO.strFutureMonth + CASE WHEN ISNULL(CH.ysnMultiplePriceFixation,0) = 0 THEN ' ('+ LTRIM(CAST(CD.dblNoOfLots AS INT)) +' Lots)' ELSE '' END 	
			END	AS	strPrice,
			ISNULL(IC.strContractItemName,IM.strDescription) strDescription,
			BM.strBagMark,
			CD.strReference,
			GETDATE() AS dtmETD,
			CH.dtmContractDate,
			EF.strFieldNumber strGarden,
			CD.strGrade,
			CD.dblNetWeight,
			NU.strUnitMeasure strWeightUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,1) dblUnitQty,
			CD.dblCashPrice,
			CY.strCurrency,
			CD.dblTotalCost,
			PU.strUnitMeasure strPriceUOM,
			CASE 
				WHEN UM.strUnitType='Quantity' THEN LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblQuantity)) + ' bags/ ' + UM.strUnitMeasure+CASE WHEN CD.dblNetWeight IS NOT NULL THEN  ' (' ELSE '' END + ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') +CASE WHEN U7.strUnitMeasure IS NOT NULL THEN   ')' ELSE '' END  
				ELSE ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') 
			END
			AS  strQuantityDesc,
			CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN LTRIM(CAST(CD.dblCashPrice AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
					WHEN 	CD.intPricingTypeId = 2	THEN LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ', ' + MO.strFutureMonth + CASE WHEN ISNULL(CH.ysnMultiplePriceFixation,0) = 0 THEN ' ('+ LTRIM(CAST(CD.dblNoOfLots AS INT)) +' Lots)' ELSE '' END 	
			END	AS	strPriceDesc,
			CASE 
			WHEN ISNULL(ysnMultiplePriceFixation,0)=1 THEN
				CASE 
					WHEN UM.strUnitType='Quantity' AND @IntNoOFUniFormItemUOM=1 THEN LTRIM(dbo.fnRemoveTrailingZeroes(@TotalQuantity)) + ' bags/ ' + UM.strUnitMeasure+CASE WHEN CD.dblNetWeight IS NOT NULL AND @IntNoOFUniFormNetWeightUOM=1 THEN  ' (' ELSE '' END + ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') +CASE WHEN U7.strUnitMeasure IS NOT NULL THEN   ')' ELSE '' END  
					ELSE CASE WHEN @IntNoOFUniFormNetWeightUOM=1 THEN ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') ELSE '' END
				END
			ELSE 
				NULL 
			END
			AS  strTotalDesc,
			CASE	WHEN	CD.intPricingTypeId = 1 THEN NULL
					WHEN 	CD.intPricingTypeId = 2	THEN 'Lots :'
			END	AS	lblLots,
			CASE	WHEN	CD.intPricingTypeId = 1 THEN NULL
					WHEN 	CD.intPricingTypeId = 2	THEN dbo.fnRemoveTrailingZeroes(@dblNoOfLots)
			END	AS	dblNoOfLots,
			AM.strAmendedColumns			
	FROM	tblCTContractDetail CD	
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
	JOIN	tblICItemUOM		QM	ON	QM.intItemUOMId			=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId		=	QM.intUnitMeasureId		LEFT
	JOIN	tblICItemUOM		PM	ON	PM.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICUnitMeasure	PU	ON	PU.intUnitMeasureId		=	PM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	CD.intCurrencyId		LEFT
	JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId		LEFT
	JOIN	tblICItem			IM	ON	IM.intItemId			=	CD.intItemId			LEFT
	JOIN	[tblEMEntityFarm]	EF	ON	EF.intFarmFieldId		=	CD.intFarmFieldId		LEFT
	JOIN	tblCTBagMark		BM	ON	BM.intContractDetailId	=	CD.intContractDetailId	
									AND	BM.ysnDefault			=	1						LEFT
	JOIN	tblICItemUOM		NM	ON	NM.intItemUOMId			=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICItemUOM		WU	ON	WU.intItemUOMId			=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICUnitMeasure	U7	ON	U7.intUnitMeasureId		=	WU.intUnitMeasureId		LEFT
	JOIN	tblICUnitMeasure	NU	ON	NU.intUnitMeasureId		=	NM.intUnitMeasureId		LEFT
	JOIN	@Amend				AM	ON	AM.intContractDetailId	=	CD.intContractDetailId	LEFT
	JOIN	tblICItemContract	IC	ON	IC.intItemContractId	=	CD.intItemContractId
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO