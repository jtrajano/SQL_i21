--liquibase formatted sql

-- changeset Von:fnConvertFloatToNumeric.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

-- This function returns the weight per uom 
CREATE OR ALTER FUNCTION [dbo].[fnConvertFloatToNumeric] (
	@input AS FLOAT
)
RETURNS NUMERIC(38, 20) 
AS
BEGIN 
	--RETURN	CONVERT(DECIMAL(38,20),           
 --                   CONVERT(
	--					DECIMAL(16,15), 
	--					LEFT(CONVERT(VARCHAR(58), @input, 2),17)
	--				)
 --                   * POWER(
	--					CONVERT(
	--						DECIMAL(38,20),10), 
	--						RIGHT(CONVERT(VARCHAR(58), @input, 2),4)
	--					)
	--		)

	RETURN	CONVERT(
				DECIMAL(38,20),
				(
					CONVERT(
						DECIMAL(21,20), 
						LEFT(CONVERT(VARCHAR(50), @input, 2), 17)
					) 
					* POWER (
							CONVERT(DECIMAL(38, 20),10),  
							RIGHT(CONVERT(VARCHAR(50), @input, 2), 4)
					)				
				)
			)
END



