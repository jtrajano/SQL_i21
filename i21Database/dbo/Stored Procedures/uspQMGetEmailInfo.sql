CREATE PROCEDURE [dbo].[uspQMGetEmailInfo]
		@strId			NVARCHAR(MAX),
		@strMailType	NVARCHAR(100),
		@strURL	NVARCHAR(MAX),
		@intCurrentUserEntityId int
AS 
BEGIN
	DECLARE @strNumber					NVARCHAR(100),
			@intEntityId				INT,
			@strEntityName				NVARCHAR(200),
			@body						NVARCHAR(MAX) = '',
			@Subject					NVARCHAR(MAX) = '',
			@Filter						NVARCHAR(MAX) = '',
			@strIds						NVARCHAR(MAX),
			@strThanks					NVARCHAR(MAX) = 'Thank you for your business.'

	DECLARE @loop TABLE
	(
		intUniqueId INT IDENTITY(1,1),
		Id INT,
		strNumber NVARCHAR(50)
	)

	IF @strMailType = 'Sample Instruction'
	BEGIN
		INSERT INTO @loop
		SELECT CD.intContractHeaderId,SL.strSampleNumber
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		INNER JOIN vyuQMSampleList SL ON CD.intContractDetailId = SL.intContractDetailId
		WHERE CD.intContractDetailId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END
	ELSE IF @strMailType = 'Sample Print'
	BEGIN
		INSERT INTO @loop
		SELECT intSampleId,strSampleNumber FROM vyuQMSampleList WHERE intSampleId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END

	SELECT @intEntityId = intPartyName
	FROM vyuQMSampleList
	WHERE intSampleId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	OR intContractDetailId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	
	SELECT @strEntityName = strName FROM tblEMEntity WHERE intEntityId = @intEntityId

	SELECT	@strIds	=	STUFF(															
								(
									SELECT	DISTINCT												
											'|^|' +	LTRIM(intEntityContactId)
									FROM	vyuCTEntityToContact 
									WHERE	intEntityId = @intEntityId
									AND		ISNULL(strEmail,'') <> ''
									FOR XML PATH('')
								),1,3, ''
							)
				
	FROM	vyuCTEntityToContact CH
	WHERE	intEntityId = @intEntityId


	SELECT	@strNumber	=	STUFF(															
									(
										SELECT	DISTINCT												
												', ' +	LTRIM(strNumber)
										FROM	@loop
										FOR XML PATH('')
									),1,2, ''
								)

	IF EXISTS ( 
	SELECT	DISTINCT	1 
	FROM	vyuCTEntityToContact 
	WHERE	intEntityId = @intEntityId
	AND		ISNULL(strEmail,'') <> '' 
	AND     strEmail NOT LIKE  '_%@__%.__%' )
	BEGIN 
		RAISERROR('Entity has invalid Email Address.', 16, 1);
		RETURN;
	END

	SET @Subject = 'Quality ' + @strMailType + ' - ' + @strNumber

	SET @body +='<!DOCTYPE html>'
	SET @body +='<html>'
	SET @body +='<body>Dear <strong>'+@strEntityName+'</strong>, <br><br>'
	SET @body += 'Please find the attached ' + LOWER(@strMailType) + '.'
	SET @body += '<br>'
	SET @body +=@strThanks+'<br><br>'
	SET @body +='Sincerely, <br>'
	SET @body +=(select top 1 strName from tblEMEntity where intEntityId = @intCurrentUserEntityId)
	SET @body +='</html>'

	SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'
	
	SELECT @Subject AS strSubject,@Filter AS strFilters,@body AS strMessage
END