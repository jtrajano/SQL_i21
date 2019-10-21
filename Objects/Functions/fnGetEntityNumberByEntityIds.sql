CREATE FUNCTION [dbo].[fnGetEntityNumberByEntityIds]
(
	@strArrayID NVARCHAR(1000)
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strValues NVARCHAR(MAX) = NULL

	DECLARE @tmpTable TABLE(intTableId INT)
	INSERT INTO @tmpTable
	SELECT CONVERT(INT, Item) FROM [dbo].fnSplitString(@strArrayID, ',')
	
	IF EXISTS(SELECT NULL FROM @tmpTable)
		BEGIN
			WHILE EXISTS(SELECT TOP 1 NULL FROM @tmpTable)
			BEGIN
				DECLARE @intTableId INT
				
				SELECT TOP 1 @intTableId = intTableId FROM @tmpTable ORDER BY intTableId
				
				IF (SELECT COUNT(*) FROM @tmpTable) > 1
					SELECT @strValues = ISNULL(@strValues, '') + LTRIM(RTRIM(strEntityNo)) + ', ' FROM tblEMEntity WHERE intEntityId = @intTableId
				ELSE
					SELECT @strValues = ISNULL(@strValues, '') + LTRIM(RTRIM(strEntityNo)) FROM tblEMEntity WHERE intEntityId = @intTableId

				DELETE FROM @tmpTable WHERE intTableId = @intTableId
			END
		END

	RETURN @strValues
END