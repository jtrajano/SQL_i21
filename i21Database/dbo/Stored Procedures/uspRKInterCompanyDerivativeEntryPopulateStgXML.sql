
CREATE PROCEDURE uspRKInterCompanyDerivativeEntryPopulateStgXML
	 @intFutOptTransactionHeaderId INT
	,@intContractHeaderId INT
	,@strInternalTradeNo NVARCHAR(20)
	,@intHedgedLots INT
	,@strTransactionType NVARCHAR(20)
	,@action NVARCHAR(20)
	,@intInterCompanyTransactionConfigurationId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET XACT_ABORT ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

DECLARE @strCondition NVARCHAR(MAX)
DECLARE @strFutOptTransactionHeaderXML NVARCHAR(MAX)
DECLARE @strFutOptTransactionXML NVARCHAR(MAX)

DECLARE @intToCompanyId INT,
		@intEntityId INT,
		@intCompanyLocationId INT


SELECT TOP 1 
	@intToCompanyId = intToCompanyId, 
	@intEntityId = intEntityId, 
	@intCompanyLocationId = intCompanyLocationId
FROM tblSMInterCompanyTransactionConfiguration
WHERE intInterCompanyTransactionConfigurationId = @intInterCompanyTransactionConfigurationId
		

SELECT @strCondition = 'intFutOptTransactionHeaderId = ' + LTRIM(@intFutOptTransactionHeaderId)

EXEC [dbo].[uspCTGetTableDataInXML] 
  'tblRKFutOptTransactionHeader'
 ,@strCondition
 ,@strFutOptTransactionHeaderXML OUTPUT
 ,NULL
 ,NULL

 EXEC [dbo].[uspCTGetTableDataInXML] 
  'tblRKFutOptTransaction'
 ,@strCondition
 ,@strFutOptTransactionXML OUTPUT
 ,NULL
 ,NULL

 IF @strFutOptTransactionHeaderXML IS NOT NULL AND @strFutOptTransactionXML IS NOT NULL
 BEGIN
	 INSERT INTO tblRKInterCompanyDerivativeEntryStage(
		intFutOptTransactionHeaderId
		,intContractHeaderId
		,strHeaderXML
		,strDetailXML
		,strTransactionType
		,strRowState
		,intMultiCompanyId
		,intEntityId
		,intCompanyLocationId
		,intHedgedLots
		,strInternalTradeNo)
	VALUES(
		@intFutOptTransactionHeaderId
		,@intContractHeaderId
		,@strFutOptTransactionHeaderXML
		,@strFutOptTransactionXML
		,@strTransactionType
		,@action
		,@intToCompanyId
		,@intEntityId
		,@intCompanyLocationId
		,@intHedgedLots
		,@strInternalTradeNo)
END

IF @@ERROR <> 0	GOTO _Rollback

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
_Commit:
	COMMIT TRANSACTION
	GOTO _Exit
	
_Rollback:
	ROLLBACK TRANSACTION

_Exit: