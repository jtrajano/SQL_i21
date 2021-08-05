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
		strEmailDistributionOption = 
		(SELECT (CASE 
			WHEN (LOWER(ISNULL(emEntity.strDocumentDelivery,'')) like '%direct mail%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
				THEN 'print , email , CF Invoice'

			WHEN (LOWER(ISNULL(emEntity.strDocumentDelivery,'')) like '%email%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
				THEN 'email , CF Invoice'

			WHEN ( (LOWER(ISNULL(emEntity.strDocumentDelivery,'')) not like '%email%' OR  LOWER(ISNULL(emEntity.strDocumentDelivery,'')) not like '%direct mail%') AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) like '%cf invoice%')
				THEN 'email , CF Invoice'

			WHEN ( LOWER(ISNULL(emEntity.strDocumentDelivery,'')) like '%direct mail%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
				THEN 'print'

			WHEN ( LOWER(ISNULL(emEntity.strDocumentDelivery,'')) like '%email%' AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
				THEN 'print'

			WHEN (  (LOWER(ISNULL(emEntity.strDocumentDelivery,'')) not like '%email%' OR  LOWER(ISNULL(emEntity.strDocumentDelivery,'')) not like '%direct mail%') AND LOWER(ISNULL(arCustomerContact.strEmailDistributionOption,'')) not like '%cf invoice%')
				THEN 'print'
		END)),
		strEmail					= arCustomerContact.strEmail
	FROM tblCFInvoiceStagingTable 
	INNER JOIN vyuCFCustomerEntity AS emEntity 
	ON emEntity.intEntityId = tblCFInvoiceStagingTable.intCustomerId
	OUTER APPLY (
		SELECT TOP 1 
			 strEmailDistributionOption
			,strEmail 
		FROM vyuARCustomerContacts
		WHERE intEntityId = tblCFInvoiceStagingTable.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != '' AND ISNULL(ysnActive,0) = 1
	) AS arCustomerContact

	WHERE LOWER(strUserId) = LOWER(@strUserId) AND LOWER(strStatementType) = LOWER(@strStatementType)

		
END

