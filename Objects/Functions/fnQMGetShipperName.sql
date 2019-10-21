CREATE FUNCTION [dbo].[fnQMGetShipperName]
    (@strMarks NVARCHAR(MAX))
RETURNS @Shipper TABLE (
	strShipperCode NVARCHAR(MAX)
	,strShipperName NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @strShipperCode NVARCHAR(MAX)
	DECLARE @strShipperName NVARCHAR(MAX)
	DECLARE @intFirstIndex INT
	DECLARE @intSecondIndex INT

	SELECT @intFirstIndex = ISNULL(CHARINDEX('/', @strMarks), 0)

	SELECT @intSecondIndex = ISNULL(CHARINDEX('/', @strMarks, @intFirstIndex + 1), 0)

	IF (
			@intFirstIndex > 0
			AND @intSecondIndex > 0
			)
	BEGIN
		SELECT @strShipperCode = SUBSTRING(@strMarks, @intFirstIndex + 1, (@intSecondIndex - @intFirstIndex - 1))

		SELECT TOP 1 @strShipperName = strName
		FROM dbo.tblEMEntity
		WHERE strEntityNo = @strShipperCode
	END
	ELSE
	BEGIN
		SELECT @strShipperCode = ''
			,@strShipperName = ''
	END

	INSERT INTO @Shipper (
		strShipperCode
		,strShipperName
		)
	SELECT @strShipperCode
		,@strShipperName

	RETURN
END
