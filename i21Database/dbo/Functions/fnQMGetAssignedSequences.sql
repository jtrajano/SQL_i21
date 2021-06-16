CREATE FUNCTION [dbo].[fnQMGetAssignedSequences] (@intSampleId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strAssignedSequences NVARCHAR(MAX)

	SET @strAssignedSequences = ''

	SELECT @strAssignedSequences = @strAssignedSequences + LTRIM(CD.intContractSeq) + ', '
	FROM dbo.tblQMSampleContractSequence SCS
	JOIN dbo.tblCTContractDetail AS CD ON CD.intContractDetailId = SCS.intContractDetailId
		AND SCS.intSampleId = @intSampleId

	IF LEN(@strAssignedSequences) > 0
		SET @strAssignedSequences = LEFT(@strAssignedSequences, LEN(@strAssignedSequences) - 1)

	RETURN @strAssignedSequences
END
