CREATE PROCEDURE [dbo].[uspICSyncItemCategory]
    @intItemNo INT = NULL,
	@intCategoryId INT = NULL
AS
BEGIN
    UPDATE tblSTPumpItem
    SET tblSTPumpItem.intCategoryId = @intCategoryId
    FROM tblSTPumpItem PU
	JOIN tblICItemUOM UOM 
	ON PU.intItemUOMId = UOM.intItemUOMId
	JOIN tblICItem I
	ON UOM.intItemId = I.intItemId
	Where I.intItemId = @intItemNo
END