CREATE PROCEDURE [dbo].[uspCTGetEmailInfo]
		@strId			NVARCHAR(MAX),
		@strMailType	NVARCHAR(100),
		@strURL	NVARCHAR(MAX)
AS 
BEGIN
	DECLARE @strNumber		NVARCHAR(100),
			@intEntityId	INT,
			@strEntityName	NVARCHAR(200),
			@body			NVARCHAR(MAX) = '',
			@Subject		NVARCHAR(MAX) = '',
			@Filter			NVARCHAR(MAX) = '',
			@strIds			NVARCHAR(MAX),
			@intUniqueId	INT,
			@Id				INT,
			@routeScreen	NVARCHAR(50),
			@intSalespersonId INT


	DECLARE @loop TABLE
	(
		intUniqueId INT IDENTITY(1,1),
		Id INT,
		intEntityId INT,
		strNumber NVARCHAR(50),
		intSalespersonId INT
	)

	IF @strMailType = 'Contract'
	BEGIN
		SET @routeScreen = 'Contract'
		INSERT INTO @loop
		SELECT intContractHeaderId,intEntityId,strContractNumber,intSalespersonId FROM tblCTContractHeader WHERE intContractHeaderId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END
	ELSE IF @strMailType = 'Price Contract'
	BEGIN
		SET @routeScreen = 'PriceContract'
		INSERT	INTO @loop
		SELECT	PF.intPriceFixationId,
				CH.intEntityId,
				CH.strContractNumber,
				CH.intSalespersonId
		FROM	tblCTContractHeader CH
		JOIN	tblCTPriceFixation	PF	ON	PF.intContractHeaderId	=	CH.intContractHeaderId
		WHERE	PF.intPriceFixationId IN (SELECT * FROM  dbo.fnSplitString(@strId,','))
	END

	SELECT @intEntityId = intEntityId FROM @loop
	SELECT @strEntityName = strName FROM tblEMEntity WHERE intEntityId = @intEntityId

	SELECT @intSalespersonId = intSalespersonId FROM @loop

	SELECT	@strIds	=	STUFF(															
									(
										SELECT	DISTINCT												
												', ' +	LTRIM(intEntityContactId)
										FROM	vyuCTEntityToContact 
										WHERE	intEntityId = @intEntityId
										AND		ISNULL(strEmail,'') <> ''
										AND		strEmailDistributionOption like '%Contracts%'
										FOR XML PATH('')
									),1,2, ''
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
				
	FROM	@loop CH

	SET @Subject = @strMailType + ' - ' + @strNumber

	SET @body +='<!DOCTYPE html>'
	SET @body +='<html>'
	SET @body +='<body>Dear <strong>'+@strEntityName+'</strong>, <br><br>'
	SET @body +='Please use the link below to open your ' + LOWER(@strMailType) + '. <br><br>'
	
	SELECT @intUniqueId = MIN(intUniqueId) FROM @loop
	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@Id = Id,@strNumber = strNumber FROM @loop WHERE intUniqueId = @intUniqueId
		SELECT  @body += '<p><a href="'+@strURL+'#/CT/'+@routeScreen+'?routeId='+LTRIM(@Id)+'">'+@strMailType+' - '+@strNumber+'</a></p>'
		SELECT	@intUniqueId = MIN(intUniqueId) FROM @loop WHERE intUniqueId > @intUniqueId
	END

	SET @body += '<br>'
	SET @body +='Thank you for your business. <br><br>'
	SET @body +='Sincerely, <br>'
	SET @body +='#SIGNATURE#'
	SET @body +='</html>'

	SET @Filter = '[{"column":"intEntityContactId","value":"' + @strIds + '","condition":"eq","conjunction":"and"}]'
	
	SELECT @Subject AS strSubject,@Filter AS strFilters,@body AS strMessage, @intSalespersonId AS intSalespersonId
END