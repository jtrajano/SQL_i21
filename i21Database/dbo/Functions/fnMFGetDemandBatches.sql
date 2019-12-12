CREATE FUNCTION [dbo].[fnMFGetDemandBatches]
	(@intInvPlngSummaryId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strBatches NVARCHAR(MAX)

	SET @strBatches = ''

	SELECT @strBatches = @strBatches + RM.strPlanNo + ', '
	FROM tblMFInvPlngSummaryBatch SB
	JOIN tblCTInvPlngReportMaster RM ON RM.intInvPlngReportMasterID = SB.intInvPlngReportMasterID
	WHERE SB.intInvPlngSummaryId = @intInvPlngSummaryId
	
	IF LEN(@strBatches) > 0
		SET @strBatches = Left(@strBatches, LEN(@strBatches) - 1)

	RETURN @strBatches
END
