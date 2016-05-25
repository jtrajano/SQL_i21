CREATE FUNCTION [dbo].[fnTRSearchItemId]
(
	@SupplyPointId AS INT,
	 @ItemString AS NVARCHAR(100)
)
RETURNS INT

AS

BEGIN
	DECLARE @ItemId AS INT = NULL
	
	-- Check Item No match
	IF EXISTS (SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = @ItemString)
	BEGIN
		SELECT TOP 1 @ItemId = intItemId FROM tblICItem WHERE strItemNo = @ItemString
	END
	-- Check Item Description match
	ELSE IF EXISTS (SELECT TOP 1 1 FROM tblICItem WHERE strDescription = @ItemString)
	BEGIN
		SELECT TOP 1 @ItemId = intItemId FROM tblICItem WHERE strDescription = @ItemString
	END
	-- Check Supply Point Item Search config complete match
	ELSE IF EXISTS (SELECT TOP 1 1 FROM tblTRSupplyPointProductSearchDetail Detail
					LEFT JOIN tblTRSupplyPointProductSearchHeader Header ON Header.intSupplyPointProductSearchHeaderId = Detail.intSupplyPointProductSearchHeaderId
					WHERE Detail.strSearchValue = @ItemString
						AND Header.intSupplyPointId = @SupplyPointId)
	BEGIN
		SELECT TOP 1 @ItemId = Header.intItemId
		FROM tblTRSupplyPointProductSearchDetail Detail
		LEFT JOIN tblTRSupplyPointProductSearchHeader Header ON Header.intSupplyPointProductSearchHeaderId = Detail.intSupplyPointProductSearchHeaderId
		WHERE Detail.strSearchValue = @ItemString
			AND Header.intSupplyPointId = @SupplyPointId
	END
	-- Check Supply Point Item Search config slight match
	ELSE IF EXISTS (SELECT TOP 1 1 FROM tblTRSupplyPointProductSearchDetail Detail
					LEFT JOIN tblTRSupplyPointProductSearchHeader Header ON Header.intSupplyPointProductSearchHeaderId = Detail.intSupplyPointProductSearchHeaderId
					WHERE Detail.strSearchValue LIKE '%' + @ItemString + '%'
						AND Header.intSupplyPointId = @SupplyPointId)
	BEGIN
		SELECT TOP 1 @ItemId = Header.intItemId 
		FROM tblTRSupplyPointProductSearchDetail Detail
		LEFT JOIN tblTRSupplyPointProductSearchHeader Header ON Header.intSupplyPointProductSearchHeaderId = Detail.intSupplyPointProductSearchHeaderId
		WHERE Detail.strSearchValue LIKE '%' + @ItemString + '%'
			AND Header.intSupplyPointId = @SupplyPointId
	END	

	RETURN @ItemId
END