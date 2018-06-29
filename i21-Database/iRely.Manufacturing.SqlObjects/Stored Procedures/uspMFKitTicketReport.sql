CREATE PROCEDURE [dbo].[uspMFKitTicketReport]
@xmlParam NVARCHAR(MAX) = NULL
AS
	DECLARE @intPickListId			INT,
			@idoc					INT 
			
	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
	EXEC sp_xml_preparedocument @idoc output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@idoc, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intPickListId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intPickListId'

Declare @intWorkOrderCount int  
SELECT  @intWorkOrderCount = COUNT(1) FROM tblMFWorkOrder WHERE intPickListId = @intPickListId 

Select pl.strPickListNo,i.strItemNo,i.strDescription,dbo.fnRemoveTrailingZeroes(SUM(pld.dblQuantity)) AS dblQuantity,
dbo.fnRemoveTrailingZeroes(SUM(pld.dblQuantity)) + ' ' + MAX(um.strUnitMeasure) AS dblQuantityUOM,
pl.strWorkOrderNo,pl.dtmCreated,@intWorkOrderCount AS intWorkOrderCount
From tblMFPickList pl 
Join tblMFPickListDetail pld on pl.intPickListId=pld.intPickListId
Join tblMFWorkOrder w on pl.intPickListId=w.intPickListId
Join tblICItem i on w.intItemId=i.intItemId
Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Where pl.intPickListId=@intPickListId
Group By pl.strPickListNo,i.strItemNo,i.strDescription,pl.strWorkOrderNo,pl.dtmCreated