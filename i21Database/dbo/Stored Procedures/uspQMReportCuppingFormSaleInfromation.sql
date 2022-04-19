CREATE PROCEDURE uspQMReportCuppingFormSaleInfromation
     @intSampleId INT
AS

DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	SELECT 
		 strEntityNameS
		,strContractNumberS
		,dblSampleQtyS
	FROM vyuQMAllocation
	WHERE intSampleId = @intSampleId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  

END CATCH