CREATE VIEW [dbo].[vyuICInventoryAdjustmentSourceLink]
	AS 
	
	select 
		a.intInventoryAdjustmentId, 
		a.intSourceId, 
		a.intSourceTransactionTypeId,
		b.strName,
		strTransactionFrom =  b.strTransactionForm,
		strSource = c.strDeliverySheetNumber
	 from tblICInventoryAdjustment a
	join tblICInventoryTransactionType b
		on a.intSourceTransactionTypeId = b.intTransactionTypeId
	left join (
		select intDeliverySheetId, strDeliverySheetNumber from tblSCDeliverySheet
	) c
		on b.intTransactionTypeId = 53 and c.intDeliverySheetId = a.intSourceId


