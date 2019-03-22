CREATE FUNCTION [dbo].[fnAPGetVoucherCategories1099]()
RETURNS @tblResult TABLE (intId INT ,strText NVARCHAR(60))
AS
BEGIN

	INSERT INTO @tblResult
		SELECT 0 ,  'None' UNION
		SELECT 1 ,  'Crop Insurance Proceeds' UNION
		SELECT 2 ,  'Direct Sales' UNION
		SELECT 3 ,  'Excess Golden Parachute Payments' UNION
		SELECT 4 ,  'Federal Income Tax Withheld' UNION
		SELECT 5 ,  'Fishing Boat Proceeds' UNION

		SELECT 6 ,  'Gross Proceeds Paid to an Attorney' UNION
		SELECT 7 ,  'Medical and Health Care Payments' UNION
		SELECT 8 ,  'Nonemployee Compensation' UNION
		SELECT 9 ,  'Other Income' UNION
		SELECT 10 , 'Rents' UNION
		SELECT 11 , 'Royalties' UNION
		SELECT 12 , 'Substitute Payments in Lieu of Dividends or Interest'
	RETURN;
END
