--liquibase formatted sql

-- changeset Von:fnCTGetCommodityUnitMeasure.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetCommodityUnitMeasure]
(
	@commodityUnitMeasureId INT
)
RETURNS INT
AS
BEGIN
	DECLARE @unitMeasureId INT

	SELECT @unitMeasureId = intUnitMeasureId
	FROM tblICCommodityUnitMeasure 
	WHERE intCommodityUnitMeasureId = @commodityUnitMeasureId

	RETURN @unitMeasureId
END



