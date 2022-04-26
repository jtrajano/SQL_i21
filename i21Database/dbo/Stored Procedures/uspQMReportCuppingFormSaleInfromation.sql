CREATE PROCEDURE uspQMReportCuppingFormSaleInfromation
     @intContractDetailId INT
AS

DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	SELECT 
		 strSContractNumber
		,strBuyer
		,dblSContractAllocatedQty
		,strSItemUOM
		,strShipmentPeriod = FORMAT(dtmSStartDate, 'dd.MM.yyyy') + ' - ' + FORMAT(dtmSEndDate, 'dd.MM.yyyy')
	FROM vyuLGAllocatedContracts
	WHERE intPContractDetailId = @intContractDetailId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  

END CATCH