CREATE PROCEDURE [dbo].[uspGRUnPostSellOffsite]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSellOffsiteId INT
	DECLARE @UserId INT
	DECLARE @strSellOffSiteNumber NVARCHAR(50)
	
	DECLARE @intInvoiceId INT	
	

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	SELECT @intSellOffsiteId = intSellOffsiteId
		  ,@UserId = intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			 intSellOffsiteId INT
			,intEntityUserSecurityId INT
	)
	
	SELECT @intInvoiceId=intInvoiceId FROM tblGRSellOffsite WHERE intSellOffsiteId=@intSellOffsiteId

	UPDATE CS
	SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnit
	FROM tblGRCustomerStorage CS
	JOIN (
			SELECT intCustomerStorageId
				,SUM(dblUnits) dblUnit
			FROM tblGRStorageHistory
			WHERE intInvoiceId=@intInvoiceId
			GROUP BY intCustomerStorageId
		) SH ON SH.intCustomerStorageId = CS.intCustomerStorageId

	DELETE FROM tblGRSellOffsite WHERE intSellOffsiteId=@intSellOffsiteId
	DELETE FROM tblGRStorageHistory WHERE intInvoiceId=@intInvoiceId
	DELETE FROM tblARInvoice WHERE intInvoiceId=@intInvoiceId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
