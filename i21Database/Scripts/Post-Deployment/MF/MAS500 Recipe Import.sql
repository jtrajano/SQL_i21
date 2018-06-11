CREATE TABLE [dbo].[iRely_MetaTransfer](
	[TransferObjectKey] [int] IDENTITY(1,1) NOT NULL,
	[TransferObject] [nvarchar](50) NULL,
	[TransferSequence] [int] NULL,
	[TransferCount] [int] NULL,
	[LastTransferDateTime] [datetime] NULL,
	[ViewName] [nvarchar](50) NULL,
	[FilterColumn] [nvarchar](50) NULL
)

GO

CREATE VIEW [dbo].[viRelyM_sp_Router_Header] AS
SELECT     a.CompanyID, a.RoutingId, a.VersionId, a.ItemKey, b.ItemID, ISNULL(c.WhseID, '') AS WhseID, a.Active, a.RollUpFlag, a.QTYCycle, 
                      ISNULL(e.WorkCenterID, '') AS WorkCenterID, a.UpdateDate,itmcls.itemclassname as ItemClassName
FROM         dbo.tmfRoutHead_HAI AS a INNER JOIN
                      dbo.timItem AS b ON a.ItemKey = b.ItemKey LEFT OUTER JOIN
                      dbo.timWarehouse AS c ON a.WhseKey = c.WhseKey LEFT OUTER JOIN
                      dbo.tmfRoutDetl_HAI AS d ON a.RoutingKey = d.RoutingKey AND d.ProgressStep = 'Y' AND d.WorkCenterKey IS NOT NULL LEFT OUTER JOIN
                      dbo.tmfWorkCenter_HAI AS e ON d.WorkCenterKey = e.WorkCenterKey LEFT OUTER JOIN 
						dbo.timItemClass AS itmcls ON itmcls.ItemClassKey = b.ItemClassKey 

WHERE a.Active = 1 AND a.RollUpFlag = 1 and ISNUll(WorkCenterId,'') Not in ('','SDRY') 

GO

CREATE VIEW [dbo].[viRelyM_sp_Router_Detail] AS
SELECT     a.CompanyID, a.RoutingKey, b.RoutingId, c.ItemID, b.VersionId, ISNULL(d.ItemID, ' ') AS MatItemID, ISNULL(e.WhseID, ' ') AS MatWhseID, 
                      a.OperationType, a.QTYCycle, a.MaterReqPer as MaterReqPer, Sum(a.MatReqPc / MaterReqPer) as MatReqPc , ISNULL(g.UnitMeasID, ' ') AS UnitMeasID, b.UpdateDate,itmcls.itemclassname as ItemClassName
FROM         dbo.tmfRoutDetl_HAI AS a INNER JOIN
                      dbo.tmfRoutHead_HAI AS b ON a.RoutingKey = b.RoutingKey INNER JOIN
                      dbo.timItem AS c ON c.ItemKey = b.ItemKey LEFT OUTER JOIN
                      dbo.timItem AS d ON a.MatItemKey = d.ItemKey LEFT OUTER JOIN
                      dbo.timWarehouse AS e ON a.WhseKey = e.WhseKey LEFT OUTER JOIN
                      dbo.tciUnitMeasure AS g ON a.MaterValUOMKey = g.UnitMeasKey LEFT JOIN 
					   dbo.timItemClass AS itmcls ON itmcls.ItemClassKey = d.ItemClassKey
WHERE a.ProgressStep <> 'Y' and 
b.Active=1 and b.RollupFlag=1 and a.OperationType='M' and MatReqPc != 0
group by   a.CompanyID, a.RoutingKey, b.RoutingId, c.ItemID, b.VersionId, ISNULL(d.ItemID, ' ') , ISNULL(e.WhseID, ' ') , 
                      a.OperationType, a.QTYCycle, a.MaterReqPer, ISNULL(g.UnitMeasID, ' ') , b.UpdateDate,itmcls.itemclassname

GO

CREATE PROCEDURE [dbo].[spGetBOM_ERP]      
      
AS      
      
BEGIN TRY      
    
 -- 0. Declarations    
 DECLARE @LastTransferDateTime datetime, @ErrMsg nvarchar(MAX)    
  
 SELECT @LastTransferDateTime = ISNULL(LastTransferDateTime,'1900-01-01')     
 FROM iRely_MetaTransfer WHERE TransferObject = 'BOM'    
  
 SELECT * FROM viRelyM_sp_Router_Header WHERE UpdateDate > @LastTransferDateTime   

 UPDATE iRely_MetaTransfer SET     
 LastTransferDateTime = GETDATE(),    
 TransferCount = ISNULL(TransferCount,0) + 1    
 WHERE TransferObject = 'BOM'  
      
END TRY      
      
BEGIN CATCH      
    
 SET @ErrMsg = ERROR_MESSAGE()        
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')       
    
END CATCH  

GO

 CREATE PROCEDURE [dbo].[spGetBOMItems_ERP]      
      
AS      
      
BEGIN TRY      
    
 -- 0. Declarations    
 DECLARE @LastTransferDateTime datetime, @ErrMsg nvarchar(MAX)    
  
 SELECT @LastTransferDateTime = ISNULL(LastTransferDateTime,'1900-01-01')     
 FROM iRely_MetaTransfer WHERE TransferObject = 'BOM'    
  
 SELECT * FROM viRelyM_sp_Router_Detail WHERE UpdateDate > @LastTransferDateTime   
      
END TRY      
      
BEGIN CATCH      
    
 SET @ErrMsg = ERROR_MESSAGE()        
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')       
    
END CATCH  

GO

insert into [iRely_MetaTransfer]([TransferObject],[ViewName])
values('BOM','viRelyM_sp_Router_Header')

GO
