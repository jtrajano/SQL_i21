CREATE FUNCTION [dbo].[fnCTGetAvgSamplePropertyValue]
(
	@intContractDetailId	INT,
	@strPropertyName		NVARCHAR(100)

)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@dblAvg NUMERIC(18,6)
	
    SELECT  @dblAvg = SUM(CAST(TR.strPropertyValue AS NUMERIC(18,6)))/COUNT(TR.intTestResultId)
    FROM	tblQMSample		SA
    JOIN	tblQMTestResult TR	ON	SA.intSampleId		=	TR.intSampleId
    JOIN	tblQMProperty	PR	ON	PR.intPropertyId	=	TR.intPropertyId AND PR.strPropertyName = @strPropertyName
    WHERE   intContractDetailId = @intContractDetailId
    AND		SA.intSampleStatusId = 3 AND ISNULL(TR.strPropertyValue,'0') NOT IN ('0','')
	
	RETURN @dblAvg
END
