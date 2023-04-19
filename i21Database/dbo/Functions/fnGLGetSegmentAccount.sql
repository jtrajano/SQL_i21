CREATE FUNCTION fnGLGetSegmentAccount(@intAccountId INT, @intStructureType INT)
RETURNS TABLE 
AS 
RETURN (
    SELECT TOP 1 AccSeg.strCode, AccSeg.strChartDesc, AccSeg.intAccountSegmentId  FROM tblGLAccountSegment AccSeg 
    JOIN tblGLAccountSegmentMapping AccSegMap ON AccSegMap.intAccountSegmentId = AccSeg.intAccountSegmentId
    JOIN tblGLAccountStructure AccStruct ON AccStruct.intAccountStructureId = AccSeg.intAccountStructureId
    WHERE @intAccountId = AccSegMap.intAccountId
    AND @intStructureType = AccStruct.intStructureType
)