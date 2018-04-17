﻿CREATE PROCEDURE [dbo].[uspSTGetSalesTaxTotalsPreload]
	@intStoreId int
AS
BEGIN

	DECLARE @tbl TABLE (strTaxNumber NVARCHAR(20), intAccountId INT)

	--DECLARE @intCnt int
	--SET @intCnt = 1
	--WHILE(@intCnt <= 4)
	--BEGIN
	--	INSERT INTO @tbl
	--	Select @intCnt [Cnt], MAX(intSalesTaxAccountId) [intSalesTaxAccountId] FROM dbo.tblSMTaxCode TC
	--	JOIN dbo.tblSMTaxGroupCode TGC ON TGC.intTaxCodeId = TC.intTaxCodeId
	--	JOIN dbo.tblSTStore ST ON ST.intTaxGroupId = TGC.intTaxGroupId
	--	WHERE ISNULL(strStoreTaxNumber,'') = CAST(@intCnt as nvarchar(10)) AND ST.intStoreId = @intStoreId

	--	SET @intCnt = @intCnt + 1
	--END

	INSERT INTO @tbl
	SELECT TC.strStoreTaxNumber AS strTaxNumber
			, TC.intSalesTaxAccountId AS intAccountId
	FROM dbo.tblSMTaxCode TC 
	JOIN dbo.tblSMTaxGroupCode TGC ON TGC.intTaxCodeId = TC.intTaxCodeId
	JOIN dbo.tblSTStore ST ON ST.intTaxGroupId = TGC.intTaxGroupId
	LEFT JOIN dbo.tblGLAccount GLA ON GLA.intAccountId = TC.intSalesTaxAccountId
	WHERE ST.intStoreId = @intStoreId

	SELECT t.strTaxNumber
		 , t.intAccountId
		 , Acc.strAccountId 
	FROM @tbl t
	LEFT JOIN dbo.tblGLAccount Acc ON Acc.intAccountId = t.intAccountId

END
