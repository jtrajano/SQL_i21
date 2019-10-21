CREATE PROCEDURE [dbo].[uspLGGetWarehouseInstructionReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	--DECLARE @intReferenceNumber			INT,
	--		@xmlDocumentId				INT 
			
	--IF	LTRIM(RTRIM(@xmlParam)) = ''   
	--	SET @xmlParam = NULL   
      
	--DECLARE @temp_xml_table TABLE 
	--(  
	--		[fieldname]		NVARCHAR(50),  
	--		condition		NVARCHAR(20),        
	--		[from]			NVARCHAR(50), 
	--		[to]			NVARCHAR(50),  
	--		[join]			NVARCHAR(10),  
	--		[begingroup]	NVARCHAR(50),  
	--		[endgroup]		NVARCHAR(50),  
	--		[datatype]		NVARCHAR(50) 
	--)  
  
	--EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	--INSERT INTO @temp_xml_table  
	--SELECT	*  
	--FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	--WITH (  
	--			[fieldname]		NVARCHAR(50),  
	--			condition		NVARCHAR(20),        
	--			[from]			NVARCHAR(50), 
	--			[to]			NVARCHAR(50),  
	--			[join]			NVARCHAR(10),  
	--			[begingroup]	NVARCHAR(50),  
	--			[endgroup]		NVARCHAR(50),  
	--			[datatype]		NVARCHAR(50)  
	--)  
    
	--SELECT	@intReferenceNumber = [from]
	--FROM	@temp_xml_table   
	--WHERE	[fieldname] = 'intReferenceNumber' 

SELECT * FROM tblLGLoadWarehouseServices WH WHERE WH.intLoadWarehouseId = @xmlParam AND WH.ysnPrint = 1 ORDER BY WH.intSort ASC
END
