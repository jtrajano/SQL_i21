CREATE PROCEDURE [dbo].[uspCTGetTerms]
	@intEntityId	INT,
	@intTermID		INT,
	@strTerm		NVARCHAR(500),
	@ysnActive		BIT	
AS

BEGIN

	IF (SELECT COUNT(*) FROM  tblAPVendorTerm WHERE intEntityVendorId = ISNULL(@intEntityId,0)) <= 1
	BEGIN
		SELECT	TM.intTermID,
				TM.strTerm
		FROM	tblSMTerm	TM
		WHERE	TM.strTerm    LIKE	'%' + @strTerm COLLATE Latin1_General_CI_AS + '%'
		AND		TM.intTermID	=	(CASE WHEN @intTermID > 0 THEN @intTermID ELSE TM.intTermID END)
		AND		TM.ysnActive	=	(CASE WHEN ISNULL(@ysnActive,0) = 0 THEN TM.ysnActive ELSE @ysnActive END)
	END		
	ELSE
	BEGIN
		SELECT	TM.intTermID,
				TM.strTerm
		FROM	tblAPVendorTerm	VT
		JOIN	tblSMTerm	TM ON VT.intTermId = TM.intTermID AND VT.intEntityVendorId = @intEntityId
		WHERE	TM.strTerm	  LIKE	'%' + @strTerm COLLATE Latin1_General_CI_AS + '%'
		AND		TM.intTermID	=	(CASE WHEN @intTermID > 0 THEN @intTermID ELSE TM.intTermID END)
		AND		TM.ysnActive	=	(CASE WHEN ISNULL(@ysnActive,0) = 0 THEN TM.ysnActive ELSE @ysnActive END)
	END

END
