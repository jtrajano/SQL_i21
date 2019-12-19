CREATE FUNCTION [dbo].[fnSCGetDPContract]
(
	@intLocationId INT
	,@intEntityId INT
	,@intItemId INT
	,@strInOutFlag NVARCHAR(1)
	,@dtmTransactionDate DATETIME
)
RETURNS @returntable TABLE
(
	 intContractDetailId	INT
	,strContractNumber		NVARCHAR(250)
)
AS
BEGIN
	IF(ISNULL(@intLocationId,0) = 0)
	BEGIN
		INSERT @returntable(
			intContractDetailId
			,strContractNumber
		)
		SELECT	TOP	1	
			CD.intContractDetailId
			,CD.strContractNumber
		FROM	vyuCTContractDetailView CD
		WHERE	CD.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
			AND	CD.intEntityId			=	@intEntityId
			AND	CD.intItemId			=	@intItemId
			AND	CD.intPricingTypeId		=	5
			AND	CD.ysnAllowedToShow		=	1
			AND	CD.dtmStartDate < @dtmTransactionDate
		ORDER BY CD.dtmStartDate DESC
	END
	ELSE
	BEGIN
		INSERT @returntable(
			intContractDetailId
			,strContractNumber
		)
		SELECT	TOP	1	
			CD.intContractDetailId
			,CD.strContractNumber
		FROM	vyuCTContractDetailView CD
		WHERE	CD.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CD.intEntityId			=	@intEntityId
		AND		CD.intItemId			=	@intItemId
		AND		CD.intPricingTypeId		=	5
		AND		CD.ysnAllowedToShow		=	1
		AND 	CD.intCompanyLocationId = 	@intLocationId
		ORDER BY CD.dtmStartDate DESC
	END
	RETURN
END