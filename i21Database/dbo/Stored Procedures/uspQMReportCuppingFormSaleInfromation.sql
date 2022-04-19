CREATE PROCEDURE uspQMReportCuppingFormSaleInfromation
     @intSampleId INT
AS

DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	SELECT 
		 strEntityNameS
		,strContractNumberS
		,dblSampleQtyS
		,strSampleUOMS
		,strShipmentPeriod = FORMAT(dtmStartDateS, 'dd.MM.yyyy') + ' - ' + FORMAT(dtmEndDateS, 'dd.MM.yyyy')
	FROM vyuQMAllocation
	WHERE intSampleId = @intSampleId
	AND ISNULL(strContractNumberS, '') <> ''

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  

END CATCH