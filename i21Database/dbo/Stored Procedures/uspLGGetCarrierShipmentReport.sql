CREATE PROCEDURE [dbo].[uspLGGetCarrierShipmentReport]
		@xmlParam NVARCHAR(MAX) = NULL
AS
DECLARE @intPLoadId INT
DECLARE @intPEntityId INT
DECLARE @intPEntityLocationId INT
DECLARE @intSLoadId INT
DECLARE @intSEntityId INT
DECLARE @intSEntityLocationId INT
BEGIN
	DECLARE @intLoadNumber			INT,
			@xmlDocumentId			INT 
			
	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
        
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	SELECT	Cast([from] as INT) AS   intLoadNumber
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
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
    WHERE	[fieldname] = 'intLoadNumber'
	
END
