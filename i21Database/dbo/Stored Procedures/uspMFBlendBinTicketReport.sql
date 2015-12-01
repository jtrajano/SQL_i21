CREATE PROCEDURE [dbo].[uspMFBlendBinTicketReport]
@xmlParam NVARCHAR(MAX) = NULL
AS
	DECLARE @intLotId			INT,
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
    
	SELECT	@intLotId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intLotId'

Select l.strLotNumber,i.strItemNo,i.strDescription,dbo.fnRemoveTrailingZeroes(wpl.dblQuantity) AS dblQuantity,
CASE WHEN wpl.dblWeightPerUnit=1 THEN '' ELSE dbo.fnRemoveTrailingZeroes(wpl.dblPhysicalCount) END AS dblPhysicalCount,
CASE WHEN wpl.dblWeightPerUnit=1 THEN '' ELSE dbo.fnRemoveTrailingZeroes(wpl.dblWeightPerUnit) END AS dblWeightPerUnit, 
w.strWorkOrderNo,w.strSalesOrderNo,wpl.strVesselNo,wpl.dtmCreated
From tblMFWorkOrderProducedLot wpl 
Join tblMFWorkOrder w on wpl.intWorkOrderId=w.intWorkOrderId
Join tblICItem i on w.intItemId=i.intItemId
Join tblICLot l on wpl.intLotId=l.intLotId
Where wpl.intLotId=@intLotId