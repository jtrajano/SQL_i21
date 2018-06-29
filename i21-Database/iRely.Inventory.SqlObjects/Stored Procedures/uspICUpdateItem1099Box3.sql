CREATE PROCEDURE [dbo].[uspICUpdateItem1099Box3]
	@intCommodityId INT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

BEGIN

	UPDATE Item
	SET Item.ysn1099Box3 = Commodity.ysn1099Box3
	FROM tblICItem Item
	INNER JOIN tblICCommodity Commodity 
		ON Commodity.intCommodityId = Item.intCommodityId
	WHERE Commodity.intCommodityId = @intCommodityId
	
END