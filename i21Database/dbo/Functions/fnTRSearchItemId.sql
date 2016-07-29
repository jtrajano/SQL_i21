CREATE FUNCTION [dbo].[fnTRSearchItemId]
(
	@SupplyPoint AS NVARCHAR(100),
	@Item AS NVARCHAR(100)
)
RETURNS INT

AS

BEGIN
	DECLARE @Location NVARCHAR(50)
		, @Supplier NVARCHAR(50)
		, @ItemNo NVARCHAR(50)
		, @Id INT

	SELECT TOP 1 @Location = SearchValue.strLocation
		, @Supplier = SearchValue.strSupplier
		, @ItemNo = SearchValue.strItemNo
	FROM vyuTRGetSupplyPointSearchValue SearchValue
	CROSS APPLY (
		SELECT Total.strLocation, Total.strSupplier, Total.strItemNo, dblTotal = COUNT(*) FROM vyuTRGetSupplyPointSearchValue Total
		WHERE SearchValue.strLocation = Total.strLocation
			AND SearchValue.strSupplier = Total.strSupplier
			AND SearchValue.strItemNo = Total.strItemNo
		GROUP BY Total.strLocation, Total.strSupplier, Total.strItemNo
	) Total
	WHERE @SupplyPoint LIKE '%' + SearchValue.strSearchValue + '%'
			OR @Item LIKE '%' + SearchValue.strSearchValue + '%'
	GROUP BY SearchValue.strLocation, SearchValue.strSupplier, SearchValue.strItemNo, Total.dblTotal
	HAVING COUNT(*) = Total.dblTotal
	ORDER BY Total.dblTotal DESC

	SELECT @Id = intKeyId FROM vyuTRGetSupplyPointSearchValue
	WHERE @Location = strLocation
		AND @Supplier = strSupplier
		AND @ItemNo = strItemNo

	RETURN @Id
END
