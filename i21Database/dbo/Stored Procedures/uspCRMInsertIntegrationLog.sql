CREATE PROCEDURE [dbo].[uspCRMInsertIntegrationLog]
	@intBrandId				INT = NULL,
	@intOpportunityId		INT = NULL,
	@strAPIMessage		    NVARCHAR(250) = NULL,
	@strStatus              NVARCHAR(50) = NULL,
	@strAction              NVARCHAR(50) = NULL
AS

INSERT INTO tblCRMBrandIntegrationLog (
	intBrandId
	,intOpportunityId
	,dtmIntegrationDate
	,strAPIMessage
	,strStatus
	,strAction
)
VALUES (
	@intBrandId
	,@intOpportunityId
	,GETDATE()
	,@strAPIMessage COLLATE Latin1_General_CI_AS
	,@strStatus COLLATE Latin1_General_CI_AS
	,@strAction COLLATE Latin1_General_CI_AS
)

GO