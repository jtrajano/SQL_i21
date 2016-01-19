CREATE PROCEDURE [dbo].[uspSTGetSalesTaxTotalsPreload]
	@intStoreId int
AS
BEGIN

	DECLARE @tbl TABLE (intCnt int, intAccountId int)

	DECLARE @intCnt int
	SET @intCnt = 1
	WHILE(@intCnt <= 4)
	BEGIN
		INSERT INTO @tbl
		Select @intCnt [Cnt], MAX(intSalesTaxAccountId) [intSalesTaxAccountId] FROM dbo.tblSMTaxCode TC
		JOIN dbo.tblSMTaxGroupCode TGC ON TGC.intTaxCodeId = TC.intTaxCodeId
		JOIN dbo.tblSTStore ST ON ST.intTaxGroupId = TGC.intTaxGroupId
		WHERE ISNULL(strStoreTaxNumber,'') = CAST(@intCnt as nvarchar(10)) AND ST.intStoreId = @intStoreId

		SET @intCnt = @intCnt + 1
	END

	Select * from @tbl

END
