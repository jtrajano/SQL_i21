CREATE VIEW [dbo].[vyuICGetShipmentAddWorkOrder]
AS

SELECT *
FROM 
	vyuICGetShipmentAddSalesOrder -- Please replace it with the 'Ag Work Order' equivalent. You can use vyuICGetShipmentAddSalesOrder as the pattern. 
WHERE
	1 = 0 
