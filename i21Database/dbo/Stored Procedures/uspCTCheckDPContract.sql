CREATE PROCEDURE [dbo].[uspCTCheckDPContract]
	@intContractHeader int = null
AS
BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX)
		
	IF EXISTS (SELECT TOP 1 1 FROM vyuCTCompanyPreference WHERE ysnAutoCompleteDPDeliveryDate = 1)
	BEGIN
		UPDATE CD SET intContractStatusId = 5
		FROM tblCTContractDetail CD
		WHERE dblBalance = 0
		AND intPricingTypeId = 5
		AND intContractStatusId = 1
		AND dbo.fnRemoveTimeOnDate(GETDATE()) > dbo.fnRemoveTimeOnDate(dtmEndDate)
  		AND intContractHeaderId = (case when isnull(@intContractHeader,0) > 0 then @intContractHeader else intContractHeaderId end)
	END

END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
