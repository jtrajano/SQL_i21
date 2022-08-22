CREATE PROCEDURE [dbo].[uspGRUpdateContractInSettlement]
	@intContractDetailId INT
	,@intProcessType INT --1. Short-close; 2. Adjust Quantity
	,@dtmDateModified DATETIME
	,@intUserId INT
	,@dblQtyToUpdate DECIMAL(38,20)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strXML NVARCHAR(MAX)
	DECLARE @RowState NVARCHAR(8)
	DECLARE @intPricingTypeId INT
	DECLARE @dblCashPrice DECIMAL(18,6)
	DECLARE @intEntityId INT
	DECLARE @strContractNumber NVARCHAR(40)
	DECLARE @ysnSigned BIT
	DECLARE @ysnPrinted BIT
	DECLARE @intSalesPersonId INT
	DECLARE @ysnUnlimitedQuantity BIT
	DECLARE @dtmLastModified DATETIME
	DECLARE @ysnReceivedSignedFixationLetter BIT
	DECLARE @intHeaderConcurrencyId INT
	DECLARE @intDetailConcurrencyId INT
	DECLARE @dtmStartDateUTC DATETIME
	DECLARE @intContractStatusId INT
	DECLARE @dtmEndDate DATETIME
	DECLARE @dblHeaderQuantity DECIMAL(18,6)
	DECLARE @dblDetailQuantity DECIMAL(18,6)
	DECLARE @dblBalance DECIMAL(18,6)
	DECLARE @ysnProvisionalPNL BIT
	DECLARE @ysnFinalPNL BIT
	DECLARE @pricedDivided BIT
	DECLARE @intContractHeaderId INT

	SELECT @intPricingTypeId = CD.intPricingTypeId
		,@dblCashPrice = CD.dblCashPrice
		,@intContractHeaderId = CH.intContractHeaderId
		,@intEntityId = CH.intEntityId
		,@dblHeaderQuantity = CASE WHEN @intProcessType = 1 THEN CH.dblQuantity ELSE CH.dblQuantity + @dblQtyToUpdate END
		,@strContractNumber = CH.strContractNumber
		,@ysnSigned = CH.ysnSigned
		,@ysnPrinted = CH.ysnPrinted
		,@intSalesPersonId = CH.intSalespersonId
		,@ysnUnlimitedQuantity = CH.ysnUnlimitedQuantity
		,@ysnReceivedSignedFixationLetter = CH.ysnReceivedSignedFixationLetter
		,@intHeaderConcurrencyId = CH.intConcurrencyId + 1
		,@intDetailConcurrencyId = CD.intConcurrencyId + 1
		,@dtmStartDateUTC = CD.dtmStartDateUTC
		,@intContractStatusId = CASE WHEN @intProcessType = 1 THEN 6 ELSE NULL END
		,@dtmEndDate = CD.dtmEndDate
		,@dblBalance = CASE WHEN @intProcessType = 1 THEN CD.dblBalance ELSE CD.dblBalance + @dblQtyToUpdate END
		,@ysnProvisionalPNL = CD.ysnProvisionalPNL
		,@ysnFinalPNL = CD.ysnFinalPNL
		,@dblDetailQuantity = CASE WHEN @intProcessType = 1 THEN CD.dblQuantity ELSE CD.dblQuantity + @dblQtyToUpdate END
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH
		ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE intContractDetailId = @intContractDetailId

	--validate the details first before updating
	SET @strXML = '<tblCTContractDetails><tblCTContractDetail><intContractDetailId>' + CAST(@intContractDetailId AS NVARCHAR) +'</intContractDetailId><intPricingTypeId>' + CAST(@intPricingTypeId AS NVARCHAR) + '</intPricingTypeId><strRowState>Modified</strRowState><dblCashPrice>' + CAST(@dblCashPrice AS NVARCHAR) + '</dblCashPrice><tblCTContractCosts></tblCTContractCosts><tblCTContractFutures></tblCTContractFutures></tblCTContractDetail></tblCTContractDetails>'

	EXEC uspCTBeforeSaveContract @intContractHeaderId, @intUserId, @strXML

	SET @strXML = '<tblCTContractHeaders><tblCTContractHeader><intContractHeaderId>' + CAST(@intContractHeaderId AS NVARCHAR) + '</intContractHeaderId><intContractTypeId>1</intContractTypeId><intEntityId>' + CAST(@intEntityId AS NVARCHAR) + '</intEntityId><dblQuantity>' + CAST(@dblHeaderQuantity AS NVARCHAR) + '</dblQuantity><strContractNumber>' + @strContractNumber + '</strContractNumber><ysnSigned>' + CAST(@ysnSigned AS NVARCHAR) + '</ysnSigned><ysnPrinted>' + CAST(@ysnPrinted AS NVARCHAR) + '</ysnPrinted><intSalespersonId>' + CAST(@intSalesPersonId AS NVARCHAR) + '</intSalespersonId><ysnUnlimitedQuantity>' + CAST(@ysnUnlimitedQuantity AS NVARCHAR) + '</ysnUnlimitedQuantity><intLastModifiedById>' + CAST(@intUserId AS NVARCHAR) + '</intLastModifiedById><dtmLastModified>' + CAST(@dtmDateModified AS NVARCHAR) + '</dtmLastModified><ysnReceivedSignedFixationLetter>' + CAST(@ysnReceivedSignedFixationLetter AS NVARCHAR) + '</ysnReceivedSignedFixationLetter><intConcurrencyId>' + CAST(@intHeaderConcurrencyId AS NVARCHAR) + '</intConcurrencyId></tblCTContractHeader></tblCTContractHeaders>'

	EXEC uspCTValidateContractHeader @strXML, 'Modified'

	SET @strXML = '<tblCTContractDetails><tblCTContractDetail><dtmStartDateUTC>' + CAST(@dtmStartDateUTC AS NVARCHAR) + '</dtmStartDateUTC><intContractDetailId>' + CAST(@intContractDetailId AS NVARCHAR) + '</intContractDetailId><intContractHeaderId>' + CAST(@intContractHeaderId AS NVARCHAR) + '</intContractHeaderId><intContractStatusId>' + CAST(@intContractStatusId AS NVARCHAR) + '</intContractStatusId><intContractSeq>0</intContractSeq><intCompanyLocationId>0</intCompanyLocationId><dtmEndDate>' + CAST(@dtmEndDate AS NVARCHAR) + '</dtmEndDate><dblQuantity>' + CAST(@dblDetailQuantity AS NVARCHAR) + '</dblQuantity><intPricingTypeId>' + CAST(@intPricingTypeId AS NVARCHAR) + '</intPricingTypeId><dblCashPrice>' + CAST(@dblCashPrice AS NVARCHAR) + '</dblCashPrice><dblBalance>' + CAST(@dblBalance AS NVARCHAR) + '</dblBalance><intLastModifiedById>' + CAST(@intUserId AS NVARCHAR) + '</intLastModifiedById><dtmLastModified>' + CAST(@dtmDateModified AS NVARCHAR) + '</dtmLastModified><ysnProvisionalPNL>' + CAST(@ysnProvisionalPNL AS NVARCHAR) + '</ysnProvisionalPNL><ysnFinalPNL>' + CAST(@ysnFinalPNL AS NVARCHAR) + '</ysnFinalPNL><intConcurrencyId>' + CAST(@intDetailConcurrencyId AS NVARCHAR) + '</intConcurrencyId><pricedDivided>False</pricedDivided></tblCTContractDetail></tblCTContractDetails>'

	EXEC uspCTValidateContractDetail @strXML, @RowState

	UPDATE [dbo].[tblCTContractDetail]
	SET [dblQuantity] = @dblDetailQuantity
		,[dblBalance] = @dblBalance
		,[intContractStatusId] = ISNULL(@intContractStatusId,intContractStatusId)
		,[intLastModifiedById] = @intUserId
		,[dtmLastModified] = @dtmLastModified
		,[intConcurrencyId] = @intDetailConcurrencyId
	WHERE intContractDetailId = @intContractDetailId

	UPDATE [dbo].[tblCTContractHeader]
	SET [dblQuantity] = @dblHeaderQuantity
		,[intLastModifiedById] = @intUserId
		,[dtmLastModified] = @dtmLastModified
		,[intConcurrencyId] = @intHeaderConcurrencyId
	WHERE intContractHeaderId = @intContractHeaderId

	EXEC uspCTSaveContract @intContractHeaderId, @intUserId,''

	EXEC uspCTValidateContractAfterSave @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH