
CREATE PROCEDURE [dbo].[uspCFSyncEmailDistributionFormat]
		@strUserId NVARCHAR(MAX),
		@strStatementType NVARCHAR(MAX)  
		AS 
BEGIN

	--===RESET FIELDS TO NULL===--
	UPDATE tblCFInvoiceStagingTable
	SET 
		strEmailDistributionOption = NULL,
		strEmail = NULL
	WHERE strUserId = @strUserId AND strStatementType = @strStatementType 

	--===UPDATE STAGING TABLE===--
	UPDATE tblCFInvoiceStagingTable 
	SET 
		strEmailDistributionOption  = arCustomerContact.strEmailDistributionOption,
		strEmail					= arCustomerContact.strEmail
	FROM tblCFInvoiceStagingTable 
	OUTER APPLY (
		SELECT TOP 1 
			 strEmailDistributionOption
			,strEmail 
		FROM vyuARCustomerContacts
		WHERE intEntityId = tblCFInvoiceStagingTable.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '' AND ISNULL(ysnActive,0) = 1
	) AS arCustomerContact
	WHERE LOWER(strUserId) = LOWER(@strUserId) AND LOWER(strStatementType) = LOWER(@strStatementType)

		
END

