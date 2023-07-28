--liquibase formatted sql

-- changeset Von:fnCFPadString.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCFPadString](@data nvarchar(max) ,@totalLen int ,@padStr nvarchar(max) = '' , @direction nvarchar(max) = 'left')
RETURNS nvarchar(max) 
AS 
BEGIN
    DECLARE @returnData NVARCHAR(MAX)
	SET @data = ISNULL(@data,'')
	SET @padStr = ISNULL(@padStr,'0')
	SET @returnData = @data
	
    SET @data = CAST(ISNULL(@data,'') as varchar(MAX))
	
	IF((@totalLen - LEN(@data)) >= 1)
	BEGIN
		IF(LOWER(@direction) = 'left')
		BEGIN
			SET @returnData = (REPLICATE(@padStr, (@totalLen - LEN(@data))) + @data);
		END
		ELSE
		BEGIN
			SET @returnData = (@data + REPLICATE(@padStr, (@totalLen - LEN(@data))));
		END
	END



	RETURN @returnData

END;



