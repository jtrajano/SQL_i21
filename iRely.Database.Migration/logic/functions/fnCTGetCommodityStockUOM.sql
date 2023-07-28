--liquibase formatted sql

-- changeset Von:fnCTGetCommodityStockUOM.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetCommodityStockUOM]
(
	@commodityId int
)
RETURNS INT
AS
BEGIN
	DECLARE @unitMeasureId INT
	
	SELECT @unitMeasureId = intUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE ysnStockUnit = 1
	AND intCommodityId = @commodityId 

	RETURN @unitMeasureId
END



