
Create  PROCEDURE [dbo].uspCTGetNoOfContract
		@dtmFrom Date = null,
		@dtmTo Date = null
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	If (@dtmFrom IS NOT NULL and @dtmTo IS NULL) OR (@dtmTo IS NOT NULL and @dtmFrom IS NULL)
	BEGIN
		SET @ErrMsg = 'Invalid Date Filter'
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	END

	If @dtmFrom IS NULL
	BEGIN
		SELECT CL.strLocationName,  Cast(''  as varchar(100)) strPeriod, Count(1) intNoOfContract
		FROM tblCTContractHeader CH
		INNER JOIN tblSMCompanyLocation CL ON CH.intCompanyLocationId = CL.intCompanyLocationId
		GROUP BY CL.strLocationName
	END
	ELSE 
	BEGIN

		SELECT CL.strLocationName,  Cast( Cast(@dtmFrom as Varchar) + ' - ' +  Cast(@dtmTo as Varchar) as varchar(100)) strPeriod, Count(1) intNoOfContract
		FROM tblCTContractHeader CH
		INNER JOIN tblSMCompanyLocation CL ON CH.intCompanyLocationId = CL.intCompanyLocationId
		Where CH.dtmContractDate Between @dtmFrom and @dtmTo
		GROUP BY CL.strLocationName
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH