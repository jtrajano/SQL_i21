CREATE PROCEDURE [dbo].[uspCTErrorMessages]
AS

	DECLARE @strmessage AS NVARCHAR(MAX)
	IF EXISTS(SELECT 1 FROM sys.messages 
	 WHERE message_id =  110001) 
	 EXEC sp_dropmessage 110001, 'us_english'	
	SET @strmessage = 'Available quantity for the contract %s and sequence %s is %s, which is insufficient to Save/Post a quantity of %s therefore could not Save/Post this transaction.'
	EXEC sp_addmessage   110001,16,@strmessage,'us_english','False'

	IF EXISTS(SELECT 1 FROM sys.messages 
	 WHERE message_id =  110002) 
	 EXEC sp_dropmessage 110002, 'us_english'	
	SET @strmessage = 'UOM %s selected in Collateral %s is not configured for the item %s.'
	EXEC sp_addmessage   110002,16,@strmessage,'us_english','False'

	IF EXISTS(SELECT 1 FROM sys.messages 
	 WHERE message_id =  110003) 
	 EXEC sp_dropmessage 110003, 'us_english'	
	SET @strmessage = 'Remaining quantity for Collateral %s cannot be negative.'
	EXEC sp_addmessage   110003,16,@strmessage,'us_english','False'

	IF EXISTS(SELECT 1 FROM sys.messages 
	 WHERE message_id =  110004) 
	 EXEC sp_dropmessage 110004, 'us_english'	
	SET @strmessage = 'Remaining quantity for Collateral %s cannot be more than original quantity.'
	EXEC sp_addmessage   110004,16,@strmessage,'us_english','False'

	IF EXISTS(SELECT 1 FROM sys.messages 
	 WHERE message_id =  110005) 
	 EXEC sp_dropmessage 110005, 'us_english'	
	SET @strmessage = 'Multiple details are available for the pricing of sequence %s. Cannot slice sequence %s.'
	EXEC sp_addmessage   110005,16,@strmessage,'us_english','False'

	IF EXISTS(SELECT 1 FROM sys.messages 
	 WHERE message_id =  110006) 
	 EXEC sp_dropmessage 110006, 'us_english'	
	SET @strmessage = 'Pricing status for sequence %s is partial. Cannot slice sequence %s.'
	EXEC sp_addmessage   110006,16,@strmessage,'us_english','False'