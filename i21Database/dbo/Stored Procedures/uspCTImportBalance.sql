﻿CREATE PROCEDURE [dbo].[uspCTImportBalance]
	@intExternalId		INT,
	@strScreenName		NVARCHAR(50),
	@intUserId			INT,
	@XML				NVARCHAR(MAX)
AS
BEGIN TRY

    DECLARE	 @ErrMsg				NVARCHAR(MAX),
			 @idoc					INT,
			 @intContractHeaderId	INT,
			 @intContractDetailId	INT,
			 @dblQuantity			NUMERIC(18,6),
			 @dblOpenQty			NUMERIC(18,6),
			 @dblReceivedQty		NUMERIC(18,6),
			 @strUOM				NVARCHAR(100),
			 @intUnitMeasureId		INT,
			 @strContractNumber		NVARCHAR(100),
			 @intContractSeq		INT,
			 @strERPPONumber		NVARCHAR(100),
			 @strERPItemNumber		NVARCHAR(100),
			 @dlERPQty				NUMERIC(18,6)
				
	UPDATE	IM
	SET		strContractNumber		=	LTRIM(strContractNumber),
			intContractSeq			=	ISNULL(intContractSeq,0),
			intContractHeaderId		=	(SELECT TOP 1 intContractHeaderId FROM tblCTContractHeader WHERE strContractNumber = LTRIM(IM.strContractNumber))
	FROM	tblCTImportBalance IM
	WHERE	ISNULL(ysnImported,0)	=	0

	UPDATE	IM
	SET		intContractDetailId		=	(SELECT TOP 1 intContractDetailId FROM tblCTContractDetail WHERE intContractHeaderId = IM.intContractHeaderId AND intContractSeq = IM.intContractSeq)
	FROM	tblCTImportBalance IM
	WHERE	ISNULL(ysnImported,0)	=	0

	SELECT  @intContractHeaderId	=	intContractHeaderId,
			@intContractDetailId	=	intContractDetailId,
			@dblOpenQty				=	dblOpenQty,	
			@dblReceivedQty			=	dblReceivedQty,
			@strUOM					=	strUOM,
			@strContractNumber		=	strContractNumber,
			@intContractSeq			=	intContractSeq,
			@strERPPONumber			=	strERPPONumber,
			@strERPItemNumber		=	strERPItemNumber
	FROM	tblCTImportBalance
	WHERE	intImportBalanceId		=	@intExternalId

    SELECT  @intUnitMeasureId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @strUOM

    IF @intContractHeaderId IS NULL
    BEGIN
	   SET @ErrMsg = 'Contract ' + ISNULL(@strContractNumber,'') + ' does not exist for ERP No: ' + ISNULL(@strERPPONumber,'') + ' and line item: ' + ISNULL(@strERPItemNumber,'') + '.'
	   RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
    END
    
    IF @intContractDetailId IS NULL
    BEGIN
	   SET @ErrMsg = 'Sequence '+ISNULL(LTRIM(@intContractSeq),'')+' does not exist for ERP No: ' + ISNULL(@strERPPONumber,'') + ' and line item: ' + ISNULL(@strERPItemNumber,'') + '.'
	   RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
    END

    IF @intContractDetailId IS NULL
    BEGIN
	   SET @ErrMsg = 'UOM not mentioned for ERP No: ' + ISNULL(@strERPPONumber,'') + ' and line item: ' + ISNULL(@strERPItemNumber,'') + '.'
	   RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
    END

    IF @intUnitMeasureId IS NULL
    BEGIN
	   SET @ErrMsg = 'UOM ' + ISNULL(@strUOM,'') + ' does not exist for ERP No: ' + ISNULL(@strERPPONumber,'') + ' and line item: ' + ISNULL(@strERPItemNumber,'') + '.'
	   RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
    END

    SELECT  @dblQuantity		=	dblQuantity,
			@dblReceivedQty		=	ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,@intUnitMeasureId,intUnitMeasureId,@dblReceivedQty),0),
			@dblOpenQty			=	ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,@intUnitMeasureId,intUnitMeasureId,@dblOpenQty),0)
    FROM	tblCTContractDetail
    WHERE	intContractDetailId = @intContractDetailId

    IF  @dblQuantity    <>  	 ISNULL(@dblReceivedQty,0) + ISNULL(@dblOpenQty,0)
    BEGIN
	   SET @ErrMsg = 'Supplied quantity does not match with current quantity.'
	   RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
    END 

    EXEC	uspCTUpdateSequenceBalance 
			@intContractDetailId	=	@intContractDetailId,
			@dblQuantityToUpdate	=	@dblReceivedQty,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	'Import'

END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH

