--liquibase formatted sql

-- changeset Von:fnARGetDefaultDecimal.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetDefaultDecimal]() RETURNS INT
AS
BEGIN
	RETURN 2
END



