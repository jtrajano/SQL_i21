CREATE PROCEDURE [dbo].[uspQMReportCuppingFormSaleInfromation]
     @intContractDetailId INT
AS
DECLARE @ErrMsg NVARCHAR(MAX)
BEGIN TRY
	SELECT strSContractNumber
		 , strBuyer
		 , dblSContractAllocatedQty
		 , strSItemUOM
		 , strShipmentPeriod = CONVERT(VARCHAR(10), dtmSStartDate, 104) + ' - ' + CONVERT(VARCHAR(10), dtmSEndDate, 104)
	FROM vyuLGAllocatedContracts
	WHERE intPContractDetailId = @intContractDetailId
	GROUP BY strSContractNumber
		   , strBuyer
		   , dblSContractAllocatedQty
		   , strSItemUOM
		   , CONVERT(VARCHAR(10), dtmSStartDate, 104) + ' - ' + CONVERT(VARCHAR(10), dtmSEndDate, 104)
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE();

	RAISERROR (@ErrMsg, 18, 1, 'WITH NOWAIT'); 
END CATCH