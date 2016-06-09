CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionCertificateReport]
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

SELECT 
	L.intLoadId,
	DOC.strDocumentName,
	LDOC.strDocumentType,
	LDOC.intOriginal,
	LDOC.intCopies
FROM	tblLGLoadDocuments LDOC
JOIN	tblLGLoad L ON L.intLoadId= LDOC.intLoadId
JOIN	tblICDocument DOC ON DOC.intDocumentId = LDOC.intDocumentId
WHERE 	L.intLoadId = @xmlParam	
END
