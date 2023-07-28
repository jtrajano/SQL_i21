--liquibase formatted sql

-- changeset Von:fnCalculateAdjustByQuantity.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

-- This function returns new adjust by quantity. 
CREATE OR ALTER FUNCTION [dbo].[fnCalculateAdjustByQuantity] (
	@dblNewQuantity AS NUMERIC(38,20)
	,@dblOriginalQuantity AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	RETURN (-1 * (ISNULL(@dblNewQuantity, 0) - ISNULL(@dblOriginalQuantity, 0)))
END



