CREATE VIEW [dbo].[vyuMFGetParentLot]
	AS
Select pl.intParentLotId,pl.strParentLotNumber,pl.intParentLotId AS intLotId,pl.strParentLotNumber AS strLotNumber,
i.intItemId,i.strItemNo,i.strDescription AS strItemDescription
From tblICParentLot pl Join tblICItem i on pl.intItemId=i.intItemId
