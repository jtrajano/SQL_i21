﻿CREATE FUNCTION dbo.fnTrimX(@str VARCHAR(MAX)) RETURNS VARCHAR(MAX)
AS
BEGIN
RETURN dbo.fnLTrimX(dbo.fnRTrimX(@str))
END