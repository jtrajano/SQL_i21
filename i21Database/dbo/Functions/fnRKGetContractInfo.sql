CREATE FUNCTION [dbo].[fnRKGetContractInfo] (
	@intContractHeader INT
	, @strContractNumbers NVARCHAR(4000))

RETURNS @returntable TABLE (intContractHeaderId INT
	, strDeliveryDates NVARCHAR(1500) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(1500) COLLATE Latin1_General_CI_AS)

AS

BEGIN
	DECLARE @intContractNumber INT
	DECLARE @strDeliveryDates NVARCHAR(1000)
	DECLARE @strFutureMonth NVARCHAR(1000)
	
	SELECT @intContractNumber = CT.intContractHeaderId 
		, @strDeliveryDates = (COALESCE(@strDeliveryDates + ', ', '') + CT.strDeliveryDate) COLLATE Latin1_General_CI_AS
		, @strFutureMonth = (COALESCE(@strFutureMonth + ', ', '') + CT.strFutureMonth) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT intContractHeaderId
		, strContractIds = strContractNumber + '-' + CONVERT(nvarchar(4000), intContractSeq) COLLATE Latin1_General_CI_AS
		, strDeliveryDate = dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy')
		, strFutureMonth
		FROM vyuCTContractDetailView
	) CT
	WHERE CT.intContractHeaderId = @intContractHeader AND CT.strContractIds IN (
		SELECT Item FROM [dbo].[fnSplitStringWithTrim](@strContractNumbers, ',')
	)

	INSERT INTO @returntable(intContractHeaderId, strDeliveryDates, strFutureMonth)
	VALUES(@intContractNumber, @strDeliveryDates, @strFutureMonth)

	RETURN;
END
