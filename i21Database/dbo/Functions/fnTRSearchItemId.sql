CREATE FUNCTION [dbo].[fnTRSearchItemId]
(
	@SupplierName AS NVARCHAR(50),
	@SupplyPoint AS NVARCHAR(50),
	@Item AS NVARCHAR(50)
)
RETURNS INT

AS

BEGIN
	DECLARE @Id INT = NULL

	IF @SupplierName = '' 
	BEGIN
		SET @SupplierName = NULL
	END

	IF @SupplyPoint = '' 
	BEGIN
		SET @SupplyPoint = NULL
	END

	IF @Item = '' 
	BEGIN
		SET @Item = NULL
	END

	SELECT TOP 1 @Id = D.intSupplyPointProductSearchHeaderId 
	FROM tblTRSupplyPointProductSearchDetail D
	INNER JOIN tblTRSupplyPointProductSearchHeader H ON H.intSupplyPointProductSearchHeaderId = D.intSupplyPointProductSearchHeaderId 
	INNER JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = H.intSupplyPointId
	INNER JOIN tblEMEntity E ON E.intEntityId = SP.intEntityVendorId
	INNER JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = SP.intEntityLocationId
	WHERE D.intSupplyPointProductSearchHeaderId IN ( 
		SELECT intSupplyPointProductSearchHeaderId FROM tblTRSupplyPointProductSearchDetail SD WHERE SD.strSearchValue = @SupplierName)
	AND D.intSupplyPointProductSearchHeaderId IN ( 
		SELECT intSupplyPointProductSearchHeaderId FROM tblTRSupplyPointProductSearchDetail SD WHERE SD.strSearchValue = @SupplyPoint)
	AND D.intSupplyPointProductSearchHeaderId IN ( 
		SELECT intSupplyPointProductSearchHeaderId FROM tblTRSupplyPointProductSearchDetail SD WHERE SD.strSearchValue = @Item)
	ORDER BY H.intSupplyPointProductSearchHeaderId ASC
	-- INNER JOIN (
	-- 	SELECT H.intSupplyPointProductSearchHeaderId,  Condition = COUNT(H.intSupplyPointProductSearchHeaderId) FROM tblTRSupplyPointProductSearchDetail D
	-- 	INNER JOIN tblTRSupplyPointProductSearchHeader H ON H.intSupplyPointProductSearchHeaderId = D.intSupplyPointProductSearchHeaderId  
	-- 	WHERE (strSearchValue LIKE @SupplierName + '%'
	-- 	OR strSearchValue = @SupplyPoint 
	-- 	--OR strSearchValue LIKE @Item + '%'
	-- 	OR strSearchValue = @Item)
	-- 	AND H.intSupplyPointProductSearchHeaderId = A.intSupplyPointProductSearchHeaderId
	-- 	GROUP BY  H.intSupplyPointProductSearchHeaderId
	-- ) A ON A.intSupplyPointProductSearchHeaderId = H.intSupplyPointProductSearchHeaderId
	-- INNER JOIN (
	-- 	SELECT D.intSupplyPointProductSearchHeaderId, TotalCondition = COUNT(intSupplyPointProductSearchDetailId)  
	-- 	FROM tblTRSupplyPointProductSearchDetail D
	-- 	WHERE D.intSupplyPointProductSearchHeaderId = A.intSupplyPointProductSearchHeaderId
	-- 	GROUP BY D.intSupplyPointProductSearchHeaderId	
	-- ) B ON B.intSupplyPointProductSearchHeaderId = A.intSupplyPointProductSearchHeaderId
	-- WHERE (strSearchValue LIKE @SupplierName + '%'
	-- 	OR strSearchValue = @SupplyPoint 
	-- 	--OR strSearchValue LIKE @Item + '%'
	-- 	OR strSearchValue = @Item)
	-- AND B.TotalCondition = A.Condition
	-- ORDER BY H.intSupplyPointProductSearchHeaderId ASC

	-- WHERE strSearchValue LIKE @SupplierName + '%'
	-- 	OR strSearchValue = @SupplyPoint 
	-- 	--OR strSearchValue LIKE @Item + '%'
	-- 	OR strSearchValue = @Item
	-- ORDER BY A.Condition DESC, H.intSupplyPointProductSearchHeaderId ASC

	-- DECLARE @Location NVARCHAR(50)
	-- 	, @Supplier NVARCHAR(50)
	-- 	, @ItemNo NVARCHAR(50)
	-- 	, @Id INT

	-- SELECT TOP 1 @Location = SearchValue.strLocation
	-- 	, @Supplier = SearchValue.strSupplier
	-- 	, @ItemNo = SearchValue.strItemNo
	-- FROM vyuTRGetSupplyPointSearchValue SearchValue
	-- CROSS APPLY (
	-- 	SELECT Total.strLocation, Total.strSupplier, Total.strItemNo, dblTotal = COUNT(*) FROM vyuTRGetSupplyPointSearchValue Total
	-- 	WHERE SearchValue.strLocation = Total.strLocation
	-- 		AND SearchValue.strSupplier = Total.strSupplier
	-- 		AND SearchValue.strItemNo = Total.strItemNo
	-- 	GROUP BY Total.strLocation, Total.strSupplier, Total.strItemNo
	-- ) Total
	-- WHERE @SupplierName LIKE '%' + SearchValue.strSearchValue + '%'
	-- 		OR @SupplyPoint LIKE '%' + SearchValue.strSearchValue + '%'
	-- 		OR @Item LIKE '%' + SearchValue.strSearchValue + '%'
	-- GROUP BY SearchValue.strLocation, SearchValue.strSupplier, SearchValue.strItemNo, Total.dblTotal
	-- HAVING COUNT(*) = Total.dblTotal
	-- ORDER BY Total.dblTotal DESC

	-- SELECT @Id = intKeyId FROM vyuTRGetSupplyPointSearchValue
	-- WHERE @Location = strLocation
	-- 	AND @Supplier = strSupplier
	-- 	AND @ItemNo = strItemNo

	RETURN @Id
END
