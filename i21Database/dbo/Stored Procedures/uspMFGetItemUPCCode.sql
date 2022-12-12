CREATE PROCEDURE uspMFGetItemUPCCode 
(
	@strUPCCode		NVARCHAR(50)
  , @intLocationId  INT
)
AS
BEGIN
	SELECT ItemUOM.intItemId
		 , ItemUOM.intItemUOMId
		 , ItemUOM.intUnitMeasureId
		 , ItemUOM.strLongUPCCode
		 , ItemUOM.strUpcCode
		 ,ItemLocation.ysnStorageUnitRequired
	FROM tblICItemUOM AS ItemUOM
	LEFT JOIN tblICItemLocation AS ItemLocation ON ItemUOM.intItemId = ItemLocation.intItemId
	WHERE ItemUOM.strLongUPCCode = @strUPCCode AND ItemLocation.intLocationId = @intLocationId;
END