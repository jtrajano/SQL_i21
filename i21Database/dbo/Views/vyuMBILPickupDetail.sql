CREATE VIEW [dbo].[vyuMBILPickupDetail]
AS
SELECT detail.intPickupDetailId
      ,detail.intPickupHeaderId
	  ,detail.intItemId
	  ,item.strDescription
	  ,item.strItemNo
	  ,detail.dblQuantity 
	  ,detail.dblPickupQuantity
	  ,detail.strRack  
FROM tblMBILPickupDetail detail    
INNER JOIN tblICItem item on detail.intItemId = item.intItemId 