--liquibase formatted sql

-- changeset Von:fnCTGetCommodityUOM.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetCommodityUOM]
(
	@unitMeasureId int
)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @unitMeasure NVARCHAR(50)
	
	SELECT @unitMeasure = strUnitMeasure 
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @unitMeasureId

	RETURN @unitMeasure
END



