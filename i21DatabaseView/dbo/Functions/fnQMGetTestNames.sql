CREATE FUNCTION [dbo].[fnQMGetTestNames]
	(@intPropertyId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strTestNames NVARCHAR(MAX)

	SET @strTestNames = ''

	SELECT @strTestNames = @strTestNames + T.strTestName + ', '
	FROM tblQMTestProperty TP
	JOIN tblQMTest T ON T.intTestId = TP.intTestId
	WHERE TP.intPropertyId = @intPropertyId

	IF LEN(@strTestNames) > 0
		SET @strTestNames = Left(@strTestNames, LEN(@strTestNames) - 1)

	RETURN @strTestNames
END
