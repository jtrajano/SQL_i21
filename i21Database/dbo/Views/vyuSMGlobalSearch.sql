CREATE VIEW [dbo].[vyuSMGlobalSearch] WITH SCHEMABINDING
AS
SELECT ROW_NUMBER() over(order by Id) as intGSIndexId, strNamespace, strDisplayTitle, strValueField, strValueData, strDisplayData, strTag
FROM
(
	select 
		'IC' + CONVERT(VARCHAR,[intItemId]) as Id,
		'Inventory.view.Item' as strNamespace,
		'Item' as strDisplayTitle,			
		'intItemId' as strValueField,
		item.intItemId as strValueData,
		item.strItemNo as strDisplayData,			
		item.strItemNo + ', ' + item.strType + ', ' + item.strDescription   as strTag
	from [dbo].[tblICItem] as item		 		 
	union
	select 
		'EM' + CONVERT(VARCHAR,[intEntityId]) as Id,
		'EntityManagement.view.Entity' as strNamespace,
		'Sample User' as strDisplayTitle,			
		'intEntityId' as strValueField,
		entity.intEntityId as strValueData,
		entity.strName as strDisplayData,
		entity.strName + ', ' + entity.strEntityNo as strTag
	from [dbo].[tblEntity] as entity
)
as viewResult