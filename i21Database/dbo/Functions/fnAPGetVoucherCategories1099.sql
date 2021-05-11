CREATE FUNCTION [dbo].[fnAPGetVoucherCategories1099](@intType AS INT)
RETURNS @tblResults TABLE (intId INT ,strText NVARCHAR(60))
AS
BEGIN

	IF @intType = 1
	BEGIN
		INSERT INTO @tblResults
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
	END
	ELSE IF @intType = 4
	BEGIN
		INSERT INTO @tblResults
		SELECT 0 ,  'None' UNION
		SELECT 1 ,  'Patronage Dividends' UNION
		SELECT 2 ,  'Nonpatronage Distributions' UNION
		SELECT 3 ,  'Per-unit retain allocations' UNION
		SELECT 4 ,  'Federal income tax withheld' UNION
		SELECT 5 ,  'Redemption of nonqualified notices and retain allocations' UNION

		SELECT 6 ,  'Domestic production activities deduction' UNION
		SELECT 7 ,  'Investment credit' UNION
		SELECT 8 ,  'Work opportunity credit' UNION
		SELECT 9 ,  'Patron''s AMT adjustment' UNION
		SELECT 10 , 'Other credits and deductions'
	END
	ELSE IF @intType = 5
	BEGIN
		INSERT INTO @tblResults
		SELECT 0 ,  'Total ordinary dividends' UNION
		SELECT 1 ,  'Qualified dividends' UNION
		SELECT 2 ,  'Total capital gain distr.' UNION
		SELECT 3 ,  'Unrecap. Sec. 1250 gain' UNION
		SELECT 4 ,  'Section 1202 gain' UNION
		SELECT 5 ,  'Collectibles (28%) gain' UNION

		SELECT 6 ,  'Nondividend distributions' UNION
		SELECT 7 ,  'Federal income tax withheld' UNION
		SELECT 8 ,  'Investment expenses' UNION
		SELECT 9 ,  'Foreign tax paid' UNION
		SELECT 10 , 'Foreign country or U.S. possession' UNION
		SELECT 11 , 'Cash liquidation distributions' UNION
		SELECT 12 , 'Noncash liquidation distributions' UNION
		SELECT 13 , 'Exempt-interest dividends' UNION
		SELECT 14 , 'Specified private activity bond interest dividends' UNION
		SELECT 15 , 'State tax withheld'
	END
	ELSE IF @intType = 6
	BEGIN
		INSERT INTO @tblResults
		SELECT 0 ,  'Gross Payment Card/Third Party Network' UNION
		SELECT 1 ,  'Card Not Present'
	END
	RETURN;
END
