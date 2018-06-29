CREATE FUNCTION [dbo].[fnTRSearchSupplyPointId]
(
	@SupplyPoint AS NVARCHAR(100)
)
RETURNS INT

AS

BEGIN
	DECLARE @SupplyPointId AS INT = NULL

	-- Check Supply Point exact match
	IF EXISTS (SELECT TOP 1 1 FROM vyuTRSupplyPointView WHERE strSupplyPoint = @SupplyPoint)
	BEGIN
		SELECT TOP 1 @SupplyPointId = intSupplyPointId FROM vyuTRSupplyPointView WHERE strSupplyPoint = @SupplyPoint
	END
	-- Check Supply Point - Fuel Supplier combination match
	IF EXISTS (SELECT TOP 1 1 
				FROM vyuTRSupplyPointView 
				WHERE (@SupplyPoint = strSupplyPoint + ' ' + strFuelSupplier)
					OR (@SupplyPoint = strSupplyPoint + ' - ' + strFuelSupplier)
					OR (@SupplyPoint = strFuelSupplier + ' ' + strSupplyPoint)
					OR (@SupplyPoint = strFuelSupplier + ' - ' + strSupplyPoint))
	BEGIN
		SELECT TOP 1 @SupplyPointId = intSupplyPointId
		FROM vyuTRSupplyPointView
		WHERE (@SupplyPoint = strSupplyPoint + ' ' + strFuelSupplier)
			OR (@SupplyPoint = strSupplyPoint + ' - ' + strFuelSupplier)
			OR (@SupplyPoint = strFuelSupplier + ' ' + strSupplyPoint)
			OR (@SupplyPoint = strFuelSupplier + ' - ' + strSupplyPoint)
	END
	-- Check Supply point slight match
	IF EXISTS (SELECT TOP 1 1 FROM vyuTRSupplyPointView WHERE @SupplyPoint LIKE '%' + strSupplyPoint + '%')
	BEGIN
		SELECT TOP 1 @SupplyPointId = intSupplyPointId FROM vyuTRSupplyPointView WHERE @SupplyPoint LIKE '%' + strSupplyPoint + '%'
	END	

	RETURN @SupplyPointId
END