CREATE VIEW [dbo].[vyuSCAgWorkOrderDetail]
AS 
	SELECT 
		A.intWorkOrderId
		,A.intWorkOrderDetailId
		,A.intItemId
	FROM tblAGWorkOrderDetail A
	INNER JOIN tblICItem B
		ON A.intItemId = B.intItemId
	
	
	
GO