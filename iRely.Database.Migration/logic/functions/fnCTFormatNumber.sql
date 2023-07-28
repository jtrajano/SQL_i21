--liquibase formatted sql

-- changeset Von:fnCTFormatNumber.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234


	CREATE OR ALTER FUNCTION [dbo].[fnCTFormatNumber]
	(
		@dblNumber numeric(18,6)
		,@strNumberFormat nvarchar(50)
	)
	RETURNS NVARCHAR(MAX)
	AS 
	BEGIN 
		return format(@dblNumber,@strNumberFormat);
	END



