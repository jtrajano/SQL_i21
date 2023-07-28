--liquibase formatted sql

-- changeset Von:fnAPGetVoucherForm1099.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPGetVoucherForm1099]()
RETURNS @tblResult TABLE (intId INT , strText NVARCHAR(50) )
AS
BEGIN
	INSERT INTO @tblResult
			 SELECT 0 ,  'None' UNION
			 SELECT 1 ,  '1099-MISC' UNION
			 SELECT 2 ,  '1099-INT' UNION
			 SELECT 3 ,  '1099-B' UNION
			 SELECT 4 ,  '1099-PATR' UNION
			 SELECT 5 ,  '1099-DIV'	UNION
			 SELECT 6 ,  '1099-K'
	RETURN;
END



