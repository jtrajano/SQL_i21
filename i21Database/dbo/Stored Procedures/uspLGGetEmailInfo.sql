CREATE PROCEDURE uspLGGetEmailInfo @intTransactionId INT
	,@strReportName NVARCHAR(100)
	,@strHyperLink NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intEntityId INT
	DECLARE @strEntityName NVARCHAR(200)
	DECLARE @body NVARCHAR(MAX) = ''
	DECLARE @Subject NVARCHAR(MAX) = ''
	DECLARE @Filter NVARCHAR(MAX) = ''
	DECLARE @strIds AS NVARCHAR(MAX)

	SELECT @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intTransactionId

	SELECT @intEntityId = (
			SELECT TOP 1 intCustomerEntityId
			FROM tblLGLoadDetail
			WHERE intLoadId = @intTransactionId
			)

	SELECT @strEntityName = strName
	FROM tblEMEntity
	WHERE intEntityId = @intEntityId

	SELECT @strIds = STUFF((
				SELECT DISTINCT ', ' + LTRIM(intEntityContactId)
				FROM vyuCTEntityToContact
				WHERE intEntityId = @intEntityId
				FOR XML PATH('')
				), 1, 2, '')
	FROM vyuCTEntityToContact CH
	WHERE intEntityId = @intEntityId

	SET @Subject = 'Load/Shipment Schedule - ' + @strLoadNumber
	SET @body += '<!DOCTYPE html>'
	SET @body += '<html>'
	SET @body += '<body>Dear <strong>' + @strEntityName + '</strong>, <br><br>'
	SET @body += 'Please use the link below to open your ' + LOWER(@strReportName) + '. <br><br>'
	SET @body += '<p><a href="' + @strHyperLink + '#/LG/Logistics?routeId=' + LTRIM(@intTransactionId) + '">' + @strReportName + ' - ' + @strLoadNumber + '</a></p>'
	SET @body += 'Thank you for your business. <br><br>'
	SET @body += 'Sincerely, <br><br>'
	SET @body += '</html>'
	SET @Filter = '[{"column":"intEntityId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'

	SELECT @Subject AS strSubject
		,@Filter AS strFilters
		,@body AS strMessage
END