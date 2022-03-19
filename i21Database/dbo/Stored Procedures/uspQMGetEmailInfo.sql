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
			@intUniqueId				INT,
			@Id							INT,
			@routeScreen				NVARCHAR(50),
			@intSalespersonId			INT,
			@strCustomerContract		NVARCHAR(50),
			@strThanks					NVARCHAR(MAX) = 'Thank you for your business.',
			@ysnContractSlspnOnEmail	BIT = 0

	DECLARE @loop TABLE
	(
		intUniqueId INT IDENTITY(1,1),
		Id INT,
		intEntityId INT,
		strNumber NVARCHAR(50),
		intSalespersonId INT
	)

	IF @strMailType = 'SampleInstruction'
	BEGIN
		SET @routeScreen = 'Contract'
		INSERT INTO @loop
		SELECT CD.intContractHeaderId,CH.intEntityId,CH.strContractNumber +'-'+ CAST(CD.intContractSeq AS NVARCHAR(10)) ,CH.intSalespersonId 
		FROM tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE CD.intContractDetailId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END

	IF @strMailType = 'ArrivalForm'
	BEGIN
		SET @routeScreen = 'Quality'
		INSERT INTO @loop
		SELECT intSampleId,intPartyName,strContractNumber,intSalespersonId FROM vyuQMSampleList WHERE intSampleId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END

	SELECT @intEntityId = intEntityId FROM @loop
	SELECT @strEntityName = strName FROM tblEMEntity WHERE intEntityId = @intEntityId

	SELECT @intSalespersonId = intSalespersonId FROM @loop

	IF @strMailType = 'Contract'
	BEGIN
		SELECT	@strIds	=	STUFF(															
										(
											SELECT	DISTINCT												
													'|^|' +	LTRIM(intEntityContactId)
											FROM	vyuCTEntityToContact 
											WHERE	intEntityId = @intEntityId
											AND		ISNULL(strEmail,'') <> ''
											AND		strEmailDistributionOption LIKE '%Contracts%'
											FOR XML PATH('')
										),1,3, ''
									)
				
		FROM	vyuCTEntityToContact CH
		WHERE	intEntityId = @intEntityId
	END
	ELSE
	BEGIN
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
	END
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

	SELECT	@strNumber	=	STUFF(															
									(
										SELECT	DISTINCT												
												', ' +	LTRIM(strNumber)
										FROM	@loop
										FOR XML PATH('')
									),1,2, ''
								)
				
	FROM	@loop CH

	SET @Subject = @strMailType + ' - ' + @strNumber

	IF @strMailType = 'SampleInstruction'
		SELECT @strCustomerContract = isnull(strCustomerContract, '') FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT TOP 1 Id FROM @loop)
	ELSE IF @strMailType = 'ArrivalForm'
		SELECT @strCustomerContract = isnull(strCustomerContract, '') FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT intLinkContractHeaderId FROM vyuQMSampleList WHERE intSampleId = (SELECT TOP 1 Id FROM @loop))

	IF(@strCustomerContract = '')
		SET @Subject = 'Contract' + ' - ' + @strNumber + ' - Sample Instruction'
	ELSE
		SET @Subject = 'Contract' + ' - ' + @strNumber + ' - Sample Instruction - Your ref. no. ' + @strCustomerContract

	SET @body +='<!DOCTYPE html>'
	SET @body +='<html>'
	SET @body +='<body>Dear <strong>'+@strEntityName+'</strong>, <br><br>'

	IF @strCustomerContract = ''
		SELECT  @body += 'Please find attached the sample instructions for contract.'
	ELSE
		SELECT  @body += 'Please find attached the sample instructions for contract - ' + @strNumber + '(Your ref. no. '+ @strCustomerContract +')'

	SET @body += '<br>'
	SET @body +=@strThanks+'<br><br>'
	SET @body +='Sincerely, <br>'
	SET @body +='</html>'

	SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'
	
	SELECT @Subject AS strSubject,@Filter AS strFilters,@body AS strMessage, @intSalespersonId AS intSalespersonId
END