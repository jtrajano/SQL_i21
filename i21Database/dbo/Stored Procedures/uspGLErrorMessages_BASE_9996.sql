CREATE PROCEDURE [dbo].[uspGLErrorMessages]
AS

DECLARE @strmessage AS NVARCHAR(MAX)
--60001 to 70000
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60001) EXEC sp_dropmessage 60001, 'us_english'	
SET @strmessage = 'Invalid G/L account id found.'
EXEC sp_addmessage 60001,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60002) EXEC sp_dropmessage 60002, 'us_english'	
SET @strmessage = 'Invalid G/L temporary table.'
EXEC sp_addmessage 60002,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60003) EXEC sp_dropmessage 60003, 'us_english'	
SET @strmessage = 'Debit and credit amounts are not balanced.'
EXEC sp_addmessage 60003,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60004) EXEC sp_dropmessage 60004, 'us_english'	
SET @strmessage = 'Unable to find an open fiscal year period to match the transaction date.'
EXEC sp_addmessage 60004,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60005) EXEC sp_dropmessage 60005, 'us_english'	
SET @strmessage = 'G/L entries are expected. Cannot continue because it is missing.'
EXEC sp_addmessage 60005,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60006) EXEC sp_dropmessage 60006, 'us_english'	
SET @strmessage = 'The transaction is already posted.'
EXEC sp_addmessage 60006,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60007) EXEC sp_dropmessage 60007, 'us_english'	
SET @strmessage = 'The transaction is already unposted.'
EXEC sp_addmessage 60007,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60008) EXEC sp_dropmessage 60008, 'us_english'	
SET @strmessage = 'You cannot %s transactions you did not create. Please contact your local administrator.'
EXEC sp_addmessage 60008,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60009) EXEC sp_dropmessage 60009, 'us_english'	
SET @strmessage = 'Unable to find an open fiscal year period for %s module to match the transaction date.'
EXEC sp_addmessage 60009,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60010) EXEC sp_dropmessage 60010, 'us_english'	
SET @strmessage = 'Unable to recalculate summary. General Ledger Detail has out of balance transactions.'
EXEC sp_addmessage 60010,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60011) EXEC sp_dropmessage 60011, 'us_english'	
SET @strmessage = 'Fiscal period for %s is %s'
EXEC sp_addmessage 60011,11,@strmessage,'us_english','False'


IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60012) EXEC sp_dropmessage 60012, 'us_english'	
SET @strmessage = 'Fiscal period of reverse date for %s is %s'
EXEC sp_addmessage 60012,11,@strmessage,'us_english','False'


