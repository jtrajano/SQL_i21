CREATE PROCEDURE [dbo].[uspSMCreateDocumentMaintenance]
	@title				NVARCHAR(50) = '',
	@companyLocation	INT = NULL,
	@customerId			INT = NULL,
	@source				NVARCHAR(25) = 'Invoice',
	@type				NVARCHAR(25) = 'Standard',
	@message			NVARCHAR(MAX) = '',
	@ysnHeader			BIT = 1,
	@newId				INT OUTPUT			
AS
	
	--DECLARE @NewId INT

	INSERT INTO tblSMDocumentMaintenance (
	strTitle				,intCompanyLocationId	,intLineOfBusinessId	
	,intEntityCustomerId	,strSource				,strType	
	,ysnCopyAll				,intConcurrencyId
	)
	VALUES(
	@title					,@companyLocation		,null
	,@customerId			,@source				,@type
	,0						,0
	)

	SET @newId = @@IDENTITY

	INSERT INTO tblSMDocumentMaintenanceMessage(
	intDocumentMaintenanceId		,strHeaderFooter			
	,intCharacterLimit
	,strMessage						
	,blbMessage					
	,ysnRecipe
	,ysnQuote						,ysnSalesOrder				,ysnPickList
	,ysnBOL							,ysnInvoice					,ysnScaleTicket
	,ysnInventoryTransfer			,strMessageOld				,ysnConverted
	,intConcurrencyId
	)
	SELECT
	@newId							,CASE WHEN @ysnHeader = 1 THEN 'Header' ELSE 'Footer' END							
	,0
	,@message						
	,CONVERT(varbinary(MAX), cast(@message as varchar(max)))	
	,1
	,1								,1									,1
	,1								,1									,1
	,1								,''									,1
	,0


RETURN 0
